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
  BatchRemoveTrailsDto,
  BatchMoveTrailsDto,
  SearchCollectionTrailsDto,
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
   * P1: 实现从 reviews 表查询评分数据
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
                // P1: 从 reviews 表实时查询评分统计
                avgRating: true,
                reviewCount: true,
                // P1: 评分分布统计
                rating5Count: true,
                rating4Count: true,
                rating3Count: true,
                rating2Count: true,
                rating1Count: true,
                // P1: 只返回已发布的路线
                isPublished: true,
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

    // P1: 过滤未发布的路线并计算评分分布
    const publishedTrails = collection.trails
      .filter(t => t.trail.isPublished !== false)
      .map(t => ({
        ...t,
        trail: {
          ...t.trail,
          // P1: 确保 rating 数据有效
          avgRating: t.trail.avgRating,
          reviewCount: t.trail.reviewCount,
          // P1: 添加评分分布
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

  /**
   * 批量从收藏夹移除路线
   */
  async batchRemoveTrails(
    userId: string,
    collectionId: string,
    dto: BatchRemoveTrailsDto,
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

    // 批量删除
    const deleteResult = await this.prisma.collectionTrail.deleteMany({
      where: {
        collectionId,
        trailId: { in: dto.trailIds },
      },
    });

    // 更新路线数
    if (deleteResult.count > 0) {
      await this.prisma.collection.update({
        where: { id: collectionId },
        data: { trailCount: { decrement: deleteResult.count } },
      });
    }
  }

  /**
   * 批量移动路线到其他收藏夹
   */
  async batchMoveTrails(
    userId: string,
    collectionId: string,
    dto: BatchMoveTrailsDto,
  ): Promise<CollectionDetailDto> {
    const sourceCollection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!sourceCollection) {
      throw new NotFoundException('源收藏夹不存在');
    }

    if (sourceCollection.userId !== userId) {
      throw new ForbiddenException('无权修改此收藏夹');
    }

    const targetCollection = await this.prisma.collection.findUnique({
      where: { id: dto.targetCollectionId },
    });

    if (!targetCollection) {
      throw new NotFoundException('目标收藏夹不存在');
    }

    if (targetCollection.userId !== userId) {
      throw new ForbiddenException('无权操作目标收藏夹');
    }

    // 获取目标收藏夹当前最大排序值
    const maxSortOrder = await this.prisma.collectionTrail.findFirst({
      where: { collectionId: dto.targetCollectionId },
      orderBy: { sortOrder: 'desc' },
      select: { sortOrder: true },
    });

    let currentSortOrder = (maxSortOrder?.sortOrder || 0) + 1;

    // 查询源收藏夹中存在的关联记录
    const sourceTrails = await this.prisma.collectionTrail.findMany({
      where: {
        collectionId,
        trailId: { in: dto.trailIds },
      },
    });

    if (sourceTrails.length === 0) {
      // 没有需要移动的路线，直接返回目标收藏夹详情
      return this.getCollectionDetail(dto.targetCollectionId, userId);
    }

    // 批量创建到目标收藏夹，忽略已存在的（使用事务确保一致性）
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

    // 使用事务确保原子性
    await this.prisma.$transaction(async (tx) => {
      // 从源收藏夹删除
      await tx.collectionTrail.deleteMany({
        where: {
          collectionId,
          trailId: { in: trailIdsToMove },
        },
      });

      // 添加到目标收藏夹（仅新路线）
      if (newTrailIds.length > 0) {
        await tx.collectionTrail.createMany({
          data: newTrailIds.map(trailId => ({
            collectionId: dto.targetCollectionId,
            trailId,
            sortOrder: currentSortOrder++,
          })),
        });
      }

      // 更新两个收藏夹的路线数
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

    // 返回更新后的源收藏夹详情（移动后）
    return this.getCollectionDetail(collectionId, userId);
  }

  /**
   * 搜索收藏夹内路线
   */
  async searchCollectionTrails(
    userId: string,
    collectionId: string,
    dto: SearchCollectionTrailsDto,
  ): Promise<CollectionDetailDto> {
    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException('收藏夹不存在');
    }

    if (!collection.isPublic && collection.userId !== userId) {
      throw new ForbiddenException('无权查看此收藏夹');
    }

    // 构建筛选条件
    const where: any = {
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

    // 查询符合条件的收藏夹路线
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

    // 过滤已发布的路线
    const publishedTrails = trails.filter(t => t.trail.isPublished !== false);

    // 返回收藏夹详情结构，但只包含搜索到的路线
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
