import { PrismaService } from '../../database/prisma.service';
import { UploadRecordingDto, RecordingListQueryDto, ApproveRecordingDto } from './dto/recording.dto';
export declare class RecordingService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    uploadRecording(dto: UploadRecordingDto, userId: string): Promise<{
        success: boolean;
        data: {
            recordingId: any;
            trailName: any;
            status: any;
            message: string;
        };
    }>;
    getUserRecordings(userId: string, query: RecordingListQueryDto): Promise<{
        success: boolean;
        data: any;
        meta: {
            page: number;
            limit: number;
            total: any;
            totalPages: number;
        };
    }>;
    getRecordingDetail(recordingId: string, userId: string): Promise<{
        success: boolean;
        data: {
            id: any;
            trailName: any;
            description: any;
            status: any;
            city: any;
            district: any;
            difficulty: any;
            tags: any;
            distanceMeters: any;
            durationSeconds: any;
            elevationGain: any;
            elevationLoss: any;
            pointCount: any;
            poiCount: any;
            trackData: any;
            trailId: any;
            reviewComment: any;
            createdAt: any;
            updatedAt: any;
        };
    }>;
    getPendingRecordings(query: RecordingListQueryDto): Promise<{
        success: boolean;
        data: any;
        meta: {
            page: number;
            limit: number;
            total: any;
            totalPages: number;
        };
    }>;
    approveRecording(recordingId: string, dto: ApproveRecordingDto): Promise<{
        success: boolean;
        data: {
            recordingId: any;
            trailId: string;
            trailName: string;
            message: string;
        };
    }>;
    rejectRecording(recordingId: string, reason?: string): Promise<{
        success: boolean;
        data: {
            recordingId: any;
            message: string;
            reason: string;
        };
    }>;
    private calculateTrackStats;
    private calculateBounds;
    private calculateDistance;
    private toRadians;
}
