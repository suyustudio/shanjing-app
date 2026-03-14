/**
 * 收藏控制器
 * 
 * 提供用户收藏功能的 REST API
 */

import {
  Controller,
  Get,
  Post,
  Delete,
  Param,
  Query,
  Body,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { FavoritesService } from './favorites.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import {
  FavoriteListQueryDto,
  AddFavoriteDto,
  FavoriteListResponseDto,
  FavoriteStatusResponseDto,
  FavoriteActionResponseDto,
} from './dto/favorite.dto';

@ApiTags('收藏')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('favorites')
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '获取收藏列表', 
    description: '获取当前用户的收藏路线列表' 
  })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: FavoriteListResponseDto,
  })
  @ApiResponse({ status: 401, description: '未授权' })
  async getUserFavorites(
    @CurrentUser('userId') userId: string,
    @Query() query: FavoriteListQueryDto,
  ) {
    return this.favoritesService.getUserFavorites(userId, query);
  }

  @Post()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '添加收藏', 
    description: '收藏指定路线' 
  })
  @ApiResponse({
    status: 200,
    description: '收藏成功',
    type: FavoriteActionResponseDto,
  })
  @ApiResponse({ status: 400, description: '参数错误' })
  @ApiResponse({ status: 401, description: '未授权' })
  @ApiResponse({ status: 404, description: '路线不存在' })
  @ApiResponse({ status: 409, description: '已收藏过该路线' })
  async addFavorite(
    @CurrentUser('userId') userId: string,
    @Body() dto: AddFavoriteDto,
  ) {
    return this.favoritesService.addFavorite(userId, dto.trailId);
  }

  @Delete(':trailId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '取消收藏', 
    description: '取消收藏指定路线' 
  })
  @ApiParam({ name: 'trailId', description: '路线ID' })
  @ApiResponse({
    status: 200,
    description: '取消收藏成功',
    type: FavoriteActionResponseDto,
  })
  @ApiResponse({ status: 401, description: '未授权' })
  @ApiResponse({ status: 404, description: '未找到收藏记录' })
  async removeFavorite(
    @CurrentUser('userId') userId: string,
    @Param('trailId') trailId: string,
  ) {
    return this.favoritesService.removeFavorite(userId, trailId);
  }

  @Post('toggle')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '切换收藏状态', 
    description: '如果已收藏则取消，未收藏则添加' 
  })
  @ApiResponse({
    status: 200,
    description: '操作成功',
    type: FavoriteActionResponseDto,
  })
  @ApiResponse({ status: 400, description: '参数错误' })
  @ApiResponse({ status: 401, description: '未授权' })
  @ApiResponse({ status: 404, description: '路线不存在' })
  async toggleFavorite(
    @CurrentUser('userId') userId: string,
    @Body() dto: AddFavoriteDto,
  ) {
    return this.favoritesService.toggleFavorite(userId, dto.trailId);
  }

  @Get('status/:trailId')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '检查收藏状态', 
    description: '检查当前用户是否已收藏指定路线' 
  })
  @ApiParam({ name: 'trailId', description: '路线ID' })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: FavoriteStatusResponseDto,
  })
  @ApiResponse({ status: 401, description: '未授权' })
  async checkFavoriteStatus(
    @CurrentUser('userId') userId: string,
    @Param('trailId') trailId: string,
  ) {
    return this.favoritesService.checkFavoriteStatus(userId, trailId);
  }
}
