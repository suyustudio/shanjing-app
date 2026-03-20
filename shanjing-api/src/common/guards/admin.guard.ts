// ================================================================
// Admin Guard
// 管理员权限守卫
// ================================================================

import { Injectable, CanActivate, ExecutionContext } from '@nestjs/common';

/**
 * 管理员权限守卫
 * 检查用户是否具有管理员角色
 */
@Injectable()
export class AdminGuard implements CanActivate {
  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // 检查用户是否登录
    if (!user) {
      return false;
    }

    // 检查用户角色
    const adminRoles = ['admin', 'superadmin'];
    return adminRoles.includes(user.role);
  }
}
