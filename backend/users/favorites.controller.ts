// favorites.controller.ts - 用户收藏控制器
// 山径APP - 用户模块
// 功能：获取当前用户收藏的路线列表

import {
  Controller,
  Get,
  Query,
  UseGuards,
  ParseIntPipe,
  DefaultValuePipe,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../shanjing-api/src/common/guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { PrismaService } from '../../shanjing-api/src/database/prisma.service';

@ApiTags('用户 - 收藏管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class FavoritesController {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * 获取当前用户收藏的路线列表
   * GET /users/favorites
   */
  @Get('favorites')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '获取用户收藏的路线列表',
    description: '获取当前登录用户收藏的所有路线列表',
  })
  @ApiQuery({ name: 'page', required: false, description: '页码，默认1', type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量，默认20', type: Number, example: 20 })
  @ApiResponse({ status: 200, description: '获取成功' })
  @ApiResponse({ status: 401, description: '未登录或Token无效' })
  async getUserFavorites(
    @CurrentUser('userId') userId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
  ) {
    const skip = (page - 1) * limit;

    const [favorites, total] = await Promise.all([
      this.prisma.favorite.findMany({
        where: { userId },
        skip,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          trail: {
            select: {
              id: true,
              name: true,
              distanceKm: true,
              durationMin: true,
              difficulty: true,
              coverImages: true,
              city: true,
            },
          },
        },
      }),
      this.prisma.favorite.count({ where: { userId } }),
    ]);

    const items = favorites.map((f) => ({
      id: f.trail.id,
      name: f.trail.name,
      distanceKm: f.trail.distanceKm,
      durationMin: f.trail.durationMin,
      difficulty: f.trail.difficulty,
      coverImage: f.trail.coverImages[0] || null,
      city: f.trail.city,
      favoritedAt: f.createdAt.toISOString(),
    }));

    return {
      success: true,
      data: {
        items,
        pagination: {
          page,
          limit,
          total,
          totalPages: Math.ceil(total / limit),
          hasMore: page < Math.ceil(total / limit),
        },
      },
    };
  }
}
