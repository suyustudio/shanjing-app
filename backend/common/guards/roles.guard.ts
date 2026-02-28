// roles.guard.ts - 角色权限守卫
// 山径APP - 通用Guards
// 功能：基于角色的访问控制（RBAC）

import {
  Injectable,
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Logger,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';

/**
 * 角色元数据键
 */
export const ROLES_KEY = 'roles';

/**
 * 用户角色枚举
 */
export enum UserRole {
  /** 普通用户 */
  USER = 'user',
  /** 管理员 */
  ADMIN = 'admin',
  /** 超级管理员 */
  SUPER_ADMIN = 'super_admin',
}

/**
 * 角色权限守卫
 * 
 * 功能说明：
 * 1. 基于用户角色进行访问控制
 * 2. 支持多个角色，满足其一即可访问
 * 3. 需要配合@Roles装饰器使用
 * 
 * 使用示例：
 * @Controller('admin')
 * @UseGuards(JwtAuthGuard, RolesGuard)
 * export class AdminController {
 *   @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
 *   @Get('users')
 *   getAllUsers() { ... }
 * }
 */
@Injectable()
export class RolesGuard implements CanActivate {
  private readonly logger = new Logger(RolesGuard.name);

  constructor(private readonly reflector: Reflector) {}

  /**
   * 判断是否允许访问
   * @param context - 执行上下文
   * @returns true - 允许访问，false - 拒绝访问
   */
  canActivate(context: ExecutionContext): boolean {
    // 获取所需角色
    const requiredRoles = this.reflector.getAllAndOverride<UserRole[]>(
      ROLES_KEY,
      [context.getHandler(), context.getClass()],
    );

    // 如果没有设置角色要求，允许访问
    if (!requiredRoles || requiredRoles.length === 0) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // 检查用户是否已认证
    if (!user) {
      this.logger.warn('Roles check failed: user not authenticated');
      throw new ForbiddenException({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: '无权访问',
        },
      });
    }

    // 检查用户角色（假设用户对象中有role字段）
    const userRole = user.role || UserRole.USER;
    
    // 超级管理员拥有所有权限
    if (userRole === UserRole.SUPER_ADMIN) {
      return true;
    }

    // 检查用户角色是否在允许列表中
    const hasRole = requiredRoles.includes(userRole);

    if (!hasRole) {
      this.logger.warn(
        `Roles check failed: user ${user.userId} with role ${userRole} attempted to access resource requiring ${requiredRoles.join(', ')}`,
      );
      throw new ForbiddenException({
        success: false,
        error: {
          code: 'FORBIDDEN',
          message: '权限不足',
        },
      });
    }

    return true;
  }
}

/**
 * Roles装饰器
 * 用于标记需要特定角色才能访问的接口
 * 
 * 使用示例：
 * @Roles(UserRole.ADMIN)
 * @Get('admin-only')
 * adminOnly() { ... }
 * 
 * @param roles - 允许访问的角色列表
 * @returns 元数据装饰器
 */
export const Roles = (...roles: UserRole[]) => {
  return (target: any, key?: string | symbol, descriptor?: any) => {
    if (descriptor) {
      // 方法装饰器
      Reflect.defineMetadata(ROLES_KEY, roles, descriptor.value);
    } else {
      // 类装饰器
      Reflect.defineMetadata(ROLES_KEY, roles, target);
    }
  };
};
