// ================================================================
// M6: 评论系统 DTO
// ================================================================

import { IsString, IsNumber, IsOptional, IsArray, IsBoolean, Min, Max, Length, ArrayMaxSize } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

// ==================== 预定义标签 ====================
export const PREDEFINED_TAGS = [
  // 风景类
  '风景优美', '视野开阔', '拍照圣地', '秋色迷人', '春花烂漫',
  // 难度类
  '难度适中', '轻松休闲', '挑战性强', '适合新手', '需要体能',
  // 设施类
  '设施完善', '补给方便', '厕所干净', '指示牌清晰',
  // 人群类
  '适合亲子', '宠物友好', '人少清静', '团队建设',
  // 特色类
  '历史文化', '古迹众多', '森林氧吧', '溪流潺潺'
] as const;

export type PredefinedTag = typeof PREDEFINED_TAGS[number];

// ==================== 创建评论 ====================
export class CreateReviewDto {
  @ApiProperty({ description: '评分 (1.0-5.0, 支持半星)', minimum: 1, maximum: 5, example: 4.5 })
  @IsNumber()
  @Min(1)
  @Max(5)
  @Type(() => Number)
  rating: number;

  @ApiPropertyOptional({ description: '评论内容 (10-500字)', example: '这条路线风景很美，难度适中，非常适合周末徒步。' })
  @IsString()
  @IsOptional()
  @Length(10, 500, { message: '评论内容需要在10-500字之间' })
  content?: string;

  @ApiPropertyOptional({ description: '评论标签', enum: PREDEFINED_TAGS, isArray: true })
  @IsArray()
  @IsOptional()
  @ArrayMaxSize(5, { message: '最多选择5个标签' })
  tags?: string[];

  @ApiPropertyOptional({ description: '评论配图URL列表', example: ['https://cdn.example.com/photo1.jpg'] })
  @IsArray()
  @IsOptional()
  @ArrayMaxSize(3, { message: '最多上传3张图片' })
  photos?: string[];
}

// ==================== 更新评论 ====================
export class UpdateReviewDto {
  @ApiPropertyOptional({ description: '评分 (1.0-5.0)', minimum: 1, maximum: 5 })
  @IsNumber()
  @Min(1)
  @Max(5)
  @IsOptional()
  @Type(() => Number)
  rating?: number;

  @ApiPropertyOptional({ description: '评论内容 (10-500字)' })
  @IsString()
  @IsOptional()
  @Length(10, 500)
  content?: string;

  @ApiPropertyOptional({ description: '评论标签' })
  @IsArray()
  @IsOptional()
  @ArrayMaxSize(5)
  tags?: string[];
}

// ==================== 评论回复 ====================
export class CreateReplyDto {
  @ApiProperty({ description: '回复内容', example: '感谢分享，我也想去试试！' })
  @IsString()
  @Length(1, 500)
  content: string;

  @ApiPropertyOptional({ description: '父回复ID（用于嵌套回复）' })
  @IsString()
  @IsOptional()
  parentId?: string;
}

// ==================== 举报评论 ====================
export class ReportReviewDto {
  @ApiProperty({ description: '举报原因', example: '内容不适当' })
  @IsString()
  @Length(1, 100)
  reason: string;
}

// ==================== 查询参数 ====================
export class QueryReviewsDto {
  @ApiPropertyOptional({ description: '排序方式', enum: ['newest', 'highest', 'lowest'], default: 'newest' })
  @IsString()
  @IsOptional()
  sort?: 'newest' | 'highest' | 'lowest' = 'newest';

  @ApiPropertyOptional({ description: '评分筛选', example: 5 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  rating?: number;

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ description: '每页数量', default: 10 })
  @IsNumber()
  @IsOptional()
  @Type(() => Number)
  limit?: number = 10;
}

// ==================== 响应 DTO ====================
export class ReviewUserDto {
  id: string;
  nickname: string | null;
  avatarUrl: string | null;
}

export class ReviewReplyDto {
  id: string;
  content: string;
  user: ReviewUserDto;
  parentId: string | null;
  createdAt: Date;
}

export class ReviewDto {
  id: string;
  rating: number;
  content: string | null;
  tags: string[];
  photos: string[];
  likeCount: number;
  replyCount: number;
  isEdited: boolean;
  user: ReviewUserDto;
  createdAt: Date;
  updatedAt: Date;
}

export class ReviewDetailDto extends ReviewDto {
  replies: ReviewReplyDto[];
}

export class ReviewStatsDto {
  trailId: string;
  avgRating: number;
  totalCount: number;
  rating5Count: number;
  rating4Count: number;
  rating3Count: number;
  rating2Count: number;
  rating1Count: number;
}

export class ReviewListResponseDto {
  list: ReviewDto[];
  total: number;
  page: number;
  limit: number;
  stats: ReviewStatsDto;
}