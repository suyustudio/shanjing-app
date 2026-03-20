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

// ============ 算法配置 ============

interface AlgorithmWeights {
  difficultyMatch: number;
  distance: number;
  rating: number;
  popularity: number;
  freshness: number;
}

const DEFAULT_WEIGHTS: AlgorithmWeights = {
  difficultyMatch: 0.25,
  distance: 0.20,
  rating: 0.20,
  popularity: 0.20,
  freshness: 0.15,
};

const NEARBY_WEIGHTS: AlgorithmWeights = {
  difficultyMatch: 0.20,
  distance: 0.40, // 附近场景提升距离权重
  rating: 0.15,
  popularity: 0.15,
  freshness: 0.10,
};

// 难度映射
const DIFFICULTY_MAP: Record<TrailDifficulty, number> = {
  [TrailDifficulty.EASY]: 1,
  [TrailDifficulty.MODERATE]: 2,
  [TrailDifficulty.HARD]: 3,
  [TrailDifficulty.EXPERT]: 4,
};

const MAX_REFERENCE_DISTANCE_KM = 100;
const FRESHNESS_DECAY_DAYS = 90;

// 缓存配置
const POPULARITY_CACHE_TTL = 300; // 5分钟
const RECOMMENDATION_CACHE_TTL = 600; // 10分钟

@Injectable()
export class RecommendationAlgorithmService {
  private readonly logger = new Logger(RecommendationAlgorithmService.name);

  constructor(
    private prisma: PrismaService,
    private redis: RedisService,
  ) {}

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
    const weights = scene === RecommendationScene.NEARBY 
      ? NEARBY_WEIGHTS 
      : DEFAULT_WEIGHTS;

    // 批量获取所有路线的热度数据 - 修复 N+1 查询问题
    const popularityData = await this.batchGetPopularityData(trails.map(t => t.id));

    const scoredTrails: ScoredTrail[] = [];

