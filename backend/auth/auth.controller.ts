// auth.controller.ts - 用户注册相关 API Controller
// 山径APP - 用户认证模块
// 功能：手机号注册、微信OAuth注册

import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import {
  SendSmsCodeDto,
  PhoneRegisterDto,
  WechatRegisterDto,
  PhoneLoginDto,
  WechatLoginDto,
  RefreshTokenDto,
  LogoutDto,
} from './dto';
import { AuthResponse, TokenResponse } from './interfaces/auth.interface';

@ApiTags('认证 - 注册/登录')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // ==================== 手机号注册 API ====================

  /**
   * 发送短信验证码
   * POST /auth/sms/send
   */
  @Post('sms/send')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '发送短信验证码',
    description: '向指定手机号发送6位数字验证码，用于注册或登录'
  })
  @ApiResponse({ status: 200, description: '验证码发送成功' })
  @ApiResponse({ status: 400, description: '手机号格式错误' })
  @ApiResponse({ status: 429, description: '发送过于频繁，请稍后再试' })
  async sendSmsCode(
    @Body() dto: SendSmsCodeDto,
  ): Promise<{ success: boolean; data: { message: string; expireSeconds: number } }> {
    return this.authService.sendSmsCode(dto);
  }

  /**
   * 手机号注册
   * POST /auth/register/phone
   */
  @Post('register/phone')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '手机号注册',
    description: '使用手机号和验证码注册新账号'
  })
  @ApiResponse({ status: 200, description: '注册成功，返回用户信息和Token' })
  @ApiResponse({ status: 400, description: '验证码错误或已过期' })
  @ApiResponse({ status: 409, description: '手机号已被注册' })
  async registerByPhone(
    @Body() dto: PhoneRegisterDto,
  ): Promise<AuthResponse> {
    return this.authService.registerByPhone(dto);
  }

  // ==================== 微信 OAuth 注册 API ====================

  /**
   * 微信OAuth注册
   * POST /auth/register/wechat
   */
  @Post('register/wechat')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '微信OAuth注册',
    description: '使用微信授权code注册新账号，自动获取微信用户信息'
  })
  @ApiResponse({ status: 200, description: '注册成功，返回用户信息和Token' })
  @ApiResponse({ status: 400, description: '微信授权失败或code已过期' })
  @ApiResponse({ status: 409, description: '该微信账号已被注册' })
  async registerByWechat(
    @Body() dto: WechatRegisterDto,
  ): Promise<AuthResponse> {
    return this.authService.registerByWechat(dto);
  }

  // ==================== 登录 API（支持自动注册） ====================

  /**
   * 手机号登录（未注册自动注册）
   * POST /auth/login/phone
   */
  @Post('login/phone')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '手机号+验证码登录',
    description: '使用手机号和验证码登录，如果手机号未注册则自动创建账号'
  })
  @ApiResponse({ status: 200, description: '登录成功，返回用户信息和Token' })
  @ApiResponse({ status: 400, description: '验证码错误或已过期' })
  async loginByPhone(@Body() dto: PhoneLoginDto): Promise<AuthResponse> {
    return this.authService.loginByPhone(dto);
  }

  /**
   * 微信一键登录（未注册自动注册）
   * POST /auth/login/wechat
   */
  @Post('login/wechat')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '微信一键登录',
    description: '使用微信授权code登录，如果微信用户未注册则自动创建账号'
  })
  @ApiResponse({ status: 200, description: '登录成功，返回用户信息和Token' })
  @ApiResponse({ status: 400, description: '微信授权失败或code已过期' })
  async loginByWechat(@Body() dto: WechatLoginDto): Promise<AuthResponse> {
    return this.authService.loginByWechat(dto);
  }

  // ==================== Token 管理 API ====================

  /**
   * 刷新Token
   * POST /auth/refresh
   */
  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '刷新Token',
    description: '使用refreshToken换取新的accessToken和refreshToken'
  })
  @ApiResponse({ status: 200, description: '刷新成功' })
  @ApiResponse({ status: 401, description: 'Token无效或已过期' })
  async refreshToken(@Body() dto: RefreshTokenDto): Promise<TokenResponse> {
    return this.authService.refreshToken(dto.refreshToken);
  }

  /**
   * 退出登录
   * POST /auth/logout
   */
  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ 
    summary: '退出登录',
    description: '注销当前Token，可选择是否登出所有设备'
  })
  @ApiResponse({ status: 200, description: '退出登录成功' })
  async logout(@Body() dto: LogoutDto): Promise<{ success: boolean; data: { message: string } }> {
    await this.authService.logout(dto);
    return {
      success: true,
      data: { message: '退出登录成功' },
    };
  }
}
