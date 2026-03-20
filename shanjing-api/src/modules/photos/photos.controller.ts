// ================================================================
// M6: 照片系统 Controller
// ================================================================

import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse } from '@nestjs/swagger';
import { PhotosService } from './photos.service';
import {
  CreatePhotoDto,
  CreatePhotosDto,
  UpdatePhotoDto,
  QueryPhotosDto,
  PhotoDto,
  PhotoListResponseDto,
  LikePhotoResponseDto,
} from './dto/photo.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { Request } from 'express';

interface RequestWithUser extends Request {
  user: {
    userId: string;
  };
}

function wrapResponse<T>(data: T, meta?: any) {
  return {
    success: true,
    data,
    meta,
  };
}

@ApiTags('照片系统')
@Controller('v1/photos')
export class PhotosController {
  constructor(private readonly photosService: PhotosService) {}

  /**
   * 上传单张照片
   * POST /v1/photos
   */
  @Post()
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '上传单张照片' })
  @ApiResponse({ status: 201, description: '上传成功', type: PhotoDto })
  async createPhoto(
    @Req() req: RequestWithUser,
    @Body() dto: CreatePhotoDto,
  ) {
    const photo = await this.photosService.createPhoto(req.user.userId, dto);
    return wrapResponse(photo);
  }

  /**
   * 批量上传照片
   * POST /v1/photos/batch
   */
  @Post('batch')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '批量上传照片' })
  @ApiResponse({ status: 201, description: '上传成功', type: [PhotoDto] })
  async createPhotos(
    @Req() req: RequestWithUser,
    @Body() dto: CreatePhotosDto,
  ) {
    const photos = await this.photosService.createPhotos(req.user.userId, dto);
    return wrapResponse(photos);
  }

  /**
   * 获取照片列表 (瀑布流)
   * GET /v1/photos
   */
  @Get()
  @ApiOperation({ summary: '获取照片列表 (瀑布流)' })
  @ApiResponse({ status: 200, description: '获取成功', type: PhotoListResponseDto })
  async getPhotos(
    @Req() req: RequestWithUser,
    @Query() query: QueryPhotosDto,
  ) {
    const currentUserId = req.user?.userId;
    const result = await this.photosService.getPhotos(query, currentUserId);
    return wrapResponse(result, {
      nextCursor: result.nextCursor,
      hasMore: result.hasMore,
    });
  }

  /**
   * 获取照片详情
   * GET /v1/photos/:id
   */
  @Get(':id')
  @ApiOperation({ summary: '获取照片详情' })
  @ApiParam({ name: 'id', description: '照片ID' })
  @ApiResponse({ status: 200, description: '获取成功', type: PhotoDto })
  async getPhotoDetail(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ) {
    const currentUserId = req.user?.userId;
    const photo = await this.photosService.getPhotoDetail(id, currentUserId);
    return wrapResponse(photo);
  }

  /**
   * 更新照片
   * PUT /v1/photos/:id
   */
  @Put(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '更新照片信息' })
  @ApiParam({ name: 'id', description: '照片ID' })
  @ApiResponse({ status: 200, description: '更新成功', type: PhotoDto })
  async updatePhoto(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: UpdatePhotoDto,
  ) {
    const photo = await this.photosService.updatePhoto(req.user.userId, id, dto);
    return wrapResponse(photo);
  }

  /**
   * 删除照片
   * DELETE /v1/photos/:id
   */
  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除照片' })
  @ApiParam({ name: 'id', description: '照片ID' })
  @ApiResponse({ status: 200, description: '删除成功' })
  async deletePhoto(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ) {
    await this.photosService.deletePhoto(req.user.userId, id);
    return wrapResponse({ message: '删除成功' });
  }

  /**
   * 点赞/取消点赞照片
   * POST /v1/photos/:id/like
   */
  @Post(':id/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '点赞/取消点赞照片' })
  @ApiParam({ name: 'id', description: '照片ID' })
  @ApiResponse({ status: 200, description: '操作成功', type: LikePhotoResponseDto })
  async likePhoto(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ) {
    const result = await this.photosService.likePhoto(req.user.userId, id);
    return wrapResponse(result);
  }

  /**
   * 获取用户的照片列表
   * GET /v1/users/:userId/photos
   */
  @Get('users/:userId/photos')
  @ApiOperation({ summary: '获取用户的照片列表' })
  @ApiParam({ name: 'userId', description: '用户ID' })
  @ApiResponse({ status: 200, description: '获取成功', type: PhotoListResponseDto })
  async getUserPhotos(
    @Req() req: RequestWithUser,
    @Param('userId') userId: string,
    @Query('cursor') cursor?: string,
    @Query('limit') limit?: number,
  ) {
    const currentUserId = req.user?.userId;
    const result = await this.photosService.getUserPhotos(
      userId,
      currentUserId,
      cursor,
      limit ? parseInt(limit as any) : 20,
    );
    return wrapResponse(result);
  }
}
