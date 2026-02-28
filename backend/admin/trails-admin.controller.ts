// trails-admin.controller.ts - 管理端路线管理控制器
// 山径APP - 管理员路线管理 API
// 功能：路线列表查询（支持分页、筛选、排序）、创建路线

import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Param,
  Body,
  Query,
  UseGuards,
  ParseIntPipe,
  DefaultValuePipe,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiQuery, ApiBearerAuth } from '@nestjs/swagger';
import { AdminGuard } from '../admin.guard';
import { PrismaService } from '../../prisma/prisma.service';
import { Difficulty, Prisma } from '@prisma/client';

@ApiTags('管理端-路线管理')
@ApiBearerAuth()
@Controller('admin/trails')
@UseGuards(AdminGuard)
export class TrailsAdminController {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * 创建新路线
   */
  @Post()
  @ApiOperation({
    summary: '创建路线',
    description: '管理员创建新路线，包含名称、描述、距离、时长、难度等基本信息',
  })
  async create(@Body() body: CreateTrailDto) {
    const trail = await this.prisma.trail.create({
      data: {
        name: body.name,
        description: body.description,
        distanceKm: body.distanceKm,
        durationMin: body.durationMin,
        elevationGainM: body.elevationGainM,
        difficulty: body.difficulty,
        tags: body.tags || [],
        city: body.city,
        district: body.district,
        coverImages: body.coverImages || [],
        isPublished: body.isPublished ?? false,
      },
    });

    return {
      success: true,
      data: trail,
    };
  }

  /**
   * 获取路线列表（管理端）
   * 
   * 支持分页、多维度筛选和排序
   */
  @Get()
  @ApiOperation({
    summary: '获取路线列表',
    description: '管理端获取路线列表，支持分页、筛选（难度、城市、发布状态）和排序',
  })
  @ApiQuery({ name: 'page', required: false, description: '页码，默认1', type: Number, example: 1 })
  @ApiQuery({ name: 'limit', required: false, description: '每页数量，默认20', type: Number, example: 20 })
  @ApiQuery({ name: 'difficulty', required: false, description: '难度筛选：easy/moderate/hard', enum: Difficulty })
  @ApiQuery({ name: 'city', required: false, description: '城市筛选', type: String, example: '杭州' })
  @ApiQuery({ name: 'isPublished', required: false, description: '发布状态筛选', type: Boolean })
  @ApiQuery({ name: 'sortBy', required: false, description: '排序字段：createdAt/updatedAt/viewCount/favoriteCount', type: String, example: 'createdAt' })
  @ApiQuery({ name: 'sortOrder', required: false, description: '排序顺序：asc/desc', type: String, example: 'desc' })
  async findAll(
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
    @Query('difficulty') difficulty?: Difficulty,
    @Query('city') city?: string,
    @Query('isPublished') isPublished?: string,
    @Query('sortBy', new DefaultValuePipe('createdAt')) sortBy: string = 'createdAt',
    @Query('sortOrder', new DefaultValuePipe('desc')) sortOrder: 'asc' | 'desc' = 'desc',
  ) {
    const skip = (page - 1) * limit;

    // 构建查询条件（过滤已软删除的记录）
    const where: Prisma.TrailWhereInput = {
      deletedAt: null,
    };

    if (difficulty) {
      where.difficulty = difficulty;
    }

    if (city) {
      where.city = { contains: city, mode: 'insensitive' };
    }

    if (isPublished !== undefined) {
      where.isPublished = isPublished === 'true';
    }

    // 构建排序条件
    const orderBy: Prisma.TrailOrderByWithRelationInput = {};
    if (['createdAt', 'updatedAt', 'viewCount', 'favoriteCount', 'name', 'distanceKm', 'durationMin'].includes(sortBy)) {
      orderBy[sortBy] = sortOrder;
    } else {
      orderBy.createdAt = 'desc';
    }

    // 执行查询
    const [items, total] = await Promise.all([
      this.prisma.trail.findMany({
        where,
        skip,
        take: limit,
        orderBy,
        select: {
          id: true,
          name: true,
          distanceKm: true,
          durationMin: true,
          elevationGainM: true,
          difficulty: true,
          tags: true,
          city: true,
          district: true,
          coverImages: true,
          isPublished: true,
          publishedAt: true,
          viewCount: true,
          favoriteCount: true,
          createdAt: true,
          updatedAt: true,
        },
      }),
      this.prisma.trail.count({ where }),
    ]);

    const totalPages = Math.ceil(total / limit);

    return {
      success: true,
      data: {
        items,
        pagination: {
          page,
          limit,
          total,
          totalPages,
          hasMore: page < totalPages,
        },
      },
    };
  }

  /**
   * 更新路线
   */
  @Put(':id')
  @ApiOperation({
    summary: '更新路线',
    description: '管理员更新路线信息',
  })
  async update(@Param('id') id: string, @Body() body: UpdateTrailDto) {
    const trail = await this.prisma.trail.update({
      where: { id },
      data: body,
    });

    return {
      success: true,
      data: trail,
    };
  }

  /**
   * 软删除路线
   */
  @Delete(':id')
  @ApiOperation({
    summary: '删除路线',
    description: '管理员软删除路线（设置 deletedAt 字段）',
  })
  async remove(@Param('id') id: string) {
    const trail = await this.prisma.trail.update({
      where: { id },
      data: { deletedAt: new Date() },
    });

    return {
      success: true,
      data: trail,
    };
  }
}

/**
 * 更新路线 DTO
 */
class UpdateTrailDto {
  /** 路线名称 */
  name?: string;

  /** 路线描述 */
  description?: string;

  /** 距离（公里） */
  distanceKm?: number;

  /** 预计时长（分钟） */
  durationMin?: number;

  /** 爬升高度（米） */
  elevationGainM?: number;

  /** 难度：easy/moderate/hard */
  difficulty?: Difficulty;

  /** 标签数组 */
  tags?: string[];

  /** 城市 */
  city?: string;

  /** 区县 */
  district?: string;

  /** 封面图片数组 */
  coverImages?: string[];

  /** 是否发布 */
  isPublished?: boolean;
}

/**
 * 创建路线 DTO
 */
class CreateTrailDto {
  /** 路线名称 */
  name: string;

  /** 路线描述 */
  description?: string;

  /** 距离（公里） */
  distanceKm: number;

  /** 预计时长（分钟） */
  durationMin: number;

  /** 爬升高度（米） */
  elevationGainM?: number;

  /** 难度：easy/moderate/hard */
  difficulty: Difficulty;

  /** 标签数组 */
  tags?: string[];

  /** 城市 */
  city?: string;

  /** 区县 */
  district?: string;

  /** 封面图片数组 */
  coverImages?: string[];

  /** 是否发布 */
  isPublished?: boolean;
}
