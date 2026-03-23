import { PrismaService } from '../../database/prisma.service';
import { UploadRecordingDto, RecordingListQueryDto, ApproveRecordingDto } from './dto/recording.dto';
export declare class RecordingService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    uploadRecording(dto: UploadRecordingDto, userId: string): Promise<{
        success: boolean;
        data: {
            recordingId: string;
            trailName: string;
            status: import(".prisma/client").$Enums.RecordingStatus;
            message: string;
        };
    }>;
    getUserRecordings(userId: string, query: RecordingListQueryDto): Promise<{
        success: boolean;
        data: {
            id: string;
            trailName: string;
            status: import(".prisma/client").$Enums.RecordingStatus;
            city: string;
            district: string;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            distanceKm: string;
            durationMin: number;
            pointCount: number;
            poiCount: number;
            trailId: string;
            createdAt: Date;
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
    }>;
    getRecordingDetail(recordingId: string, userId: string): Promise<{
        success: boolean;
        data: {
            id: string;
            trailName: string;
            description: string;
            status: import(".prisma/client").$Enums.RecordingStatus;
            city: string;
            district: string;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            tags: string[];
            distanceMeters: number;
            durationSeconds: number;
            elevationGain: number;
            elevationLoss: number;
            pointCount: number;
            poiCount: number;
            trackData: import("@prisma/client/runtime/library").JsonValue;
            trailId: string;
            reviewComment: string;
            createdAt: Date;
            updatedAt: Date;
        };
    }>;
    getPendingRecordings(query: RecordingListQueryDto): Promise<{
        success: boolean;
        data: {
            id: string;
            trailName: string;
            description: string;
            city: string;
            district: string;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            distanceMeters: number;
            durationSeconds: number;
            pointCount: number;
            poiCount: number;
            createdAt: Date;
            user: {
                id: string;
                nickname: string;
                avatarUrl: string;
            };
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
    }>;
    approveRecording(recordingId: string, dto: ApproveRecordingDto): Promise<{
        success: boolean;
        data: {
            recordingId: string;
            trailId: string;
            trailName: string;
            message: string;
        };
    }>;
    rejectRecording(recordingId: string, reason?: string): Promise<{
        success: boolean;
        data: {
            recordingId: string;
            message: string;
            reason: string;
        };
    }>;
    private calculateTrackStats;
    private calculateBounds;
    private calculateDistance;
    private toRadians;
}
