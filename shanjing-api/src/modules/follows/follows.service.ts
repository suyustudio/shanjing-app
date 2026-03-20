// ================================================================
// M6: 关注系统 Service
// ================================================================

import { Injectable, NotFoundException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import {
  QueryFollowsDto,
  FollowListResponseDto,
  FollowStatsDto,
  FollowActionResponseDto,
} from './dto/follow.dto';

@Injectable()
export class FollowsService {
  constructor(private prisma: PrismaService) {}

  /**
   * 关注/取消关注用户
   */
  async toggleFollow(
    followerId: string,
    followingId: string,
  ): Promise<FollowActionResponseDto> {
    // 不能关注自己
    if (followerId === followingId) {
      throw new BadRequestException('不能关注自己');
    }

    // 检查被关注用户是否存在
    const targetUser = await this.prisma.user.findUnique({
      where: { id: followingId },
    });
    if (!targetUser) {
      throw new NotFoundException('用户不存在');
    }

    // 检查是否已关注
    const existingFollow = await this.prisma.follow.findUnique({
      where: {
        followerId_followingId: {
          followerId,
          followingId,
        },
      },
    });

    if (existingFollow) {
      // 取消关注
      await this.prisma.follow.delete({
        where: { id: existingFollow.id },
      });

      // 更新双方的关注数
      await this.prisma.user.update({
        where: { id: followerId },
        data: { followingCount: { decrement: 1 } },
      });

      await this.prisma.user.update({
        where: { id: followingId },
        data: { followersCount: { decrement: 1 } },
      });

      return {
        isFollowing: false,
        followersCount: targetUser.followersCount - 1,
        followingCount: (await this.prisma.user.findUnique({
          where: { id: followerId },
          select: { followingCount: true },
        }))?.followingCount || 0,
      };
    } else {
      // 添加关注
      await this.prisma.follow.create({
        data: {
          followerId,
          followingId,
        },
      });

      // 更新双方的关注数
      await this.prisma.user.update({
        where: { id: followerId },
        data: { followingCount: { increment: 1 } },
      });

      await this.prisma.user.update({
        where: { id: followingId },
        data: { followersCount: { increment: 1 } },
      });

      return {
        isFollowing: true,
        followersCount: targetUser.followersCount + 1,
        followingCount: (await this.prisma.user.findUnique({
          where: { id: followerId },
          select: { followingCount: true },
        }))?.followingCount || 0,
      };
    }
  }

  /**
   * 获取关注列表
   */
  async getFollowing(
    userId: string,
    query: QueryFollowsDto,
    currentUserId?: string,
  ): Promise<FollowListResponseDto> {
    const where: any = { followerId: userId };

    if (query.cursor) {
      where.createdAt = { lt: new Date(query.cursor) };
    }

    const follows = await this.prisma.follow.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: query.limit + 1,
      include: {
        following: {
          select: {
            id: true,
            nickname: true,
            avatarUrl: true,
            followersCount: true,
            followingCount: true,
          },
        },
      },
    });

    const hasMore = follows.length > query.limit;
    const followList = hasMore ? follows.slice(0, query.limit) : follows;

    // 获取当前用户与这些用户的关系
    let followingIds: string[] = [];
    if (currentUserId) {
      const currentUserFollowing = await this.prisma.follow.findMany({
        where: {
          followerId: currentUserId,
          followingId: {
            in: followList.map(f => f.followingId),
          },
        },
        select: { followingId: true },
      });
      followingIds = currentUserFollowing.map(f => f.followingId);
    }

    const nextCursor = hasMore && followList.length > 0
      ? followList[followList.length - 1].createdAt.toISOString()
      : null;

    const total = await this.prisma.follow.count({
      where: { followerId: userId },
    });

    return {
      list: followList.map(f => ({
        id: f.following.id,
        nickname: f.following.nickname,
        avatarUrl: f.following.avatarUrl,
        followersCount: f.following.followersCount,
        isFollowing: followingIds.includes(f.followingId),
      })),
      nextCursor,
      hasMore,
      total,
    };
  }

  /**
   * 获取粉丝列表
   */
  async getFollowers(
    userId: string,
    query: QueryFollowsDto,
    currentUserId?: string,
  ): Promise<FollowListResponseDto> {
    const where: any = { followingId: userId };

    if (query.cursor) {
      where.createdAt = { lt: new Date(query.cursor) };
    }

    const follows = await this.prisma.follow.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      take: query.limit + 1,
      include: {
        follower: {
          select: {
            id: true,
            nickname: true,
            avatarUrl: true,
            followersCount: true,
            followingCount: true,
          },
        },
      },
    });

    const hasMore = follows.length > query.limit;
    const followList = hasMore ? follows.slice(0, query.limit) : follows;

    // 获取当前用户与这些用户的关系
    let followingIds: string[] = [];
    if (currentUserId) {
      const currentUserFollowing = await this.prisma.follow.findMany({
        where: {
          followerId: currentUserId,
          followingId: {
            in: followList.map(f => f.followerId),
          },
        },
        select: { followingId: true },
      });
      followingIds = currentUserFollowing.map(f => f.followingId);
    }

    const nextCursor = hasMore && followList.length > 0
      ? followList[followList.length - 1].createdAt.toISOString()
      : null;

    const total = await this.prisma.follow.count({
      where: { followingId: userId },
    });

    return {
      list: followList.map(f => ({
        id: f.follower.id,
        nickname: f.follower.nickname,
        avatarUrl: f.follower.avatarUrl,
        followersCount: f.follower.followersCount,
        isFollowing: followingIds.includes(f.followerId),
      })),
      nextCursor,
      hasMore,
      total,
    };
  }

  /**
   * 获取关注统计
   */
  async getFollowStats(
    userId: string,
    currentUserId?: string,
  ): Promise<FollowStatsDto> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        followersCount: true,
        followingCount: true,
      },
    });

    if (!user) {
      throw new NotFoundException('用户不存在');
    }

    let isFollowing = false;
    if (currentUserId && currentUserId !== userId) {
      const follow = await this.prisma.follow.findUnique({
        where: {
          followerId_followingId: {
            followerId: currentUserId,
            followingId: userId,
          },
        },
      });
      isFollowing = !!follow;
    }

    return {
      followersCount: user.followersCount,
      followingCount: user.followingCount,
      isFollowing,
    };
  }

  /**
   * 检查关注关系
   */
  async checkFollowStatus(
    followerId: string,
    followingId: string,
  ): Promise<{ isFollowing: boolean }> {
    const follow = await this.prisma.follow.findUnique({
      where: {
        followerId_followingId: {
          followerId,
          followingId,
        },
      },
    });

    return { isFollowing: !!follow };
  }

  /**
   * 获取推荐关注用户
   * 基于：热门用户、有共同关注的人、活跃度高的用户
   */
  async getSuggestions(
    userId: string,
    limit: number = 10,
  ): Promise<FollowListResponseDto> {
    // 1. 获取当前用户已关注的用户ID
    const userFollowing = await this.prisma.follow.findMany({
      where: { followerId: userId },
      select: { followingId: true },
    });
    const followingIds = new Set(userFollowing.map(f => f.followingId));
    followingIds.add(userId); // 排除自己

    // 2. 获取推荐用户
    // 策略1: 粉丝数多的活跃用户
    const suggestedUsers = await this.prisma.user.findMany({
      where: {
        id: {
          notIn: Array.from(followingIds),
        },
        followersCount: {
          gt: 0,
        },
      },
      orderBy: [
        { followersCount: 'desc' },
        { createdAt: 'desc' },
      ],
      take: limit,
      select: {
        id: true,
        nickname: true,
        avatarUrl: true,
        followersCount: true,
      },
    });

    // 3. 计算共同关注数（如果有关注的人）
    let mutualFollowCounts: Map<string, number> = new Map();
    if (userFollowing.length > 0) {
      const followingIdList = userFollowing.map(f => f.followingId);
      
      // 查找这些用户的关注者中，也在 suggestedUsers 中的
      const mutualRelations = await this.prisma.follow.findMany({
        where: {
          followerId: {
            in: followingIdList,
          },
          followingId: {
            in: suggestedUsers.map(u => u.id),
          },
        },
        select: {
          followingId: true,
        },
      });

      // 统计共同关注数
      for (const relation of mutualRelations) {
        const count = mutualFollowCounts.get(relation.followingId) || 0;
        mutualFollowCounts.set(relation.followingId, count + 1);
      }
    }

    return {
      list: suggestedUsers.map(u => ({
        id: u.id,
        nickname: u.nickname,
        avatarUrl: u.avatarUrl,
        followersCount: u.followersCount,
        isFollowing: false,
        mutualFollows: mutualFollowCounts.get(u.id) || 0,
      })),
      nextCursor: null,
      hasMore: false,
      total: suggestedUsers.length,
    };
  }
}
