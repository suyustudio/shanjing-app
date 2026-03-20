import { PrismaService } from '../../database/prisma.service';
import { CreateReviewDto, UpdateReviewDto, CreateReplyDto, QueryReviewsDto, ReviewDto, ReviewDetailDto, ReviewListResponseDto, ReviewStatsDto, ReviewReplyDto, LikeReviewResponseDto } from './dto/review.dto';
export declare class ReviewsService {
    private prisma;
    private readonly EDIT_TIME_LIMIT_HOURS;
    constructor(prisma: PrismaService);
    createReview(userId: string, trailId: string, dto: CreateReviewDto): Promise<ReviewDto>;
    getReviews(trailId: string, query: QueryReviewsDto, currentUserId?: string): Promise<ReviewListResponseDto>;
    getReviewDetail(reviewId: string, currentUserId?: string): Promise<ReviewDetailDto>;
    updateReview(userId: string, reviewId: string, dto: UpdateReviewDto): Promise<ReviewDto>;
    deleteReview(userId: string, reviewId: string): Promise<void>;
    createReply(userId: string, reviewId: string, dto: CreateReplyDto): Promise<ReviewReplyDto>;
    getReplies(reviewId: string): Promise<ReviewReplyDto[]>;
    likeReview(userId: string, reviewId: string): Promise<LikeReviewResponseDto>;
    checkUserLikedReview(userId: string, reviewId: string): Promise<boolean>;
    getReviewStats(trailId: string): Promise<ReviewStatsDto>;
    private updateTrailRatingStats;
    private calculateWeightedRating;
    private checkUserCompletedTrail;
    reportReview(userId: string, reviewId: string, reason: string): Promise<void>;
    private mapToReviewDto;
    private mapToReviewDetailDto;
    private mapToReplyDto;
}
