// current-user.decorator.ts - 当前用户装饰器
// 山径APP - 用户模块
// 用于从请求中提取当前登录用户信息

import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * 当前用户装饰器
 * 从请求对象中提取用户信息（由JWT策略设置）
 * 
 * 使用示例：
 * @Get('me')
 * async getCurrentUser(@CurrentUser() user: UserPayload) { ... }
 * 
 * 获取特定字段：
 * @Get('me')
 * async getCurrentUser(@CurrentUser('userId') userId: string) { ... }
 */
export const CurrentUser = createParamDecorator(
  (data: keyof any | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;

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
