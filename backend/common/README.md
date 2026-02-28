# JWT 认证中间件和 Guards 使用说明

## 概述

本文档介绍山径APP后端JWT认证系统的使用方法，包括：
- JWT认证中间件（JwtAuthMiddleware）
- 认证守卫（JwtAuthGuard）
- 公开接口装饰器（@Public）
- 当前用户装饰器（@CurrentUser）
- 角色权限守卫（RolesGuard）

## 目录结构

```
backend/common/
├── decorators/
│   ├── public.decorator.ts      # @Public 装饰器
│   ├── current-user.decorator.ts # @CurrentUser 装饰器
│   └── index.ts
├── middleware/
│   ├── jwt-auth.middleware.ts   # JWT认证中间件
│   └── index.ts
└── guards/
    ├── jwt-auth.guard.ts        # JWT认证守卫
    ├── roles.guard.ts           # 角色权限守卫
    └── index.ts
```

## 1. JWT认证中间件（JwtAuthMiddleware）

### 功能
- 验证请求头中的 `Authorization: Bearer <token>`
- 解析Token获取用户信息
- 处理Token过期、无效等异常情况
- 将用户信息附加到请求对象

### 配置方法

在 `app.module.ts` 中配置为全局中间件：

```typescript
import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { JwtAuthMiddleware } from './common/middleware/jwt-auth.middleware';

@Module({
  // ... 其他配置
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    consumer
      .apply(JwtAuthMiddleware)
      .forRoutes('*'); // 应用到所有路由
  }
}
```

## 2. JWT认证守卫（JwtAuthGuard）

### 功能
- 保护需要登录的接口
- 自动注入当前用户信息
- 支持 `@Public()` 装饰器标记的公开接口

### 全局注册

在 `app.module.ts` 中配置为全局Guard：

```typescript
import { Module } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';

@Module({
  providers: [
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
```

### 局部使用

在Controller或Method上使用：

```typescript
import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

@Controller('users')
@UseGuards(JwtAuthGuard)  // 保护整个Controller
export class UsersController {
  
  @Get('profile')
  @UseGuards(JwtAuthGuard)  // 只保护单个方法
  getProfile() {
    // ...
  }
}
```

## 3. @Public 装饰器

### 功能
标记接口为公开访问，不需要JWT认证。

### 使用示例

```typescript
import { Controller, Get } from '@nestjs/common';
import { Public } from '../common/decorators/public.decorator';

@Controller('auth')
export class AuthController {
  
  @Public()  // 公开接口，不需要登录
  @Post('login')
  login() {
    // ...
  }
  
  @Public()
  @Get('health')
  healthCheck() {
    return { status: 'ok' };
  }
}

// 也可以在Controller级别使用
@Public()
@Controller('public')
export class PublicController {
  // 该Controller下的所有接口都是公开的
}
```

## 4. @CurrentUser 装饰器

### 功能
从请求对象中提取当前登录用户信息。

### 使用示例

```typescript
import { Controller, Get } from '@nestjs/common';
import { CurrentUser, UserPayload } from '../common/decorators/current-user.decorator';

@Controller('users')
export class UsersController {
  
  // 获取完整用户信息
  @Get('me')
  async getCurrentUser(@CurrentUser() user: UserPayload) {
    return {
      userId: user.userId,
      phone: user.phone,
      nickname: user.nickname,
    };
  }
  
  // 获取特定字段
  @Get('id')
  async getUserId(@CurrentUser('userId') userId: string) {
    return { userId };
  }
}
```

### UserPayload 接口

```typescript
interface UserPayload {
  userId: string;      // 用户ID
  phone?: string;      // 手机号
  nickname?: string;   // 昵称
  avatarUrl?: string;  // 头像URL
  type?: 'access' | 'refresh';  // Token类型
  iat?: number;        // 签发时间
  exp?: number;        // 过期时间
}
```

## 5. 角色权限守卫（RolesGuard）

### 功能
基于用户角色进行访问控制（RBAC）。

### 使用示例

```typescript
import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { RolesGuard, Roles, UserRole } from '../common/guards/roles.guard';

@Controller('admin')
@UseGuards(JwtAuthGuard, RolesGuard)  // 需要同时应用两个Guard
export class AdminController {
  
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get('users')
  getAllUsers() {
    // 只有管理员可以访问
  }
  
  @Roles(UserRole.SUPER_ADMIN)
  @Delete('users/:id')
  deleteUser() {
    // 只有超级管理员可以访问
  }
}
```

### 用户角色枚举

```typescript
enum UserRole {
  USER = 'user',           // 普通用户
  ADMIN = 'admin',         // 管理员
  SUPER_ADMIN = 'super_admin',  // 超级管理员
}
```

## 6. 完整配置示例

### app.module.ts

```typescript
import { MiddlewareConsumer, Module, NestModule } from '@nestjs/common';
import { APP_GUARD } from '@nestjs/core';
import { JwtAuthMiddleware } from './common/middleware/jwt-auth.middleware';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';

@Module({
  imports: [
    // ... 其他模块
  ],
  providers: [
    // 全局JWT认证守卫
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule implements NestModule {
  configure(consumer: MiddlewareConsumer) {
    // 全局JWT中间件
    consumer
      .apply(JwtAuthMiddleware)
      .forRoutes('*');
  }
}
```

### 环境变量配置

```bash
# JWT配置
JWT_ACCESS_SECRET=your-access-secret-key
JWT_ACCESS_EXPIRATION=2h
JWT_REFRESH_SECRET=your-refresh-secret-key
JWT_REFRESH_EXPIRATION=7d
```

## 7. 错误码说明

| 错误码 | 说明 | HTTP状态码 |
|--------|------|-----------|
| TOKEN_INVALID_FORMAT | Authorization头格式错误 | 401 |
| TOKEN_EXPIRED | Token已过期 | 401 |
| TOKEN_INVALID | Token无效 | 401 |
| TOKEN_TYPE_ERROR | Token类型错误（非access token） | 401 |
| TOKEN_NOT_ACTIVE | Token尚未生效 | 401 |
| UNAUTHORIZED | 未登录 | 401 |
| FORBIDDEN | 权限不足 | 403 |

## 8. 请求示例

### 携带Token的请求

```bash
# 登录获取Token
curl -X POST http://localhost:3000/auth/login/phone \
  -H "Content-Type: application/json" \
  -d '{"phone": "13800138000", "code": "123456"}'

# 响应
{
  "success": true,
  "data": {
    "user": { ... },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 7200
    }
  }
}

# 使用Token访问受保护接口
curl -X GET http://localhost:3000/users/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."
```

## 9. 注意事项

1. **中间件和Guard的区别**：
   - 中间件负责解析Token并设置用户信息
   - Guard负责决定是否允许访问

2. **执行顺序**：
   - 先执行中间件（JwtAuthMiddleware）
   - 再执行守卫（JwtAuthGuard）

3. **公开接口**：
   - 使用 `@Public()` 装饰器标记的接口会跳过认证检查
   - 但仍会执行中间件（如果有Token会解析用户信息）

4. **Token过期处理**：
   - 当收到 `TOKEN_EXPIRED` 错误时，应使用refreshToken换取新的accessToken
   - 刷新Token接口：`POST /auth/refresh`
