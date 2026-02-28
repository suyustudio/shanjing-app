import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsNumber, IsEnum } from 'class-validator';
import { Type } from 'class-transformer';

/**
 * 地理编码请求 DTO
 */
export class GeocodeDto {
  @ApiProperty({
    description: '结构化地址信息，如：北京市朝阳区阜通东大街6号',
    example: '北京市朝阳区阜通东大街6号',
  })
  @IsString()
  address: string;

  @ApiPropertyOptional({
    description: '指定地址所在城市，如：北京/北京市/BEIJING',
    example: '北京',
  })
  @IsOptional()
  @IsString()
  city?: string;
}

/**
 * 逆地理编码请求 DTO
 */
export class RegeocodeDto {
  @ApiProperty({
    description: '纬度',
    example: 39.990464,
  })
  @IsNumber()
  @Type(() => Number)
  lat: number;

  @ApiProperty({
    description: '经度',
    example: 116.481488,
  })
  @IsNumber()
  @Type(() => Number)
  lng: number;

  @ApiPropertyOptional({
    description: '返回结果控制，base:基本地址信息，all:基本+附近POI+道路',
    enum: ['base', 'all'],
    default: 'base',
  })
  @IsOptional()
  @IsEnum(['base', 'all'])
  extensions?: 'base' | 'all';

  @ApiPropertyOptional({
    description: '搜索半径，单位：米，取值范围：0-3000',
    default: 1000,
  })
  @IsOptional()
  @IsNumber()
  @Type(() => Number)
  radius?: number;
}
