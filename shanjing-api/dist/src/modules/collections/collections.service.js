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
exports.CollectionsService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
let CollectionsService = class CollectionsService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createCollection(userId, dto) {
        const collection = await this.prisma.collection.create({
            data: {
                userId,
                name: dto.name,
                description: dto.description || null,
                coverUrl: dto.coverUrl || null,
                isPublic: dto.isPublic ?? true,
            },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
            },
        });
        return this.mapToCollectionDto(collection);
    }
    async getCollections(query, currentUserId) {
        const targetUserId = query.userId || currentUserId;
        if (!targetUserId) {
            throw new common_1.ForbiddenException('需要指定用户ID或登录');
        }
        const where = { userId: targetUserId };
        if (targetUserId !== currentUserId) {
            where.isPublic = true;
        }
        const [collections, total] = await Promise.all([
            this.prisma.collection.findMany({
                where,
                orderBy: [{ sortOrder: 'asc' }, { createdAt: 'desc' }],
                skip: (query.page - 1) * query.limit,
                take: query.limit,
                include: {
                    user: {
                        select: {
                            id: true,
                            nickname: true,
                            avatarUrl: true,
                        },
                    },
                },
            }),
            this.prisma.collection.count({ where }),
        ]);
        return {
            list: collections.map(c => this.mapToCollectionDto(c)),
            total,
            page: query.page,
            limit: query.limit,
        };
    }
    async getCollectionDetail(collectionId, currentUserId) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                trails: {
                    orderBy: { sortOrder: 'asc' },
                    include: {
                        trail: {
                            select: {
                                id: true,
                                name: true,
                                coverImages: true,
                                distanceKm: true,
                                durationMin: true,
                                difficulty: true,
                                avgRating: true,
                                reviewCount: true,
                                rating5Count: true,
                                rating4Count: true,
                                rating3Count: true,
                                rating2Count: true,
                                rating1Count: true,
                                isPublished: true,
                            },
                        },
                    },
                },
            },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (!collection.isPublic && collection.userId !== currentUserId) {
            throw new common_1.ForbiddenException('无权查看此收藏夹');
        }
        const publishedTrails = collection.trails
            .filter(t => t.trail.isPublished !== false)
            .map(t => ({
            ...t,
            trail: {
                ...t.trail,
                avgRating: t.trail.avgRating,
                reviewCount: t.trail.reviewCount,
                ratingDistribution: {
                    5: t.trail.rating5Count,
                    4: t.trail.rating4Count,
                    3: t.trail.rating3Count,
                    2: t.trail.rating2Count,
                    1: t.trail.rating1Count,
                },
            },
        }));
        return this.mapToCollectionDetailDto({
            ...collection,
            trails: publishedTrails,
        });
    }
    async updateCollection(userId, collectionId, dto) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (collection.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此收藏夹');
        }
        const updated = await this.prisma.collection.update({
            where: { id: collectionId },
            data: {
                name: dto.name,
                description: dto.description,
                coverUrl: dto.coverUrl,
                isPublic: dto.isPublic,
                sortOrder: dto.sortOrder,
            },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
            },
        });
        return this.mapToCollectionDto(updated);
    }
    async deleteCollection(userId, collectionId) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (collection.userId !== userId) {
            throw new common_1.ForbiddenException('无权删除此收藏夹');
        }
        await this.prisma.collection.delete({
            where: { id: collectionId },
        });
    }
    async addTrailToCollection(userId, collectionId, dto) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (collection.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此收藏夹');
        }
        const trail = await this.prisma.trail.findUnique({
            where: { id: dto.trailId },
        });
        if (!trail) {
            throw new common_1.NotFoundException('路线不存在');
        }
        const existing = await this.prisma.collectionTrail.findUnique({
            where: {
                collectionId_trailId: {
                    collectionId,
                    trailId: dto.trailId,
                },
            },
        });
        if (existing) {
            throw new common_1.ForbiddenException('该路线已在收藏夹中');
        }
        const maxSortOrder = await this.prisma.collectionTrail.findFirst({
            where: { collectionId },
            orderBy: { sortOrder: 'desc' },
            select: { sortOrder: true },
        });
        await this.prisma.collectionTrail.create({
            data: {
                collectionId,
                trailId: dto.trailId,
                note: dto.note || null,
                sortOrder: (maxSortOrder?.sortOrder || 0) + 1,
            },
        });
        await this.prisma.collection.update({
            where: { id: collectionId },
            data: { trailCount: { increment: 1 } },
        });
        return this.getCollectionDetail(collectionId, userId);
    }
    async removeTrailFromCollection(userId, collectionId, trailId) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (collection.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此收藏夹');
        }
        await this.prisma.collectionTrail.deleteMany({
            where: {
                collectionId,
                trailId,
            },
        });
        await this.prisma.collection.update({
            where: { id: collectionId },
            data: { trailCount: { decrement: 1 } },
        });
    }
    async batchAddTrails(userId, collectionId, dto) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (collection.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此收藏夹');
        }
        const maxSortOrder = await this.prisma.collectionTrail.findFirst({
            where: { collectionId },
            orderBy: { sortOrder: 'desc' },
            select: { sortOrder: true },
        });
        let currentSortOrder = (maxSortOrder?.sortOrder || 0) + 1;
        const existingTrails = await this.prisma.collectionTrail.findMany({
            where: {
                collectionId,
                trailId: { in: dto.trailIds },
            },
            select: { trailId: true },
        });
        const existingTrailIds = existingTrails.map(t => t.trailId);
        const newTrailIds = dto.trailIds.filter(id => !existingTrailIds.includes(id));
        if (newTrailIds.length > 0) {
            await this.prisma.collectionTrail.createMany({
                data: newTrailIds.map(trailId => ({
                    collectionId,
                    trailId,
                    sortOrder: currentSortOrder++,
                })),
            });
            await this.prisma.collection.update({
                where: { id: collectionId },
                data: { trailCount: { increment: newTrailIds.length } },
            });
        }
        return this.getCollectionDetail(collectionId, userId);
    }
    mapToCollectionDto(collection) {
        return {
            id: collection.id,
            name: collection.name,
            description: collection.description,
            coverUrl: collection.coverUrl,
            isPublic: collection.isPublic,
            sortOrder: collection.sortOrder,
            trailCount: collection.trailCount,
            createdAt: collection.createdAt,
            updatedAt: collection.updatedAt,
            user: {
                id: collection.user.id,
                nickname: collection.user.nickname,
                avatarUrl: collection.user.avatarUrl,
            },
        };
    }
    mapToCollectionDetailDto(collection) {
        return {
            ...this.mapToCollectionDto(collection),
            trails: collection.trails.map((t) => ({
                id: t.id,
                trailId: t.trailId,
                trail: t.trail,
                note: t.note,
                createdAt: t.createdAt,
            })),
        };
    }
};
exports.CollectionsService = CollectionsService;
exports.CollectionsService = CollectionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], CollectionsService);
//# sourceMappingURL=collections.service.js.map