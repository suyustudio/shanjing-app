// ============================================
// 推荐算法服务 - 5因子排序引擎 V2 (Performance Optimized)
// ============================================

import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { RedisService } from '../../../shared/redis/redis.service';
import { TrailDifficulty } from '@prisma/client';
import {
  ScoredTrail,
  TrailFeatureVector,
  UserPreferenceVector,
  RecommendationScene,
} from '../dto/recommendation.dto';
import {
  RECOMMENDATION_CONSTANTS,
  DIFFICULTY_MAP,
  ALGORITHM_WEIGHTS,
  TIME_CONSTANTS,
  CACHE_TTL,
  DISTANCE_CONSTANTS,
  LOG_CONTEXT,
} from '../../../modules/achievements/constants/achievement.constants';
import {
  StructuredLogger,
  createStructuredLogger,
} from '../../../shared/logger/structured-logger.util';

@Injectable()
export class RecommendationAlgorithmService {
  private readonly logger: StructuredLogger;

  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
  ) {
    this.logger = createStructuredLogger(
      new Logger(RecommendationAlgorithmService.name),
      LOG_CONTEXT.RECOMMENDATION_ALGORITHM_SERVICE,
    );
  }

  // ============ 核心推荐算法 ============

  /**
   * 计算推荐分数
   * @param trails 路线列表
   * @param userPrefs 用户偏好
   * @param userLat 用户纬度
   * @param userLng 用户经度
   * @param scene 推荐场景
   * @returns 带分数的路线列表
   */
  async calculateScores(
    trails: any[],
    userPrefs: UserPreferenceVector,
    userLat?: number,
    userLng?: number,
    scene: RecommendationScene = RecommendationScene.HOME,
  ): Promise<ScoredTrail[]> {
    const timer = this.logger.startTimer('calculateScores', {
      trailCount: trails.length,
      scene,
      hasLocation: !!(userLat && userLng),
    });

    const weights =
      scene === RecommendationScene.NEARBY
        ? ALGORITHM_WEIGHTS.NEARBY
        : ALGORITHM_WEIGHTS.DEFAULT;

    // 批量获取所有路线的热度数据 - 修复 N+1 查询问题
    const popularityData = await this.batchGetPopularityData(trails.map((t) => t.id));

    const scoredTrails: ScoredTrail[] = [];

    for (const trail of trails) {
      const featureVector = this.extractTrailFeatures(trail);
      const popularity = popularityData.get(trail.id) || {
        completionScore: 0,
        bookmarkScore: 0,
      };

      const factors = {
        difficultyMatch: this.calculateDifficultyMatch(featureVector, userPrefs),
        distance: this.calculateDistanceScore(featureVector, userLat, userLng, trail),
        rating: this.calculateRatingScore(trail),
        popularity: this.calculatePopularityScoreFromData(trail, popularity),
        freshness: this.calculateFreshnessScore(trail),
      };

      // 加权总分
      const totalScore =
        factors.difficultyMatch * weights.difficultyMatch +
        factors.distance * weights.distance +
        factors.rating * weights.rating +
        factors.popularity * weights.popularity +
        factors.freshness * weights.freshness;

      scoredTrails.push({
        trail,
        score: Math.round(totalScore * 100),
        factors,
        userDistanceM:
          userLat && userLng
            ? this.calculateDistanceM(userLat, userLng, trail.startPointLat, trail.startPointLng)
            : undefined,
      });
    }

    // 按分数降序排序，同分按热度 > 评分 > 距离
    const sortedTrails = scoredTrails.sort((a, b) => {
      if (b.score !== a.score) return b.score - a.score;
      if (b.factors.popularity !== a.factors.popularity) {
        return b.factors.popularity - a.factors.popularity;
      }
      if (b.factors.rating !== a.factors.rating) {
        return b.factors.rating - a.factors.rating;
      }
      return (a.userDistanceM || Infinity) - (b.userDistanceM || Infinity);
    });

    timer.end({
      outputCount: sortedTrails.length,
      topScore: sortedTrails[0]?.score,
    });

    return sortedTrails;
  }

  // ============ 批量查询优化 (修复 N+1) ============

  /**
   * 批量获取热度数据 - 使用 groupBy 替代循环查询
   * 将 N 次查询优化为 2 次查询
   */
  private async batchGetPopularityData(
    trailIds: string[],
  ): Promise<Map<string, { completionScore: number; bookmarkScore: number }>> {
    const result = new Map<string, { completionScore: number; bookmarkScore: number }>();

    if (trailIds.length === 0) {
      return result;
    }

    const timer = this.logger.startTimer('batchGetPopularityData', {
      trailCount: trailIds.length,
    });

    // 检查缓存
    const cacheKey = `popularity:batch:${trailIds.sort().join(',')}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      try {
        const parsed = JSON.parse(cached);
        timer.end({ source: 'cache', trailCount: trailIds.length });
        return new Map(Object.entries(parsed));
      } catch {
        // 缓存解析失败，继续查询数据库
        this.logger.warn('Failed to parse popularity cache', undefined, { cacheKey });
      }
    }

    const thirtyDaysAgo = new Date(Date.now() - TIME_CONSTANTS.THIRTY_DAYS);

    try {
      // 批量查询 - 2 次 groupBy 替代 N 次 count
      const [completionCounts, bookmarkCounts] = await Promise.all([
        this.prisma.userTrailInteraction.groupBy({
          by: ['trailId'],
          where: {
            trailId: { in: trailIds },
            interactionType: 'complete',
            createdAt: { gte: thirtyDaysAgo },
          },
          _count: { trailId: true },
        }),
        this.prisma.userTrailInteraction.groupBy({
          by: ['trailId'],
          where: {
            trailId: { in: trailIds },
            interactionType: 'bookmark',
          },
          _count: { trailId: true },
        }),
      ]);

      // 构建查询结果映射
      const completionMap = new Map(
        completionCounts.map((c) => [c.trailId, c._count.trailId]),
      );
      const bookmarkMap = new Map(bookmarkCounts.map((c) => [c.trailId, c._count.trailId]));

      for (const trailId of trailIds) {
        const recentCompletions = completionMap.get(trailId) || 0;
        const bookmarkCount = bookmarkMap.get(trailId) || 0;

        result.set(trailId, {
          completionScore: recentCompletions,
          bookmarkScore: bookmarkCount,
        });
      }

      // 写入缓存
      await this.redis.setex(
        cacheKey,
        RECOMMENDATION_CONSTANTS.POPULARITY_CACHE_TTL,
        JSON.stringify(Object.fromEntries(result)),
      );

      timer.end({
        source: 'database',
        trailCount: trailIds.length,
        completionQueries: completionCounts.length,
        bookmarkQueries: bookmarkCounts.length,
      });
    } catch (error) {
      timer.fail(error instanceof Error ? error : undefined, { trailCount: trailIds.length });
      this.logger.error('Failed to batch get popularity data', error, {
        trailCount: trailIds.length,
      });
      // 返回默认值，不阻断推荐流程
      for (const trailId of trailIds) {
        result.set(trailId, { completionScore: 0, bookmarkScore: 0 });
      }
    }

    return result;
  }

  // ============ 因子计算 ============

  /**
   * 因子1: 难度匹配
   * 计算路线难度与用户偏好的匹配程度
   */
  private calculateDifficultyMatch(
    feature: TrailFeatureVector,
    prefs: UserPreferenceVector,
  ): number {
    // 冷启动用户或无偏好，返回默认匹配分
    if (!prefs.preferredDifficulty || prefs.preferredDifficulty === 0) {
      return RECOMMENDATION_CONSTANTS.COLD_START_DEFAULT_MATCH_SCORE;
    }

    const trailDifficulty = feature.difficulty;
    const userDifficulty = prefs.preferredDifficulty;
    const maxDiff = RECOMMENDATION_CONSTANTS.MAX_DIFFICULTY_DIFF;

    // 计算匹配度：1 - |diff| / maxDiff
    const diff = Math.abs(trailDifficulty - userDifficulty);
    let matchScore = 1 - diff / maxDiff;

    // 用户偏好范围较宽（完成过多种难度），允许 ±1 误差
    const difficultyDist = prefs.difficultyDistribution;
    if (difficultyDist) {
      const uniqueDifficulties = Object.values(difficultyDist).filter((v) => v > 0).length;
      if (uniqueDifficulties >= 2 && diff <= 1) {
        matchScore = Math.min(1, matchScore + 0.1);
      }
    }

    return Math.max(0, matchScore);
  }

  /**
   * 因子2: 距离
   * 计算路线与用户的地理距离分数
   */
  private calculateDistanceScore(
    feature: TrailFeatureVector,
    userLat?: number,
    userLng?: number,
    trail?: any,
  ): number {
    // 无法获取位置，返回默认分
    if (!userLat || !userLng || !trail) {
      return RECOMMENDATION_CONSTANTS.DEFAULT_DISTANCE_SCORE;
    }

    const distanceKm =
      this.calculateDistanceM(
        userLat,
        userLng,
        trail.startPointLat,
        trail.startPointLng,
      ) / DISTANCE_CONSTANTS.ONE_KM;

    // 距离分 = max(0, 1 - 实际距离 / 最大参考距离)
    let score = Math.max(
      0,
      1 - distanceKm / RECOMMENDATION_CONSTANTS.MAX_REFERENCE_DISTANCE_KM,
    );

    // 距离分级加分
    if (distanceKm < RECOMMENDATION_CONSTANTS.DISTANCE_BONUS_THRESHOLD_KM) {
      score = Math.min(1, score + 0.1);
    } else if (distanceKm > RECOMMENDATION_CONSTANTS.DISTANCE_PENALTY_THRESHOLD_KM) {
      score = score * 0.5;
    }

    return score;
  }

  /**
   * 因子3: 评分
   * 计算路线的评分分数
   */
  private calculateRatingScore(trail: any): number {
    const baseRating = trail.avgRating || RECOMMENDATION_CONSTANTS.DEFAULT_RATING;
    const reviewCount = trail.reviewCount || 0;

    // 评价数过少时给予保底分
    if (reviewCount < RECOMMENDATION_CONSTANTS.MIN_REVIEW_COUNT) {
      return RECOMMENDATION_CONSTANTS.LOW_REVIEW_COUNT_SCORE;
    }

    return Math.min(1, baseRating / 5.0);
  }

  /**
   * 因子4: 热度
   * 从批量查询数据计算热度分数
   */
  private calculatePopularityScoreFromData(
    trail: any,
    data: { completionScore: number; bookmarkScore: number },
  ): number {
    // 热度分 = min(1.0, 近30天完成人数 / 100 + 收藏数 / 50)
    const completionScore =
      data.completionScore / RECOMMENDATION_CONSTANTS.POPULARITY_COMPLETION_DENOMINATOR;
    const bookmarkScore =
      data.bookmarkScore / RECOMMENDATION_CONSTANTS.POPULARITY_BOOKMARK_DENOMINATOR;
    let score = Math.min(
      1,
      completionScore * RECOMMENDATION_CONSTANTS.POPULARITY_COMPLETION_WEIGHT +
        bookmarkScore * RECOMMENDATION_CONSTANTS.POPULARITY_BOOKMARK_WEIGHT,
    );

    // 新路线保护期（30天内）热度分保底
    const daysSinceCreated = trail.createdAt
      ? (Date.now() - new Date(trail.createdAt).getTime()) / TIME_CONSTANTS.ONE_DAY
      : Infinity;

    if (daysSinceCreated <= RECOMMENDATION_CONSTANTS.NEW_TRAIL_PROTECTION_DAYS) {
      score = Math.max(RECOMMENDATION_CONSTANTS.NEW_TRAIL_BASE_POPULARITY_SCORE, score);
    }

    return score;
  }

  /**
   * 因子5: 新鲜度
   * 计算路线的新鲜度分数
   */
  private calculateFreshnessScore(trail: any): number {
    if (!trail.createdAt) {
      return RECOMMENDATION_CONSTANTS.DEFAULT_FRESHNESS_SCORE;
    }

    const daysSinceCreated =
      (Date.now() - new Date(trail.createdAt).getTime()) / TIME_CONSTANTS.ONE_DAY;

    // 新鲜度分 = max(0, 1 - 上线天数 / 90)
    return Math.max(0, 1 - daysSinceCreated / RECOMMENDATION_CONSTANTS.FRESHNESS_DECAY_DAYS);
  }

  // ============ 工具方法 ============

  /**
   * 提取路线特征向量
   */
  private extractTrailFeatures(trail: any): TrailFeatureVector {
    return {
      difficulty: DIFFICULTY_MAP[trail.difficulty as keyof typeof DIFFICULTY_MAP] || 2,
      distanceKm: trail.distanceKm || 0,
      rating: trail.avgRating || RECOMMENDATION_CONSTANTS.DEFAULT_RATING,
      popularity: 0, // 需要异步计算
      freshness: 0, // 需要异步计算
      tags: trail.tags || [],
    };
  }

  /**
   * 计算两点间距离（米）- 使用 Haversine 公式
   * 注意: 此方法不考虑高程，适用于一般距离计算
   * 对于需要高精度的山地路线，考虑使用更精确的算法
   */
  private calculateDistanceM(
    lat1: number,
    lng1: number,
    lat2: number,
    lng2: number,
  ): number {
    const R = DISTANCE_CONSTANTS.EARTH_RADIUS_METERS;
    const φ1 = (lat1 * Math.PI) / 180;
    const φ2 = (lat2 * Math.PI) / 180;
    const Δφ = ((lat2 - lat1) * Math.PI) / 180;
    const Δλ = ((lng2 - lng1) * Math.PI) / 180;

    const a =
      Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
      Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  /**
   * 生成推荐理由
   */
  generateRecommendReason(scoredTrail: ScoredTrail, scene: RecommendationScene): string {
    const { factors, userDistanceM } = scoredTrail;

    if (scene === RecommendationScene.NEARBY && userDistanceM !== undefined) {
      const distanceKm = (userDistanceM / DISTANCE_CONSTANTS.ONE_KM).toFixed(1);
      return `距离你 ${distanceKm} 公里`;
    }

    if (factors.freshness > RECOMMENDATION_CONSTANTS.FRESHNESS_HIGH_THRESHOLD) {
      return '新上线的路线';
    }

    if (
      factors.difficultyMatch > RECOMMENDATION_CONSTANTS.DIFFICULTY_MATCH_HIGH_THRESHOLD &&
      factors.distance > RECOMMENDATION_CONSTANTS.DISTANCE_HIGH_THRESHOLD
    ) {
      return '符合你的难度偏好，距离合适';
    }

    if (factors.popularity > RECOMMENDATION_CONSTANTS.POPULARITY_HIGH_THRESHOLD) {
      return '近期热门路线';
    }

    if (factors.rating > RECOMMENDATION_CONSTANTS.RATING_HIGH_THRESHOLD) {
      return '高分推荐路线';
    }

    if (userDistanceM !== undefined) {
      const distanceKm = (userDistanceM / DISTANCE_CONSTANTS.ONE_KM).toFixed(1);
      return `距离你 ${distanceKm} 公里`;
    }

    return '为你推荐';
  }

  /**
   * 清除推荐缓存
   */
  async clearRecommendationCache(userId: string): Promise<void> {
    const pattern = `recommendation:*:${userId}:*`;
    await this.redis.delPattern(pattern);
    this.logger.info('Cleared recommendation cache', { userId });
  }
}
