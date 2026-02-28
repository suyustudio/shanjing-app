/**
 * 获取当前管理员装饰器
 * 
 * 在控制器方法中使用，获取当前登录的管理员信息
 * 
 * @example
 * ```typescript
 * @Get('profile')
 * getProfile(@CurrentAdmin() admin: AdminInfo) {
 *   return admin;
 * }
 * ```
 */

import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import { AdminRequest } from '../guards/admin-jwt.guard';
import { AdminRole } from '../admin-role.enum';

/**
 * 管理员信息接口
 */
export interface AdminInfo {
  id: string;
  username: string;
  role: AdminRole;
}

export const CurrentAdmin = createParamDecorator(
  (data: keyof AdminInfo | undefined, ctx: ExecutionContext): AdminInfo | any => {
    const request = ctx.switchToHttp().getRequest<AdminRequest>();
    const admin = request.admin;

    if (!admin) {
      return null;
    }

    // 如果指定了字段，返回该字段值
    if (data) {
      return admin[data];
    }

    // 否则返回整个管理员对象
    return admin;
  },
);
