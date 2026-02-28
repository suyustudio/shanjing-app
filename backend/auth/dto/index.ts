// dto/index.ts - 注册相关 DTO（数据传输对象）
// 山径APP - 认证模块请求参数定义

import { IsString, IsOptional, Length, Matches, IsBoolean } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

/**
 * 发送短信验证码请求 DTO
 * POST /auth/sms/send
 */
export class SendSmsCodeDto {
  @ApiProperty({ 
    description: '手机号', 
    example: '13800138000',
    pattern: '^1[3-9]\\d{9}$'
  })
  @IsString()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式错误，请输入11位有效手机号' })
  phone: string;
}

/**
 * 手机号注册请求 DTO
 * POST /auth/register/phone
 */
export class PhoneRegisterDto {
  @ApiProperty({ 
    description: '手机号', 
    example: '13800138000',
    pattern: '^1[3-9]\\d{9}$'
  })
  @IsString()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式错误，请输入11位有效手机号' })
  phone: string;

  @ApiProperty({ 
    description: '短信验证码', 
    example: '123456',
    minLength: 6,
    maxLength: 6
  })
  @IsString()
  @Length(6, 6, { message: '验证码必须是6位数字' })
  code: string;

  @ApiPropertyOptional({ 
    description: '用户昵称', 
    example: '山径用户',
    minLength: 2,
    maxLength: 20
  })
  @IsOptional()
  @IsString()
  @Length(2, 20, { message: '昵称长度必须在2-20个字符之间' })
  nickname?: string;
}

/**
 * 微信OAuth注册请求 DTO
 * POST /auth/register/wechat
 */
export class WechatRegisterDto {
  @ApiProperty({ 
    description: '微信授权code', 
    example: 'wechat_auth_code',
    notes: '通过微信小程序或公众号授权获取的临时code'
  })
  @IsString()
  code: string;

  @ApiPropertyOptional({ 
    description: '用户昵称（可选，默认使用微信昵称）', 
    example: '微信用户',
    minLength: 2,
    maxLength: 20
  })
  @IsOptional()
  @IsString()
  @Length(2, 20, { message: '昵称长度必须在2-20个字符之间' })
  nickname?: string;
}

/**
 * 手机号登录请求 DTO
 * POST /auth/login/phone
 */
export class PhoneLoginDto {
  @ApiProperty({ 
    description: '手机号', 
    example: '13800138000',
    pattern: '^1[3-9]\\d{9}$'
  })
  @IsString()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式错误，请输入11位有效手机号' })
  phone: string;

  @ApiProperty({ 
    description: '短信验证码', 
    example: '123456',
    minLength: 6,
    maxLength: 6
  })
  @IsString()
  @Length(6, 6, { message: '验证码必须是6位数字' })
  code: string;
}

/**
 * 微信登录请求 DTO
 * POST /auth/login/wechat
 */
export class WechatLoginDto {
  @ApiProperty({ 
    description: '微信授权code', 
    example: 'wechat_auth_code',
    notes: '通过微信小程序或公众号授权获取的临时code'
  })
  @IsString()
  code: string;
}

/**
 * 刷新Token请求 DTO
 * POST /auth/refresh
 */
export class RefreshTokenDto {
  @ApiProperty({ 
    description: '刷新令牌', 
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  })
  @IsString()
  refreshToken: string;
}

/**
 * 退出登录请求 DTO
 * POST /auth/logout
 */
export class LogoutDto {
  @ApiPropertyOptional({ 
    description: '刷新令牌（可选，用于注销特定设备）', 
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...'
  })
  @IsOptional()
  @IsString()
  refreshToken?: string;

  @ApiPropertyOptional({ 
    description: '是否登出所有设备', 
    default: false,
    example: false
  })
  @IsOptional()
  @IsBoolean()
  allDevices?: boolean;
}
