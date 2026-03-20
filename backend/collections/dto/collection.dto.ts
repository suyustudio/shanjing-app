// collection.dto.ts
// 山径APP - 收藏夹 DTO

import { IsString, IsOptional, IsBoolean, MaxLength, IsNotEmpty, IsArray } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 创建收藏夹请求 DTO
 */
export class CreateCollectionDto {
  @ApiProperty({ description: '收藏夹名称，最多20字', example: '杭州周边必去' })
  @IsString()
  @IsNotEmpty()
  @MaxLength(20)
  name: string;

  @ApiPropertyOptional({ description: '收藏夹描述，最多200字', example: '精选杭州周边最值得去的徒步路线' })
  @IsString()
  @IsOptional()
  @MaxLength(200)
  description?: string;

  @ApiPropertyOptional({ description: '是否公开', default: true })
  @IsBoolean()
  @IsOptional()
  isPublic?: boolean = true;
}

/**
 * 更新收藏夹请求 DTO
 */
export class UpdateCollectionDto {
  @ApiPropertyOptional({ description: '收藏夹名称，最多20字', example: '杭州周边必去' })
  @IsString()
  @IsOptional()
  @MaxLength(20)
  name?: string;

  @ApiPropertyOptional({ description: '收藏夹描述，最多200字', example: '精选杭州周边最值得去的徒步路线' })
  @IsString()
  @IsOptional()
  @MaxLength(200)
  description?: string;

  @ApiPropertyOptional({ description: '是否公开' })
  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;
}

/**
 * 添加路线到收藏夹请求 DTO
 */
export class AddTrailToCollectionDto {
  @ApiProperty({ description: '路线ID', example: 'trail_001' })
  @IsString()
  @IsNotEmpty()
  trailId: string;

  @ApiPropertyOptional({ description: '收藏备注，最多200字', example: '春天去特别美' })
  @IsString()
  @IsOptional()
  @MaxLength(200)
  note?: string;
}

/**
 * 排序路线请求 DTO
 */
export class SortTrailsDto {
  @ApiProperty({ 
    description: '路线ID排序数组', 
    example: ['trail_003', 'trail_001', 'trail_002'],
    type: [String]
  })
  @IsArray()
  @IsString({ each: true })
  trailIds: string[];
}
