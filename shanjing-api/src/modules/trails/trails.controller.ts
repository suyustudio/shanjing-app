/**
 * 路线控制器
 * 
 * 提供前端用户使用的路线查询 API
 */

import {
  Controller,
  Get,
  Post,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  Optional,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam, ApiQuery } from '@nestjs/swagger';
import { TrailsService } from './trails.service';
import { CurrentUser } from '../../common/decorators/current-user.decorator';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { UseGuards } from '@nestjs/common';
import {
  TrailListQueryDto,
  TrailDetailResponseDto,
  TrailListResponseDto,
  NearbyTrailsQueryDto,
  RecommendedTrailsResponseDto,
} from './dto/trail.dto';

@ApiTags('路线')
@Controller('trails')
export class TrailsController {
  constructor(private readonly trailsService: TrailsService) {}

  @Get()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '获取路线列表', 
    description: '支持搜索、筛选、分页获取路线列表' 
  })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: TrailListResponseDto,
  })
  @ApiQuery({ name: 'keyword', required: false, description: '搜索关键词' })
  @ApiQuery({ name: 'city', required: false, description: '城市' })
  @ApiQuery({ name: 'district', required: false, description: '区域' })
  @ApiQuery({ name: 'difficulty', required: false, description: '难度级别 (EASY/MODERATE/HARD)' })
  @ApiQuery({ name: 'tag', required: false, description: '标签筛选' })
  @ApiQuery({ name: 'page', required: false, description: '页码', type: Number })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量', type: Number })
  async getTrailList(
    @Query() query: TrailListQueryDto,
    @CurrentUser('userId') userId?: string,
  ) {
    return this.trailsService.getTrailList(query, userId);
  }

  @Get('recommended')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '获取推荐路线', 
    description: '基于收藏数和热度获取推荐路线' 
  })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: RecommendedTrailsResponseDto,
  })
  @ApiQuery({ name: 'limit', required: false, description: '数量限制', type: Number })
  async getRecommendedTrails(
    @Query('limit') limit: number = 10,
    @CurrentUser('userId') userId?: string,
  ) {
    return this.trailsService.getRecommendedTrails(limit, userId);
  }

  @Get('nearby')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '获取附近路线', 
    description: '基于当前坐标获取附近路线' 
  })
  @ApiResponse({
    status: 200,
    description: '获取成功',
  })
  @ApiQuery({ name: 'lat', required: true, description: '纬度', type: Number })
  @ApiQuery({ name: 'lng', required: true, description: '经度', type: Number })
  @ApiQuery({ name: 'radius', required: false, description: '搜索半径（公里）', type: Number })
  @ApiQuery({ name: 'limit', required: false, description: '数量限制', type: Number })
  async getNearbyTrails(
    @Query() query: NearbyTrailsQueryDto,
    @CurrentUser('userId') userId?: string,
  ) {
    return this.trailsService.getNearbyTrails(query, userId);
  }

  @Get(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '获取路线详情', 
    description: '获取指定路线的详细信息' 
  })
  @ApiParam({ name: 'id', description: '路线ID' })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: TrailDetailResponseDto,
  })
  @ApiResponse({ status: 404, description: '路线不存在' })
  async getTrailById(
    @Param('id') trailId: string,
    @CurrentUser('userId') userId?: string,
  ) {
    return this.trailsService.getTrailById(trailId, userId);
  }
}
