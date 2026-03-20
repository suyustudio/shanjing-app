// ================================================================
// Achievement Controller
// 成就系统控制器
// ================================================================

import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  UseGuards,
  Request,
  HttpCode,
  HttpStatus,
  Query,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { AdminGuard } from '../../common/guards/admin.guard';
import { AchievementsService } from './achievements.service';
import {
  AchievementDto,
  UserAchievementSummaryDto,
  CheckAchievementsRequestDto,
  CheckAchievementsResponseDto,
  UserStatsDto,
} from './dto/achievement.dto';

@ApiTags('成就系统')
@Controller('achievements')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class AchievementsController {
  constructor(private readonly achievementsService: AchievementsService) {}

  /**
   * 获取所有成就定义
   */
  @Get()
  @ApiOperation({ summary: '获取所有成就定义', description: '获取系统中所有成就的定义列表，包含等级信息' })
  @ApiResponse({
    status: 200,
    description: '成功获取成就列表',
    type: [AchievementDto],
  })
  async getAllAchievements(): Promise<AchievementDto[]> {
    return this.achievementsService.getAllAchievements();
  }

  /**
   * 获取单个成就定义
   */
  @Get(':id')
  @ApiOperation({ summary: '获取单个成就定义', description: '根据ID获取成就的详细信息' })
  @ApiResponse({
    status: 200,
    description: '成功获取成就信息',
    type: AchievementDto,
  })
  @ApiResponse({ status: 404, description: '成就不存在' })
  async getAchievementById(@Param('id') id: string): Promise<AchievementDto> {
    return this.achievementsService.getAchievementById(id);
  }

  /**
   * 获取当前用户成就
   */
  @Get('user/me')
  @ApiOperation({
    summary: '获取当前用户成就',
    description: '获取当前登录用户的所有成就状态和进度',
  })
  @ApiResponse({
    status: 200,
    description: '成功获取用户成就',
    type: UserAchievementSummaryDto,
  })
  async getMyAchievements(@Request() req): Promise<UserAchievementSummaryDto> {
    return this.achievementsService.getUserAchievements(req.user.userId);
  }

  /**
   * 获取指定用户成就
   */
  @Get('user/:userId')
  @ApiOperation({
    summary: '获取指定用户成就',
    description: '获取指定用户的成就列表（公开信息）',
  })
  @ApiResponse({
    status: 200,
    description: '成功获取用户成就',
    type: UserAchievementSummaryDto,
  })
  async getUserAchievements(
    @Param('userId') userId: string
  ): Promise<UserAchievementSummaryDto> {
    return this.achievementsService.getUserAchievements(userId);
  }

  /**
   * 检查并解锁成就
   */
  @Post('check')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '检查并解锁成就',
    description: '根据用户行为检查是否满足成就解锁条件，通常在轨迹完成或分享后调用',
  })
  @ApiResponse({
    status: 200,
    description: '检查完成，返回新解锁的成就和进度更新',
    type: CheckAchievementsResponseDto,
  })
  async checkAchievements(
    @Request() req,
    @Body() dto: CheckAchievementsRequestDto
  ): Promise<CheckAchievementsResponseDto> {
    return this.achievementsService.checkAchievements(req.user.userId, dto);
  }

  /**
   * 标记成就已查看
   */
  @Put(':id/viewed')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '标记成就已查看',
    description: '标记指定成就的新解锁状态为已查看',
  })
  @ApiResponse({
    status: 200,
    description: '标记成功',
  })
  async markAchievementViewed(
    @Request() req,
    @Param('id') achievementId: string
  ): Promise<{ success: boolean }> {
    await this.achievementsService.markAchievementViewed(req.user.userId, achievementId);
    return { success: true };
  }

  /**
   * 标记所有成就已查看
   */
  @Put('viewed/all')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '标记所有成就已查看',
    description: '将所有新解锁的成就标记为已查看',
  })
  @ApiResponse({
    status: 200,
    description: '标记成功',
  })
  async markAllAchievementsViewed(@Request() req): Promise<{ success: boolean }> {
    await this.achievementsService.markAllAchievementsViewed(req.user.userId);
    return { success: true };
  }
}

/**
 * 成就缓存管理控制器（管理员）
 */
@ApiTags('成就缓存管理')
@Controller('achievements/admin/cache')
@UseGuards(JwtAuthGuard, AdminGuard)
@ApiBearerAuth()
export class AchievementCacheController {
  constructor(private readonly achievementsService: AchievementsService) {}

  /**
   * 清除所有成就缓存
   */
  @Delete('all')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '清除所有成就缓存',
    description: '管理员接口：清除所有成就相关的缓存',
  })
  @ApiResponse({ status: 200, description: '清除成功' })
  async clearAllCache(): Promise<{ success: boolean; message: string }> {
    await this.achievementsService.clearAllAchievementCache();
    return { success: true, message: '所有成就缓存已清除' };
  }

  /**
   * 按标签清除缓存
   */
  @Delete('by-tag')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '按标签清除缓存',
    description: '管理员接口：按指定标签批量清除缓存',
  })
  @ApiResponse({ status: 200, description: '清除成功' })
  async invalidateByTag(
    @Query('tag') tag: string
  ): Promise<{ success: boolean; deletedCount: number }> {
    const deletedCount = await this.achievementsService.invalidateCacheByTag(tag);
    return { success: true, deletedCount };
  }
}

/**
 * 用户统计控制器
 */
@ApiTags('用户统计')
@Controller('users/me/stats')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class UserStatsController {
  constructor(private readonly achievementsService: AchievementsService) {}

  /**
   * 获取用户统计
   */
  @Get()
  @ApiOperation({
    summary: '获取用户统计',
    description: '获取当前用户的徒步统计数据',
  })
  @ApiResponse({
    status: 200,
    description: '成功获取用户统计',
    type: UserStatsDto,
  })
  async getUserStats(@Request() req): Promise<UserStatsDto> {
    return this.achievementsService.getUserStats(req.user.userId);
  }
}
