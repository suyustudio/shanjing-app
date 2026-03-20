// ============================================
// 推荐控制器
// ============================================

import {
  Controller,
  Get,
  Post,
  Body,
  Query,
  UseGuards,
  Req,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiBearerAuth, ApiResponse } from '@nestjs/swagger';
import { Request } from 'express';
import { RecommendationService } from './services/recommendation.service';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import {
  GetRecommendationsDto,
  RecommendationsResponseDto,
  FeedbackDto,
} from './dto/recommendation.dto';

@ApiTags('推荐')
@Controller('api/recommendations')
@UseGuards(JwtAuthGuard)
@ApiBearerAuth()
export class RecommendationController {
  constructor(private recommendationService: RecommendationService) {}

  @Get()
  @ApiOperation({ summary: '获取个性化推荐路线' })
  @ApiResponse({
    status: 200,
    description: '获取推荐成功',
    type: RecommendationsResponseDto,
  })
  async getRecommendations(
    @Query() dto: GetRecommendationsDto,
    @Req() req: Request,
  ): Promise<{ success: boolean; data: RecommendationsResponseDto }> {
    const userId = (req as any).user?.userId;
    const result = await this.recommendationService.getRecommendations(dto, userId);
    return { success: true, data: result };
  }

  @Post('feedback')
  @ApiOperation({ summary: '记录用户反馈' })
  @ApiResponse({
    status: 200,
    description: '反馈记录成功',
  })
  async recordFeedback(
    @Body() dto: FeedbackDto,
    @Req() req: Request,
  ): Promise<{ success: boolean }> {
    const userId = (req as any).user?.userId;
    const result = await this.recommendationService.recordFeedback(dto, userId);
    return result;
  }
}