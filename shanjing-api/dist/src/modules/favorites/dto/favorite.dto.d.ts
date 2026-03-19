export declare class FavoriteListQueryDto {
    page?: number;
    limit?: number;
}
export declare class AddFavoriteDto {
    trailId: string;
}
export declare class RemoveFavoriteDto {
    trailId: string;
}
export declare class FavoriteListItemDto {
    id: string;
    trailId: string;
    trailName: string;
    coverImage: string;
    distanceKm: number;
    durationMin: number;
    difficulty: string;
    city: string;
    createdAt: Date;
}
export declare class FavoriteListResponseDto {
    data: FavoriteListItemDto[];
    meta: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}
export declare class FavoriteStatusResponseDto {
    isFavorited: boolean;
    favoriteCount: number;
}
export declare class FavoriteActionResponseDto {
    success: boolean;
    isFavorited: boolean;
    favoriteCount: number;
    message: string;
}
