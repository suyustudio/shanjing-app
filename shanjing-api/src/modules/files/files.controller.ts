import {
  Controller,
  Post,
  Body,
  UseGuards,
  Req,
  Get,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth } from '@nestjs/swagger';
import { OssService, PresignedUrlResult } from './oss.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { Request } from 'express';

interface RequestWithUser extends Request {
  user: {
    userId: string;
  };
}

class GenerateUploadUrlDto {
  filename: string;
  contentType: string;
}

class BatchUploadUrlDto {
  files: { filename: string; contentType: string }[];
}

@ApiTags('文件上传')
@Controller('v1/files')
export class FilesController {
  constructor(private readonly ossService: OssService) {}

  /**
   * 获取单张照片上传凭证
   */
  @Post('upload-url')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取照片上传凭证' })
  async getUploadUrl(
    @Req() req: RequestWithUser,
    @Body() dto: GenerateUploadUrlDto,
  ) {
    const result = await this.ossService.generatePhotoUploadUrl(
      req.user.userId,
      dto.filename,
      dto.contentType,
    );
    return {
      success: true,
      data: result,
    };
  }

  /**
   * 批量获取上传凭证
   */
  @Post('upload-urls')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '批量获取照片上传凭证' })
  async getBatchUploadUrls(
    @Req() req: RequestWithUser,
    @Body() dto: BatchUploadUrlDto,
  ) {
    const results = await this.ossService.generateBatchUploadUrls(
      req.user.userId,
      dto.files,
    );
    return {
      success: true,
      data: results,
    };
  }

  /**
   * 检查 OSS 配置状态
   */
  @Get('status')
  @ApiOperation({ summary: '检查 OSS 配置状态' })
  getStatus() {
    return {
      success: true,
      data: {
        configured: this.ossService.isConfigured(),
      },
    };
  }
}
