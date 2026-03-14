/**
 * 路线模块 DTO
 * 
 * 前端用户使用的路线相关数据传输对象
 */

import { IsOptional, IsString, IsNumber, IsEnum, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { TrailDifficulty } from '@prisma/client';

/**
 * 路线列表查询 DTO
 */
export class TrailListQueryDto {
  @ApiPropertyOptional({ description: '搜索关键词（路线名称）' })
  @IsOptional()
  @IsString()
  keyword?: string;

  @ApiPropertyOptional({ description: '城市' })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({ description: '区域/区县' })
  @IsOptional()
  @IsString()
  district?: string;

  @ApiPropertyOptional({ 
    description: '难度级别', 
    enum: TrailDifficulty,
    enumName: 'TrailDifficulty'
  })
  @IsOptional()
  @IsEnum(TrailDifficulty)
  difficulty?: TrailDifficulty;

  @ApiPropertyOptional({ description: '标签筛选' })
  @IsOptional()
  @IsString()
  tag?: string;

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: '每页数量', default: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

/**
 * 路线详情响应 DTO
 */
export class TrailDetailResponseDto {
  @ApiProperty({ description: '路线ID' })
  id: string;

  @ApiProperty({ description: '路线名称' })
  name: string;

  @ApiPropertyOptional({ description: '路线描述' })
  description?: string;

  @ApiProperty({ description: '距离（公里）' })
  distanceKm: number;

  @ApiProperty({ description: '预计用时（分钟）' })
  durationMin: number;

  @ApiProperty({ description: '海拔爬升（米）' })
  elevationGainM: number;

  @ApiProperty({ description: '难度级别', enum: TrailDifficulty })
  difficulty: TrailDifficulty;

  @ApiProperty({ description: '标签列表' })
  tags: string[];

  @ApiProperty({ description: '封面图片列表' })
  coverImages: string[];

  @ApiPropertyOptional({ description: 'GPX文件URL' })
  gpxUrl?: string;

  @ApiProperty({ description: '城市' })
  city: string;

  @ApiProperty({ description: '区域' })
  district: string;

  @ApiProperty({ description: '起点纬度' })
  startPointLat: number;

  @ApiProperty({ description: '起点经度' })
  startPointLng: number;

  @ApiPropertyOptional({ description: '起点地址' })
  startPointAddress?: string;

  @ApiPropertyOptional({ description: '安全信息' })
  safetyInfo?: any;

  @ApiProperty({ description: '收藏数' })
  favoriteCount: number;

  @ApiProperty({ description: '是否已收藏（当前用户）' })
  isFavorited: boolean;

  @ApiProperty({ description: 'POI点列表' })
  pois: TrailPoiDto[];

  @ApiProperty({ description: '创建时间' })
  createdAt: Date;
}

/**
 * 路线 POI DTO
 */
export class TrailPoiDto {
  @ApiProperty({ description: 'POI ID' })
  id: string;

  @ApiProperty({ description: 'POI名称' })
  name: string;

  @ApiPropertyOptional({ description: 'POI描述' })
  description?: string;

  @ApiProperty({ description: '纬度' })
  lat: number;

  @ApiProperty({ description: '经度' })
  lng: number;

  @ApiProperty({ description: 'POI类型' })
  type: string;

  @ApiProperty({ description: '排序顺序' })
  order: number;
}

/**
 * 路线列表项 DTO
 */
export class TrailListItemDto {
  @ApiProperty({ description: '路线ID' })
  id: string;

  @ApiProperty({ description: '路线名称' })
  name: string;

  @ApiProperty({ description: '距离（公里）' })
  distanceKm: number;

  @ApiProperty({ description: '预计用时（分钟）' })
  durationMin: number;

  @ApiProperty({ description: '难度级别', enum: TrailDifficulty })
  difficulty: TrailDifficulty;

  @ApiProperty({ description: '城市' })
  city: string;

  @ApiProperty({ description: '区域' })
  district: string;

  @ApiProperty({ description: '封面图片' })
  coverImages: string[];

  @ApiProperty({ description: '收藏数' })
  favoriteCount: number;

  @ApiProperty({ description: '是否已收藏（当前用户）' })
  isFavorited: boolean;
}

/**
 * 路线列表响应 DTO
 */
export class TrailListResponseDto {
  @ApiProperty({ description: '路线列表', type: [TrailListItemDto] })
  data: TrailListItemDto[];

  @ApiProperty({ description: '分页信息' })
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

/**
 * 附近路线查询 DTO
 */
export class NearbyTrailsQueryDto {
  @ApiProperty({ description: '纬度' })
  @IsNumber()
  @Min(-90)
  @Max(90)
  lat: number;

  @ApiProperty({ description: '经度' })
  @IsNumber()
  @Min(-180)
  @Max(180)
  lng: number;

  @ApiPropertyOptional({ description: '搜索半径（公里）', default: 10 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  radius?: number = 10;

  @ApiPropertyOptional({ description: '数量限制', default: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(50)
  limit?: number = 20;
}

/**
 * 推荐路线响应 DTO
 */
export class RecommendedTrailsResponseDto {
  @ApiProperty({ description: '推荐路线列表', type: [TrailListItemDto] })
  data: TrailListItemDto[];
}
