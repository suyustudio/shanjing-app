// public.decorator.ts - 公开接口装饰器
// 山径APP - 通用装饰器
// 用于标记不需要登录的接口

import { SetMetadata } from '@nestjs/common';

/**
 * 公开接口元数据键
 */
export const IS_PUBLIC_KEY = 'isPublic';

/**
 * Public 装饰器
 * 标记接口为公开访问，不需要JWT认证
 * 
 * 使用示例：
 * @Public()
 * @Get('health')
 * healthCheck() { ... }
 * 
 * 在Controller级别使用：
 * @Public()
 * @Controller('public')
 * export class PublicController { ... }
 * 
 * @returns 元数据装饰器
 */
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
