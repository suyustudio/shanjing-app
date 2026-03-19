import { TrailDifficulty } from '@prisma/client';
export declare class CreateTrailDto {
    name: string;
    description?: string;
    distanceKm: number;
    durationMin: number;
    elevationGainM: number;
    difficulty: TrailDifficulty;
    tags?: string[];
    coverImages?: string[];
    gpxUrl?: string;
    city: string;
    district: string;
    startPointLat: number;
    startPointLng: number;
    startPointAddress?: string;
    safetyInfo?: Record<string, any>;
}
export declare class UpdateTrailDto {
    name?: string;
    description?: string;
    distanceKm?: number;
    durationMin?: number;
    elevationGainM?: number;
    difficulty?: TrailDifficulty;
    tags?: string[];
    coverImages?: string[];
    gpxUrl?: string;
    city?: string;
    district?: string;
    startPointLat?: number;
    startPointLng?: number;
    startPointAddress?: string;
    safetyInfo?: Record<string, any>;
    isActive?: boolean;
}
export declare class TrailListQueryDto {
    keyword?: string;
    city?: string;
    difficulty?: TrailDifficulty;
    isActive?: boolean;
    page?: number;
    limit?: number;
}
export declare class TrailResponseDto {
    success: boolean;
    errorMessage?: string;
    data: {
        id: string;
        name: string;
        description: string | null;
        distanceKm: number;
        durationMin: number;
        elevationGainM: number;
        difficulty: TrailDifficulty;
        tags: string[];
        coverImages: string[];
        gpxUrl: string | null;
        city: string;
        district: string;
        startPointLat: number;
        startPointLng: number;
        startPointAddress: string | null;
        safetyInfo: Record<string, any> | null;
        isActive: boolean;
        createdAt: Date;
        updatedAt: Date;
    };
}
export declare class TrailListResponseDto {
    success: boolean;
    data: Array<{
        id: string;
        name: string;
        distanceKm: number;
        durationMin: number;
        difficulty: TrailDifficulty;
        city: string;
        district: string;
        isActive: boolean;
        createdAt: Date;
    }>;
    meta: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}
