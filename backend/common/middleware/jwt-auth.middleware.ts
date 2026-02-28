// jwt-auth.middleware.ts - JWT认证中间件
// 山径APP - 通用中间件
// 功能：验证Access Token、解析用户信息、处理Token过期

import {
  Injectable,
  NestMiddleware,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { JwtService } from '@nestjs/jwt';
import { Request, Response, NextFunction } from 'express';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

/**
 * 扩展Express Request类型，添加user属性
 */
declare global {
  namespace Express {
    interface Request {
      /** 当前登录用户信息 */
      user?: {
        userId: string;
        phone?: string;
        nickname?: string;
        avatarUrl?: string;
        type?: 'access' | 'refresh';
        iat?: number;
        exp?: number;
      };
    }
  }
}

/**
 * JWT Token Payload
 */
interface TokenPayload {
  /** 用户ID */
  sub: string;
  /** Token类型: access - 访问令牌, refresh - 刷新令牌 */
  type: 'access' | 'refresh';
  /** 签发时间 */
  iat?: number;
  /** 过期时间 */
  exp?: number;
}

/**
 * JWT认证中间件
 * 
 * 功能说明：
 * 1. 验证请求头中的Authorization Bearer Token
 * 2. 解析Token获取用户信息并附加到请求对象
 * 3. 处理Token过期、无效等异常情况
 * 4. 支持公开接口跳过认证（通过@Public装饰器标记）
 * 
 * 使用方式：
 * 在AppModule中配置为全局中间件
 */
@Injectable()
export class JwtAuthMiddleware implements NestMiddleware {
  private readonly logger = new Logger(JwtAuthMiddleware.name);

  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
    private readonly reflector: Reflector,
  ) {}

  /**
   * 中间件执行逻辑
   * @param req - Express请求对象
   * @param res - Express响应对象
   * @param next - 下一个中间件函数
   */
  async use(req: Request, res: Response, next: NextFunction): Promise<void> {
    // 检查是否是公开接口（通过路由处理器的元数据判断）
    // 注意：这里无法直接获取路由元数据，需要在Guard中处理
    // 中间件阶段只处理Token解析，不拦截请求

    const authHeader = req.headers.authorization;

    // 如果没有Authorization头，直接放行（由Guard决定是否拦截）
    if (!authHeader) {
      return next();
    }

    // 检查Bearer格式
    if (!authHeader.startsWith('Bearer ')) {
      this.logger.warn('Invalid authorization header format');
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'TOKEN_INVALID_FORMAT',
          message: 'Authorization头格式错误，应为Bearer token',
        },
      });
    }

    const token = authHeader.substring(7); // 移除 'Bearer ' 前缀

    try {
      // 验证并解析Token
      const payload = await this.verifyToken(token);

      // 检查Token类型
      if (payload.type !== 'access') {
        throw new UnauthorizedException({
          success: false,
          error: {
            code: 'TOKEN_TYPE_ERROR',
            message: 'Token类型错误，请使用access token',
          },
        });
      }

      // 将用户信息附加到请求对象
      req.user = {
        userId: payload.sub,
        type: payload.type,
        iat: payload.iat,
        exp: payload.exp,
      };

      this.logger.debug(`User authenticated: ${payload.sub}`);
      next();
    } catch (error) {
      // 处理各种Token错误
      this.handleTokenError(error);
    }
  }

  /**
   * 验证JWT Token
   * @param token - JWT令牌
   * @returns 解析后的Token载荷
   * @throws UnauthorizedException 当Token无效或过期时
   */
  private async verifyToken(token: string): Promise<TokenPayload> {
    const secret = this.configService.get<string>('JWT_ACCESS_SECRET');
    
    if (!secret) {
      this.logger.error('JWT_ACCESS_SECRET not configured');
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'SERVER_CONFIG_ERROR',
          message: '服务器配置错误',
        },
      });
    }

    try {
      return await this.jwtService.verifyAsync<TokenPayload>(token, {
        secret,
      });
    } catch (error) {
      throw error;
    }
  }

  /**
   * 处理Token验证错误
   * @param error - 错误对象
   * @throws UnauthorizedException 统一抛出认证错误
   */
  private handleTokenError(error: any): never {
    // JWT错误类型处理
    if (error.name === 'TokenExpiredError') {
      this.logger.warn('Token expired');
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'TOKEN_EXPIRED',
          message: 'Token已过期，请重新登录',
          expiredAt: error.expiredAt,
        },
      });
    }

    if (error.name === 'JsonWebTokenError') {
      this.logger.warn(`JWT Error: ${error.message}`);
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'TOKEN_INVALID',
          message: 'Token无效',
        },
      });
    }

    if (error.name === 'NotBeforeError') {
      this.logger.warn(`Token not active: ${error.message}`);
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'TOKEN_NOT_ACTIVE',
          message: 'Token尚未生效',
        },
      });
    }

    // 如果是已经包装好的UnauthorizedException，直接抛出
    if (error instanceof UnauthorizedException) {
      throw error;
    }

    // 其他未知错误
    this.logger.error(`Unexpected token error: ${error.message}`);
    throw new UnauthorizedException({
      success: false,
      error: {
        code: 'TOKEN_VERIFICATION_FAILED',
        message: 'Token验证失败',
      },
    });
  }
}
