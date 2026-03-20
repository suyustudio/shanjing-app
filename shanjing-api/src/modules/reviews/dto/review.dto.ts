// ================================================================
// M6: 评论系统 DTO - 修复版
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

// ==================== 统一响应格式 ====================
export class ApiResponseDto<T> {
  @ApiProperty({ description: '是否成功' })
  success: boolean;

  @ApiProperty({ description: '响应数据' })
  data: T;

  @ApiPropertyOptional({ description: '错误信息' })
  message?: string;

  @ApiPropertyOptional({ description: '分页信息' })
  meta?: {
    total?: number;
    page?: number;
    limit?: number;
    hasMore?: boolean;
  };
}

// ==================== 创建评论 ====================
export class CreateReviewDto {
  @ApiProperty({ description: '评分 (1-5星，整数)', minimum: 1, maximum: 5, example: 4 })
  @IsNumber()
  @Min(1)
  @Max(5)
  @Type(() => Number)
  rating: number;

  @ApiPropertyOptional({ description: '评论内容 (0-500字)', example: '这条路线风景很美，难度适中，非常适合周末徒步。' })
  @IsString()
  @IsOptional()
  @Length(0, 500, { message: '评论内容需要在0-500字之间' })
  content?: string;

  @ApiPropertyOptional({ description: '评论标签', enum: PREDEFINED_TAGS, isArray: true })
  @IsArray()
  @IsOptional()
  @ArrayMaxSize(5, { message: '最多选择5个标签' })
  tags?: string[];

  @ApiPropertyOptional({ description: '评论配图URL列表 (最多9张)', example: ['https://cdn.example.com/photo1.jpg'] })
  @IsArray()
  @IsOptional()
  @ArrayMaxSize(9, { message: '最多上传9张图片' })
  photos?: string[];

  @ApiPropertyOptional({ description: '难度再评估 (可选)', enum: ['EASY', 'MODERATE', 'HARD'] })
  @IsString()
  @IsOptional()
  difficulty?: string;
}

// ==================== 更新评论 ====================
export class UpdateReviewDto {
  @ApiPropertyOptional({ description: '评分 (1-5星)', minimum: 1, maximum: 5 })
  @IsNumber()
  @Min(1)
  @Max(5)
  @IsOptional()
  @Type(() => Number)
  rating?: number;

  @ApiPropertyOptional({ description: '评论内容 (0-500字)' })
  @IsString()
  @IsOptional()
  @Length(0, 500)
  content?: string;

  @ApiPropertyOptional({ description: '评论标签' })
  @IsArray()
  @IsOptional()
  @ArrayMaxSize(5)
  tags?: string[];

  @ApiPropertyOptional({ description: '评论配图URL列表 (可修改)', example: ['https://cdn.example.com/photo1.jpg'] })
  @IsArray()
  @IsOptional()
  @ArrayMaxSize(9)
  photos?: string[];
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
  @ApiPropertyOptional({ description: '排序方式', enum: ['newest', 'highest', 'lowest', 'hot'], default: 'newest' })
  @IsString()
  @IsOptional()
  sort?: 'newest' | 'highest' | 'lowest' | 'hot' = 'newest';

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

  @ApiPropertyOptional({ description: '每页数量 (最大100)', default: 10 })
  @IsNumber()
  @IsOptional()
  @Max(100)
  @Type(() => Number)
  limit?: number = 10;
}

// ==================== 响应 DTO ====================
export class ReviewUserDto {
  @ApiProperty({ description: '用户ID' })
  id: string;

  @ApiProperty({ description: '用户昵称', nullable: true })
  nickname: string | null;

  @ApiProperty({ description: '用户头像', nullable: true })
  avatarUrl: string | null;
}

export class ReviewReplyDto {
  @ApiProperty({ description: '回复ID' })
  id: string;

  @ApiProperty({ description: '回复内容' })
  content: string;

  @ApiProperty({ description: '回复用户信息', type: ReviewUserDto })
  user: ReviewUserDto;

  @ApiProperty({ description: '父回复ID', nullable: true })
  parentId: string | null;

  @ApiProperty({ description: '创建时间' })
  createdAt: Date;
}

export class ReviewDto {
  @ApiProperty({ description: '评论ID' })
  id: string;

  @ApiProperty({ description: '评分 (1-5星)' })
  rating: number;

  @ApiProperty({ description: '评论内容', nullable: true })
  content: string | null;

  @ApiProperty({ description: '评论标签', type: [String] })
  tags: string[];

  @ApiProperty({ description: '评论配图URL列表', type: [String] })
  photos: string[];

  @ApiProperty({ description: '点赞数' })
  likeCount: number;

  @ApiProperty({ description: '回复数' })
  replyCount: number;

  @ApiProperty({ description: '是否已编辑' })
  isEdited: boolean;

  @ApiProperty({ description: '是否"体验过"认证' })
  isVerified: boolean;

  @ApiProperty({ description: '当前用户是否已点赞', nullable: true })
  isLiked?: boolean;

  @ApiProperty({ description: '评论用户信息', type: ReviewUserDto })
  user: ReviewUserDto;

  @ApiProperty({ description: '创建时间' })
  createdAt: Date;

  @ApiProperty({ description: '更新时间' })
  updatedAt: Date;
}

export class ReviewDetailDto extends ReviewDto {
  @ApiProperty({ description: '回复列表', type: [ReviewReplyDto] })
  replies: ReviewReplyDto[];
}

export class ReviewStatsDto {
  @ApiProperty({ description: '路线ID' })
  trailId: string;

  @ApiProperty({ description: '加权平均评分' })
  avgRating: number;

  @ApiProperty({ description: '总评论数' })
  totalCount: number;

  @ApiProperty({ description: '5星数量' })
  rating5Count: number;

  @ApiProperty({ description: '4星数量' })
  rating4Count: number;

  @ApiProperty({ description: '3星数量' })
  rating3Count: number;

  @ApiProperty({ description: '2星数量' })
  rating2Count: number;

  @ApiProperty({ description: '1星数量' })
  rating1Count: number;
}

export class ReviewListResponseDto {
  @ApiProperty({ description: '评论列表', type: [ReviewDto] })
  list: ReviewDto[];

  @ApiProperty({ description: '总数' })
  total: number;

  @ApiProperty({ description: '当前页码' })
  page: number;

  @ApiProperty({ description: '每页数量' })
  limit: number;

  @ApiProperty({ description: '评分统计', type: ReviewStatsDto })
  stats: ReviewStatsDto;
}

// ==================== 点赞相关 DTO ====================
export class LikeReviewResponseDto {
  @ApiProperty({ description: '是否已点赞' })
  isLiked: boolean;

  @ApiProperty({ description: '当前点赞数' })
  likeCount: number;
}
