// collections.controller.ts
// 山径APP - 收藏夹控制器

import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  ParseIntPipe,
  DefaultValuePipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiQuery, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { CollectionsService } from './collections.service';
import { JwtAuthGuard } from '../common/guards';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import {
  CreateCollectionDto,
  UpdateCollectionDto,
  AddTrailToCollectionDto,
  SortTrailsDto,
} from './dto/collection.dto';
import {
  CollectionResponseDto,
  CollectionListResponseDto,
  CollectionDetailResponseDto,
  CollectionActionResponseDto,
} from './dto/collection-response.dto';

/**
 * 收藏夹控制器
 * 
 * 提供收藏夹管理的 REST API 接口
 */
@ApiTags('收藏夹')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('collections')
export class CollectionsController {
  constructor(private readonly collectionsService: CollectionsService) {}

  /**
   * 获取收藏夹列表
   */
  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '获取收藏夹列表',
    description: '获取当前用户的收藏夹列表',
  })
  @ApiQuery({ name: 'userId', required: false, description: '用户ID（查看他人公开收藏夹）' })
  @ApiResponse({ status: 200, description: '获取成功', type: CollectionListResponseDto })
  async getCollections(
    @CurrentUser('userId') currentUserId: string,
    @Query('userId') targetUserId?: string,
  ): Promise<CollectionListResponseDto> {
    return this.collectionsService.getCollections(currentUserId, targetUserId);
  }

  /**
   * 创建收藏夹
   */
  @Post()
  @HttpCode(HttpStatus.CREATED)
  @ApiOperation({
    summary: '创建收藏夹',
    description: '创建新的收藏夹',
  })
  @ApiResponse({ status: 201, description: '创建成功', type: CollectionResponseDto })
  @ApiResponse({ status: 400, description: '参数错误' })
  @ApiResponse({ status: 409, description: '名称已存在' })
  async createCollection(
    @CurrentUser('userId') userId: string,
    @Body() dto: CreateCollectionDto,
  ): Promise<CollectionResponseDto> {
    return this.collectionsService.createCollection(userId, dto);
  }

  /**
   * 获取收藏夹详情
   */
  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '获取收藏夹详情',
    description: '获取收藏夹详情及路线列表',
  })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiQuery({ name: 'page', required: false, description: '页码', example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量', example: 20 })
  @ApiResponse({ status: 200, description: '获取成功', type: CollectionDetailResponseDto })
  @ApiResponse({ status: 403, description: '私密收藏夹' })
  @ApiResponse({ status: 404, description: '收藏夹不存在' })
  async getCollectionDetail(
    @CurrentUser('userId') currentUserId: string,
    @Param('id') collectionId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
  ): Promise<CollectionDetailResponseDto> {
    return this.collectionsService.getCollectionDetail(currentUserId, collectionId, page, limit);
  }

  /**
   * 更新收藏夹
   */
  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '更新收藏夹',
    description: '更新收藏夹信息',
  })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '更新成功', type: CollectionResponseDto })
  @ApiResponse({ status: 403, description: '无权限' })
  @ApiResponse({ status: 404, description: '收藏夹不存在' })
  async updateCollection(
    @CurrentUser('userId') userId: string,
    @Param('id') collectionId: string,
    @Body() dto: UpdateCollectionDto,
  ): Promise<CollectionResponseDto> {
    return this.collectionsService.updateCollection(userId, collectionId, dto);
  }

  /**
   * 删除收藏夹
   */
  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '删除收藏夹',
    description: '删除收藏夹及其所有路线关联',
  })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '删除成功' })
  @ApiResponse({ status: 403, description: '无权限' })
  @ApiResponse({ status: 404, description: '收藏夹不存在' })
  async deleteCollection(
    @CurrentUser('userId') userId: string,
    @Param('id') collectionId: string,
  ): Promise<CollectionActionResponseDto> {
    return this.collectionsService.deleteCollection(userId, collectionId);
  }

  /**
   * 添加路线到收藏夹
   */
  @Post(':id/trails')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '添加路线到收藏夹',
    description: '将路线添加到指定收藏夹',
  })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '添加成功', type: CollectionActionResponseDto })
  @ApiResponse({ status: 403, description: '无权限' })
  @ApiResponse({ status: 404, description: '收藏夹或路线不存在' })
  @ApiResponse({ status: 409, description: '路线已在收藏夹中' })
  async addTrailToCollection(
    @CurrentUser('userId') userId: string,
    @Param('id') collectionId: string,
    @Body() dto: AddTrailToCollectionDto,
  ): Promise<CollectionActionResponseDto> {
    return this.collectionsService.addTrailToCollection(userId, collectionId, dto);
  }

  /**
   * 从收藏夹移除路线
   */
  @Delete(':id/trails/:trailId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '从收藏夹移除路线',
    description: '从收藏夹中移除指定路线',
  })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiParam({ name: 'trailId', description: '路线ID' })
  @ApiResponse({ status: 200, description: '移除成功', type: CollectionActionResponseDto })
  @ApiResponse({ status: 403, description: '无权限' })
  @ApiResponse({ status: 404, description: '收藏夹或路线不存在' })
  async removeTrailFromCollection(
    @CurrentUser('userId') userId: string,
    @Param('id') collectionId: string,
    @Param('trailId') trailId: string,
  ): Promise<CollectionActionResponseDto> {
    return this.collectionsService.removeTrailFromCollection(userId, collectionId, trailId);
  }

  /**
   * 排序收藏夹内路线
   */
  @Put(':id/sort')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '排序收藏夹内路线',
    description: '调整收藏夹内路线的排序',
  })
  @ApiParam({ name: 'id', description: '收藏夹ID' })
  @ApiResponse({ status: 200, description: '排序成功', type: CollectionActionResponseDto })
  @ApiResponse({ status: 403, description: '无权限' })
  async sortTrailsInCollection(
    @CurrentUser('userId') userId: string,
    @Param('id') collectionId: string,
    @Body() dto: SortTrailsDto,
  ): Promise<CollectionActionResponseDto> {
    return this.collectionsService.sortTrailsInCollection(userId, collectionId, dto);
  }
}

/**
 * 快速收藏控制器
 */
@ApiTags('快速收藏')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('trails')
export class QuickCollectController {
  constructor(private readonly collectionsService: CollectionsService) {}

  /**
   * 快速收藏（添加到默认收藏夹）
   */
  @Post(':id/collect')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '快速收藏路线',
    description: '将路线快速收藏到默认收藏夹（想去）',
  })
  @ApiParam({ name: 'id', description: '路线ID' })
  @ApiResponse({ status: 200, description: '操作成功' })
  async quickCollect(
    @CurrentUser('userId') userId: string,
    @Param('id') trailId: string,
  ): Promise<CollectionActionResponseDto> {
    return this.collectionsService.quickCollect(userId, trailId);
  }
}
