// ================================================================
// M6: 评论系统 Service
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
} from './dto/review.dto';
import { PREDEFINED_TAGS } from './dto/review.dto';

@Injectable()
export class ReviewsService {
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

    // 创建评论
    const review = await this.prisma.review.create({
      data: {
        userId,
        trailId,
        rating: dto.rating,
        content: dto.content,
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
    const orderBy: any = {};
    switch (query.sort) {
      case 'highest':
        orderBy.rating = 'desc';
        break;
      case 'lowest':
        orderBy.rating = 'asc';
        break;
      case 'newest':
      default:
        orderBy.createdAt = 'desc';
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
        },
      }),
      this.prisma.review.count({ where }),
    ]);

    // 获取评分统计
    const stats = await this.getReviewStats(trailId);

    return {
      list: reviews.map(r => this.mapToReviewDto(r)),
      total,
      page: query.page,
      limit: query.limit,
      stats,
    };
  }

  /**
   * 获取评论详情
   */
  async getReviewDetail(reviewId: string): Promise<ReviewDetailDto> {
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
      },
    });

    if (!review) {
      throw new NotFoundException('评论不存在');
    }

    return this.mapToReviewDetailDto(review);
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
    if (hoursSinceCreated > 24) {
      throw new ForbiddenException('评论超过24小时，无法编辑');
    }

    // 验证标签
    if (dto.tags) {
      const invalidTags = dto.tags.filter(tag => !PREDEFINED_TAGS.includes(tag as any));
      if (invalidTags.length > 0) {
        throw new BadRequestException(`无效的标签: ${invalidTags.join(', ')}`);
      }
    }

    // 更新评论
    const updated = await this.prisma.review.update({
      where: { id: reviewId },
      data: {
        rating: dto.rating,
        content: dto.content,
        isEdited: true,
        tags: dto.tags ? {
          deleteMany: {},
          create: dto.tags.map(tag => ({ tag })),
        } : undefined,
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

  // ==================== 评分统计 ====================

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
   * 更新路线评分统计
   */
  private async updateTrailRatingStats(trailId: string): Promise<void> {
    const reviews = await this.prisma.review.findMany({
      where: { trailId },
      select: { rating: true },
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

    const ratingSum = reviews.reduce((sum, r) => sum + Number(r.rating), 0);
    const avgRating = ratingSum / totalCount;

    const counts = {
      rating5Count: reviews.filter(r => Number(r.rating) >= 4.5).length,
      rating4Count: reviews.filter(r => Number(r.rating) >= 3.5 && Number(r.rating) < 4.5).length,
      rating3Count: reviews.filter(r => Number(r.rating) >= 2.5 && Number(r.rating) < 3.5).length,
      rating2Count: reviews.filter(r => Number(r.rating) >= 1.5 && Number(r.rating) < 2.5).length,
      rating1Count: reviews.filter(r => Number(r.rating) < 1.5).length,
    };

    await this.prisma.trail.update({
      where: { id: trailId },
      data: {
        avgRating,
        reviewCount: totalCount,
        ...counts,
      },
    });
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

  private mapToReviewDto(review: any): ReviewDto {
    return {
      id: review.id,
      rating: Number(review.rating),
      content: review.content,
      tags: review.tags?.map((t: any) => t.tag) || [],
      photos: review.photos?.map((p: any) => p.url) || [],
      likeCount: review.likeCount,
      replyCount: review.replyCount,
      isEdited: review.isEdited,
      user: {
        id: review.user.id,
        nickname: review.user.nickname,
        avatarUrl: review.user.avatarUrl,
      },
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
    };
  }

  private mapToReviewDetailDto(review: any): ReviewDetailDto {
    return {
      ...this.mapToReviewDto(review),
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
