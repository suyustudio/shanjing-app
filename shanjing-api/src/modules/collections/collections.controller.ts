// ================================================================
// M6: 收藏夹系统 Controller
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
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse, ApiQuery } from '@nestjs/swagger';
import { CollectionsService } from './collections.service';
import {
  CreateCollectionDto,
  UpdateCollectionDto,
  AddTrailToCollectionDto,
  BatchAddTrailsDto,
  BatchRemoveTrailsDto,
  BatchMoveTrailsDto,
  SearchCollectionTrailsDto,
  QueryCollectionsDto,
  CollectionDto,
  CollectionDetailDto,
  CollectionListResponseDto,
} from './dto/collection.dto';
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

@ApiTags('收藏夹系统')
@Controller('v1')
export class CollectionsController {
  constructor(private readonly collectionsService: CollectionsService) {}

  /**
   * 创建收藏夹
   * POST /v1/collections
   */
  @Post('collections')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '创建收藏夹' })
  @ApiResponse({ status: 201, description: '创建成功', type: CollectionDto })
  async createCollection(
    @Req() req: RequestWithUser,
    @Body() dto: CreateCollectionDto,
  ) {
    const collection = await this.collectionsService.createCollection(req.user.userId, dto);
    return wrapResponse(collection);
  }

  /**
   * 获取收藏夹列表
   * GET /v1/collections
   */
  @Get('collections')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取收藏夹列表' })
  @ApiResponse({ status: 200, description: '获取成功', type: CollectionListResponseDto })
  async getCollections(
    @Req() req: RequestWithUser,
    @Query() query: QueryCollectionsDto,
  ) {
    const currentUserId = req.user?.userId;
    const result = await this.collectionsService.getCollections(query, currentUserId);
    return wrapResponse(result, {
      total: result.total,
      page: result.page,
      limit: result.limit,
    });
  }

  /**
   * 获取收藏夹详情
   * GET /v1/collections/:id
   */
  @Get('collections/:id')
  @ApiOperation({ summary: '获取收藏夹详情' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '获取成功', type: CollectionDetailDto })
  async getCollectionDetail(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ) {
    const currentUserId = req.user?.userId;
    const collection = await this.collectionsService.getCollectionDetail(id, currentUserId);
    return wrapResponse(collection);
  }

  /**
   * 更新收藏夹
   * PUT /v1/collections/:id
   */
  @Put('collections/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '更新收藏夹' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '更新成功', type: CollectionDto })
  async updateCollection(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: UpdateCollectionDto,
  ) {
    const collection = await this.collectionsService.updateCollection(
      req.user.userId,
      id,
      dto,
    );
    return wrapResponse(collection);
  }

  /**
   * 删除收藏夹
   * DELETE /v1/collections/:id
   */
  @Delete('collections/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除收藏夹' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '删除成功' })
  async deleteCollection(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ) {
    await this.collectionsService.deleteCollection(req.user.userId, id);
    return wrapResponse({ message: '删除成功' });
  }

  /**
   * 添加路线到收藏夹
   * POST /v1/collections/:id/trails
   */
  @Post('collections/:id/trails')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '添加路线到收藏夹' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '添加成功', type: CollectionDetailDto })
  async addTrailToCollection(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: AddTrailToCollectionDto,
  ) {
    const collection = await this.collectionsService.addTrailToCollection(
      req.user.userId,
      id,
      dto,
    );
    return wrapResponse(collection);
  }

  /**
   * 批量添加路线到收藏夹
   * POST /v1/collections/:id/trails/batch
   */
  @Post('collections/:id/trails/batch')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '批量添加路线到收藏夹' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '添加成功', type: CollectionDetailDto })
  async batchAddTrails(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: BatchAddTrailsDto,
  ) {
    const collection = await this.collectionsService.batchAddTrails(
      req.user.userId,
      id,
      dto,
    );
    return wrapResponse(collection);
  }

  /**
   * 从收藏夹移除路线
   * DELETE /v1/collections/:collectionId/trails/:trailId
   */
  @Delete('collections/:collectionId/trails/:trailId')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '从收藏夹移除路线' })
  @ApiParam({ name: 'collectionId', description: '收藏夹ID' })
  @ApiParam({ name: 'trailId', description: '路线ID' })
  @ApiResponse({ status: 200, description: '移除成功' })
  async removeTrailFromCollection(
    @Req() req: RequestWithUser,
    @Param('collectionId') collectionId: string,
    @Param('trailId') trailId: string,
  ) {
    await this.collectionsService.removeTrailFromCollection(
      req.user.userId,
      collectionId,
      trailId,
    );
    return wrapResponse({ message: '移除成功' });
  }

  /**
   * 批量从收藏夹移除路线
   * DELETE /v1/collections/:id/trails/batch
   */
  @Delete('collections/:id/trails/batch')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '批量从收藏夹移除路线' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '移除成功' })
  async batchRemoveTrails(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: BatchRemoveTrailsDto,
  ) {
    await this.collectionsService.batchRemoveTrails(
      req.user.userId,
      id,
      dto,
    );
    return wrapResponse({ message: '移除成功' });
  }

  /**
   * 批量移动路线到其他收藏夹
   * POST /v1/collections/:id/trails/move
   */
  @Post('collections/:id/trails/move')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '批量移动路线到其他收藏夹' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '移动成功', type: CollectionDetailDto })
  async batchMoveTrails(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: BatchMoveTrailsDto,
  ) {
    const collection = await this.collectionsService.batchMoveTrails(
      req.user.userId,
      id,
      dto,
    );
    return wrapResponse(collection);
  }

  /**
   * 搜索收藏夹内路线
   * GET /v1/collections/:id/search
   */
  @Get('collections/:id/search')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '搜索收藏夹内路线' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '搜索成功', type: CollectionDetailDto })
  async searchCollectionTrails(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Query() dto: SearchCollectionTrailsDto,
  ) {
    const collection = await this.collectionsService.searchCollectionTrails(
      req.user.userId,
      id,
      dto,
    );
    return wrapResponse(collection);
  }

  // ==================== 标签管理 ====================

  /**
   * 获取所有标签
   * GET /v1/collections/tags
   */
  @Get('collections/tags')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取所有标签' })
  @ApiQuery({ name: 'userId', required: false, description: '用户ID（可选，不传则获取当前用户）' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getAllTags(
    @Req() req: RequestWithUser,
    @Query('userId') userId?: string,
  ) {
    const targetUserId = userId || req.user.userId;
    const tags = await this.collectionsService.getAllTags(targetUserId);
    return wrapResponse(tags);
  }

  /**
   * 创建标签
   * POST /v1/collections/tags
   */
  @Post('collections/tags')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '创建标签' })
  @ApiResponse({ status: 200, description: '创建成功' })
  async createTag(
    @Req() req: RequestWithUser,
    @Body() body: { name: string, color?: string },
  ) {
    const tag = await this.collectionsService.createTag(req.user.userId, body.name, body.color);
    return wrapResponse(tag);
  }

  /**
   * 删除标签
   * DELETE /v1/collections/tags/:name
   */
  @Delete('collections/tags/:name')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除标签' })
  @ApiParam({ name: 'name', description: '标签名' })
  @ApiResponse({ status: 200, description: '删除成功' })
  async deleteTag(
    @Req() req: RequestWithUser,
    @Param('name') tagName: string,
  ) {
    await this.collectionsService.deleteTag(req.user.userId, tagName);
    return wrapResponse({ message: '删除成功' });
  }

  /**
   * 获取收藏夹的标签
   * GET /v1/collections/:id/tags
   */
  @Get('collections/:id/tags')
  @ApiOperation({ summary: '获取收藏夹的标签' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getCollectionTags(
    @Req() req: RequestWithUser,
    @Param('id') collectionId: string,
  ) {
    const userId = req.user?.userId;
    const tags = await this.collectionsService.getCollectionTags(collectionId, userId);
    return wrapResponse(tags);
  }

  /**
   * 更新收藏夹标签
   * PUT /v1/collections/:id/tags
   */
  @Put('collections/:id/tags')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '更新收藏夹标签' })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '更新成功', type: CollectionDto })
  async updateCollectionTags(
    @Req() req: RequestWithUser,
    @Param('id') collectionId: string,
    @Body() body: { tags: string[] },
  ) {
    const collection = await this.collectionsService.updateCollectionTags(
      req.user.userId,
      collectionId,
      body.tags,
    );
    return wrapResponse(collection);
  }

  /**
   * 搜索标签
   * GET /v1/collections/tags/search
   */
  @Get('collections/tags/search')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '搜索标签' })
  @ApiQuery({ name: 'q', description: '搜索关键词' })
  @ApiQuery({ name: 'userId', required: false, description: '用户ID（可选）' })
  @ApiResponse({ status: 200, description: '搜索成功' })
  async searchTags(
    @Req() req: RequestWithUser,
    @Query('q') query: string,
    @Query('userId') userId?: string,
  ) {
    const targetUserId = userId || req.user.userId;
    const tags = await this.collectionsService.searchTags(query, targetUserId);
    return wrapResponse(tags);
  }
}
