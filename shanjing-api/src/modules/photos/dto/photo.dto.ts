// ================================================================
// M6: 照片系统 DTO
// ================================================================

import { IsString, IsNumber, IsOptional, IsArray, IsBoolean, Min, Max, Length, ArrayMaxSize } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

// ==================== 创建照片 ====================
export class CreatePhotoDto {
  @ApiProperty({ description: '照片URL', example: 'https://cdn.example.com/photo1.jpg' })
  @IsString()
  url: string;

  @ApiPropertyOptional({ description: '缩略图URL', example: 'https://cdn.example.com/photo1_thumb.jpg' })
  @IsString()
  @IsOptional()
  thumbnailUrl?: string;

  @ApiPropertyOptional({ description: '路线ID' })
  @IsString()
  @IsOptional()
  trailId?: string;

  @ApiPropertyOptional({ description: 'POI ID' })
  @IsString()
  @IsOptional()
  poiId?: string;

  @ApiPropertyOptional({ description: '照片宽度' })
  @IsNumber()
  @IsOptional()
  width?: number;

  @ApiPropertyOptional({ description: '照片高度' })
  @IsNumber()
  @IsOptional()
  height?: number;

  @ApiPropertyOptional({ description: '照片描述 (0-100字)', example: '山顶的风景' })
  @IsString()
  @IsOptional()
  @Length(0, 100)
  description?: string;

  @ApiPropertyOptional({ description: '纬度' })
  @IsNumber()
  @IsOptional()
  latitude?: number;

  @ApiPropertyOptional({ description: '经度' })
  @IsNumber()
  @IsOptional()
  longitude?: number;

  @ApiPropertyOptional({ description: '拍摄时间' })
  @IsString()
  @IsOptional()
  takenAt?: string;
}

// ==================== 批量创建照片 ====================
export class CreatePhotosDto {
  @ApiProperty({ description: '照片列表', type: [CreatePhotoDto] })
  @IsArray()
  @ArrayMaxSize(9, { message: '一次最多上传9张照片' })
  photos: CreatePhotoDto[];
}

// ==================== 更新照片 ====================
export class UpdatePhotoDto {
  @ApiPropertyOptional({ description: '照片描述' })
  @IsString()
  @IsOptional()
  @Length(0, 100)
  description?: string;

  @ApiPropertyOptional({ description: '是否公开', default: true })
  @IsBoolean()
  @IsOptional()
  isPublic?: boolean;
}

// ==================== 查询参数 ====================
export class QueryPhotosDto {
  @ApiPropertyOptional({ description: '路线ID' })
  @IsString()
  @IsOptional()
  trailId?: string;

  @ApiPropertyOptional({ description: '用户ID' })
  @IsString()
  @IsOptional()
  userId?: string;

  @ApiPropertyOptional({ description: '排序方式', enum: ['newest', 'popular'], default: 'newest' })
  @IsString()
  @IsOptional()
  sort?: 'newest' | 'popular' = 'newest';

  @ApiPropertyOptional({ description: '游标 (用于分页)' })
  @IsString()
  @IsOptional()
  cursor?: string;

  @ApiPropertyOptional({ description: '每页数量', default: 20 })
  @IsNumber()
  @IsOptional()
  @Max(100)
  @Type(() => Number)
  limit?: number = 20;
}

// ==================== 响应 DTO ====================
export class PhotoUserDto {
  id: string;
  nickname: string | null;
  avatarUrl: string | null;
}

export class PhotoDto {
  id: string;
  url: string;
  thumbnailUrl: string | null;
  width: number | null;
  height: number | null;
  description: string | null;
  likeCount: number;
  isLiked?: boolean;
  isPublic: boolean;
  createdAt: Date;
  user: PhotoUserDto;
  trail?: {
    id: string;
    name: string;
  } | null;
}

export class PhotoListResponseDto {
  list: PhotoDto[];
  nextCursor: string | null;
  hasMore: boolean;
}

export class LikePhotoResponseDto {
  isLiked: boolean;
  likeCount: number;
}
