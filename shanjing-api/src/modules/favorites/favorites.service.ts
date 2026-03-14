/**
 * 收藏服务
 * 
 * 提供用户收藏功能的服务
 */

import { Injectable, NotFoundException, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { FavoriteListQueryDto } from './dto/favorite.dto';

@Injectable()
export class FavoritesService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * 添加收藏
   */
  async addFavorite(userId: string, trailId: string) {
    // 检查路线是否存在且上架
    const trail = await this.prisma.trail.findUnique({
      where: {
        id: trailId,
        isActive: true,
        deletedAt: null,
      },
    });

    if (!trail) {
      throw new NotFoundException({
        success: false,
        error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在或已下架' },
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
        error: { code: 'ALREADY_FAVORITED', message: '已经收藏过该路线' },
      });
    }

    // 创建收藏记录
    await this.prisma.favorite.create({
      data: {
        userId,
        trailId,
      },
    });

    // 获取最新收藏数
    const favoriteCount = await this.prisma.favorite.count({
      where: { trailId },
    });

    return {
      success: true,
      isFavorited: true,
      favoriteCount,
      message: '收藏成功',
    };
  }

  /**
   * 取消收藏
   */
  async removeFavorite(userId: string, trailId: string) {
    // 检查收藏记录是否存在
    const favorite = await this.prisma.favorite.findUnique({
      where: {
        userId_trailId: {
          userId,
          trailId,
        },
      },
    });

    if (!favorite) {
      throw new NotFoundException({
        success: false,
        error: { code: 'FAVORITE_NOT_FOUND', message: '未找到收藏记录' },
      });
    }

    // 删除收藏记录
    await this.prisma.favorite.delete({
      where: {
        userId_trailId: {
          userId,
          trailId,
        },
      },
    });

    // 获取最新收藏数
    const favoriteCount = await this.prisma.favorite.count({
      where: { trailId },
    });

    return {
      success: true,
      isFavorited: false,
      favoriteCount,
      message: '取消收藏成功',
    };
  }

  /**
   * 切换收藏状态
   * 如果已收藏则取消，未收藏则添加
   */
  async toggleFavorite(userId: string, trailId: string) {
    const favorite = await this.prisma.favorite.findUnique({
      where: {
        userId_trailId: {
          userId,
          trailId,
        },
      },
    });

    if (favorite) {
      return this.removeFavorite(userId, trailId);
    } else {
      return this.addFavorite(userId, trailId);
    }
  }

  /**
   * 获取用户收藏列表
   */
  async getUserFavorites(userId: string, query: FavoriteListQueryDto) {
    const { page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    const [favorites, total] = await Promise.all([
      this.prisma.favorite.findMany({
        where: { userId },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          trail: {
            select: {
              id: true,
              name: true,
              coverImages: true,
              distanceKm: true,
              durationMin: true,
              difficulty: true,
              city: true,
            },
          },
        },
      }),
      this.prisma.favorite.count({
        where: { userId },
      }),
    ]);

    return {
      success: true,
      data: favorites.map((fav) => ({
        id: fav.id,
        trailId: fav.trail.id,
        trailName: fav.trail.name,
        coverImage: fav.trail.coverImages[0] || '',
        distanceKm: fav.trail.distanceKm,
        durationMin: fav.trail.durationMin,
        difficulty: fav.trail.difficulty,
        city: fav.trail.city,
        createdAt: fav.createdAt,
      })),
      meta: {
        page,
        limit,
        total,
        totalPages: Math.ceil(total / limit),
      },
    };
  }

  /**
   * 检查用户是否已收藏指定路线
   */
  async checkFavoriteStatus(userId: string, trailId: string) {
    const favorite = await this.prisma.favorite.findUnique({
      where: {
        userId_trailId: {
          userId,
          trailId,
        },
      },
    });

    const favoriteCount = await this.prisma.favorite.count({
      where: { trailId },
    });

    return {
      success: true,
      isFavorited: !!favorite,
      favoriteCount,
    };
  }

  /**
   * 获取用户的所有收藏路线ID
   */
  async getUserFavoriteTrailIds(userId: string): Promise<string>[] {
    const favorites = await this.prisma.favorite.findMany({
      where: { userId },
      select: { trailId: true },
    });
    return favorites.map((f) => f.trailId);
  }
}
