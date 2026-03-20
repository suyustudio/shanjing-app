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
            id: string;
            name: string;
            createdAt: Date;
            _count: {
                favorites: number;
            };
            distanceKm: number;
            durationMin: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            city: string;
            district: string;
            isActive: boolean;
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
            _count: {
                favorites: number;
            };
            pois: {
                id: string;
                name: string;
                description: string | null;
                createdAt: Date;
                type: string;
                trailId: string;
                lat: number;
                lng: number;
                order: number;
            }[];
            tags: string[];
            id: string;
            name: string;
            description: string | null;
            createdAt: Date;
            updatedAt: Date;
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
            avgRating: number | null;
            reviewCount: number;
            createdBy: string;
            deletedAt: Date | null;
        };
    }>;
    createTrail(dto: CreateTrailDto, admin: AdminInfo): Promise<{
        success: boolean;
        data: {
            tags: string[];
            id: string;
            name: string;
            description: string | null;
            createdAt: Date;
            updatedAt: Date;
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
            avgRating: number | null;
            reviewCount: number;
            createdBy: string;
            deletedAt: Date | null;
        };
    }>;
    updateTrail(trailId: string, dto: UpdateTrailDto): Promise<{
        success: boolean;
        data: {
            tags: string[];
            id: string;
            name: string;
            description: string | null;
            createdAt: Date;
            updatedAt: Date;
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
            avgRating: number | null;
            reviewCount: number;
            createdBy: string;
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
