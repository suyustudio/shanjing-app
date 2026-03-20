// ================================================================
// Achievement Service
// 成就系统服务层 (Optimized with Transactions & Concurrency Control)
// ================================================================

import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { RedisService } from '../../shared/redis/redis.service';
import {
  AchievementCategory,
  AchievementLevelEnum,
  Prisma,
} from '@prisma/client';
import {
  AchievementDto,
  UserAchievementSummaryDto,
  UserAchievementDto,
  CheckAchievementsRequestDto,
  CheckAchievementsResponseDto,
  NewlyUnlockedAchievementDto,
  ProgressUpdateDto,
  UserStatsDto,
} from './dto/achievement.dto';
import {
  AchievementError,
  AchievementNotFoundError,
  InvalidTriggerTypeError,
  TransactionError,
  ConcurrentModificationError,
} from './errors';

// 缓存配置
const ACHIEVEMENT_CACHE_TTL = 300; // 5分钟
const USER_ACHIEVEMENT_CACHE_TTL = 180; // 3分钟

@Injectable()
export class AchievementsService {
  private readonly logger = new Logger(AchievementsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly redis: RedisService,
  ) {}

  // ==================== 成就定义查询 ====================

  /**
   * 获取所有成就定义
   */
  async getAllAchievements(): Promise<AchievementDto[]> {
    // 尝试从缓存获取
    const cacheKey = 'achievements:all';
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      try {
        return JSON.parse(cached);
      } catch {
        // 缓存解析失败，继续查询数据库
      }
    }

    const achievements = await this.prisma.achievement.findMany({
      include: {
        levels: {
          orderBy: {
            requirement: 'asc',
          },
        },
      },
      orderBy: {
        sortOrder: 'asc',
      },
    });

    const result = achievements.map((achievement) => this.mapToAchievementDto(achievement));
    
    // 写入缓存
    await this.redis.setex(cacheKey, ACHIEVEMENT_CACHE_TTL, JSON.stringify(result));
    
