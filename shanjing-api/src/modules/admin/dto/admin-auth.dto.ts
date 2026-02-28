/**
 * 管理员认证相关 DTO
 */

import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { IsString, IsOptional, IsEnum, MinLength, MaxLength } from 'class-validator';
import { AdminRole } from '../admin-role.enum';

/**
 * 管理员登录请求 DTO
 */
export class AdminLoginDto {
  @ApiProperty({
    description: '用户名',
    example: 'admin',
  })
  @IsString()
  @MinLength(3)
  @MaxLength(50)
  username: string;

  @ApiProperty({
    description: '密码',
    example: 'admin123',
  })
  @IsString()
  @MinLength(6)
  @MaxLength(100)
  password: string;
}

/**
 * 创建管理员请求 DTO
 */
export class CreateAdminDto {
  @ApiProperty({
    description: '用户名',
    example: 'newadmin',
  })
  @IsString()
  @MinLength(3)
  @MaxLength(50)
  username: string;

  @ApiProperty({
    description: '密码',
    example: 'password123',
  })
  @IsString()
  @MinLength(6)
  @MaxLength(100)
  password: string;

  @ApiPropertyOptional({
    description: '昵称',
    example: '新管理员',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  nickname?: string;

  @ApiProperty({
    description: '角色',
    enum: AdminRole,
    example: AdminRole.ADMIN,
  })
  @IsEnum(AdminRole)
  role: AdminRole;
}

/**
 * 更新管理员请求 DTO
 */
export class UpdateAdminDto {
  @ApiPropertyOptional({
    description: '昵称',
    example: '更新的昵称',
  })
  @IsOptional()
  @IsString()
  @MaxLength(100)
  nickname?: string;

  @ApiPropertyOptional({
    description: '密码',
    example: 'newpassword123',
  })
  @IsOptional()
  @IsString()
  @MinLength(6)
  @MaxLength(100)
  password?: string;

  @ApiPropertyOptional({
    description: '角色',
    enum: AdminRole,
    example: AdminRole.OPERATOR,
  })
  @IsOptional()
  @IsEnum(AdminRole)
  role?: AdminRole;

  @ApiPropertyOptional({
    description: '状态：true-启用，false-禁用',
    example: true,
  })
  @IsOptional()
  isActive?: boolean;
}

/**
 * 管理员登录响应 DTO
 */
export class AdminLoginResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiPropertyOptional({ description: '错误信息' })
  errorMessage?: string;

  @ApiProperty({ description: '响应数据' })
  data: {
    admin: {
      id: string;
      username: string;
      nickname: string | null;
      role: AdminRole;
    };
    tokens: {
      accessToken: string;
      refreshToken: string;
      expiresIn: number;
    };
  };
}

/**
 * 管理员信息响应 DTO
 */
export class AdminInfoResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '响应数据' })
  data: {
    id: string;
    username: string;
    nickname: string | null;
    role: AdminRole;
    isActive: boolean;
    lastLoginAt: Date | null;
    createdAt: Date;
  };
}

/**
 * 管理员列表响应 DTO
 */
export class AdminListResponseDto {
  @ApiProperty({ description: '是否成功', example: true })
  success: boolean;

  @ApiProperty({ description: '管理员列表' })
  data: Array<{
    id: string;
    username: string;
    nickname: string | null;
    role: AdminRole;
    isActive: boolean;
    lastLoginAt: Date | null;
    createdAt: Date;
  }>;

  @ApiProperty({ description: '分页信息' })
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
