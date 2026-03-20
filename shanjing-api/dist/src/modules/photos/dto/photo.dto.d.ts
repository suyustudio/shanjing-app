export declare class CreatePhotoDto {
    url: string;
    thumbnailUrl?: string;
    trailId?: string;
    poiId?: string;
    width?: number;
    height?: number;
    description?: string;
    latitude?: number;
    longitude?: number;
    takenAt?: string;
}
export declare class CreatePhotosDto {
    photos: CreatePhotoDto[];
}
export declare class UpdatePhotoDto {
    description?: string;
    isPublic?: boolean;
}
export declare class QueryPhotosDto {
    trailId?: string;
    userId?: string;
    sort?: 'newest' | 'popular';
    cursor?: string;
    limit?: number;
}
export declare class PhotoUserDto {
    id: string;
    nickname: string | null;
    avatarUrl: string | null;
}
export declare class PhotoDto {
    id: string;
    url: string;
    thumbnailUrl: string | null;
    width: number | null;
    height: number | null;
    description: string | null;
    likeCount: number;
    isLiked?: boolean;
    isPublic: boolean;
    createdAt: Date;
    user: PhotoUserDto;
    trail?: {
        id: string;
        name: string;
    } | null;
}
export declare class PhotoListResponseDto {
    list: PhotoDto[];
    nextCursor: string | null;
    hasMore: boolean;
}
export declare class LikePhotoResponseDto {
    isLiked: boolean;
    likeCount: number;
}
