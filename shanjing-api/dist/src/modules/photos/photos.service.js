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
exports.PhotosService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
let PhotosService = class PhotosService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async createPhoto(userId, dto) {
        const photo = await this.prisma.photo.create({
            data: {
                userId,
                trailId: dto.trailId || null,
                poiId: dto.poiId || null,
                url: dto.url,
                thumbnailUrl: dto.thumbnailUrl || null,
                width: dto.width || null,
                height: dto.height || null,
                description: dto.description || null,
                latitude: dto.latitude ? dto.latitude.toString() : null,
                longitude: dto.longitude ? dto.longitude.toString() : null,
                takenAt: dto.takenAt ? new Date(dto.takenAt) : null,
            },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                trail: {
                    select: {
                        id: true,
                        name: true,
                    },
                },
                _count: {
                    select: { likes: true },
                },
            },
        });
        await this.prisma.user.update({
            where: { id: userId },
            data: { photosCount: { increment: 1 } },
        });
        return this.mapToPhotoDto(photo);
    }
    async createPhotos(userId, dto) {
        const photos = await Promise.all(dto.photos.map(photoDto => this.createPhoto(userId, photoDto)));
        return photos;
    }
    async getPhotos(query, currentUserId) {
        const where = { isPublic: true };
        if (query.trailId) {
            where.trailId = query.trailId;
        }
        if (query.userId) {
            where.userId = query.userId;
        }
        if (query.cursor) {
            where.createdAt = { lt: new Date(query.cursor) };
        }
        const orderBy = query.sort === 'popular'
            ? [{ likeCount: 'desc' }, { createdAt: 'desc' }]
            : { createdAt: 'desc' };
        const photos = await this.prisma.photo.findMany({
            where,
            orderBy,
            take: query.limit + 1,
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                trail: {
                    select: {
                        id: true,
                        name: true,
                    },
                },
                likes: currentUserId ? {
                    where: { userId: currentUserId },
                    take: 1,
                } : false,
                _count: {
                    select: { likes: true },
                },
            },
        });
        const hasMore = photos.length > query.limit;
        const photoList = hasMore ? photos.slice(0, query.limit) : photos;
        const nextCursor = hasMore && photoList.length > 0
            ? photoList[photoList.length - 1].createdAt.toISOString()
            : null;
        return {
            list: photoList.map(p => this.mapToPhotoDto(p, currentUserId)),
            nextCursor,
            hasMore,
        };
    }
    async getPhotoDetail(photoId, currentUserId) {
        const photo = await this.prisma.photo.findUnique({
            where: { id: photoId },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                trail: {
                    select: {
                        id: true,
                        name: true,
                    },
                },
                likes: currentUserId ? {
                    where: { userId: currentUserId },
                    take: 1,
                } : false,
                _count: {
                    select: { likes: true },
                },
            },
        });
        if (!photo) {
            throw new common_1.NotFoundException('照片不存在');
        }
        return this.mapToPhotoDto(photo, currentUserId);
    }
    async updatePhoto(userId, photoId, dto) {
        const photo = await this.prisma.photo.findUnique({
            where: { id: photoId },
        });
        if (!photo) {
            throw new common_1.NotFoundException('照片不存在');
        }
        if (photo.userId !== userId) {
            throw new common_1.ForbiddenException('无权修改此照片');
        }
        const updated = await this.prisma.photo.update({
            where: { id: photoId },
            data: {
                description: dto.description,
                isPublic: dto.isPublic,
            },
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                trail: {
                    select: {
                        id: true,
                        name: true,
                    },
                },
                _count: {
                    select: { likes: true },
                },
            },
        });
        return this.mapToPhotoDto(updated);
    }
    async deletePhoto(userId, photoId) {
        const photo = await this.prisma.photo.findUnique({
            where: { id: photoId },
        });
        if (!photo) {
            throw new common_1.NotFoundException('照片不存在');
        }
        if (photo.userId !== userId) {
            throw new common_1.ForbiddenException('无权删除此照片');
        }
        await this.prisma.photo.delete({
            where: { id: photoId },
        });
        await this.prisma.user.update({
            where: { id: userId },
            data: { photosCount: { decrement: 1 } },
        });
    }
    async likePhoto(userId, photoId) {
        const photo = await this.prisma.photo.findUnique({
            where: { id: photoId },
        });
        if (!photo) {
            throw new common_1.NotFoundException('照片不存在');
        }
        const existingLike = await this.prisma.photoLike.findUnique({
            where: {
                photoId_userId: {
                    photoId,
                    userId,
                },
            },
        });
        if (existingLike) {
            await this.prisma.photoLike.delete({
                where: { id: existingLike.id },
            });
            await this.prisma.photo.update({
                where: { id: photoId },
                data: { likeCount: { decrement: 1 } },
            });
            const updated = await this.prisma.photo.findUnique({
                where: { id: photoId },
                select: { likeCount: true },
            });
            return { isLiked: false, likeCount: updated?.likeCount || 0 };
        }
        else {
            await this.prisma.photoLike.create({
                data: {
                    photoId,
                    userId,
                },
            });
            await this.prisma.photo.update({
                where: { id: photoId },
                data: { likeCount: { increment: 1 } },
            });
            const updated = await this.prisma.photo.findUnique({
                where: { id: photoId },
                select: { likeCount: true },
            });
            return { isLiked: true, likeCount: updated?.likeCount || 0 };
        }
    }
    async getUserPhotos(userId, currentUserId, cursor, limit = 20) {
        const where = { userId };
        if (userId !== currentUserId) {
            where.isPublic = true;
        }
        if (cursor) {
            where.createdAt = { lt: new Date(cursor) };
        }
        const photos = await this.prisma.photo.findMany({
            where,
            orderBy: { createdAt: 'desc' },
            take: limit + 1,
            include: {
                user: {
                    select: {
                        id: true,
                        nickname: true,
                        avatarUrl: true,
                    },
                },
                trail: {
                    select: {
                        id: true,
                        name: true,
                    },
                },
                likes: currentUserId ? {
                    where: { userId: currentUserId },
                    take: 1,
                } : false,
                _count: {
                    select: { likes: true },
                },
            },
        });
        const hasMore = photos.length > limit;
        const photoList = hasMore ? photos.slice(0, limit) : photos;
        const nextCursor = hasMore && photoList.length > 0
            ? photoList[photoList.length - 1].createdAt.toISOString()
            : null;
        return {
            list: photoList.map(p => this.mapToPhotoDto(p, currentUserId)),
            nextCursor,
            hasMore,
        };
    }
    mapToPhotoDto(photo, currentUserId) {
        let isLiked = false;
        if (currentUserId && photo.likes) {
            isLiked = photo.likes.length > 0;
        }
        return {
            id: photo.id,
            url: photo.url,
            thumbnailUrl: photo.thumbnailUrl,
            width: photo.width,
            height: photo.height,
            description: photo.description,
            likeCount: photo.likeCount,
            isLiked,
            isPublic: photo.isPublic,
            createdAt: photo.createdAt,
            user: {
                id: photo.user.id,
                nickname: photo.user.nickname,
                avatarUrl: photo.user.avatarUrl,
            },
            trail: photo.trail,
        };
    }
};
exports.PhotosService = PhotosService;
exports.PhotosService = PhotosService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], PhotosService);
//# sourceMappingURL=photos.service.js.map