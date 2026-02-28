// trails.service.ts - 路线服务
// 山径APP - 路线数据 API
// 功能：路线列表查询、搜索、详情等业务逻辑

import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { Difficulty, Prisma } from '@prisma/client';
import { ListTrailsDto, SearchTrailsDto, TrailSortBy } from './dto/list-trails.dto';
import { TrailListResponseDto, TrailDetailResponseDto, TrailListItemDto } from './dto/trail-response.dto';
import { TrackDataResponseDto, TrackPointDto } from './dto/track-response.dto';

/**
 * 路线服务
 * 
 * 处理路线相关的业务逻辑：
 * - 路线列表查询（支持分页、筛选、排序）
 * - 路线搜索（关键字匹配）
 * - 路线详情获取
 */
@Injectable()
export class TrailsService {
  private readonly logger = new Logger(TrailsService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * 获取路线列表（用户端公开接口）
   * 
   * @param dto - 查询参数
   * @returns 路线列表和分页信息
   */
  async findAllPublic(dto: { page: number; limit: number; city?: string; difficulty?: Difficulty }) {
    const { page, limit, city, difficulty } = dto;
    const skip = (page - 1) * limit;

    // 构建查询条件
    const where: Prisma.TrailWhereInput = {
      isPublished: true,
    };

    // 难度筛选
    if (difficulty) {
      where.difficulty = difficulty;
    }

    // 城市筛选
    if (city) {
      where.city = {
        contains: city,
        mode: 'insensitive',
      };
    }

    // 执行查询
    const [trails, total] = await Promise.all([
      this.prisma.trail.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
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
          startPointAddress: true,
          favoriteCount: true,
          viewCount: true,
          createdAt: true,
        },
      }),
      this.prisma.trail.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limit);

