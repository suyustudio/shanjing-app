import { AchievementCategory, AchievementLevelEnum } from '@prisma/client';
export declare class TrailStatsDto {
    distance: number;
    duration: number;
    isNight: boolean;
    isRain: boolean;
    isSolo: boolean;
}
export declare class AchievementLevelDto {
    id: string;
    level: AchievementLevelEnum;
    requirement: number;
    name: string;
    description?: string;
    reward?: string;
    iconUrl?: string;
}
export declare class AchievementDto {
    id: string;
    key: string;
    name: string;
    description?: string;
    category: AchievementCategory;
    iconUrl?: string;
    isHidden: boolean;
    sortOrder: number;
    levels: AchievementLevelDto[];
}
export declare class UserAchievementDto {
    achievementId: string;
    key: string;
    name: string;
    category: string;
    currentLevel?: string;
    currentProgress: number;
    nextRequirement: number;
    percentage: number;
    unlockedAt?: Date;
    isNew: boolean;
    isUnlocked: boolean;
}
export declare class UserAchievementSummaryDto {
    totalCount: number;
    unlockedCount: number;
    newUnlockedCount: number;
    achievements: UserAchievementDto[];
}
export declare class CheckAchievementsRequestDto {
    triggerType: 'trail_completed' | 'share' | 'manual';
    trailId?: string;
    stats?: TrailStatsDto;
}
export declare class NewlyUnlockedAchievementDto {
    achievementId: string;
    level: string;
    name: string;
    message: string;
    badgeUrl: string;
}
export declare class ProgressUpdateDto {
    achievementId: string;
    progress: number;
    requirement: number;
    percentage: number;
}
export declare class CheckAchievementsResponseDto {
    newlyUnlocked: NewlyUnlockedAchievementDto[];
    progressUpdated: ProgressUpdateDto[];
}
export declare class UserStatsDto {
    totalDistanceM: number;
    totalDurationSec: number;
    totalElevationGainM: number;
    uniqueTrailsCount: number;
    currentWeeklyStreak: number;
    longestWeeklyStreak: number;
    nightTrailCount: number;
    rainTrailCount: number;
    shareCount: number;
}
