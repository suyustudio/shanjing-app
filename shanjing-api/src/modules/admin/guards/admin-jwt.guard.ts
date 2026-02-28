/**
 * 管理员 JWT 认证守卫
 * 
 * 验证请求中的管理员 Token，确保用户已登录且是管理员身份
 */

import {
  Injectable,
  CanActivate,
  ExecutionContext,
  UnauthorizedException,
  ForbiddenException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { ConfigService } from '@nestjs/config';
import { Request } from 'express';
import { AdminRole, AdminPermission, hasPermission } from '../admin-role.enum';

/**
 * 扩展 Express Request 类型
 */
export interface AdminRequest extends Request {
  admin?: {
    id: string;
    username: string;
    role: AdminRole;
  };
}

/**
 * Token 载荷接口
 */
interface AdminTokenPayload {
  sub: string;
  username: string;
  role: AdminRole;
  type: string;
}

@Injectable()
export class AdminJwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly configService: ConfigService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest<AdminRequest>();
    const token = this.extractTokenFromHeader(request);

    if (!token) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'ADMIN_TOKEN_MISSING',
          message: '管理员认证令牌缺失',
        },
      });
    }

    try {
      const payload = await this.jwtService.verifyAsync<AdminTokenPayload>(
        token,
        {
          secret: this.configService.get<string>('ADMIN_JWT_SECRET'),
        },
      );

      // 验证 Token 类型
      if (payload.type !== 'admin_access') {
        throw new UnauthorizedException({
          success: false,
          error: {
            code: 'ADMIN_TOKEN_INVALID',
            message: '无效的管理员令牌',
          },
        });
      }

      // 将管理员信息附加到请求对象
      request.admin = {
        id: payload.sub,
        username: payload.username,
        role: payload.role,
      };

      return true;
    } catch (error) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'ADMIN_TOKEN_EXPIRED',
          message: '管理员令牌已过期或无效',
        },
      });
    }
  }

  private extractTokenFromHeader(request: AdminRequest): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}

/**
 * 管理员权限守卫
 * 
 * 验证管理员是否具有指定的权限
 */
@Injectable()
export class AdminPermissionGuard implements CanActivate {
  constructor(private readonly requiredPermission: AdminPermission) {}

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<AdminRequest>();
    const admin = request.admin;

    if (!admin) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'ADMIN_NOT_AUTHENTICATED',
          message: '管理员未认证',
        },
      });
    }

    if (!hasPermission(admin.role, this.requiredPermission)) {
      throw new ForbiddenException({
        success: false,
        error: {
          code: 'ADMIN_PERMISSION_DENIED',
          message: '管理员权限不足',
        },
      });
    }

    return true;
  }
}

/**
 * 超级管理员守卫
 * 
 * 仅允许超级管理员访问
 */
@Injectable()
export class SuperAdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest<AdminRequest>();
    const admin = request.admin;

    if (!admin) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'ADMIN_NOT_AUTHENTICATED',
          message: '管理员未认证',
        },
      });
    }

    if (admin.role !== AdminRole.SUPER_ADMIN) {
      throw new ForbiddenException({
        success: false,
        error: {
          code: 'SUPER_ADMIN_REQUIRED',
          message: '需要超级管理员权限',
        },
      });
    }

    return true;
  }
}
