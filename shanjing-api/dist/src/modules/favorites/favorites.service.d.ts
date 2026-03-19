import { PrismaService } from '../../database/prisma.service';
import { FavoriteListQueryDto } from './dto/favorite.dto';
export declare class FavoritesService {
    private readonly prisma;
    constructor(prisma: PrismaService);
    addFavorite(userId: string, trailId: string): Promise<{
        success: boolean;
        isFavorited: boolean;
        favoriteCount: number;
        message: string;
    }>;
    removeFavorite(userId: string, trailId: string): Promise<{
        success: boolean;
        isFavorited: boolean;
        favoriteCount: number;
        message: string;
    }>;
    toggleFavorite(userId: string, trailId: string): Promise<{
        success: boolean;
        isFavorited: boolean;
        favoriteCount: number;
        message: string;
    }>;
    getUserFavorites(userId: string, query: FavoriteListQueryDto): Promise<{
        success: boolean;
        data: {
            id: string;
            trailId: string;
            trailName: string;
            coverImage: string;
            distanceKm: number;
            durationMin: number;
            difficulty: import(".prisma/client").$Enums.TrailDifficulty;
            city: string;
            createdAt: Date;
        }[];
        meta: {
            page: number;
            limit: number;
            total: number;
            totalPages: number;
        };
    }>;
    checkFavoriteStatus(userId: string, trailId: string): Promise<{
        success: boolean;
        isFavorited: boolean;
        favoriteCount: number;
    }>;
    getUserFavoriteTrailIds(userId: string): Promise<string>[];
}
