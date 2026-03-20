import { PrismaService } from '../../database/prisma.service';
import { CreatePhotoDto, CreatePhotosDto, UpdatePhotoDto, QueryPhotosDto, PhotoDto, PhotoListResponseDto, LikePhotoResponseDto } from './dto/photo.dto';
export declare class PhotosService {
    private prisma;
    constructor(prisma: PrismaService);
    createPhoto(userId: string, dto: CreatePhotoDto): Promise<PhotoDto>;
    createPhotos(userId: string, dto: CreatePhotosDto): Promise<PhotoDto[]>;
    getPhotos(query: QueryPhotosDto, currentUserId?: string): Promise<PhotoListResponseDto>;
    getPhotoDetail(photoId: string, currentUserId?: string): Promise<PhotoDto>;
    updatePhoto(userId: string, photoId: string, dto: UpdatePhotoDto): Promise<PhotoDto>;
    deletePhoto(userId: string, photoId: string): Promise<void>;
    likePhoto(userId: string, photoId: string): Promise<LikePhotoResponseDto>;
    getUserPhotos(userId: string, currentUserId?: string, cursor?: string, limit?: number): Promise<PhotoListResponseDto>;
    private mapToPhotoDto;
}
