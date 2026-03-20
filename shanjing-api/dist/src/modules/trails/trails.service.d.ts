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
    getNearbyTrails(query: NearbyTrailsQueryDto, userId?: string): Promise<{
        success: boolean;
        data: {
            distanceFromUser: number;
            favoriteCount: number;
            isFavorited: boolean;
            id: string;
            name: string;
            _count: {
                favorites: number;
            };
            distanceKm: number;
            durationMin: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            coverImages: string[];
            city: string;
            district: string;
            startPointLat: number;
            startPointLng: number;
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
