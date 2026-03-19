import { PrismaService } from '../../database/prisma.service';
import { TrailListQueryDto, NearbyTrailsQueryDto } from './dto/trail.dto';
export declare class TrailsService {
    private readonly prisma;
    constructor(prisma: PrismaService);
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
    getTrailById(trailId: string, userId?: string): Promise<{
        success: boolean;
        data: {
            favoriteCount: number;
            isFavorited: boolean;
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
    getNearbyTrails(query: NearbyTrailsQueryDto, userId?: string): Promise<{
        success: boolean;
        data: {
            distanceFromUser: number;
            favoriteCount: number;
            isFavorited: boolean;
            name: string;
            id: string;
            distanceKm: number;
            durationMin: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            coverImages: string[];
            city: string;
            district: string;
            startPointLat: number;
            startPointLng: number;
            _count: {
                favorites: number;
            };
        }[];
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
    private calculateDistance;
    private toRadians;
}
