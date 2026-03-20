import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CheckAchievementsDto, TrailStatsDto } from './dto/check-achievements.dto';
import { CheckResultResponseDto, NewlyUnlockedDto, ProgressUpdatedDto } from './dto/check-result-response.dto';
import { AchievementCategory, AchievementLevel } from '@prisma/client';

interface AchievementCheckContext {
  userId: string;
  userStats: any;
  completedTrailIds: string[];
  triggerType: string;
  trailStats?: TrailStatsDto;
}

@Injectable()
export class AchievementsCheckerService {
  private readonly logger = new Logger(AchievementsCheckerService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * 检查并解锁成就
   */
  async checkAchievements(
    userId: string,
    dto: CheckAchievementsDto,
  ): Promise<CheckResultResponseDto> {
    // 获取或初始化用户统计
    let userStats = await this.prisma.userStats.findUnique({
      where: { userId },
    });

    if (!userStats) {
      userStats = await this.prisma.userStats.create({
        data: { userId },
      });
    }

    // 更新用户统计数据
    await this.updateUserStats(userId, dto, userStats);

    // 重新获取更新后的统计
    userStats = await this.prisma.userStats.findUnique({
      where: { userId },
    });

    const context: AchievementCheckContext = {
      userId,
      userStats,
      completedTrailIds: userStats?.completedTrailIds || [],
      triggerType: dto.triggerType,
      trailStats: dto.stats,
    };

    // 获取所有成就定义
    const achievements = await this.prisma.achievement.findMany({
      include: {
        levels: {
          orderBy: { requirement: 'asc' },
        },
      },
    });

    // 获取用户已解锁的成就
    const userAchievements = await this.prisma.userAchievement.findMany({
      where: { userId },
      include: { level: true },
    });

    const newlyUnlocked: NewlyUnlockedDto[] = [];
    const progressUpdated: ProgressUpdatedDto[] = [];

    // 检查每个成就
    for (const achievement of achievements) {
      const userAchievement = userAchievements.find(
        (ua) => ua.achievementId === achievement.id,
      );

      const currentLevelOrder = userAchievement?.level
        ? this.getLevelOrder(userAchievement.level.level)
        : 0;

      // 检查是否可以解锁更高级别
      for (const level of achievement.levels) {
        const levelOrder = this.getLevelOrder(level.level);

        // 只能逐级解锁
        if (levelOrder <= currentLevelOrder) continue;
        if (levelOrder > currentLevelOrder + 1) break;

        const shouldUnlock = this.checkAchievementCondition(
          achievement.category,
          level.requirement,
          context,
        );

        if (shouldUnlock) {
          // 解锁成就
          await this.unlockAchievement(userId, achievement.id, level.id);

          newlyUnlocked.push({
            achievementId: achievement.id,
            level: level.level,
            name: `${achievement.name}·${this.getLevelName(level.level)}`,
            message: this.generateUnlockMessage(achievement, level),
            badgeUrl: level.iconUrl || achievement.iconUrl,
          });

          this.logger.log(
            `User ${userId} unlocked achievement: ${achievement.key} - ${level.level}`,
          );
          break; // 每次只解锁一个等级
        }
      }

      // 计算进度更新
      const progress = this.calculateProgress(achievement.category, context);
      const nextLevel = this.getNextLevel(achievement.levels, progress);

      if (nextLevel) {
        progressUpdated.push({
          achievementId: achievement.id,
          progress,
          requirement: nextLevel.requirement,
          percentage: Math.min(100, Math.round((progress / nextLevel.requirement) * 100)),
        });
      }
    }

    return {
      newlyUnlocked,
      progressUpdated,
    };
  }

  /**
   * 更新用户统计数据
   */
  private async updateUserStats(
    userId: string,
    dto: CheckAchievementsDto,
    currentStats: any,
  ): Promise<void> {
    const updates: any = {};
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());

    if (dto.triggerType === 'trail_completed' && dto.stats) {
      const stats = dto.stats;

      // 更新里程
      updates.totalDistanceM = {
        increment: stats.distance || 0,
      };
      updates.totalDurationSec = {
        increment: stats.duration || 0,
      };

      // 更新路线统计
      if (dto.trailId && !currentStats?.completedTrailIds?.includes(dto.trailId)) {
        updates.uniqueTrailsCount = { increment: 1 };
        updates.completedTrailIds = {
          push: dto.trailId,
        };
      }

      // 更新挑战统计
      if (stats.isNight) {
        updates.nightTrailCount = { increment: 1 };
      }
      if (stats.isRain) {
        updates.rainTrailCount = { increment: 1 };
      }
      if (stats.isSolo) {
        updates.soloTrailCount = { increment: 1 };
      }

      // 更新连续打卡
      await this.updateStreak(userId, currentStats, today);

      // 更新最后徒步日期
      updates.lastTrailDate = today;
    }

    if (dto.triggerType === 'share') {
      updates.shareCount = { increment: 1 };
    }

    if (Object.keys(updates).length > 0) {
      await this.prisma.userStats.update({
        where: { userId },
        data: updates,
      });
    }
  }

