// create-trail.dto.ts - 创建路线请求DTO
// 山径APP - 后台管理 API
// 功能：管理员创建路线的数据验证

import {
  IsString,
  IsNumber,
  IsOptional,
  IsEnum,
  IsArray,
  IsBoolean,
  Min,
  Max,
  Length,
  IsUrl,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Difficulty } from '@prisma/client';

/**
 * 坐标点DTO
 */
export class CoordinateDto {
  @ApiProperty({ description: '纬度', example: 30.2741 })
  @IsNumber()
  @Min(-90)
  @Max(90)
  lat: number;

  @ApiProperty({ description: '经度', example: 120.1551 })
  @IsNumber()
  @Min(-180)
  @Max(180)
  lng: number;

  @ApiPropertyOptional({ description: '海拔（米）', example: 150.5 })
  @IsOptional()
  @IsNumber()
  altitude?: number;
}

/**
 * 边界框DTO
 */
export class BoundsInputDto {
  @ApiProperty({ description: '北边界', example: 30.2841 })
  @IsNumber()
  north: number;

  @ApiProperty({ description: '南边界', example: 30.2641 })
  @IsNumber()
  south: number;

  @ApiProperty({ description: '东边界', example: 120.1651 })
  @IsNumber()
  east: number;

  @ApiProperty({ description: '西边界', example: 120.1451 })
  @IsNumber()
  west: number;
}

/**
 * 海拔剖面点DTO
 */
export class ElevationPointDto {
  @ApiProperty({ description: '距离起点的距离（公里）', example: 0.5 })
  @IsNumber()
  @Min(0)
  distance: number;

  @ApiProperty({ description: '海拔高度（米）', example: 150.5 })
  @IsNumber()
  elevation: number;
}

/**
 * 创建路线请求DTO
 */
export class CreateTrailDto {
  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线', minLength: 2, maxLength: 100 })
  @IsString()
  @Length(2, 100)
  name: string;

  @ApiPropertyOptional({ description: '路线描述', example: '经典杭州徒步路线，沿途溪流潺潺，风景优美...' })
  @IsOptional()
  @IsString()
  @Length(0, 5000)
  description?: string;

  @ApiProperty({ description: '距离（公里）', example: 8.5, minimum: 0 })
  @IsNumber()
  @Min(0)
  distanceKm: number;

  @ApiProperty({ description: '预计用时（分钟）', example: 180, minimum: 0 })
  @IsNumber()
  @Min(0)
  durationMin: number;

  @ApiProperty({ description: '累计爬升（米）', example: 350.5, minimum: 0 })
  @IsNumber()
  @Min(0)
  elevationGainM: number;

  @ApiPropertyOptional({ description: '累计下降（米）', example: 350.5, minimum: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  elevationLossM?: number;

  @ApiProperty({ description: '难度等级', enum: Difficulty, example: Difficulty.MODERATE })
  @IsEnum(Difficulty)
  difficulty: Difficulty;

  @ApiPropertyOptional({ description: '标签数组', example: ['森林', '溪流', '亲子友好'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ description: '封面图片URL数组', example: ['https://example.com/images/trail1.jpg'], type: [String] })
  @IsOptional()
  @IsArray()
  @IsUrl({}, { each: true })
  coverImages?: string[];

  @ApiPropertyOptional({ description: 'GPX文件URL', example: 'https://example.com/trails/trail1.gpx' })
  @IsOptional()
  @IsUrl()
  gpxUrl?: string;

  @ApiPropertyOptional({ description: '城市', example: '杭州' })
  @IsOptional()
  @IsString()
  @Length(0, 50)
  city?: string;

  @ApiPropertyOptional({ description: '区县', example: '西湖区' })
  @IsOptional()
  @IsString()
  @Length(0, 50)
  district?: string;

  @ApiProperty({ description: '起点地址', example: '龙井村入口' })
  @IsString()
  @Length(0, 200)
  startPointAddress: string;

  @ApiProperty({ description: '起点坐标', type: CoordinateDto })
  @ValidateNested()
  @Type(() => CoordinateDto)
  startPoint: CoordinateDto;

  @ApiPropertyOptional({ description: '边界框', type: BoundsInputDto })
  @IsOptional()
  @ValidateNested()
  @Type(() => BoundsInputDto)
  bounds?: BoundsInputDto;

  @ApiPropertyOptional({ description: '海拔剖面数据', type: [ElevationPointDto] })
  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => ElevationPointDto)
  elevationProfile?: ElevationPointDto[];

  @ApiPropertyOptional({ description: '安全信息', example: { femaleFriendly: true, hasRestroom: true } })
  @IsOptional()
  safetyInfo?: Record<string, any>;

  @ApiPropertyOptional({ description: '是否立即发布', example: true, default: false })
  @IsOptional()
  @IsBoolean()
  isPublished?: boolean = false;
}
