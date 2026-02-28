// track-response.dto.ts - 轨迹数据响应DTO
// 山径APP - 路线数据 API

import { ApiProperty } from '@nestjs/swagger';

/**
 * 轨迹点DTO
 */
export class TrackPointDto {
  @ApiProperty({ description: '纬度', example: 30.2741 })
  lat: number;

  @ApiProperty({ description: '经度', example: 120.1551 })
  lng: number;

  @ApiProperty({ description: '海拔（米）', example: 150.5, required: false })
  altitude?: number;

  @ApiProperty({ description: '时间戳（ISO 8601）', example: '2024-01-15T08:30:00.000Z', required: false })
  timestamp?: string;
}

/**
 * 轨迹数据响应DTO
 */
export class TrackDataResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据', type: () => TrackDataDto })
  data: TrackDataDto;
}

/**
 * 轨迹数据DTO
 */
export class TrackDataDto {
  @ApiProperty({ description: '路线ID', example: 'clq1234567890abcdef' })
  trailId: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  trailName: string;

  @ApiProperty({ description: '轨迹点总数', example: 156 })
  totalPoints: number;

  @ApiProperty({ description: '轨迹总距离（公里）', example: 8.5 })
  totalDistanceKm: number;

  @ApiProperty({ description: '轨迹点数组', type: [TrackPointDto] })
  points: TrackPointDto[];

  @ApiProperty({ description: 'GPX文件URL', example: 'https://example.com/trail1.gpx' })
  gpxUrl: string;
}

/**
 * GPX格式轨迹响应（XML格式）
 * 用于直接返回GPX文件内容
 */
export class GpxTrackResponseDto {
  @ApiProperty({ description: 'GPX XML内容', example: '<?xml version="1.0"?>...' })
  gpx: string;
}
