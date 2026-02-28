// users.controller.ts - 用户信息管理 API Controller
// 山径APP - 用户模块
// 功能：获取用户信息、更新用户信息、上传头像

import {
  Controller,
  Get,
  Patch,
  Post,
  Body,
  UseGuards,
  UseInterceptors,
  UploadedFile,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiConsumes } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { JwtAuthGuard } from '../../shanjing-api/src/common/guards/jwt-auth.guard';
import { CurrentUser } from './decorators/current-user.decorator';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserResponse, AvatarUploadResponse } from './interfaces/user.interface';

@ApiTags('用户 - 用户信息管理')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  /**
   * 获取当前用户信息
   * GET /users/me
   */
  @Get('me')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '获取当前用户信息',
    description: '获取当前登录用户的详细信息',
  })
  @ApiResponse({ status: 200, description: '获取成功', type: UserResponse })
  @ApiResponse({ status: 401, description: '未登录或Token无效' })
  async getCurrentUser(
    @CurrentUser('userId') userId: string,
  ): Promise<{ success: boolean; data: UserResponse }> {
    return this.usersService.getCurrentUser(userId);
  }

  /**
   * 更新当前用户信息
   * PATCH /users/me
   */
  @Patch('me')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '更新当前用户信息',
    description: '更新当前登录用户的个人信息，支持更新：昵称、头像、性别、生日、简介',
  })
  @ApiResponse({ status: 200, description: '更新成功', type: UserResponse })
  @ApiResponse({ status: 400, description: '参数错误' })
  @ApiResponse({ status: 401, description: '未登录或Token无效' })
  async updateCurrentUser(
    @CurrentUser('userId') userId: string,
    @Body() dto: UpdateUserDto,
  ): Promise<{ success: boolean; data: UserResponse }> {
    return this.usersService.updateCurrentUser(userId, dto);
  }

  /**
   * 上传用户头像
   * POST /users/avatar
   */
  @Post('avatar')
  @HttpCode(HttpStatus.OK)
  @UseInterceptors(FileInterceptor('file'))
  @ApiOperation({
    summary: '上传用户头像',
    description: '上传用户头像图片，支持 JPG、PNG、WebP 格式，最大 5MB',
  })
  @ApiConsumes('multipart/form-data')
  @ApiResponse({ status: 200, description: '上传成功', type: AvatarUploadResponse })
  @ApiResponse({ status: 400, description: '文件格式错误或文件过大' })
  @ApiResponse({ status: 401, description: '未登录或Token无效' })
  async uploadAvatar(
    @CurrentUser('userId') userId: string,
    @UploadedFile() file: Express.Multer.File,
  ): Promise<{ success: boolean; data: AvatarUploadResponse }> {
    return this.usersService.uploadAvatar(userId, file);
  }
}
