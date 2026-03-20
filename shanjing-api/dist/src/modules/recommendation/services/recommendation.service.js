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
var RecommendationService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.RecommendationService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../../database/prisma.service");
const redis_service_1 = require("../../../shared/redis/redis.service");
const recommendation_algorithm_service_1 = require("./recommendation-algorithm.service");
const user_profile_service_1 = require("./user-profile.service");
const recommendation_dto_1 = require("../dto/recommendation.dto");
const achievement_constants_1 = require("../../../modules/achievements/constants/achievement.constants");
const structured_logger_util_1 = require("../../../shared/logger/structured-logger.util");
let RecommendationService = RecommendationService_1 = class RecommendationService {
    constructor(prisma, redis, algorithmService, profileService) {
        this.prisma = prisma;
        this.redis = redis;
        this.algorithmService = algorithmService;
        this.profileService = profileService;
        this.logger = (0, structured_logger_util_1.createStructuredLogger)(new common_1.Logger(RecommendationService_1.name), achievement_constants_1.LOG_CONTEXT.RECOMMENDATION_SERVICE);
    }
    async getRecommendations(dto, currentUserId) {
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
        const profileTimer = this.logger.startTimer('getUserProfile', { userId: targetUserId });
        const userProfile = await this.profileService.getOrCreateProfile(targetUserId);
        const userPrefs = await this.profileService.getUserPreferenceVector(targetUserId);
        profileTimer.end({ isColdStart: userProfile.isColdStart });
        let candidateTrails = [];
        const candidateTimer = this.logger.startTimer('getCandidateTrails', { scene });
        if (userProfile.isColdStart && scene !== recommendation_dto_1.RecommendationScene.SIMILAR) {
            candidateTrails = await this.profileService.getColdStartRecommendations(limit * achievement_constants_1.RECOMMENDATION_CONSTANTS.COLD_START_MULTIPLIER);
        }
        else if (scene === recommendation_dto_1.RecommendationScene.SIMILAR && referenceTrailId) {
            candidateTrails = await this.getSimilarTrails(referenceTrailId, targetUserId, limit * achievement_constants_1.RECOMMENDATION_CONSTANTS.COLD_START_MULTIPLIER);
        }
        else {
            candidateTrails = await this.getActiveTrails(excludeIds, limit * achievement_constants_1.RECOMMENDATION_CONSTANTS.COLD_START_MULTIPLIER);
        }
        candidateTimer.end({ candidateCount: candidateTrails.length });
        const excludeTimer = this.logger.startTimer('excludeCompletedTrails', { userId: targetUserId });
        const completedTrailIds = await this.getCompletedTrailIds(targetUserId);
        candidateTrails = candidateTrails.filter((trail) => !completedTrailIds.includes(trail.id));
        excludeTimer.end({
            beforeCount: candidateTrails.length + completedTrailIds.length,
            afterCount: candidateTrails.length,
        });
        const scoredTrails = await this.algorithmService.calculateScores(candidateTrails, userPrefs, lat, lng, scene);
        const selectedTrails = this.applySceneStrategy(scoredTrails, scene, limit);
        const recommendedTrails = selectedTrails.map((st) => ({
            id: st.trail.id,
            name: st.trail.name,
            coverImage: st.trail.coverImages?.[0] || '',
            distanceKm: st.trail.distanceKm,
            durationMin: st.trail.durationMin,
            difficulty: st.trail.difficulty,
            rating: st.trail.avgRating || achievement_constants_1.RECOMMENDATION_CONSTANTS.DEFAULT_RATING,
            matchScore: st.score,
            matchFactors: {
                difficultyMatch: Math.round(st.factors.difficultyMatch * 100),
                distance: Math.round(st.factors.distance * 100),
                rating: Math.round(st.factors.rating * 100),
                popularity: Math.round(st.factors.popularity * 100),
                freshness: Math.round(st.factors.freshness * 100),
            },
            recommendReason: this.algorithmService.generateRecommendReason(st, scene),
            userDistanceM: st.userDistanceM,
        }));
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
                })),
            },
        });
        const response = {
            algorithm: 'v1_rule_based',
            scene,
            logId: log.id,
            trails: recommendedTrails,
        };
        await this.setCache(cacheKey, response, scene);
        timer.end({
            trailCount: recommendedTrails.length,
            logId: log.id,
            topScore: recommendedTrails[0]?.matchScore,
        });
        return response;
    }
    async recordFeedback(dto, currentUserId) {
        const { action, trailId, logId, durationSec } = dto;
        const timer = this.logger.startTimer('recordFeedback', {
            userId: currentUserId,
            action,
            trailId,
        });
        await this.profileService.recordInteraction(currentUserId, trailId, action, { durationSec, source: 'recommendation' });
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
        await this.clearUserCache(currentUserId);
        timer.end({ action, trailId });
        return { success: true };
    }
    async recordImpression(dto, currentUserId) {
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
            const impressionData = trailIds.map((trailId) => ({
                userId: currentUserId,
                trailId,
                scene,
                logId,
                timestamp: timestamp ? new Date(timestamp) : new Date(),
            }));
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
        }
        catch (error) {
            timer.fail(error instanceof Error ? error : undefined, { trailCount: trailIds.length });
            this.logger.error('Failed to record impression', error, {
                userId: currentUserId,
                scene,
                trailCount: trailIds.length,
            });
            return { success: false, message: error.message };
        }
    }
    async getSimilarTrails(referenceTrailId, userId, limit) {
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
    async getActiveTrails(excludeIds = [], limit) {
        const validatedExcludeIds = excludeIds.length > achievement_constants_1.VALIDATION_CONSTRAINTS.MAX_LIMIT
            ? excludeIds.slice(0, achievement_constants_1.VALIDATION_CONSTRAINTS.MAX_LIMIT)
            : excludeIds;
        return this.prisma.trail.findMany({
            where: {
                isActive: true,
                id: { notIn: validatedExcludeIds.length > 0 ? validatedExcludeIds : undefined },
            },
            take: limit,
        });
    }
    async getCompletedTrailIds(userId) {
        const interactions = await this.prisma.userTrailInteraction.findMany({
            where: {
                userId,
                interactionType: 'complete',
            },
            select: { trailId: true },
        });
        return interactions.map((i) => i.trailId);
    }
    applySceneStrategy(scoredTrails, scene, limit) {
        if (scoredTrails.length <= limit) {
            return scoredTrails;
        }
        switch (scene) {
            case recommendation_dto_1.RecommendationScene.HOME:
                return this.applyHomeStrategy(scoredTrails, limit);
            case recommendation_dto_1.RecommendationScene.NEARBY:
                return this.applyNearbyStrategy(scoredTrails, limit);
            default:
                return scoredTrails.slice(0, limit);
        }
    }
    applyHomeStrategy(scoredTrails, limit) {
        const result = [];
        const usedDifficulties = new Set();
        const topByScore = scoredTrails.slice(0, Math.min(achievement_constants_1.RECOMMENDATION_CONSTANTS.HOME_TOP_TRAILS_COUNT, limit));
        for (const trail of topByScore) {
            result.push(trail);
            usedDifficulties.add(trail.trail.difficulty);
        }
        const remaining = scoredTrails.slice(achievement_constants_1.RECOMMENDATION_CONSTANTS.HOME_TOP_TRAILS_COUNT);
        const freshTrails = remaining
            .filter((t) => t.factors.freshness > achievement_constants_1.RECOMMENDATION_CONSTANTS.FRESHNESS_HIGH_THRESHOLD)
            .slice(0, 2);
        for (const trail of freshTrails) {
            if (result.length >= limit)
                break;
            result.push(trail);
        }
        for (const trail of remaining) {
            if (result.length >= limit)
                break;
            if (!result.includes(trail)) {
                if (!usedDifficulties.has(trail.trail.difficulty) || result.length >= limit - 1) {
                    result.push(trail);
                    usedDifficulties.add(trail.trail.difficulty);
                }
            }
        }
        return result;
    }
    applyNearbyStrategy(scoredTrails, limit) {
        return scoredTrails
            .filter((t) => !t.userDistanceM ||
            t.userDistanceM <= achievement_constants_1.RECOMMENDATION_CONSTANTS.NEARBY_MAX_DISTANCE_METERS)
            .sort((a, b) => (a.userDistanceM || Infinity) - (b.userDistanceM || Infinity))
            .slice(0, limit);
    }
    buildCacheKey(userId, scene, lat, lng, limit) {
        const locationHash = lat && lng
            ? `${Math.round(lat * 100) / 100},${Math.round(lng * 100) / 100}`
            : 'none';
        return `${achievement_constants_1.RECOMMENDATION_CONSTANTS.CACHE_PREFIX}${userId}:${scene}:${locationHash}:${limit}`;
    }
    async getFromCache(key) {
        try {
            const cached = await this.redis.get(key);
            return cached ? JSON.parse(cached) : null;
        }
        catch {
            return null;
        }
    }
    async setCache(key, value, scene = recommendation_dto_1.RecommendationScene.HOME) {
        try {
            const ttl = achievement_constants_1.CACHE_TTL_BY_SCENE[scene] || achievement_constants_1.CACHE_TTL_BY_SCENE.HOME;
            await this.redis.set(key, JSON.stringify(value), ttl);
        }
        catch (error) {
            this.logger.warn('Failed to cache recommendation', error, { key });
        }
    }
    async clearUserCache(userId) {
        try {
            const pattern = `${achievement_constants_1.RECOMMENDATION_CONSTANTS.CACHE_PREFIX}${userId}:*`;
            const keys = await this.redis.keys(pattern);
            if (keys.length > 0) {
                await this.redis.del(...keys);
                this.logger.debug('Cleared user cache', { userId, keyCount: keys.length });
            }
        }
        catch (error) {
            this.logger.warn('Failed to clear cache', error, { userId });
        }
    }
};
exports.RecommendationService = RecommendationService;
exports.RecommendationService = RecommendationService = RecommendationService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        redis_service_1.RedisService,
        recommendation_algorithm_service_1.RecommendationAlgorithmService,
        user_profile_service_1.UserProfileService])
], RecommendationService);
//# sourceMappingURL=recommendation.service.js.map