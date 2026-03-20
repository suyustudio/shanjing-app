"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var RecommendationAlgorithmService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RecommendationAlgorithmService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../../database/prisma.service");
const redis_service_1 = require("../../../shared/redis/redis.service");
const recommendation_dto_1 = require("../dto/recommendation.dto");
const achievement_constants_1 = require("../../../modules/achievements/constants/achievement.constants");
const structured_logger_util_1 = require("../../../shared/logger/structured-logger.util");
let RecommendationAlgorithmService = RecommendationAlgorithmService_1 = class RecommendationAlgorithmService {
    constructor(prisma, redis) {
        this.prisma = prisma;
        this.redis = redis;
        this.logger = (0, structured_logger_util_1.createStructuredLogger)(new common_1.Logger(RecommendationAlgorithmService_1.name), achievement_constants_1.LOG_CONTEXT.RECOMMENDATION_ALGORITHM_SERVICE);
    }
    async calculateScores(trails, userPrefs, userLat, userLng, scene = recommendation_dto_1.RecommendationScene.HOME) {
        const timer = this.logger.startTimer('calculateScores', {
            trailCount: trails.length,
            scene,
            hasLocation: !!(userLat && userLng),
        });
        const weights = scene === recommendation_dto_1.RecommendationScene.NEARBY
            ? achievement_constants_1.ALGORITHM_WEIGHTS.NEARBY
            : achievement_constants_1.ALGORITHM_WEIGHTS.DEFAULT;
        const popularityData = await this.batchGetPopularityData(trails.map((t) => t.id));
        const scoredTrails = [];
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
            const totalScore = factors.difficultyMatch * weights.difficultyMatch +
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
        const sortedTrails = scoredTrails.sort((a, b) => {
            if (b.score !== a.score)
                return b.score - a.score;
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
    async batchGetPopularityData(trailIds) {
        const result = new Map();
        if (trailIds.length === 0) {
            return result;
        }
        const timer = this.logger.startTimer('batchGetPopularityData', {
            trailCount: trailIds.length,
        });
        const cacheKey = `popularity:batch:${trailIds.sort().join(',')}`;
        const cached = await this.redis.get(cacheKey);
        if (cached) {
            try {
                const parsed = JSON.parse(cached);
                timer.end({ source: 'cache', trailCount: trailIds.length });
                return new Map(Object.entries(parsed));
            }
            catch {
                this.logger.warn('Failed to parse popularity cache', undefined, { cacheKey });
            }
        }
        const thirtyDaysAgo = new Date(Date.now() - achievement_constants_1.TIME_CONSTANTS.THIRTY_DAYS);
        try {
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
            const completionMap = new Map(completionCounts.map((c) => [c.trailId, c._count.trailId]));
            const bookmarkMap = new Map(bookmarkCounts.map((c) => [c.trailId, c._count.trailId]));
            for (const trailId of trailIds) {
                const recentCompletions = completionMap.get(trailId) || 0;
                const bookmarkCount = bookmarkMap.get(trailId) || 0;
                result.set(trailId, {
                    completionScore: recentCompletions,
                    bookmarkScore: bookmarkCount,
                });
            }
            await this.redis.setex(cacheKey, achievement_constants_1.RECOMMENDATION_CONSTANTS.POPULARITY_CACHE_TTL, JSON.stringify(Object.fromEntries(result)));
            timer.end({
                source: 'database',
                trailCount: trailIds.length,
                completionQueries: completionCounts.length,
                bookmarkQueries: bookmarkCounts.length,
            });
        }
        catch (error) {
            timer.fail(error instanceof Error ? error : undefined, { trailCount: trailIds.length });
            this.logger.error('Failed to batch get popularity data', error, {
                trailCount: trailIds.length,
            });
            for (const trailId of trailIds) {
                result.set(trailId, { completionScore: 0, bookmarkScore: 0 });
            }
        }
        return result;
    }
    calculateDifficultyMatch(feature, prefs) {
        if (!prefs.preferredDifficulty || prefs.preferredDifficulty === 0) {
            return achievement_constants_1.RECOMMENDATION_CONSTANTS.COLD_START_DEFAULT_MATCH_SCORE;
        }
        const trailDifficulty = feature.difficulty;
        const userDifficulty = prefs.preferredDifficulty;
        const maxDiff = achievement_constants_1.RECOMMENDATION_CONSTANTS.MAX_DIFFICULTY_DIFF;
        const diff = Math.abs(trailDifficulty - userDifficulty);
        let matchScore = 1 - diff / maxDiff;
        const difficultyDist = prefs.difficultyDistribution;
        if (difficultyDist) {
            const uniqueDifficulties = Object.values(difficultyDist).filter((v) => v > 0).length;
            if (uniqueDifficulties >= 2 && diff <= 1) {
                matchScore = Math.min(1, matchScore + 0.1);
            }
        }
        return Math.max(0, matchScore);
    }
    calculateDistanceScore(feature, userLat, userLng, trail) {
        if (!userLat || !userLng || !trail) {
            return achievement_constants_1.RECOMMENDATION_CONSTANTS.DEFAULT_DISTANCE_SCORE;
        }
        const distanceKm = this.calculateDistanceM(userLat, userLng, trail.startPointLat, trail.startPointLng) / achievement_constants_1.DISTANCE_CONSTANTS.ONE_KM;
        let score = Math.max(0, 1 - distanceKm / achievement_constants_1.RECOMMENDATION_CONSTANTS.MAX_REFERENCE_DISTANCE_KM);
        if (distanceKm < achievement_constants_1.RECOMMENDATION_CONSTANTS.DISTANCE_BONUS_THRESHOLD_KM) {
            score = Math.min(1, score + 0.1);
        }
        else if (distanceKm > achievement_constants_1.RECOMMENDATION_CONSTANTS.DISTANCE_PENALTY_THRESHOLD_KM) {
            score = score * 0.5;
        }
        return score;
    }
    calculateRatingScore(trail) {
        const baseRating = trail.avgRating || achievement_constants_1.RECOMMENDATION_CONSTANTS.DEFAULT_RATING;
        const reviewCount = trail.reviewCount || 0;
        if (reviewCount < achievement_constants_1.RECOMMENDATION_CONSTANTS.MIN_REVIEW_COUNT) {
            return achievement_constants_1.RECOMMENDATION_CONSTANTS.LOW_REVIEW_COUNT_SCORE;
        }
        return Math.min(1, baseRating / 5.0);
    }
    calculatePopularityScoreFromData(trail, data) {
        const completionScore = data.completionScore / achievement_constants_1.RECOMMENDATION_CONSTANTS.POPULARITY_COMPLETION_DENOMINATOR;
        const bookmarkScore = data.bookmarkScore / achievement_constants_1.RECOMMENDATION_CONSTANTS.POPULARITY_BOOKMARK_DENOMINATOR;
        let score = Math.min(1, completionScore * achievement_constants_1.RECOMMENDATION_CONSTANTS.POPULARITY_COMPLETION_WEIGHT +
            bookmarkScore * achievement_constants_1.RECOMMENDATION_CONSTANTS.POPULARITY_BOOKMARK_WEIGHT);
        const daysSinceCreated = trail.createdAt
            ? (Date.now() - new Date(trail.createdAt).getTime()) / achievement_constants_1.TIME_CONSTANTS.ONE_DAY
            : Infinity;
        if (daysSinceCreated <= achievement_constants_1.RECOMMENDATION_CONSTANTS.NEW_TRAIL_PROTECTION_DAYS) {
            score = Math.max(achievement_constants_1.RECOMMENDATION_CONSTANTS.NEW_TRAIL_BASE_POPULARITY_SCORE, score);
        }
        return score;
    }
    calculateFreshnessScore(trail) {
        if (!trail.createdAt) {
            return achievement_constants_1.RECOMMENDATION_CONSTANTS.DEFAULT_FRESHNESS_SCORE;
        }
        const daysSinceCreated = (Date.now() - new Date(trail.createdAt).getTime()) / achievement_constants_1.TIME_CONSTANTS.ONE_DAY;
        return Math.max(0, 1 - daysSinceCreated / achievement_constants_1.RECOMMENDATION_CONSTANTS.FRESHNESS_DECAY_DAYS);
    }
    extractTrailFeatures(trail) {
        return {
            difficulty: achievement_constants_1.DIFFICULTY_MAP[trail.difficulty] || 2,
            distanceKm: trail.distanceKm || 0,
            rating: trail.avgRating || achievement_constants_1.RECOMMENDATION_CONSTANTS.DEFAULT_RATING,
            popularity: 0,
            freshness: 0,
            tags: trail.tags || [],
        };
    }
    calculateDistanceM(lat1, lng1, lat2, lng2) {
        const R = achievement_constants_1.DISTANCE_CONSTANTS.EARTH_RADIUS_METERS;
        const φ1 = (lat1 * Math.PI) / 180;
        const φ2 = (lat2 * Math.PI) / 180;
        const Δφ = ((lat2 - lat1) * Math.PI) / 180;
        const Δλ = ((lng2 - lng1) * Math.PI) / 180;
        const a = Math.sin(Δφ / 2) * Math.sin(Δφ / 2) +
            Math.cos(φ1) * Math.cos(φ2) * Math.sin(Δλ / 2) * Math.sin(Δλ / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
    generateRecommendReason(scoredTrail, scene) {
        const { factors, userDistanceM } = scoredTrail;
        if (scene === recommendation_dto_1.RecommendationScene.NEARBY && userDistanceM !== undefined) {
            const distanceKm = (userDistanceM / achievement_constants_1.DISTANCE_CONSTANTS.ONE_KM).toFixed(1);
            return `距离你 ${distanceKm} 公里`;
        }
        if (factors.freshness > achievement_constants_1.RECOMMENDATION_CONSTANTS.FRESHNESS_HIGH_THRESHOLD) {
            return '新上线的路线';
        }
        if (factors.difficultyMatch > achievement_constants_1.RECOMMENDATION_CONSTANTS.DIFFICULTY_MATCH_HIGH_THRESHOLD &&
            factors.distance > achievement_constants_1.RECOMMENDATION_CONSTANTS.DISTANCE_HIGH_THRESHOLD) {
            return '符合你的难度偏好，距离合适';
        }
        if (factors.popularity > achievement_constants_1.RECOMMENDATION_CONSTANTS.POPULARITY_HIGH_THRESHOLD) {
            return '近期热门路线';
        }
        if (factors.rating > achievement_constants_1.RECOMMENDATION_CONSTANTS.RATING_HIGH_THRESHOLD) {
            return '高分推荐路线';
        }
        if (userDistanceM !== undefined) {
            const distanceKm = (userDistanceM / achievement_constants_1.DISTANCE_CONSTANTS.ONE_KM).toFixed(1);
            return `距离你 ${distanceKm} 公里`;
        }
        return '为你推荐';
    }
    async clearRecommendationCache(userId) {
        const pattern = `recommendation:*:${userId}:*`;
        await this.redis.delPattern(pattern);
        this.logger.info('Cleared recommendation cache', { userId });
    }
};
exports.RecommendationAlgorithmService = RecommendationAlgorithmService;
exports.RecommendationAlgorithmService = RecommendationAlgorithmService = RecommendationAlgorithmService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        redis_service_1.RedisService])
], RecommendationAlgorithmService);
//# sourceMappingURL=recommendation-algorithm.service.js.map