import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';

/**
 * 步行路线规划请求 DTO
 */
export class WalkingRouteDto {
  @ApiProperty({
    description: '出发点纬度',
    example: 39.989643,
  })
  @IsNumber()
  @Type(() => Number)
  originLat: number;

  @ApiProperty({
    description: '出发点经度',
    example: 116.481028,
  })
  @IsNumber()
  @Type(() => Number)
  originLng: number;

  @ApiProperty({
    description: '目的地纬度',
    example: 39.90816,
  })
  @IsNumber()
  @Type(() => Number)
  destLat: number;

  @ApiProperty({
    description: '目的地经度',
    example: 116.434446,
  })
  @IsNumber()
  @Type(() => Number)
  destLng: number;
}

/**
 * 驾车路线规划请求 DTO
 */
export class DrivingRouteDto {
  @ApiProperty({
    description: '出发点纬度',
    example: 39.989643,
  })
  @IsNumber()
  @Type(() => Number)
  originLat: number;

  @ApiProperty({
    description: '出发点经度',
    example: 116.481028,
  })
  @IsNumber()
  @Type(() => Number)
  originLng: number;

  @ApiProperty({
    description: '目的地纬度',
    example: 39.90816,
  })
  @IsNumber()
  @Type(() => Number)
  destLat: number;

  @ApiProperty({
    description: '目的地经度',
    example: 116.434446,
  })
  @IsNumber()
  @Type(() => Number)
  destLng: number;

  @ApiPropertyOptional({
    description: '驾车策略，默认10（躲避拥堵）',
    example: 10,
    default: 10,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  strategy?: number;
}

/**
 * 骑行路线规划请求 DTO
 */
export class BicyclingRouteDto {
  @ApiProperty({
    description: '出发点纬度',
    example: 39.989643,
  })
  @IsNumber()
  @Type(() => Number)
  originLat: number;

  @ApiProperty({
    description: '出发点经度',
    example: 116.481028,
  })
  @IsNumber()
  @Type(() => Number)
  originLng: number;

  @ApiProperty({
    description: '目的地纬度',
    example: 39.90816,
  })
  @IsNumber()
  @Type(() => Number)
  destLat: number;

  @ApiProperty({
    description: '目的地经度',
    example: 116.434446,
  })
  @IsNumber()
  @Type(() => Number)
  destLng: number;
}

/**
 * 路线规划类型
 */
export enum RouteType {
  WALKING = 'walking',
  DRIVING = 'driving',
  BICYCLING = 'bicycling',
}

/**
 * 通用路线规划请求 DTO
 */
export class RoutePlanningDto {
  @ApiProperty({
    description: '出发点纬度',
    example: 39.989643,
  })
  @IsNumber()
  @Type(() => Number)
  originLat: number;

  @ApiProperty({
    description: '出发点经度',
    example: 116.481028,
  })
  @IsNumber()
  @Type(() => Number)
  originLng: number;

  @ApiProperty({
    description: '目的地纬度',
    example: 39.90816,
  })
  @IsNumber()
  @Type(() => Number)
  destLat: number;

  @ApiProperty({
    description: '目的地经度',
    example: 116.434446,
  })
  @IsNumber()
  @Type(() => Number)
  destLng: number;

  @ApiProperty({
    description: '路线类型：walking(步行)、driving(驾车)、bicycling(骑行)',
    enum: RouteType,
    example: RouteType.WALKING,
  })
  @IsEnum(RouteType)
  type: RouteType;

  @ApiPropertyOptional({
    description: '驾车策略（仅驾车路线有效），默认10（躲避拥堵）',
    example: 10,
    default: 10,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  strategy?: number;
}
