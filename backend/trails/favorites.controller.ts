// favorites.controller.ts - 收藏控制器
// 山径APP - 路线数据 API
// 功能：收藏/取消收藏路线、获取收藏列表

import {
  Controller,
  Post,
  Delete,
  Get,
  Param,
  Query,
  UseGuards,
  ParseIntPipe,
  DefaultValuePipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiParam, ApiQuery, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '../common/guards';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ListFavoritesDto, FavoriteSortBy } from './dto/list-favorites.dto';
import {
  FavoriteActionResponseDto,
  FavoriteListResponseDto,
  FavoriteCheckResponseDto,
} from './dto/favorite-response.dto';

/**
 * 收藏控制器
 *
 * 提供路线收藏相关的 REST API 接口：
 * - 收藏路线
 * - 取消收藏路线
 * - 获取用户收藏列表
 * - 检查收藏状态
 */
@ApiTags('路线收藏')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('trails')
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  /**
   * 收藏路线
   *
   * 将指定路线添加到当前用户的收藏列表
   */
  @Post(':id/favorite')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '收藏路线',
    description: '将指定路线添加到当前用户的收藏列表，并更新路线的收藏数',
  })
  @ApiParam({ name: 'id', description: '路线ID', example: 'clq1234567890abcdef' })
  @ApiResponse({
    status: 200,
    description: '收藏成功',
    type: FavoriteActionResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  @ApiResponse({
    status: 404,
    description: '路线不存在或未发布',
  })
  @ApiResponse({
    status: 409,
    description: '该路线已收藏',
  })
  async addFavorite(
    @CurrentUser('userId') userId: string,
    @Param('id') trailId: string,
  ): Promise<FavoriteActionResponseDto> {
    return this.favoritesService.addFavorite(userId, trailId);
  }

  /**
   * 取消收藏路线
   *
   * 从当前用户的收藏列表中移除指定路线
   */
  @Delete(':id/favorite')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '取消收藏路线',
    description: '从当前用户的收藏列表中移除指定路线，并更新路线的收藏数',
  })
  @ApiParam({ name: 'id', description: '路线ID', example: 'clq1234567890abcdef' })
  @ApiResponse({
    status: 200,
    description: '取消收藏成功',
    type: FavoriteActionResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  @ApiResponse({
    status: 404,
    description: '路线不存在或未收藏',
  })
  async removeFavorite(
    @CurrentUser('userId') userId: string,
    @Param('id') trailId: string,
  ): Promise<FavoriteActionResponseDto> {
    return this.favoritesService.removeFavorite(userId, trailId);
  }

  /**
   * 检查收藏状态
   *
   * 检查当前用户是否已收藏指定路线
   */
  @Get(':id/favorite')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '检查收藏状态',
    description: '检查当前用户是否已收藏指定路线',
  })
  @ApiParam({ name: 'id', description: '路线ID', example: 'clq1234567890abcdef' })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: FavoriteCheckResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  async checkFavorite(
    @CurrentUser('userId') userId: string,
    @Param('id') trailId: string,
  ): Promise<FavoriteCheckResponseDto> {
    return this.favoritesService.checkFavoriteStatus(userId, trailId);
  }
}

/**
 * 用户收藏列表控制器
 *
 * 提供用户收藏列表相关的 REST API 接口
 */
@ApiTags('用户收藏')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UserFavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  /**
   * 获取用户收藏的路线列表
   *
   * 获取当前用户收藏的所有路线，支持分页和排序
   */
  @Get('favorites')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '获取用户收藏的路线列表',
    description: '获取当前用户收藏的所有路线，支持分页、城市筛选和多种排序方式',
  })
  @ApiQuery({ name: 'page', required: false, description: '页码，默认1', type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量，默认20，最大100', type: Number, example: 20 })
  @ApiQuery({
    name: 'sortBy',
    required: false,
    description: '排序方式：newest(最新收藏), oldest(最早收藏), name(路线名称), distance(距离), duration(时长)',
    enum: FavoriteSortBy,
    example: 'newest',
  })
  @ApiQuery({
    name: 'sortOrder',
    required: false,
    description: '排序顺序：asc(升序), desc(降序)',
    enum: ['asc', 'desc'],
    example: 'desc',
  })
  @ApiQuery({
    name: 'city',
    required: false,
    description: '城市筛选',
    type: String,
    example: '杭州',
  })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: FavoriteListResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  async getUserFavorites(
    @CurrentUser('userId') userId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
    @Query('sortBy', new DefaultValuePipe(FavoriteSortBy.NEWEST)) sortBy: FavoriteSortBy,
    @Query('sortOrder', new DefaultValuePipe('desc')) sortOrder: 'asc' | 'desc',
    @Query('city') city?: string,
  ): Promise<FavoriteListResponseDto> {
    const dto: ListFavoritesDto = {
      page,
      limit: Math.min(limit, 100),
      sortBy,
      sortOrder,
      city,
    };

    return this.favoritesService.getUserFavorites(userId, dto);
  }
}
