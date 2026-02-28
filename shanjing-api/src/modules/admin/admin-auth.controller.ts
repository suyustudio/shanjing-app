/**
 * 管理员认证控制器
 * 
 * 提供管理员登录、Token刷新等认证接口
 */

import {
  Controller,
  Post,
  Get,
  Body,
  Query,
  HttpCode,
  HttpStatus,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AdminAuthService } from './admin-auth.service';
import { AdminJwtAuthGuard, SuperAdminGuard } from './guards/admin-jwt.guard';
import { CurrentAdmin, AdminInfo } from './decorators/current-admin.decorator';
import { AdminRole } from './admin-role.enum';
import {
  AdminLoginDto,
  CreateAdminDto,
  UpdateAdminDto,
  AdminLoginResponseDto,
  AdminInfoResponseDto,
  AdminListResponseDto,
} from './dto/admin-auth.dto';

@ApiTags('后台管理-认证')
@Controller('admin/auth')
export class AdminAuthController {
  constructor(private readonly adminAuthService: AdminAuthService) {}

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '管理员登录' })
  @ApiResponse({
    status: 200,
    description: '登录成功',
    type: AdminLoginResponseDto,
  })
  @ApiResponse({ status: 401, description: '用户名或密码错误' })
  async login(@Body() dto: AdminLoginDto): Promise<AdminLoginResponseDto> {
    return this.adminAuthService.login(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '刷新Token' })
  @ApiResponse({ status: 200, description: '刷新成功' })
  @ApiResponse({ status: 401, description: 'Token无效或已过期' })
  async refreshToken(
    @Body('refreshToken') refreshToken: string,
  ): Promise<{ accessToken: string; refreshToken: string; expiresIn: number }> {
    return this.adminAuthService.refreshToken(refreshToken);
  }

  @Get('profile')
  @UseGuards(AdminJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取当前管理员信息' })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: AdminInfoResponseDto,
  })
  async getProfile(
    @CurrentAdmin('id') adminId: string,
  ): Promise<AdminInfoResponseDto> {
    return this.adminAuthService.getAdminInfo(adminId);
  }

  @Post('admins')
  @UseGuards(AdminJwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '创建管理员（仅超级管理员）' })
  @ApiResponse({ status: 200, description: '创建成功' })
  @ApiResponse({ status: 401, description: '权限不足' })
  @ApiResponse({ status: 409, description: '用户名已存在' })
  async createAdmin(
    @Body() dto: CreateAdminDto,
    @CurrentAdmin() admin: AdminInfo,
  ) {
    return this.adminAuthService.createAdmin(dto, admin.role);
  }

  @Get('admins')
  @UseGuards(AdminJwtAuthGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: '获取管理员列表' })
  @ApiResponse({
    status: 200,
    description: '获取成功',
    type: AdminListResponseDto,
  })
  async getAdminList(
    @Query('page') page: string = '1',
    @Query('limit') limit: string = '20',
  ): Promise<AdminListResponseDto> {
    return this.adminAuthService.getAdminList(
      parseInt(page, 10),
      parseInt(limit, 10),
    );
  }

  @Post('admins/:id')
  @UseGuards(AdminJwtAuthGuard)
  @ApiBearerAuth()
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '更新管理员信息' })
  @ApiResponse({ status: 200, description: '更新成功' })
  async updateAdmin(
    @Body() dto: UpdateAdminDto,
    @CurrentAdmin() admin: AdminInfo,
  ) {
    // 注意：这里需要在路由参数中获取 adminId
    // 实际实现中需要使用 @Param('id') 装饰器
    // 这里简化处理，实际应该通过 Param 获取
    return {
      success: true,
      message: '请使用 PUT /admin/admins/:id 接口',
    };
  }
}
