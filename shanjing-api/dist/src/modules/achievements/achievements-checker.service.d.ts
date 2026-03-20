import { PrismaService } from '../../database/prisma.service';
import { AchievementLevelEnum } from '@prisma/client';
interface TrailStats {
    distance: number;
    duration: number;
    isNight: boolean;
    isRain: boolean;
    isSolo: boolean;
}
interface CheckAchievementsDto {
    triggerType: 'trail_completed' | 'share' | 'manual' | 'like_received';
    trailId?: string;
    stats?: TrailStats;
    likeCount?: number;
}
interface UnlockedAchievement {
    achievementId: string;
    level: AchievementLevelEnum;
    name: string;
    message: string;
    badgeUrl?: string;
}
export declare class AchievementsCheckerService {
    private readonly prisma;
    private readonly logger;
    constructor(prisma: PrismaService);
    checkAchievements(userId: string, dto: CheckAchievementsDto): Promise<{
        newlyUnlocked: UnlockedAchievement[];
    }>;
    private checkAndUnlockFirstHikeTx;
    private checkDistanceAchievementsTx;
    private checkTrailAchievementsTx;
    private checkStreakAchievementsTx;
    private checkSocialAchievementsTx;
    private checkCategoryAchievementsTx;
    private updateStatsAfterTrailTx;
    private incrementShareCountTx;
    private updateLikesCountTx;
    private getOrCreateUserStatsTx;
    private getLevelOrder;
    private generateUnlockMessage;
    private getWeekNumber;
}
export {};
