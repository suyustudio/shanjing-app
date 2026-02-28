// downloads.controller.ts - 下载控制器
// 山径APP - 路线数据 API
// 功能：记录下载行为、获取下载历史

import {
  Controller,
  Post,
  Get,
  Param,
  Query,
  Body,
  UseGuards,
  ParseIntPipe,
  DefaultValuePipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiQuery, ApiBearerAuth, ApiResponse, ApiBody } from '@nestjs/swagger';
import { DownloadsService } from './downloads.service';
import { JwtAuthGuard } from '../common/guards';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ListDownloadsDto } from './dto/list-favorites.dto';
import {
  DownloadActionResponseDto,
  DownloadListResponseDto,
} from './dto/download-response.dto';

/**
 * 下载请求DTO
 */
class DownloadTrailDto {
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        deviceId: {
          type: 'string',
          description: '设备标识（可选）',
          example: 'device_abc123',
        },
      },
    },
  })
  deviceId?: string;
}

/**
 * 下载控制器
 *
 * 提供离线包下载相关的 REST API 接口：
 * - 记录下载行为
 * - 获取下载历史
 */
@ApiTags('离线包下载')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('trails')
export class DownloadsController {
  constructor(private readonly downloadsService: DownloadsService) {}

  /**
   * 下载路线离线包
   *
   * 记录用户下载路线离线包的行为，并返回离线包信息
   */
  @Post(':id/download')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '下载路线离线包',
    description: '记录用户下载路线离线包的行为，返回离线包下载信息（文件URL、校验值等）',
  })
  @ApiParam({ name: 'id', description: '路线ID', example: 'clq1234567890abcdef' })
  @ApiBody({
    schema: {
      type: 'object',
      properties: {
        deviceId: {
          type: 'string',
          description: '设备标识（可选，用于区分不同设备的下载记录）',
          example: 'device_abc123',
        },
      },
    },
  })
  @ApiResponse({
    status: 200,
    description: '下载记录成功',
    type: DownloadActionResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  @ApiResponse({
    status: 404,
    description: '路线不存在或未发布，或暂无可用离线包',
  })
  async downloadTrail(
    @CurrentUser('userId') userId: string,
    @Param('id') trailId: string,
    @Body('deviceId') deviceId?: string,
  ): Promise<DownloadActionResponseDto> {
    return this.downloadsService.recordDownload(userId, trailId, deviceId);
  }
}

/**
 * 用户下载历史控制器
 *
 * 提供用户下载历史相关的 REST API 接口
 */
@ApiTags('用户下载')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UserDownloadsController {
  constructor(private readonly downloadsService: DownloadsService) {}

  /**
   * 获取用户下载历史
   *
   * 获取当前用户的离线包下载历史记录
   */
  @Get('downloads')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '获取用户下载历史',
    description: '获取当前用户的离线包下载历史记录，按下载时间倒序排列',
  })
  @ApiQuery({ name: 'page', required: false, description: '页码，默认1', type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量，默认20，最大100', type: Number, example: 20 })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: DownloadListResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  async getUserDownloads(
    @CurrentUser('userId') userId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
  ): Promise<DownloadListResponseDto> {
    const dto: ListDownloadsDto = {
      page,
      limit: Math.min(limit, 100),
    };

    return this.downloadsService.getUserDownloads(userId, dto);
  }
}
