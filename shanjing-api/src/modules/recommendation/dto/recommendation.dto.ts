// ============================================
// 推荐系统 DTO
// ============================================

import { IsNumber, IsOptional, IsString, IsEnum, Min, Max, IsArray } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export enum RecommendationScene {
  HOME = 'home',
  LIST = 'list',
  SIMILAR = 'similar',
  NEARBY = 'nearby',
}

export enum UserAction {
  CLICK = 'click',
  BOOKMARK = 'bookmark',
  COMPLETE = 'complete',
  IGNORE = 'ignore',
}

// ============ 请求 DTO ============

export class GetRecommendationsDto {
  @ApiPropertyOptional({ description: '用户ID（从JWT获取，也可传参用于测试）' })
  @IsOptional()
  @IsString()
  userId?: string;

  @ApiProperty({ enum: RecommendationScene, description: '推荐场景' })
  @IsEnum(RecommendationScene)
  scene: RecommendationScene;

  @ApiPropertyOptional({ description: '用户纬度' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  lat?: number;

  @ApiPropertyOptional({ description: '用户经度' })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  lng?: number;

  @ApiPropertyOptional({ description: '返回数量', default: 10 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(50)
  @Type(() => Number)
  limit?: number = 10;

  @ApiPropertyOptional({ description: '排除的路线ID列表' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  excludeIds?: string[];

  @ApiPropertyOptional({ description: '参考路线ID（用于相似推荐）' })
  @IsOptional()
  @IsString()
  referenceTrailId?: string;
}

export class FeedbackDto {
  @ApiProperty({ enum: UserAction, description: '用户行为' })
  @IsEnum(UserAction)
  action: UserAction;

  @ApiProperty({ description: '推荐的路线ID' })
  @IsString()
  trailId: string;

  @ApiPropertyOptional({ description: '推荐日志ID' })
  @IsOptional()
  @IsString()
  logId?: string;

  @ApiPropertyOptional({ description: '交互时长（秒）' })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  durationSec?: number;
}

// ============ 响应 DTO ============

export class MatchFactorsDto {
  @ApiProperty({ description: '难度匹配分数 (0-100)' })
  difficultyMatch: number;

  @ApiProperty({ description: '距离分数 (0-100)' })
  distance: number;

  @ApiProperty({ description: '评分分数 (0-100)' })
  rating: number;

  @ApiProperty({ description: '热度分数 (0-100)' })
  popularity: number;

  @ApiProperty({ description: '新鲜度分数 (0-100)' })
  freshness: number;
}

export class RecommendedTrailDto {
  @ApiProperty({ description: '路线ID' })
  id: string;

  @ApiProperty({ description: '路线名称' })
  name: string;

  @ApiProperty({ description: '封面图片' })
  coverImage: string;

  @ApiProperty({ description: '距离（公里）' })
  distanceKm: number;

  @ApiProperty({ description: '时长（分钟）' })
  durationMin: number;

  @ApiProperty({ description: '难度' })
  difficulty: string;

  @ApiProperty({ description: '评分' })
  rating: number;

  @ApiProperty({ description: '匹配分数 (0-100)' })
  matchScore: number;

  @ApiProperty({ description: '匹配因子详情' })
  matchFactors: MatchFactorsDto;

  @ApiPropertyOptional({ description: '推荐理由' })
  recommendReason?: string;

  @ApiPropertyOptional({ description: '与用户距离（米）' })
  userDistanceM?: number;
}

export class RecommendationsResponseDto {
  @ApiProperty({ description: '算法版本' })
  algorithm: string;

  @ApiProperty({ description: '推荐场景' })
  scene: string;

  @ApiProperty({ description: '推荐日志ID（用于反馈追踪）' })
  logId: string;

  @ApiProperty({ description: '推荐路线列表' })
  trails: RecommendedTrailDto[];
}

// ============ 内部使用 DTO ============

export interface TrailFeatureVector {
  difficulty: number; // 1: EASY, 2: MODERATE, 3: HARD
  distanceKm: number;
  rating: number;
  popularity: number; // 0-1
  freshness: number; // 0-1
  tags: string[];
}

export interface UserPreferenceVector {
  preferredDifficulty: number;
  preferredMinDistance: number;
  preferredMaxDistance: number;
  preferredTags: string[];
  difficultyDistribution: Record<string, number>; // {EASY: 0.3, MODERATE: 0.5, HARD: 0.2}
}

export interface ScoredTrail {
  trail: any; // Trail entity
  score: number;
  factors: {
    difficultyMatch: number;
    distance: number;
    rating: number;
    popularity: number;
    freshness: number;
  };
  userDistanceM?: number;
}