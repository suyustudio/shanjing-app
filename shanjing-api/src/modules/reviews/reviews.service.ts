// ================================================================
// M6: 评论系统 Service - 修复版
// ================================================================

import { Injectable, NotFoundException, ForbiddenException, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import {
  CreateReviewDto,
  UpdateReviewDto,
  CreateReplyDto,
  QueryReviewsDto,
  ReviewDto,
  ReviewDetailDto,
  ReviewListResponseDto,
  ReviewStatsDto,
  ReviewReplyDto,
  LikeReviewResponseDto,
} from './dto/review.dto';
import { PREDEFINED_TAGS } from './dto/review.dto';

@Injectable()
export class ReviewsService {
  // 24小时编辑限制（可配置）
  private readonly EDIT_TIME_LIMIT_HOURS = 24;

  constructor(private prisma: PrismaService) {}

  // ==================== 评论 CRUD ====================

  /**
   * 创建评论
   */
  async createReview(
    userId: string,
    trailId: string,
    dto: CreateReviewDto,
  ): Promise<ReviewDto> {
    // 检查路线是否存在
    const trail = await this.prisma.trail.findUnique({
      where: { id: trailId },
    });
    if (!trail) {
      throw new NotFoundException('路线不存在');
    }

    // 检查用户是否已评论过
    const existingReview = await this.prisma.review.findUnique({
      where: {
        userId_trailId: {
          userId,
          trailId,
        },
      },
    });
    if (existingReview) {
      throw new BadRequestException('您已经评论过这条路线了');
    }

    // 验证标签
    if (dto.tags) {
      const invalidTags = dto.tags.filter(tag => !PREDEFINED_TAGS.includes(tag as any));
      if (invalidTags.length > 0) {
        throw new BadRequestException(`无效的标签: ${invalidTags.join(', ')}`);
      }
    }

    // P1: 检查用户是否"体验过"该路线
    const isVerified = await this.checkUserCompletedTrail(userId, trailId);

    // 创建评论
    const review = await this.prisma.review.create({
      data: {
        userId,
        trailId,
        rating: dto.rating,
        content: dto.content,
        isVerified,
        tags: {
          create: dto.tags?.map(tag => ({ tag })) || [],
        },
        photos: {
          create: dto.photos?.map((url, index) => ({
            url,
            sortOrder: index,
          })) || [],
        },
      },
      include: {
        user: {
          select: {
            id: true,
            nickname: true,
            avatarUrl: true,
          },
        },
        tags: true,
        photos: {
          orderBy: { sortOrder: 'asc' },
        },
        _count: {
          select: { likes: true }
        }
      },
    });

    // 更新路线评分统计
    await this.updateTrailRatingStats(trailId);

    return this.mapToReviewDto(review);
  }

  /**
   * 获取评论列表
   */
  async getReviews(
    trailId: string,
    query: QueryReviewsDto,
    currentUserId?: string,
  ): Promise<ReviewListResponseDto> {
    // 构建排序条件
    let orderBy: any = {};
    switch (query.sort) {
      case 'highest':
        orderBy = { rating: 'desc' };
        break;
      case 'lowest':
        orderBy = { rating: 'asc' };
        break;
      case 'hot':
        orderBy = [
          { likeCount: 'desc' },
          { replyCount: 'desc' },
          { createdAt: 'desc' }
        ];
        break;
      case 'newest':
      default:
        orderBy = { createdAt: 'desc' };
    }

    // 构建筛选条件
    const where: any = { trailId };
    if (query.rating) {
      where.rating = query.rating;
    }

    // 查询评论
    const [reviews, total] = await Promise.all([
      this.prisma.review.findMany({
        where,
        orderBy,
        skip: (query.page - 1) * query.limit,
        take: query.limit,
        include: {
          user: {
            select: {
              id: true,
              nickname: true,
              avatarUrl: true,
            },
          },
          tags: true,
          photos: {
            orderBy: { sortOrder: 'asc' },
          },
          likes: currentUserId ? {
            where: { userId: currentUserId },
            take: 1,
          } : false,
          _count: {
            select: { likes: true }
          }
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    // 获取评分统计
    const stats = await this.getReviewStats(trailId);

    return {
      list: reviews.map(r => this.mapToReviewDto(r, currentUserId)),
      total,
      page: query.page,
      limit: query.limit,
      stats,
    };
  }

  /**
   * 获取评论详情
   */
  async getReviewDetail(reviewId: string, currentUserId?: string): Promise<ReviewDetailDto> {
    const review = await this.prisma.review.findUnique({
      where: { id: reviewId },
      include: {
        user: {
          select: {
            id: true,
            nickname: true,
            avatarUrl: true,
          },
        },
        tags: true,
        photos: {
          orderBy: { sortOrder: 'asc' },
        },
        replies: {
          include: {
            user: {
              select: {
                id: true,
                nickname: true,
                avatarUrl: true,
              },
            },
          },
          orderBy: { createdAt: 'asc' },
        },
        likes: currentUserId ? {
          where: { userId: currentUserId },
          take: 1,
        } : false,
        _count: {
          select: { likes: true }
        }
      },
    });

    if (!review) {
      throw new NotFoundException('评论不存在');
    }

    return this.mapToReviewDetailDto(review, currentUserId);
  }

  /**
   * 更新评论
   */
  async updateReview(
    userId: string,
    reviewId: string,
    dto: UpdateReviewDto,
  ): Promise<ReviewDto> {
    const review = await this.prisma.review.findUnique({
      where: { id: reviewId },
    });

    if (!review) {
      throw new NotFoundException('评论不存在');
    }

    if (review.userId !== userId) {
      throw new ForbiddenException('无权修改此评论');
    }

    // 检查是否在24小时内
    const hoursSinceCreated = (Date.now() - review.createdAt.getTime()) / (1000 * 60 * 60);
    if (hoursSinceCreated > this.EDIT_TIME_LIMIT_HOURS) {
      throw new ForbiddenException(`评论超过${this.EDIT_TIME_LIMIT_HOURS}小时，无法编辑`);
    }

    // 验证标签
    if (dto.tags) {
      const invalidTags = dto.tags.filter(tag => !PREDEFINED_TAGS.includes(tag as any));
      if (invalidTags.length > 0) {
        throw new BadRequestException(`无效的标签: ${invalidTags.join(', ')}`);
      }
    }

    // 更新评论 - 包括照片更新
    const updateData: any = {
      rating: dto.rating,
      content: dto.content,
      isEdited: true,
    };

    // 更新标签
    if (dto.tags) {
      updateData.tags = {
        deleteMany: {},
        create: dto.tags.map(tag => ({ tag })),
      };
    }

    // P1: 更新照片
    if (dto.photos !== undefined) {
      updateData.photos = {
        deleteMany: {},
        create: dto.photos?.map((url, index) => ({
          url,
          sortOrder: index,
        })) || [],
      };
    }

    const updated = await this.prisma.review.update({
      where: { id: reviewId },
      data: updateData,
      include: {
        user: {
          select: {
            id: true,
            nickname: true,
            avatarUrl: true,
          },
        },
        tags: true,
        photos: {
          orderBy: { sortOrder: 'asc' },
        },
        _count: {
          select: { likes: true }
        }
      },
    });

    // 更新路线评分统计
    await this.updateTrailRatingStats(review.trailId);

    return this.mapToReviewDto(updated);
  }

  /**
   * 删除评论
   */
  async deleteReview(userId: string, reviewId: string): Promise<void> {
    const review = await this.prisma.review.findUnique({
      where: { id: reviewId },
    });

    if (!review) {
      throw new NotFoundException('评论不存在');
    }

    if (review.userId !== userId) {
      throw new ForbiddenException('无权删除此评论');
    }

    const trailId = review.trailId;

    await this.prisma.review.delete({
      where: { id: reviewId },
    });

    // 更新路线评分统计
    await this.updateTrailRatingStats(trailId);
  }

  // ==================== 评论回复 ====================

  /**
   * 创建回复
   */
  async createReply(
    userId: string,
    reviewId: string,
    dto: CreateReplyDto,
  ): Promise<ReviewReplyDto> {
    const review = await this.prisma.review.findUnique({
      where: { id: reviewId },
    });

    if (!review) {
      throw new NotFoundException('评论不存在');
    }

    // 如果指定了父回复，验证是否存在
    if (dto.parentId) {
      const parentReply = await this.prisma.reviewReply.findUnique({
        where: { id: dto.parentId },
      });
      if (!parentReply || parentReply.reviewId !== reviewId) {
        throw new BadRequestException('父回复不存在');
      }
    }

    const reply = await this.prisma.reviewReply.create({
      data: {
        reviewId,
        userId,
        parentId: dto.parentId || null,
        content: dto.content,
      },
      include: {
        user: {
          select: {
            id: true,
            nickname: true,
            avatarUrl: true,
          },
        },
      },
    });

    // 更新评论回复数
    await this.prisma.review.update({
      where: { id: reviewId },
      data: {
        replyCount: {
          increment: 1,
        },
      },
    });

    return this.mapToReplyDto(reply);
  }

  /**
   * 获取评论回复列表
   */
  async getReplies(reviewId: string): Promise<ReviewReplyDto[]> {
    const replies = await this.prisma.reviewReply.findMany({
      where: { reviewId },
      include: {
        user: {
          select: {
            id: true,
            nickname: true,
            avatarUrl: true,
          },
        },
      },
      orderBy: { createdAt: 'asc' },
    });

    return replies.map(r => this.mapToReplyDto(r));
  }

  // ==================== 点赞功能 (P0) ====================

  /**
   * 点赞评论
   */
  async likeReview(userId: string, reviewId: string): Promise<LikeReviewResponseDto> {
    const review = await this.prisma.review.findUnique({
      where: { id: reviewId },
    });

    if (!review) {
      throw new NotFoundException('评论不存在');
    }

    // 检查是否已点赞
    const existingLike = await this.prisma.reviewLike.findUnique({
      where: {
        reviewId_userId: {
          reviewId,
          userId,
        },
      },
    });

    if (existingLike) {
      // 已点赞，取消点赞
      await this.prisma.reviewLike.delete({
        where: { id: existingLike.id },
      });

      // 更新点赞数
      await this.prisma.review.update({
        where: { id: reviewId },
        data: { likeCount: { decrement: 1 } },
      });

      const updatedReview = await this.prisma.review.findUnique({
        where: { id: reviewId },
        select: { likeCount: true },
      });

      return { isLiked: false, likeCount: updatedReview?.likeCount || 0 };
    } else {
      // 未点赞，添加点赞
      await this.prisma.reviewLike.create({
        data: {
          reviewId,
          userId,
        },
      });

      // 更新点赞数
      await this.prisma.review.update({
        where: { id: reviewId },
        data: { likeCount: { increment: 1 } },
      });

      const updatedReview = await this.prisma.review.findUnique({
        where: { id: reviewId },
        select: { likeCount: true },
      });

      return { isLiked: true, likeCount: updatedReview?.likeCount || 0 };
    }
  }

  /**
   * 检查用户是否已点赞评论
   */
  async checkUserLikedReview(userId: string, reviewId: string): Promise<boolean> {
    const like = await this.prisma.reviewLike.findUnique({
      where: {
        reviewId_userId: {
          reviewId,
          userId,
        },
      },
    });
    return !!like;
  }

  // ==================== 评分统计 (P1: 高级评分算法) ====================

  /**
   * 获取评论统计
   */
  async getReviewStats(trailId: string): Promise<ReviewStatsDto> {
    const stats = await this.prisma.trail.findUnique({
      where: { id: trailId },
      select: {
        id: true,
        avgRating: true,
        reviewCount: true,
        rating5Count: true,
        rating4Count: true,
        rating3Count: true,
        rating2Count: true,
        rating1Count: true,
      },
    });

    if (!stats) {
      throw new NotFoundException('路线不存在');
    }

    return {
      trailId: stats.id,
      avgRating: stats.avgRating || 0,
      totalCount: stats.reviewCount,
      rating5Count: stats.rating5Count,
      rating4Count: stats.rating4Count,
      rating3Count: stats.rating3Count,
      rating2Count: stats.rating2Count,
      rating1Count: stats.rating1Count,
    };
  }

  /**
   * 更新路线评分统计 - P1: 高级评分算法
   * - 去掉最高最低各5%
   * - 最近30天评价权重×1.2
   */
  private async updateTrailRatingStats(trailId: string): Promise<void> {
    const reviews = await this.prisma.review.findMany({
      where: { trailId },
      select: { rating: true, createdAt: true },
    });

    const totalCount = reviews.length;
    if (totalCount === 0) {
      await this.prisma.trail.update({
        where: { id: trailId },
        data: {
          avgRating: null,
          reviewCount: 0,
          rating5Count: 0,
          rating4Count: 0,
          rating3Count: 0,
          rating2Count: 0,
          rating1Count: 0,
        },
      });
      return;
    }

    // P1: 高级评分算法
    const weightedRating = this.calculateWeightedRating(reviews);

    // 统计各星级数量 (使用原始数据，不经过加权)
    const counts = {
      rating5Count: reviews.filter(r => r.rating === 5).length,
      rating4Count: reviews.filter(r => r.rating === 4).length,
      rating3Count: reviews.filter(r => r.rating === 3).length,
      rating2Count: reviews.filter(r => r.rating === 2).length,
      rating1Count: reviews.filter(r => r.rating === 1).length,
    };

    await this.prisma.trail.update({
      where: { id: trailId },
      data: {
        avgRating: weightedRating,
        reviewCount: totalCount,
        ...counts,
      },
    });
  }

  /**
   * P1: 高级评分算法
   * 1. 去掉最高最低各5%
   * 2. 最近30天评价权重×1.2
   */
  private calculateWeightedRating(
    reviews: { rating: number; createdAt: Date }[]
  ): number {
    if (reviews.length === 0) return 0;
    if (reviews.length <= 2) {
      // 评论太少时不进行去极值处理
      return Number((reviews.reduce((sum, r) => sum + r.rating, 0) / reviews.length).toFixed(1));
    }

    // 1. 去掉最高最低各5%
    const sorted = [...reviews].sort((a, b) => a.rating - b.rating);
    const trimCount = Math.max(1, Math.ceil(sorted.length * 0.05));
    const trimmed = sorted.slice(trimCount, sorted.length - trimCount);

    // 2. 最近30天权重×1.2
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    let weightedSum = 0;
    let totalWeight = 0;

    for (const review of trimmed) {
      const isRecent = review.createdAt > thirtyDaysAgo;
      const weight = isRecent ? 1.2 : 1.0;
      weightedSum += review.rating * weight;
      totalWeight += weight;
    }

    return Number((weightedSum / totalWeight).toFixed(1));
  }

  /**
   * P1: 检查用户是否完成过该路线（"体验过"标识）
   */
  private async checkUserCompletedTrail(userId: string, trailId: string): Promise<boolean> {
    // 查询用户是否有该路线的完成记录
    // 这里假设有 trackRecords 或其他记录表来存储完成记录
    // 简化实现：查询用户的成就系统中是否有完成该路线的记录
    const userStats = await this.prisma.userStats.findUnique({
      where: { userId },
      select: { completedTrailIds: true },
    });

    return userStats?.completedTrailIds?.includes(trailId) || false;
  }

  // ==================== 举报 ====================

  /**
   * 举报评论
   */
  async reportReview(
    userId: string,
    reviewId: string,
    reason: string,
  ): Promise<void> {
    const review = await this.prisma.review.findUnique({
      where: { id: reviewId },
    });

    if (!review) {
      throw new NotFoundException('评论不存在');
    }

    if (review.userId === userId) {
      throw new BadRequestException('不能举报自己的评论');
    }

    await this.prisma.review.update({
      where: { id: reviewId },
      data: {
        isReported: true,
        reportReason: reason,
      },
    });
  }

  // ==================== 数据映射 ====================

  private mapToReviewDto(review: any, currentUserId?: string): ReviewDto {
    // 检查当前用户是否已点赞
    let isLiked = false;
    if (currentUserId && review.likes) {
      isLiked = review.likes.length > 0;
    }

    return {
      id: review.id,
      rating: review.rating,
      content: review.content,
      tags: review.tags?.map((t: any) => t.tag) || [],
      photos: review.photos?.map((p: any) => p.url) || [],
      likeCount: review.likeCount,
      replyCount: review.replyCount,
      isEdited: review.isEdited,
      isVerified: review.isVerified,
      isLiked,
      user: {
        id: review.user.id,
        nickname: review.user.nickname,
        avatarUrl: review.user.avatarUrl,
      },
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
    };
  }

  private mapToReviewDetailDto(review: any, currentUserId?: string): ReviewDetailDto {
    return {
      ...this.mapToReviewDto(review, currentUserId),
      replies: review.replies?.map((r: any) => this.mapToReplyDto(r)) || [],
    };
  }

  private mapToReplyDto(reply: any): ReviewReplyDto {
    return {
      id: reply.id,
      content: reply.content,
      user: {
        id: reply.user.id,
        nickname: reply.user.nickname,
        avatarUrl: reply.user.avatarUrl,
      },
      parentId: reply.parentId,
      createdAt: reply.createdAt,
    };
  }
}
