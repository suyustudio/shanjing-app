import { ConfigService } from '@nestjs/config';
export interface OssUploadResult {
    url: string;
    thumbnailUrl?: string;
    width: number;
    height: number;
    size: number;
}
export interface PresignedUrlResult {
    uploadUrl: string;
    accessUrl: string;
    thumbnailUrl?: string;
    key: string;
    expires: number;
}
export declare class OssService {
    private readonly configService;
    private client;
    private bucket;
    private region;
    private baseUrl;
    constructor(configService: ConfigService);
    isConfigured(): boolean;
    generatePhotoUploadUrl(userId: string, filename: string, contentType: string): Promise<PresignedUrlResult>;
    generateBatchUploadUrls(userId: string, files: {
        filename: string;
        contentType: string;
    }[]): Promise<PresignedUrlResult[]>;
    deleteFile(fileUrl: string): Promise<void>;
    generateThumbnail(imageBuffer: Buffer, maxWidth?: number): Promise<Buffer>;
    getImageMetadata(imageBuffer: Buffer): Promise<{
        width: number;
        height: number;
    }>;
}
