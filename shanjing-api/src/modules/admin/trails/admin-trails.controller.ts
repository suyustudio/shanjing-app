/**
 * 后台管理 - 路线管理控制器
 * 
 * 提供路线 CRUD 接口，需要管理员权限
 */

import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiParam } from '@nestjs/swagger';
import { AdminTrailsService } from './admin-trails.service';
import { AdminJwtAuthGuard, AdminPermissionGuard } from '../guards/admin-jwt.guard';
import { CurrentAdmin, AdminInfo } from '../decorators/current-admin.decorator';
import { AdminPermission } from '../admin-role.enum';
import {
  CreateTrailDto,
  UpdateTrailDto,
  TrailListQueryDto,
  TrailResponseDto,
  TrailListResponseDto,
} from './dto/trail-admin.dto';

@ApiTags('后台管理-路线管理')
@ApiBearerAuth()
@UseGuards(AdminJwtAuthGuard)
@Controller('admin/trails')
export class AdminTrailsController {
  constructor(private readonly adminTrailsService: AdminTrailsService) {}

  @Get()
  @ApiOperation({ summary: '获取路线列表', description: '支持分页、搜索、筛选' })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: TrailListResponseDto,
  })
  async getTrailList(@Query() query: TrailListQueryDto) {
    return this.adminTrailsService.getTrailList(query);
  }

  @Get('stats')
  @ApiOperation({ summary: '获取路线统计信息' })
  @ApiResponse({ status: 200, description: '获取成功' })
  async getTrailStats() {
    return this.adminTrailsService.getTrailStats();
  }

  @Get(':id')
  @ApiOperation({ summary: '获取路线详情' })
  @ApiParam({ name: 'id', description: '路线ID' })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: TrailResponseDto,
  })
  @ApiResponse({ status: 404, description: '路线不存在' })
  async getTrailById(@Param('id') trailId: string) {
    return this.adminTrailsService.getTrailById(trailId);
  }

  @Post()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '创建路线', description: '需要 trail:create 权限' })
  @ApiResponse({
    status: 200,
    description: '创建成功',
    type: TrailResponseDto,
  })
  @ApiResponse({ status: 400, description: '参数错误' })
  async createTrail(
    @Body() dto: CreateTrailDto,
    @CurrentAdmin() admin: AdminInfo,
  ) {
    return this.adminTrailsService.createTrail(dto, admin.id);
  }

  @Put(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '更新路线', description: '需要 trail:update 权限' })
  @ApiParam({ name: 'id', description: '路线ID' })
  @ApiResponse({
    status: 200,
    description: '更新成功',
    type: TrailResponseDto,
  })
  @ApiResponse({ status: 404, description: '路线不存在' })
  async updateTrail(
    @Param('id') trailId: string,
    @Body() dto: UpdateTrailDto,
  ) {
    return this.adminTrailsService.updateTrail(trailId, dto);
  }

  @Delete(':id')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '删除路线', description: '需要 trail:delete 权限（软删除）' })
  @ApiParam({ name: 'id', description: '路线ID' })
  @ApiResponse({ status: 200, description: '删除成功' })
  @ApiResponse({ status: 404, description: '路线不存在' })
  async deleteTrail(@Param('id') trailId: string) {
    return this.adminTrailsService.deleteTrail(trailId);
  }

  @Post('batch/status')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '批量更新路线状态' })
  @ApiResponse({ status: 200, description: '更新成功' })
  async batchUpdateStatus(
    @Body('trailIds') trailIds: string[],
    @Body('isActive') isActive: boolean,
  ) {
    return this.adminTrailsService.batchUpdateStatus(trailIds, isActive);
  }
}
