/**
 * 路线服务
 * 
 * 提供前端用户使用的路线查询服务
 */

import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { TrailListQueryDto, NearbyTrailsQueryDto } from './dto/trail.dto';

@Injectable()
export class TrailsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * 获取路线列表
   * 支持搜索、筛选、分页
   */
  async getTrailList(query: TrailListQueryDto, userId?: string) {
    const {
      keyword,
      city,
      district,
      difficulty,
      tag,
      page = 1,
      limit = 20,
    } = query;

    const skip = (page - 1) * limit;

    // 构建查询条件
    const where: any = {
      isActive: true,
      deletedAt: null,
    };

    if (keyword) {
      where.name = {
        contains: keyword,
        mode: 'insensitive',
      };
    }

    if (city) {
      where.city = city;
    }

    if (district) {
      where.district = district;
    }

    if (difficulty) {
      where.difficulty = difficulty;
    }

    if (tag) {
      where.tags = {
        has: tag,
      };
    }

    // 查询路线列表
    const [trails, total] = await Promise.all([
      this.prisma.trail.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          name: true,
          distanceKm: true,
          durationMin: true,
          difficulty: true,
          city: true,
          district: true,
          coverImages: true,
          _count: {
            select: {
              favorites: true,
            },
          },
        },
      }),
      this.prisma.trail.count({ where }),
    ]);

    // 获取当前用户的收藏状态
    let favoritedTrailIds: Set<string> = new Set();
    if (userId) {
      const favorites = await this.prisma.favorite.findMany({
        where: {
          userId,
          trailId: {
            in: trails.map((t) => t.id),
          },
        },
        select: { trailId: true },
      });
      favoritedTrailIds = new Set(favorites.map((f) => f.trailId));
    }

    return {
      success: true,
      data: trails.map((trail) => ({
        id: trail.id,
        name: trail.name,
        distanceKm: trail.distanceKm,
        durationMin: trail.durationMin,
        difficulty: trail.difficulty,
        city: trail.city,
        district: trail.district,
        coverImages: trail.coverImages,
        favoriteCount: trail._count.favorites,
        isFavorited: favoritedTrailIds.has(trail.id),
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
   * 获取路线详情
   */
  async getTrailById(trailId: string, userId?: string) {
    const trail = await this.prisma.trail.findUnique({
      where: {
        id: trailId,
        isActive: true,
        deletedAt: null,
      },
      include: {
        pois: {
          orderBy: { order: 'asc' },
        },
        _count: {
          select: {
            favorites: true,
          },
        },
      },
    });

    if (!trail) {
      throw new NotFoundException({
        success: false,
        error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在或已下架' },
      });
    }

    // 检查当前用户是否已收藏
    let isFavorited = false;
    if (userId) {
      const favorite = await this.prisma.favorite.findUnique({
        where: {
          userId_trailId: {
            userId,
            trailId,
          },
        },
      });
      isFavorited = !!favorite;
    }

    return {
      success: true,
      data: {
        ...trail,
        favoriteCount: trail._count.favorites,
        isFavorited,
      },
    };
  }

  /**
   * 获取附近路线
   * 基于起点坐标计算距离
   */
  async getNearbyTrails(query: NearbyTrailsQueryDto, userId?: string) {
    const { lat, lng, radius = 10, limit = 20 } = query;

    // 计算边界框（简化计算，实际应使用 PostGIS）
    const latDelta = radius / 111; // 1度纬度约111公里
    const lngDelta = radius / (111 * Math.cos(lat * Math.PI / 180));

    const trails = await this.prisma.trail.findMany({
      where: {
        isActive: true,
        deletedAt: null,
        startPointLat: {
          gte: lat - latDelta,
          lte: lat + latDelta,
        },
        startPointLng: {
          gte: lng - lngDelta,
          lte: lng + lngDelta,
        },
      },
      take: limit,
      select: {
        id: true,
        name: true,
        distanceKm: true,
        durationMin: true,
        difficulty: true,
        city: true,
        district: true,
        coverImages: true,
        startPointLat: true,
        startPointLng: true,
        _count: {
          select: {
            favorites: true,
          },
        },
      },
    });

    // 获取当前用户的收藏状态
    let favoritedTrailIds: Set<string> = new Set();
    if (userId) {
      const favorites = await this.prisma.favorite.findMany({
        where: {
          userId,
          trailId: {
            in: trails.map((t) => t.id),
          },
        },
        select: { trailId: true },
      });
      favoritedTrailIds = new Set(favorites.map((f) => f.trailId));
    }

    // 计算实际距离并排序
    const trailsWithDistance = trails.map((trail) => {
      const distance = this.calculateDistance(
        lat,
        lng,
        trail.startPointLat,
        trail.startPointLng
      );
      return {
        ...trail,
        distanceFromUser: distance,
        favoriteCount: trail._count.favorites,
        isFavorited: favoritedTrailIds.has(trail.id),
      };
    });

    // 过滤并排序
    const filteredTrails = trailsWithDistance
      .filter((t) => t.distanceFromUser <= radius)
      .sort((a, b) => a.distanceFromUser - b.distanceFromUser);

    return {
      success: true,
      data: filteredTrails.slice(0, limit),
    };
  }

  /**
   * 获取推荐路线
   * 基于收藏数和创建时间排序
   */
  async getRecommendedTrails(limit: number = 10, userId?: string) {
    const trails = await this.prisma.trail.findMany({
      where: {
        isActive: true,
        deletedAt: null,
      },
      take: limit,
      orderBy: [
        { favorites: { _count: 'desc' } },
        { createdAt: 'desc' },
      ],
      select: {
        id: true,
        name: true,
        distanceKm: true,
        durationMin: true,
        difficulty: true,
        city: true,
        district: true,
        coverImages: true,
        _count: {
          select: {
            favorites: true,
          },
        },
      },
    });

    // 获取当前用户的收藏状态
    let favoritedTrailIds: Set<string> = new Set();
    if (userId) {
      const favorites = await this.prisma.favorite.findMany({
        where: {
          userId,
          trailId: {
            in: trails.map((t) => t.id),
          },
        },
        select: { trailId: true },
      });
      favoritedTrailIds = new Set(favorites.map((f) => f.trailId));
    }

    return {
      success: true,
      data: trails.map((trail) => ({
        id: trail.id,
        name: trail.name,
        distanceKm: trail.distanceKm,
        durationMin: trail.durationMin,
        difficulty: trail.difficulty,
        city: trail.city,
        district: trail.district,
        coverImages: trail.coverImages,
        favoriteCount: trail._count.favorites,
        isFavorited: favoritedTrailIds.has(trail.id),
      })),
    };
  }

  /**
   * 计算两点间距离（公里）
   * 使用 Haversine 公式
   */
  private calculateDistance(
    lat1: number,
    lng1: number,
    lat2: number,
    lng2: number
  ): number {
    const R = 6371; // 地球半径（公里）
    const dLat = this.toRadians(lat2 - lat1);
    const dLng = this.toRadians(lng2 - lng1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) *
        Math.cos(this.toRadians(lat2)) *
        Math.sin(dLng / 2) *
        Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return R * c;
  }

  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }
}
