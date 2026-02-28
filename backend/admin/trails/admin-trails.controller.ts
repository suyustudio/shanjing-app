// admin-trails.controller.ts - 后台管理路线控制器
// 山径APP - 后台管理 API
// 功能：管理员路线管理接口（创建、更新、删除）

import {
  Controller,
  Post,
  Patch,
  Delete,
  Body,
  Param,
  UseGuards,
  ValidationPipe,
  UsePipes,
  ParseUUIDPipe,
  Request,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiBearerAuth,
  ApiResponse,
  ApiParam,
  ApiBody,
} from '@nestjs/swagger';
import { AdminTrailsService } from './admin-trails.service';
import { JwtAuthGuard } from '../../common/guards';
import { RolesGuard, Roles, UserRole } from '../../common/guards/roles.guard';
import { CreateTrailDto } from './dto/create-trail.dto';
import { UpdateTrailDto } from './dto/update-trail.dto';
import {
  AdminCreateTrailResponseDto,
  AdminUpdateTrailResponseDto,
  AdminDeleteTrailResponseDto,
} from './dto/admin-trail-response.dto';

/**
 * 后台管理路线控制器
 * 
 * 提供管理员路线管理的 REST API 接口：
 * - POST /admin/trails - 创建路线
 * - PATCH /admin/trails/:id - 更新路线
 * - DELETE /admin/trails/:id - 删除路线
 * 
 * 所有接口需要管理员权限（ADMIN 或 SUPER_ADMIN）
 */
@ApiTags('后台管理-路线管理')
@ApiBearerAuth()
@Controller('admin/trails')
@UseGuards(JwtAuthGuard, RolesGuard)
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
export class AdminTrailsController {
  constructor(private readonly adminTrailsService: AdminTrailsService) {}

  /**
   * 创建路线
   * 
   * 管理员创建新路线，可选择立即发布或保存为草稿
   */
  @Post()
  @ApiOperation({
    summary: '创建路线（管理员）',
    description: '创建新路线，需要管理员权限。可选择立即发布或保存为草稿。',
  })
  @ApiBody({
    description: '路线创建数据',
    type: CreateTrailDto,
  })
  @ApiResponse({
    status: 201,
    description: '路线创建成功',
    type: AdminCreateTrailResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: '请求参数错误',
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  @ApiResponse({
    status: 403,
    description: '权限不足（需要管理员权限）',
  })
  @ApiResponse({
    status: 409,
    description: '路线名称已存在',
  })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async create(
    @Body() createTrailDto: CreateTrailDto,
    @Request() req: any,
  ): Promise<AdminCreateTrailResponseDto> {
    const adminId = req.user?.userId;
    return this.adminTrailsService.create(createTrailDto, adminId);
  }

  /**
   * 更新路线
   * 
   * 管理员更新现有路线信息
   */
  @Patch(':id')
  @ApiOperation({
    summary: '更新路线（管理员）',
    description: '更新路线信息，需要管理员权限。支持部分更新。',
  })
  @ApiParam({
    name: 'id',
    description: '路线ID',
    example: 'clq1234567890abcdef',
  })
  @ApiBody({
    description: '路线更新数据（支持部分更新）',
    type: UpdateTrailDto,
  })
  @ApiResponse({
    status: 200,
    description: '路线更新成功',
    type: AdminUpdateTrailResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: '请求参数错误',
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  @ApiResponse({
    status: 403,
    description: '权限不足（需要管理员权限）',
  })
  @ApiResponse({
    status: 404,
    description: '路线不存在',
  })
  @ApiResponse({
    status: 409,
    description: '路线名称已存在',
  })
  @UsePipes(new ValidationPipe({ transform: true, whitelist: true }))
  async update(
    @Param('id') id: string,
    @Body() updateTrailDto: UpdateTrailDto,
  ): Promise<AdminUpdateTrailResponseDto> {
    return this.adminTrailsService.update(id, updateTrailDto);
  }

  /**
   * 删除路线
   * 
   * 管理员删除路线
   */
  @Delete(':id')
  @ApiOperation({
    summary: '删除路线（管理员）',
    description: '删除路线，需要管理员权限。删除后不可恢复。',
  })
  @ApiParam({
    name: 'id',
    description: '路线ID',
    example: 'clq1234567890abcdef',
  })
  @ApiResponse({
    status: 200,
    description: '路线删除成功',
    type: AdminDeleteTrailResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: '未登录或Token无效',
  })
  @ApiResponse({
    status: 403,
    description: '权限不足（需要管理员权限）',
  })
  @ApiResponse({
    status: 404,
    description: '路线不存在',
  })
  async remove(@Param('id') id: string): Promise<AdminDeleteTrailResponseDto> {
    return this.adminTrailsService.remove(id);
  }
}
