// ================================================================
// M6: 收藏夹系统 Service
// ================================================================

import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import {
  CreateCollectionDto,
  UpdateCollectionDto,
  AddTrailToCollectionDto,
  BatchAddTrailsDto,
  QueryCollectionsDto,
  CollectionDto,
  CollectionDetailDto,
  CollectionListResponseDto,
} from './dto/collection.dto';

@Injectable()
export class CollectionsService {
  constructor(private prisma: PrismaService) {}

  /**
   * 创建收藏夹
   */
  async createCollection(
    userId: string,
    dto: CreateCollectionDto,
  ): Promise<CollectionDto> {
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

  /**
   * 获取收藏夹列表
   */
  async getCollections(
    query: QueryCollectionsDto,
    currentUserId?: string,
  ): Promise<CollectionListResponseDto> {
    const targetUserId = query.userId || currentUserId;

    if (!targetUserId) {
      throw new ForbiddenException('需要指定用户ID或登录');
    }

    const where: any = { userId: targetUserId };

    // 只能查看自己的非公开收藏夹
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

  /**
   * 获取收藏夹详情
   */
  async getCollectionDetail(
    collectionId: string,
    currentUserId?: string,
  ): Promise<CollectionDetailDto> {
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
              },
            },
          },
        },
      },
    });

    if (!collection) {
      throw new NotFoundException('收藏夹不存在');
    }

    // 检查权限
    if (!collection.isPublic && collection.userId !== currentUserId) {
      throw new ForbiddenException('无权查看此收藏夹');
    }

    return this.mapToCollectionDetailDto(collection);
  }

  /**
   * 更新收藏夹
   */
  async updateCollection(
    userId: string,
    collectionId: string,
    dto: UpdateCollectionDto,
  ): Promise<CollectionDto> {
    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException('收藏夹不存在');
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException('无权修改此收藏夹');
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

  /**
   * 删除收藏夹
   */
  async deleteCollection(userId: string, collectionId: string): Promise<void> {
    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException('收藏夹不存在');
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException('无权删除此收藏夹');
    }

    await this.prisma.collection.delete({
      where: { id: collectionId },
    });
  }

  /**
   * 添加路线到收藏夹
   */
  async addTrailToCollection(
    userId: string,
    collectionId: string,
    dto: AddTrailToCollectionDto,
  ): Promise<CollectionDetailDto> {
    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException('收藏夹不存在');
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException('无权修改此收藏夹');
    }

    // 检查路线是否存在
    const trail = await this.prisma.trail.findUnique({
      where: { id: dto.trailId },
    });

    if (!trail) {
      throw new NotFoundException('路线不存在');
    }

    // 检查是否已存在
    const existing = await this.prisma.collectionTrail.findUnique({
      where: {
        collectionId_trailId: {
          collectionId,
          trailId: dto.trailId,
        },
      },
    });

    if (existing) {
      throw new ForbiddenException('该路线已在收藏夹中');
    }

    // 获取当前最大排序值
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

    // 更新路线数
    await this.prisma.collection.update({
      where: { id: collectionId },
      data: { trailCount: { increment: 1 } },
    });

    return this.getCollectionDetail(collectionId, userId);
  }

  /**
   * 从收藏夹移除路线
   */
  async removeTrailFromCollection(
    userId: string,
    collectionId: string,
    trailId: string,
  ): Promise<void> {
    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException('收藏夹不存在');
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException('无权修改此收藏夹');
    }

    await this.prisma.collectionTrail.deleteMany({
      where: {
        collectionId,
        trailId,
      },
    });

    // 更新路线数
    await this.prisma.collection.update({
      where: { id: collectionId },
      data: { trailCount: { decrement: 1 } },
    });
  }

  /**
   * 批量添加路线到收藏夹
   */
  async batchAddTrails(
    userId: string,
    collectionId: string,
    dto: BatchAddTrailsDto,
  ): Promise<CollectionDetailDto> {
    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException('收藏夹不存在');
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException('无权修改此收藏夹');
    }

    // 获取当前最大排序值
    const maxSortOrder = await this.prisma.collectionTrail.findFirst({
      where: { collectionId },
      orderBy: { sortOrder: 'desc' },
      select: { sortOrder: true },
    });

    let currentSortOrder = (maxSortOrder?.sortOrder || 0) + 1;

    // 过滤已存在的路线
    const existingTrails = await this.prisma.collectionTrail.findMany({
      where: {
        collectionId,
        trailId: { in: dto.trailIds },
      },
      select: { trailId: true },
    });

    const existingTrailIds = existingTrails.map(t => t.trailId);
    const newTrailIds = dto.trailIds.filter(id => !existingTrailIds.includes(id));

    // 批量创建
    if (newTrailIds.length > 0) {
      await this.prisma.collectionTrail.createMany({
        data: newTrailIds.map(trailId => ({
          collectionId,
          trailId,
          sortOrder: currentSortOrder++,
        })),
      });

      // 更新路线数
      await this.prisma.collection.update({
        where: { id: collectionId },
        data: { trailCount: { increment: newTrailIds.length } },
      });
    }

    return this.getCollectionDetail(collectionId, userId);
  }

  // ==================== 数据映射 ====================

  private mapToCollectionDto(collection: any): CollectionDto {
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

  private mapToCollectionDetailDto(collection: any): CollectionDetailDto {
    return {
      ...this.mapToCollectionDto(collection),
      trails: collection.trails.map((t: any) => ({
        id: t.id,
        trailId: t.trailId,
        trail: t.trail,
        note: t.note,
        createdAt: t.createdAt,
      })),
    };
  }
}
