/**
 * 轨迹录制 DTO
 */

import { IsOptional, IsString, IsNumber, IsEnum, IsArray, Min, Max, IsObject } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { TrailDifficulty } from '@prisma/client';

/**
 * 上传轨迹录制数据 DTO
 */
export class UploadRecordingDto {
  @ApiProperty({ description: '录制会话ID' })
  @IsString()
  sessionId: string;

  @ApiProperty({ description: '路线名称' })
  @IsString()
  trailName: string;

  @ApiPropertyOptional({ description: '路线描述' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ description: '城市' })
  @IsString()
  city: string;

  @ApiProperty({ description: '区域/区县' })
  @IsString()
  district: string;

  @ApiProperty({ 
    description: '难度级别', 
    enum: TrailDifficulty,
    default: TrailDifficulty.EASY 
  })
  @IsEnum(TrailDifficulty)
  difficulty: TrailDifficulty;

  @ApiPropertyOptional({ description: '标签列表' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiProperty({ description: '轨迹数据（包含轨迹点和POI）' })
  @IsObject()
  trackData: {
    trackPoints: Array<{
      latitude: number;
      longitude: number;
      altitude: number;
      accuracy: number;
      speed?: number;
      timestamp: string;
    }>;
    pois?: Array<{
      id: string;
      latitude: number;
      longitude: number;
      altitude: number;
      type: string;
      name?: string;
      description?: string;
      photoUrls?: string[];
      createdAt: string;
    }>;
    durationSeconds: number;
    elevationGain: number;
    elevationLoss: number;
  };
}

/**
 * 录制记录列表查询 DTO
 */
export class RecordingListQueryDto {
  @ApiPropertyOptional({ description: '状态筛选: pending/approved/rejected' })
  @IsOptional()
  @IsString()
  status?: string;

  @ApiPropertyOptional({ description: '页码', default: 1 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  page?: number = 1;

  @ApiPropertyOptional({ description: '每页数量', default: 20 })
  @IsOptional()
  @IsNumber()
  @Min(1)
  @Max(100)
  limit?: number = 20;
}

/**
 * 审核录制 DTO
 */
export class ApproveRecordingDto {
  @ApiPropertyOptional({ description: '路线名称（可修改）' })
  @IsOptional()
  @IsString()
  trailName?: string;

  @ApiPropertyOptional({ description: '路线描述（可修改）' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiPropertyOptional({ description: '难度级别（可修改）', enum: TrailDifficulty })
  @IsOptional()
  @IsEnum(TrailDifficulty)
  difficulty?: TrailDifficulty;

  @ApiPropertyOptional({ description: '标签列表（可修改）' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  tags?: string[];

  @ApiPropertyOptional({ description: '起点地址' })
  @IsOptional()
  @IsString()
  startPointAddress?: string;

  @ApiPropertyOptional({ description: '封面图片列表' })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  coverImages?: string[];

  @ApiPropertyOptional({ description: '审核备注' })
  @IsOptional()
  @IsString()
  comment?: string;
}

/**
 * 上传响应 DTO
 */
export class UploadResponseDto {
  @ApiProperty({ description: '是否成功' })
  success: boolean;

  @ApiProperty({ description: '响应数据' })
  data: {
    recordingId: string;
    trailName: string;
    status: string;
    message?: string;
  };
}

/**
 * 录制记录列表项 DTO
 */
export class RecordingListItemDto {
  @ApiProperty({ description: '录制记录ID' })
  id: string;

  @ApiProperty({ description: '路线名称' })
  trailName: string;

  @ApiProperty({ description: '状态: pending/approved/rejected' })
  status: string;

  @ApiProperty({ description: '城市' })
  city: string;

  @ApiProperty({ description: '区域' })
  district: string;

  @ApiProperty({ description: '难度级别', enum: TrailDifficulty })
  difficulty: TrailDifficulty;

  @ApiProperty({ description: '距离（公里）' })
  distanceKm: string;

  @ApiProperty({ description: '时长（分钟）' })
  durationMin: number;

  @ApiProperty({ description: '轨迹点数量' })
  pointCount: number;

  @ApiProperty({ description: 'POI数量' })
  poiCount: number;

  @ApiPropertyOptional({ description: '生成的路线ID' })
  trailId?: string;

  @ApiProperty({ description: '创建时间' })
  createdAt: Date;
}

/**
 * 录制记录列表响应 DTO
 */
export class RecordingListResponseDto {
  @ApiProperty({ description: '录制记录列表', type: [RecordingListItemDto] })
  data: RecordingListItemDto[];

  @ApiProperty({ description: '分页信息' })
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

/**
 * 录制详情响应 DTO
 */
export class RecordingDetailResponseDto {
  @ApiProperty({ description: '录制记录ID' })
  id: string;

  @ApiProperty({ description: '路线名称' })
  trailName: string;

  @ApiPropertyOptional({ description: '路线描述' })
  description?: string;

  @ApiProperty({ description: '状态' })
  status: string;

  @ApiProperty({ description: '城市' })
  city: string;

  @ApiProperty({ description: '区域' })
  district: string;

  @ApiProperty({ description: '难度级别', enum: TrailDifficulty })
  difficulty: TrailDifficulty;

  @ApiProperty({ description: '标签列表' })
  tags: string[];

  @ApiProperty({ description: '距离（米）' })
  distanceMeters: number;

  @ApiProperty({ description: '时长（秒）' })
  durationSeconds: number;

  @ApiProperty({ description: '海拔爬升' })
  elevationGain: number;

  @ApiProperty({ description: '海拔下降' })
  elevationLoss: number;

  @ApiProperty({ description: '轨迹点数量' })
  pointCount: number;

  @ApiProperty({ description: 'POI数量' })
  poiCount: number;

  @ApiProperty({ description: '轨迹数据' })
  trackData: any;

  @ApiPropertyOptional({ description: '生成的路线ID' })
  trailId?: string;

  @ApiPropertyOptional({ description: '审核备注' })
  reviewComment?: string;

  @ApiProperty({ description: '创建时间' })
  createdAt: Date;

  @ApiProperty({ description: '更新时间' })
  updatedAt: Date;
}
