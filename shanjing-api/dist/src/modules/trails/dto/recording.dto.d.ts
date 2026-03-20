import { TrailDifficulty } from '@prisma/client';
export declare class UploadRecordingDto {
    sessionId: string;
    trailName: string;
    description?: string;
    city: string;
    district: string;
    difficulty: TrailDifficulty;
    tags?: string[];
    trackData: {
        trackPoints: Array<{
            latitude: number;
            longitude: number;
            altitude: number;
            accuracy: number;
            speed?: number;
            timestamp: string;
        }>;
        pois?: Array<{
            id: string;
            latitude: number;
            longitude: number;
            altitude: number;
            type: string;
            name?: string;
            description?: string;
            photoUrls?: string[];
            createdAt: string;
        }>;
        durationSeconds: number;
        elevationGain: number;
        elevationLoss: number;
    };
}
export declare class RecordingListQueryDto {
    status?: string;
    page?: number;
    limit?: number;
}
export declare class ApproveRecordingDto {
    trailName?: string;
    description?: string;
    difficulty?: TrailDifficulty;
    tags?: string[];
    startPointAddress?: string;
    coverImages?: string[];
    comment?: string;
}
export declare class UploadResponseDto {
    success: boolean;
    data: {
        recordingId: string;
        trailName: string;
        status: string;
        message?: string;
    };
}
export declare class RecordingListItemDto {
    id: string;
    trailName: string;
    status: string;
    city: string;
    district: string;
    difficulty: TrailDifficulty;
    distanceKm: string;
    durationMin: number;
    pointCount: number;
    poiCount: number;
    trailId?: string;
    createdAt: Date;
}
export declare class RecordingListResponseDto {
    data: RecordingListItemDto[];
    meta: {
        page: number;
        limit: number;
        total: number;
        totalPages: number;
    };
}
export declare class RecordingDetailResponseDto {
    id: string;
    trailName: string;
    description?: string;
    status: string;
    city: string;
    district: string;
    difficulty: TrailDifficulty;
    tags: string[];
    distanceMeters: number;
    durationSeconds: number;
    elevationGain: number;
    elevationLoss: number;
    pointCount: number;
    poiCount: number;
    trackData: any;
    trailId?: string;
    reviewComment?: string;
    createdAt: Date;
    updatedAt: Date;
}
