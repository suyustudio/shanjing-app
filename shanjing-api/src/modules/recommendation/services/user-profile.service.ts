// ============================================
// 用户画像服务
// ============================================

import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { UserPreferenceVector } from '../dto/recommendation.dto';
import { TrailDifficulty } from '@prisma/client';

@Injectable()
export class UserProfileService {
  constructor(private prisma: PrismaService) {}

  /**
   * 获取或创建用户画像
   */
  async getOrCreateProfile(userId: string) {
    let profile = await this.prisma.userProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      profile = await this.prisma.userProfile.create({
        data: {
          userId,
          isColdStart: true,
        },
      });
    }

    return profile;
  }

  /**
   * 获取用户偏好向量
   */
  async getUserPreferenceVector(userId: string): Promise<UserPreferenceVector> {
    const profile = await this.getOrCreateProfile(userId);

    // 如果是冷启动用户，返回空偏好
    if (profile.isColdStart) {
      return {
        preferredDifficulty: 0,
        preferredMinDistance: 0,
        preferredMaxDistance: 0,
        preferredTags: [],
        difficultyDistribution: {},
      };
    }

    return {
      preferredDifficulty: profile.preferredDifficulty 
        ? this.difficultyToNumber(profile.preferredDifficulty as TrailDifficulty)
        : 0,
      preferredMinDistance: profile.preferredMinDistanceKm || 0,
      preferredMaxDistance: profile.preferredMaxDistanceKm || 0,
      preferredTags: profile.preferredTags || [],
      difficultyDistribution: (profile.difficultyVector as Record<string, number>) || {},
    };
  }

  /**
   * 更新用户画像
   * 基于用户历史行为重新计算画像
   */
  async updateProfile(userId: string): Promise<void> {
    // 获取用户完成的路线
    const completedInteractions = await this.prisma.userTrailInteraction.findMany({
      where: {
        userId,
        interactionType: 'complete',
      },
      include: {
        trail: true,
      },
      orderBy: {
        createdAt: 'desc',
      },
    });

    if (completedInteractions.length === 0) {
      // 无历史数据，保持冷启动状态
      await this.prisma.userProfile.update({
        where: { userId },
        data: { isColdStart: true },
      });
      return;
    }

    // 计算偏好难度（加权平均）
    const difficultyCounts: Record<string, number> = {};
    let totalDistance = 0;
    let totalDuration = 0;
    const allTags: string[] = [];

    for (const interaction of completedInteractions) {
      const trail = interaction.trail;
      if (!trail) continue;

      // 统计难度分布
      difficultyCounts[trail.difficulty] = (difficultyCounts[trail.difficulty] || 0) + 1;

      // 累计距离和时长
      totalDistance += trail.distanceKm || 0;
      totalDuration += trail.durationMin || 0;

      // 收集标签
      if (trail.tags) {
        allTags.push(...trail.tags);
      }
    }

    // 计算偏好难度（出现次数最多的）
    const preferredDifficulty = Object.entries(difficultyCounts)
      .sort((a, b) => b[1] - a[1])[0]?.[0] || 'MODERATE';

    // 计算难度分布比例
    const totalCount = completedInteractions.length;
    const difficultyDistribution: Record<string, number> = {};
    for (const [diff, count] of Object.entries(difficultyCounts)) {
      difficultyDistribution[diff] = count / totalCount;
    }

    // 计算平均距离和偏好范围
    const avgDistance = totalDistance / totalCount;
    const distances = completedInteractions
      .map(i => i.trail?.distanceKm || 0)
      .filter(d => d > 0)
      .sort((a, b) => a - b);
    
    const minDistance = distances[0] || avgDistance * 0.5;
    const maxDistance = distances[distances.length - 1] || avgDistance * 1.5;

    // 统计热门标签
    const tagCounts: Record<string, number> = {};
    for (const tag of allTags) {
      tagCounts[tag] = (tagCounts[tag] || 0) + 1;
    }
    const preferredTags = Object.entries(tagCounts)
      .sort((a, b) => b[1] - a[1])
      .slice(0, 5)
      .map(([tag]) => tag);

    // 获取用户评分数据
    const ratings = await this.prisma.userTrailInteraction.findMany({
      where: {
        userId,
        interactionType: 'rate',
        rating: { not: null },
      },
    });

    const avgRatingGiven = ratings.length > 0
      ? ratings.reduce((sum, r) => sum + (r.rating || 0), 0) / ratings.length
      : null;

    // 更新用户画像
    await this.prisma.userProfile.update({
      where: { userId },
      data: {
        preferredDifficulty,
        preferredMinDistanceKm: minDistance,
        preferredMaxDistanceKm: maxDistance,
        preferredTags,
        totalCompletedTrails: totalCount,
        totalDistanceKm: totalDistance,
        totalDurationMin: totalDuration,
        difficultyVector: difficultyDistribution,
        tagVector: tagCounts,
        avgRatingGiven,
        isColdStart: totalCount < 3, // 完成少于3条路线视为冷启动
      },
    });
  }

  /**
   * 记录用户行为
   */
  async recordInteraction(
    userId: string,
    trailId: string,
    interactionType: string,
    metadata?: {
      rating?: number;
      durationSec?: number;
      source?: string;
    },
  ): Promise<void> {
    // 创建交互记录
    await this.prisma.userTrailInteraction.upsert({
      where: {
        userId_trailId_interactionType: {
          userId,
          trailId,
          interactionType,
        },
      },
      update: {
        rating: metadata?.rating,
        durationSec: metadata?.durationSec,
      },
      create: {
        userId,
        trailId,
        interactionType,
        rating: metadata?.rating,
        durationSec: metadata?.durationSec,
        source: metadata?.source,
      },
    });

    // 如果是完成或评分行为，更新用户画像
    if (interactionType === 'complete' || interactionType === 'rate') {
      await this.updateProfile(userId);
    }
  }

  /**
   * 获取冷启动推荐（新用户）
   */
  async getColdStartRecommendations(limit: number = 10): Promise<any[]> {
    // 获取热门路线（按近期完成数 + 收藏数排序）
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const popularTrails = await this.prisma.trail.findMany({
      where: { isActive: true },
      take: limit * 2,
      orderBy: { createdAt: 'desc' },
      include: {
        _count: {
          select: {
            favorites: true,
          },
        },
      },
    });

    // 获取近30天完成数
    const trailIds = popularTrails.map(t => t.id);
    const completionCounts = await this.prisma.userTrailInteraction.groupBy({
      by: ['trailId'],
      where: {
        trailId: { in: trailIds },
        interactionType: 'complete',
        createdAt: { gte: thirtyDaysAgo },
      },
      _count: { trailId: true },
    });

    const completionMap = new Map(
      completionCounts.map(c => [c.trailId, c._count.trailId])
    );

    // 按热度排序
    return popularTrails
      .map(trail => ({
        ...trail,
        popularityScore: (completionMap.get(trail.id) || 0) + trail._count.favorites,
      }))
      .sort((a, b) => b.popularityScore - a.popularityScore)
      .slice(0, limit);
  }

  // ============ 辅助方法 ============

  private difficultyToNumber(difficulty: TrailDifficulty): number {
    const map: Record<TrailDifficulty, number> = {
      [TrailDifficulty.EASY]: 1,
      [TrailDifficulty.MODERATE]: 2,
      [TrailDifficulty.HARD]: 3,
      [TrailDifficulty.EXPERT]: 4,
    };
    return map[difficulty] || 2;
  }
}