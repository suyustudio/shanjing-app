import { Request } from 'express';
import { RecommendationService } from './services/recommendation.service';
import { GetRecommendationsDto, RecommendationsResponseDto, FeedbackDto, ImpressionDto } from './dto/recommendation.dto';
export declare class RecommendationController {
    private recommendationService;
    constructor(recommendationService: RecommendationService);
    getRecommendations(dto: GetRecommendationsDto, req: Request): Promise<{
        success: boolean;
        data: RecommendationsResponseDto;
    }>;
    recordFeedback(dto: FeedbackDto, req: Request): Promise<{
        success: boolean;
    }>;
    recordImpression(dto: ImpressionDto, req: Request): Promise<{
        success: boolean;
        message: string;
    }>;
}