    for (const trail of trails) {
      const featureVector = this.extractTrailFeatures(trail);
      const popularity = popularityData.get(trail.id) || { completionScore: 0, bookmarkScore: 0 };
      
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
        userDistanceM: userLat && userLng 
          ? this.calculateDistanceM(userLat, userLng, trail.startPointLat, trail.startPointLng)
          : undefined,
      });
    }

    // 按分数降序排序，同分按热度 > 评分 > 距离
    return scoredTrails.sort((a, b) => {
      if (b.score !== a.score) return b.score - a.score;
      if (b.factors.popularity !== a.factors.popularity) {
        return b.factors.popularity - a.factors.popularity;
      }
      if (b.factors.rating !== a.factors.rating) {
        return b.factors.rating - a.factors.rating;
      }
      return (a.userDistanceM || Infinity) - (b.userDistanceM || Infinity);
    });
  }

  // ============ 批量查询优化 (修复 N+1) ============

  /**
   * 批量获取热度数据 - 使用 groupBy 替代循环查询
   * 将 N 次查询优化为 2 次查询
   */
  private async batchGetPopularityData(trailIds: string[]): Promise<Map<string, { completionScore: number; bookmarkScore: number }>> {
    const result = new Map<string, { completionScore: number; bookmarkScore: number }>();
    
    if (trailIds.length === 0) {
      return result;
    }

    // 检查缓存
    const cacheKey = `popularity:batch:${trailIds.sort().join(',')}`;
    const cached = await this.redis.get(cacheKey);
    if (cached) {
      try {
        const parsed = JSON.parse(cached);
        return new Map(Object.entries(parsed));
      } catch {
        // 缓存解析失败，继续查询
      }
    }

    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

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
      const completionMap = new Map(completionCounts.map(c => [c.trailId, c._count.trailId]));
      const bookmarkMap = new Map(bookmarkCounts.map(c => [c.trailId, c._count.trailId]));

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
        POPULARITY_CACHE_TTL,
        JSON.stringify(Object.fromEntries(result))
      );

    } catch (error) {
      this.logger.error('Failed to batch get popularity data', error);
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
      return 0.8;
    }

    const trailDifficulty = feature.difficulty;
    const userDifficulty = prefs.preferredDifficulty;
    const maxDiff = 3; // 最大难度差

    // 计算匹配度：1 - |diff| / maxDiff
    const diff = Math.abs(trailDifficulty - userDifficulty);
    let matchScore = 1 - diff / maxDiff;

    // 用户偏好范围较宽（完成过多种难度），允许 ±1 误差
    const difficultyDist = prefs.difficultyDistribution;
    if (difficultyDist) {
      const uniqueDifficulties = Object.values(difficultyDist).filter(v => v > 0).length;
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
      return 0.5;
    }

    const distanceKm = this.calculateDistanceM(
      userLat, 
      userLng, 
      trail.startPointLat, 
      trail.startPointLng
    ) / 1000;

    // 距离分 = max(0, 1 - 实际距离 / 最大参考距离)
    let score = Math.max(0, 1 - distanceKm / MAX_REFERENCE_DISTANCE_KM);

    // 距离分级加分
    if (distanceKm < 10) score = Math.min(1, score + 0.1);
    else if (distanceKm > 100) score = score * 0.5;

    return score;
  }

  /**
   * 因子3: 评分
   * 计算路线的评分分数
   */
  private calculateRatingScore(trail: any): number {
    // 基础评分（默认3.5分）
    const baseRating = trail.avgRating || 3.5;
    const reviewCount = trail.reviewCount || 0;

    // 评价数过少时给予保底分
    if (reviewCount < 10) {
      return 0.7;
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
    const completionScore = data.completionScore / 100;
    const bookmarkScore = data.bookmarkScore / 50;
    let score = Math.min(1, completionScore * 0.6 + bookmarkScore * 0.4);

    // 新路线保护期（30天内）热度分保底 0.5
    const daysSinceCreated = trail.createdAt 
      ? (Date.now() - new Date(trail.createdAt).getTime()) / (1000 * 60 * 60 * 24)
      : Infinity;
    
    if (daysSinceCreated <= 30) {
      score = Math.max(0.5, score);
    }

    return score;
  }

  /**
   * 因子5: 新鲜度
   * 计算路线的新鲜度分数
   */
  private calculateFreshnessScore(trail: any): number {
    if (!trail.createdAt) {
      return 0.5;
    }

    const daysSinceCreated = 
      (Date.now() - new Date(trail.createdAt).getTime()) / (1000 * 60 * 60 * 24);

    // 新鲜度分 = max(0, 1 - 上线天数 / 90)
    return Math.max(0, 1 - daysSinceCreated / FRESHNESS_DECAY_DAYS);
  }

  // ============ 工具方法 ============

  /**
   * 提取路线特征向量
   */
  private extractTrailFeatures(trail: any): TrailFeatureVector {
    return {
      difficulty: DIFFICULTY_MAP[trail.difficulty as TrailDifficulty] || 2,
      distanceKm: trail.distanceKm || 0,
      rating: trail.avgRating || 3.5,
      popularity: 0, // 需要异步计算
      freshness: 0,  // 需要异步计算
      tags: trail.tags || [],
    };
  }

  /**
   * 计算两点间距离（米）- 使用 Haversine 公式
   */
  private calculateDistanceM(
    lat1: number, 
    lng1: number, 
    lat2: number, 
    lng2: number
  ): number {
    const R = 6371000; // 地球半径（米）
    const φ1 = lat1 * Math.PI / 180;
    const φ2 = lat2 * Math.PI / 180;
    const Δφ = (lat2 - lat1) * Math.PI / 180;
    const Δλ = (lng2 - lng1) * Math.PI / 180;

    const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
              Math.cos(φ1) * Math.cos(φ2) *
              Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));

    return R * c;
  }

  /**
   * 生成推荐理由
   */
  generateRecommendReason(scoredTrail: ScoredTrail, scene: RecommendationScene): string {
    const { factors, userDistanceM } = scoredTrail;
    
    if (scene === RecommendationScene.NEARBY && userDistanceM !== undefined) {
      const distanceKm = (userDistanceM / 1000).toFixed(1);
      return `距离你 ${distanceKm} 公里`;
    }

    if (factors.freshness > 0.8) {
      return '新上线的路线';
    }

    if (factors.difficultyMatch > 0.8 && factors.distance > 0.7) {
      return '符合你的难度偏好，距离合适';
    }

    if (factors.popularity > 0.8) {
      return '近期热门路线';
    }

    if (factors.rating > 0.85) {
      return '高分推荐路线';
    }

    if (userDistanceM !== undefined) {
      const distanceKm = (userDistanceM / 1000).toFixed(1);
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
  }
}
