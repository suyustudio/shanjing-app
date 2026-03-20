// collection-response.dto.ts
// 山径APP - 收藏夹响应 DTO

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 收藏夹基础信息 DTO
 */
export class CollectionDto {
  @ApiProperty({ description: '收藏夹ID' })
  id: string;

  @ApiProperty({ description: '收藏夹名称' })
  name: string;

  @ApiPropertyOptional({ description: '收藏夹描述' })
  description?: string;

  @ApiPropertyOptional({ description: '封面图片URL' })
  coverUrl?: string;

  @ApiProperty({ description: '路线数量' })
  trailCount: number;

  @ApiProperty({ description: '是否公开' })
  isPublic: boolean;

  @ApiProperty({ description: '是否默认收藏夹' })
  isDefault: boolean;

  @ApiProperty({ description: '排序顺序' })
  sortOrder: number;

  @ApiProperty({ description: '创建时间' })
  createdAt: string;

  @ApiProperty({ description: '更新时间' })
  updatedAt: string;
}

/**
 * 收藏夹中的路线信息 DTO
 */
export class CollectionTrailDto {
  @ApiProperty({ description: '关联ID' })
  id: string;

  @ApiProperty({ description: '路线ID' })
  trailId: string;

  @ApiProperty({ description: '路线名称' })
  name: string;

  @ApiPropertyOptional({ description: '路线封面图' })
  coverImage?: string;

  @ApiProperty({ description: '距离(公里)' })
  distanceKm: number;

  @ApiProperty({ description: '时长(分钟)' })
  durationMin: number;

  @ApiProperty({ description: '难度' })
  difficulty: string;

  @ApiPropertyOptional({ description: '评分' })
  rating?: number;

  @ApiPropertyOptional({ description: '评价数量' })
  reviewCount?: number;

  @ApiPropertyOptional({ description: '收藏备注' })
  note?: string;

  @ApiProperty({ description: '添加时间' })
  addedAt: string;

  @ApiProperty({ description: '排序顺序' })
  sortOrder: number;
}

/**
 * 用户信息 DTO
 */
export class CollectionUserDto {
  @ApiProperty({ description: '用户ID' })
  id: string;

  @ApiProperty({ description: '昵称' })
  nickname: string;

  @ApiPropertyOptional({ description: '头像URL' })
  avatar?: string;
}

/**
 * 分页信息 DTO
 */
export class PaginationMetaDto {
  @ApiProperty({ description: '当前页码' })
  page: number;

  @ApiProperty({ description: '每页数量' })
  limit: number;

  @ApiProperty({ description: '总数量' })
  total: number;

  @ApiProperty({ description: '总页数' })
  totalPages: number;

  @ApiProperty({ description: '是否有更多' })
  hasMore: boolean;
}

/**
 * 收藏夹列表响应 DTO
 */
export class CollectionListResponseDto {
  @ApiProperty({ description: '是否成功' })
  success: boolean;

  @ApiProperty({ description: '收藏夹列表', type: [CollectionDto] })
  data: CollectionDto[];
}

/**
 * 单个收藏夹响应 DTO
 */
export class CollectionResponseDto {
  @ApiProperty({ description: '是否成功' })
  success: boolean;

  @ApiProperty({ description: '收藏夹信息' })
  data: CollectionDto;
}

/**
 * 收藏夹详情响应 DTO
 */
export class CollectionDetailResponseDto {
  @ApiProperty({ description: '是否成功' })
  success: boolean;

  @ApiProperty({
    description: '收藏夹详情',
    type: 'object',
    additionalProperties: true,
  })
  data: {
    id: string;
    name: string;
    description?: string;
    coverUrl?: string;
    user: CollectionUserDto;
    trailCount: number;
    isPublic: boolean;
    isOwner: boolean;
    createdAt: string;
    updatedAt: string;
    trails: CollectionTrailDto[];
  };

  @ApiPropertyOptional({ description: '分页信息' })
  meta?: PaginationMetaDto;
}

/**
 * 收藏夹操作响应 DTO
 */
export class CollectionActionResponseDto {
  @ApiProperty({ description: '是否成功' })
  success: boolean;

  @ApiProperty({ description: '操作结果数据', type: 'object', additionalProperties: true })
  data: Record<string, any>;
}
