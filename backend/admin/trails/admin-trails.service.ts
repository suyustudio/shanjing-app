// admin-trails.service.ts - 后台管理路线服务
// 山径APP - 后台管理 API
// 功能：管理员创建、更新、删除路线

import { Injectable, NotFoundException, Logger, ConflictException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';
import { CreateTrailDto } from './dto/create-trail.dto';
import { UpdateTrailDto } from './dto/update-trail.dto';
import {
  AdminCreateTrailResponseDto,
  AdminUpdateTrailResponseDto,
  AdminDeleteTrailResponseDto,
} from './dto/admin-trail-response.dto';

/**
 * 后台管理路线服务
 * 
 * 处理管理员路线管理相关的业务逻辑：
 * - 创建路线
 * - 更新路线
 * - 删除路线
 */
@Injectable()
export class AdminTrailsService {
  private readonly logger = new Logger(AdminTrailsService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * 创建路线
   * 
   * @param dto - 创建路线数据
   * @param adminId - 管理员ID
   * @returns 创建结果
   */
  async create(dto: CreateTrailDto, adminId: string): Promise<AdminCreateTrailResponseDto> {
    this.logger.debug(`Creating trail: ${dto.name} by admin: ${adminId}`);

    // 检查路线名称是否已存在
    const existingTrail = await this.prisma.trail.findFirst({
      where: {
        name: {
          equals: dto.name,
          mode: 'insensitive',
        },
      },
    });

    if (existingTrail) {
      throw new ConflictException({
        success: false,
        error: {
          code: 'TRAIL_NAME_EXISTS',
          message: '路线名称已存在',
        },
      });
    }

    // 构建创建数据
    const createData: any = {
      name: dto.name,
      description: dto.description,
      distanceKm: dto.distanceKm,
      durationMin: dto.durationMin,
      elevationGainM: dto.elevationGainM,
      elevationLossM: dto.elevationLossM,
      difficulty: dto.difficulty,
      tags: dto.tags || [],
      coverImages: dto.coverImages || [],
      gpxUrl: dto.gpxUrl,
      city: dto.city,
      district: dto.district,
      startPointAddress: dto.startPointAddress,
      startPointLat: dto.startPoint.lat,
      startPointLng: dto.startPoint.lng,
      boundsNorth: dto.bounds?.north,
      boundsSouth: dto.bounds?.south,
      boundsEast: dto.bounds?.east,
      boundsWest: dto.bounds?.west,
      elevationProfile: dto.elevationProfile || [],
      safetyInfo: dto.safetyInfo || {},
      isPublished: dto.isPublished || false,
      createdBy: adminId,
    };

    // 如果立即发布，设置发布时间
    if (dto.isPublished) {
      createData.publishedAt = new Date();
    }

    // 创建路线
    const trail = await this.prisma.trail.create({
      data: createData,
    });

    this.logger.log(`Trail created: ${trail.id} - ${trail.name}`);

    return {
      success: true,
      message: '路线创建成功',
      data: {
        id: trail.id,
        name: trail.name,
        createdAt: trail.createdAt.toISOString(),
      },
    };
  }

  /**
   * 更新路线
   * 
   * @param id - 路线ID
   * @param dto - 更新路线数据
   * @returns 更新结果
   */
  async update(id: string, dto: UpdateTrailDto): Promise<AdminUpdateTrailResponseDto> {
    this.logger.debug(`Updating trail: ${id}`);

    // 检查路线是否存在
    const existingTrail = await this.prisma.trail.findUnique({
      where: { id },
    });

    if (!existingTrail) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'TRAIL_NOT_FOUND',
          message: '路线不存在',
        },
      });
    }

    // 如果更新名称，检查新名称是否与其他路线冲突
    if (dto.name && dto.name !== existingTrail.name) {
      const nameConflict = await this.prisma.trail.findFirst({
        where: {
          id: { not: id },
          name: {
            equals: dto.name,
            mode: 'insensitive',
          },
        },
      });

      if (nameConflict) {
        throw new ConflictException({
          success: false,
          error: {
            code: 'TRAIL_NAME_EXISTS',
            message: '路线名称已存在',
          },
        });
      }
    }

    // 构建更新数据
    const updateData: any = {};

    if (dto.name !== undefined) updateData.name = dto.name;
    if (dto.description !== undefined) updateData.description = dto.description;
    if (dto.distanceKm !== undefined) updateData.distanceKm = dto.distanceKm;
    if (dto.durationMin !== undefined) updateData.durationMin = dto.durationMin;
    if (dto.elevationGainM !== undefined) updateData.elevationGainM = dto.elevationGainM;
    if (dto.elevationLossM !== undefined) updateData.elevationLossM = dto.elevationLossM;
    if (dto.difficulty !== undefined) updateData.difficulty = dto.difficulty;
    if (dto.tags !== undefined) updateData.tags = dto.tags;
    if (dto.coverImages !== undefined) updateData.coverImages = dto.coverImages;
    if (dto.gpxUrl !== undefined) updateData.gpxUrl = dto.gpxUrl;
    if (dto.city !== undefined) updateData.city = dto.city;
    if (dto.district !== undefined) updateData.district = dto.district;
    if (dto.startPointAddress !== undefined) updateData.startPointAddress = dto.startPointAddress;
    if (dto.safetyInfo !== undefined) updateData.safetyInfo = dto.safetyInfo;
    if (dto.elevationProfile !== undefined) updateData.elevationProfile = dto.elevationProfile;

    // 更新坐标
    if (dto.startPoint) {
      updateData.startPointLat = dto.startPoint.lat;
      updateData.startPointLng = dto.startPoint.lng;
      if (dto.startPoint.altitude !== undefined) {
        // 海拔可以存储在 elevationProfile 的第一个点或单独字段
        // 这里简化处理，暂不单独存储
      }
    }

    // 更新边界框
    if (dto.bounds) {
      updateData.boundsNorth = dto.bounds.north;
      updateData.boundsSouth = dto.bounds.south;
      updateData.boundsEast = dto.bounds.east;
      updateData.boundsWest = dto.bounds.west;
    }

    // 处理发布状态变更
    if (dto.isPublished !== undefined && dto.isPublished !== existingTrail.isPublished) {
      updateData.isPublished = dto.isPublished;
      if (dto.isPublished && !existingTrail.publishedAt) {
        updateData.publishedAt = new Date();
      }
    }

    // 执行更新
    const updatedTrail = await this.prisma.trail.update({
      where: { id },
      data: updateData,
    });

    this.logger.log(`Trail updated: ${updatedTrail.id} - ${updatedTrail.name}`);

    return {
      success: true,
      message: '路线更新成功',
      data: {
        id: updatedTrail.id,
        name: updatedTrail.name,
        updatedAt: updatedTrail.updatedAt.toISOString(),
      },
    };
  }

  /**
   * 删除路线
   * 
   * @param id - 路线ID
   * @returns 删除结果
   */
  async remove(id: string): Promise<AdminDeleteTrailResponseDto> {
    this.logger.debug(`Deleting trail: ${id}`);

    // 检查路线是否存在
    const existingTrail = await this.prisma.trail.findUnique({
      where: { id },
      include: {
        _count: {
          select: {
            favorites: true,
            completions: true,
          },
        },
      },
    });

    if (!existingTrail) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'TRAIL_NOT_FOUND',
          message: '路线不存在',
        },
      });
    }

    // 记录路线信息用于响应
    const trailInfo = {
      id: existingTrail.id,
      name: existingTrail.name,
    };

    // 检查是否有关联数据（收藏、完成记录等）
    const hasRelatedData = 
      existingTrail._count.favorites > 0 || 
      existingTrail._count.completions > 0;

    if (hasRelatedData) {
      this.logger.warn(`Trail ${id} has related data (favorites: ${existingTrail._count.favorites}, completions: ${existingTrail._count.completions}), soft delete may be considered`);
      // 这里可以选择软删除或级联删除，根据业务需求
      // 目前采用硬删除，但记录警告日志
    }

    // 删除路线（Prisma 会自动处理关联的 POI 和离线包，如果设置了 onDelete: Cascade）
    await this.prisma.trail.delete({
      where: { id },
    });

    this.logger.log(`Trail deleted: ${trailInfo.id} - ${trailInfo.name}`);

    return {
      success: true,
      message: '路线删除成功',
      data: {
        id: trailInfo.id,
        name: trailInfo.name,
        deletedAt: new Date().toISOString(),
      },
    };
  }
}
