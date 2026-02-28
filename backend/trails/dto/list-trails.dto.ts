// list-trails.dto.ts - 路线列表请求DTO
// 山径APP - 路线数据 API

import { IsOptional, IsInt, IsEnum, IsString, IsNumber, Min, Max, IsArray } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';
import { Difficulty } from '@prisma/client';

/**
 * 排序方式枚举
 */
export enum TrailSortBy {
  RECOMMENDED = 'recommended',  // 推荐
  DISTANCE = 'distance',        // 距离
  POPULARITY = 'popularity',    // 热度
}

/**
 * 获取路线列表请求DTO
 */
export class ListTrailsDto {
  @ApiPropertyOptional({ description: '页码，默认1', minimum: 1, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: '每页数量，默认20，最大100', minimum: 1, maximum: 100, example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({ description: '难度筛选', enum: Difficulty, example: Difficulty.MODERATE })
  @IsOptional()
  @IsEnum(Difficulty)
  difficulty?: Difficulty;

  @ApiPropertyOptional({ description: '最短时长（分钟）', minimum: 0, example: 60 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  minDuration?: number;

  @ApiPropertyOptional({ description: '最长时长（分钟）', minimum: 0, example: 300 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  maxDuration?: number;

  @ApiPropertyOptional({ description: '最短距离（公里）', minimum: 0, example: 5 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  minDistance?: number;

  @ApiPropertyOptional({ description: '最长距离（公里）', minimum: 0, example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  @Min(0)
  maxDistance?: number;

  @ApiPropertyOptional({ description: '标签筛选，多个标签', type: [String], example: ['森林', '瀑布'] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ description: '城市筛选', example: '杭州' })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({ description: '排序方式', enum: TrailSortBy, default: TrailSortBy.RECOMMENDED })
  @IsOptional()
  @IsEnum(TrailSortBy)
  sortBy?: TrailSortBy = TrailSortBy.RECOMMENDED;

  @ApiPropertyOptional({ description: '排序顺序', enum: ['asc', 'desc'], default: 'desc' })
  @IsOptional()
  sortOrder?: 'asc' | 'desc' = 'desc';

  @ApiPropertyOptional({ description: '当前纬度（用于距离排序）', example: 30.2741 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  lat?: number;

  @ApiPropertyOptional({ description: '当前经度（用于距离排序）', example: 120.1551 })
  @IsOptional()
  @Type(() => Number)
  @IsNumber()
  lng?: number;
}

/**
 * 搜索路线请求DTO
 */
export class SearchTrailsDto {
  @ApiPropertyOptional({ description: '搜索关键字', example: '西湖' })
  @IsOptional()
  @IsString()
  keyword?: string;

  @ApiPropertyOptional({ description: '页码，默认1', minimum: 1, example: 1 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: '每页数量，默认20，最大100', minimum: 1, maximum: 100, example: 20 })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @ApiPropertyOptional({ description: '排序方式', enum: TrailSortBy, default: TrailSortBy.RECOMMENDED })
  @IsOptional()
  @IsEnum(TrailSortBy)
  sortBy?: TrailSortBy = TrailSortBy.RECOMMENDED;

  @ApiPropertyOptional({ description: '排序顺序', enum: ['asc', 'desc'], default: 'desc' })
  @IsOptional()
  sortOrder?: 'asc' | 'desc' = 'desc';
}
