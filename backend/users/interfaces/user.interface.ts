// user.interface.ts - 用户模块接口定义
// 山径APP - 用户模块

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 用户响应数据
 */
export class UserResponse {
  @ApiProperty({ description: '用户ID', example: 'clx1234567890abcdef' })
  id: string;

  @ApiPropertyOptional({ description: '用户昵称', example: '山径行者' })
  nickname?: string;

  @ApiPropertyOptional({ description: '头像URL', example: 'https://example.com/avatar.jpg' })
  avatarUrl?: string;

  @ApiPropertyOptional({ description: '手机号', example: '13800138000' })
  phone?: string;

  @ApiPropertyOptional({ description: '性别', example: 'male', enum: ['male', 'female', 'other'] })
  gender?: string;

  @ApiPropertyOptional({ description: '生日', example: '1990-01-01T00:00:00.000Z' })
  birthday?: Date;

  @ApiPropertyOptional({ description: '个人简介', example: '热爱户外徒步，喜欢探索未知的路径' })
  bio?: string;

  @ApiPropertyOptional({ description: '紧急联系人', example: [{ name: '张三', phone: '13800138000', relation: '配偶' }] })
  emergencyContacts?: any;

  @ApiPropertyOptional({ description: '用户设置', example: {} })
  settings?: any;

  @ApiProperty({ description: '创建时间', example: '2024-01-01T00:00:00.000Z' })
  createdAt: Date;

  @ApiProperty({ description: '更新时间', example: '2024-01-01T00:00:00.000Z' })
  updatedAt: Date;
}

/**
 * 头像上传响应数据
 */
export class AvatarUploadResponse {
  @ApiProperty({ description: '头像URL', example: 'https://example.com/uploads/avatars/xxx.jpg' })
  avatarUrl: string;

  @ApiProperty({ description: '文件名', example: 'xxx.jpg' })
  fileName: string;

  @ApiProperty({ description: '文件大小（字节）', example: 102400 })
  size: number;

  @ApiProperty({ description: '文件类型', example: 'image/jpeg' })
  mimeType: string;
}
