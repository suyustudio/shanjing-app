import { AdminTrailsService } from './admin-trails.service';
import { AdminInfo } from '../decorators/current-admin.decorator';
import { CreateTrailDto, UpdateTrailDto, TrailListQueryDto } from './dto/trail-admin.dto';
export declare class AdminTrailsController {
    private readonly adminTrailsService;
    constructor(adminTrailsService: AdminTrailsService);
    getTrailList(query: TrailListQueryDto): Promise<{
        success: boolean;
        data: {
            favoriteCount: number;
            name: string;
            id: string;
            distanceKm: number;
            durationMin: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            city: string;
            district: string;
            isActive: boolean;
            createdAt: Date;
            _count: {
                favorites: number;
            };
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
    }>;
    getTrailStats(): Promise<{
        success: boolean;
        data: {
            totalTrails: number;
            activeTrails: number;
            inactiveTrails: number;
            totalFavorites: number;
            difficultyDistribution: {
                difficulty: import(".prisma/client").$Enums.TrailDifficulty;
                count: number;
            }[];
        };
    }>;
    getTrailById(trailId: string): Promise<{
        success: boolean;
        data: {
            favoriteCount: number;
            pois: {
                name: string;
                type: string;
                description: string | null;
                lng: number;
                lat: number;
                id: string;
                createdAt: Date;
                order: number;
                trailId: string;
            }[];
            _count: {
                favorites: number;
            };
            name: string;
            description: string | null;
            tags: string[];
            id: string;
            distanceKm: number;
            durationMin: number;
            elevationGainM: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            coverImages: string[];
            gpxUrl: string | null;
            city: string;
            district: string;
            startPointLat: number;
            startPointLng: number;
            startPointAddress: string | null;
            safetyInfo: import("@prisma/client/runtime/library").JsonValue | null;
            boundsNorth: number | null;
            boundsSouth: number | null;
            boundsEast: number | null;
            boundsWest: number | null;
            isActive: boolean;
            createdBy: string;
            createdAt: Date;
            updatedAt: Date;
            deletedAt: Date | null;
        };
    }>;
    createTrail(dto: CreateTrailDto, admin: AdminInfo): Promise<{
        success: boolean;
        data: {
            name: string;
            description: string | null;
            tags: string[];
            id: string;
            distanceKm: number;
            durationMin: number;
            elevationGainM: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            coverImages: string[];
            gpxUrl: string | null;
            city: string;
            district: string;
            startPointLat: number;
            startPointLng: number;
            startPointAddress: string | null;
            safetyInfo: import("@prisma/client/runtime/library").JsonValue | null;
            boundsNorth: number | null;
            boundsSouth: number | null;
            boundsEast: number | null;
            boundsWest: number | null;
            isActive: boolean;
            createdBy: string;
            createdAt: Date;
            updatedAt: Date;
            deletedAt: Date | null;
        };
    }>;
    updateTrail(trailId: string, dto: UpdateTrailDto): Promise<{
        success: boolean;
        data: {
            name: string;
            description: string | null;
            tags: string[];
            id: string;
            distanceKm: number;
            durationMin: number;
            elevationGainM: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            coverImages: string[];
            gpxUrl: string | null;
            city: string;
            district: string;
            startPointLat: number;
            startPointLng: number;
            startPointAddress: string | null;
            safetyInfo: import("@prisma/client/runtime/library").JsonValue | null;
            boundsNorth: number | null;
            boundsSouth: number | null;
            boundsEast: number | null;
            boundsWest: number | null;
            isActive: boolean;
            createdBy: string;
            createdAt: Date;
            updatedAt: Date;
            deletedAt: Date | null;
        };
    }>;
    deleteTrail(trailId: string): Promise<{
        success: boolean;
        data: {
            message: string;
        };
    }>;
    batchUpdateStatus(trailIds: string[], isActive: boolean): Promise<{
        success: boolean;
        data: {
            message: string;
        };
    }>;
}
