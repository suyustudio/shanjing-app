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
Object.defineProperty(exports, "__esModule", { value: true });
exports.UserProfileService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../../database/prisma.service");
const client_1 = require("@prisma/client");
let UserProfileService = class UserProfileService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getOrCreateProfile(userId) {
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
    async getUserPreferenceVector(userId) {
        const profile = await this.getOrCreateProfile(userId);
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
                ? this.difficultyToNumber(profile.preferredDifficulty)
                : 0,
            preferredMinDistance: profile.preferredMinDistanceKm || 0,
            preferredMaxDistance: profile.preferredMaxDistanceKm || 0,
            preferredTags: profile.preferredTags || [],
            difficultyDistribution: profile.difficultyVector || {},
        };
    }
    async updateProfile(userId) {
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
            await this.prisma.userProfile.update({
                where: { userId },
                data: { isColdStart: true },
            });
            return;
        }
        const difficultyCounts = {};
        let totalDistance = 0;
        let totalDuration = 0;
        const allTags = [];
        for (const interaction of completedInteractions) {
            const trail = interaction.trail;
            if (!trail)
                continue;
            difficultyCounts[trail.difficulty] = (difficultyCounts[trail.difficulty] || 0) + 1;
            totalDistance += trail.distanceKm || 0;
            totalDuration += trail.durationMin || 0;
            if (trail.tags) {
                allTags.push(...trail.tags);
            }
        }
        const preferredDifficulty = Object.entries(difficultyCounts)
            .sort((a, b) => b[1] - a[1])[0]?.[0] || 'MODERATE';
        const totalCount = completedInteractions.length;
        const difficultyDistribution = {};
        for (const [diff, count] of Object.entries(difficultyCounts)) {
            difficultyDistribution[diff] = count / totalCount;
        }
        const avgDistance = totalDistance / totalCount;
        const distances = completedInteractions
            .map(i => i.trail?.distanceKm || 0)
            .filter(d => d > 0)
            .sort((a, b) => a - b);
        const minDistance = distances[0] || avgDistance * 0.5;
        const maxDistance = distances[distances.length - 1] || avgDistance * 1.5;
        const tagCounts = {};
        for (const tag of allTags) {
            tagCounts[tag] = (tagCounts[tag] || 0) + 1;
        }
        const preferredTags = Object.entries(tagCounts)
            .sort((a, b) => b[1] - a[1])
            .slice(0, 5)
            .map(([tag]) => tag);
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
                isColdStart: totalCount < 3,
            },
        });
    }
    async recordInteraction(userId, trailId, interactionType, metadata) {
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
        if (interactionType === 'complete' || interactionType === 'rate') {
            await this.updateProfile(userId);
        }
    }
    async getColdStartRecommendations(limit = 10) {
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
        const completionMap = new Map(completionCounts.map(c => [c.trailId, c._count.trailId]));
        return popularTrails
            .map(trail => ({
            ...trail,
            popularityScore: (completionMap.get(trail.id) || 0) + trail._count.favorites,
        }))
            .sort((a, b) => b.popularityScore - a.popularityScore)
            .slice(0, limit);
    }
    difficultyToNumber(difficulty) {
        const map = {
            [client_1.TrailDifficulty.EASY]: 1,
            [client_1.TrailDifficulty.MODERATE]: 2,
            [client_1.TrailDifficulty.HARD]: 3,
            [client_1.TrailDifficulty.EXPERT]: 4,
        };
        return map[difficulty] || 2;
    }
};
exports.UserProfileService = UserProfileService;
exports.UserProfileService = UserProfileService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], UserProfileService);
//# sourceMappingURL=user-profile.service.js.map