    return result;
  }

  /**
   * 获取单个成就定义
   */
  async getAchievementById(id: string): Promise<AchievementDto> {
    const achievement = await this.prisma.achievement.findUnique({
      where: { id },
      include: {
        levels: {
          orderBy: {
            requirement: 'asc',
          },
        },
      },
    });

    if (!achievement) {
      throw new AchievementNotFoundError(id);
    }

    return this.mapToAchievementDto(achievement);
  }

  // ==================== 用户成就查询 ====================

  /**
   * 获取用户成就概览
   */
  async getUserAchievements(userId: string): Promise<UserAchievementSummaryDto> {
    // 尝试从缓存获取
    const cacheKey = `achievements:user:${userId}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      try {
        return JSON.parse(cached);
      } catch {
        // 缓存解析失败，继续查询
      }
    }

    // 获取所有成就定义
    const allAchievements = await this.prisma.achievement.findMany({
      include: {
        levels: {
          orderBy: {
            requirement: 'asc',
          },
        },
      },
      orderBy: {
        sortOrder: 'asc',
      },
    });

    // 获取用户已解锁的成就
    const userAchievements = await this.prisma.userAchievement.findMany({
      where: { userId },
      include: {
        achievement: true,
        level: true,
      },
    });

    // 获取用户统计
    const userStats = await this.getOrCreateUserStats(userId);

    // 构建成就列表
    const achievements: UserAchievementDto[] = allAchievements.map((achievement) => {
      const userAchievement = userAchievements.find(
        (ua) => ua.achievementId === achievement.id
      );

      return this.buildUserAchievementDto(achievement, userAchievement, userStats);
    });

    // 计算统计数据
    const unlockedCount = achievements.filter((a) => a.isUnlocked).length;
    const newUnlockedCount = userAchievements.filter((ua) => ua.isNew).length;

    const result = {
      totalCount: allAchievements.length,
      unlockedCount,
      newUnlockedCount,
      achievements,
    };

    // 写入缓存
    await this.redis.setex(cacheKey, USER_ACHIEVEMENT_CACHE_TTL, JSON.stringify(result));

    return result;
  }

  /**
   * 标记成就已查看
   */
  async markAchievementViewed(userId: string, achievementId: string): Promise<void> {
    await this.prisma.userAchievement.updateMany({
      where: {
        userId,
        achievementId,
      },
      data: {
        isNew: false,
      },
    });

    // 清除用户成就缓存
    await this.clearUserAchievementCache(userId);
  }

  /**
   * 标记所有新成就已查看
   */
  async markAllAchievementsViewed(userId: string): Promise<void> {
    await this.prisma.userAchievement.updateMany({
      where: {
        userId,
        isNew: true,
      },
      data: {
        isNew: false,
      },
    });

    // 清除用户成就缓存
    await this.clearUserAchievementCache(userId);
  }

  // ==================== 成就检查与解锁 (事务保护) ====================

  /**
   * 检查并解锁成就
   * 
   * 关键修复:
   * 1. 使用 $transaction 包裹所有写操作，保证原子性
   * 2. 使用 upsert 替代 create/update，防止竞态条件导致的重复解锁
   * 3. 添加唯一约束检查 (userId, achievementId) 已在数据库层定义
   */
  async checkAchievements(
    userId: string,
    dto: CheckAchievementsRequestDto
  ): Promise<CheckAchievementsResponseDto> {
    // 验证触发类型
    const validTriggerTypes = ['trail_completed', 'share', 'manual'];
    if (!validTriggerTypes.includes(dto.triggerType)) {
      throw new InvalidTriggerTypeError(dto.triggerType);
    }

    try {
      // 使用事务包裹所有操作
      return await this.prisma.$transaction(async (tx) => {
        const newlyUnlocked: NewlyUnlockedAchievementDto[] = [];
        const progressUpdated: ProgressUpdateDto[] = [];

        // 更新用户统计 (在事务内)
        if (dto.triggerType === 'trail_completed' && dto.stats) {
          await this.updateStatsAfterTrailTx(tx, userId, dto.trailId, dto.stats);
        } else if (dto.triggerType === 'share') {
          await this.incrementShareCountTx(tx, userId);
        }

        // 获取最新的用户统计 (在事务内)
        const userStats = await tx.userStats.findUnique({
          where: { userId },
        });

        if (!userStats) {
          throw new AchievementError('用户统计不存在', 'USER_STATS_NOT_FOUND', 500);
        }

        // 获取所有成就定义
        const allAchievements = await tx.achievement.findMany({
          include: {
            levels: {
              orderBy: {
                requirement: 'asc',
              },
            },
          },
        });

        // 获取用户已解锁的成就 (使用 FOR UPDATE 语义保证一致性)
        const userAchievements = await tx.userAchievement.findMany({
          where: { userId },
          include: {
            level: true,
          },
        });

        // 检查每个成就
        for (const achievement of allAchievements) {
          const currentProgress = this.getProgressForAchievement(achievement.category, userStats);
          const userAchievement = userAchievements.find(
            (ua) => ua.achievementId === achievement.id
          );

          // 计算应该达到的等级
          const targetLevel = this.calculateTargetLevel(achievement.levels, currentProgress);

          if (!targetLevel) {
            // 未解锁任何等级，更新进度
            const nextLevel = achievement.levels[0];
            if (nextLevel) {
              progressUpdated.push({
                achievementId: achievement.id,
                progress: currentProgress,
                requirement: nextLevel.requirement,
                percentage: Math.min(100, Math.round((currentProgress / nextLevel.requirement) * 100)),
              });
            }
            continue;
          }

          if (!userAchievement) {
            // 首次解锁该成就 - 使用 upsert 防止竞态条件
            try {
              await tx.userAchievement.upsert({
                where: {
                  userId_achievementId: {
                    userId,
                    achievementId: achievement.id,
                  },
                },
                update: {
                  // 如果已存在，检查是否需要升级
                  levelId: targetLevel.id,
                  progress: currentProgress,
                  isNew: true,
                  unlockedAt: new Date(),
                },
                create: {
                  userId,
                  achievementId: achievement.id,
                  levelId: targetLevel.id,
                  progress: currentProgress,
                  isNew: true,
                  unlockedAt: new Date(),
                },
              });

              newlyUnlocked.push({
                achievementId: achievement.id,
                level: targetLevel.level,
                name: targetLevel.name,
                message: `恭喜！你已完成${achievement.name}成就 - ${targetLevel.name}`,
                badgeUrl: targetLevel.iconUrl || achievement.iconUrl || '',
              });
            } catch (error) {
              // 唯一约束冲突或其他错误，记录但不中断
              this.logger.warn(`Achievement upsert conflict for user ${userId}, achievement ${achievement.id}`, error);
            }
          } else if (targetLevel.id !== userAchievement.levelId) {
            // 升级到更高等级
            const oldLevelIndex = achievement.levels.findIndex(
              (l) => l.id === userAchievement.levelId
            );
            const newLevelIndex = achievement.levels.findIndex((l) => l.id === targetLevel.id);

            if (newLevelIndex > oldLevelIndex) {
              await tx.userAchievement.update({
                where: { id: userAchievement.id },
                data: {
                  levelId: targetLevel.id,
                  progress: currentProgress,
                  isNew: true,
                  unlockedAt: new Date(),
                },
              });

              newlyUnlocked.push({
                achievementId: achievement.id,
                level: targetLevel.level,
                name: targetLevel.name,
                message: `恭喜升级！你已达到${achievement.name} - ${targetLevel.name}`,
                badgeUrl: targetLevel.iconUrl || achievement.iconUrl || '',
              });
            }
          } else {
            // 更新进度
            await tx.userAchievement.update({
              where: { id: userAchievement.id },
              data: {
                progress: currentProgress,
              },
            });

            // 计算下一级
            const currentLevelIndex = achievement.levels.findIndex(
              (l) => l.id === userAchievement.levelId
            );
            const nextLevel = achievement.levels[currentLevelIndex + 1];

            if (nextLevel) {
              progressUpdated.push({
                achievementId: achievement.id,
                progress: currentProgress,
                requirement: nextLevel.requirement,
                percentage: Math.min(
                  100,
                  Math.round(
                    ((currentProgress - targetLevel.requirement) /
                      (nextLevel.requirement - targetLevel.requirement)) *
                      100
                  )
                ),
              });
            }
          }
        }

        return {
          newlyUnlocked,
          progressUpdated,
        };
      }, {
        // 使用 Serializable 隔离级别防止幻读
        isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
        // 重试配置
        maxWait: 5000,
        timeout: 10000,
      });
    } catch (error) {
      if (error instanceof AchievementError) {
        throw error;
      }
      
      this.logger.error(`Transaction failed for user ${userId}`, error);
      
      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        // 唯一约束冲突 (P2002)
        if (error.code === 'P2002') {
          throw new ConcurrentModificationError('user_achievement', userId);
        }
        // 外键约束冲突 (P2003)
        if (error.code === 'P2003') {
          throw new AchievementError('关联数据不存在', 'FOREIGN_KEY_VIOLATION', 400);
        }
      }
      
      throw new TransactionError('checkAchievements', error as Error);
    } finally {
      // 清除用户成就缓存 (无论成功与否都清除，确保数据一致性)
      await this.clearUserAchievementCache(userId);
    }
  }

  // ==================== 用户统计管理 (事务版本) ====================

  /**
   * 获取或创建用户统计
   */
  async getOrCreateUserStats(userId: string) {
    let stats = await this.prisma.userStats.findUnique({
      where: { userId },
    });

    if (!stats) {
      stats = await this.prisma.userStats.create({
        data: {
          userId,
        },
      });
    }

    return stats;
  }

  /**
   * 获取用户统计
   */
  async getUserStats(userId: string): Promise<UserStatsDto> {
    const stats = await this.getOrCreateUserStats(userId);

    return {
      totalDistanceM: stats.totalDistanceM,
      totalDurationSec: stats.totalDurationSec,
      totalElevationGainM: stats.totalElevationGainM,
      uniqueTrailsCount: stats.uniqueTrailsCount,
      currentWeeklyStreak: stats.currentWeeklyStreak,
      longestWeeklyStreak: stats.longestWeeklyStreak,
      nightTrailCount: stats.nightTrailCount,
      rainTrailCount: stats.rainTrailCount,
      shareCount: stats.shareCount,
    };
  }

  /**
   * 更新用户统计（轨迹完成后调用）- 事务版本
   */
  private async updateStatsAfterTrailTx(
    tx: Prisma.TransactionClient,
    userId: string,
    trailId: string | undefined,
    stats: {
      distance: number;
      duration: number;
      isNight: boolean;
      isRain: boolean;
      isSolo: boolean;
    }
  ): Promise<void> {
    const userStats = await tx.userStats.findUnique({
      where: { userId },
    });

    if (!userStats) {
      // 创建新统计
      await tx.userStats.create({
        data: {
          userId,
          totalDistanceM: stats.distance,
          totalDurationSec: stats.duration,
          uniqueTrailsCount: trailId ? 1 : 0,
          completedTrailIds: trailId ? [trailId] : [],
          nightTrailCount: stats.isNight ? 1 : 0,
          rainTrailCount: stats.isRain ? 1 : 0,
          soloTrailCount: stats.isSolo ? 1 : 0,
          currentWeeklyStreak: 1,
          longestWeeklyStreak: 1,
          lastTrailDate: new Date(),
        },
      });
      return;
    }

    // 构建更新数据
    const updateData: Prisma.UserStatsUpdateInput = {
      totalDistanceM: { increment: stats.distance },
      totalDurationSec: { increment: stats.duration },
    };

    // 更新路线统计
    if (trailId) {
      const completedTrailIds = userStats.completedTrailIds || [];
      if (!completedTrailIds.includes(trailId)) {
        updateData.completedTrailIds = {
          push: trailId,
        };
        updateData.uniqueTrailsCount = { increment: 1 };
      }
    }

    // 更新挑战统计
    if (stats.isNight) {
      updateData.nightTrailCount = { increment: 1 };
    }
    if (stats.isRain) {
      updateData.rainTrailCount = { increment: 1 };
    }
    if (stats.isSolo) {
      updateData.soloTrailCount = { increment: 1 };
    }

    // 更新频率统计
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (userStats.lastTrailDate) {
      const lastDate = new Date(userStats.lastTrailDate);
      lastDate.setHours(0, 0, 0, 0);

      const diffDays = Math.floor((today.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24));

      if (diffDays === 1) {
        // 连续徒步，增加周连续数
        updateData.currentWeeklyStreak = userStats.currentWeeklyStreak + 1;
        if ((updateData.currentWeeklyStreak as number) > userStats.longestWeeklyStreak) {
          updateData.longestWeeklyStreak = updateData.currentWeeklyStreak as number;
        }
      } else if (diffDays > 1) {
        // 断开了连续
        updateData.currentWeeklyStreak = 1;
      }
    } else {
      updateData.currentWeeklyStreak = 1;
    }

    updateData.lastTrailDate = today;

    // 计算本周和本月次数（简化处理）- 这些字段在schema中不存在，暂时注释
    // const currentWeek = this.getWeekNumber(today);
    // const lastWeek = userStats.lastTrailDate
    //   ? this.getWeekNumber(new Date(userStats.lastTrailDate))
    //   : null;

    // if (lastWeek === currentWeek) {
    //   updateData.trailCountThisWeek = { increment: 1 };
    // } else {
    //   updateData.trailCountThisWeek = 1;
    // }

    // 更新平均数据
    const totalTrails = (userStats.uniqueTrailsCount || 0) + (trailId && !userStats.completedTrailIds?.includes(trailId) ? 1 : 0);
    if (totalTrails > 0) {
      const totalDistanceKm = (userStats.totalDistanceM + stats.distance) / 1000;
      const totalDurationMin = (userStats.totalDurationSec + stats.duration) / 60;
      updateData.avgDistanceKm = totalDistanceKm / totalTrails;
      updateData.avgDurationMin = totalDurationMin / totalTrails;
    }

    await tx.userStats.update({
      where: { userId },
      data: updateData,
    });
  }

  /**
   * 增加分享次数 - 事务版本
   */
  private async incrementShareCountTx(tx: Prisma.TransactionClient, userId: string): Promise<void> {
    const userStats = await tx.userStats.findUnique({
      where: { userId },
    });

    if (!userStats) {
      await tx.userStats.create({
        data: {
          userId,
          shareCount: 1,
        },
      });
      return;
    }

    await tx.userStats.update({
      where: { userId },
      data: {
        shareCount: { increment: 1 },
      },
    });
  }

  // ==================== 缓存管理 ====================

  /**
   * 清除用户成就缓存
   */
  private async clearUserAchievementCache(userId: string): Promise<void> {
    const cacheKey = `achievements:user:${userId}`;
    await this.redis.del(cacheKey);
  }

  /**
   * 清除所有成就缓存
   */
  async clearAllAchievementCache(): Promise<void> {
    await this.redis.del('achievements:all');
  }

  // ==================== 辅助方法 ====================

  /**
   * 将数据库成就映射为DTO
   */
  private mapToAchievementDto(achievement: any): AchievementDto {
    return {
      id: achievement.id,
      key: achievement.key,
      name: achievement.name,
      description: achievement.description || undefined,
      category: achievement.category,
      iconUrl: achievement.iconUrl || undefined,
      isHidden: achievement.isHidden,
      sortOrder: achievement.sortOrder,
      levels: achievement.levels.map((level: any) => ({
        id: level.id,
        level: level.level,
        requirement: level.requirement,
        name: level.name,
        description: level.description || undefined,
        reward: level.reward || undefined,
        iconUrl: level.iconUrl || undefined,
      })),
    };
  }

  /**
   * 构建用户成就DTO
   */
  private buildUserAchievementDto(
    achievement: any,
    userAchievement: any,
    userStats: any
  ): UserAchievementDto {
    const currentProgress = this.getProgressForAchievement(achievement.category, userStats);
    const isUnlocked = !!userAchievement;
    const currentLevel = userAchievement?.level;

    // 计算下一级需求
    let nextRequirement = achievement.levels[0]?.requirement || 0;
    if (currentLevel) {
      const currentLevelIndex = achievement.levels.findIndex(
        (l: any) => l.id === currentLevel.id
      );
      const nextLevel = achievement.levels[currentLevelIndex + 1];
      nextRequirement = nextLevel?.requirement || currentLevel.requirement;
    }

    // 计算百分比
    let percentage = 0;
    if (currentLevel) {
      const currentLevelIndex = achievement.levels.findIndex(
        (l: any) => l.id === currentLevel.id
      );
      const nextLevel = achievement.levels[currentLevelIndex + 1];
      if (nextLevel) {
        percentage = Math.min(
          100,
          Math.round(
            ((currentProgress - currentLevel.requirement) /
              (nextLevel.requirement - currentLevel.requirement)) *
              100
          )
        );
      } else {
        percentage = 100;
      }
    } else {
      percentage = Math.min(
        100,
        Math.round((currentProgress / nextRequirement) * 100)
      );
    }

    return {
      achievementId: achievement.id,
      key: achievement.key,
      name: achievement.name,
      category: achievement.category,
      currentLevel: currentLevel?.name,
      currentProgress,
      nextRequirement,
      percentage,
      unlockedAt: userAchievement?.unlockedAt,
      isNew: userAchievement?.isNew || false,
      isUnlocked,
    };
  }

  /**
   * 获取指定类别的当前进度
   */
  private getProgressForAchievement(category: AchievementCategory, userStats: any): number {
    switch (category) {
      case AchievementCategory.EXPLORER:
        return userStats.uniqueTrailsCount || 0;
      case AchievementCategory.DISTANCE:
        return userStats.totalDistanceM || 0;
      case AchievementCategory.FREQUENCY:
        return userStats.currentWeeklyStreak || 0;
      case AchievementCategory.CHALLENGE:
        // 挑战类使用夜间徒步次数作为示例
        return userStats.nightTrailCount || 0;
      case AchievementCategory.SOCIAL:
        return userStats.shareCount || 0;
      default:
        return 0;
    }
  }

  /**
   * 计算目标等级
   */
  private calculateTargetLevel(
    levels: any[],
    currentProgress: number
  ): any | null {
    let targetLevel = null;
    for (const level of levels) {
      if (currentProgress >= level.requirement) {
        targetLevel = level;
      } else {
        break;
      }
    }
    return targetLevel;
  }

  /**
   * 获取周数
   */
  private getWeekNumber(date: Date): number {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
  }
}
