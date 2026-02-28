// favorites.service.ts - 收藏服务
// 山径APP - 路线数据 API
// 功能：路线收藏、取消收藏、获取收藏列表

import { Injectable, NotFoundException, ConflictException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ListFavoritesDto, FavoriteSortBy } from './dto/list-favorites.dto';
import {
  FavoriteActionResponseDto,
  FavoriteListResponseDto,
  FavoriteCheckResponseDto,
  FavoriteTrailDto,
} from './dto/favorite-response.dto';

/**
 * 收藏服务
 *
 * 处理路线收藏相关的业务逻辑：
 * - 收藏路线
 * - 取消收藏路线
 * - 获取用户收藏列表
 * - 检查收藏状态
 */
@Injectable()
export class FavoritesService {
  private readonly logger = new Logger(FavoritesService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * 收藏路线
   *
   * @param userId - 用户ID
   * @param trailId - 路线ID
   * @returns 收藏操作结果
   */
  async addFavorite(userId: string, trailId: string): Promise<FavoriteActionResponseDto> {
    this.logger.debug(`User ${userId} adding favorite for trail ${trailId}`);

    // 检查路线是否存在且已发布
    const trail = await this.prisma.trail.findUnique({
      where: { id: trailId, isPublished: true },
      select: { id: true, favoriteCount: true },
    });

    if (!trail) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'TRAIL_NOT_FOUND',
          message: '路线不存在或未发布',
        },
      });
    }

    // 检查是否已收藏
    const existingFavorite = await this.prisma.favorite.findUnique({
      where: {
        userId_trailId: {
          userId,
          trailId,
        },
      },
    });

    if (existingFavorite) {
      throw new ConflictException({
        success: false,
        error: {
          code: 'ALREADY_FAVORITED',
          message: '该路线已收藏',
        },
      });
    }

    // 创建收藏记录并更新路线收藏数（使用事务）
    const [favorite, updatedTrail] = await this.prisma.$transaction([
      this.prisma.favorite.create({
        data: {
          userId,
          trailId,
        },
      }),
      this.prisma.trail.update({
        where: { id: trailId },
        data: { favoriteCount: { increment: 1 } },
        select: { favoriteCount: true },
      }),
    ]);

    this.logger.debug(`User ${userId} favorited trail ${trailId} successfully`);

    return {
      success: true,
      data: {
        trailId,
        isFavorited: true,
        favoriteCount: updatedTrail.favoriteCount,
        favoritedAt: favorite.createdAt.toISOString(),
      },
    };
  }

  /**
   * 取消收藏路线
   *
   * @param userId - 用户ID
   * @param trailId - 路线ID
   * @returns 取消收藏操作结果
   */
  async removeFavorite(userId: string, trailId: string): Promise<FavoriteActionResponseDto> {
    this.logger.debug(`User ${userId} removing favorite for trail ${trailId}`);

    // 检查路线是否存在
    const trail = await this.prisma.trail.findUnique({
      where: { id: trailId },
      select: { id: true, favoriteCount: true },
    });

    if (!trail) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'TRAIL_NOT_FOUND',
          message: '路线不存在',
        },
      });
    }

    // 检查是否已收藏
    const existingFavorite = await this.prisma.favorite.findUnique({
      where: {
        userId_trailId: {
          userId,
          trailId,
        },
      },
    });

    if (!existingFavorite) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'FAVORITE_NOT_FOUND',
          message: '未收藏该路线',
        },
      });
    }

    // 删除收藏记录并更新路线收藏数（使用事务）
    const [, updatedTrail] = await this.prisma.$transaction([
      this.prisma.favorite.delete({
        where: {
          userId_trailId: {
            userId,
            trailId,
          },
        },
      }),
      this.prisma.trail.update({
        where: { id: trailId },
        data: { favoriteCount: { decrement: 1 } },
        select: { favoriteCount: true },
      }),
    ]);

    this.logger.debug(`User ${userId} unfavorited trail ${trailId} successfully`);

    return {
      success: true,
      data: {
        trailId,
        isFavorited: false,
        favoriteCount: Math.max(0, updatedTrail.favoriteCount),
      },
    };
  }

  /**
   * 获取用户收藏列表
   *
   * @param userId - 用户ID
   * @param dto - 查询参数
   * @returns 收藏列表
   */
  async getUserFavorites(userId: string, dto: ListFavoritesDto): Promise<FavoriteListResponseDto> {
    this.logger.debug(`Getting favorites for user ${userId} with filters: ${JSON.stringify(dto)}`);

    const { page, limit, sortBy, sortOrder, city } = dto;
    const skip = (page - 1) * limit;

    // 构建查询条件
    const where: any = {
      userId,
    };

    // 城市筛选（通过关联的路线）
    if (city) {
      where.trail = {
        city: {
          contains: city,
          mode: 'insensitive',
        },
      };
    }

    // 构建排序条件
    const orderBy = this.buildFavoriteOrderBy(sortBy, sortOrder);

    // 执行查询
    const [favorites, total] = await Promise.all([
      this.prisma.favorite.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        include: {
          trail: {
            select: {
              id: true,
              name: true,
              description: true,
              distanceKm: true,
              durationMin: true,
              elevationGainM: true,
              difficulty: true,
              tags: true,
              coverImages: true,
              city: true,
              district: true,
              favoriteCount: true,
              viewCount: true,
            },
          },
        },
      }),
      this.prisma.favorite.count({ where }),
    ]);

    // 计算总页数
    const totalPages = Math.ceil(total / limit);

    // 转换数据格式
    const items: FavoriteTrailDto[] = favorites.map((favorite) => ({
      id: favorite.id,
      trailId: favorite.trail.id,
      trailName: favorite.trail.name,
      description: favorite.trail.description,
      distanceKm: favorite.trail.distanceKm,
      durationMin: favorite.trail.durationMin,
      elevationGainM: favorite.trail.elevationGainM,
      difficulty: favorite.trail.difficulty,
      tags: favorite.trail.tags,
      coverImage: favorite.trail.coverImages[0] || null,
      city: favorite.trail.city,
      district: favorite.trail.district,
      favoriteCount: favorite.trail.favoriteCount,
      viewCount: favorite.trail.viewCount,
      createdAt: favorite.createdAt.toISOString(),
    }));

    this.logger.debug(`Found ${items.length} favorites for user ${userId}, total: ${total}`);

    return {
      success: true,
      data: {
        items,
        pagination: {
          page,
          limit,
          total,
          totalPages,
          hasMore: page < totalPages,
        },
      },
    };
  }

  /**
   * 检查用户是否已收藏某路线
   *
   * @param userId - 用户ID
   * @param trailId - 路线ID
   * @returns 收藏状态
   */
  async checkFavoriteStatus(userId: string, trailId: string): Promise<FavoriteCheckResponseDto> {
    const favorite = await this.prisma.favorite.findUnique({
      where: {
        userId_trailId: {
          userId,
          trailId,
        },
      },
    });

    return {
      success: true,
      data: {
        trailId,
        isFavorited: !!favorite,
        favoritedAt: favorite?.createdAt.toISOString(),
      },
    };
  }

  /**
   * 构建收藏列表排序条件
   *
   * @param sortBy - 排序字段
   * @param sortOrder - 排序顺序
   * @returns Prisma排序条件
   */
  private buildFavoriteOrderBy(
    sortBy: FavoriteSortBy,
    sortOrder: 'asc' | 'desc',
  ): any {
    switch (sortBy) {
      case FavoriteSortBy.NEWEST:
        return { createdAt: 'desc' };
      case FavoriteSortBy.OLDEST:
        return { createdAt: 'asc' };
      case FavoriteSortBy.NAME:
        return { trail: { name: sortOrder } };
      case FavoriteSortBy.DISTANCE:
        return { trail: { distanceKm: sortOrder } };
      case FavoriteSortBy.DURATION:
        return { trail: { durationMin: sortOrder } };
      default:
        return { createdAt: 'desc' };
    }
  }
}
