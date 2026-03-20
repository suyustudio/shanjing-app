import { PrismaService } from '../../../database/prisma.service';
import { RedisService } from '../../../shared/redis/redis.service';
import { RecommendationAlgorithmService } from './recommendation-algorithm.service';
import { UserProfileService } from './user-profile.service';
import { GetRecommendationsDto, RecommendationsResponseDto, FeedbackDto, ImpressionDto } from '../dto/recommendation.dto';
export declare class RecommendationService {
    private prisma;
    private redis;
    private algorithmService;
    private profileService;
    private readonly logger;
    constructor(prisma: PrismaService, redis: RedisService, algorithmService: RecommendationAlgorithmService, profileService: UserProfileService);
    getRecommendations(dto: GetRecommendationsDto, currentUserId?: string): Promise<RecommendationsResponseDto>;
    recordFeedback(dto: FeedbackDto, currentUserId: string): Promise<{
        success: boolean;
    }>;
    recordImpression(dto: ImpressionDto, currentUserId?: string): Promise<{
        success: boolean;
        message: string;
    }>;
    private getSimilarTrails;
    private getActiveTrails;
    private getCompletedTrailIds;
    private applySceneStrategy;
    private applyHomeStrategy;
    private applyNearbyStrategy;
    private buildCacheKey;
    private getFromCache;
    private setCache;
    private clearUserCache;
}
