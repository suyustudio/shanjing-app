/**
 * 路线管理 DTO
 */

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsOptional,
  IsNumber,
  IsEnum,
  IsArray,
  IsBoolean,
  Min,
  Max,
  MinLength,
  MaxLength,
} from 'class-validator';
import { Type } from 'class-transformer';
import { TrailDifficulty } from '@prisma/client';

/**
 * 创建路线请求 DTO
 */
export class CreateTrailDto {
  @ApiProperty({
    description: '路线名称',
    example: '西湖环湖步道',
  })
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name: string;

  @ApiPropertyOptional({
    description: '路线描述',
    example: '环绕西湖的经典徒步路线，风景优美...',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({
    description: '距离（公里）',
    example: 10.5,
  })
  @IsNumber()
  @Min(0.1)
  @Max(1000)
  @Type(() => Number)
  distanceKm: number;

  @ApiProperty({
    description: '预计耗时（分钟）',
    example: 180,
  })
  @IsNumber()
  @Min(1)
  @Max(1440)
  @Type(() => Number)
  durationMin: number;

  @ApiProperty({
    description: '爬升高度（米）',
    example: 150,
  })
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  elevationGainM: number;

  @ApiProperty({
    description: '难度等级',
    enum: TrailDifficulty,
    example: TrailDifficulty.MODERATE,
  })
  @IsEnum(TrailDifficulty)
  difficulty: TrailDifficulty;

  @ApiPropertyOptional({
    description: '标签列表',
    example: ['风景优美', '适合新手', '亲子友好'],
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({
    description: '封面图片URL列表',
    example: ['https://example.com/image1.jpg'],
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  coverImages?: string[];

  @ApiPropertyOptional({
    description: 'GPX文件URL',
    example: 'https://example.com/trail.gpx',
  })
  @IsOptional()
  @IsString()
  gpxUrl?: string;

  @ApiProperty({
    description: '城市',
    example: '杭州市',
  })
  @IsString()
  city: string;

  @ApiProperty({
    description: '区县',
    example: '西湖区',
  })
  @IsString()
  district: string;

  @ApiProperty({
    description: '起点纬度',
    example: 30.25961,
  })
  @IsNumber()
  @Type(() => Number)
  startPointLat: number;

  @ApiProperty({
    description: '起点经度',
    example: 120.13026,
  })
  @IsNumber()
  @Type(() => Number)
  startPointLng: number;

  @ApiPropertyOptional({
    description: '起点地址',
    example: '杭州市西湖区断桥残雪',
  })
  @IsOptional()
  @IsString()
  startPointAddress?: string;

  @ApiPropertyOptional({
    description: '安全信息',
    example: {
      femaleFriendly: true,
      signalCoverage: '全程覆盖',
      evacuationPoints: 3,
    },
  })
  @IsOptional()
  safetyInfo?: Record<string, any>;
}

/**
 * 更新路线请求 DTO
 */
export class UpdateTrailDto {
  @ApiPropertyOptional({
    description: '路线名称',
    example: '西湖环湖步道（更新）',
  })
  @IsOptional()
  @IsString()
  @MinLength(2)
  @MaxLength(100)
  name?: string;

  @ApiPropertyOptional({
    description: '路线描述',
    example: '环绕西湖的经典徒步路线...',
  })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({
    description: '距离（公里）',
    example: 10.5,
  })
  @IsOptional()
  @IsNumber()
  @Min(0.1)
  @Max(1000)
  @Type(() => Number)
  distanceKm?: number;

  @ApiPropertyOptional({
    description: '预计耗时（分钟）',
    example: 180,
  })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(1440)
  @Type(() => Number)
  durationMin?: number;

  @ApiPropertyOptional({
    description: '爬升高度（米）',
    example: 150,
  })
  @IsOptional()
  @IsNumber()
  @Min(0)
  @Type(() => Number)
  elevationGainM?: number;

  @ApiPropertyOptional({
    description: '难度等级',
    enum: TrailDifficulty,
    example: TrailDifficulty.MODERATE,
  })
  @IsOptional()
  @IsEnum(TrailDifficulty)
  difficulty?: TrailDifficulty;

  @ApiPropertyOptional({
    description: '标签列表',
    example: ['风景优美', '适合新手'],
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({
    description: '封面图片URL列表',
    example: ['https://example.com/image1.jpg'],
    type: [String],
  })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  coverImages?: string[];

  @ApiPropertyOptional({
    description: 'GPX文件URL',
    example: 'https://example.com/trail.gpx',
  })
  @IsOptional()
  @IsString()
  gpxUrl?: string;

  @ApiPropertyOptional({
    description: '城市',
    example: '杭州市',
  })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({
    description: '区县',
    example: '西湖区',
  })
  @IsOptional()
  @IsString()
  district?: string;

  @ApiPropertyOptional({
    description: '起点纬度',
    example: 30.25961,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  startPointLat?: number;

  @ApiPropertyOptional({
    description: '起点经度',
    example: 120.13026,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  startPointLng?: number;

  @ApiPropertyOptional({
    description: '起点地址',
    example: '杭州市西湖区断桥残雪',
  })
  @IsOptional()
  @IsString()
  startPointAddress?: string;

  @ApiPropertyOptional({
    description: '安全信息',
    example: {
      femaleFriendly: true,
      signalCoverage: '全程覆盖',
      evacuationPoints: 3,
    },
  })
  @IsOptional()
  safetyInfo?: Record<string, any>;

  @ApiPropertyOptional({
    description: '状态：true-上架，false-下架',
    example: true,
  })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

/**
 * 路线列表查询 DTO
 */
export class TrailListQueryDto {
  @ApiPropertyOptional({
    description: '搜索关键词（路线名称）',
    example: '西湖',
  })
  @IsOptional()
  @IsString()
  keyword?: string;

  @ApiPropertyOptional({
    description: '城市',
    example: '杭州市',
  })
  @IsOptional()
  @IsString()
  city?: string;

  @ApiPropertyOptional({
    description: '难度等级',
    enum: TrailDifficulty,
    example: TrailDifficulty.EASY,
  })
  @IsOptional()
  @IsEnum(TrailDifficulty)
  difficulty?: TrailDifficulty;

  @ApiPropertyOptional({
    description: '状态：true-上架，false-下架',
    example: true,
  })
  @IsOptional()
  @IsBoolean()
  @Type(() => Boolean)
  isActive?: boolean;

  @ApiPropertyOptional({
    description: '页码',
    example: 1,
    default: 1,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  page?: number;

  @ApiPropertyOptional({
    description: '每页数量',
    example: 20,
    default: 20,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  limit?: number;
}

/**
 * 路线响应 DTO
 */
export class TrailResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiPropertyOptional({ description: '错误信息' })
  errorMessage?: string;

  @ApiProperty({ description: '路线数据' })
  data: {
    id: string;
    name: string;
    description: string | null;
    distanceKm: number;
    durationMin: number;
    elevationGainM: number;
    difficulty: TrailDifficulty;
    tags: string[];
    coverImages: string[];
    gpxUrl: string | null;
    city: string;
    district: string;
    startPointLat: number;
    startPointLng: number;
    startPointAddress: string | null;
    safetyInfo: Record<string, any> | null;
    isActive: boolean;
    createdAt: Date;
    updatedAt: Date;
  };
}

/**
 * 路线列表响应 DTO
 */
export class TrailListResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '路线列表', type: 'array' })
  data: Array<{
    id: string;
    name: string;
    distanceKm: number;
    durationMin: number;
    difficulty: TrailDifficulty;
    city: string;
    district: string;
    isActive: boolean;
    createdAt: Date;
  }>;

  @ApiProperty({ description: '分页信息' })
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
