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
                tags: dto.tags || [],
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
                tags: dto.tags,
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
    async batchRemoveTrails(userId, collectionId, dto) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (collection.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此收藏夹');
        }
        const deleteResult = await this.prisma.collectionTrail.deleteMany({
            where: {
                collectionId,
                trailId: { in: dto.trailIds },
            },
        });
        if (deleteResult.count > 0) {
            await this.prisma.collection.update({
                where: { id: collectionId },
                data: { trailCount: { decrement: deleteResult.count } },
            });
        }
    }
    async batchMoveTrails(userId, collectionId, dto) {
        const sourceCollection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!sourceCollection) {
            throw new common_1.NotFoundException('源收藏夹不存在');
        }
        if (sourceCollection.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此收藏夹');
        }
        const targetCollection = await this.prisma.collection.findUnique({
            where: { id: dto.targetCollectionId },
        });
        if (!targetCollection) {
            throw new common_1.NotFoundException('目标收藏夹不存在');
        }
        if (targetCollection.userId !== userId) {
            throw new common_1.ForbiddenException('无权操作目标收藏夹');
        }
        const maxSortOrder = await this.prisma.collectionTrail.findFirst({
            where: { collectionId: dto.targetCollectionId },
            orderBy: { sortOrder: 'desc' },
            select: { sortOrder: true },
        });
        let currentSortOrder = (maxSortOrder?.sortOrder || 0) + 1;
        const sourceTrails = await this.prisma.collectionTrail.findMany({
            where: {
                collectionId,
                trailId: { in: dto.trailIds },
            },
        });
        if (sourceTrails.length === 0) {
            return this.getCollectionDetail(dto.targetCollectionId, userId);
        }
        const trailIdsToMove = sourceTrails.map(st => st.trailId);
        const existingInTarget = await this.prisma.collectionTrail.findMany({
            where: {
                collectionId: dto.targetCollectionId,
                trailId: { in: trailIdsToMove },
            },
            select: { trailId: true },
        });
        const existingTrailIds = existingInTarget.map(et => et.trailId);
        const newTrailIds = trailIdsToMove.filter(id => !existingTrailIds.includes(id));
        await this.prisma.$transaction(async (tx) => {
            await tx.collectionTrail.deleteMany({
                where: {
                    collectionId,
                    trailId: { in: trailIdsToMove },
                },
            });
            if (newTrailIds.length > 0) {
                await tx.collectionTrail.createMany({
                    data: newTrailIds.map(trailId => ({
                        collectionId: dto.targetCollectionId,
                        trailId,
                        sortOrder: currentSortOrder++,
                    })),
                });
            }
            await tx.collection.update({
                where: { id: collectionId },
                data: { trailCount: { decrement: sourceTrails.length } },
            });
            if (newTrailIds.length > 0) {
                await tx.collection.update({
                    where: { id: dto.targetCollectionId },
                    data: { trailCount: { increment: newTrailIds.length } },
                });
            }
        });
        return this.getCollectionDetail(collectionId, userId);
    }
    async searchCollectionTrails(userId, collectionId, dto) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (!collection.isPublic && collection.userId !== userId) {
            throw new common_1.ForbiddenException('无权查看此收藏夹');
        }
        const where = {
            collectionId,
        };
        if (dto.q) {
            where.trail = {
                OR: [
                    { name: { contains: dto.q, mode: 'insensitive' } },
                    { description: { contains: dto.q, mode: 'insensitive' } },
                    { tags: { has: dto.q } },
                ],
            };
        }
        if (dto.difficulty) {
            where.trail = {
                ...where.trail,
                difficulty: dto.difficulty,
            };
        }
        if (dto.minDistance !== undefined || dto.maxDistance !== undefined) {
            where.trail = {
                ...where.trail,
                distanceKm: {
                    ...(dto.minDistance !== undefined && { gte: dto.minDistance }),
                    ...(dto.maxDistance !== undefined && { lte: dto.maxDistance }),
                },
            };
        }
        if (dto.minRating !== undefined) {
            where.trail = {
                ...where.trail,
                avgRating: { gte: dto.minRating },
            };
        }
        if (dto.tags && dto.tags.length > 0) {
            where.trail = {
                ...where.trail,
                tags: { hasEvery: dto.tags },
            };
        }
        const trails = await this.prisma.collectionTrail.findMany({
            where,
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
            skip: (dto.page - 1) * dto.limit,
            take: dto.limit,
        });
        const publishedTrails = trails.filter(t => t.trail.isPublished !== false);
        const collectionDetail = {
            ...collection,
            trails: publishedTrails,
            user: await this.prisma.user.findUnique({
                where: { id: collection.userId },
                select: { id: true, nickname: true, avatarUrl: true },
            }),
        };
        return this.mapToCollectionDetailDto(collectionDetail);
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
    generateTagColor(tagName) {
        let hash = 0;
        for (let i = 0; i < tagName.length; i++) {
            hash = ((hash << 5) - hash) + tagName.charCodeAt(i);
            hash |= 0;
        }
        hash = Math.abs(hash);
        const hue = hash % 360;
        const saturation = 60 + (hash % 20);
        const lightness = 50 + (hash % 10);
        const h = hue / 360;
        const s = saturation / 100;
        const l = lightness / 100;
        const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
        const p = 2 * l - q;
        const r = Math.round(this.hueToRgb(p, q, h + 1 / 3) * 255);
        const g = Math.round(this.hueToRgb(p, q, h) * 255);
        const b = Math.round(this.hueToRgb(p, q, h - 1 / 3) * 255);
        return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1).toUpperCase()}`;
    }
    hueToRgb(p, q, t) {
        if (t < 0)
            t += 1;
        if (t > 1)
            t -= 1;
        if (t < 1 / 6)
            return p + (q - p) * 6 * t;
        if (t < 1 / 2)
            return q;
        if (t < 2 / 3)
            return p + (q - p) * (2 / 3 - t) * 6;
        return p;
    }
    generateTagId(tagName) {
        let hash = 0;
        for (let i = 0; i < tagName.length; i++) {
            hash = ((hash << 5) - hash) + tagName.charCodeAt(i);
            hash |= 0;
        }
        return Math.abs(hash).toString();
    }
    async getAllTags(userId) {
        const where = {};
        if (userId) {
            where.userId = userId;
        }
        const collections = await this.prisma.collection.findMany({
            where,
            select: { tags: true },
        });
        const tagCounts = new Map();
        collections.forEach(collection => {
            collection.tags.forEach(tag => {
                tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
            });
        });
        return Array.from(tagCounts.entries())
            .map(([name, count]) => ({
            id: this.generateTagId(name),
            name,
            color: this.generateTagColor(name),
            count,
        }))
            .sort((a, b) => b.count - a.count);
    }
    async createTag(userId, tagName, color) {
        if (!tagName || tagName.trim().length === 0) {
            throw new Error('标签名不能为空');
        }
        if (tagName.length > 20) {
            throw new Error('标签名不能超过20个字符');
        }
        const userCollections = await this.prisma.collection.findMany({
            where: { userId },
            select: { tags: true },
        });
        const existingTags = new Set();
        userCollections.forEach(collection => {
            collection.tags.forEach(tag => existingTags.add(tag));
        });
        if (existingTags.has(tagName)) {
            const allTags = await this.getAllTags(userId);
            const existingTag = allTags.find(t => t.name === tagName);
            return existingTag || {
                id: this.generateTagId(tagName),
                name: tagName,
                color: color || this.generateTagColor(tagName),
                count: 0,
            };
        }
        return {
            id: this.generateTagId(tagName),
            name: tagName,
            color: color || this.generateTagColor(tagName),
            count: 0,
        };
    }
    async deleteTag(userId, tagName) {
        const collections = await this.prisma.collection.findMany({
            where: {
                userId,
                tags: { has: tagName },
            },
        });
        for (const collection of collections) {
            const updatedTags = collection.tags.filter(t => t !== tagName);
            await this.prisma.collection.update({
                where: { id: collection.id },
                data: { tags: updatedTags },
            });
        }
    }
    async getCollectionTags(collectionId, userId) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
            select: { tags: true, userId: true },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (collection.userId !== userId) {
            const publicCollection = await this.prisma.collection.findFirst({
                where: { id: collectionId, isPublic: true },
            });
            if (!publicCollection) {
                throw new common_1.ForbiddenException('无权访问此收藏夹');
            }
        }
        return collection.tags;
    }
    async updateCollectionTags(userId, collectionId, tags) {
        const collection = await this.prisma.collection.findUnique({
            where: { id: collectionId },
        });
        if (!collection) {
            throw new common_1.NotFoundException('收藏夹不存在');
        }
        if (collection.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此收藏夹');
        }
        const validatedTags = tags
            .map(tag => tag.trim())
            .filter(tag => tag.length > 0 && tag.length <= 20)
            .slice(0, 10);
        const updatedCollection = await this.prisma.collection.update({
            where: { id: collectionId },
            data: { tags: validatedTags },
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
        return this.mapToCollectionDto(updatedCollection);
    }
    async searchTags(query, userId) {
        const allTags = await this.getAllTags(userId);
        const lowerQuery = query.toLowerCase();
        return allTags.filter(tag => tag.name.toLowerCase().includes(lowerQuery));
    }
};
exports.CollectionsService = CollectionsService;
exports.CollectionsService = CollectionsService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], CollectionsService);
//# sourceMappingURL=collections.service.js.map