import { TrailsService } from './trails.service';
import { TrailListQueryDto, NearbyTrailsQueryDto } from './dto/trail.dto';
export declare class TrailsController {
    private readonly trailsService;
    constructor(trailsService: TrailsService);
    getTrailList(query: TrailListQueryDto, userId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            distanceKm: number;
            durationMin: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            city: string;
            district: string;
            coverImages: string[];
            favoriteCount: number;
            isFavorited: boolean;
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
    }>;
    getRecommendedTrails(limit?: number, userId?: string): Promise<{
        success: boolean;
        data: {
            id: string;
            name: string;
            distanceKm: number;
            durationMin: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            city: string;
            district: string;
            coverImages: string[];
            favoriteCount: number;
            isFavorited: boolean;
        }[];
    }>;
    getNearbyTrails(query: NearbyTrailsQueryDto, userId?: string): Promise<{
        success: boolean;
        data: {
            distanceFromUser: number;
            favoriteCount: number;
            isFavorited: boolean;
            name: string;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            id: string;
            _count: {
                favorites: number;
            };
            distanceKm: number;
            durationMin: number;
            coverImages: string[];
            city: string;
            district: string;
            startPointLat: number;
            startPointLng: number;
        }[];
    }>;
    getTrailById(trailId: string, userId?: string): Promise<{
        success: boolean;
        data: {
            favoriteCount: number;
            isFavorited: boolean;
            _count: {
                favorites: number;
            };
            pois: {
                name: string;
                type: string;
                description: string | null;
                trailId: string;
                id: string;
                createdAt: Date;
                order: number;
                lat: number;
                lng: number;
            }[];
            name: string;
            description: string | null;
            tags: string[];
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            id: string;
            createdAt: Date;
            updatedAt: Date;
            distanceKm: number;
            durationMin: number;
            elevationGainM: number;
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
            isPublished: boolean;
            avgRating: number | null;
            reviewCount: number;
            rating5Count: number;
            rating4Count: number;
            rating3Count: number;
            rating2Count: number;
            rating1Count: number;
            createdBy: string;
            deletedAt: Date | null;
        };
    }>;
}
