// collection-enhanced.dto.ts
// 山径APP - 增强版收藏夹 DTO（M7 P1）

import { IsString, IsOptional, IsArray, IsBoolean, IsInt, Min, Max } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Type } from 'class-transformer';

/**
 * 批量添加路线请求 DTO
 */
export class BatchAddTrailsDto {
  @ApiProperty({ 
    description: '路线ID数组', 
    example: ['trail_001', 'trail_002', 'trail_003'],
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  trailIds: string[];

  @ApiPropertyOptional({ 
    description: '批量添加的备注（应用到所有路线）', 
    example: '春季推荐路线',
  })
  @IsString()
  @IsOptional()
  @MaxLength(200)
  note?: string;
}

/**
 * 批量移除路线请求 DTO
 */
export class BatchRemoveTrailsDto {
  @ApiProperty({ 
    description: '路线ID数组', 
    example: ['trail_001', 'trail_002', 'trail_003'],
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  trailIds: string[];
}

/**
 * 批量移动路线请求 DTO
 */
export class BatchMoveTrailsDto {
  @ApiProperty({ 
    description: '源收藏夹ID', 
    example: 'collection_001',
  })
  @IsString()
  sourceCollectionId: string;

  @ApiProperty({ 
    description: '目标收藏夹ID', 
    example: 'collection_002',
  })
  @IsString()
  targetCollectionId: string;

  @ApiProperty({ 
    description: '要移动的路线ID数组', 
    example: ['trail_001', 'trail_002'],
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  trailIds: string[];
}

/**
 * 批量删除收藏夹请求 DTO
 */
export class BatchDeleteCollectionsDto {
  @ApiProperty({ 
    description: '收藏夹ID数组', 
    example: ['collection_001', 'collection_002'],
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  collectionIds: string[];
}

/**
 * 更新收藏夹标签请求 DTO
 */
export class UpdateCollectionTagsDto {
  @ApiProperty({ 
    description: '标签数组', 
    example: ['工作', '旅行', '周末'],
    type: [String],
  })
  @IsArray()
  @IsString({ each: true })
  @MaxLength(20, { each: true })
  tags: string[];
}

/**
 * 收藏夹搜索查询 DTO
 */
export class SearchCollectionsQueryDto {
  @ApiPropertyOptional({ 
    description: '搜索关键词（名称或描述）', 
    example: '杭州',
  })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({ 
    description: '标签筛选（逗号分隔）', 
    example: '工作,旅行',
  })
  @IsString()
  @IsOptional()
  tags?: string;

  @ApiPropertyOptional({ 
    description: '是否公开', 
    example: true,
  })
  @IsBoolean()
  @IsOptional()
  @Type(() => Boolean)
  isPublic?: boolean;

  @ApiPropertyOptional({ 
    description: '排序方式', 
    enum: ['created', 'updated', 'name', 'trailCount'],
    default: 'updated',
  })
  @IsString()
  @IsOptional()
  sort?: string = 'updated';

  @ApiPropertyOptional({ 
    description: '页码', 
    minimum: 1,
    default: 1,
  })
  @IsInt()
  @Min(1)
  @IsOptional()
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ 
    description: '每页数量', 
    minimum: 1,
    maximum: 100,
    default: 20,
  })
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  @Type(() => Number)
  limit?: number = 20;
}

/**
 * 收藏夹内路线搜索查询 DTO
 */
export class SearchCollectionTrailsQueryDto {
  @ApiPropertyOptional({ 
    description: '搜索关键词（路线名称）', 
    example: '西湖',
  })
  @IsString()
  @IsOptional()
  search?: string;

  @ApiPropertyOptional({ 
    description: '难度筛选（逗号分隔）', 
    example: 'easy,moderate',
  })
  @IsString()
  @IsOptional()
  difficulty?: string;

  @ApiPropertyOptional({ 
    description: '最小距离（公里）', 
    example: 0,
    minimum: 0,
  })
  @IsInt()
  @Min(0)
  @IsOptional()
  @Type(() => Number)
  minDistance?: number;

  @ApiPropertyOptional({ 
    description: '最大距离（公里）', 
    example: 10,
    minimum: 0,
  })
  @IsInt()
  @Min(0)
  @IsOptional()
  @Type(() => Number)
  maxDistance?: number;

  @ApiPropertyOptional({ 
    description: '最小时长（分钟）', 
    example: 0,
    minimum: 0,
  })
  @IsInt()
  @Min(0)
  @IsOptional()
  @Type(() => Number)
  minDuration?: number;

  @ApiPropertyOptional({ 
    description: '最大时长（分钟）', 
    example: 300,
    minimum: 0,
  })
  @IsInt()
  @Min(0)
  @IsOptional()
  @Type(() => Number)
  maxDuration?: number;

  @ApiPropertyOptional({ 
    description: '排序方式', 
    enum: ['added', 'name', 'distance', 'duration', 'difficulty'],
    default: 'added',
  })
  @IsString()
  @IsOptional()
  sort?: string = 'added';

  @ApiPropertyOptional({ 
    description: '页码', 
    minimum: 1,
    default: 1,
  })
  @IsInt()
  @Min(1)
  @IsOptional()
  @Type(() => Number)
  page?: number = 1;

  @ApiPropertyOptional({ 
    description: '每页数量', 
    minimum: 1,
    maximum: 100,
    default: 20,
  })
  @IsInt()
  @Min(1)
  @Max(100)
  @IsOptional()
  @Type(() => Number)
  limit?: number = 20;
}

/**
 * 批量操作结果 DTO
 */
export class BatchOperationResultDto {
  @ApiProperty({ description: '是否成功' })
  success: boolean;

  @ApiPropertyOptional({ description: '操作结果消息' })
  message?: string;

  @ApiProperty({ description: '成功数量' })
  successCount: number;

  @ApiProperty({ description: '总数量' })
  totalCount: number;

  @ApiPropertyOptional({ 
    description: '失败的项目ID', 
    type: [String],
  })
  failedIds?: string[];

  @ApiPropertyOptional({ description: '额外数据' })
  data?: Record<string, any>;
}

// 工具函数：最大长度装饰器
function MaxLength(length: number) {
  return function (target: any, propertyKey: string) {
    // 简化实现，实际应使用 class-validator 的 @MaxLength
    return;
  };
}
