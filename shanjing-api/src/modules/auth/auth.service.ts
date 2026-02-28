import {
  Injectable,
  BadRequestException,
  ConflictException,
  UnauthorizedException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../../database/prisma.service';
import {
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
} from './interfaces/auth.interface';
import * as crypto from 'crypto';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  /**
   * 手机号注册
   */
  async registerByPhone(dto: PhoneRegisterDto): Promise<AuthResponse> {
    const { phone, code, nickname } = dto;

    // 验证验证码
    await this.verifySmsCode(phone, code);

    // 检查手机号是否已存在
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

    // 创建用户
    const user = await this.prisma.user.create({
      data: {
        phone,
        nickname: nickname || `用户${phone.slice(-4)}`,
        settings: {},
      },
    });

    // 生成Token
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
   * 微信OAuth注册
   */
  async registerByWechat(dto: WechatRegisterDto): Promise<AuthResponse> {
    const { code, nickname } = dto;

    // 获取微信用户信息
    const wechatUser = await this.getWechatUserInfo(code);

    // 检查微信用户是否已存在
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

    // 创建用户
    const user = await this.prisma.user.create({
      data: {
        wxOpenid: wechatUser.openid,
        wxUnionid: wechatUser.unionid,
        nickname: nickname || wechatUser.nickname || '微信用户',
        avatarUrl: wechatUser.avatarUrl,
        settings: {},
      },
    });

    // 生成Token
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
   * 手机号登录
   */
  async loginByPhone(dto: PhoneLoginDto): Promise<AuthResponse> {
    const { phone, code } = dto;

    // 验证验证码
    await this.verifySmsCode(phone, code);

    // 查找或创建用户
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

    // 生成Token
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
   * 微信登录
   */
  async loginByWechat(dto: WechatLoginDto): Promise<AuthResponse> {
    const { code } = dto;

    // 获取微信用户信息
    const wechatUser = await this.getWechatUserInfo(code);

    // 查找或创建用户
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

    // 生成Token
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
   * 刷新Token
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
  }

  /**
   * 生成Token对
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
   * 验证短信验证码
   * TODO: 接入真实的短信服务
   */
  private async verifySmsCode(phone: string, code: string): Promise<void> {
    // 测试环境验证码
    const testCode = '123456';
    
    if (code !== testCode) {
      throw new BadRequestException({
        success: false,
        error: {
          code: 'INVALID_VERIFICATION_CODE',
          message: '验证码错误或已过期',
        },
      });
    }
  }

  /**
   * 获取微信用户信息
   * TODO: 接入真实的微信API
   */
  private async getWechatUserInfo(code: string): Promise<WechatUserInfo> {
    // 模拟微信用户信息
    // 实际实现需要调用微信API:
    // 1. 使用code换取access_token和openid
    // 2. 使用access_token获取用户信息
    
    const mockOpenid = `o${crypto.randomBytes(16).toString('hex')}`;
    
    return {
      openid: mockOpenid,
      unionid: `u${crypto.randomBytes(16).toString('hex')}`,
      nickname: '微信用户',
      avatarUrl: `https://thirdwx.qlogo.cn/mmopen/vi_32/placeholder/${mockOpenid}/132`,
    };
  }

  /**
   * 清理用户敏感信息
   */
  private sanitizeUser(user: any) {
    const { wxOpenid, wxUnionid, ...safeUser } = user;
    return safeUser;
  }
}
