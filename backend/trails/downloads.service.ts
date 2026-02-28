// downloads.service.ts - 下载服务
// 山径APP - 路线数据 API
// 功能：记录下载行为、获取下载历史

import { Injectable, NotFoundException, Logger } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { ListDownloadsDto } from './dto/list-favorites.dto';
import {
  DownloadActionResponseDto,
  DownloadListResponseDto,
  DownloadRecordDto,
} from './dto/download-response.dto';

/**
 * 下载服务
 *
 * 处理离线包下载相关的业务逻辑：
 * - 记录下载行为
 * - 获取用户下载历史
 */
@Injectable()
export class DownloadsService {
  private readonly logger = new Logger(DownloadsService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * 记录路线离线包下载
   *
   * @param userId - 用户ID
   * @param trailId - 路线ID
   * @param deviceId - 设备标识（可选）
   * @returns 下载记录
   */
  async recordDownload(
    userId: string,
    trailId: string,
    deviceId?: string,
  ): Promise<DownloadActionResponseDto> {
    this.logger.debug(`User ${userId} downloading trail ${trailId}, device: ${deviceId}`);

    // 检查路线是否存在且已发布
    const trail = await this.prisma.trail.findUnique({
      where: { id: trailId, isPublished: true },
      include: {
        offlinePackages: {
          where: {
            expiresAt: {
              gt: new Date(),
            },
          },
          orderBy: {
            createdAt: 'desc',
          },
          take: 1,
        },
      },
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

    // 检查是否有可用的离线包
    if (trail.offlinePackages.length === 0) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'OFFLINE_PACKAGE_NOT_FOUND',
          message: '该路线暂无可用离线包',
        },
      });
    }

    const offlinePackage = trail.offlinePackages[0];

    // 创建下载记录
    const downloadRecord = await this.prisma.trailDownload.create({
      data: {
        userId,
        trailId,
        offlinePackageId: offlinePackage.id,
        deviceId,
        downloadedAt: new Date(),
      },
    });

    this.logger.debug(`Download recorded: ${downloadRecord.id}`);

    return {
      success: true,
      data: {
        id: downloadRecord.id,
        trailId,
        offlinePackage: {
          id: offlinePackage.id,
          version: offlinePackage.version,
          fileUrl: offlinePackage.fileUrl,
          fileSizeMb: offlinePackage.fileSizeMb,
          checksum: offlinePackage.checksum,
          minZoom: offlinePackage.minZoom,
          maxZoom: offlinePackage.maxZoom,
          bounds: {
            north: offlinePackage.boundsNorth,
            south: offlinePackage.boundsSouth,
            east: offlinePackage.boundsEast,
            west: offlinePackage.boundsWest,
          },
          expiresAt: offlinePackage.expiresAt.toISOString(),
        },
        downloadedAt: downloadRecord.downloadedAt.toISOString(),
      },
    };
  }

  /**
   * 获取用户下载历史
   *
   * @param userId - 用户ID
   * @param dto - 查询参数
   * @returns 下载历史列表
   */
  async getUserDownloads(userId: string, dto: ListDownloadsDto): Promise<DownloadListResponseDto> {
    this.logger.debug(`Getting downloads for user ${userId} with filters: ${JSON.stringify(dto)}`);

    const { page, limit } = dto;
    const skip = (page - 1) * limit;

    // 执行查询
    const [downloads, total] = await Promise.all([
      this.prisma.trailDownload.findMany({
        where: { userId },
        skip,
        take: limit,
        orderBy: { downloadedAt: 'desc' },
        include: {
          trail: {
            select: {
              id: true,
              name: true,
            },
          },
          offlinePackage: {
            select: {
              id: true,
              version: true,
              fileUrl: true,
              fileSizeMb: true,
              checksum: true,
            },
          },
        },
      }),
      this.prisma.trailDownload.count({ where: { userId } }),
    ]);

    // 计算总页数
    const totalPages = Math.ceil(total / limit);

    // 转换数据格式
    const items: DownloadRecordDto[] = downloads.map((download) => ({
      id: download.id,
      trailId: download.trail.id,
      trailName: download.trail.name,
      offlinePackageId: download.offlinePackage.id,
      version: download.offlinePackage.version,
      fileUrl: download.offlinePackage.fileUrl,
      fileSizeMb: download.offlinePackage.fileSizeMb,
      checksum: download.offlinePackage.checksum,
      downloadedAt: download.downloadedAt.toISOString(),
      deviceId: download.deviceId || undefined,
    }));

    this.logger.debug(`Found ${items.length} downloads for user ${userId}, total: ${total}`);

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
}
