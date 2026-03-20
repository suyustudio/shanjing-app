// ================================================================
// M6: 照片系统 Service
// ================================================================

import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import {
  CreatePhotoDto,
  CreatePhotosDto,
  UpdatePhotoDto,
  QueryPhotosDto,
  PhotoDto,
  PhotoListResponseDto,
  LikePhotoResponseDto,
} from './dto/photo.dto';

@Injectable()
export class PhotosService {
  constructor(private prisma: PrismaService) {}

  /**
   * 创建照片
   */
  async createPhoto(userId: string, dto: CreatePhotoDto): Promise<PhotoDto> {
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

    // 更新用户照片数
    await this.prisma.user.update({
      where: { id: userId },
      data: { photosCount: { increment: 1 } },
    });

    return this.mapToPhotoDto(photo);
  }

  /**
   * 批量创建照片
   */
  async createPhotos(userId: string, dto: CreatePhotosDto): Promise<PhotoDto[]> {
    const photos = await Promise.all(
      dto.photos.map(photoDto => this.createPhoto(userId, photoDto))
    );
    return photos;
  }

  /**
   * 获取照片列表 (支持瀑布流分页)
   */
  async getPhotos(
    query: QueryPhotosDto,
    currentUserId?: string,
  ): Promise<PhotoListResponseDto> {
    // 构建查询条件
    const where: any = { isPublic: true };
    if (query.trailId) {
      where.trailId = query.trailId;
    }
    if (query.userId) {
      where.userId = query.userId;
    }

    // 游标条件
    if (query.cursor) {
      where.createdAt = { lt: new Date(query.cursor) };
    }

    // 排序
    const orderBy = query.sort === 'popular'
      ? [{ likeCount: 'desc' }, { createdAt: 'desc' }]
      : { createdAt: 'desc' };

    // 查询
    const photos = await this.prisma.photo.findMany({
      where,
      orderBy,
      take: query.limit + 1, // 多取一条用于判断是否有更多
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

    // 判断是否有更多
    const hasMore = photos.length > query.limit;
    const photoList = hasMore ? photos.slice(0, query.limit) : photos;

    // 生成下一页游标
    const nextCursor = hasMore && photoList.length > 0
      ? photoList[photoList.length - 1].createdAt.toISOString()
      : null;

    return {
      list: photoList.map(p => this.mapToPhotoDto(p, currentUserId)),
      nextCursor,
      hasMore,
    };
  }

  /**
   * 获取照片详情
   */
  async getPhotoDetail(photoId: string, currentUserId?: string): Promise<PhotoDto> {
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
      throw new NotFoundException('照片不存在');
    }

    return this.mapToPhotoDto(photo, currentUserId);
  }

  /**
   * 更新照片
   */
  async updatePhoto(
    userId: string,
    photoId: string,
    dto: UpdatePhotoDto,
  ): Promise<PhotoDto> {
    const photo = await this.prisma.photo.findUnique({
      where: { id: photoId },
    });

    if (!photo) {
      throw new NotFoundException('照片不存在');
    }

    if (photo.userId !== userId) {
      throw new ForbiddenException('无权修改此照片');
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

  /**
   * 删除照片
   */
  async deletePhoto(userId: string, photoId: string): Promise<void> {
    const photo = await this.prisma.photo.findUnique({
      where: { id: photoId },
    });

    if (!photo) {
      throw new NotFoundException('照片不存在');
    }

    if (photo.userId !== userId) {
      throw new ForbiddenException('无权删除此照片');
    }

    await this.prisma.photo.delete({
      where: { id: photoId },
    });

    // 更新用户照片数
    await this.prisma.user.update({
      where: { id: userId },
      data: { photosCount: { decrement: 1 } },
    });
  }

  /**
   * 点赞/取消点赞照片
   */
  async likePhoto(userId: string, photoId: string): Promise<LikePhotoResponseDto> {
    const photo = await this.prisma.photo.findUnique({
      where: { id: photoId },
    });

    if (!photo) {
      throw new NotFoundException('照片不存在');
    }

    // 检查是否已点赞
    const existingLike = await this.prisma.photoLike.findUnique({
      where: {
        photoId_userId: {
          photoId,
          userId,
        },
      },
    });

    if (existingLike) {
      // 取消点赞
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
    } else {
      // 添加点赞
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

  /**
   * 获取用户的照片列表
   */
  async getUserPhotos(
    userId: string,
    currentUserId?: string,
    cursor?: string,
    limit: number = 20,
  ): Promise<PhotoListResponseDto> {
    const where: any = { userId };
    
    // 只能查看自己的非公开照片
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

  // ==================== 数据映射 ====================

  private mapToPhotoDto(photo: any, currentUserId?: string): PhotoDto {
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
}