    return {
      success: true,
      data: {
        items: trails.map(trail => ({
          id: trail.id,
          name: trail.name,
          description: trail.description,
          distanceKm: trail.distanceKm,
          durationMin: trail.durationMin,
          elevationGainM: trail.elevationGainM,
          difficulty: trail.difficulty,
          tags: trail.tags,
          coverImage: trail.coverImages[0] || null,
          location: {
            city: trail.city,
            district: trail.district,
            address: trail.startPointAddress,
          },
          stats: {
            favoriteCount: trail.favoriteCount,
            viewCount: trail.viewCount,
          },
          createdAt: trail.createdAt.toISOString(),
        })),
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
   * 获取路线列表
   * 
   * @param dto - 查询参数
   * @returns 路线列表和分页信息
   */
  async findAll(dto: ListTrailsDto): Promise<TrailListResponseDto> {
    this.logger.debug(`Finding trails with filters: ${JSON.stringify(dto)}`);

    const { page, limit, difficulty, minDuration, maxDuration, minDistance, maxDistance, tags, city, sortBy, sortOrder, lat, lng } = dto;
    const skip = (page - 1) * limit;

    // 构建查询条件
    const where: Prisma.TrailWhereInput = {
      isPublished: true,
    };

    // 难度筛选
    if (difficulty) {
      where.difficulty = difficulty;
    }

    // 时长范围筛选
    if (minDuration !== undefined || maxDuration !== undefined) {
      where.durationMin = {};
      if (minDuration !== undefined) {
        where.durationMin.gte = minDuration;
      }
      if (maxDuration !== undefined) {
        where.durationMin.lte = maxDuration;
      }
    }

    // 距离范围筛选
    if (minDistance !== undefined || maxDistance !== undefined) {
      where.distanceKm = {};
      if (minDistance !== undefined) {
        where.distanceKm.gte = minDistance;
      }
      if (maxDistance !== undefined) {
        where.distanceKm.lte = maxDistance;
      }
    }

    // 标签筛选（包含任意一个标签即可）
    if (tags && tags.length > 0) {
      where.tags = {
        hasSome: tags,
      };
    }

    // 城市筛选
    if (city) {
      where.city = {
        contains: city,
        mode: 'insensitive',
      };
    }

    // 构建排序条件
    const orderBy = this.buildOrderBy(sortBy, sortOrder, lat, lng);

    // 执行查询
    const [trails, total] = await Promise.all([
      this.prisma.trail.findMany({
        where,
        skip,
        take: limit,
        orderBy,
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
          startPointLat: true,
          startPointLng: true,
          startPointAddress: true,
          favoriteCount: true,
          viewCount: true,
          createdAt: true,
        },
      }),
      this.prisma.trail.count({ where }),
    ]);

    // 计算总页数
    const totalPages = Math.ceil(total / limit);

    // 转换数据格式
    const items: TrailListItemDto[] = trails.map(trail => ({
      id: trail.id,
      name: trail.name,
      description: trail.description,
      distanceKm: trail.distanceKm,
      durationMin: trail.durationMin,
      elevationGainM: trail.elevationGainM,
      difficulty: trail.difficulty,
      tags: trail.tags,
      coverImage: trail.coverImages[0] || null,
      location: {
        city: trail.city,
        district: trail.district,
        address: trail.startPointAddress,
      },
      coordinates: {
        lat: trail.startPointLat,
        lng: trail.startPointLng,
      },
      stats: {
        favoriteCount: trail.favoriteCount,
        viewCount: trail.viewCount,
      },
      // 如果提供了坐标，计算距离
      distanceFromUser: (lat && lng) 
        ? this.calculateDistance(lat, lng, trail.startPointLat, trail.startPointLng)
        : undefined,
      createdAt: trail.createdAt.toISOString(),
    }));

    this.logger.debug(`Found ${items.length} trails, total: ${total}`);

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
   * 搜索路线
   * 
   * @param dto - 搜索参数
   * @returns 搜索结果和分页信息
   */
  async search(dto: SearchTrailsDto): Promise<TrailListResponseDto> {
    this.logger.debug(`Searching trails with keyword: ${dto.keyword}`);

    const { keyword, page, limit, sortBy, sortOrder } = dto;
    
    if (!keyword) {
      return {
        success: true,
        data: {
          items: [],
          pagination: {
            page,
            limit,
            total: 0,
            totalPages: 0,
            hasMore: false,
          },
        },
      };
    }

    const skip = (page - 1) * limit;

    // 构建搜索条件（路线名称或地点）
    const where: Prisma.TrailWhereInput = {
      isPublished: true,
      OR: [
        {
          name: {
            contains: keyword,
            mode: 'insensitive',
          },
        },
        {
          city: {
            contains: keyword,
            mode: 'insensitive',
          },
        },
        {
          district: {
            contains: keyword,
            mode: 'insensitive',
          },
        },
        {
          startPointAddress: {
            contains: keyword,
            mode: 'insensitive',
          },
        },
        {
          description: {
            contains: keyword,
            mode: 'insensitive',
          },
        },
      ],
    };

    // 构建排序条件
    const orderBy = this.buildOrderBy(sortBy, sortOrder);

    // 执行查询
    const [trails, total] = await Promise.all([
      this.prisma.trail.findMany({
        where,
        skip,
        take: limit,
        orderBy,
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
          startPointLat: true,
          startPointLng: true,
          startPointAddress: true,
          favoriteCount: true,
          viewCount: true,
          createdAt: true,
        },
      }),
      this.prisma.trail.count({ where }),
    ]);

    // 计算总页数
    const totalPages = Math.ceil(total / limit);

    // 转换数据格式
    const items: TrailListItemDto[] = trails.map(trail => ({
      id: trail.id,
      name: trail.name,
      description: trail.description,
      distanceKm: trail.distanceKm,
      durationMin: trail.durationMin,
      elevationGainM: trail.elevationGainM,
      difficulty: trail.difficulty,
      tags: trail.tags,
      coverImage: trail.coverImages[0] || null,
      location: {
        city: trail.city,
        district: trail.district,
        address: trail.startPointAddress,
      },
      coordinates: {
        lat: trail.startPointLat,
        lng: trail.startPointLng,
      },
      stats: {
        favoriteCount: trail.favoriteCount,
        viewCount: trail.viewCount,
      },
      createdAt: trail.createdAt.toISOString(),
    }));

    this.logger.debug(`Found ${items.length} trails matching "${keyword}", total: ${total}`);

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
   * 获取路线详情
   * 
   * @param id - 路线ID
   * @returns 路线详细信息
   */
  async findOne(id: string): Promise<TrailDetailResponseDto> {
    this.logger.debug(`Finding trail detail: ${id}`);

    const trail = await this.prisma.trail.findUnique({
      where: { id, isPublished: true },
      include: {
        pois: {
          orderBy: { sequence: 'asc' },
          select: {
            id: true,
            name: true,
            type: true,
            subtype: true,
            latitude: true,
            longitude: true,
            altitude: true,
            sequence: true,
            description: true,
            photos: true,
            priority: true,
            metadata: true,
          },
        },
        offlinePackages: {
          where: {
            expiresAt: {
              gt: new Date(),
            },
          },
          select: {
            id: true,
            version: true,
            fileUrl: true,
            fileSizeMb: true,
            checksum: true,
            minZoom: true,
            maxZoom: true,
            boundsNorth: true,
            boundsSouth: true,
            boundsEast: true,
            boundsWest: true,
            expiresAt: true,
          },
        },
      },
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

    // 增加浏览数（异步执行，不阻塞响应）
    this.incrementViewCount(id).catch(err => {
      this.logger.error(`Failed to increment view count: ${err.message}`);
    });

    return {
      success: true,
      data: {
        id: trail.id,
        name: trail.name,
        description: trail.description,
        distanceKm: trail.distanceKm,
        durationMin: trail.durationMin,
        elevationGainM: trail.elevationGainM,
        elevationLossM: trail.elevationLossM,
        difficulty: trail.difficulty,
        tags: trail.tags,
        coverImages: trail.coverImages,
        gpxUrl: trail.gpxUrl,
        safetyInfo: trail.safetyInfo as Record<string, any>,
        location: {
          city: trail.city,
          district: trail.district,
          address: trail.startPointAddress,
        },
        coordinates: {
          lat: trail.startPointLat,
          lng: trail.startPointLng,
        },
        bounds: {
          north: trail.boundsNorth,
          south: trail.boundsSouth,
          east: trail.boundsEast,
          west: trail.boundsWest,
        },
        elevationProfile: trail.elevationProfile as Array<{ distance: number; elevation: number }>,
        stats: {
          favoriteCount: trail.favoriteCount,
          viewCount: trail.viewCount,
        },
        pois: trail.pois.map(poi => ({
          id: poi.id,
          name: poi.name,
          type: poi.type,
          subtype: poi.subtype,
          coordinates: {
            lat: poi.latitude,
            lng: poi.longitude,
            altitude: poi.altitude,
          },
          sequence: poi.sequence,
          description: poi.description,
          photos: poi.photos,
          priority: poi.priority,
          metadata: poi.metadata as Record<string, any>,
        })),
        offlinePackages: trail.offlinePackages.map(pkg => ({
          id: pkg.id,
          version: pkg.version,
          fileUrl: pkg.fileUrl,
          fileSizeMb: pkg.fileSizeMb,
          checksum: pkg.checksum,
          minZoom: pkg.minZoom,
          maxZoom: pkg.maxZoom,
          bounds: {
            north: pkg.boundsNorth,
            south: pkg.boundsSouth,
            east: pkg.boundsEast,
            west: pkg.boundsWest,
          },
          expiresAt: pkg.expiresAt.toISOString(),
        })),
        createdAt: trail.createdAt.toISOString(),
        updatedAt: trail.updatedAt.toISOString(),
      },
    };
  }

  /**
   * 构建排序条件
   * 
   * @param sortBy - 排序字段
   * @param sortOrder - 排序顺序
   * @param lat - 当前纬度（用于距离排序）
   * @param lng - 当前经度（用于距离排序）
   * @returns Prisma排序条件
   */
  private buildOrderBy(
    sortBy: TrailSortBy,
    sortOrder: 'asc' | 'desc',
    lat?: number,
    lng?: number,
  ): Prisma.TrailOrderByWithRelationInput {
    switch (sortBy) {
      case TrailSortBy.DISTANCE:
        // 如果提供了坐标，按距离排序（通过计算字段在应用层处理）
        // 这里先按起点纬度近似排序
        if (lat !== undefined && lng !== undefined) {
          // 返回一个近似排序，精确距离在应用层计算
          return { startPointLat: sortOrder };
        }
        // 没有坐标时按距离字段排序
        return { distanceKm: sortOrder };

      case TrailSortBy.POPULARITY:
        // 按热度排序（收藏数 + 浏览数加权）
        return { favoriteCount: sortOrder };

      case TrailSortBy.RECOMMENDED:
      default:
        // 推荐排序：按发布时间倒序 + 热度
        return { publishedAt: 'desc' };
    }
  }

  /**
   * 计算两点之间的距离（Haversine公式）
   * 
   * @param lat1 - 起点纬度
   * @param lng1 - 起点经度
   * @param lat2 - 终点纬度
   * @param lng2 - 终点经度
   * @returns 距离（公里）
   */
  private calculateDistance(lat1: number, lng1: number, lat2: number, lng2: number): number {
    const R = 6371; // 地球半径（公里）
    const dLat = this.toRadians(lat2 - lat1);
    const dLng = this.toRadians(lng2 - lng1);
    const a =
      Math.sin(dLat / 2) * Math.sin(dLat / 2) +
      Math.cos(this.toRadians(lat1)) * Math.cos(this.toRadians(lat2)) *
      Math.sin(dLng / 2) * Math.sin(dLng / 2);
    const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return Math.round(R * c * 10) / 10; // 保留一位小数
  }

  /**
   * 角度转弧度
   */
  private toRadians(degrees: number): number {
    return degrees * (Math.PI / 180);
  }

  /**
   * 增加路线浏览数
   *
   * @param id - 路线ID
   */
  private async incrementViewCount(id: string): Promise<void> {
    await this.prisma.trail.update({
      where: { id },
      data: {
        viewCount: {
          increment: 1,
        },
      },
    });
  }

  /**
   * 获取路线轨迹数据
   *
   * @param id - 路线ID
   * @returns 轨迹点数据
   */
  async getTrack(id: string): Promise<TrackDataResponseDto> {
    this.logger.debug(`Getting track data for trail: ${id}`);

    const trail = await this.prisma.trail.findUnique({
      where: { id, isPublished: true },
      select: {
        id: true,
        name: true,
        distanceKm: true,
        gpxUrl: true,
        elevationProfile: true,
      },
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

    // 从 elevationProfile 解析轨迹点数据
    // elevationProfile 格式: [{ distance: 0, elevation: 100 }, { distance: 0.5, elevation: 150 }]
    const elevationProfile = trail.elevationProfile as Array<{ distance: number; elevation: number }> || [];

    // 生成轨迹点数据（基于海拔剖面数据）
    // 实际项目中，这里应该从GPX文件解析或从TrackPoint表查询
    const points: TrackPointDto[] = elevationProfile.map((point, index) => ({
      lat: 0, // 实际应从GPX解析
      lng: 0, // 实际应从GPX解析
      altitude: point.elevation,
      timestamp: undefined,
    }));

    // 如果没有海拔剖面数据，返回空数组
    if (points.length === 0) {
      this.logger.warn(`No track data available for trail: ${id}`);
    }

    return {
      success: true,
      data: {
        trailId: trail.id,
        trailName: trail.name,
        totalPoints: points.length,
        totalDistanceKm: trail.distanceKm,
        points,
        gpxUrl: trail.gpxUrl,
      },
    };
  }
}
