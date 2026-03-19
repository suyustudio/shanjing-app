import { TrailDifficulty } from '@prisma/client';
export declare class TrailListQueryDto {
    keyword?: string;
    city?: string;
    district?: string;
    difficulty?: TrailDifficulty;
    tag?: string;
    page?: number;
    limit?: number;
}
export declare class TrailDetailResponseDto {
    id: string;
    name: string;
    description?: string;
    distanceKm: number;
    durationMin: number;
    elevationGainM: number;
    difficulty: TrailDifficulty;
    tags: string[];
    coverImages: string[];
    gpxUrl?: string;
    city: string;
    district: string;
    startPointLat: number;
    startPointLng: number;
    startPointAddress?: string;
    safetyInfo?: any;
    favoriteCount: number;
    isFavorited: boolean;
    pois: TrailPoiDto[];
    createdAt: Date;
}
export declare class TrailPoiDto {
    id: string;
    name: string;
    description?: string;
    lat: number;
    lng: number;
    type: string;
    order: number;
}
export declare class TrailListItemDto {
    id: string;
    name: string;
    distanceKm: number;
    durationMin: number;
    difficulty: TrailDifficulty;
    city: string;
    district: string;
    coverImages: string[];
    favoriteCount: number;
    isFavorited: boolean;
}
export declare class TrailListResponseDto {
    data: TrailListItemDto[];
    meta: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}
export declare class NearbyTrailsQueryDto {
    lat: number;
    lng: number;
    radius?: number;
    limit?: number;
}
export declare class RecommendedTrailsResponseDto {
    data: TrailListItemDto[];
}
