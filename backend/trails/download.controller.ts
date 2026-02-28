// download.controller.ts - 下载记录控制器
// 山径APP - 路线数据 API
// 功能：记录用户下载离线包行为

import {
  Controller,
  Post,
  Param,
  Body,
  UseGuards,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { DownloadsService } from './downloads.service';
import { JwtAuthGuard } from '../common/guards';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { DownloadActionResponseDto } from './dto/download-response.dto';

/**
 * 记录下载请求 DTO
 */
class RecordDownloadDto {
  deviceId?: string;
}

/**
 * 下载记录控制器
 *
 * 提供离线包下载记录相关的 REST API 接口：
 * - 记录用户下载离线包行为
 */
@ApiTags('路线下载')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('trails')
export class DownloadsController {
  constructor(private readonly downloadsService: DownloadsService) {}

  /**
   * 记录路线离线包下载
   *
   * 用户下载离线包时调用此接口记录下载行为
   */
  @Post(':id/download')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '记录路线离线包下载',
    description: '记录用户下载路线离线包的行为，返回离线包下载信息',
  })
  @ApiParam({ name: 'id', description: '路线ID', example: 'clq1234567890abcdef' })
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
  async recordDownload(
    @CurrentUser('userId') userId: string,
    @Param('id') trailId: string,
    @Body() dto: RecordDownloadDto,
  ): Promise<DownloadActionResponseDto> {
    return this.downloadsService.recordDownload(userId, trailId, dto.deviceId);
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

  // 用户下载历史接口由其他任务实现
}
