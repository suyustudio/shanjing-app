// jwt-auth.guard.ts - JWT认证守卫
// 山径APP - 通用Guards
// 功能：保护需要登录的接口、自动注入当前用户信息

import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

/**
 * JWT认证守卫
 * 
 * 功能说明：
 * 1. 保护需要登录的接口，未登录用户将被拦截
 * 2. 自动注入当前用户信息到请求对象
 * 3. 支持@Public装饰器标记的公开接口
 * 
 * 使用方式：
 * 1. 全局注册：在AppModule中配置为全局Guard
 * 2. 局部使用：在Controller或Method上使用@UseGuards(JwtAuthGuard)
 * 
 * 示例：
 * @Controller('users')
 * @UseGuards(JwtAuthGuard)
 * export class UsersController { ... }
 */
@Injectable()
export class JwtAuthGuard implements CanActivate {
  private readonly logger = new Logger(JwtAuthGuard.name);

  constructor(private readonly reflector: Reflector) {}

  /**
   * 判断是否允许访问
   * @param context - 执行上下文
   * @returns true - 允许访问，false - 拒绝访问
   */
  canActivate(context: ExecutionContext): boolean {
    // 检查是否是公开接口
    const isPublic = this.isPublicRoute(context);
    
    if (isPublic) {
      this.logger.debug('Public route, skipping auth check');
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // 检查用户是否已认证（由JwtAuthMiddleware设置）
    if (!user) {
      this.logger.warn('Unauthorized access attempt');
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: '请先登录',
        },
      });
    }

    this.logger.debug(`Authorized access for user: ${user.userId}`);
    return true;
  }

  /**
   * 检查当前路由是否为公开接口
   * @param context - 执行上下文
   * @returns true - 公开接口，false - 需要认证
   */
  private isPublicRoute(context: ExecutionContext): boolean {
    // 先检查方法级别的元数据
    const isPublicMethod = this.reflector.getAllAndOverride<boolean>(
      IS_PUBLIC_KEY,
      [context.getHandler(), context.getClass()],
    );

    if (isPublicMethod) {
      return true;
    }

    // 再检查类级别的元数据
    const isPublicClass = this.reflector.getAllAndOverride<boolean>(
      IS_PUBLIC_KEY,
      [context.getClass(), context.getHandler()],
    );

    return isPublicClass ?? false;
  }
}
