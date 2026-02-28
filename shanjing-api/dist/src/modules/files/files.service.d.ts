import { ConfigService } from '@nestjs/config';
export declare class FilesService {
    private readonly configService;
    private readonly uploadDir;
    private readonly baseUrl;
    constructor(configService: ConfigService);
    uploadAvatar(file: Express.Multer.File, userId: string): Promise<string>;
    deleteFile(fileUrl: string): Promise<void>;
}
