"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FavoritesService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
let FavoritesService = class FavoritesService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async addFavorite(userId, trailId) {
        const trail = await this.prisma.trail.findUnique({
            where: {
                id: trailId,
                isActive: true,
                deletedAt: null,
            },
        });
        if (!trail) {
            throw new common_1.NotFoundException({
                success: false,
                error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在或已下架' },
            });
        }
        const existingFavorite = await this.prisma.favorite.findUnique({
            where: {
                userId_trailId: {
                    userId,
                    trailId,
                },
            },
        });
        if (existingFavorite) {
            throw new common_1.ConflictException({
                success: false,
                error: { code: 'ALREADY_FAVORITED', message: '已经收藏过该路线' },
            });
        }
        await this.prisma.favorite.create({
            data: {
                userId,
                trailId,
            },
        });
        const favoriteCount = await this.prisma.favorite.count({
            where: { trailId },
        });
        return {
            success: true,
            isFavorited: true,
            favoriteCount,
            message: '收藏成功',
        };
    }
    async removeFavorite(userId, trailId) {
        const favorite = await this.prisma.favorite.findUnique({
            where: {
                userId_trailId: {
                    userId,
                    trailId,
                },
            },
        });
        if (!favorite) {
            throw new common_1.NotFoundException({
                success: false,
                error: { code: 'FAVORITE_NOT_FOUND', message: '未找到收藏记录' },
            });
        }
        await this.prisma.favorite.delete({
            where: {
                userId_trailId: {
                    userId,
                    trailId,
                },
            },
        });
        const favoriteCount = await this.prisma.favorite.count({
            where: { trailId },
        });
        return {
            success: true,
            isFavorited: false,
            favoriteCount,
            message: '取消收藏成功',
        };
    }
    async toggleFavorite(userId, trailId) {
        const favorite = await this.prisma.favorite.findUnique({
            where: {
                userId_trailId: {
                    userId,
                    trailId,
                },
            },
        });
        if (favorite) {
            return this.removeFavorite(userId, trailId);
        }
        else {
            return this.addFavorite(userId, trailId);
        }
    }
    async getUserFavorites(userId, query) {
        const { page = 1, limit = 20 } = query;
        const skip = (page - 1) * limit;
        const [favorites, total] = await Promise.all([
            this.prisma.favorite.findMany({
                where: { userId },
                skip,
                take: limit,
                orderBy: { createdAt: 'desc' },
                include: {
                    trail: {
                        select: {
                            id: true,
                            name: true,
                            coverImages: true,
                            distanceKm: true,
                            durationMin: true,
                            difficulty: true,
                            city: true,
                        },
                    },
                },
            }),
            this.prisma.favorite.count({
                where: { userId },
            }),
        ]);
        return {
            success: true,
            data: favorites.map((fav) => ({
                id: fav.id,
                trailId: fav.trail.id,
                trailName: fav.trail.name,
                coverImage: fav.trail.coverImages[0] || '',
                distanceKm: fav.trail.distanceKm,
                durationMin: fav.trail.durationMin,
                difficulty: fav.trail.difficulty,
                city: fav.trail.city,
                createdAt: fav.createdAt,
            })),
            meta: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    async checkFavoriteStatus(userId, trailId) {
        const favorite = await this.prisma.favorite.findUnique({
            where: {
                userId_trailId: {
                    userId,
                    trailId,
                },
            },
        });
        const favoriteCount = await this.prisma.favorite.count({
            where: { trailId },
        });
        return {
            success: true,
            isFavorited: !!favorite,
            favoriteCount,
        };
    }
    async getUserFavoriteTrailIds(userId) {
        const favorites = await this.prisma.favorite.findMany({
            where: { userId },
            select: { trailId: true },
        });
        return favorites.map((f) => f.trailId);
    }
};
exports.FavoritesService = FavoritesService;
exports.FavoritesService = FavoritesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], FavoritesService);
//# sourceMappingURL=favorites.service.js.map