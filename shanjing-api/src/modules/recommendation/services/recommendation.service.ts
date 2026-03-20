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
  ImpressionDto,
  RecommendationScene,
} from '../dto/recommendation.dto';
import {
  CACHE_TTL_BY_SCENE,
  RECOMMENDATION_CONSTANTS,
  DISTANCE_CONSTANTS,
  LOG_CONTEXT,
  VALIDATION_CONSTRAINTS,
} from '../../../modules/achievements/constants/achievement.constants';
import {
  StructuredLogger,
  createStructuredLogger,
} from '../../../shared/logger/structured-logger.util';

@Injectable()
export class RecommendationService {
  private readonly logger: StructuredLogger;

  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
    private algorithmService: RecommendationAlgorithmService,
    private profileService: UserProfileService,
  ) {
    this.logger = createStructuredLogger(
      new Logger(RecommendationService.name),
      LOG_CONTEXT.RECOMMENDATION_SERVICE,
    );
  }

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

    const timer = this.logger.startTimer('getRecommendations', {
      userId: targetUserId,
      scene,
      hasLocation: !!(lat && lng),
      limit,
    });

    // 尝试从缓存获取
    const cacheKey = this.buildCacheKey(targetUserId, scene, lat, lng, limit);
    const cached = await this.getFromCache(cacheKey);
    if (cached) {
      this.logger.debug('Cache hit for recommendation', {
        userId: targetUserId,
        cacheKey,
        scene,
      });
      timer.end({ source: 'cache', trailCount: cached.trails.length });
      return cached;
    }

    // 获取用户画像
    const profileTimer = this.logger.startTimer('getUserProfile', { userId: targetUserId });
    const userProfile = await this.profileService.getOrCreateProfile(targetUserId);
    const userPrefs = await this.profileService.getUserPreferenceVector(targetUserId);
    profileTimer.end({ isColdStart: userProfile.isColdStart });

    // 获取候选路线
    let candidateTrails: any[] = [];
    const candidateTimer = this.logger.startTimer('getCandidateTrails', { scene });

    if (userProfile.isColdStart && scene !== RecommendationScene.SIMILAR) {
      // 冷启动用户：使用热门路线
      candidateTrails = await this.profileService.getColdStartRecommendations(
        limit * RECOMMENDATION_CONSTANTS.COLD_START_MULTIPLIER,
      );
    } else if (scene === RecommendationScene.SIMILAR && referenceTrailId) {
      // 相似推荐
      candidateTrails = await this.getSimilarTrails(
        referenceTrailId,
        targetUserId,
        limit * RECOMMENDATION_CONSTANTS.COLD_START_MULTIPLIER,
      );
    } else {
      // 正常推荐：获取活跃路线
      candidateTrails = await this.getActiveTrails(
        excludeIds,
        limit * RECOMMENDATION_CONSTANTS.COLD_START_MULTIPLIER,
      );
    }
    candidateTimer.end({ candidateCount: candidateTrails.length });

    // 排除已完成的路线
    const excludeTimer = this.logger.startTimer('excludeCompletedTrails', { userId: targetUserId });
    const completedTrailIds = await this.getCompletedTrailIds(targetUserId);
    candidateTrails = candidateTrails.filter(
      (trail) => !completedTrailIds.includes(trail.id),
    );
    excludeTimer.end({
      beforeCount: candidateTrails.length + completedTrailIds.length,
      afterCount: candidateTrails.length,
    });

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
    const recommendedTrails: RecommendedTrailDto[] = selectedTrails.map((st) => ({
      id: st.trail.id,
      name: st.trail.name,
      coverImage: st.trail.coverImages?.[0] || '',
      distanceKm: st.trail.distanceKm,
      durationMin: st.trail.durationMin,
      difficulty: st.trail.difficulty,
      rating: st.trail.avgRating || RECOMMENDATION_CONSTANTS.DEFAULT_RATING,
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
        results: recommendedTrails.map((t) => ({
          trailId: t.id,
          score: t.matchScore,
          factors: {
            difficultyMatch: t.matchFactors.difficultyMatch,
            distance: t.matchFactors.distance,
            rating: t.matchFactors.rating,
            popularity: t.matchFactors.popularity,
            freshness: t.matchFactors.freshness,
          },
        })) as any,
      },
    });

    const response: RecommendationsResponseDto = {
      algorithm: 'v1_rule_based',
      scene,
      logId: log.id,
      trails: recommendedTrails,
    };

    // 写入缓存（使用场景化TTL）
    await this.setCache(cacheKey, response, scene);

    timer.end({
      trailCount: recommendedTrails.length,
      logId: log.id,
      topScore: recommendedTrails[0]?.matchScore,
    });

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

    const timer = this.logger.startTimer('recordFeedback', {
      userId: currentUserId,
      action,
      trailId,
    });

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
    timer.end({ action, trailId });

    return { success: true };
  }

  /**
   * 记录推荐曝光事件
   */
  async recordImpression(
    dto: ImpressionDto,
    currentUserId?: string,
  ): Promise<{ success: boolean; message: string }> {
    const { scene, trailIds, logId, timestamp } = dto;

    if (!trailIds || trailIds.length === 0) {
      return { success: false, message: 'trailIds cannot be empty' };
    }

    const timer = this.logger.startTimer('recordImpression', {
      userId: currentUserId,
      scene,
      trailCount: trailIds.length,
    });

    try {
      // 批量记录曝光日志
      const impressionData = trailIds.map((trailId) => ({
        userId: currentUserId,
        trailId,
        scene,
        logId,
        timestamp: timestamp ? new Date(timestamp) : new Date(),
      }));

      // 使用事务批量创建曝光记录
      await this.prisma.$transaction(async (tx) => {
        for (const data of impressionData) {
          await tx.recommendationImpression.create({
            data: {
              userId: data.userId,
              trailId: data.trailId,
              scene: data.scene,
              logId: data.logId,
              viewedAt: data.timestamp,
            },
          });
        }
      });

      this.logger.debug('Recorded impressions', {
        userId: currentUserId,
        scene,
        count: trailIds.length,
      });
      timer.end({ count: trailIds.length });

      return {
        success: true,
        message: `Recorded ${trailIds.length} impressions successfully`,
      };
    } catch (error) {
      timer.fail(error instanceof Error ? error : undefined, { trailCount: trailIds.length });
      this.logger.error('Failed to record impression', error, {
        userId: currentUserId,
        scene,
        trailCount: trailIds.length,
      });
      return { success: false, message: (error as Error).message };
    }
  }

  /**
   * 获取相似路线
   */
  private async getSimilarTrails(
    referenceTrailId: string,
    userId: string,
    limit: number,
  ): Promise<any[]> {
    const timer = this.logger.startTimer('getSimilarTrails', {
      referenceTrailId,
      userId,
    });

    const referenceTrail = await this.prisma.trail.findUnique({
      where: { id: referenceTrailId },
    });

    if (!referenceTrail) {
      timer.end({ found: 0 });
      return [];
    }

    // 查找同难度、同区域的路线
    const trails = await this.prisma.trail.findMany({
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

    timer.end({ found: trails.length });
    return trails;
  }

  /**
   * 获取活跃路线
   */
  private async getActiveTrails(
    excludeIds: string[] = [],
    limit: number,
  ): Promise<any[]> {
    // 验证并限制 excludeIds 长度，防止查询过大
    const validatedExcludeIds =
      excludeIds.length > VALIDATION_CONSTRAINTS.MAX_LIMIT
        ? excludeIds.slice(0, VALIDATION_CONSTRAINTS.MAX_LIMIT)
        : excludeIds;

    return this.prisma.trail.findMany({
      where: {
        isActive: true,
        id: { notIn: validatedExcludeIds.length > 0 ? validatedExcludeIds : undefined },
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
    return interactions.map((i) => i.trailId);
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
    const topByScore = scoredTrails.slice(
      0,
      Math.min(RECOMMENDATION_CONSTANTS.HOME_TOP_TRAILS_COUNT, limit),
    );
    for (const trail of topByScore) {
      result.push(trail);
      usedDifficulties.add(trail.trail.difficulty);
    }

    // 第4-5条：适当加入新鲜度高的新路线
    const remaining = scoredTrails.slice(RECOMMENDATION_CONSTANTS.HOME_TOP_TRAILS_COUNT);
    const freshTrails = remaining
      .filter((t) => t.factors.freshness > RECOMMENDATION_CONSTANTS.FRESHNESS_HIGH_THRESHOLD)
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
      .filter(
        (t) =>
          !t.userDistanceM ||
          t.userDistanceM <= RECOMMENDATION_CONSTANTS.NEARBY_MAX_DISTANCE_METERS,
      )
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
    const locationHash =
      lat && lng
        ? `${Math.round(lat * 100) / 100},${Math.round(lng * 100) / 100}`
        : 'none';
    return `${RECOMMENDATION_CONSTANTS.CACHE_PREFIX}${userId}:${scene}:${locationHash}:${limit}`;
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
    scene: RecommendationScene = RecommendationScene.HOME,
  ): Promise<void> {
    try {
      const ttl = CACHE_TTL_BY_SCENE[scene] || CACHE_TTL_BY_SCENE.HOME;
      await this.redis.set(key, JSON.stringify(value), ttl);
    } catch (error) {
      this.logger.warn('Failed to cache recommendation', error, { key });
    }
  }

  private async clearUserCache(userId: string): Promise<void> {
    try {
      const pattern = `${RECOMMENDATION_CONSTANTS.CACHE_PREFIX}${userId}:*`;
      const keys = await this.redis.keys(pattern);
      if (keys.length > 0) {
        await this.redis.del(...keys);
        this.logger.debug('Cleared user cache', { userId, keyCount: keys.length });
      }
    } catch (error) {
      this.logger.warn('Failed to clear cache', error, { userId });
    }
  }
}
