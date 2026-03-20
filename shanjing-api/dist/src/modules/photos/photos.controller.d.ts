import { PhotosService } from './photos.service';
import { CreatePhotoDto, CreatePhotosDto, UpdatePhotoDto, QueryPhotosDto, PhotoDto, PhotoListResponseDto, LikePhotoResponseDto } from './dto/photo.dto';
import { Request } from 'express';
interface RequestWithUser extends Request {
    user: {
        userId: string;
    };
}
export declare class PhotosController {
    private readonly photosService;
    constructor(photosService: PhotosService);
    createPhoto(req: RequestWithUser, dto: CreatePhotoDto): Promise<{
        success: boolean;
        data: PhotoDto;
        meta: any;
    }>;
    createPhotos(req: RequestWithUser, dto: CreatePhotosDto): Promise<{
        success: boolean;
        data: PhotoDto[];
        meta: any;
    }>;
    getPhotos(req: RequestWithUser, query: QueryPhotosDto): Promise<{
        success: boolean;
        data: PhotoListResponseDto;
        meta: any;
    }>;
    getPhotoDetail(req: RequestWithUser, id: string): Promise<{
        success: boolean;
        data: PhotoDto;
        meta: any;
    }>;
    updatePhoto(req: RequestWithUser, id: string, dto: UpdatePhotoDto): Promise<{
        success: boolean;
        data: PhotoDto;
        meta: any;
    }>;
    deletePhoto(req: RequestWithUser, id: string): Promise<{
        success: boolean;
        data: {
            message: string;
        };
        meta: any;
    }>;
    likePhoto(req: RequestWithUser, id: string): Promise<{
        success: boolean;
        data: LikePhotoResponseDto;
        meta: any;
    }>;
    getUserPhotos(req: RequestWithUser, userId: string, cursor?: string, limit?: number): Promise<{
        success: boolean;
        data: PhotoListResponseDto;
        meta: any;
    }>;
}
export {};