  /**
   * 更新连续打卡统计
   */
  private async updateStreak(
    userId: string,
    currentStats: any,
    today: Date,
  ): Promise<void> {
    if (!currentStats?.lastTrailDate) {
      await this.prisma.userStats.update({
        where: { userId },
        data: {
          currentWeeklyStreak: 1,
          longestWeeklyStreak: 1,
        },
      });
      return;
    }

    const lastDate = new Date(currentStats.lastTrailDate);
    const diffDays = Math.floor((today.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24));

    if (diffDays === 0) {
      // 今天已经完成过，不更新
      return;
    }

    // 计算周连续
    const lastWeek = this.getWeekNumber(lastDate);
    const thisWeek = this.getWeekNumber(today);
    const lastYear = lastDate.getFullYear();
    const thisYear = today.getFullYear();

    let newWeeklyStreak = currentStats.currentWeeklyStreak || 0;

    if ((thisYear === lastYear && thisWeek === lastWeek + 1) ||
        (thisYear === lastYear + 1 && lastWeek >= 52 && thisWeek === 1)) {
      // 连续周
      newWeeklyStreak += 1;
    } else if (thisYear !== lastYear || thisWeek !== lastWeek) {
      // 不连续，重置
      newWeeklyStreak = 1;
    }

    const newLongestStreak = Math.max(
      currentStats.longestWeeklyStreak || 0,
      newWeeklyStreak,
    );

    await this.prisma.userStats.update({
      where: { userId },
      data: {
        currentWeeklyStreak: newWeeklyStreak,
        longestWeeklyStreak: newLongestStreak,
      },
    });
  }

  /**
   * 检查成就条件
   */
  private checkAchievementCondition(
    category: AchievementCategory,
    requirement: number,
    context: AchievementCheckContext,
  ): boolean {
    const stats = context.userStats;

    switch (category) {
      case AchievementCategory.explorer:
        return (stats?.uniqueTrailsCount || 0) >= requirement;

      case AchievementCategory.distance:
        return (stats?.totalDistanceM || 0) >= requirement;

      case AchievementCategory.frequency:
        return (stats?.currentWeeklyStreak || 0) >= requirement;

      case AchievementCategory.challenge:
        // 挑战类成就基于不同类型的统计
        if (context.trailStats?.isNight) {
          return (stats?.nightTrailCount || 0) >= requirement;
        }
        if (context.trailStats?.isRain) {
          return (stats?.rainTrailCount || 0) >= requirement;
        }
        return false;

      case AchievementCategory.social:
        return (stats?.shareCount || 0) >= requirement;

      default:
        return false;
    }
  }

  /**
   * 计算当前进度
   */
  private calculateProgress(
    category: AchievementCategory,
    context: AchievementCheckContext,
  ): number {
    const stats = context.userStats;

    switch (category) {
      case AchievementCategory.explorer:
        return stats?.uniqueTrailsCount || 0;
      case AchievementCategory.distance:
        return stats?.totalDistanceM || 0;
      case AchievementCategory.frequency:
        return stats?.currentWeeklyStreak || 0;
      case AchievementCategory.challenge:
        return stats?.nightTrailCount || 0;
      case AchievementCategory.social:
        return stats?.shareCount || 0;
      default:
        return 0;
    }
  }

  /**
   * 解锁成就
   */
  private async unlockAchievement(
    userId: string,
    achievementId: string,
    levelId: string,
  ): Promise<void> {
    const existing = await this.prisma.userAchievement.findFirst({
      where: {
        userId,
        achievementId,
      },
    });

    if (existing) {
      // 升级成就
      await this.prisma.userAchievement.update({
        where: { id: existing.id },
        data: {
          levelId,
          isNew: true,
          isNotified: false,
          unlockedAt: new Date(),
        },
      });
    } else {
      // 新解锁成就
      await this.prisma.userAchievement.create({
        data: {
          userId,
          achievementId,
          levelId,
          isNew: true,
          isNotified: false,
        },
      });
    }
  }

  /**
   * 获取下一等级
   */
  private getNextLevel(
    levels: { level: AchievementLevel; requirement: number }[],
    currentProgress: number,
  ): { level: AchievementLevel; requirement: number } | null {
    for (const level of levels) {
      if (currentProgress < level.requirement) {
        return level;
      }
    }
    return null;
  }

  /**
   * 获取等级顺序
   */
  private getLevelOrder(level: AchievementLevel): number {
    const order = {
      [AchievementLevel.bronze]: 1,
      [AchievementLevel.silver]: 2,
      [AchievementLevel.gold]: 3,
      [AchievementLevel.diamond]: 4,
    };
    return order[level] || 0;
  }

  /**
   * 获取等级名称
   */
  private getLevelName(level: AchievementLevel): string {
    const names = {
      [AchievementLevel.bronze]: '铜',
      [AchievementLevel.silver]: '银',
      [AchievementLevel.gold]: '金',
      [AchievementLevel.diamond]: '钻石',
    };
    return names[level] || level;
  }

  /**
   * 生成解锁消息
   */
  private generateUnlockMessage(
    achievement: { name: string; category: AchievementCategory },
    level: { name: string; description?: string },
  ): string {
    if (level.description) {
      return `恭喜！${level.description}`;
    }
    return `恭喜解锁 ${achievement.name}·${this.getLevelName(level.level)}！`;
  }

  /**
   * 获取周数
   */
  private getWeekNumber(date: Date): number {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil(((+d - +yearStart) / 86400000 + 1) / 7);
  }
}
