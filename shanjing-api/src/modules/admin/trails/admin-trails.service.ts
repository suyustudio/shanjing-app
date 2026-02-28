/**
 * 后台管理 - 路线管理服务
 * 
 * 提供路线的增删改查等管理功能
 */

import {
  Injectable,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { CreateTrailDto, UpdateTrailDto, TrailListQueryDto } from './dto/trail-admin.dto';
import { TrailDifficulty } from '@prisma/client';

@Injectable()
export class AdminTrailsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * 创建路线
   */
  async createTrail(dto: CreateTrailDto, adminId: string) {
    // 验证起点坐标
    if (dto.startPointLat < -90 || dto.startPointLat > 90) {
      throw new BadRequestException({
        success: false,
        error: { code: 'INVALID_LATITUDE', message: '纬度范围应为 -90 到 90' },
      });
    }
    if (dto.startPointLng < -180 || dto.startPointLng > 180) {
      throw new BadRequestException({
        success: false,
        error: { code: 'INVALID_LONGITUDE', message: '经度范围应为 -180 到 180' },
      });
    }

    const trail = await this.prisma.trail.create({
      data: {
        name: dto.name,
        description: dto.description || null,
        distanceKm: dto.distanceKm,
        durationMin: dto.durationMin,
        elevationGainM: dto.elevationGainM,
        difficulty: dto.difficulty,
        tags: dto.tags || [],
        coverImages: dto.coverImages || [],
        gpxUrl: dto.gpxUrl || null,
        city: dto.city,
        district: dto.district,
        startPointLat: dto.startPointLat,
        startPointLng: dto.startPointLng,
        startPointAddress: dto.startPointAddress || null,
        safetyInfo: dto.safetyInfo || {},
        boundsNorth: dto.startPointLat + 0.01, // 简化处理，实际应根据GPX计算
        boundsSouth: dto.startPointLat - 0.01,
        boundsEast: dto.startPointLng + 0.01,
        boundsWest: dto.startPointLng - 0.01,
        isActive: true,
        createdBy: adminId,
      },
    });

    return {
      success: true,
      data: trail,
    };
  }

  /**
   * 更新路线
   */
  async updateTrail(trailId: string, dto: UpdateTrailDto) {
    const existingTrail = await this.prisma.trail.findUnique({
      where: { id: trailId },
    });

    if (!existingTrail) {
      throw new NotFoundException({
        success: false,
        error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在' },
      });
    }

    // 验证坐标
    if (dto.startPointLat !== undefined && (dto.startPointLat < -90 || dto.startPointLat > 90)) {
      throw new BadRequestException({
        success: false,
        error: { code: 'INVALID_LATITUDE', message: '纬度范围应为 -90 到 90' },
      });
    }
    if (dto.startPointLng !== undefined && (dto.startPointLng < -180 || dto.startPointLng > 180)) {
      throw new BadRequestException({
        success: false,
        error: { code: 'INVALID_LONGITUDE', message: '经度范围应为 -180 到 180' },
      });
    }

    const updateData: any = {};
    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.description !== undefined) updateData.description = dto.description;
    if (dto.distanceKm !== undefined) updateData.distanceKm = dto.distanceKm;
    if (dto.durationMin !== undefined) updateData.durationMin = dto.durationMin;
    if (dto.elevationGainM !== undefined) updateData.elevationGainM = dto.elevationGainM;
    if (dto.difficulty !== undefined) updateData.difficulty = dto.difficulty;
    if (dto.tags !== undefined) updateData.tags = dto.tags;
    if (dto.coverImages !== undefined) updateData.coverImages = dto.coverImages;
    if (dto.gpxUrl !== undefined) updateData.gpxUrl = dto.gpxUrl;
    if (dto.city !== undefined) updateData.city = dto.city;
    if (dto.district !== undefined) updateData.district = dto.district;
    if (dto.startPointLat !== undefined) updateData.startPointLat = dto.startPointLat;
    if (dto.startPointLng !== undefined) updateData.startPointLng = dto.startPointLng;
    if (dto.startPointAddress !== undefined) updateData.startPointAddress = dto.startPointAddress;
    if (dto.safetyInfo !== undefined) updateData.safetyInfo = dto.safetyInfo;
    if (dto.isActive !== undefined) updateData.isActive = dto.isActive;

    const trail = await this.prisma.trail.update({
      where: { id: trailId },
      data: updateData,
    });

    return {
      success: true,
      data: trail,
    };
  }

  /**
   * 删除路线
   */
  async deleteTrail(trailId: string) {
    const existingTrail = await this.prisma.trail.findUnique({
      where: { id: trailId },
    });

    if (!existingTrail) {
      throw new NotFoundException({
        success: false,
        error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在' },
      });
    }

    // 软删除：将路线标记为下架状态
    await this.prisma.trail.update({
      where: { id: trailId },
      data: { isActive: false },
    });

    return {
      success: true,
      data: { message: '路线已删除' },
    };
  }

  /**
   * 获取路线详情
   */
  async getTrailById(trailId: string) {
    const trail = await this.prisma.trail.findUnique({
      where: { id: trailId },
      include: {
        pois: true,
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
        error: { code: 'TRAIL_NOT_FOUND', message: '路线不存在' },
      });
    }

    return {
      success: true,
      data: {
        ...trail,
        favoriteCount: trail._count.favorites,
      },
    };
  }

  /**
   * 获取路线列表
   */
  async getTrailList(query: TrailListQueryDto) {
    const {
      keyword,
      city,
      difficulty,
      isActive,
      page = 1,
      limit = 20,
    } = query;

    const skip = (page - 1) * limit;

    // 构建查询条件（过滤已软删除的记录）
    const where: any = {
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

    if (difficulty) {
      where.difficulty = difficulty;
    }

    if (isActive !== undefined) {
      where.isActive = isActive;
    }

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
          isActive: true,
          createdAt: true,
          _count: {
            select: {
              favorites: true,
            },
          },
        },
      }),
      this.prisma.trail.count({ where }),
    ]);

    return {
      success: true,
      data: trails.map((trail) => ({
        ...trail,
        favoriteCount: trail._count.favorites,
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
   * 批量上架/下架路线
   */
  async batchUpdateStatus(trailIds: string[], isActive: boolean) {
    await this.prisma.trail.updateMany({
      where: {
        id: {
          in: trailIds,
        },
      },
      data: {
        isActive,
      },
    });

    return {
      success: true,
      data: {
        message: `已${isActive ? '上架' : '下架'} ${trailIds.length} 条路线`,
      },
    };
  }

  /**
   * 获取路线统计信息
   */
  async getTrailStats() {
    const [
      totalTrails,
      activeTrails,
      totalFavorites,
      difficultyStats,
    ] = await Promise.all([
      this.prisma.trail.count(),
      this.prisma.trail.count({ where: { isActive: true } }),
      this.prisma.favorite.count(),
      this.prisma.trail.groupBy({
        by: ['difficulty'],
        _count: {
          id: true,
        },
      }),
    ]);

    return {
      success: true,
      data: {
        totalTrails,
        activeTrails,
        inactiveTrails: totalTrails - activeTrails,
        totalFavorites,
        difficultyDistribution: difficultyStats.map((stat) => ({
          difficulty: stat.difficulty,
          count: stat._count.id,
        })),
      },
    };
  }
}
