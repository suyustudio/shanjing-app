import { CollectionsService } from './collections.service';
import { CreateCollectionDto, UpdateCollectionDto, AddTrailToCollectionDto, BatchAddTrailsDto, BatchRemoveTrailsDto, BatchMoveTrailsDto, SearchCollectionTrailsDto, QueryCollectionsDto, CollectionDto, CollectionDetailDto, CollectionListResponseDto } from './dto/collection.dto';
import { Request } from 'express';
interface RequestWithUser extends Request {
    user: {
        userId: string;
    };
}
export declare class CollectionsController {
    private readonly collectionsService;
    constructor(collectionsService: CollectionsService);
    createCollection(req: RequestWithUser, dto: CreateCollectionDto): Promise<{
        success: boolean;
        data: CollectionDto;
        meta: any;
    }>;
    getCollections(req: RequestWithUser, query: QueryCollectionsDto): Promise<{
        success: boolean;
        data: CollectionListResponseDto;
        meta: any;
    }>;
    getCollectionDetail(req: RequestWithUser, id: string): Promise<{
        success: boolean;
        data: CollectionDetailDto;
        meta: any;
    }>;
    updateCollection(req: RequestWithUser, id: string, dto: UpdateCollectionDto): Promise<{
        success: boolean;
        data: CollectionDto;
        meta: any;
    }>;
    deleteCollection(req: RequestWithUser, id: string): Promise<{
        success: boolean;
        data: {
            message: string;
        };
        meta: any;
    }>;
    addTrailToCollection(req: RequestWithUser, id: string, dto: AddTrailToCollectionDto): Promise<{
        success: boolean;
        data: CollectionDetailDto;
        meta: any;
    }>;
    batchAddTrails(req: RequestWithUser, id: string, dto: BatchAddTrailsDto): Promise<{
        success: boolean;
        data: CollectionDetailDto;
        meta: any;
    }>;
    removeTrailFromCollection(req: RequestWithUser, collectionId: string, trailId: string): Promise<{
        success: boolean;
        data: {
            message: string;
        };
        meta: any;
    }>;
    batchRemoveTrails(req: RequestWithUser, id: string, dto: BatchRemoveTrailsDto): Promise<{
        success: boolean;
        data: {
            message: string;
        };
        meta: any;
    }>;
    batchMoveTrails(req: RequestWithUser, id: string, dto: BatchMoveTrailsDto): Promise<{
        success: boolean;
        data: CollectionDetailDto;
        meta: any;
    }>;
    searchCollectionTrails(req: RequestWithUser, id: string, dto: SearchCollectionTrailsDto): Promise<{
        success: boolean;
        data: CollectionDetailDto;
        meta: any;
    }>;
    getAllTags(req: RequestWithUser, userId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            color: string;
            count: number;
        }[];
        meta: any;
    }>;
    createTag(req: RequestWithUser, body: {
        name: string;
        color?: string;
    }): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            color: string;
            count: number;
        };
        meta: any;
    }>;
    deleteTag(req: RequestWithUser, tagName: string): Promise<{
        success: boolean;
        data: {
            message: string;
        };
        meta: any;
    }>;
    getCollectionTags(req: RequestWithUser, collectionId: string): Promise<{
        success: boolean;
        data: string[];
        meta: any;
    }>;
    updateCollectionTags(req: RequestWithUser, collectionId: string, body: {
        tags: string[];
    }): Promise<{
        success: boolean;
        data: CollectionDto;
        meta: any;
    }>;
    searchTags(req: RequestWithUser, query: string, userId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            color: string;
            count: number;
        }[];
        meta: any;
    }>;
}
export {};
