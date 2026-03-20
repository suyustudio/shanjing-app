// ================================================================
// M6: 评论系统 Controller
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
} from './dto/review.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { Request } from 'express';

interface RequestWithUser extends Request {
  user: {
    userId: string;
  };
}

@ApiTags('评论系统')
@Controller('reviews')
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  // ==================== 评论 CRUD ====================

  @Post('trails/:trailId')
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
  ): Promise<ReviewDto> {
    return this.reviewsService.createReview(req.user.userId, trailId, dto);
  }

  @Get('trails/:trailId')
  @ApiOperation({ summary: '获取路线评论列表' })
  @ApiParam({ name: 'trailId', description: '路线ID' })
  @ApiResponse({ status: 200, description: '获取成功', type: ReviewListResponseDto })
  async getReviews(
    @Param('trailId') trailId: string,
    @Query() query: QueryReviewsDto,
  ): Promise<ReviewListResponseDto> {
    return this.reviewsService.getReviews(trailId, query);
  }

  @Get(':id')
  @ApiOperation({ summary: '获取评论详情' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '获取成功', type: ReviewDetailDto })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async getReviewDetail(@Param('id') id: string): Promise<ReviewDetailDto> {
    return this.reviewsService.getReviewDetail(id);
  }

  @Put(':id')
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
  ): Promise<ReviewDto> {
    return this.reviewsService.updateReview(req.user.userId, id, dto);
  }

  @Delete(':id')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '删除评论' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 204, description: '删除成功' })
  @ApiResponse({ status: 403, description: '无权删除' })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async deleteReview(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
  ): Promise<void> {
    return this.reviewsService.deleteReview(req.user.userId, id);
  }

  // ==================== 评论回复 ====================

  @Post(':id/replies')
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
  ): Promise<any> {
    return this.reviewsService.createReply(req.user.userId, id, dto);
  }

  @Get(':id/replies')
  @ApiOperation({ summary: '获取评论回复列表' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getReplies(@Param('id') id: string): Promise<any[]> {
    return this.reviewsService.getReplies(id);
  }

  // ==================== 举报 ====================

  @Post(':id/report')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.NO_CONTENT)
  @ApiOperation({ summary: '举报评论' })
  @ApiParam({ name: 'id', description: '评论ID' })
  @ApiResponse({ status: 204, description: '举报成功' })
  @ApiResponse({ status: 400, description: '不能举报自己的评论' })
  @ApiResponse({ status: 404, description: '评论不存在' })
  async reportReview(
    @Req() req: RequestWithUser,
    @Param('id') id: string,
    @Body() dto: ReportReviewDto,
  ): Promise<void> {
    return this.reviewsService.reportReview(req.user.userId, id, dto.reason);
  }
}
