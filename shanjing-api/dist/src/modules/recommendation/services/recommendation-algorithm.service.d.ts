import { PrismaService } from '../../../database/prisma.service';
import { RedisService } from '../../../shared/redis/redis.service';
import { ScoredTrail, UserPreferenceVector, RecommendationScene } from '../dto/recommendation.dto';
export declare class RecommendationAlgorithmService {
    private prisma;
    private redis;
    private readonly logger;
    constructor(prisma: PrismaService, redis: RedisService);
    calculateScores(trails: any[], userPrefs: UserPreferenceVector, userLat?: number, userLng?: number, scene?: RecommendationScene): Promise<ScoredTrail[]>;
    private batchGetPopularityData;
    private calculateDifficultyMatch;
    private calculateDistanceScore;
    private calculateRatingScore;
    private calculatePopularityScoreFromData;
    private calculateFreshnessScore;
    private extractTrailFeatures;
    private calculateDistanceM;
    generateRecommendReason(scoredTrail: ScoredTrail, scene: RecommendationScene): string;
    clearRecommendationCache(userId: string): Promise<void>;
}
