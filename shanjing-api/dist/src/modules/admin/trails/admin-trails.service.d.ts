import { PrismaService } from '../../../database/prisma.service';
import { CreateTrailDto, UpdateTrailDto, TrailListQueryDto } from './dto/trail-admin.dto';
export declare class AdminTrailsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    createTrail(dto: CreateTrailDto, adminId: string): Promise<{
        success: boolean;
        data: {
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
    updateTrail(trailId: string, dto: UpdateTrailDto): Promise<{
        success: boolean;
        data: {
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
    deleteTrail(trailId: string): Promise<{
        success: boolean;
        data: {
            message: string;
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
    getTrailList(query: TrailListQueryDto): Promise<{
        success: boolean;
        data: {
            favoriteCount: number;
            name: string;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            id: string;
            createdAt: Date;
            _count: {
                favorites: number;
            };
            distanceKm: number;
            durationMin: number;
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
    batchUpdateStatus(trailIds: string[], isActive: boolean): Promise<{
        success: boolean;
        data: {
            message: string;
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
}
