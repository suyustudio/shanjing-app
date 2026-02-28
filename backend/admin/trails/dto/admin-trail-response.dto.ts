// admin-trail-response.dto.ts - 后台管理路线响应DTO
// 山径APP - 后台管理 API

import { ApiProperty } from '@nestjs/swagger';
import { Difficulty } from '@prisma/client';

/**
 * 后台管理路线列表项DTO
 */
export class AdminTrailListItemDto {
  @ApiProperty({ description: '路线ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  name: string;

  @ApiProperty({ description: '距离（公里）', example: 8.5 })
  distanceKm: number;

  @ApiProperty({ description: '预计用时（分钟）', example: 180 })
  durationMin: number;

  @ApiProperty({ description: '累计爬升（米）', example: 350.5 })
  elevationGainM: number;

  @ApiProperty({ description: '难度等级', enum: Difficulty })
  difficulty: Difficulty;

  @ApiProperty({ description: '标签数组', example: ['森林', '溪流'] })
  tags: string[];

  @ApiProperty({ description: '封面图片URL', example: 'https://example.com/images/trail1.jpg', required: false })
  coverImage?: string;

  @ApiProperty({ description: '城市', example: '杭州' })
  city: string;

  @ApiProperty({ description: '区县', example: '西湖区' })
  district: string;

  @ApiProperty({ description: '是否已发布', example: true })
  isPublished: boolean;

  @ApiProperty({ description: '收藏数', example: 128 })
  favoriteCount: number;

  @ApiProperty({ description: '浏览数', example: 1024 })
  viewCount: number;

  @ApiProperty({ description: '创建时间', example: '2024-01-15T08:30:00.000Z' })
  createdAt: string;

  @ApiProperty({ description: '更新时间', example: '2024-01-15T10:30:00.000Z' })
  updatedAt: string;
}

/**
 * 后台管理路线详情DTO
 */
export class AdminTrailDetailDto extends AdminTrailListItemDto {
  @ApiProperty({ description: '路线描述', example: '经典杭州徒步路线...' })
  description?: string;

  @ApiProperty({ description: '封面图片URL数组', example: ['https://example.com/1.jpg'] })
  coverImages: string[];

  @ApiProperty({ description: 'GPX文件URL', example: 'https://example.com/trail1.gpx' })
  gpxUrl?: string;

  @ApiProperty({ description: '起点地址', example: '龙井村入口' })
  startPointAddress: string;

  @ApiProperty({ description: '起点纬度', example: 30.2741 })
  startPointLat: number;

  @ApiProperty({ description: '起点经度', example: 120.1551 })
  startPointLng: number;

  @ApiProperty({ description: '累计下降（米）', example: 350.5 })
  elevationLossM?: number;

  @ApiProperty({ description: '边界框', example: { north: 30.2841, south: 30.2641, east: 120.1651, west: 120.1451 } })
  bounds?: {
    north: number;
    south: number;
    east: number;
    west: number;
  };

  @ApiProperty({ description: '海拔剖面数据', example: [{ distance: 0, elevation: 100 }] })
  elevationProfile?: Array<{ distance: number; elevation: number }>;

  @ApiProperty({ description: '安全信息', example: { femaleFriendly: true } })
  safetyInfo?: Record<string, any>;

  @ApiProperty({ description: '发布时间', example: '2024-01-15T09:00:00.000Z', required: false })
  publishedAt?: string;
}

/**
 * 创建路线响应数据DTO
 */
export class CreateTrailDataDto {
  @ApiProperty({ description: '路线ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  name: string;

  @ApiProperty({ description: '创建时间', example: '2024-01-15T08:30:00.000Z' })
  createdAt: string;
}

/**
 * 更新路线响应数据DTO
 */
export class UpdateTrailDataDto {
  @ApiProperty({ description: '路线ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  name: string;

  @ApiProperty({ description: '更新时间', example: '2024-01-15T10:30:00.000Z' })
  updatedAt: string;
}

/**
 * 删除路线响应数据DTO
 */
export class DeleteTrailDataDto {
  @ApiProperty({ description: '路线ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  name: string;

  @ApiProperty({ description: '删除时间', example: '2024-01-15T12:00:00.000Z' })
  deletedAt: string;
}

/**
 * 后台管理路线创建响应DTO
 */
export class AdminCreateTrailResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应消息', example: '路线创建成功' })
  message: string;

  @ApiProperty({ description: '响应数据', type: CreateTrailDataDto })
  data: CreateTrailDataDto;
}

/**
 * 后台管理路线更新响应DTO
 */
export class AdminUpdateTrailResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应消息', example: '路线更新成功' })
  message: string;

  @ApiProperty({ description: '响应数据', type: UpdateTrailDataDto })
  data: UpdateTrailDataDto;
}

/**
 * 后台管理路线删除响应DTO
 */
export class AdminDeleteTrailResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应消息', example: '路线删除成功' })
  message: string;

  @ApiProperty({ description: '响应数据', type: DeleteTrailDataDto })
  data: DeleteTrailDataDto;
}

/**
 * 后台管理路线详情响应DTO
 */
export class AdminTrailDetailResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据', type: AdminTrailDetailDto })
  data: AdminTrailDetailDto;
}
