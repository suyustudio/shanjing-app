export declare class CreateCollectionDto {
    name: string;
    description?: string;
    coverUrl?: string;
    isPublic?: boolean;
}
export declare class UpdateCollectionDto {
    name?: string;
    description?: string;
    coverUrl?: string;
    isPublic?: boolean;
    sortOrder?: number;
}
export declare class AddTrailToCollectionDto {
    trailId: string;
    note?: string;
}
export declare class BatchAddTrailsDto {
    trailIds: string[];
}
export declare class QueryCollectionsDto {
    userId?: string;
    page?: number;
    limit?: number;
}
export declare class CollectionUserDto {
    id: string;
    nickname: string | null;
    avatarUrl: string | null;
}
export declare class CollectionTrailDto {
    id: string;
    trailId: string;
    trail: {
        id: string;
        name: string;
        coverImages: string[];
        distanceKm: number;
        durationMin: number;
        difficulty: string;
        avgRating: number | null;
        reviewCount: number;
    };
    note: string | null;
    createdAt: Date;
}
export declare class CollectionDto {
    id: string;
    name: string;
    description: string | null;
    coverUrl: string | null;
    isPublic: boolean;
    sortOrder: number;
    trailCount: number;
    createdAt: Date;
    updatedAt: Date;
    user: CollectionUserDto;
}
export declare class CollectionDetailDto extends CollectionDto {
    trails: CollectionTrailDto[];
}
export declare class CollectionListResponseDto {
    list: CollectionDto[];
    total: number;
    page: number;
    limit: number;
}
