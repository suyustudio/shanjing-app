// list-favorites.dto.ts - 收藏列表请求DTO
// 山径APP - 路线数据 API

import { IsOptional, IsInt, Min, Max, IsEnum, IsString } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 收藏排序方式枚举
 */
export enum FavoriteSortBy {
  NEWEST = 'newest',        // 最新收藏
  OLDEST = 'oldest',        // 最早收藏
  NAME = 'name',            // 路线名称
  DISTANCE = 'distance',    // 距离
  DURATION = 'duration',    // 时长
}

/**
 * 获取用户收藏列表请求DTO
 */
export class ListFavoritesDto {
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

  @ApiPropertyOptional({ description: '排序方式', enum: FavoriteSortBy, default: FavoriteSortBy.NEWEST })
  @IsOptional()
  @IsEnum(FavoriteSortBy)
  sortBy?: FavoriteSortBy = FavoriteSortBy.NEWEST;

  @ApiPropertyOptional({ description: '排序顺序', enum: ['asc', 'desc'], default: 'desc' })
  @IsOptional()
  sortOrder?: 'asc' | 'desc' = 'desc';

  @ApiPropertyOptional({ description: '城市筛选', example: '杭州' })
  @IsOptional()
  @IsString()
  city?: string;
}

/**
 * 获取下载历史列表请求DTO
 */
export class ListDownloadsDto {
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
}
