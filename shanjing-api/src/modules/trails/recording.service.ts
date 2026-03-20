/**
 * 轨迹录制服务
 * 
 * 处理轨迹录制数据的存储、处理和审核
 */

import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { TrailDifficulty } from '@prisma/client';
import {
  UploadRecordingDto,
  RecordingListQueryDto,
  ApproveRecordingDto,
} from './dto/recording.dto';

@Injectable()
export class RecordingService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * 上传轨迹录制数据
   */
  async uploadRecording(dto: UploadRecordingDto, userId: string) {
    // 验证轨迹数据
    if (!dto.trackData || !dto.trackData.trackPoints || dto.trackData.trackPoints.length < 2) {
      throw new BadRequestException({
        success: false,
        error: { code: 'INVALID_TRACK_DATA', message: '轨迹数据无效，至少需要2个轨迹点' },
      });
    }

    const trackPoints = dto.trackData.trackPoints;
    const pois = dto.trackData.pois || [];

    // 计算轨迹统计数据
    const stats = this.calculateTrackStats(trackPoints);

    // 保存录制记录
    const recording = await this.prisma.trailRecording.create({
      data: {
        userId,
        sessionId: dto.sessionId,
        trailName: dto.trailName,
        description: dto.description,
        city: dto.city,
        district: dto.district,
        difficulty: dto.difficulty as TrailDifficulty,
        tags: dto.tags || [],
        status: 'PENDING', // 待审核状态
        // 轨迹统计
        distanceMeters: stats.distance,
        durationSeconds: dto.trackData.durationSeconds || 0,
        elevationGain: stats.elevationGain,
        elevationLoss: stats.elevationLoss,
        pointCount: trackPoints.length,
        poiCount: pois.length,
        // 原始数据（JSON格式存储）
        trackData: dto.trackData as any,
      },
    });

    return {
      success: true,
      data: {
        recordingId: recording.id,
        trailName: recording.trailName,
        status: recording.status,
        message: '轨迹上传成功，等待审核后发布',
      },
    };
  }

  /**
   * 获取用户的录制记录列表
   */
  async getUserRecordings(userId: string, query: RecordingListQueryDto) {
    const { status, page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    const where: any = { userId };
    if (status) {
      where.status = status.toUpperCase();
    }

    const [recordings, total] = await Promise.all([
      this.prisma.trailRecording.findMany({
        where,
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        select: {
          id: true,
          trailName: true,
          status: true,
          city: true,
          district: true,
          difficulty: true,
          distanceMeters: true,
          durationSeconds: true,
          pointCount: true,
          poiCount: true,
          createdAt: true,
          // 如果有生成正式路线，显示路线ID
          trailId: true,
        },
      }),
      this.prisma.trailRecording.count({ where }),
    ]);

    return {
      success: true,
      data: recordings.map(r => ({
        id: r.id,
        trailName: r.trailName,
        status: r.status,
        city: r.city,
        district: r.district,
        difficulty: r.difficulty,
        distanceKm: (r.distanceMeters / 1000).toFixed(2),
        durationMin: Math.floor(r.durationSeconds / 60),
        pointCount: r.pointCount,
        poiCount: r.poiCount,
        trailId: r.trailId,
        createdAt: r.createdAt,
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
   * 获取录制详情
   */
  async getRecordingDetail(recordingId: string, userId: string) {
    const recording = await this.prisma.trailRecording.findFirst({
      where: {
        id: recordingId,
        userId,
      },
    });

    if (!recording) {
      throw new NotFoundException({
        success: false,
        error: { code: 'RECORDING_NOT_FOUND', message: '录制记录不存在' },
      });
    }

    return {
      success: true,
      data: {
        id: recording.id,
        trailName: recording.trailName,
        description: recording.description,
        status: recording.status,
        city: recording.city,
        district: recording.district,
        difficulty: recording.difficulty,
        tags: recording.tags,
        distanceMeters: recording.distanceMeters,
        durationSeconds: recording.durationSeconds,
        elevationGain: recording.elevationGain,
        elevationLoss: recording.elevationLoss,
        pointCount: recording.pointCount,
        poiCount: recording.poiCount,
        trackData: recording.trackData,
        trailId: recording.trailId,
        reviewComment: recording.reviewComment,
        createdAt: recording.createdAt,
        updatedAt: recording.updatedAt,
      },
    };
  }

  /**
   * 获取待审核的录制记录（管理员）
   */
  async getPendingRecordings(query: RecordingListQueryDto) {
    const { page = 1, limit = 20 } = query;
    const skip = (page - 1) * limit;

    const [recordings, total] = await Promise.all([
      this.prisma.trailRecording.findMany({
        where: { status: 'PENDING' },
        skip,
        take: limit,
        orderBy: { createdAt: 'asc' },
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
      this.prisma.trailRecording.count({ where: { status: 'PENDING' } }),
    ]);

    return {
      success: true,
      data: recordings.map(r => ({
        id: r.id,
        trailName: r.trailName,
        description: r.description,
        city: r.city,
        district: r.district,
        difficulty: r.difficulty,
        distanceMeters: r.distanceMeters,
        durationSeconds: r.durationSeconds,
        pointCount: r.pointCount,
        poiCount: r.poiCount,
        createdAt: r.createdAt,
        user: r.user,
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
   * 审核通过录制记录（管理员）
   */
  async approveRecording(recordingId: string, dto: ApproveRecordingDto) {
    const recording = await this.prisma.trailRecording.findUnique({
      where: { id: recordingId },
    });

    if (!recording) {
      throw new NotFoundException({
        success: false,
        error: { code: 'RECORDING_NOT_FOUND', message: '录制记录不存在' },
      });
    }

    if (recording.status !== 'PENDING') {
      throw new BadRequestException({
        success: false,
        error: { code: 'INVALID_STATUS', message: '该记录已被处理' },
      });
    }

    const trackData = recording.trackData as any;
    const trackPoints = trackData.trackPoints || [];
    const pois = trackData.pois || [];

    // 计算起点和边界
    const bounds = this.calculateBounds(trackPoints);
    const startPoint = trackPoints[0];
    const endPoint = trackPoints[trackPoints.length - 1];

    // 创建正式路线
    const trail = await this.prisma.trail.create({
      data: {
        name: dto.trailName || recording.trailName,
        description: dto.description || recording.description,
        distanceKm: recording.distanceMeters / 1000,
        durationMin: Math.floor(recording.durationSeconds / 60),
        elevationGainM: Math.floor(recording.elevationGain),
        difficulty: (dto.difficulty || recording.difficulty) as TrailDifficulty,
        tags: dto.tags || recording.tags,
        city: recording.city,
        district: recording.district,
        startPointLat: startPoint.latitude,
        startPointLng: startPoint.longitude,
        startPointAddress: dto.startPointAddress,
        coverImages: dto.coverImages || [],
        boundsNorth: bounds.north,
        boundsSouth: bounds.south,
        boundsEast: bounds.east,
        boundsWest: bounds.west,
        isActive: true,
        isPublished: true,
        createdBy: recording.userId,
        // 创建POI
        pois: {
          create: pois.map((poi: any, index: number) => ({
            name: poi.name || poi.type,
            description: poi.description,
            lat: poi.latitude,
            lng: poi.longitude,
            type: poi.type,
            order: index,
          })),
        },
      },
    });

    // 更新录制记录状态
    await this.prisma.trailRecording.update({
      where: { id: recordingId },
      data: {
        status: 'APPROVED',
        trailId: trail.id,
        reviewComment: dto.comment,
        reviewedAt: new Date(),
      },
    });

    return {
      success: true,
      data: {
        recordingId: recording.id,
        trailId: trail.id,
        trailName: trail.name,
        message: '审核通过，路线已发布',
      },
    };
  }

  /**
   * 拒绝录制记录（管理员）
   */
  async rejectRecording(recordingId: string, reason?: string) {
    const recording = await this.prisma.trailRecording.findUnique({
      where: { id: recordingId },
    });

    if (!recording) {
      throw new NotFoundException({
        success: false,
        error: { code: 'RECORDING_NOT_FOUND', message: '录制记录不存在' },
      });
    }

    if (recording.status !== 'PENDING') {
      throw new BadRequestException({
        success: false,
        error: { code: 'INVALID_STATUS', message: '该记录已被处理' },
      });
    }

    await this.prisma.trailRecording.update({
      where: { id: recordingId },
      data: {
        status: 'REJECTED',
        reviewComment: reason,
        reviewedAt: new Date(),
      },
    });

    return {
      success: true,
      data: {
        recordingId: recording.id,
        message: '已拒绝该录制',
        reason,
      },
    };
  }

  // ========== 私有方法 ==========

  /**
   * 计算轨迹统计数据
   */
  private calculateTrackStats(trackPoints: any[]) {
    let distance = 0;
    let elevationGain = 0;
    let elevationLoss = 0;

    for (let i = 1; i < trackPoints.length; i++) {
      const prev = trackPoints[i - 1];
      const curr = trackPoints[i];

      // 计算距离
      distance += this.calculateDistance(
        prev.latitude,
        prev.longitude,
        curr.latitude,
        curr.longitude,
      );

      // 计算海拔变化
      const altDiff = curr.altitude - prev.altitude;
      if (altDiff > 0.5) {
        elevationGain += altDiff;
      } else if (altDiff < -0.5) {
        elevationLoss += Math.abs(altDiff);
      }
    }

    return {
      distance,
      elevationGain,
      elevationLoss,
    };
  }

  /**
   * 计算轨迹边界框
   */
  private calculateBounds(trackPoints: any[]) {
    let north = trackPoints[0].latitude;
    let south = trackPoints[0].latitude;
    let east = trackPoints[0].longitude;
    let west = trackPoints[0].longitude;

    for (const point of trackPoints) {
      if (point.latitude > north) north = point.latitude;
      if (point.latitude < south) south = point.latitude;
      if (point.longitude > east) east = point.longitude;
      if (point.longitude < west) west = point.longitude;
    }

    return { north, south, east, west };
  }

  /**
   * 计算两点间距离（米）
   */
  private calculateDistance(
    lat1: number,
    lng1: number,
    lat2: number,
    lng2: number,
  ): number {
    const R = 6371000; // 地球半径（米）
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
