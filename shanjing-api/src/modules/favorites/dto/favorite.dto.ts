/**
 * 收藏模块 DTO
 * 
 * 用户收藏功能的数据传输对象
 */

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString, IsNumber, Min, Max } from 'class-validator';

/**
 * 收藏列表查询 DTO
 */
export class FavoriteListQueryDto {
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
 * 添加收藏 DTO
 */
export class AddFavoriteDto {
  @ApiProperty({ description: '路线ID' })
  @IsString()
  trailId: string;
}

/**
 * 取消收藏 DTO
 */
export class RemoveFavoriteDto {
  @ApiProperty({ description: '路线ID' })
  @IsString()
  trailId: string;
}

/**
 * 收藏列表项 DTO
 */
export class FavoriteListItemDto {
  @ApiProperty({ description: '收藏ID' })
  id: string;

  @ApiProperty({ description: '路线ID' })
  trailId: string;

  @ApiProperty({ description: '路线名称' })
  trailName: string;

  @ApiProperty({ description: '封面图片' })
  coverImage: string;

  @ApiProperty({ description: '距离（公里）' })
  distanceKm: number;

  @ApiProperty({ description: '预计用时（分钟）' })
  durationMin: number;

  @ApiProperty({ description: '难度级别' })
  difficulty: string;

  @ApiProperty({ description: '城市' })
  city: string;

  @ApiProperty({ description: '收藏时间' })
  createdAt: Date;
}

/**
 * 收藏列表响应 DTO
 */
export class FavoriteListResponseDto {
  @ApiProperty({ description: '收藏列表', type: [FavoriteListItemDto] })
  data: FavoriteListItemDto[];

  @ApiProperty({ description: '分页信息' })
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

/**
 * 收藏状态响应 DTO
 */
export class FavoriteStatusResponseDto {
  @ApiProperty({ description: '是否已收藏' })
  isFavorited: boolean;

  @ApiProperty({ description: '收藏总数' })
  favoriteCount: number;
}

/**
 * 收藏操作响应 DTO
 */
export class FavoriteActionResponseDto {
  @ApiProperty({ description: '操作成功' })
  success: boolean;

  @ApiProperty({ description: '是否已收藏' })
  isFavorited: boolean;

  @ApiProperty({ description: '收藏总数' })
  favoriteCount: number;

  @ApiProperty({ description: '提示消息' })
  message: string;
}
