import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import {
  PhoneRegisterDto,
  WechatRegisterDto,
  PhoneLoginDto,
  WechatLoginDto,
  RefreshTokenDto,
  LogoutDto,
  PhonePasswordRegisterDto,
  PhonePasswordLoginDto,
} from './dto';
import { AuthResponse, TokenResponse } from './interfaces/auth.interface';

@ApiTags('认证')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  // ========== M3批次1简化版：密码登录 ==========

  @Post('register')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '手机号密码注册（简化版）' })
  @ApiResponse({ status: 200, description: '注册成功' })
  @ApiResponse({ status: 409, description: '手机号已存在' })
  async register(
    @Body() dto: PhonePasswordRegisterDto,
  ): Promise<AuthResponse> {
    return this.authService.registerWithPassword(dto);
  }

  @Post('login')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '手机号密码登录（简化版）' })
  @ApiResponse({ status: 200, description: '登录成功' })
  @ApiResponse({ status: 401, description: '手机号或密码错误' })
  async login(@Body() dto: PhonePasswordLoginDto): Promise<AuthResponse> {
    return this.authService.loginWithPassword(dto);
  }

  // ========== 原有端点（保留兼容） ==========
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '手机号注册' })
  @ApiResponse({ status: 200, description: '注册成功' })
  @ApiResponse({ status: 400, description: '验证码错误或已过期' })
  @ApiResponse({ status: 409, description: '手机号已存在' })
  async registerByPhone(
    @Body() dto: PhoneRegisterDto,
  ): Promise<AuthResponse> {
    return this.authService.registerByPhone(dto);
  }

  @Post('register/wechat')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '微信OAuth注册' })
  @ApiResponse({ status: 200, description: '注册成功' })
  @ApiResponse({ status: 400, description: '微信授权失败' })
  async registerByWechat(
    @Body() dto: WechatRegisterDto,
  ): Promise<AuthResponse> {
    return this.authService.registerByWechat(dto);
  }

  @Post('login/phone')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '手机号+验证码登录' })
  @ApiResponse({ status: 200, description: '登录成功' })
  @ApiResponse({ status: 400, description: '验证码错误' })
  async loginByPhone(@Body() dto: PhoneLoginDto): Promise<AuthResponse> {
    return this.authService.loginByPhone(dto);
  }

  @Post('login/wechat')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '微信一键登录' })
  @ApiResponse({ status: 200, description: '登录成功' })
  @ApiResponse({ status: 400, description: '微信授权失败' })
  async loginByWechat(@Body() dto: WechatLoginDto): Promise<AuthResponse> {
    return this.authService.loginByWechat(dto);
  }

  @Post('refresh')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '刷新Token' })
  @ApiResponse({ status: 200, description: '刷新成功' })
  @ApiResponse({ status: 401, description: 'Token无效或已过期' })
  async refreshToken(@Body() dto: RefreshTokenDto): Promise<TokenResponse> {
    return this.authService.refreshToken(dto.refreshToken);
  }

  @Post('logout')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({ summary: '退出登录' })
  @ApiResponse({ status: 200, description: '退出成功' })
  async logout(@Body() dto: LogoutDto): Promise<{ success: boolean; data: { message: string } }> {
    await this.authService.logout(dto);
    return {
      success: true,
      data: { message: '退出登录成功' },
    };
  }
}
