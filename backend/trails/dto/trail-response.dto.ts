// trail-response.dto.ts - 路线响应DTO
// 山径APP - 路线数据 API

import { ApiProperty } from '@nestjs/swagger';
import { Difficulty } from '@prisma/client';

/**
 * 位置信息DTO
 */
export class LocationDto {
  @ApiProperty({ description: '城市', example: '杭州' })
  city: string;

  @ApiProperty({ description: '区县', example: '西湖区' })
  district: string;

  @ApiProperty({ description: '详细地址', example: '龙井村入口' })
  address: string;
}

/**
 * 坐标信息DTO
 */
export class CoordinatesDto {
  @ApiProperty({ description: '纬度', example: 30.2741 })
  lat: number;

  @ApiProperty({ description: '经度', example: 120.1551 })
  lng: number;

  @ApiProperty({ description: '海拔（米）', example: 150.5, required: false })
  altitude?: number;
}

/**
 * 边界框DTO
 */
export class BoundsDto {
  @ApiProperty({ description: '北边界', example: 30.2841 })
  north: number;

  @ApiProperty({ description: '南边界', example: 30.2641 })
  south: number;

  @ApiProperty({ description: '东边界', example: 120.1651 })
  east: number;

  @ApiProperty({ description: '西边界', example: 120.1451 })
  west: number;
}

/**
 * 统计信息DTO
 */
export class TrailStatsDto {
  @ApiProperty({ description: '收藏数', example: 128 })
  favoriteCount: number;

  @ApiProperty({ description: '浏览数', example: 1024 })
  viewCount: number;
}

/**
 * 路线列表项DTO
 */
export class TrailListItemDto {
  @ApiProperty({ description: '路线ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  name: string;

  @ApiProperty({ description: '路线描述', example: '经典杭州徒步路线，沿途溪流潺潺...', required: false })
  description?: string;

  @ApiProperty({ description: '距离（公里）', example: 8.5 })
  distanceKm: number;

  @ApiProperty({ description: '预计用时（分钟）', example: 180 })
  durationMin: number;

  @ApiProperty({ description: '累计爬升（米）', example: 350.5 })
  elevationGainM: number;

  @ApiProperty({ description: '难度等级', enum: Difficulty, example: Difficulty.MODERATE })
  difficulty: Difficulty;

  @ApiProperty({ description: '标签数组', example: ['森林', '溪流', '亲子友好'] })
  tags: string[];

  @ApiProperty({ description: '封面图片URL', example: 'https://example.com/images/trail1.jpg', required: false })
  coverImage?: string;

  @ApiProperty({ description: '位置信息', type: LocationDto })
  location: LocationDto;

  @ApiProperty({ description: '起点坐标', type: CoordinatesDto })
  coordinates: CoordinatesDto;

  @ApiProperty({ description: '统计信息', type: TrailStatsDto })
  stats: TrailStatsDto;

  @ApiProperty({ description: '距离用户的距离（公里），仅在提供坐标时返回', example: 5.2, required: false })
  distanceFromUser?: number;

  @ApiProperty({ description: '创建时间', example: '2024-01-15T08:30:00.000Z' })
  createdAt: string;
}

/**
 * 分页信息DTO
 */
export class PaginationDto {
  @ApiProperty({ description: '当前页码', example: 1 })
  page: number;

  @ApiProperty({ description: '每页数量', example: 20 })
  limit: number;

  @ApiProperty({ description: '总记录数', example: 156 })
  total: number;

  @ApiProperty({ description: '总页数', example: 8 })
  totalPages: number;

  @ApiProperty({ description: '是否还有更多', example: true })
  hasMore: boolean;
}

/**
 * 路线列表响应数据DTO
 */
export class TrailListDataDto {
  @ApiProperty({ description: '路线列表', type: [TrailListItemDto] })
  items: TrailListItemDto[];

  @ApiProperty({ description: '分页信息', type: PaginationDto })
  pagination: PaginationDto;
}

/**
 * 路线列表响应DTO
 */
export class TrailListResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据', type: TrailListDataDto })
  data: TrailListDataDto;
}

/**
 * POI信息DTO
 */
export class PoiDto {
  @ApiProperty({ description: 'POI ID', example: 'clq0987654321fedcba' })
  id: string;

  @ApiProperty({ description: 'POI名称', example: '九溪烟树' })
  name: string;

