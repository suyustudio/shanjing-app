import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AchievementsCheckerService } from './achievements-checker.service';
import { AchievementsGateway } from './achievements.gateway';
import { CheckAchievementsDto } from './dto/check-achievements.dto';
import { AchievementResponseDto } from './dto/achievement-response.dto';
import { UserAchievementResponseDto, UserAchievementItemDto } from './dto/user-achievement-response.dto';
import { CheckResultResponseDto, NewlyUnlockedDto, ProgressUpdatedDto } from './dto/check-result-response.dto';
import { AchievementCategory, AchievementLevel } from '@prisma/client';

@Injectable()
export class AchievementsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly checker: AchievementsCheckerService,
    private readonly gateway: AchievementsGateway,
  ) {}

  /**
   * 获取所有成就定义
   */
  async getAllAchievements(): Promise<AchievementResponseDto[]> {
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

    return achievements.map((achievement) => ({
      id: achievement.id,
      key: achievement.key,
      name: achievement.name,
      description: achievement.description,
      category: achievement.category,
      iconUrl: achievement.iconUrl,
      isHidden: achievement.isHidden,
      sortOrder: achievement.sortOrder,
      levels: achievement.levels.map((level) => ({
        level: level.level,
        requirement: level.requirement,
        name: level.name,
        description: level.description,
        iconUrl: level.iconUrl,
      })),
    }));
  }

  /**
   * 获取用户成就
   */
  async getUserAchievements(
    userId: string,
    includeHidden: boolean = false,
  ): Promise<UserAchievementResponseDto> {
    // 获取所有成就定义
    const achievements = await this.prisma.achievement.findMany({
      where: includeHidden ? undefined : { isHidden: false },
      include: {
        levels: {
          orderBy: { requirement: 'asc' },
        },
      },
      orderBy: { sortOrder: 'asc' },
    });

    // 获取用户已解锁的成就
    const userAchievements = await this.prisma.userAchievement.findMany({
      where: { userId },
      include: {
        achievement: true,
        level: true,
      },
    });

    // 获取用户统计数据
    const userStats = await this.prisma.userStats.findUnique({
      where: { userId },
    });

    // 构建用户成就列表
    const userAchievementList: UserAchievementItemDto[] = achievements.map((achievement) => {
      const userAchievement = userAchievements.find(
        (ua) => ua.achievementId === achievement.id,
      );

      const currentProgress = this.getProgressForAchievement(
        achievement.category,
        userStats,
      );

      const nextLevel = this.getNextLevel(achievement.levels, currentProgress);
      const percentage = nextLevel
        ? Math.min(100, Math.round((currentProgress / nextLevel.requirement) * 100))
        : 100;

      return {
        achievementId: achievement.id,
        key: achievement.key,
        name: achievement.name,
        category: achievement.category,
        currentLevel: userAchievement?.level?.level || null,
        currentProgress,
        nextRequirement: nextLevel?.requirement || currentProgress,
        percentage,
        unlockedAt: userAchievement?.unlockedAt?.toISOString() || null,
        isNew: userAchievement?.isNew || false,
      };
    });

    const unlockedCount = userAchievementList.filter((ua) => ua.currentLevel !== null).length;
    const newUnlockedCount = userAchievementList.filter((ua) => ua.isNew).length;

    return {
      totalCount: achievements.length,
      unlockedCount,
      newUnlockedCount,
      achievements: userAchievementList,
    };
  }

  /**
   * 检查并解锁成就
   */
  async checkAndUnlockAchievements(
    userId: string,
    dto: CheckAchievementsDto,
  ): Promise<CheckResultResponseDto> {
    const result = await this.checker.checkAchievements(userId, dto);

    // 如果有新解锁的成就，发送实时通知
    if (result.newlyUnlocked.length > 0) {
      for (const unlocked of result.newlyUnlocked) {
        this.gateway.sendAchievementUnlocked(userId, {
          achievementId: unlocked.achievementId,
          level: unlocked.level,
          name: unlocked.name,
          message: unlocked.message,
          badgeUrl: unlocked.badgeUrl,
        });
      }
    }

    return result;
  }

  /**
   * 标记成就已查看
   */
  async markAchievementViewed(
    userId: string,
    achievementId: string,
  ): Promise<{ achievementId: string; isNew: boolean }> {
    await this.prisma.userAchievement.updateMany({
      where: {
        userId,
        achievementId,
      },
      data: {
        isNew: false,
      },
    });

    return {
      achievementId,
      isNew: false,
    };
  }

  /**
   * 获取成就的进度值
   */
  private getProgressForAchievement(
    category: AchievementCategory,
    userStats: any,
  ): number {
    if (!userStats) return 0;

    switch (category) {
      case AchievementCategory.explorer:
        return userStats.uniqueTrailsCount || 0;
      case AchievementCategory.distance:
        return userStats.totalDistanceM || 0;
      case AchievementCategory.frequency:
        return userStats.currentWeeklyStreak || 0;
      case AchievementCategory.challenge:
        return userStats.nightTrailCount || 0;
      case AchievementCategory.social:
        return userStats.shareCount || 0;
      default:
        return 0;
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
   * 初始化用户统计数据（如果不存在）
   */
  async initUserStats(userId: string): Promise<void> {
    const existing = await this.prisma.userStats.findUnique({
      where: { userId },
    });

    if (!existing) {
      await this.prisma.userStats.create({
        data: {
          userId,
        },
      });
    }
  }
}
