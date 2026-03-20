import { OssService, PresignedUrlResult } from './oss.service';
import { Request } from 'express';
interface RequestWithUser extends Request {
    user: {
        userId: string;
    };
}
declare class GenerateUploadUrlDto {
    filename: string;
    contentType: string;
}
declare class BatchUploadUrlDto {
    files: {
        filename: string;
        contentType: string;
    }[];
}
export declare class FilesController {
    private readonly ossService;
    constructor(ossService: OssService);
    getUploadUrl(req: RequestWithUser, dto: GenerateUploadUrlDto): Promise<{
        success: boolean;
        data: PresignedUrlResult;
    }>;
    getBatchUploadUrls(req: RequestWithUser, dto: BatchUploadUrlDto): Promise<{
        success: boolean;
        data: PresignedUrlResult[];
    }>;
    getStatus(): {
        success: boolean;
        data: {
            configured: boolean;
        };
    };
}
export {};
