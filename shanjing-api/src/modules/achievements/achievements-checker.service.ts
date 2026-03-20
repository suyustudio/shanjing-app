// ================================================================
// Achievements Checker Service - Production Fixed Version
// 成就检查服务 - 修复版 (含事务控制)
// 
// 修复内容:
// 1. P0-2: 连续打卡从"按周计算"改为"按天计算" (3/7/30/60/100天)
// 2. P0-3: 分享成就从"分享次数"改为"获得点赞数"
// 3. P1-2: 添加首次徒步成就检查
// 4. CRITICAL: 添加事务控制防止数据不一致
// 5. CRITICAL: 使用 upsert 防止竞态条件导致的重复解锁
// ================================================================

import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { AchievementCategory, AchievementLevelEnum, Prisma } from '@prisma/client';
import {
  AchievementError,
  InvalidTriggerTypeError,
  TransactionError,
  ConcurrentModificationError,
} from './errors';

interface TrailStats {
  distance: number;
  duration: number;
  isNight: boolean;
  isRain: boolean;
  isSolo: boolean;
}

interface CheckAchievementsDto {
  triggerType: 'trail_completed' | 'share' | 'manual' | 'like_received';
  trailId?: string;
  stats?: TrailStats;
  likeCount?: number;
}

interface UnlockedAchievement {
  achievementId: string;
  level: AchievementLevelEnum;
  name: string;
  message: string;
  badgeUrl?: string;
}

