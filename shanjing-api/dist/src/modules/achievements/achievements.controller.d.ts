import { AchievementsService } from './achievements.service';
import { AchievementDto, UserAchievementSummaryDto, CheckAchievementsRequestDto, CheckAchievementsResponseDto, UserStatsDto } from './dto/achievement.dto';
export declare class AchievementsController {
    private readonly achievementsService;
    constructor(achievementsService: AchievementsService);
    getAllAchievements(): Promise<AchievementDto[]>;
    getAchievementById(id: string): Promise<AchievementDto>;
    getMyAchievements(req: any): Promise<UserAchievementSummaryDto>;
    getUserAchievements(userId: string): Promise<UserAchievementSummaryDto>;
    checkAchievements(req: any, dto: CheckAchievementsRequestDto): Promise<CheckAchievementsResponseDto>;
    markAchievementViewed(req: any, achievementId: string): Promise<{
        success: boolean;
    }>;
    markAllAchievementsViewed(req: any): Promise<{
        success: boolean;
    }>;
}
export declare class AchievementCacheController {
    private readonly achievementsService;
    constructor(achievementsService: AchievementsService);
    clearAllCache(): Promise<{
        success: boolean;
        message: string;
    }>;
    invalidateByTag(tag: string): Promise<{
        success: boolean;
        deletedCount: number;
    }>;
}
export declare class UserStatsController {
    private readonly achievementsService;
    constructor(achievementsService: AchievementsService);
    getUserStats(req: any): Promise<UserStatsDto>;
}
