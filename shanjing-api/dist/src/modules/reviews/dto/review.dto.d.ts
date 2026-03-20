export declare const PREDEFINED_TAGS: readonly ["风景优美", "视野开阔", "拍照圣地", "秋色迷人", "春花烂漫", "难度适中", "轻松休闲", "挑战性强", "适合新手", "需要体能", "设施完善", "补给方便", "厕所干净", "指示牌清晰", "适合亲子", "宠物友好", "人少清静", "团队建设", "历史文化", "古迹众多", "森林氧吧", "溪流潺潺"];
export type PredefinedTag = typeof PREDEFINED_TAGS[number];
export declare class ApiResponseDto<T> {
    success: boolean;
    data: T;
    message?: string;
    meta?: {
        total?: number;
        page?: number;
        limit?: number;
        hasMore?: boolean;
    };
}
export declare class CreateReviewDto {
    rating: number;
    content?: string;
    tags?: string[];
    photos?: string[];
    difficulty?: string;
}
export declare class UpdateReviewDto {
    rating?: number;
    content?: string;
    tags?: string[];
    photos?: string[];
}
export declare class CreateReplyDto {
    content: string;
    parentId?: string;
}
export declare class ReportReviewDto {
    reason: string;
}
export declare class QueryReviewsDto {
    sort?: 'newest' | 'highest' | 'lowest' | 'hot';
    rating?: number;
    page?: number;
    limit?: number;
}
export declare class ReviewUserDto {
    id: string;
    nickname: string | null;
    avatarUrl: string | null;
}
export declare class ReviewReplyDto {
    id: string;
    content: string;
    user: ReviewUserDto;
    parentId: string | null;
    createdAt: Date;
}
export declare class ReviewDto {
    id: string;
    rating: number;
    content: string | null;
    tags: string[];
    photos: string[];
    likeCount: number;
    replyCount: number;
    isEdited: boolean;
    isVerified: boolean;
    isLiked?: boolean;
    user: ReviewUserDto;
    createdAt: Date;
    updatedAt: Date;
}
export declare class ReviewDetailDto extends ReviewDto {
    replies: ReviewReplyDto[];
}
export declare class ReviewStatsDto {
    trailId: string;
    avgRating: number;
    totalCount: number;
    rating5Count: number;
    rating4Count: number;
    rating3Count: number;
    rating2Count: number;
    rating1Count: number;
}
export declare class ReviewListResponseDto {
    list: ReviewDto[];
    total: number;
    page: number;
    limit: number;
    stats: ReviewStatsDto;
}
export declare class LikeReviewResponseDto {
    isLiked: boolean;
    likeCount: number;
}
