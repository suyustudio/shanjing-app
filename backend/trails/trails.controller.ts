// trails.controller.ts - 路线控制器
// 山径APP - 用户端路线浏览 API
// Week 4 Day 3 任务: B12 实现用户端路线浏览 API

import { Controller, Get, Query, ParseIntPipe, DefaultValuePipe, MaxLength } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiResponse } from '@nestjs/swagger';
import { TrailsService } from './trails.service';
import { Public } from '../common/decorators/public.decorator';
import { Difficulty } from '@prisma/client';

/**
 * 用户端路线浏览控制器
 * 
 * 提供公开的路线浏览 API：
 * - GET /trails - 获取路线列表（支持分页、城市筛选、难度筛选）
 */
@ApiTags('路线浏览')
@Controller('trails')
export class TrailsController {
  constructor(private readonly trailsService: TrailsService) {}

  /**
   * 获取路线列表
   * 
   * 支持分页、城市筛选、难度筛选
   * 不需要管理员权限，公开访问
   */
  @Get()
  @Public()
  @ApiOperation({
    summary: '获取路线列表',
    description: '获取路线列表，支持分页、城市筛选、难度筛选',
  })
  @ApiQuery({ name: 'page', required: false, description: '页码，默认1', type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量，默认20', type: Number, example: 20 })
  @ApiQuery({ 
    name: 'city', 
    required: false, 
    description: '城市筛选', 
    type: String, 
    example: '杭州' 
  })
  @ApiQuery({ 
    name: 'difficulty', 
    required: false, 
    description: '难度筛选：easy(简单), moderate(中等), hard(困难)', 
    enum: Difficulty,
    example: 'moderate' 
  })
  @ApiResponse({
    status: 200,
    description: '获取成功',
  })
  async findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
    @Query('city', new MaxLength(50)) city?: string,
    @Query('difficulty') difficulty?: Difficulty,
  ) {
    return this.trailsService.findAllPublic({
      page,
      limit: Math.min(limit, 100),
      city,
      difficulty,
    });
  }
}
