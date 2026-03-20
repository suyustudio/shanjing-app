import { ReviewsService } from './reviews.service';
import { CreateReviewDto, UpdateReviewDto, CreateReplyDto, ReportReviewDto, QueryReviewsDto, ReviewDto, ReviewDetailDto, ReviewListResponseDto, ApiResponseDto, LikeReviewResponseDto } from './dto/review.dto';
import { Request } from 'express';
interface RequestWithUser extends Request {
    user: {
        userId: string;
    };
}
export declare class ReviewsController {
    private readonly reviewsService;
    constructor(reviewsService: ReviewsService);
    createReview(req: RequestWithUser, trailId: string, dto: CreateReviewDto): Promise<ApiResponseDto<ReviewDto>>;
    getReviews(req: RequestWithUser, trailId: string, query: QueryReviewsDto): Promise<ApiResponseDto<ReviewListResponseDto>>;
    getReviewDetail(req: RequestWithUser, id: string): Promise<ApiResponseDto<ReviewDetailDto>>;
    updateReview(req: RequestWithUser, id: string, dto: UpdateReviewDto): Promise<ApiResponseDto<ReviewDto>>;
    deleteReview(req: RequestWithUser, id: string): Promise<ApiResponseDto<{
        message: string;
    }>>;
    likeReview(req: RequestWithUser, id: string): Promise<ApiResponseDto<LikeReviewResponseDto>>;
    checkLikeStatus(req: RequestWithUser, id: string): Promise<ApiResponseDto<{
        isLiked: boolean;
    }>>;
    createReply(req: RequestWithUser, id: string, dto: CreateReplyDto): Promise<ApiResponseDto<any>>;
    getReplies(id: string): Promise<ApiResponseDto<any[]>>;
    reportReview(req: RequestWithUser, id: string, dto: ReportReviewDto): Promise<ApiResponseDto<{
        message: string;
    }>>;
}
export {};
