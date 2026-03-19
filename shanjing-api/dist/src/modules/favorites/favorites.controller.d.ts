import { FavoritesService } from './favorites.service';
import { FavoriteListQueryDto, AddFavoriteDto } from './dto/favorite.dto';
export declare class FavoritesController {
    private readonly favoritesService;
    constructor(favoritesService: FavoritesService);
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
    addFavorite(userId: string, dto: AddFavoriteDto): Promise<{
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
    toggleFavorite(userId: string, dto: AddFavoriteDto): Promise<{
        success: boolean;
        isFavorited: boolean;
        favoriteCount: number;
        message: string;
    }>;
    checkFavoriteStatus(userId: string, trailId: string): Promise<{
        success: boolean;
        isFavorited: boolean;
        favoriteCount: number;
    }>;
}
