// users.service.ts - 用户信息管理 Service
// 山径APP - 用户模块
// 功能：获取用户信息、更新用户信息、上传头像

import {
  Injectable,
  BadRequestException,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../shanjing-api/src/database/prisma.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { UserResponse, AvatarUploadResponse } from './interfaces/user.interface';
import * as path from 'path';
import * as fs from 'fs';
import * as crypto from 'crypto';

@Injectable()
export class UsersService {
  // 允许的图片格式
  private readonly ALLOWED_MIME_TYPES = [
    'image/jpeg',
    'image/jpg',
    'image/png',
    'image/webp',
  ];
  
  // 最大文件大小：5MB
  private readonly MAX_FILE_SIZE = 5 * 1024 * 1024;
  
  // 头像存储目录
  private readonly AVATAR_UPLOAD_DIR = 'uploads/avatars';

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {
    // 确保上传目录存在
    this.ensureUploadDirExists();
  }

  /**
   * 确保上传目录存在
   */
  private ensureUploadDirExists(): void {
    const uploadPath = path.join(process.cwd(), this.AVATAR_UPLOAD_DIR);
    if (!fs.existsSync(uploadPath)) {
      fs.mkdirSync(uploadPath, { recursive: true });
    }
  }

  // ==================== 获取用户信息 API ====================

  /**
   * 获取当前用户信息
   * @param userId 用户ID
   * @returns 用户信息
   */
  async getCurrentUser(
    userId: string,
  ): Promise<{ success: boolean; data: UserResponse }> {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: '用户不存在',
        },
      });
    }

    return {
      success: true,
      data: this.sanitizeUser(user),
    };
  }

  // ==================== 更新用户信息 API ====================

  /**
   * 更新当前用户信息
   * 支持更新：昵称、头像、性别、生日、简介
   * 
   * @param userId 用户ID
   * @param dto 更新参数
   * @returns 更新后的用户信息
   */
  async updateCurrentUser(
    userId: string,
    dto: UpdateUserDto,
  ): Promise<{ success: boolean; data: UserResponse }> {
    // 检查用户是否存在
    const existingUser = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!existingUser) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: '用户不存在',
        },
      });
    }

    // 构建更新数据
    const updateData: any = {};

    if (dto.nickname !== undefined) {
      updateData.nickname = dto.nickname;
    }

    if (dto.avatarUrl !== undefined) {
      updateData.avatarUrl = dto.avatarUrl;
    }

    if (dto.gender !== undefined) {
      updateData.gender = dto.gender;
    }

    if (dto.birthday !== undefined) {
      updateData.birthday = dto.birthday ? new Date(dto.birthday) : null;
    }

    if (dto.bio !== undefined) {
      updateData.bio = dto.bio;
    }

    // 更新用户
    const updatedUser = await this.prisma.user.update({
      where: { id: userId },
      data: updateData,
    });

    return {
      success: true,
      data: this.sanitizeUser(updatedUser),
    };
  }

  // ==================== 上传头像 API ====================

  /**
   * 上传用户头像
   * 支持图片上传，返回头像 URL
   * 
   * @param userId 用户ID
   * @param file 上传的文件
   * @returns 头像URL
   */
  async uploadAvatar(
    userId: string,
    file: Express.Multer.File,
  ): Promise<{ success: boolean; data: AvatarUploadResponse }> {
    // 验证用户是否存在
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundException({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: '用户不存在',
        },
      });
    }

    // 验证文件是否存在
    if (!file) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'FILE_REQUIRED',
          message: '请选择要上传的文件',
        },
      });
    }

    // 验证文件类型
    if (!this.ALLOWED_MIME_TYPES.includes(file.mimetype)) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'INVALID_FILE_TYPE',
          message: `不支持的文件格式，仅支持: ${this.ALLOWED_MIME_TYPES.map(t => t.replace('image/', '.')).join(', ')}`,
        },
      });
    }

    // 验证文件大小
    if (file.size > this.MAX_FILE_SIZE) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'FILE_TOO_LARGE',
          message: `文件过大，最大支持 ${this.MAX_FILE_SIZE / 1024 / 1024}MB`,
        },
      });
    }

    // 生成唯一文件名
    const fileExt = path.extname(file.originalname) || '.jpg';
    const fileName = `${crypto.randomUUID()}${fileExt}`;
    const filePath = path.join(this.AVATAR_UPLOAD_DIR, fileName);
    const fullPath = path.join(process.cwd(), filePath);

    // 保存文件
    try {
      fs.writeFileSync(fullPath, file.buffer);
    } catch (error) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'UPLOAD_FAILED',
          message: '文件上传失败，请重试',
        },
      });
    }

    // 构建文件URL
    const baseUrl = this.configService.get<string>('APP_URL', 'http://localhost:3000');
    const avatarUrl = `${baseUrl}/${filePath}`;

    // 更新用户头像
    await this.prisma.user.update({
      where: { id: userId },
      data: { avatarUrl },
    });

    // 删除旧头像文件（如果存在且不是默认头像）
    if (user.avatarUrl) {
      this.deleteOldAvatar(user.avatarUrl);
    }

    return {
      success: true,
      data: {
        avatarUrl,
        fileName,
        size: file.size,
        mimeType: file.mimetype,
      },
    };
  }

  /**
   * 删除旧头像文件
   * @param avatarUrl 头像URL
   */
  private deleteOldAvatar(avatarUrl: string): void {
    try {
      // 从URL中提取文件路径
      const url = new URL(avatarUrl);
      const filePath = url.pathname.replace(/^\//, '');
      const fullPath = path.join(process.cwd(), filePath);

      // 检查文件是否存在并删除
      if (fs.existsSync(fullPath)) {
        fs.unlinkSync(fullPath);
      }
    } catch (error) {
      // 删除失败不抛出异常，仅记录日志
      console.warn(`删除旧头像失败: ${avatarUrl}`, error);
    }
  }

  /**
   * 清理用户敏感信息
   * 移除wxOpenid、wxUnionid等敏感字段
   * @param user 用户对象
   * @returns 清理后的用户对象
   */
  private sanitizeUser(user: any): UserResponse {
    const { wxOpenid, wxUnionid, ...safeUser } = user;
    return safeUser as UserResponse;
  }
}
