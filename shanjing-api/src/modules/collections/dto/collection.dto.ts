// ================================================================
// M6: 收藏夹系统 DTO
// ================================================================

import { IsString, IsOptional, IsBoolean, IsArray, Length, MaxLength } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

// ==================== 创建收藏夹 ====================
export class CreateCollectionDto {
  @ApiProperty({ description: '收藏夹名称 (1-50字)', example: '周末徒步路线' })
  @IsString()
  @Length(1, 50)
  name: string;

  @ApiPropertyOptional({ description: '收藏夹描述 (0-200字)', example: '适合周末短途徒步的路线合集' })
  @IsString()
  @IsOptional()
  @MaxLength(200)
  description?: string;

  @ApiPropertyOptional({ description: '封面图片URL' })
  @IsString()
  @IsOptional()
  coverUrl?: string;

  @ApiPropertyOptional({ description: '是否公开', default: true })
  @IsBoolean()
  @IsOptional()
  isPublic?: boolean = true;
}

// ==================== 更新收藏夹 ====================
export class UpdateCollectionDto {
  @ApiPropertyOptional({ description: '收藏夹名称 (1-50字)' })
  @IsString()
  @IsOptional()
  @Length(1, 50)
  name?: string;

  @ApiPropertyOptional({ description: '收藏夹描述 (0-200字)' })
  @IsString()
  @IsOptional()
  @MaxLength(200)
  description?: string;

  @ApiPropertyOptional({ description: '封面图片URL' })
  @IsString()
  @IsOptional()
  coverUrl?: string;

  @ApiPropertyOptional({ description: '是否公开' })
  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;

  @ApiPropertyOptional({ description: '排序权重', example: 0 })
  @IsOptional()
  sortOrder?: number;
}

// ==================== 添加路线到收藏夹 ====================
export class AddTrailToCollectionDto {
  @ApiProperty({ description: '路线ID' })
  @IsString()
  trailId: string;

  @ApiPropertyOptional({ description: '备注 (0-100字)', example: '秋天去会很美' })
  @IsString()
  @IsOptional()
  @MaxLength(100)
  note?: string;
}

// ==================== 批量添加路线 ====================
export class BatchAddTrailsDto {
  @ApiProperty({ description: '路线ID列表', type: [String], example: ['trail1', 'trail2'] })
  @IsArray()
  trailIds: string[];
}

// ==================== 查询参数 ====================
export class QueryCollectionsDto {
  @ApiPropertyOptional({ description: '用户ID (不填则查询当前用户)' })
  @IsString()
  @IsOptional()
  userId?: string;

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  page?: number = 1;

  @ApiPropertyOptional({ description: '每页数量', default: 20 })
  @IsOptional()
  limit?: number = 20;
}

// ==================== 响应 DTO ====================
export class CollectionUserDto {
  id: string;
  nickname: string | null;
  avatarUrl: string | null;
}

export class CollectionTrailDto {
  id: string;
  trailId: string;
  trail: {
    id: string;
    name: string;
    coverImages: string[];
    distanceKm: number;
    durationMin: number;
    difficulty: string;
    avgRating: number | null;
    reviewCount: number;
  };
  note: string | null;
  createdAt: Date;
}

export class CollectionDto {
  id: string;
  name: string;
  description: string | null;
  coverUrl: string | null;
  isPublic: boolean;
  sortOrder: number;
  trailCount: number;
  createdAt: Date;
  updatedAt: Date;
  user: CollectionUserDto;
}

export class CollectionDetailDto extends CollectionDto {
  trails: CollectionTrailDto[];
}

export class CollectionListResponseDto {
  list: CollectionDto[];
  total: number;
  page: number;
  limit: number;
}
