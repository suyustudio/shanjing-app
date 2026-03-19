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
exports.AdminTrailsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../../database/prisma.service");
let AdminTrailsService = class AdminTrailsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createTrail(dto, adminId) {
        if (dto.startPointLat < -90 || dto.startPointLat > 90) {
            throw new common_1.BadRequestException({
                success: false,
                error: { code: 'INVALID_LATITUDE', message: '纬度范围应为 -90 到 90' },
            });
        }
        if (dto.startPointLng < -180 || dto.startPointLng > 180) {
            throw new common_1.BadRequestException({
                success: false,
                error: { code: 'INVALID_LONGITUDE', message: '经度范围应为 -180 到 180' },
            });
        }
        const trail = await this.prisma.trail.create({
            data: {
                name: dto.name,
                description: dto.description || null,
                distanceKm: dto.distanceKm,
                durationMin: dto.durationMin,
                elevationGainM: dto.elevationGainM,
                difficulty: dto.difficulty,
                tags: dto.tags || [],
                coverImages: dto.coverImages || [],
                gpxUrl: dto.gpxUrl || null,
                city: dto.city,
                district: dto.district,
                startPointLat: dto.startPointLat,
                startPointLng: dto.startPointLng,
                startPointAddress: dto.startPointAddress || null,
                safetyInfo: dto.safetyInfo || {},
                boundsNorth: dto.startPointLat + 0.01,
                boundsSouth: dto.startPointLat - 0.01,
                boundsEast: dto.startPointLng + 0.01,
                boundsWest: dto.startPointLng - 0.01,
                isActive: true,
                createdBy: adminId,
            },
        });
        return {
            success: true,
            data: trail,
        };
    }
    async updateTrail(trailId, dto) {
        const existingTrail = await this.prisma.trail.findUnique({
            where: { id: trailId },
        });
        if (!existingTrail) {
            throw new common_1.NotFoundException({
                success: false,
                error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在' },
            });
        }
        if (dto.startPointLat !== undefined && (dto.startPointLat < -90 || dto.startPointLat > 90)) {
            throw new common_1.BadRequestException({
                success: false,
                error: { code: 'INVALID_LATITUDE', message: '纬度范围应为 -90 到 90' },
            });
        }
        if (dto.startPointLng !== undefined && (dto.startPointLng < -180 || dto.startPointLng > 180)) {
            throw new common_1.BadRequestException({
                success: false,
                error: { code: 'INVALID_LONGITUDE', message: '经度范围应为 -180 到 180' },
            });
        }
        const updateData = {};
        if (dto.name !== undefined)
            updateData.name = dto.name;
        if (dto.description !== undefined)
            updateData.description = dto.description;
        if (dto.distanceKm !== undefined)
            updateData.distanceKm = dto.distanceKm;
        if (dto.durationMin !== undefined)
            updateData.durationMin = dto.durationMin;
        if (dto.elevationGainM !== undefined)
            updateData.elevationGainM = dto.elevationGainM;
        if (dto.difficulty !== undefined)
            updateData.difficulty = dto.difficulty;
        if (dto.tags !== undefined)
            updateData.tags = dto.tags;
        if (dto.coverImages !== undefined)
            updateData.coverImages = dto.coverImages;
        if (dto.gpxUrl !== undefined)
            updateData.gpxUrl = dto.gpxUrl;
        if (dto.city !== undefined)
            updateData.city = dto.city;
        if (dto.district !== undefined)
            updateData.district = dto.district;
        if (dto.startPointLat !== undefined)
            updateData.startPointLat = dto.startPointLat;
        if (dto.startPointLng !== undefined)
            updateData.startPointLng = dto.startPointLng;
        if (dto.startPointAddress !== undefined)
            updateData.startPointAddress = dto.startPointAddress;
        if (dto.safetyInfo !== undefined)
            updateData.safetyInfo = dto.safetyInfo;
        if (dto.isActive !== undefined)
            updateData.isActive = dto.isActive;
        const trail = await this.prisma.trail.update({
            where: { id: trailId },
            data: updateData,
        });
        return {
            success: true,
            data: trail,
        };
    }
    async deleteTrail(trailId) {
        const existingTrail = await this.prisma.trail.findUnique({
            where: { id: trailId },
        });
        if (!existingTrail) {
            throw new common_1.NotFoundException({
                success: false,
                error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在' },
            });
        }
        await this.prisma.trail.update({
            where: { id: trailId },
            data: { isActive: false },
        });
        return {
            success: true,
            data: { message: '路线已删除' },
        };
    }
    async getTrailById(trailId) {
        const trail = await this.prisma.trail.findUnique({
            where: { id: trailId },
            include: {
                pois: true,
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
                error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在' },
            });
        }
        return {
            success: true,
            data: {
                ...trail,
                favoriteCount: trail._count.favorites,
            },
        };
    }
    async getTrailList(query) {
        const { keyword, city, difficulty, isActive, page = 1, limit = 20, } = query;
        const skip = (page - 1) * limit;
        const where = {
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
        if (difficulty) {
            where.difficulty = difficulty;
        }
        if (isActive !== undefined) {
            where.isActive = isActive;
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
                    isActive: true,
                    createdAt: true,
                    _count: {
                        select: {
                            favorites: true,
                        },
                    },
                },
            }),
            this.prisma.trail.count({ where }),
        ]);
        return {
            success: true,
            data: trails.map((trail) => ({
                ...trail,
                favoriteCount: trail._count.favorites,
            })),
            meta: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    async batchUpdateStatus(trailIds, isActive) {
        await this.prisma.trail.updateMany({
            where: {
                id: {
                    in: trailIds,
                },
            },
            data: {
                isActive,
            },
        });
        return {
            success: true,
            data: {
                message: `已${isActive ? '上架' : '下架'} ${trailIds.length} 条路线`,
            },
        };
    }
    async getTrailStats() {
        const [totalTrails, activeTrails, totalFavorites, difficultyStats,] = await Promise.all([
            this.prisma.trail.count(),
            this.prisma.trail.count({ where: { isActive: true } }),
            this.prisma.favorite.count(),
            this.prisma.trail.groupBy({
                by: ['difficulty'],
                _count: {
                    id: true,
                },
            }),
        ]);
        return {
            success: true,
            data: {
                totalTrails,
                activeTrails,
                inactiveTrails: totalTrails - activeTrails,
                totalFavorites,
                difficultyDistribution: difficultyStats.map((stat) => ({
                    difficulty: stat.difficulty,
                    count: stat._count.id,
                })),
            },
        };
    }
};
exports.AdminTrailsService = AdminTrailsService;
exports.AdminTrailsService = AdminTrailsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], AdminTrailsService);
//# sourceMappingURL=admin-trails.service.js.map