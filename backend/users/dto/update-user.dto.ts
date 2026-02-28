// update-user.dto.ts - 更新用户信息请求 DTO
// 山径APP - 用户模块请求参数定义

import { IsString, IsOptional, Length, IsEnum, IsDateString, Matches } from 'class-validator';
import { ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 性别枚举
 */
export enum Gender {
  MALE = 'male',
  FEMALE = 'female',
  OTHER = 'other',
}

/**
 * 更新用户信息请求 DTO
 * PATCH /users/me
 */
export class UpdateUserDto {
  @ApiPropertyOptional({
    description: '用户昵称',
    example: '山径行者',
    minLength: 2,
    maxLength: 20,
  })
  @IsOptional()
  @IsString()
  @Length(2, 20, { message: '昵称长度必须在2-20个字符之间' })
  nickname?: string;

  @ApiPropertyOptional({
    description: '头像URL',
    example: 'https://example.com/avatar.jpg',
  })
  @IsOptional()
  @IsString()
  avatarUrl?: string;

  @ApiPropertyOptional({
    description: '性别',
    example: 'male',
    enum: Gender,
    enumName: 'Gender',
  })
  @IsOptional()
  @IsEnum(Gender, { message: '性别必须是 male、female 或 other' })
  gender?: string;

  @ApiPropertyOptional({
    description: '生日',
    example: '1990-01-01',
    format: 'date',
  })
  @IsOptional()
  @IsDateString({}, { message: '生日格式错误，请使用 YYYY-MM-DD 格式' })
  birthday?: string;

  @ApiPropertyOptional({
    description: '个人简介',
    example: '热爱户外徒步，喜欢探索未知的路径',
    maxLength: 500,
  })
  @IsOptional()
  @IsString()
  @Length(0, 500, { message: '简介长度不能超过500个字符' })
  bio?: string;
}