@Injectable()
export class AchievementsCheckerService {
  private readonly logger = new Logger(AchievementsCheckerService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * 检查并解锁成就
   * 
   * 关键修复:
   * 1. 使用 $transaction 包裹所有写操作，保证原子性
   * 2. 使用 upsert 替代 create/update，防止竞态条件导致的重复解锁
   * 
   * @param userId 用户ID
   * @param dto 检查请求
   * @returns 新解锁的成就列表
   */
  async checkAchievements(
    userId: string,
    dto: CheckAchievementsDto,
  ): Promise<{ newlyUnlocked: UnlockedAchievement[] }> {
    // 验证触发类型
    const validTriggerTypes = ['trail_completed', 'share', 'manual', 'like_received'];
    if (!validTriggerTypes.includes(dto.triggerType)) {
      throw new InvalidTriggerTypeError(dto.triggerType);
    }

    try {
      // 使用事务包裹所有操作
      return await this.prisma.$transaction(async (tx) => {
        const newlyUnlocked: UnlockedAchievement[] = [];

        // 获取或初始化用户统计 (事务内)
        let userStats = await this.getOrCreateUserStatsTx(tx, userId);

        // 根据触发类型更新统计 (事务内)
        if (dto.triggerType === 'trail_completed' && dto.stats) {
          const wasFirstTrail = userStats.uniqueTrailsCount === 0;
          userStats = await this.updateStatsAfterTrailTx(tx, userId, dto.trailId, dto.stats);
          
          // 检查首次徒步成就 (事务内)
          if (wasFirstTrail || userStats.uniqueTrailsCount === 1) {
            const firstHikeUnlock = await this.checkAndUnlockFirstHikeTx(tx, userId);
            if (firstHikeUnlock) {
              newlyUnlocked.push(firstHikeUnlock);
            }
          }
        } else if (dto.triggerType === 'share') {
          userStats = await this.incrementShareCountTx(tx, userId);
        } else if (dto.triggerType === 'like_received' && dto.likeCount) {
          userStats = await this.updateLikesCountTx(tx, userId, dto.likeCount);
        }

        // 检查各项成就 (事务内)
        const distanceUnlocks = await this.checkDistanceAchievementsTx(tx, userId, userStats);
        const trailUnlocks = await this.checkTrailAchievementsTx(tx, userId, userStats);
        const streakUnlocks = await this.checkStreakAchievementsTx(tx, userId, userStats);
        const socialUnlocks = await this.checkSocialAchievementsTx(tx, userId, userStats);

        newlyUnlocked.push(...distanceUnlocks, ...trailUnlocks, ...streakUnlocks, ...socialUnlocks);

        return { newlyUnlocked };
      }, {
        // 使用 Serializable 隔离级别防止幻读
        isolationLevel: Prisma.TransactionIsolationLevel.Serializable,
        maxWait: 5000,
        timeout: 10000,
      });
    } catch (error) {
      if (error instanceof AchievementError) {
        throw error;
      }

      this.logger.error(`Transaction failed for user ${userId}`, error);

      if (error instanceof Prisma.PrismaClientKnownRequestError) {
        if (error.code === 'P2002') {
          throw new ConcurrentModificationError('user_achievement', userId);
        }
        if (error.code === 'P2003') {
          throw new AchievementError('关联数据不存在', 'FOREIGN_KEY_VIOLATION', 400);
        }
      }

      throw new TransactionError('checkAchievements', error as Error);
    }
  }

  /**
   * P1-2: 检查首次徒步成就 - 事务版本
   */
  private async checkAndUnlockFirstHikeTx(
    tx: Prisma.TransactionClient,
    userId: string
  ): Promise<UnlockedAchievement | null> {
    const achievement = await tx.achievement.findUnique({
      where: { key: 'first_hike' },
      include: { levels: true },
    });

    if (!achievement) return null;

    const bronzeLevel = achievement.levels.find(l => l.level === AchievementLevelEnum.BRONZE);
    if (!bronzeLevel) return null;

    // 使用 upsert 防止竞态条件
    try {
      await tx.userAchievement.upsert({
        where: {
          userId_achievementId: {
            userId,
            achievementId: achievement.id,
          },
        },
        update: {
          // 已存在则不操作
        },
        create: {
          userId,
          achievementId: achievement.id,
          levelId: bronzeLevel.id,
          progress: 1,
          isNew: true,
        },
      });

      // 检查是否是新创建的（通过查询判断）
      const existing = await tx.userAchievement.findUnique({
        where: {
          userId_achievementId: {
            userId,
            achievementId: achievement.id,
          },
        },
      });

      // 如果是刚刚创建的（unlockedAt 在最近几秒内），认为是新解锁
      if (existing && (Date.now() - new Date(existing.unlockedAt).getTime()) < 5000) {
        this.logger.log(`User ${userId} unlocked first hike achievement`);
        return {
          achievementId: achievement.id,
          level: AchievementLevelEnum.BRONZE,
          name: bronzeLevel.name,
          message: `🎉 恭喜解锁「${achievement.name}」成就！迈出了徒步的第一步！`,
          badgeUrl: bronzeLevel.iconUrl || achievement.iconUrl,
        };
      }

      return null;
    } catch (error) {
      this.logger.warn(`First hike achievement upsert conflict for user ${userId}`, error);
      return null;
    }
  }

  /**
   * 检查里程成就 - 事务版本
   */
  private async checkDistanceAchievementsTx(
    tx: Prisma.TransactionClient,
    userId: string,
    userStats: any,
  ): Promise<UnlockedAchievement[]> {
    return this.checkCategoryAchievementsTx(
      tx,
      userId,
      'distance_master',
      userStats.totalDistanceM || 0,
    );
  }

  /**
   * 检查路线收集成就 - 事务版本
   */
  private async checkTrailAchievementsTx(
    tx: Prisma.TransactionClient,
    userId: string,
    userStats: any,
  ): Promise<UnlockedAchievement[]> {
    return this.checkCategoryAchievementsTx(
      tx,
      userId,
      'trail_collector',
      userStats.uniqueTrailsCount || 0,
    );
  }

  /**
   * P0-2 Fix: 检查连续打卡成就（按天计算）- 事务版本
   */
  private async checkStreakAchievementsTx(
    tx: Prisma.TransactionClient,
    userId: string,
    userStats: any,
  ): Promise<UnlockedAchievement[]> {
    return this.checkCategoryAchievementsTx(
      tx,
      userId,
      'streak_master',
      userStats.currentStreak || 0,
    );
  }

  /**
   * P0-3 Fix: 检查社交成就（基于点赞数）- 事务版本
   */
  private async checkSocialAchievementsTx(
    tx: Prisma.TransactionClient,
    userId: string,
    userStats: any,
  ): Promise<UnlockedAchievement[]> {
    const achievement = await tx.achievement.findUnique({
      where: { key: 'social_star' },
      include: { levels: { orderBy: { requirement: 'asc' } } },
    });

    if (!achievement) return [];

    const unlocked: UnlockedAchievement[] = [];
    const shareCount = userStats.shareCount || 0;
    const likeCount = userStats.totalLikesReceived || 0;

    // 获取用户当前成就等级
    const userAchievement = await tx.userAchievement.findUnique({
      where: {
        userId_achievementId: {
          userId,
          achievementId: achievement.id,
        },
      },
      include: { level: true },
    });

    const currentLevelOrder = userAchievement?.level 
      ? this.getLevelOrder(userAchievement.level.level) 
      : 0;

    for (const level of achievement.levels) {
      const levelOrder = this.getLevelOrder(level.level);
      
      // 只能逐级解锁
      if (levelOrder <= currentLevelOrder) continue;
      if (levelOrder > currentLevelOrder + 1) break;

      // 铜银级检查分享次数，金钻级检查点赞数
      let shouldUnlock = false;
      if (level.level === AchievementLevelEnum.BRONZE || level.level === AchievementLevelEnum.SILVER) {
        shouldUnlock = shareCount >= level.requirement;
      } else {
        shouldUnlock = likeCount >= level.requirement;
      }

      if (shouldUnlock) {
        // 使用 upsert 防止竞态条件
        try {
          await tx.userAchievement.upsert({
            where: {
              userId_achievementId: {
                userId,
                achievementId: achievement.id,
              },
            },
            update: {
              levelId: level.id,
              isNew: true,
              unlockedAt: new Date(),
            },
            create: {
              userId,
              achievementId: achievement.id,
              levelId: level.id,
              isNew: true,
            },
          });

          unlocked.push({
            achievementId: achievement.id,
            level: level.level,
            name: level.name,
            message: this.generateUnlockMessage(achievement.name, level.name, level.level),
            badgeUrl: level.iconUrl || achievement.iconUrl,
          });

          this.logger.log(`User ${userId} unlocked social achievement: ${level.level}`);
        } catch (error) {
          this.logger.warn(`Social achievement upsert conflict for user ${userId}`, error);
        }
        break; // 每次只解锁一个等级
      }
    }

    return unlocked;
  }

  /**
   * 通用类别成就检查 - 事务版本
   */
  private async checkCategoryAchievementsTx(
    tx: Prisma.TransactionClient,
    userId: string,
    achievementKey: string,
    currentProgress: number,
  ): Promise<UnlockedAchievement[]> {
    const achievement = await tx.achievement.findUnique({
      where: { key: achievementKey },
      include: { levels: { orderBy: { requirement: 'asc' } } },
    });

    if (!achievement) return [];

    const unlocked: UnlockedAchievement[] = [];

    // 获取用户当前成就等级
    const userAchievement = await tx.userAchievement.findUnique({
      where: {
        userId_achievementId: {
          userId,
          achievementId: achievement.id,
        },
      },
      include: { level: true },
    });

    const currentLevelOrder = userAchievement?.level 
      ? this.getLevelOrder(userAchievement.level.level) 
      : 0;

    for (const level of achievement.levels) {
      const levelOrder = this.getLevelOrder(level.level);
      
      // 只能逐级解锁
      if (levelOrder <= currentLevelOrder) continue;
      if (levelOrder > currentLevelOrder + 1) break;

      if (currentProgress >= level.requirement) {
        // 使用 upsert 防止竞态条件
        try {
          await tx.userAchievement.upsert({
            where: {
              userId_achievementId: {
                userId,
                achievementId: achievement.id,
              },
            },
            update: {
              levelId: level.id,
              isNew: true,
              unlockedAt: new Date(),
            },
            create: {
              userId,
              achievementId: achievement.id,
              levelId: level.id,
              isNew: true,
            },
          });

          unlocked.push({
            achievementId: achievement.id,
            level: level.level,
            name: level.name,
            message: this.generateUnlockMessage(achievement.name, level.name, level.level),
            badgeUrl: level.iconUrl || achievement.iconUrl,
          });

          this.logger.log(`User ${userId} unlocked ${achievementKey}: ${level.level}`);
        } catch (error) {
          this.logger.warn(`${achievementKey} achievement upsert conflict for user ${userId}`, error);
        }
        break; // 每次只解锁一个等级
      }
    }

    return unlocked;
  }

  /**
   * P0-2 Fix: 更新用户统计（按天计算连续打卡）- 事务版本
   */
  private async updateStatsAfterTrailTx(
    tx: Prisma.TransactionClient,
    userId: string,
    trailId: string | undefined,
    stats: TrailStats,
  ): Promise<any> {
    const userStats = await tx.userStats.findUnique({
      where: { userId },
    });

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    if (!userStats) {
      // 首次创建统计
      return tx.userStats.create({
        data: {
          userId,
          totalDistanceM: stats.distance,
          totalDurationSec: stats.duration,
          uniqueTrailsCount: trailId ? 1 : 0,
          completedTrailIds: trailId ? [trailId] : [],
          nightTrailCount: stats.isNight ? 1 : 0,
          rainTrailCount: stats.isRain ? 1 : 0,
          soloTrailCount: stats.isSolo ? 1 : 0,
          currentStreak: 1,
          longestStreak: 1,
          currentWeeklyStreak: 1,
          longestWeeklyStreak: 1,
          lastTrailDate: today,
        },
      });
    }

    // 构建更新数据
    const updateData: any = {
      totalDistanceM: { increment: stats.distance },
      totalDurationSec: { increment: stats.duration },
    };

    // 更新路线统计
    if (trailId) {
      const completedTrailIds = userStats.completedTrailIds || [];
      if (!completedTrailIds.includes(trailId)) {
        updateData.completedTrailIds = { push: trailId };
        updateData.uniqueTrailsCount = { increment: 1 };
      }
    }

    // 更新挑战统计
    if (stats.isNight) updateData.nightTrailCount = { increment: 1 };
    if (stats.isRain) updateData.rainTrailCount = { increment: 1 };
    if (stats.isSolo) updateData.soloTrailCount = { increment: 1 };

    // P0-2 Fix: 按天计算连续打卡
    if (userStats.lastTrailDate) {
      const lastDate = new Date(userStats.lastTrailDate);
      lastDate.setHours(0, 0, 0, 0);

      const diffDays = Math.floor((today.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24));

      if (diffDays === 0) {
        // 今天已完成过，不更新连续天数
      } else if (diffDays === 1) {
        // 连续打卡（昨天有记录）
        const newStreak = (userStats.currentStreak || 0) + 1;
        updateData.currentStreak = newStreak;
        updateData.longestStreak = Math.max(userStats.longestStreak || 0, newStreak);
      } else {
        // 中断后重新开始
        updateData.currentStreak = 1;
      }
    } else {
      updateData.currentStreak = 1;
      updateData.longestStreak = Math.max(userStats.longestStreak || 0, 1);
    }

    updateData.lastTrailDate = today;

    // 同时更新周统计（保留兼容性）
    const lastWeek = userStats.lastTrailDate ? this.getWeekNumber(new Date(userStats.lastTrailDate)) : null;
    const thisWeek = this.getWeekNumber(today);
    
    if (lastWeek === thisWeek) {
      // 同一周
    } else if (lastWeek === thisWeek - 1 || (lastWeek === 52 && thisWeek === 1)) {
      updateData.currentWeeklyStreak = (userStats.currentWeeklyStreak || 0) + 1;
      updateData.longestWeeklyStreak = Math.max(
        userStats.longestWeeklyStreak || 0,
        updateData.currentWeeklyStreak,
      );
    } else {
      updateData.currentWeeklyStreak = 1;
    }

    await tx.userStats.update({
      where: { userId },
      data: updateData,
    });

    return tx.userStats.findUnique({ where: { userId } });
  }

  /**
   * 增加分享次数 - 事务版本
   */
  private async incrementShareCountTx(
    tx: Prisma.TransactionClient,
    userId: string
  ): Promise<any> {
    await tx.userStats.upsert({
      where: { userId },
      create: { userId, shareCount: 1 },
      update: { shareCount: { increment: 1 } },
    });

    return tx.userStats.findUnique({ where: { userId } });
  }

  /**
   * P0-3 Fix: 更新点赞数 - 事务版本
   */
  private async updateLikesCountTx(
    tx: Prisma.TransactionClient,
    userId: string,
    likeCount: number
  ): Promise<any> {
    await tx.userStats.upsert({
      where: { userId },
      create: { userId, totalLikesReceived: likeCount },
      update: { totalLikesReceived: { increment: likeCount } },
    });

    return tx.userStats.findUnique({ where: { userId } });
  }

  /**
   * 获取或创建用户统计 - 事务版本
   */
  private async getOrCreateUserStatsTx(
    tx: Prisma.TransactionClient,
    userId: string
  ): Promise<any> {
    const stats = await tx.userStats.findUnique({
      where: { userId },
    });

    if (stats) return stats;

    return tx.userStats.create({
      data: { userId },
    });
  }

  /**
   * 获取等级顺序
   */
  private getLevelOrder(level: AchievementLevelEnum): number {
    const order = {
      [AchievementLevelEnum.BRONZE]: 1,
      [AchievementLevelEnum.SILVER]: 2,
      [AchievementLevelEnum.GOLD]: 3,
      [AchievementLevelEnum.DIAMOND]: 4,
    };
    return order[level] || 0;
  }

  /**
   * 生成解锁消息
   */
  private generateUnlockMessage(
    achievementName: string,
    levelName: string,
    level: AchievementLevelEnum,
  ): string {
    const levelEmojis = {
      [AchievementLevelEnum.BRONZE]: '🥉',
      [AchievementLevelEnum.SILVER]: '🥈',
      [AchievementLevelEnum.GOLD]: '🥇',
      [AchievementLevelEnum.DIAMOND]: '💎',
    };

    return `${levelEmojis[level]} 恭喜解锁「${achievementName}·${levelName}」！`;
  }

  /**
   * 获取周数（保留兼容性）
   */
  private getWeekNumber(date: Date): number {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
  }
}
