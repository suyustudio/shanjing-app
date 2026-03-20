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
var AchievementsService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AchievementsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
const redis_service_1 = require("../../shared/redis/redis.service");
const client_1 = require("@prisma/client");
const errors_1 = require("./errors");
const achievement_constants_1 = require("./constants/achievement.constants");
const structured_logger_util_1 = require("../../shared/logger/structured-logger.util");
let AchievementsService = AchievementsService_1 = class AchievementsService {
    constructor(prisma, redis) {
        this.prisma = prisma;
        this.redis = redis;
        this.logger = (0, structured_logger_util_1.createStructuredLogger)(new common_1.Logger(AchievementsService_1.name), achievement_constants_1.LOG_CONTEXT.ACHIEVEMENTS_SERVICE);
    }
    async getAllAchievements() {
        const timer = this.logger.startTimer('getAllAchievements');
        const cacheKey = achievement_constants_1.ACHIEVEMENT_CONSTANTS.ACHIEVEMENT_LIST_CACHE_KEY;
        const cached = await this.redis.get(cacheKey);
        if (cached) {
            try {
                const parsed = JSON.parse(cached);
                timer.end({ source: 'cache', count: parsed.length });
                this.logger.debug('Achievement list cache hit', { count: parsed.length });
                return parsed;
            }
            catch {
                this.logger.warn('Failed to parse achievement list cache');
            }
        }
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
        const result = achievements.map((achievement) => this.mapToAchievementDto(achievement));
        await this.redis.setex(cacheKey, achievement_constants_1.ACHIEVEMENT_CONSTANTS.ACHIEVEMENT_CACHE_TTL, JSON.stringify(result));
        timer.end({ source: 'database', count: result.length });
        this.logger.info('Fetched all achievements', { count: result.length });
        return result;
    }
    async getAchievementById(id) {
        const timer = this.logger.startTimer('getAchievementById', { achievementId: id });
        const achievement = await this.prisma.achievement.findUnique({
            where: { id },
            include: {
                levels: {
                    orderBy: {
                        requirement: 'asc',
                    },
                },
            },
        });
        if (!achievement) {
            timer.end({ found: false });
            throw new errors_1.AchievementNotFoundError(id);
        }
        timer.end({ found: true, name: achievement.name });
        return this.mapToAchievementDto(achievement);
    }
    async getUserAchievements(userId) {
        const timer = this.logger.startTimer('getUserAchievements', { userId });
        const cacheKey = `${achievement_constants_1.ACHIEVEMENT_CONSTANTS.USER_ACHIEVEMENT_CACHE_PREFIX}:${userId}`;
        const cached = await this.redis.get(cacheKey);
        if (cached) {
            try {
                const parsed = JSON.parse(cached);
                timer.end({ source: 'cache', totalCount: parsed.totalCount, unlockedCount: parsed.unlockedCount });
                this.logger.debug('User achievement cache hit', { userId, unlockedCount: parsed.unlockedCount });
                return parsed;
            }
            catch {
                this.logger.warn('Failed to parse user achievement cache', undefined, { userId });
            }
        }
        const allAchievements = await this.prisma.achievement.findMany({
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
        const userAchievements = await this.prisma.userAchievement.findMany({
            where: { userId },
            include: {
                achievement: true,
                level: true,
            },
        });
        const userStats = await this.getOrCreateUserStats(userId);
        const achievements = allAchievements.map((achievement) => {
            const userAchievement = userAchievements.find((ua) => ua.achievementId === achievement.id);
            return this.buildUserAchievementDto(achievement, userAchievement, userStats);
        });
        const unlockedCount = achievements.filter((a) => a.isUnlocked).length;
        const newUnlockedCount = userAchievements.filter((ua) => ua.isNew).length;
        const result = {
            totalCount: allAchievements.length,
            unlockedCount,
            newUnlockedCount,
            achievements,
        };
        await this.redis.setex(cacheKey, achievement_constants_1.ACHIEVEMENT_CONSTANTS.USER_ACHIEVEMENT_CACHE_TTL, JSON.stringify(result));
        timer.end({
            source: 'database',
            totalCount: result.totalCount,
            unlockedCount: result.unlockedCount,
            newUnlockedCount: result.newUnlockedCount,
        });
        this.logger.info('Fetched user achievements', {
            userId,
            totalCount: result.totalCount,
            unlockedCount: result.unlockedCount,
        });
        return result;
    }
    async markAchievementViewed(userId, achievementId) {
        const timer = this.logger.startTimer('markAchievementViewed', { userId, achievementId });
        await this.prisma.userAchievement.updateMany({
            where: {
                userId,
                achievementId,
            },
            data: {
                isNew: false,
            },
        });
        await this.clearUserAchievementCache(userId);
        timer.end({ userId, achievementId });
        this.logger.info('Marked achievement as viewed', { userId, achievementId });
    }
    async markAllAchievementsViewed(userId) {
        const timer = this.logger.startTimer('markAllAchievementsViewed', { userId });
        const result = await this.prisma.userAchievement.updateMany({
            where: {
                userId,
                isNew: true,
            },
            data: {
                isNew: false,
            },
        });
        await this.clearUserAchievementCache(userId);
        timer.end({ userId, updatedCount: result.count });
        this.logger.info('Marked all achievements as viewed', { userId, updatedCount: result.count });
    }
    async checkAchievements(userId, dto) {
        const timer = this.logger.startTimer('checkAchievements', {
            userId,
            triggerType: dto.triggerType,
            trailId: dto.trailId,
        });
        if (!achievement_constants_1.ACHIEVEMENT_CONSTANTS.VALID_TRIGGER_TYPES.includes(dto.triggerType)) {
            throw new errors_1.InvalidTriggerTypeError(dto.triggerType);
        }
        try {
            const result = await this.prisma.$transaction(async (tx) => {
                const newlyUnlocked = [];
                const progressUpdated = [];
                if (dto.triggerType === 'trail_completed' && dto.stats) {
                    await this.updateStatsAfterTrailTx(tx, userId, dto.trailId, dto.stats);
                }
                else if (dto.triggerType === 'share') {
                    await this.incrementShareCountTx(tx, userId);
                }
                const userStats = await tx.userStats.findUnique({
                    where: { userId },
                });
                if (!userStats) {
                    throw new errors_1.AchievementError('用户统计不存在', 'USER_STATS_NOT_FOUND', 500);
                }
                const allAchievements = await tx.achievement.findMany({
                    include: {
                        levels: {
                            orderBy: {
                                requirement: 'asc',
                            },
                        },
                    },
                });
                const userAchievements = await tx.userAchievement.findMany({
                    where: { userId },
                    include: {
                        level: true,
                    },
                });
                for (const achievement of allAchievements) {
                    const currentProgress = this.getProgressForAchievement(achievement.category, userStats);
                    const userAchievement = userAchievements.find((ua) => ua.achievementId === achievement.id);
                    const targetLevel = this.calculateTargetLevel(achievement.levels, currentProgress);
                    if (!targetLevel) {
                        const nextLevel = achievement.levels[0];
                        if (nextLevel) {
                            progressUpdated.push({
                                achievementId: achievement.id,
                                progress: currentProgress,
                                requirement: nextLevel.requirement,
                                percentage: Math.min(100, Math.round((currentProgress / nextLevel.requirement) * 100)),
                            });
                        }
                        continue;
                    }
                    if (!userAchievement) {
                        try {
                            await tx.userAchievement.upsert({
                                where: {
                                    userId_achievementId: {
                                        userId,
                                        achievementId: achievement.id,
                                    },
                                },
                                update: {
                                    levelId: targetLevel.id,
                                    progress: currentProgress,
                                    isNew: true,
                                    unlockedAt: new Date(),
                                },
                                create: {
                                    userId,
                                    achievementId: achievement.id,
                                    levelId: targetLevel.id,
                                    progress: currentProgress,
                                    isNew: true,
                                    unlockedAt: new Date(),
                                },
                            });
                            newlyUnlocked.push({
                                achievementId: achievement.id,
                                level: targetLevel.level,
                                name: targetLevel.name,
                                message: `恭喜！你已完成${achievement.name}成就 - ${targetLevel.name}`,
                                badgeUrl: targetLevel.iconUrl || achievement.iconUrl || '',
                            });
                        }
                        catch (error) {
                            this.logger.warn('Achievement upsert conflict', error, { userId, achievementId: achievement.id });
                        }
                    }
                    else if (targetLevel.id !== userAchievement.levelId) {
                        const oldLevelIndex = achievement.levels.findIndex((l) => l.id === userAchievement.levelId);
                        const newLevelIndex = achievement.levels.findIndex((l) => l.id === targetLevel.id);
                        if (newLevelIndex > oldLevelIndex) {
                            await tx.userAchievement.update({
                                where: { id: userAchievement.id },
                                data: {
                                    levelId: targetLevel.id,
                                    progress: currentProgress,
                                    isNew: true,
                                    unlockedAt: new Date(),
                                },
                            });
                            newlyUnlocked.push({
                                achievementId: achievement.id,
                                level: targetLevel.level,
                                name: targetLevel.name,
                                message: `恭喜升级！你已达到${achievement.name} - ${targetLevel.name}`,
                                badgeUrl: targetLevel.iconUrl || achievement.iconUrl || '',
                            });
                        }
                    }
                    else {
                        await tx.userAchievement.update({
                            where: { id: userAchievement.id },
                            data: {
                                progress: currentProgress,
                            },
                        });
                        const currentLevelIndex = achievement.levels.findIndex((l) => l.id === userAchievement.levelId);
                        const nextLevel = achievement.levels[currentLevelIndex + 1];
                        if (nextLevel) {
                            progressUpdated.push({
                                achievementId: achievement.id,
                                progress: currentProgress,
                                requirement: nextLevel.requirement,
                                percentage: Math.min(100, Math.round(((currentProgress - targetLevel.requirement) /
                                    (nextLevel.requirement - targetLevel.requirement)) *
                                    100)),
                            });
                        }
                    }
                }
                return {
                    newlyUnlocked,
                    progressUpdated,
                };
            }, {
                isolationLevel: client_1.Prisma.TransactionIsolationLevel.Serializable,
                maxWait: achievement_constants_1.TRANSACTION_CONFIG.MAX_WAIT_MS,
                timeout: achievement_constants_1.TRANSACTION_CONFIG.TIMEOUT_MS,
            });
            timer.end({
                userId,
                newlyUnlockedCount: result.newlyUnlocked.length,
                progressUpdatedCount: result.progressUpdated.length,
            });
            if (result.newlyUnlocked.length > 0) {
                this.logger.info('Achievements unlocked', {
                    userId,
                    newlyUnlocked: result.newlyUnlocked.map((a) => ({
                        achievementId: a.achievementId,
                        level: a.level,
                        name: a.name,
                    })),
                });
            }
            return result;
        }
        catch (error) {
            timer.fail(error instanceof Error ? error : undefined, { userId });
            if (error instanceof errors_1.AchievementError) {
                throw error;
            }
            this.logger.error('Transaction failed', error, { userId, triggerType: dto.triggerType });
            if (error instanceof client_1.Prisma.PrismaClientKnownRequestError) {
                if (error.code === 'P2002') {
                    throw new errors_1.ConcurrentModificationError('user_achievement', userId);
                }
                if (error.code === 'P2003') {
                    throw new errors_1.AchievementError('关联数据不存在', 'FOREIGN_KEY_VIOLATION', 400);
                }
            }
            throw new errors_1.TransactionError('checkAchievements', error);
        }
        finally {
            await this.clearUserAchievementCache(userId);
        }
    }
    async getOrCreateUserStats(userId) {
        let stats = await this.prisma.userStats.findUnique({
            where: { userId },
        });
        if (!stats) {
            stats = await this.prisma.userStats.create({
                data: {
                    userId,
                },
            });
            this.logger.info('Created user stats', { userId });
        }
        return stats;
    }
    async getUserStats(userId) {
        const stats = await this.getOrCreateUserStats(userId);
        return {
            totalDistanceM: stats.totalDistanceM,
            totalDurationSec: stats.totalDurationSec,
            totalElevationGainM: stats.totalElevationGainM,
            uniqueTrailsCount: stats.uniqueTrailsCount,
            currentWeeklyStreak: stats.currentWeeklyStreak,
            longestWeeklyStreak: stats.longestWeeklyStreak,
            nightTrailCount: stats.nightTrailCount,
            rainTrailCount: stats.rainTrailCount,
            shareCount: stats.shareCount,
        };
    }
    async updateStatsAfterTrailTx(tx, userId, trailId, stats) {
        const userStats = await tx.userStats.findUnique({
            where: { userId },
        });
        if (!userStats) {
            await tx.userStats.create({
                data: {
                    userId,
                    totalDistanceM: stats.distance,
                    totalDurationSec: stats.duration,
                    uniqueTrailsCount: trailId ? 1 : 0,
                    completedTrailIds: trailId ? [trailId] : [],
                    nightTrailCount: stats.isNight ? 1 : 0,
                    rainTrailCount: stats.isRain ? 1 : 0,
                    soloTrailCount: stats.isSolo ? 1 : 0,
                    currentWeeklyStreak: 1,
                    longestWeeklyStreak: 1,
                    lastTrailDate: new Date(),
                },
            });
            return;
        }
        const updateData = {
            totalDistanceM: { increment: stats.distance },
            totalDurationSec: { increment: stats.duration },
        };
        if (trailId) {
            const completedTrailIds = userStats.completedTrailIds || [];
            if (!completedTrailIds.includes(trailId)) {
                updateData.completedTrailIds = {
                    push: trailId,
                };
                updateData.uniqueTrailsCount = { increment: 1 };
            }
        }
        if (stats.isNight) {
            updateData.nightTrailCount = { increment: 1 };
        }
        if (stats.isRain) {
            updateData.rainTrailCount = { increment: 1 };
        }
        if (stats.isSolo) {
            updateData.soloTrailCount = { increment: 1 };
        }
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        if (userStats.lastTrailDate) {
            const lastDate = new Date(userStats.lastTrailDate);
            lastDate.setHours(0, 0, 0, 0);
            const diffDays = Math.floor((today.getTime() - lastDate.getTime()) / achievement_constants_1.TIME_CONSTANTS.ONE_DAY);
            if (diffDays === 1) {
                updateData.currentWeeklyStreak = userStats.currentWeeklyStreak + 1;
                if (updateData.currentWeeklyStreak > userStats.longestWeeklyStreak) {
                    updateData.longestWeeklyStreak = updateData.currentWeeklyStreak;
                }
            }
            else if (diffDays > 1) {
                updateData.currentWeeklyStreak = 1;
            }
        }
        else {
            updateData.currentWeeklyStreak = 1;
        }
        updateData.lastTrailDate = today;
        const totalTrails = (userStats.uniqueTrailsCount || 0) +
            (trailId && !userStats.completedTrailIds?.includes(trailId) ? 1 : 0);
        if (totalTrails > 0) {
            const totalDistanceKm = (userStats.totalDistanceM + stats.distance) / 1000;
            const totalDurationMin = (userStats.totalDurationSec + stats.duration) / 60;
            updateData.avgDistanceKm = totalDistanceKm / totalTrails;
            updateData.avgDurationMin = totalDurationMin / totalTrails;
        }
        await tx.userStats.update({
            where: { userId },
            data: updateData,
        });
    }
    async incrementShareCountTx(tx, userId) {
        const userStats = await tx.userStats.findUnique({
            where: { userId },
        });
        if (!userStats) {
            await tx.userStats.create({
                data: {
                    userId,
                    shareCount: 1,
                },
            });
            return;
        }
        await tx.userStats.update({
            where: { userId },
            data: {
                shareCount: { increment: 1 },
            },
        });
    }
    async clearUserAchievementCache(userId) {
        const cacheKey = `${achievement_constants_1.ACHIEVEMENT_CONSTANTS.USER_ACHIEVEMENT_CACHE_PREFIX}:${userId}`;
        await this.redis.del(cacheKey);
        this.logger.debug('Cleared user achievement cache', { userId });
    }
    async clearAllAchievementCache() {
        await this.redis.del(achievement_constants_1.ACHIEVEMENT_CONSTANTS.ACHIEVEMENT_LIST_CACHE_KEY);
        this.logger.info('Cleared all achievement cache');
    }
    mapToAchievementDto(achievement) {
        return {
            id: achievement.id,
            key: achievement.key,
            name: achievement.name,
            description: achievement.description || undefined,
            category: achievement.category,
            iconUrl: achievement.iconUrl || undefined,
            isHidden: achievement.isHidden,
            sortOrder: achievement.sortOrder,
            levels: achievement.levels.map((level) => ({
                id: level.id,
                level: level.level,
                requirement: level.requirement,
                name: level.name,
                description: level.description || undefined,
                reward: level.reward || undefined,
                iconUrl: level.iconUrl || undefined,
            })),
        };
    }
    buildUserAchievementDto(achievement, userAchievement, userStats) {
        const currentProgress = this.getProgressForAchievement(achievement.category, userStats);
        const isUnlocked = !!userAchievement;
        const currentLevel = userAchievement?.level;
        let nextRequirement = achievement.levels[0]?.requirement || 0;
        if (currentLevel) {
            const currentLevelIndex = achievement.levels.findIndex((l) => l.id === currentLevel.id);
            const nextLevel = achievement.levels[currentLevelIndex + 1];
            nextRequirement = nextLevel?.requirement || currentLevel.requirement;
        }
        let percentage = 0;
        if (currentLevel) {
            const currentLevelIndex = achievement.levels.findIndex((l) => l.id === currentLevel.id);
            const nextLevel = achievement.levels[currentLevelIndex + 1];
            if (nextLevel) {
                percentage = Math.min(100, Math.round(((currentProgress - currentLevel.requirement) /
                    (nextLevel.requirement - currentLevel.requirement)) *
                    100));
            }
            else {
                percentage = 100;
            }
        }
        else {
            percentage = Math.min(100, Math.round((currentProgress / nextRequirement) * 100));
        }
        return {
            achievementId: achievement.id,
            key: achievement.key,
            name: achievement.name,
            category: achievement.category,
            currentLevel: currentLevel?.name,
            currentProgress,
            nextRequirement,
            percentage,
            unlockedAt: userAchievement?.unlockedAt,
            isNew: userAchievement?.isNew || false,
            isUnlocked,
        };
    }
    getProgressForAchievement(category, userStats) {
        switch (category) {
            case client_1.AchievementCategory.EXPLORER:
                return userStats.uniqueTrailsCount || 0;
            case client_1.AchievementCategory.DISTANCE:
                return userStats.totalDistanceM || 0;
            case client_1.AchievementCategory.FREQUENCY:
                return userStats.currentWeeklyStreak || 0;
            case client_1.AchievementCategory.CHALLENGE:
                return userStats.nightTrailCount || 0;
            case client_1.AchievementCategory.SOCIAL:
                return userStats.shareCount || 0;
            default:
                return 0;
        }
    }
    calculateTargetLevel(levels, currentProgress) {
        let targetLevel = null;
        for (const level of levels) {
            if (currentProgress >= level.requirement) {
                targetLevel = level;
            }
            else {
                break;
            }
        }
        return targetLevel;
    }
    getWeekNumber(date) {
        const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
        const dayNum = d.getUTCDay() || 7;
        d.setUTCDate(d.getUTCDate() + 4 - dayNum);
        const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
        return Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
    }
};
exports.AchievementsService = AchievementsService;
exports.AchievementsService = AchievementsService = AchievementsService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService,
        redis_service_1.RedisService])
], AchievementsService);
//# sourceMappingURL=achievements.service.js.map