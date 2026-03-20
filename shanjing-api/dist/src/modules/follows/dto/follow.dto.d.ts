export declare class QueryFollowsDto {
    cursor?: string;
    limit?: number;
}
export declare class FollowUserDto {
    id: string;
    nickname: string | null;
    avatarUrl: string | null;
    bio?: string | null;
    followersCount: number;
    isFollowing?: boolean;
    mutualFollows?: number;
}
export declare class FollowListResponseDto {
    list: FollowUserDto[];
    nextCursor: string | null;
    hasMore: boolean;
    total: number;
}
export declare class FollowStatsDto {
    followersCount: number;
    followingCount: number;
    isFollowing: boolean;
}
export declare class FollowActionResponseDto {
    isFollowing: boolean;
    followersCount: number;
    followingCount: number;
}
