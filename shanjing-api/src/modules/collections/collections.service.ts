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

  // ==================== 标签管理 ====================

  /**
   * 生成标签颜色（基于标签名哈希）
   */
  private generateTagColor(tagName: string): string {
    // 简单哈希函数
    let hash = 0;
    for (let i = 0; i < tagName.length; i++) {
      hash = ((hash << 5) - hash) + tagName.charCodeAt(i);
      hash |= 0; // 转换为32位整数
    }
    hash = Math.abs(hash);
    
    // 使用HSL颜色空间生成柔和颜色
    const hue = hash % 360;
    const saturation = 60 + (hash % 20); // 60-80%
    const lightness = 50 + (hash % 10); // 50-60%
    
    // HSL转RGB（简化版）
    const h = hue / 360;
    const s = saturation / 100;
    const l = lightness / 100;
    
    const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
    const p = 2 * l - q;
    
    const r = Math.round(this.hueToRgb(p, q, h + 1/3) * 255);
    const g = Math.round(this.hueToRgb(p, q, h) * 255);
    const b = Math.round(this.hueToRgb(p, q, h - 1/3) * 255);
    
    // 返回Hex颜色
    return `#${((1 << 24) + (r << 16) + (g << 8) + b).toString(16).slice(1).toUpperCase()}`;
  }

  /**
   * HSL转RGB辅助函数
   */
  private hueToRgb(p: number, q: number, t: number): number {
    if (t < 0) t += 1;
    if (t > 1) t -= 1;
    if (t < 1/6) return p + (q - p) * 6 * t;
    if (t < 1/2) return q;
    if (t < 2/3) return p + (q - p) * (2/3 - t) * 6;
    return p;
  }

  /**
   * 生成标签ID（基于标签名哈希）
   */
  private generateTagId(tagName: string): string {
    let hash = 0;
    for (let i = 0; i < tagName.length; i++) {
      hash = ((hash << 5) - hash) + tagName.charCodeAt(i);
      hash |= 0;
    }
    return Math.abs(hash).toString();
  }

  /**
   * 获取所有标签（从所有收藏夹中聚合）
   */
  async getAllTags(userId?: string): Promise<Array<{id: string, name: string, color: string, count: number}>> {
    // 构建查询条件
    const where: any = {};
    if (userId) {
      where.userId = userId;
    }
    
    const collections = await this.prisma.collection.findMany({
      where,
      select: { tags: true },
    });

    // 聚合标签计数
    const tagCounts = new Map<string, number>();
    collections.forEach(collection => {
      collection.tags.forEach(tag => {
        tagCounts.set(tag, (tagCounts.get(tag) || 0) + 1);
      });
    });

    // 转换为数组并排序，添加id和color
    return Array.from(tagCounts.entries())
      .map(([name, count]) => ({
        id: this.generateTagId(name),
        name,
        color: this.generateTagColor(name),
        count,
      }))
      .sort((a, b) => b.count - a.count);
  }

  /**
   * 创建标签（验证标签名，不实际存储独立实体）
   */
  async createTag(userId: string, tagName: string, color?: string): Promise<{id: string, name: string, color: string, count: number}> {
    // 标签名验证
    if (!tagName || tagName.trim().length === 0) {
      throw new Error('标签名不能为空');
    }
    if (tagName.length > 20) {
      throw new Error('标签名不能超过20个字符');
    }

    // 检查标签是否已存在（在用户的收藏夹中）
    const userCollections = await this.prisma.collection.findMany({
      where: { userId },
      select: { tags: true },
    });

    const existingTags = new Set<string>();
    userCollections.forEach(collection => {
      collection.tags.forEach(tag => existingTags.add(tag));
    });

    if (existingTags.has(tagName)) {
      // 标签已存在，返回现有统计
      const allTags = await this.getAllTags(userId);
      const existingTag = allTags.find(t => t.name === tagName);
      return existingTag || {
        id: this.generateTagId(tagName),
        name: tagName,
        color: color || this.generateTagColor(tagName),
        count: 0,
      };
    }

    // 新标签，返回0计数
    return {
      id: this.generateTagId(tagName),
      name: tagName,
      color: color || this.generateTagColor(tagName),
      count: 0,
    };
  }

  /**
   * 删除标签（从所有收藏夹中移除）
   */
  async deleteTag(userId: string, tagName: string): Promise<void> {
    // 获取用户所有包含此标签的收藏夹
    const collections = await this.prisma.collection.findMany({
      where: {
        userId,
        tags: { has: tagName },
      },
    });

    // 从每个收藏夹中移除标签
    for (const collection of collections) {
      const updatedTags = collection.tags.filter(t => t !== tagName);
      await this.prisma.collection.update({
        where: { id: collection.id },
        data: { tags: updatedTags },
      });
    }
  }

  /**
   * 获取收藏夹的标签
   */
  async getCollectionTags(collectionId: string, userId?: string): Promise<string[]> {
    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
      select: { tags: true, userId: true },
    });

    if (!collection) {
      throw new NotFoundException('收藏夹不存在');
    }

    // 检查权限（非公开收藏夹只能所有者查看）
    if (collection.userId !== userId) {
      const publicCollection = await this.prisma.collection.findFirst({
        where: { id: collectionId, isPublic: true },
      });
      if (!publicCollection) {
        throw new ForbiddenException('无权访问此收藏夹');
      }
    }

    return collection.tags;
  }

  /**
   * 更新收藏夹标签
   */
  async updateCollectionTags(
    userId: string,
    collectionId: string,
    tags: string[],
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

    // 验证标签
    const validatedTags = tags
      .map(tag => tag.trim())
      .filter(tag => tag.length > 0 && tag.length <= 20)
      .slice(0, 10); // 最多10个标签

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

  /**
   * 搜索标签
   */
  async searchTags(query: string, userId?: string): Promise<Array<{id: string, name: string, color: string, count: number}>> {
    const allTags = await this.getAllTags(userId);
    const lowerQuery = query.toLowerCase();
    
    return allTags.filter(tag => 
      tag.name.toLowerCase().includes(lowerQuery)
    );
  }
}
