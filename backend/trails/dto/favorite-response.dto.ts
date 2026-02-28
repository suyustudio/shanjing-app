// favorite-response.dto.ts - 收藏相关响应DTO
// 山径APP - 路线数据 API

import { ApiProperty } from '@nestjs/swagger';
import { Difficulty } from '@prisma/client';

/**
 * 收藏路线信息DTO
 */
export class FavoriteTrailDto {
  @ApiProperty({ description: '收藏记录ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线ID', example: 'clq0987654321fedcba' })
  trailId: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  trailName: string;

  @ApiProperty({ description: '路线描述', example: '经典杭州徒步路线...', required: false })
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

  @ApiProperty({ description: '城市', example: '杭州' })
  city: string;

  @ApiProperty({ description: '区县', example: '西湖区' })
  district: string;

  @ApiProperty({ description: '收藏数', example: 128 })
  favoriteCount: number;

  @ApiProperty({ description: '浏览数', example: 1024 })
  viewCount: number;

  @ApiProperty({ description: '收藏时间', example: '2024-01-15T08:30:00.000Z' })
  createdAt: string;
}

/**
 * 收藏操作响应数据DTO
 */
export class FavoriteActionDataDto {
  @ApiProperty({ description: '路线ID', example: 'clq0987654321fedcba' })
  trailId: string;

  @ApiProperty({ description: '是否已收藏', example: true })
  isFavorited: boolean;

  @ApiProperty({ description: '路线当前收藏总数', example: 129 })
  favoriteCount: number;

  @ApiProperty({ description: '收藏时间（收藏时返回）', example: '2024-01-15T08:30:00.000Z', required: false })
  favoritedAt?: string;
}

/**
 * 收藏操作响应DTO
 */
export class FavoriteActionResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据', type: FavoriteActionDataDto })
  data: FavoriteActionDataDto;
}

/**
 * 收藏列表分页数据DTO
 */
export class FavoriteListDataDto {
  @ApiProperty({ description: '收藏列表', type: [FavoriteTrailDto] })
  items: FavoriteTrailDto[];

  @ApiProperty({ description: '分页信息', type: () => import('./trail-response.dto').then(m => m.PaginationDto) })
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasMore: boolean;
  };
}

/**
 * 收藏列表响应DTO
 */
export class FavoriteListResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据', type: FavoriteListDataDto })
  data: FavoriteListDataDto;
}

/**
 * 检查收藏状态响应DTO
 */
export class FavoriteCheckResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据' })
  data: {
    @ApiProperty({ description: '路线ID', example: 'clq0987654321fedcba' })
    trailId: string;

    @ApiProperty({ description: '是否已收藏', example: true })
    isFavorited: boolean;

    @ApiProperty({ description: '收藏时间', example: '2024-01-15T08:30:00.000Z', required: false })
    favoritedAt?: string;
  };
}
