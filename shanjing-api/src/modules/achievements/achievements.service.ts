// ================================================================
// Achievement Service
// 成就系统服务层
// ================================================================

import { Injectable, Logger, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
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
  UpdateUserStatsDto,
} from './dto/achievement.dto';

@Injectable()
export class AchievementsService {
  private readonly logger = new Logger(AchievementsService.name);

  constructor(private readonly prisma: PrismaService) {}

  // ==================== 成就定义查询 ====================

  /**
   * 获取所有成就定义
   */
  async getAllAchievements(): Promise<AchievementDto[]> {
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

    return achievements.map((achievement) => this.mapToAchievementDto(achievement));
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
      throw new NotFoundException('Achievement not found');
    }

    return this.mapToAchievementDto(achievement);
  }

  // ==================== 用户成就查询 ====================

  /**
   * 获取用户成就概览
   */
  async getUserAchievements(userId: string): Promise<UserAchievementSummaryDto> {
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

    return {
      totalCount: allAchievements.length,
      unlockedCount,
      newUnlockedCount,
      achievements,
    };
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
  }

  // ==================== 成就检查与解锁 ====================

  /**
   * 检查并解锁成就
   */
  async checkAchievements(
    userId: string,
    dto: CheckAchievementsRequestDto
  ): Promise<CheckAchievementsResponseDto> {
    const newlyUnlocked: NewlyUnlockedAchievementDto[] = [];
    const progressUpdated: ProgressUpdateDto[] = [];

    // 更新用户统计
    if (dto.triggerType === 'trail_completed' && dto.stats) {
      await this.updateStatsAfterTrail(userId, dto.trailId, dto.stats);
    } else if (dto.triggerType === 'share') {
      await this.incrementShareCount(userId);
    }

    // 获取最新的用户统计
    const userStats = await this.getOrCreateUserStats(userId);

    // 获取所有成就定义
    const allAchievements = await this.prisma.achievement.findMany({
      include: {
        levels: {
          orderBy: {
            requirement: 'asc',
          },
        },
      },
    });

    // 获取用户已解锁的成就
    const userAchievements = await this.prisma.userAchievement.findMany({
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
        // 首次解锁该成就
        const newUserAchievement = await this.prisma.userAchievement.create({
          data: {
            userId,
            achievementId: achievement.id,
            levelId: targetLevel.id,
            progress: currentProgress,
            isNew: true,
          },
          include: {
            level: true,
          },
        });

        newlyUnlocked.push({
          achievementId: achievement.id,
          level: targetLevel.level,
          name: targetLevel.name,
          message: `恭喜！你已完成${achievement.name}成就 - ${targetLevel.name}`,
          badgeUrl: targetLevel.iconUrl || achievement.iconUrl || '',
        });
      } else if (targetLevel.id !== userAchievement.levelId) {
        // 升级到更高等级
        const oldLevelIndex = achievement.levels.findIndex(
          (l) => l.id === userAchievement.levelId
        );
        const newLevelIndex = achievement.levels.findIndex((l) => l.id === targetLevel.id);

        if (newLevelIndex > oldLevelIndex) {
          await this.prisma.userAchievement.update({
            where: { id: userAchievement.id },
            data: {
              levelId: targetLevel.id,
              progress: currentProgress,
              isNew: true,
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
        await this.prisma.userAchievement.update({
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
  }

  // ==================== 用户统计管理 ====================

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
   * 更新用户统计（轨迹完成后调用）
   */
  async updateStatsAfterTrail(
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
    const userStats = await this.getOrCreateUserStats(userId);

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
        // 这里简化处理，实际应该根据完整的连续周逻辑计算
        updateData.currentWeeklyStreak = userStats.currentWeeklyStreak + 1;
        if (updateData.currentWeeklyStreak > userStats.longestWeeklyStreak) {
          updateData.longestWeeklyStreak = updateData.currentWeeklyStreak;
        }
      } else if (diffDays > 1) {
        // 断开了连续
        updateData.currentWeeklyStreak = 1;
      }
    } else {
      updateData.currentWeeklyStreak = 1;
    }

    updateData.lastTrailDate = today;

    // 计算本周和本月次数（简化处理）
    const currentWeek = this.getWeekNumber(today);
    const lastWeek = userStats.lastTrailDate
      ? this.getWeekNumber(new Date(userStats.lastTrailDate))
      : null;

    if (lastWeek === currentWeek) {
      updateData.trailCountThisWeek = { increment: 1 };
    } else {
      updateData.trailCountThisWeek = 1;
    }

    // 更新平均数据
    const totalTrails = (userStats.uniqueTrailsCount || 0) + 1;
    const totalDistanceKm = (userStats.totalDistanceM + stats.distance) / 1000;
    const totalDurationMin = (userStats.totalDurationSec + stats.duration) / 60;

    updateData.avgDistanceKm = totalDistanceKm / totalTrails;
    updateData.avgDurationMin = totalDurationMin / totalTrails;

    await this.prisma.userStats.update({
      where: { userId },
      data: updateData,
    });
  }

  /**
   * 增加分享次数
   */
  async incrementShareCount(userId: string): Promise<void> {
    await this.prisma.userStats.update({
      where: { userId },
      data: {
        shareCount: { increment: 1 },
      },
    });
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
