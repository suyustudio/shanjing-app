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
exports.TrailsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
let TrailsService = class TrailsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async getTrailList(query, userId) {
        const { keyword, city, district, difficulty, tag, page = 1, limit = 20, } = query;
        const skip = (page - 1) * limit;
        const where = {
            isActive: true,
            deletedAt: null,
        };
        if (keyword) {
            where.name = {
                contains: keyword,
                mode: 'insensitive',
            };
        }
        if (city) {
            where.city = city;
        }
        if (district) {
            where.district = district;
        }
        if (difficulty) {
            where.difficulty = difficulty;
        }
        if (tag) {
            where.tags = {
                has: tag,
            };
        }
        const [trails, total] = await Promise.all([
            this.prisma.trail.findMany({
                where,
                skip,
                take: limit,
                orderBy: { createdAt: 'desc' },
                select: {
                    id: true,
                    name: true,
                    distanceKm: true,
                    durationMin: true,
                    difficulty: true,
                    city: true,
                    district: true,
                    coverImages: true,
                    _count: {
                        select: {
                            favorites: true,
                        },
                    },
                },
            }),
            this.prisma.trail.count({ where }),
        ]);
        let favoritedTrailIds = new Set();
        if (userId) {
            const favorites = await this.prisma.favorite.findMany({
                where: {
                    userId,
                    trailId: {
                        in: trails.map((t) => t.id),
                    },
                },
                select: { trailId: true },
            });
            favoritedTrailIds = new Set(favorites.map((f) => f.trailId));
        }
        return {
            success: true,
            data: trails.map((trail) => ({
                id: trail.id,
                name: trail.name,
                distanceKm: trail.distanceKm,
                durationMin: trail.durationMin,
                difficulty: trail.difficulty,
                city: trail.city,
                district: trail.district,
                coverImages: trail.coverImages,
                favoriteCount: trail._count.favorites,
                isFavorited: favoritedTrailIds.has(trail.id),
            })),
            meta: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    async getTrailById(trailId, userId) {
        const trail = await this.prisma.trail.findUnique({
            where: {
                id: trailId,
                isActive: true,
                deletedAt: null,
            },
            include: {
                pois: {
                    orderBy: { order: 'asc' },
                },
                _count: {
                    select: {
                        favorites: true,
                    },
                },
            },
        });
        if (!trail) {
            throw new common_1.NotFoundException({
                success: false,
                error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在或已下架' },
            });
        }
        let isFavorited = false;
        if (userId) {
            const favorite = await this.prisma.favorite.findUnique({
                where: {
                    userId_trailId: {
                        userId,
                        trailId,
                    },
                },
            });
            isFavorited = !!favorite;
        }
        return {
            success: true,
            data: {
                ...trail,
                favoriteCount: trail._count.favorites,
                isFavorited,
            },
        };
    }
    async getNearbyTrails(query, userId) {
        const { lat, lng, radius = 10, limit = 20 } = query;
        const latDelta = radius / 111;
        const lngDelta = radius / (111 * Math.cos(lat * Math.PI / 180));
        const trails = await this.prisma.trail.findMany({
            where: {
                isActive: true,
                deletedAt: null,
                startPointLat: {
                    gte: lat - latDelta,
                    lte: lat + latDelta,
                },
                startPointLng: {
                    gte: lng - lngDelta,
                    lte: lng + lngDelta,
                },
            },
            take: limit,
            select: {
                id: true,
                name: true,
                distanceKm: true,
                durationMin: true,
                difficulty: true,
                city: true,
                district: true,
                coverImages: true,
                startPointLat: true,
                startPointLng: true,
                _count: {
                    select: {
                        favorites: true,
                    },
                },
            },
        });
        let favoritedTrailIds = new Set();
        if (userId) {
            const favorites = await this.prisma.favorite.findMany({
                where: {
                    userId,
                    trailId: {
                        in: trails.map((t) => t.id),
                    },
                },
                select: { trailId: true },
            });
            favoritedTrailIds = new Set(favorites.map((f) => f.trailId));
        }
        const trailsWithDistance = trails.map((trail) => {
            const distance = this.calculateDistance(lat, lng, trail.startPointLat, trail.startPointLng);
            return {
                ...trail,
                distanceFromUser: distance,
                favoriteCount: trail._count.favorites,
                isFavorited: favoritedTrailIds.has(trail.id),
            };
        });
        const filteredTrails = trailsWithDistance
            .filter((t) => t.distanceFromUser <= radius)
            .sort((a, b) => a.distanceFromUser - b.distanceFromUser);
        return {
            success: true,
            data: filteredTrails.slice(0, limit),
        };
    }
    async getRecommendedTrails(limit = 10, userId) {
        const trails = await this.prisma.trail.findMany({
            where: {
                isActive: true,
                deletedAt: null,
            },
            take: limit,
            orderBy: [
                { favorites: { _count: 'desc' } },
                { createdAt: 'desc' },
            ],
            select: {
                id: true,
                name: true,
                distanceKm: true,
                durationMin: true,
                difficulty: true,
                city: true,
                district: true,
                coverImages: true,
                _count: {
                    select: {
                        favorites: true,
                    },
                },
            },
        });
        let favoritedTrailIds = new Set();
        if (userId) {
            const favorites = await this.prisma.favorite.findMany({
                where: {
                    userId,
                    trailId: {
                        in: trails.map((t) => t.id),
                    },
                },
                select: { trailId: true },
            });
            favoritedTrailIds = new Set(favorites.map((f) => f.trailId));
        }
        return {
            success: true,
            data: trails.map((trail) => ({
                id: trail.id,
                name: trail.name,
                distanceKm: trail.distanceKm,
                durationMin: trail.durationMin,
                difficulty: trail.difficulty,
                city: trail.city,
                district: trail.district,
                coverImages: trail.coverImages,
                favoriteCount: trail._count.favorites,
                isFavorited: favoritedTrailIds.has(trail.id),
            })),
        };
    }
    calculateDistance(lat1, lng1, lat2, lng2) {
        const R = 6371;
        const dLat = this.toRadians(lat2 - lat1);
        const dLng = this.toRadians(lng2 - lng1);
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.toRadians(lat1)) *
                Math.cos(this.toRadians(lat2)) *
                Math.sin(dLng / 2) *
                Math.sin(dLng / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
    toRadians(degrees) {
        return degrees * (Math.PI / 180);
    }
};
exports.TrailsService = TrailsService;
exports.TrailsService = TrailsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], TrailsService);
//# sourceMappingURL=trails.service.js.map