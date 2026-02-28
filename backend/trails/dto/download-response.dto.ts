// download-response.dto.ts - 下载相关响应DTO
// 山径APP - 路线数据 API

import { ApiProperty } from '@nestjs/swagger';

/**
 * 下载记录DTO
 */
export class DownloadRecordDto {
  @ApiProperty({ description: '下载记录ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线ID', example: 'clq0987654321fedcba' })
  trailId: string;

  @ApiProperty({ description: '路线名称', example: '九溪十八涧徒步路线' })
  trailName: string;

  @ApiProperty({ description: '离线包ID', example: 'clqaaaa1111bbbb2222' })
  offlinePackageId: string;

  @ApiProperty({ description: '离线包版本', example: '1.0.0' })
  version: string;

  @ApiProperty({ description: '文件URL', example: 'https://example.com/packages/trail1.zip' })
  fileUrl: string;

  @ApiProperty({ description: '文件大小（MB）', example: 15.5 })
  fileSizeMb: number;

  @ApiProperty({ description: '文件校验值（SHA-256）', example: 'a1b2c3d4e5f6...' })
  checksum: string;

  @ApiProperty({ description: '下载时间', example: '2024-01-15T08:30:00.000Z' })
  downloadedAt: string;

  @ApiProperty({ description: '设备标识', example: 'device_abc123', required: false })
  deviceId?: string;
}

/**
 * 下载响应数据DTO
 */
export class DownloadActionDataDto {
  @ApiProperty({ description: '下载记录ID', example: 'clq1234567890abcdef' })
  id: string;

  @ApiProperty({ description: '路线ID', example: 'clq0987654321fedcba' })
  trailId: string;

  @ApiProperty({ description: '离线包信息' })
  offlinePackage: {
    @ApiProperty({ description: '离线包ID', example: 'clqaaaa1111bbbb2222' })
    id: string;

    @ApiProperty({ description: '版本号', example: '1.0.0' })
    version: string;

    @ApiProperty({ description: '文件URL', example: 'https://example.com/packages/trail1.zip' })
    fileUrl: string;

    @ApiProperty({ description: '文件大小（MB）', example: 15.5 })
    fileSizeMb: number;

    @ApiProperty({ description: '文件校验值（SHA-256）', example: 'a1b2c3d4e5f6...' })
    checksum: string;

    @ApiProperty({ description: '最小缩放级别', example: 12 })
    minZoom: number;

    @ApiProperty({ description: '最大缩放级别', example: 18 })
    maxZoom: number;

    @ApiProperty({ description: '边界框' })
    bounds: {
      north: number;
      south: number;
      east: number;
      west: number;
    };

    @ApiProperty({ description: '过期时间', example: '2025-01-15T08:30:00.000Z' })
    expiresAt: string;
  };

  @ApiProperty({ description: '下载时间', example: '2024-01-15T08:30:00.000Z' })
  downloadedAt: string;
}

/**
 * 下载操作响应DTO
 */
export class DownloadActionResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据', type: DownloadActionDataDto })
  data: DownloadActionDataDto;
}

/**
 * 下载历史列表数据DTO
 */
export class DownloadListDataDto {
  @ApiProperty({ description: '下载记录列表', type: [DownloadRecordDto] })
  items: DownloadRecordDto[];

  @ApiProperty({ description: '分页信息' })
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
    hasMore: boolean;
  };
}

/**
 * 下载历史列表响应DTO
 */
export class DownloadListResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据', type: DownloadListDataDto })
  data: DownloadListDataDto;
}
