// ============================================
// 推荐服务主文件
// ============================================

import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { RedisService } from '../../../shared/redis/redis.service';
import { RecommendationAlgorithmService } from './recommendation-algorithm.service';
import { UserProfileService } from './user-profile.service';
import {
  GetRecommendationsDto,
  RecommendationsResponseDto,
  RecommendedTrailDto,
  MatchFactorsDto,
  FeedbackDto,
  RecommendationScene,
} from '../dto/recommendation.dto';

const CACHE_PREFIX = 'recommendation:';
const CACHE_TTL_SECONDS = 300; // 5分钟缓存

@Injectable()
export class RecommendationService {
  private readonly logger = new Logger(RecommendationService.name);

  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
    private algorithmService: RecommendationAlgorithmService,
    private profileService: UserProfileService,
  ) {}

  /**
   * 获取推荐路线
   */
  async getRecommendations(
    dto: GetRecommendationsDto,
    currentUserId?: string,
  ): Promise<RecommendationsResponseDto> {
    const { userId, scene, lat, lng, limit, excludeIds, referenceTrailId } = dto;
    const targetUserId = userId || currentUserId;

    if (!targetUserId) {
      throw new Error('User ID is required');
    }

    // 尝试从缓存获取
    const cacheKey = this.buildCacheKey(targetUserId, scene, lat, lng, limit);
    const cached = await this.getFromCache(cacheKey);
    if (cached) {
      this.logger.debug(`Cache hit for ${cacheKey}`);
      return cached;
    }

    // 获取用户画像
    const userProfile = await this.profileService.getOrCreateProfile(targetUserId);
    const userPrefs = await this.profileService.getUserPreferenceVector(targetUserId);

    // 获取候选路线
    let candidateTrails: any[] = [];

    if (userProfile.isColdStart && scene !== RecommendationScene.SIMILAR) {
      // 冷启动用户：使用热门路线
      candidateTrails = await this.profileService.getColdStartRecommendations(limit * 3);
    } else if (scene === RecommendationScene.SIMILAR && referenceTrailId) {
      // 相似推荐
      candidateTrails = await this.getSimilarTrails(referenceTrailId, targetUserId, limit * 3);
    } else {
      // 正常推荐：获取活跃路线
      candidateTrails = await this.getActiveTrails(excludeIds, limit * 3);
    }

    // 排除已完成的路线
    const completedTrailIds = await this.getCompletedTrailIds(targetUserId);
    candidateTrails = candidateTrails.filter(
      trail => !completedTrailIds.includes(trail.id)
    );

    // 计算推荐分数
    const scoredTrails = await this.algorithmService.calculateScores(
      candidateTrails,
      userPrefs,
      lat,
      lng,
      scene,
    );

    // 应用场景策略
    const selectedTrails = this.applySceneStrategy(scoredTrails, scene, limit);

    // 转换为响应DTO
    const recommendedTrails: RecommendedTrailDto[] = selectedTrails.map(st => ({
      id: st.trail.id,
      name: st.trail.name,
      coverImage: st.trail.coverImages?.[0] || '',
      distanceKm: st.trail.distanceKm,
      durationMin: st.trail.durationMin,
      difficulty: st.trail.difficulty,
      rating: st.trail.avgRating || 3.5,
      matchScore: st.score,
      matchFactors: {
        difficultyMatch: Math.round(st.factors.difficultyMatch * 100),
        distance: Math.round(st.factors.distance * 100),
        rating: Math.round(st.factors.rating * 100),
        popularity: Math.round(st.factors.popularity * 100),
        freshness: Math.round(st.factors.freshness * 100),
      } as MatchFactorsDto,
      recommendReason: this.algorithmService.generateRecommendReason(st, scene),
      userDistanceM: st.userDistanceM,
    }));

    // 创建推荐日志
    const log = await this.prisma.recommendationLog.create({
      data: {
        userId: targetUserId,
        algorithm: 'v1_rule_based',
        scene,
        contextLat: lat,
        contextLng: lng,
        contextTime: new Date(),
        results: recommendedTrails.map(t => ({
          trailId: t.id,
          score: t.matchScore,
          factors: t.matchFactors,
        })),
      },
    });

    const response: RecommendationsResponseDto = {
      algorithm: 'v1_rule_based',
      scene,
      logId: log.id,
      trails: recommendedTrails,
    };

    // 写入缓存
    await this.setCache(cacheKey, response);

    return response;
  }

  /**
   * 处理用户反馈
   */
  async recordFeedback(
    dto: FeedbackDto,
    currentUserId: string,
  ): Promise<{ success: boolean }> {
    const { action, trailId, logId, durationSec } = dto;

    // 记录交互
    await this.profileService.recordInteraction(
      currentUserId,
      trailId,
      action,
      { durationSec, source: 'recommendation' },
    );

    // 更新推荐日志
    if (logId) {
      await this.prisma.recommendationLog.update({
        where: { id: logId },
        data: {
          userAction: action,
          actionTime: new Date(),
          clickedTrailId: trailId,
        },
      });
    }

    // 清除用户推荐缓存
    await this.clearUserCache(currentUserId);

    return { success: true };
  }

  /**
   * 获取相似路线
   */
  private async getSimilarTrails(
    referenceTrailId: string,
    userId: string,
    limit: number,
  ): Promise<any[]> {
    const referenceTrail = await this.prisma.trail.findUnique({
      where: { id: referenceTrailId },
    });

    if (!referenceTrail) {
      return [];
    }

    // 查找同难度、同区域的路线
    return this.prisma.trail.findMany({
      where: {
        id: { not: referenceTrailId },
        isActive: true,
        OR: [
          { difficulty: referenceTrail.difficulty },
          { city: referenceTrail.city },
          {
            AND: [
              { distanceKm: { gte: referenceTrail.distanceKm * 0.5 } },
              { distanceKm: { lte: referenceTrail.distanceKm * 1.5 } },
            ],
          },
        ],
      },
      take: limit,
    });
  }

  /**
   * 获取活跃路线
   */
  private async getActiveTrails(
    excludeIds: string[] = [],
    limit: number,
  ): Promise<any[]> {
    return this.prisma.trail.findMany({
      where: {
        isActive: true,
        id: { notIn: excludeIds.length > 0 ? excludeIds : undefined },
      },
      take: limit,
    });
  }

  /**
   * 获取用户已完成的路线ID
   */
  private async getCompletedTrailIds(userId: string): Promise<string[]> {
    const interactions = await this.prisma.userTrailInteraction.findMany({
      where: {
        userId,
        interactionType: 'complete',
      },
      select: { trailId: true },
    });
    return interactions.map(i => i.trailId);
  }

  /**
   * 应用场景策略
   */
  private applySceneStrategy(
    scoredTrails: any[],
    scene: RecommendationScene,
    limit: number,
  ): any[] {
    if (scoredTrails.length <= limit) {
      return scoredTrails;
    }

    switch (scene) {
      case RecommendationScene.HOME:
        return this.applyHomeStrategy(scoredTrails, limit);
      case RecommendationScene.NEARBY:
        return this.applyNearbyStrategy(scoredTrails, limit);
      default:
        return scoredTrails.slice(0, limit);
    }
  }

  /**
   * 首页推荐策略
   */
  private applyHomeStrategy(scoredTrails: any[], limit: number): any[] {
    const result: any[] = [];
    const usedDifficulties = new Set<string>();
    
    // 前3条：综合得分最高的路线
    const topByScore = scoredTrails.slice(0, Math.min(3, limit));
    for (const trail of topByScore) {
      result.push(trail);
      usedDifficulties.add(trail.trail.difficulty);
    }

    // 第4-5条：适当加入新鲜度高的新路线
    const remaining = scoredTrails.slice(3);
    const freshTrails = remaining
      .filter(t => t.factors.freshness > 0.7)
      .slice(0, 2);
    
    for (const trail of freshTrails) {
      if (result.length >= limit) break;
      result.push(trail);
    }

    // 补充到limit
    for (const trail of remaining) {
      if (result.length >= limit) break;
      if (!result.includes(trail)) {
        // 避免连续展示同难度
        if (!usedDifficulties.has(trail.trail.difficulty) || result.length >= limit - 1) {
          result.push(trail);
          usedDifficulties.add(trail.trail.difficulty);
        }
      }
    }

    return result;
  }

  /**
   * 附近推荐策略
   */
  private applyNearbyStrategy(scoredTrails: any[], limit: number): any[] {
    // 仅显示50km范围内的路线，按距离排序
    return scoredTrails
      .filter(t => !t.userDistanceM || t.userDistanceM <= 50000)
      .sort((a, b) => (a.userDistanceM || Infinity) - (b.userDistanceM || Infinity))
      .slice(0, limit);
  }

  // ============ 缓存操作 ============

  private buildCacheKey(
    userId: string,
    scene: string,
    lat?: number,
    lng?: number,
    limit?: number,
  ): string {
    const locationHash = lat && lng 
      ? `${Math.round(lat * 100) / 100},${Math.round(lng * 100) / 100}`
      : 'none';
    return `${CACHE_PREFIX}${userId}:${scene}:${locationHash}:${limit}`;
  }

  private async getFromCache(key: string): Promise<RecommendationsResponseDto | null> {
    try {
      const cached = await this.redis.get(key);
      return cached ? JSON.parse(cached) : null;
    } catch {
      return null;
    }
  }

  private async setCache(
    key: string,
    value: RecommendationsResponseDto,
  ): Promise<void> {
    try {
      await this.redis.set(key, JSON.stringify(value), CACHE_TTL_SECONDS);
    } catch (error) {
      this.logger.warn(`Failed to cache recommendation: ${error.message}`);
    }
  }

  private async clearUserCache(userId: string): Promise<void> {
    try {
      const pattern = `${CACHE_PREFIX}${userId}:*`;
      const keys = await this.redis.keys(pattern);
      if (keys.length > 0) {
        await this.redis.del(...keys);
      }
    } catch (error) {
      this.logger.warn(`Failed to clear cache: ${error.message}`);
    }
  }
}