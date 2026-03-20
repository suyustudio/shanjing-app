// ================================================================
// M6: 关注系统 Controller
// ================================================================

import {
  Controller,
  Post,
  Delete,
  Get,
  Param,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { FollowsService } from './follows.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import {
  QueryFollowsDto,
  FollowListResponseDto,
  FollowStatsDto,
  FollowActionResponseDto,
} from './dto/follow.dto';

@ApiTags('关注系统')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('v1/users')
export class FollowsController {
  constructor(private readonly followsService: FollowsService) {}

  @Post(':id/follow')
  @ApiOperation({ summary: '关注用户' })
  @ApiResponse({ status: 200, description: '关注成功' })
  @ApiResponse({ status: 400, description: '不能关注自己' })
  @ApiResponse({ status: 404, description: '用户不存在' })
  async followUser(
    @CurrentUser('userId') currentUserId: string,
    @Param('id') targetUserId: string,
  ): Promise<FollowActionResponseDto> {
    return this.followsService.toggleFollow(currentUserId, targetUserId);
  }

  @Delete(':id/follow')
  @ApiOperation({ summary: '取消关注用户' })
  @ApiResponse({ status: 200, description: '取消关注成功' })
  @ApiResponse({ status: 404, description: '用户不存在' })
  async unfollowUser(
    @CurrentUser('userId') currentUserId: string,
    @Param('id') targetUserId: string,
  ): Promise<FollowActionResponseDto> {
    return this.followsService.toggleFollow(currentUserId, targetUserId);
  }

  @Get(':id/followers')
  @ApiOperation({ summary: '获取粉丝列表' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getFollowers(
    @CurrentUser('userId') currentUserId: string,
    @Param('id') userId: string,
    @Query() query: QueryFollowsDto,
  ): Promise<FollowListResponseDto> {
    return this.followsService.getFollowers(userId, query, currentUserId);
  }

  @Get(':id/following')
  @ApiOperation({ summary: '获取关注列表' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getFollowing(
    @CurrentUser('userId') currentUserId: string,
    @Param('id') userId: string,
    @Query() query: QueryFollowsDto,
  ): Promise<FollowListResponseDto> {
    return this.followsService.getFollowing(userId, query, currentUserId);
  }

  @Get(':id/follow-status')
  @ApiOperation({ summary: '获取关注状态' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getFollowStatus(
    @CurrentUser('userId') currentUserId: string,
    @Param('id') targetUserId: string,
  ): Promise<{ isFollowing: boolean; isMutual: boolean }> {
    const [currentUserStatus, targetUserStatus] = await Promise.all([
      this.followsService.checkFollowStatus(currentUserId, targetUserId),
      this.followsService.checkFollowStatus(targetUserId, currentUserId),
    ]);

    return {
      isFollowing: currentUserStatus.isFollowing,
      isMutual: currentUserStatus.isFollowing && targetUserStatus.isFollowing,
    };
  }

  @Get(':id/follow-stats')
  @ApiOperation({ summary: '获取关注统计' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getFollowStats(
    @CurrentUser('userId') currentUserId: string,
    @Param('id') userId: string,
  ): Promise<FollowStatsDto> {
    return this.followsService.getFollowStats(userId, currentUserId);
  }

  @Get('suggestions')
  @ApiOperation({ summary: '获取推荐关注用户' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getFollowSuggestions(
    @CurrentUser('userId') currentUserId: string,
    @Query('limit') limit: number = 10,
  ): Promise<FollowListResponseDto> {
    return this.followsService.getSuggestions(currentUserId, limit);
  }
}
