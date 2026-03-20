// ================================================================
// M6: 评论系统 Controller - 修复版
// 修复内容:
// 1. 统一接口路径为 /v1/trails/:trailId/reviews (与 M5 风格一致)
// 2. 添加点赞/取消点赞接口
// 3. 统一响应格式 { success: boolean, data: T }
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
import { ApiTags, ApiOperation, ApiBearerAuth, ApiParam, ApiResponse } from '@nestjs/swagger';
import { ReviewsService } from './reviews.service';
import {
  CreateReviewDto,
  UpdateReviewDto,
  CreateReplyDto,
  ReportReviewDto,
  QueryReviewsDto,
  ReviewDto,
  ReviewDetailDto,
  ReviewListResponseDto,
  ApiResponseDto,
  LikeReviewResponseDto,
} from './dto/review.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { Request } from 'express';

interface RequestWithUser extends Request {
  user: {
    userId: string;
  };
}

/**
 * 统一响应格式包装
 */
function wrapResponse<T>(data: T, meta?: any): ApiResponseDto<T> {
  return {
    success: true,
    data,
    meta,
  };
}

@ApiTags('评论系统')
@Controller('v1')  // 修复：统一使用 /v1 前缀
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  // ==================== 评论 CRUD ====================

  /**
   * 发表评论
   * 修复：路径改为 /v1/trails/:trailId/reviews (与 M5 风格一致)
   */
  @Post('trails/:trailId/reviews')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '发表评论' })
  @ApiParam({ name: 'trailId', description: '路线ID' })
  @ApiResponse({ status: 201, description: '评论成功', type: ReviewDto })
  @ApiResponse({ status: 400, description: '参数错误或已评论过' })
  @ApiResponse({ status: 404, description: '路线不存在' })
  async createReview(
    @Req() req: RequestWithUser,
    @Param('trailId') trailId: string,
    @Body() dto: CreateReviewDto,
  ): Promise<ApiResponseDto<ReviewDto>> {
    const review = await this.reviewsService.createReview(req.user.userId, trailId, dto);
    return wrapResponse(review);
  }

  /**
   * 获取路线评论列表
   * 修复：路径改为 /v1/trails/:trailId/reviews
   */
  @Get('trails/:trailId/reviews')
  @ApiOperation({ summary: '获取路线评论列表' })
  @ApiParam({ name: 'trailId', description: '路线ID' })
  @ApiResponse({ status: 200, description: '获取成功', type: ReviewListResponseDto })
  async getReviews(
    @Req() req: RequestWithUser,
    @Param('trailId') trailId: string,
    @Query() query: QueryReviewsDto,
  ): Promise<ApiResponseDto<ReviewListResponseDto>> {
    const currentUserId = req.user?.userId;
    const result = await this.reviewsService.getReviews(trailId, query, currentUserId);
    return wrapResponse(result, {
      total: result.total,
      page: result.page,
      limit: result.limit,
    });
  }

  /**
   * 获取评论详情
   * 修复：路径改为 /v1/reviews/:id
   */
  @Get('reviews/:id')
  @ApiOperation({ summary: '获取评论详情' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '获取成功', type: ReviewDetailDto })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async getReviewDetail(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ): Promise<ApiResponseDto<ReviewDetailDto>> {
    const currentUserId = req.user?.userId;
    const review = await this.reviewsService.getReviewDetail(id, currentUserId);
    return wrapResponse(review);
  }

  /**
   * 编辑评论
   * 修复：路径改为 /v1/reviews/:id
   */
  @Put('reviews/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '编辑评论' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '更新成功', type: ReviewDto })
  @ApiResponse({ status: 403, description: '无权修改或超过24小时' })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async updateReview(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: UpdateReviewDto,
  ): Promise<ApiResponseDto<ReviewDto>> {
    const review = await this.reviewsService.updateReview(req.user.userId, id, dto);
    return wrapResponse(review);
  }

  /**
   * 删除评论
   * 修复：路径改为 /v1/reviews/:id
   */
  @Delete('reviews/:id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除评论' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '删除成功' })
  @ApiResponse({ status: 403, description: '无权删除' })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async deleteReview(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ): Promise<ApiResponseDto<{ message: string }>> {
    await this.reviewsService.deleteReview(req.user.userId, id);
    return wrapResponse({ message: '删除成功' });
  }

  // ==================== 评论点赞 (P0) ====================

  /**
   * P0: 点赞/取消点赞评论
   * POST /v1/reviews/:id/like
   */
  @Post('reviews/:id/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '点赞/取消点赞评论' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '操作成功', type: LikeReviewResponseDto })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async likeReview(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ): Promise<ApiResponseDto<LikeReviewResponseDto>> {
    const result = await this.reviewsService.likeReview(req.user.userId, id);
    return wrapResponse(result);
  }

  /**
   * P0: 检查当前用户是否已点赞评论
   * GET /v1/reviews/:id/like
   */
  @Get('reviews/:id/like')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '检查是否已点赞评论' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '查询成功' })
  async checkLikeStatus(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ): Promise<ApiResponseDto<{ isLiked: boolean }>> {
    const isLiked = await this.reviewsService.checkUserLikedReview(req.user.userId, id);
    return wrapResponse({ isLiked });
  }

  // ==================== 评论回复 ====================

  /**
   * 回复评论
   * 修复：路径改为 /v1/reviews/:id/replies
   */
  @Post('reviews/:id/replies')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '回复评论' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 201, description: '回复成功' })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async createReply(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: CreateReplyDto,
  ): Promise<ApiResponseDto<any>> {
    const reply = await this.reviewsService.createReply(req.user.userId, id, dto);
    return wrapResponse(reply);
  }

  /**
   * 获取评论回复列表
   * 修复：路径改为 /v1/reviews/:id/replies
   */
  @Get('reviews/:id/replies')
  @ApiOperation({ summary: '获取评论回复列表' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getReplies(
    @Param('id') id: string,
  ): Promise<ApiResponseDto<any[]>> {
    const replies = await this.reviewsService.getReplies(id);
    return wrapResponse(replies);
  }

  // ==================== 举报 ====================

  /**
   * 举报评论
   * 修复：路径改为 /v1/reviews/:id/report
   */
  @Post('reviews/:id/report')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '举报评论' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '举报成功' })
  @ApiResponse({ status: 400, description: '不能举报自己的评论' })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async reportReview(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: ReportReviewDto,
  ): Promise<ApiResponseDto<{ message: string }>> {
    await this.reviewsService.reportReview(req.user.userId, id, dto.reason);
    return wrapResponse({ message: '举报成功' });
  }
}
