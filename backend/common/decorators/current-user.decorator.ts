// current-user.decorator.ts - 当前用户装饰器
// 山径APP - 通用装饰器
// 用于从请求中提取当前登录用户信息

import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * 用户载荷接口
 */
export interface UserPayload {
  /** 用户ID */
  userId: string;
  /** 手机号 */
  phone?: string;
  /** 昵称 */
  nickname?: string;
  /** 头像URL */
  avatarUrl?: string;
  /** Token类型 */
  type?: 'access' | 'refresh';
  /** Token签发时间 */
  iat?: number;
  /** Token过期时间 */
  exp?: number;
}

/**
 * 当前用户装饰器
 * 从请求对象中提取用户信息（由JWT中间件设置）
 * 
 * 使用示例：
 * @Get('me')
 * async getCurrentUser(@CurrentUser() user: UserPayload) { ... }
 * 
 * 获取特定字段：
 * @Get('me')
 * async getCurrentUser(@CurrentUser('userId') userId: string) { ... }
 * 
 * @param data - 可选，指定要获取的用户字段
 * @param ctx - 执行上下文
 * @returns 用户对象或指定字段值
 */
export const CurrentUser = createParamDecorator(
  (data: keyof UserPayload | undefined, ctx: ExecutionContext): UserPayload | any => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user as UserPayload;

    if (!user) {
      return null;
    }

    // 如果指定了字段名，返回该字段值
    if (data) {
      return user[data];
    }

    // 否则返回整个用户对象
    return user;
  },
);
