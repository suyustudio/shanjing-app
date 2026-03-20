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
var AchievementsCheckerService_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.AchievementsCheckerService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
const client_1 = require("@prisma/client");
const errors_1 = require("./errors");
let AchievementsCheckerService = AchievementsCheckerService_1 = class AchievementsCheckerService {
    constructor(prisma) {
        this.prisma = prisma;
        this.logger = new common_1.Logger(AchievementsCheckerService_1.name);
    }
    async checkAchievements(userId, dto) {
        const validTriggerTypes = ['trail_completed', 'share', 'manual', 'like_received'];
        if (!validTriggerTypes.includes(dto.triggerType)) {
            throw new errors_1.InvalidTriggerTypeError(dto.triggerType);
        }
        try {
            return await this.prisma.$transaction(async (tx) => {
                const newlyUnlocked = [];
                let userStats = await this.getOrCreateUserStatsTx(tx, userId);
                if (dto.triggerType === 'trail_completed' && dto.stats) {
                    const wasFirstTrail = userStats.uniqueTrailsCount === 0;
                    userStats = await this.updateStatsAfterTrailTx(tx, userId, dto.trailId, dto.stats);
                    if (wasFirstTrail || userStats.uniqueTrailsCount === 1) {
                        const firstHikeUnlock = await this.checkAndUnlockFirstHikeTx(tx, userId);
                        if (firstHikeUnlock) {
                            newlyUnlocked.push(firstHikeUnlock);
                        }
                    }
                }
                else if (dto.triggerType === 'share') {
                    userStats = await this.incrementShareCountTx(tx, userId);
                }
                else if (dto.triggerType === 'like_received' && dto.likeCount) {
                    userStats = await this.updateLikesCountTx(tx, userId, dto.likeCount);
                }
                const distanceUnlocks = await this.checkDistanceAchievementsTx(tx, userId, userStats);
                const trailUnlocks = await this.checkTrailAchievementsTx(tx, userId, userStats);
                const streakUnlocks = await this.checkStreakAchievementsTx(tx, userId, userStats);
                const socialUnlocks = await this.checkSocialAchievementsTx(tx, userId, userStats);
                newlyUnlocked.push(...distanceUnlocks, ...trailUnlocks, ...streakUnlocks, ...socialUnlocks);
                return { newlyUnlocked };
            }, {
                isolationLevel: client_1.Prisma.TransactionIsolationLevel.Serializable,
                maxWait: 5000,
                timeout: 10000,
            });
        }
        catch (error) {
            if (error instanceof errors_1.AchievementError) {
                throw error;
            }
            this.logger.error(`Transaction failed for user ${userId}`, error);
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
    }
    async checkAndUnlockFirstHikeTx(tx, userId) {
        const achievement = await tx.achievement.findUnique({
            where: { key: 'first_hike' },
            include: { levels: true },
        });
        if (!achievement)
            return null;
        const bronzeLevel = achievement.levels.find(l => l.level === client_1.AchievementLevelEnum.BRONZE);
        if (!bronzeLevel)
            return null;
        try {
            await tx.userAchievement.upsert({
                where: {
                    userId_achievementId: {
                        userId,
                        achievementId: achievement.id,
                    },
                },
                update: {},
                create: {
                    userId,
                    achievementId: achievement.id,
                    levelId: bronzeLevel.id,
                    progress: 1,
                    isNew: true,
                },
            });
            const existing = await tx.userAchievement.findUnique({
                where: {
                    userId_achievementId: {
                        userId,
                        achievementId: achievement.id,
                    },
                },
            });
            if (existing && (Date.now() - new Date(existing.unlockedAt).getTime()) < 5000) {
                this.logger.log(`User ${userId} unlocked first hike achievement`);
                return {
                    achievementId: achievement.id,
                    level: client_1.AchievementLevelEnum.BRONZE,
                    name: bronzeLevel.name,
                    message: `🎉 恭喜解锁「${achievement.name}」成就！迈出了徒步的第一步！`,
                    badgeUrl: bronzeLevel.iconUrl || achievement.iconUrl,
                };
            }
            return null;
        }
        catch (error) {
            this.logger.warn(`First hike achievement upsert conflict for user ${userId}`, error);
            return null;
        }
    }
    async checkDistanceAchievementsTx(tx, userId, userStats) {
        return this.checkCategoryAchievementsTx(tx, userId, 'distance_master', userStats.totalDistanceM || 0);
    }
    async checkTrailAchievementsTx(tx, userId, userStats) {
        return this.checkCategoryAchievementsTx(tx, userId, 'trail_collector', userStats.uniqueTrailsCount || 0);
    }
    async checkStreakAchievementsTx(tx, userId, userStats) {
        return this.checkCategoryAchievementsTx(tx, userId, 'streak_master', userStats.currentStreak || 0);
    }
    async checkSocialAchievementsTx(tx, userId, userStats) {
        const achievement = await tx.achievement.findUnique({
            where: { key: 'social_star' },
            include: { levels: { orderBy: { requirement: 'asc' } } },
        });
        if (!achievement)
            return [];
        const unlocked = [];
        const shareCount = userStats.shareCount || 0;
        const likeCount = userStats.totalLikesReceived || 0;
        const userAchievement = await tx.userAchievement.findUnique({
            where: {
                userId_achievementId: {
                    userId,
                    achievementId: achievement.id,
                },
            },
            include: { level: true },
        });
        const currentLevelOrder = userAchievement?.level
            ? this.getLevelOrder(userAchievement.level.level)
            : 0;
        for (const level of achievement.levels) {
            const levelOrder = this.getLevelOrder(level.level);
            if (levelOrder <= currentLevelOrder)
                continue;
            if (levelOrder > currentLevelOrder + 1)
                break;
            let shouldUnlock = false;
            if (level.level === client_1.AchievementLevelEnum.BRONZE || level.level === client_1.AchievementLevelEnum.SILVER) {
                shouldUnlock = shareCount >= level.requirement;
            }
            else {
                shouldUnlock = likeCount >= level.requirement;
            }
            if (shouldUnlock) {
                try {
                    await tx.userAchievement.upsert({
                        where: {
                            userId_achievementId: {
                                userId,
                                achievementId: achievement.id,
                            },
                        },
                        update: {
                            levelId: level.id,
                            isNew: true,
                            unlockedAt: new Date(),
                        },
                        create: {
                            userId,
                            achievementId: achievement.id,
                            levelId: level.id,
                            isNew: true,
                        },
                    });
                    unlocked.push({
                        achievementId: achievement.id,
                        level: level.level,
                        name: level.name,
                        message: this.generateUnlockMessage(achievement.name, level.name, level.level),
                        badgeUrl: level.iconUrl || achievement.iconUrl,
                    });
                    this.logger.log(`User ${userId} unlocked social achievement: ${level.level}`);
                }
                catch (error) {
                    this.logger.warn(`Social achievement upsert conflict for user ${userId}`, error);
                }
                break;
            }
        }
        return unlocked;
    }
    async checkCategoryAchievementsTx(tx, userId, achievementKey, currentProgress) {
        const achievement = await tx.achievement.findUnique({
            where: { key: achievementKey },
            include: { levels: { orderBy: { requirement: 'asc' } } },
        });
        if (!achievement)
            return [];
        const unlocked = [];
        const userAchievement = await tx.userAchievement.findUnique({
            where: {
                userId_achievementId: {
                    userId,
                    achievementId: achievement.id,
                },
            },
            include: { level: true },
        });
        const currentLevelOrder = userAchievement?.level
            ? this.getLevelOrder(userAchievement.level.level)
            : 0;
        for (const level of achievement.levels) {
            const levelOrder = this.getLevelOrder(level.level);
            if (levelOrder <= currentLevelOrder)
                continue;
            if (levelOrder > currentLevelOrder + 1)
                break;
            if (currentProgress >= level.requirement) {
                try {
                    await tx.userAchievement.upsert({
                        where: {
                            userId_achievementId: {
                                userId,
                                achievementId: achievement.id,
                            },
                        },
                        update: {
                            levelId: level.id,
                            isNew: true,
                            unlockedAt: new Date(),
                        },
                        create: {
                            userId,
                            achievementId: achievement.id,
                            levelId: level.id,
                            isNew: true,
                        },
                    });
                    unlocked.push({
                        achievementId: achievement.id,
                        level: level.level,
                        name: level.name,
                        message: this.generateUnlockMessage(achievement.name, level.name, level.level),
                        badgeUrl: level.iconUrl || achievement.iconUrl,
                    });
                    this.logger.log(`User ${userId} unlocked ${achievementKey}: ${level.level}`);
                }
                catch (error) {
                    this.logger.warn(`${achievementKey} achievement upsert conflict for user ${userId}`, error);
                }
                break;
            }
        }
        return unlocked;
    }
    async updateStatsAfterTrailTx(tx, userId, trailId, stats) {
        const userStats = await tx.userStats.findUnique({
            where: { userId },
        });
        const today = new Date();
        today.setHours(0, 0, 0, 0);
        if (!userStats) {
            return tx.userStats.create({
                data: {
                    userId,
                    totalDistanceM: stats.distance,
                    totalDurationSec: stats.duration,
                    uniqueTrailsCount: trailId ? 1 : 0,
                    completedTrailIds: trailId ? [trailId] : [],
                    nightTrailCount: stats.isNight ? 1 : 0,
                    rainTrailCount: stats.isRain ? 1 : 0,
                    soloTrailCount: stats.isSolo ? 1 : 0,
                    currentStreak: 1,
                    longestStreak: 1,
                    currentWeeklyStreak: 1,
                    longestWeeklyStreak: 1,
                    lastTrailDate: today,
                },
            });
        }
        const updateData = {
            totalDistanceM: { increment: stats.distance },
            totalDurationSec: { increment: stats.duration },
        };
        if (trailId) {
            const completedTrailIds = userStats.completedTrailIds || [];
            if (!completedTrailIds.includes(trailId)) {
                updateData.completedTrailIds = { push: trailId };
                updateData.uniqueTrailsCount = { increment: 1 };
            }
        }
        if (stats.isNight)
            updateData.nightTrailCount = { increment: 1 };
        if (stats.isRain)
            updateData.rainTrailCount = { increment: 1 };
        if (stats.isSolo)
            updateData.soloTrailCount = { increment: 1 };
        if (userStats.lastTrailDate) {
            const lastDate = new Date(userStats.lastTrailDate);
            lastDate.setHours(0, 0, 0, 0);
            const diffDays = Math.floor((today.getTime() - lastDate.getTime()) / (1000 * 60 * 60 * 24));
            if (diffDays === 0) {
            }
            else if (diffDays === 1) {
                const newStreak = (userStats.currentStreak || 0) + 1;
                updateData.currentStreak = newStreak;
                updateData.longestStreak = Math.max(userStats.longestStreak || 0, newStreak);
            }
            else {
                updateData.currentStreak = 1;
            }
        }
        else {
            updateData.currentStreak = 1;
            updateData.longestStreak = Math.max(userStats.longestStreak || 0, 1);
        }
        updateData.lastTrailDate = today;
        const lastWeek = userStats.lastTrailDate ? this.getWeekNumber(new Date(userStats.lastTrailDate)) : null;
        const thisWeek = this.getWeekNumber(today);
        if (lastWeek === thisWeek) {
        }
        else if (lastWeek === thisWeek - 1 || (lastWeek === 52 && thisWeek === 1)) {
            updateData.currentWeeklyStreak = (userStats.currentWeeklyStreak || 0) + 1;
            updateData.longestWeeklyStreak = Math.max(userStats.longestWeeklyStreak || 0, updateData.currentWeeklyStreak);
        }
        else {
            updateData.currentWeeklyStreak = 1;
        }
        await tx.userStats.update({
            where: { userId },
            data: updateData,
        });
        return tx.userStats.findUnique({ where: { userId } });
    }
    async incrementShareCountTx(tx, userId) {
        await tx.userStats.upsert({
            where: { userId },
            create: { userId, shareCount: 1 },
            update: { shareCount: { increment: 1 } },
        });
        return tx.userStats.findUnique({ where: { userId } });
    }
    async updateLikesCountTx(tx, userId, likeCount) {
        await tx.userStats.upsert({
            where: { userId },
            create: { userId, totalLikesReceived: likeCount },
            update: { totalLikesReceived: { increment: likeCount } },
        });
        return tx.userStats.findUnique({ where: { userId } });
    }
    async getOrCreateUserStatsTx(tx, userId) {
        const stats = await tx.userStats.findUnique({
            where: { userId },
        });
        if (stats)
            return stats;
        return tx.userStats.create({
            data: { userId },
        });
    }
    getLevelOrder(level) {
        const order = {
            [client_1.AchievementLevelEnum.BRONZE]: 1,
            [client_1.AchievementLevelEnum.SILVER]: 2,
            [client_1.AchievementLevelEnum.GOLD]: 3,
            [client_1.AchievementLevelEnum.DIAMOND]: 4,
        };
        return order[level] || 0;
    }
    generateUnlockMessage(achievementName, levelName, level) {
        const levelEmojis = {
            [client_1.AchievementLevelEnum.BRONZE]: '🥉',
            [client_1.AchievementLevelEnum.SILVER]: '🥈',
            [client_1.AchievementLevelEnum.GOLD]: '🥇',
            [client_1.AchievementLevelEnum.DIAMOND]: '💎',
        };
        return `${levelEmojis[level]} 恭喜解锁「${achievementName}·${levelName}」！`;
    }
    getWeekNumber(date) {
        const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
        const dayNum = d.getUTCDay() || 7;
        d.setUTCDate(d.getUTCDate() + 4 - dayNum);
        const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
        return Math.ceil(((d.getTime() - yearStart.getTime()) / 86400000 + 1) / 7);
    }
};
exports.AchievementsCheckerService = AchievementsCheckerService;
exports.AchievementsCheckerService = AchievementsCheckerService = AchievementsCheckerService_1 = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AchievementsCheckerService);
//# sourceMappingURL=achievements-checker.service.js.map