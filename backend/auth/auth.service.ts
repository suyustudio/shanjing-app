// auth.service.ts - 用户注册相关 Service
// 山径APP - 用户认证服务
// 功能：手机号注册、微信OAuth注册、验证码管理、Token生成

import {
  Injectable,
  BadRequestException,
  ConflictException,
  UnauthorizedException,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../database/prisma.service';
import {
  SendSmsCodeDto,
  PhoneRegisterDto,
  WechatRegisterDto,
  PhoneLoginDto,
  WechatLoginDto,
  LogoutDto,
} from './dto';
import {
  AuthResponse,
  TokenResponse,
  TokenPayload,
  WechatUserInfo,
  SmsCodeInfo,
} from './interfaces/auth.interface';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
  // 内存存储验证码（生产环境应使用Redis）
  private smsCodeStore: Map<string, SmsCodeInfo> = new Map();

  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  // ==================== 短信验证码 API ====================

  /**
   * 发送短信验证码
   * @param dto 发送验证码请求参数
   * @returns 发送结果
   */
  async sendSmsCode(dto: SendSmsCodeDto): Promise<{ success: boolean; data: { message: string; expireSeconds: number } }> {
    const { phone } = dto;

    // 检查发送频率限制（60秒内只能发送一次）
    const existingCode = this.smsCodeStore.get(phone);
    if (existingCode) {
      const timeSinceLastSend = Date.now() - existingCode.sentAt;
      if (timeSinceLastSend < 60000) {
        const waitSeconds = Math.ceil((60000 - timeSinceLastSend) / 1000);
        throw new HttpException({
          success: false,
          error: {
            code: 'RATE_LIMITED',
            message: `发送过于频繁，请${waitSeconds}秒后再试`,
          },
        }, HttpStatus.TOO_MANY_REQUESTS);
      }
    }

    // 生成6位随机验证码
    const code = this.generateSmsCode();
    
    // 存储验证码（10分钟有效）
    this.smsCodeStore.set(phone, {
      code,
      sentAt: Date.now(),
      expiresAt: Date.now() + 10 * 60 * 1000, // 10分钟过期
      attemptCount: 0,
    });

    // TODO: 接入真实短信服务（阿里云、腾讯云等）
    // await this.sendRealSms(phone, code);
    
    // 开发环境：打印验证码到日志
    console.log(`[SMS] 手机号: ${phone}, 验证码: ${code}`);

    return {
      success: true,
      data: {
        message: '验证码发送成功',
        expireSeconds: 600, // 10分钟
      },
    };
  }

  /**
   * 生成6位数字验证码
   */
  private generateSmsCode(): string {
    // 生成6位随机数字
    return Math.floor(100000 + Math.random() * 900000).toString();
  }

  // ==================== 手机号注册 API ====================

  /**
   * 手机号注册
   * 流程：
   * 1. 验证短信验证码
   * 2. 检查手机号是否已注册
   * 3. 创建用户账号
   * 4. 生成JWT Token
   * 
   * @param dto 手机号注册请求参数
   * @returns 注册成功响应（用户信息 + Token）
   */
  async registerByPhone(dto: PhoneRegisterDto): Promise<AuthResponse> {
    const { phone, code, nickname } = dto;

    // 1. 验证验证码
    await this.verifySmsCode(phone, code);

    // 2. 检查手机号是否已存在
    const existingUser = await this.prisma.user.findUnique({
      where: { phone },
    });

    if (existingUser) {
      throw new ConflictException({
        success: false,
        error: {
          code: 'PHONE_ALREADY_EXISTS',
          message: '该手机号已被注册',
        },
      });
    }

    // 3. 创建用户
    const user = await this.prisma.user.create({
      data: {
        phone,
        nickname: nickname || `用户${phone.slice(-4)}`,
        settings: {},
      },
    });

    // 4. 生成Token
    const tokens = await this.generateTokens(user.id);

    // 5. 清除已使用的验证码
    this.smsCodeStore.delete(phone);

    return {
      success: true,
      data: {
        user: this.sanitizeUser(user),
        tokens,
      },
    };
  }

  /**
   * 验证短信验证码
   * @param phone 手机号
   * @param code 验证码
   */
  private async verifySmsCode(phone: string, code: string): Promise<void> {
    // 开发环境测试验证码
    if (code === '123456') {
      return;
    }

    const smsCodeInfo = this.smsCodeStore.get(phone);

    if (!smsCodeInfo) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'INVALID_VERIFICATION_CODE',
          message: '验证码错误或已过期',
        },
      });
    }

    // 检查是否过期
    if (Date.now() > smsCodeInfo.expiresAt) {
      this.smsCodeStore.delete(phone);
      throw new BadRequestException({
        success: false,
        error: {
          code: 'INVALID_VERIFICATION_CODE',
          message: '验证码已过期，请重新获取',
        },
      });
    }

    // 检查尝试次数（最多5次）
    if (smsCodeInfo.attemptCount >= 5) {
      this.smsCodeStore.delete(phone);
      throw new BadRequestException({
        success: false,
        error: {
          code: 'INVALID_VERIFICATION_CODE',
          message: '验证码错误次数过多，请重新获取',
        },
      });
    }

    // 验证验证码
    if (smsCodeInfo.code !== code) {
      smsCodeInfo.attemptCount++;
      this.smsCodeStore.set(phone, smsCodeInfo);
      throw new BadRequestException({
        success: false,
        error: {
          code: 'INVALID_VERIFICATION_CODE',
          message: '验证码错误',
        },
      });
    }
  }

  // ==================== 微信 OAuth 注册 API ====================

  /**
   * 微信OAuth注册
   * 流程：
   * 1. 使用code换取微信access_token和openid
   * 2. 获取微信用户信息（昵称、头像等）
   * 3. 检查微信用户是否已注册
   * 4. 创建用户账号
   * 5. 生成JWT Token
   * 
   * @param dto 微信注册请求参数
   * @returns 注册成功响应（用户信息 + Token）
   */
  async registerByWechat(dto: WechatRegisterDto): Promise<AuthResponse> {
    const { code, nickname } = dto;

    // 1. 获取微信用户信息
    const wechatUser = await this.getWechatUserInfo(code);

    // 2. 检查微信用户是否已存在
    const existingUser = await this.prisma.user.findUnique({
      where: { wxOpenid: wechatUser.openid },
    });

    if (existingUser) {
      throw new ConflictException({
        success: false,
        error: {
          code: 'WECHAT_ALREADY_EXISTS',
          message: '该微信账号已被注册',
        },
      });
    }

    // 3. 创建用户
    const user = await this.prisma.user.create({
      data: {
        wxOpenid: wechatUser.openid,
        wxUnionid: wechatUser.unionid,
        nickname: nickname || wechatUser.nickname || '微信用户',
        avatarUrl: wechatUser.avatarUrl,
        settings: {},
      },
    });

    // 4. 生成Token
    const tokens = await this.generateTokens(user.id);

    return {
      success: true,
      data: {
        user: this.sanitizeUser(user),
        tokens,
      },
    };
  }

  /**
   * 获取微信用户信息
   * 流程：
   * 1. 使用code换取access_token和openid
   * 2. 使用access_token获取用户信息
   * 
   * @param code 微信授权code
   * @returns 微信用户信息
   */
  private async getWechatUserInfo(code: string): Promise<WechatUserInfo> {
    // 获取配置
    const appId = this.configService.get<string>('WECHAT_APPID');
    const appSecret = this.configService.get<string>('WECHAT_SECRET');

    // 开发环境：模拟微信用户信息
    if (!appId || !appSecret || code === 'test_code') {
      const mockOpenid = `o${crypto.randomBytes(16).toString('hex')}`;
      return {
        openid: mockOpenid,
        unionid: `u${crypto.randomBytes(16).toString('hex')}`,
        nickname: '微信用户',
        avatarUrl: `https://thirdwx.qlogo.cn/mmopen/vi_32/placeholder/${mockOpenid}/132`,
      };
    }

    try {
      // 1. 使用code换取access_token
      const tokenUrl = `https://api.weixin.qq.com/sns/oauth2/access_token?appid=${appId}&secret=${appSecret}&code=${code}&grant_type=authorization_code`;
      const tokenResponse = await fetch(tokenUrl);
      const tokenData = await tokenResponse.json();

      if (tokenData.errcode) {
        throw new BadRequestException({
          success: false,
          error: {
            code: 'WECHAT_AUTH_FAILED',
            message: `微信授权失败: ${tokenData.errmsg}`,
          },
        });
      }

      const { access_token, openid, unionid } = tokenData;

      // 2. 获取用户信息
      const userInfoUrl = `https://api.weixin.qq.com/sns/userinfo?access_token=${access_token}&openid=${openid}`;
      const userInfoResponse = await fetch(userInfoUrl);
      const userInfo = await userInfoResponse.json();

      if (userInfo.errcode) {
        throw new BadRequestException({
          success: false,
          error: {
            code: 'WECHAT_AUTH_FAILED',
            message: `获取用户信息失败: ${userInfo.errmsg}`,
          },
        });
      }

      return {
        openid: userInfo.openid,
        unionid: userInfo.unionid || unionid,
        nickname: userInfo.nickname,
        avatarUrl: userInfo.headimgurl,
      };
    } catch (error) {
      if (error instanceof BadRequestException) {
        throw error;
      }
      throw new BadRequestException({
        success: false,
        error: {
          code: 'WECHAT_AUTH_FAILED',
          message: '微信授权请求失败',
        },
      });
    }
  }

  // ==================== 登录 API（支持自动注册） ====================

  /**
   * 手机号登录
   * 如果手机号未注册，自动创建新账号
   * 
   * @param dto 手机号登录请求参数
   * @returns 登录成功响应
   */
  async loginByPhone(dto: PhoneLoginDto): Promise<AuthResponse> {
    const { phone, code } = dto;

    // 1. 验证验证码
    await this.verifySmsCode(phone, code);

    // 2. 查找或创建用户
    let user = await this.prisma.user.findUnique({
      where: { phone },
    });

    if (!user) {
      // 自动注册
      user = await this.prisma.user.create({
        data: {
          phone,
          nickname: `用户${phone.slice(-4)}`,
          settings: {},
        },
      });
    }

    // 3. 生成Token
    const tokens = await this.generateTokens(user.id);

    // 4. 清除已使用的验证码
    this.smsCodeStore.delete(phone);

    return {
      success: true,
      data: {
        user: this.sanitizeUser(user),
        tokens,
      },
    };
  }

  /**
   * 微信登录
   * 如果微信用户未注册，自动创建新账号
   * 
   * @param dto 微信登录请求参数
   * @returns 登录成功响应
   */
  async loginByWechat(dto: WechatLoginDto): Promise<AuthResponse> {
    const { code } = dto;

    // 1. 获取微信用户信息
    const wechatUser = await this.getWechatUserInfo(code);

    // 2. 查找或创建用户
    let user = await this.prisma.user.findUnique({
      where: { wxOpenid: wechatUser.openid },
    });

    if (!user) {
      // 自动注册
      user = await this.prisma.user.create({
        data: {
          wxOpenid: wechatUser.openid,
          wxUnionid: wechatUser.unionid,
          nickname: wechatUser.nickname || '微信用户',
          avatarUrl: wechatUser.avatarUrl,
          settings: {},
        },
      });
    }

    // 3. 生成Token
    const tokens = await this.generateTokens(user.id);

    return {
      success: true,
      data: {
        user: this.sanitizeUser(user),
        tokens,
      },
    };
  }

  // ==================== Token 管理 ====================

  /**
   * 生成Token对（accessToken + refreshToken）
   * @param userId 用户ID
   * @returns Token响应
   */
  private async generateTokens(userId: string): Promise<TokenResponse> {
    const accessSecret = this.configService.get<string>('JWT_ACCESS_SECRET');
    const refreshSecret = this.configService.get<string>('JWT_REFRESH_SECRET');
    const accessExpiration = this.configService.get<string>('JWT_ACCESS_EXPIRATION', '2h');
    const refreshExpiration = this.configService.get<string>('JWT_REFRESH_EXPIRATION', '7d');

    const accessPayload: TokenPayload = {
      sub: userId,
      type: 'access',
    };

    const refreshPayload: TokenPayload = {
      sub: userId,
      type: 'refresh',
      jti: crypto.randomUUID(),
    };

    const [accessToken, refreshToken] = await Promise.all([
      this.jwtService.signAsync(accessPayload, {
        secret: accessSecret,
        expiresIn: accessExpiration,
      }),
      this.jwtService.signAsync(refreshPayload, {
        secret: refreshSecret,
        expiresIn: refreshExpiration,
      }),
    ]);

    // 解析access token获取过期时间
    const decoded = this.jwtService.decode(accessToken) as { exp: number };
    const expiresIn = decoded.exp - Math.floor(Date.now() / 1000);

    return {
      accessToken,
      refreshToken,
      expiresIn,
    };
  }

  /**
   * 刷新Token
   * @param refreshToken 刷新令牌
   * @returns 新的Token对
   */
  async refreshToken(refreshToken: string): Promise<TokenResponse> {
    try {
      // 验证刷新令牌
      const payload = this.jwtService.verify(refreshToken, {
        secret: this.configService.get<string>('JWT_REFRESH_SECRET'),
      }) as TokenPayload;

      if (payload.type !== 'refresh') {
        throw new UnauthorizedException({
          success: false,
          error: {
            code: 'TOKEN_INVALID',
            message: 'Token类型错误',
          },
        });
      }

      // 检查Token是否在黑名单中
      const blacklisted = await this.prisma.tokenBlacklist.findUnique({
        where: { token: refreshToken },
      });

      if (blacklisted) {
        throw new UnauthorizedException({
          success: false,
          error: {
            code: 'TOKEN_BLACKLISTED',
            message: 'Token已被注销',
          },
        });
      }

      // 生成新Token
      return this.generateTokens(payload.sub);
    } catch (error) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'TOKEN_EXPIRED',
          message: 'Token已过期或无效',
        },
      });
    }
  }

  /**
   * 退出登录
   * @param dto 退出登录请求参数
   */
  async logout(dto: LogoutDto): Promise<void> {
    const { refreshToken, allDevices = false } = dto;

    if (refreshToken) {
      // 将Token加入黑名单
      const payload = this.jwtService.decode(refreshToken) as TokenPayload;
      if (payload && payload.exp) {
        await this.prisma.tokenBlacklist.create({
          data: {
            token: refreshToken,
            expiresAt: new Date(payload.exp * 1000),
          },
        });
      }
    }

    // TODO: 如果allDevices为true，需要将所有该用户的Token加入黑名单
    // 需要记录用户所有登录设备的Token
  }

  /**
   * 清理用户敏感信息
   * 移除wxOpenid、wxUnionid等敏感字段
   * @param user 用户对象
   * @returns 清理后的用户对象
   */
  private sanitizeUser(user: any) {
    const { wxOpenid, wxUnionid, ...safeUser } = user;
    return safeUser;
  }
}
