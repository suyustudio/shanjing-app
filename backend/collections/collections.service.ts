// collections.service.ts
// 山径APP - 收藏夹服务

import {
  Injectable,
  NotFoundException,
  ForbiddenException,
  ConflictException,
  Logger,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import {
  CreateCollectionDto,
  UpdateCollectionDto,
  AddTrailToCollectionDto,
  SortTrailsDto,
} from './dto/collection.dto';
import {
  CollectionResponseDto,
  CollectionListResponseDto,
  CollectionDetailResponseDto,
  CollectionActionResponseDto,
  CollectionDto,
} from './dto/collection-response.dto';

/**
 * 收藏夹服务
 * 
 * 处理收藏夹相关的业务逻辑
 */
@Injectable()
export class CollectionsService {
  private readonly logger = new Logger(CollectionsService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * 获取或创建默认收藏夹
   */
  private async getOrCreateDefaultCollection(userId: string): Promise<any> {
    let defaultCollection = await this.prisma.collection.findFirst({
      where: { userId, isDefault: true },
    });

    if (!defaultCollection) {
      defaultCollection = await this.prisma.collection.create({
        data: {
          userId,
          name: '想去',
          description: '',
          isPublic: false,
          isDefault: true,
          sortOrder: 0,
        },
      });
      this.logger.log(`Created default collection for user ${userId}`);
    }

    return defaultCollection;
  }

  /**
   * 获取收藏夹列表
   */
  async getCollections(
    currentUserId: string,
    targetUserId?: string,
  ): Promise<CollectionListResponseDto> {
    const userId = targetUserId || currentUserId;
    const isSelf = userId === currentUserId;

    this.logger.debug(`Getting collections for user ${userId}, isSelf: ${isSelf}`);

    // 如果不是查看自己的收藏夹，只能查看公开的
    const where: any = { userId };
    if (!isSelf) {
      where.isPublic = true;
    }

    const collections = await this.prisma.collection.findMany({
      where,
      orderBy: [{ isDefault: 'desc' }, { sortOrder: 'asc' }, { createdAt: 'desc' }],
    });

    // 如果是查看自己的收藏夹，确保有默认收藏夹
    if (isSelf && collections.length === 0) {
      const defaultCollection = await this.getOrCreateDefaultCollection(userId);
      collections.push(defaultCollection);
    }

    const data: CollectionDto[] = collections.map((c) => ({
      id: c.id,
      name: c.name,
      description: c.description || undefined,
      coverUrl: c.coverUrl || undefined,
      trailCount: c.trailCount,
      isPublic: c.isPublic,
      isDefault: c.isDefault,
      sortOrder: c.sortOrder,
      createdAt: c.createdAt.toISOString(),
      updatedAt: c.updatedAt.toISOString(),
    }));

    return { success: true, data };
  }

  /**
   * 创建收藏夹
   */
  async createCollection(
    userId: string,
    dto: CreateCollectionDto,
  ): Promise<CollectionResponseDto> {
    this.logger.debug(`User ${userId} creating collection: ${dto.name}`);

    // 检查名称是否已存在
    const existing = await this.prisma.collection.findUnique({
      where: { userId_name: { userId, name: dto.name } },
    });

    if (existing) {
      throw new ConflictException({
        success: false,
        error: { code: 'NAME_EXISTS', message: '收藏夹名称已存在' },
      });
    }

    // 获取当前最大排序号
    const maxOrder = await this.prisma.collection.findFirst({
      where: { userId },
      orderBy: { sortOrder: 'desc' },
      select: { sortOrder: true },
    });

    const collection = await this.prisma.collection.create({
      data: {
        userId,
        name: dto.name,
        description: dto.description,
        isPublic: dto.isPublic ?? true,
        sortOrder: (maxOrder?.sortOrder ?? 0) + 1,
      },
    });

    this.logger.log(`Collection created: ${collection.id}`);

    return {
      success: true,
      data: {
        id: collection.id,
        name: collection.name,
        description: collection.description || undefined,
        coverUrl: collection.coverUrl || undefined,
        trailCount: 0,
        isPublic: collection.isPublic,
        isDefault: false,
        sortOrder: collection.sortOrder,
        createdAt: collection.createdAt.toISOString(),
        updatedAt: collection.updatedAt.toISOString(),
      },
    };
  }

  /**
   * 获取收藏夹详情
   */
  async getCollectionDetail(
    currentUserId: string,
    collectionId: string,
    page: number,
    limit: number,
  ): Promise<CollectionDetailResponseDto> {
    this.logger.debug(`Getting collection detail: ${collectionId}`);

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
      },
    });

    if (!collection) {
      throw new NotFoundException({
        success: false,
        error: { code: 'COLLECTION_NOT_FOUND', message: '收藏夹不存在' },
      });
    }

    const isOwner = collection.userId === currentUserId;

    // 如果不是自己的私密收藏夹，拒绝访问
    if (!collection.isPublic && !isOwner) {
      throw new ForbiddenException({
        success: false,
        error: { code: 'PRIVATE_COLLECTION', message: '该收藏夹为私密' },
      });
    }

    const skip = (page - 1) * limit;

    // 获取收藏夹内的路线
    const [trails, total] = await Promise.all([
      this.prisma.collectionTrail.findMany({
        where: { collectionId },
        skip,
        take: limit,
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
              favoriteCount: true,
              viewCount: true,
            },
          },
        },
      }),
      this.prisma.collectionTrail.count({ where: { collectionId } }),
    ]);

    const totalPages = Math.ceil(total / limit);

    return {
      success: true,
      data: {
        id: collection.id,
        name: collection.name,
        description: collection.description || undefined,
        coverUrl: collection.coverUrl || undefined,
        user: {
          id: collection.user.id,
          nickname: collection.user.nickname || '',
          avatar: collection.user.avatarUrl || undefined,
        },
        trailCount: collection.trailCount,
        isPublic: collection.isPublic,
        isOwner,
        createdAt: collection.createdAt.toISOString(),
        updatedAt: collection.updatedAt.toISOString(),
        trails: trails.map((t) => ({
          id: t.id,
          trailId: t.trail.id,
          name: t.trail.name,
          coverImage: t.trail.coverImages[0],
          distanceKm: t.trail.distanceKm,
          durationMin: t.trail.durationMin,
          difficulty: t.trail.difficulty,
          rating: undefined, // TODO: 从 reviews 表计算
          reviewCount: undefined, // TODO: 从 reviews 表计算
          note: t.note || undefined,
          addedAt: t.addedAt.toISOString(),
          sortOrder: t.sortOrder,
        })),
      },
      meta: {
        page,
        limit,
        total,
        totalPages,
        hasMore: page < totalPages,
      },
    };
  }

  /**
   * 更新收藏夹
   */
  async updateCollection(
    userId: string,
    collectionId: string,
    dto: UpdateCollectionDto,
  ): Promise<CollectionResponseDto> {
    this.logger.debug(`User ${userId} updating collection: ${collectionId}`);

    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException({
        success: false,
        error: { code: 'COLLECTION_NOT_FOUND', message: '收藏夹不存在' },
      });
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException({
        success: false,
        error: { code: 'FORBIDDEN', message: '无权限修改此收藏夹' },
      });
    }

    // 默认收藏夹不能修改名称和隐私设置
    if (collection.isDefault) {
      if (dto.name !== undefined && dto.name !== collection.name) {
        throw new ForbiddenException({
          success: false,
          error: { code: 'CANNOT_MODIFY_DEFAULT', message: '默认收藏夹不能修改名称' },
        });
      }
      if (dto.isPublic !== undefined) {
        delete dto.isPublic;
      }
    }

    // 检查新名称是否冲突
    if (dto.name && dto.name !== collection.name) {
      const existing = await this.prisma.collection.findUnique({
        where: { userId_name: { userId, name: dto.name } },
      });
      if (existing) {
        throw new ConflictException({
          success: false,
          error: { code: 'NAME_EXISTS', message: '收藏夹名称已存在' },
        });
      }
    }

    const updated = await this.prisma.collection.update({
      where: { id: collectionId },
      data: {
        ...(dto.name !== undefined && { name: dto.name }),
        ...(dto.description !== undefined && { description: dto.description }),
        ...(dto.isPublic !== undefined && { isPublic: dto.isPublic }),
      },
    });

    return {
      success: true,
      data: {
        id: updated.id,
        name: updated.name,
        description: updated.description || undefined,
        coverUrl: updated.coverUrl || undefined,
        trailCount: updated.trailCount,
        isPublic: updated.isPublic,
        isDefault: updated.isDefault,
        sortOrder: updated.sortOrder,
        createdAt: updated.createdAt.toISOString(),
        updatedAt: updated.updatedAt.toISOString(),
      },
    };
  }

  /**
   * 删除收藏夹
   */
  async deleteCollection(
    userId: string,
    collectionId: string,
  ): Promise<CollectionActionResponseDto> {
    this.logger.debug(`User ${userId} deleting collection: ${collectionId}`);

    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException({
        success: false,
        error: { code: 'COLLECTION_NOT_FOUND', message: '收藏夹不存在' },
      });
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException({
        success: false,
        error: { code: 'FORBIDDEN', message: '无权限删除此收藏夹' },
      });
    }

    // 默认收藏夹不能删除
    if (collection.isDefault) {
      throw new ForbiddenException({
        success: false,
        error: { code: 'CANNOT_DELETE_DEFAULT', message: '默认收藏夹不能删除' },
      });
    }

    await this.prisma.collection.delete({
      where: { id: collectionId },
    });

    return {
      success: true,
      data: { collectionId, deleted: true },
    };
  }

  /**
   * 添加路线到收藏夹
   */
  async addTrailToCollection(
    userId: string,
    collectionId: string,
    dto: AddTrailToCollectionDto,
  ): Promise<CollectionActionResponseDto> {
    this.logger.debug(`Adding trail ${dto.trailId} to collection ${collectionId}`);

    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException({
        success: false,
        error: { code: 'COLLECTION_NOT_FOUND', message: '收藏夹不存在' },
      });
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException({
        success: false,
        error: { code: 'FORBIDDEN', message: '无权限修改此收藏夹' },
      });
    }

    // 检查路线是否存在
    const trail = await this.prisma.trail.findUnique({
      where: { id: dto.trailId, isPublished: true },
    });

    if (!trail) {
      throw new NotFoundException({
        success: false,
        error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在或未发布' },
      });
    }

    // 检查是否已在收藏夹中
    const existing = await this.prisma.collectionTrail.findUnique({
      where: {
        collectionId_trailId: {
          collectionId,
          trailId: dto.trailId,
        },
      },
    });

    if (existing) {
      throw new ConflictException({
        success: false,
        error: { code: 'ALREADY_IN_COLLECTION', message: '该路线已在收藏夹中' },
      });
    }

    // 获取当前最大排序号
    const maxOrder = await this.prisma.collectionTrail.findFirst({
      where: { collectionId },
      orderBy: { sortOrder: 'desc' },
      select: { sortOrder: true },
    });

    // 使用事务添加路线并更新计数
    const [, updatedCollection] = await this.prisma.$transaction([
      this.prisma.collectionTrail.create({
        data: {
          collectionId,
          trailId: dto.trailId,
          note: dto.note,
          sortOrder: (maxOrder?.sortOrder ?? 0) + 1,
        },
      }),
      this.prisma.collection.update({
        where: { id: collectionId },
        data: { trailCount: { increment: 1 } },
      }),
    ]);

    return {
      success: true,
      data: {
        collectionId,
        trailId: dto.trailId,
        action: 'added',
        trailCount: updatedCollection.trailCount,
      },
    };
  }

  /**
   * 从收藏夹移除路线
   */
  async removeTrailFromCollection(
    userId: string,
    collectionId: string,
    trailId: string,
  ): Promise<CollectionActionResponseDto> {
    this.logger.debug(`Removing trail ${trailId} from collection ${collectionId}`);

    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException({
        success: false,
        error: { code: 'COLLECTION_NOT_FOUND', message: '收藏夹不存在' },
      });
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException({
        success: false,
        error: { code: 'FORBIDDEN', message: '无权限修改此收藏夹' },
      });
    }

    // 检查路线是否在收藏夹中
    const existing = await this.prisma.collectionTrail.findUnique({
      where: {
        collectionId_trailId: {
          collectionId,
          trailId,
        },
      },
    });

    if (!existing) {
      throw new NotFoundException({
        success: false,
        error: { code: 'TRAIL_NOT_IN_COLLECTION', message: '该路线不在收藏夹中' },
      });
    }

    // 使用事务移除路线并更新计数
    const [, updatedCollection] = await this.prisma.$transaction([
      this.prisma.collectionTrail.delete({
        where: {
          collectionId_trailId: {
            collectionId,
            trailId,
          },
        },
      }),
      this.prisma.collection.update({
        where: { id: collectionId },
        data: { trailCount: { decrement: 1 } },
      }),
    ]);

    return {
      success: true,
      data: {
        collectionId,
        trailId,
        action: 'removed',
        trailCount: Math.max(0, updatedCollection.trailCount),
      },
    };
  }

  /**
   * 排序收藏夹内路线
   */
  async sortTrailsInCollection(
    userId: string,
    collectionId: string,
    dto: SortTrailsDto,
  ): Promise<CollectionActionResponseDto> {
    this.logger.debug(`Sorting trails in collection ${collectionId}`);

    const collection = await this.prisma.collection.findUnique({
      where: { id: collectionId },
    });

    if (!collection) {
      throw new NotFoundException({
        success: false,
        error: { code: 'COLLECTION_NOT_FOUND', message: '收藏夹不存在' },
      });
    }

    if (collection.userId !== userId) {
      throw new ForbiddenException({
        success: false,
        error: { code: 'FORBIDDEN', message: '无权限修改此收藏夹' },
      });
    }

    // 批量更新排序
    const updates = dto.trailIds.map((trailId, index) =>
      this.prisma.collectionTrail.updateMany({
        where: { collectionId, trailId },
        data: { sortOrder: index },
      })
    );

    await this.prisma.$transaction(updates);

    return {
      success: true,
      data: { collectionId, sorted: true },
    };
  }

  /**
   * 快速收藏（添加到默认收藏夹）
   */
  async quickCollect(
    userId: string,
    trailId: string,
  ): Promise<CollectionActionResponseDto> {
    this.logger.debug(`Quick collect trail ${trailId} for user ${userId}`);

    // 获取或创建默认收藏夹
    const defaultCollection = await this.getOrCreateDefaultCollection(userId);

    // 检查是否已在默认收藏夹中
    const existing = await this.prisma.collectionTrail.findUnique({
      where: {
        collectionId_trailId: {
          collectionId: defaultCollection.id,
          trailId,
        },
      },
    });

    if (existing) {
      // 已在收藏夹中，移除它（取消收藏）
      return this.removeTrailFromCollection(userId, defaultCollection.id, trailId);
    }

    // 添加到默认收藏夹
    return this.addTrailToCollection(userId, defaultCollection.id, { trailId });
  }
}
