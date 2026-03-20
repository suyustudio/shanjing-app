import { PrismaService } from '../../database/prisma.service';
import { CreateCollectionDto, UpdateCollectionDto, AddTrailToCollectionDto, BatchAddTrailsDto, QueryCollectionsDto, CollectionDto, CollectionDetailDto, CollectionListResponseDto } from './dto/collection.dto';
export declare class CollectionsService {
    private prisma;
    constructor(prisma: PrismaService);
    createCollection(userId: string, dto: CreateCollectionDto): Promise<CollectionDto>;
    getCollections(query: QueryCollectionsDto, currentUserId?: string): Promise<CollectionListResponseDto>;
    getCollectionDetail(collectionId: string, currentUserId?: string): Promise<CollectionDetailDto>;
    updateCollection(userId: string, collectionId: string, dto: UpdateCollectionDto): Promise<CollectionDto>;
    deleteCollection(userId: string, collectionId: string): Promise<void>;
    addTrailToCollection(userId: string, collectionId: string, dto: AddTrailToCollectionDto): Promise<CollectionDetailDto>;
    removeTrailFromCollection(userId: string, collectionId: string, trailId: string): Promise<void>;
    batchAddTrails(userId: string, collectionId: string, dto: BatchAddTrailsDto): Promise<CollectionDetailDto>;
    private mapToCollectionDto;
    private mapToCollectionDetailDto;
}