  @ApiProperty({ description: 'POI类型', example: 'navigation' })
  type: string;

  @ApiProperty({ description: '子类型', example: '观景台' })
  subtype: string;

  @ApiProperty({ description: '坐标', type: CoordinatesDto })
  coordinates: CoordinatesDto;

  @ApiProperty({ description: '序号', example: 1 })
  sequence: number;

  @ApiProperty({ description: '描述', example: '著名观景点，可俯瞰整个九溪', required: false })
  description?: string;

  @ApiProperty({ description: '照片URL数组', example: ['https://example.com/poi1.jpg'] })
  photos: string[];

  @ApiProperty({ description: '优先级', example: 8 })
  priority: number;

  @ApiProperty({ description: '扩展信息', example: { hasRestroom: true }, required: false })
  metadata?: Record<string, any>;
}

/**
 * 离线包信息DTO
 */
export class OfflinePackageDto {
  @ApiProperty({ description: '离线包ID', example: 'clqaaaa1111bbbb2222' })
  id: string;

  @ApiProperty({ description: '版本号', example: '1.0.0' })
  version: string;

  @ApiProperty({ description: '文件URL', example: 'https://example.com/packages/trail1.zip' })
  fileUrl: string;

  @ApiProperty({ description: '文件大小（MB）', example: 15.5 })
  fileSizeMb: number;

  @ApiProperty({ description: '文件校验值（SHA-256）', example: 'a1b2c3d4e5f6...' })
  checksum: string;

  @ApiProperty({ description: '最小缩放级别', example: 12 })
  minZoom: number;

  @ApiProperty({ description: '最大缩放级别', example: 18 })
  maxZoom: number;

  @ApiProperty({ description: '边界框', type: BoundsDto })
  bounds: BoundsDto;

  @ApiProperty({ description: '过期时间', example: '2025-01-15T08:30:00.000Z' })
  expiresAt: string;
}

/**
 * 路线详情数据DTO
 */
export class TrailDetailDataDto {
  @ApiProperty({ description: '路线ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  name: string;

  @ApiProperty({ description: '路线描述', example: '经典杭州徒步路线...' })
  description?: string;

  @ApiProperty({ description: '距离（公里）', example: 8.5 })
  distanceKm: number;

  @ApiProperty({ description: '预计用时（分钟）', example: 180 })
  durationMin: number;

  @ApiProperty({ description: '累计爬升（米）', example: 350.5 })
  elevationGainM: number;

  @ApiProperty({ description: '累计下降（米）', example: 350.5 })
  elevationLossM?: number;

  @ApiProperty({ description: '难度等级', enum: Difficulty })
  difficulty: Difficulty;

  @ApiProperty({ description: '标签数组', example: ['森林', '溪流'] })
  tags: string[];

  @ApiProperty({ description: '封面图片URL数组', example: ['https://example.com/1.jpg'] })
  coverImages: string[];

  @ApiProperty({ description: 'GPX文件URL', example: 'https://example.com/trail1.gpx' })
  gpxUrl: string;

  @ApiProperty({ description: '安全信息', example: { femaleFriendly: true } })
  safetyInfo: Record<string, any>;

  @ApiProperty({ description: '位置信息', type: LocationDto })
  location: LocationDto;

  @ApiProperty({ description: '起点坐标', type: CoordinatesDto })
  coordinates: CoordinatesDto;

  @ApiProperty({ description: '边界框', type: BoundsDto })
  bounds: BoundsDto;

  @ApiProperty({ description: '海拔剖面数据', example: [{ distance: 0, elevation: 100 }] })
  elevationProfile?: Array<{ distance: number; elevation: number }>;

  @ApiProperty({ description: '统计信息', type: TrailStatsDto })
  stats: TrailStatsDto;

  @ApiProperty({ description: 'POI列表', type: [PoiDto] })
  pois: PoiDto[];

  @ApiProperty({ description: '离线包列表', type: [OfflinePackageDto] })
  offlinePackages: OfflinePackageDto[];

  @ApiProperty({ description: '创建时间', example: '2024-01-15T08:30:00.000Z' })
  createdAt: string;

  @ApiProperty({ description: '更新时间', example: '2024-01-15T08:30:00.000Z' })
  updatedAt: string;
}

/**
 * 路线详情响应DTO
 */
export class TrailDetailResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据', type: TrailDetailDataDto })
  data: TrailDetailDataDto;
}
