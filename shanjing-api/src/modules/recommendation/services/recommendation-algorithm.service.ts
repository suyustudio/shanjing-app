// ============================================
// 推荐算法服务 - 5因子排序引擎 V1
// ============================================

import { Injectable } from '@nestjs/common';
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
};

const MAX_REFERENCE_DISTANCE_KM = 100;
const FRESHNESS_DECAY_DAYS = 90;

@Injectable()
export class RecommendationAlgorithmService {
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

    const scoredTrails: ScoredTrail[] = [];

    for (const trail of trails) {
      const featureVector = this.extractTrailFeatures(trail);
      
      const factors = {
        difficultyMatch: this.calculateDifficultyMatch(featureVector, userPrefs),
        distance: this.calculateDistanceScore(featureVector, userLat, userLng, trail),
        rating: this.calculateRatingScore(trail),
        popularity: await this.calculatePopularityScore(trail),
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
   * 计算路线的热度分数
   */
  private async calculatePopularityScore(trail: any): Promise<number> {
    // 获取近期完成数（30天内）
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);

    const recentCompletions = await this.prisma.userTrailInteraction.count({
      where: {
        trailId: trail.id,
        interactionType: 'complete',
        createdAt: { gte: thirtyDaysAgo },
      },
    });

    // 获取收藏数
    const bookmarkCount = await this.prisma.userTrailInteraction.count({
      where: {
        trailId: trail.id,
        interactionType: 'bookmark',
      },
    });

    // 热度分 = min(1.0, 近30天完成人数 / 100 + 收藏数 / 50)
    const completionScore = recentCompletions / 100;
    const bookmarkScore = bookmarkCount / 50;
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
}