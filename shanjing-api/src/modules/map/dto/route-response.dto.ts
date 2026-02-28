import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 坐标点 DTO
 */
export class LatLngDto {
  @ApiProperty({ description: '纬度', example: 39.990464 })
  lat: number;

  @ApiProperty({ description: '经度', example: 116.481488 })
  lng: number;
}

/**
 * 导航路段 DTO
 */
export class RouteStepDto {
  @ApiProperty({ description: '路段说明', example: '沿阜通东大街向北步行100米' })
  instruction: string;

  @ApiProperty({ description: '道路名称', example: '阜通东大街' })
  road: string;

  @ApiProperty({ description: '距离，单位：米', example: 100 })
  distance: number;

  @ApiProperty({ description: '预计耗时，单位：秒', example: 60 })
  duration: number;

  @ApiProperty({ description: '坐标点数组', type: [LatLngDto] })
  polyline: LatLngDto[];

  @ApiPropertyOptional({ description: '收费，单位：元（驾车）', example: 0 })
  tolls?: number;

  @ApiPropertyOptional({ description: 'toll道路名称（驾车）' })
  tollRoad?: string;

  @ApiProperty({ description: '主要动作', example: '直行' })
  action: string;

  @ApiProperty({ description: '辅助动作', example: '' })
  assistantAction: string;
}

/**
 * 路线方案 DTO
 */
export class RoutePathDto {
  @ApiProperty({ description: '距离，单位：米', example: 5000 })
  distance: number;

  @ApiProperty({ description: '预计耗时，单位：秒', example: 3600 })
  duration: number;

  @ApiPropertyOptional({ description: '收费，单位：元（驾车）', example: 0 })
  tolls?: number;

  @ApiPropertyOptional({ description: '收费路段距离，单位：米（驾车）', example: 0 })
  tollDistance?: number;

  @ApiPropertyOptional({ description: '是否限行（驾车）', example: false })
  restriction?: boolean;

  @ApiPropertyOptional({ description: '红绿灯个数（驾车）', example: 5 })
  trafficLights?: number;

  @ApiProperty({ description: '导航路段列表', type: [RouteStepDto] })
  steps: RouteStepDto[];
}

/**
 * 路线规划响应数据 DTO
 */
export class RouteDataDto {
  @ApiProperty({ description: '起点坐标', example: '116.481028,39.989643' })
  origin: string;

  @ApiProperty({ description: '终点坐标', example: '116.434446,39.90816' })
  destination: string;

  @ApiProperty({ description: '路线方案列表', type: [RoutePathDto] })
  paths: RoutePathDto[];
}

/**
 * 路线规划响应 DTO
 */
export class RouteResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiPropertyOptional({ description: '错误信息' })
  errorMessage?: string;

  @ApiProperty({ description: '响应数据', type: RouteDataDto })
  data: RouteDataDto;
}
