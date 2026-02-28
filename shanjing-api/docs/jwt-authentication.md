# JWT 认证中间件文档

> **版本**: v1.0  
> **更新日期**: 2026-02-27

---

## 概述

山径APP 使用 JWT (JSON Web Token) 进行用户认证。认证流程基于 Passport.js 和 @nestjs/passport 实现，支持双 Token 机制（Access Token + Refresh Token）。

---

## 架构设计

```
┌─────────────────────────────────────────────────────────────────┐
│                        JWT 认证流程                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐  │
│  │  客户端   │───▶│  API请求  │───▶│ JWT验证  │───▶│ 业务处理  │  │
│  └──────────┘    └──────────┘    └──────────┘    └──────────┘  │
│       │                               │                         │
│       │                               │                         │
│       ▼                               ▼                         │
│  ┌──────────┐                  ┌──────────────┐                │
│  │ 登录请求  │───────────────▶│  生成Token   │                │
│  └──────────┘                  └──────────────┘                │
│                                       │                         │
│                                       ▼                         │
│                                ┌──────────────┐                │
│                                │ 返回Token对  │                │
│                                └──────────────┘                │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Token 类型

### Access Token

- **用途**: 访问受保护的 API 资源
- **有效期**: 2 小时
- **存储位置**: 客户端内存（推荐）或本地存储
- **传输方式**: HTTP Header `Authorization: Bearer <token>`

### Refresh Token

- **用途**: 刷新 Access Token
- **有效期**: 7 天
- **存储位置**: 客户端安全存储（如 Keychain、Keystore）
- **特点**: 
  - 包含唯一标识符 (jti)
  - 支持黑名单机制（用户登出）

---

## Token 结构

### JWT Payload

```typescript
interface TokenPayload {
  sub: string;           // 用户ID (subject)
  type: 'access' | 'refresh';  // Token 类型
  jti?: string;          // Token 唯一ID（仅 refresh token）
  iat?: number;          // 签发时间 (issued at)
  exp?: number;          // 过期时间 (expiration)
}
```

### Access Token 示例

```json
{
  "sub": "clu1234567890abcdef",
  "type": "access",
  "iat": 1709030400,
  "exp": 1709037600
}
```

### Refresh Token 示例

```json
{
  "sub": "clu1234567890abcdef",
  "type": "refresh",
  "jti": "550e8400-e29b-41d4-a716-446655440000",
  "iat": 1709030400,
  "exp": 1709635200
}
```

---

## 核心组件

### 1. JwtStrategy

**文件**: `src/modules/auth/strategies/jwt.strategy.ts`

负责验证 Access Token 的有效性，并提取用户信息。

```typescript
@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    private readonly configService: ConfigService,
    private readonly prisma: PrismaService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_ACCESS_SECRET'),
    });
  }

  async validate(payload: TokenPayload) {
    // 验证 Token 类型
    if (payload.type !== 'access') {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'TOKEN_INVALID',
          message: 'Token类型错误',
        },
      });
    }

    // 查询用户
    const user = await this.prisma.user.findUnique({
      where: { id: payload.sub },
    });

    if (!user) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'USER_NOT_FOUND',
          message: '用户不存在',
        },
      });
    }

    // 返回用户信息，挂载到 request 对象
    return {
      userId: user.id,
      phone: user.phone,
      wxOpenid: user.wxOpenid,
    };
  }
}
```

### 2. JwtAuthGuard

**文件**: `src/common/guards/jwt-auth.guard.ts`

保护路由，确保只有已认证用户可以访问。

```typescript
@Injectable()
export class JwtAuthGuard implements CanActivate {
  canActivate(
    context: ExecutionContext,
  ): boolean | Promise<boolean> | Observable<boolean> {
    const request = context.switchToHttp().getRequest();
    
    // Passport 自动处理 JWT 验证，这里检查 user 是否存在
    if (!request.user) {
      throw new UnauthorizedException({
        success: false,
        error: {
          code: 'UNAUTHORIZED',
          message: '请先登录',
        },
      });
    }

    return true;
  }
}
```

### 3. CurrentUser 装饰器

**文件**: `src/common/decorators/current-user.decorator.ts`

便捷获取当前登录用户信息。

```typescript
export const CurrentUser = createParamDecorator(
  (data: string | undefined, ctx: ExecutionContext) => {
    const request = ctx.switchToHttp().getRequest();
    const user = request.user;

    if (!user) {
      return null;
    }

    return data ? user[data] : user;
  },
);
```

**使用示例**:

```typescript
@Get('me')
async getCurrentUser(@CurrentUser('userId') userId: string) {
  return this.usersService.getUserById(userId);
}
```

---

## 使用方法

### 保护路由

在 Controller 中使用 `@UseGuards(JwtAuthGuard)` 装饰器：

```typescript
@ApiTags('用户')
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller('users')
export class UsersController {
  // 所有路由都需要认证
}
```

### 获取当前用户

```typescript
@Get('me')
async getCurrentUser(
  @CurrentUser('userId') userId: string,  // 获取用户ID
) {
  return this.usersService.getUserById(userId);
}

@Put('me')
async updateUser(
  @CurrentUser() user: any,  // 获取完整用户信息
  @Body() dto: UpdateUserDto,
) {
  return this.usersService.updateUser(user.userId, dto);
}
```

---

## 环境变量配置

```bash
# JWT 配置
JWT_ACCESS_SECRET=your-access-token-secret-key-here
JWT_REFRESH_SECRET=your-refresh-token-secret-key-here
JWT_ACCESS_EXPIRATION=2h
JWT_REFRESH_EXPIRATION=7d
```

### 配置说明

| 变量名 | 说明 | 默认值 |
|--------|------|--------|
| JWT_ACCESS_SECRET | Access Token 签名密钥 | - |
| JWT_REFRESH_SECRET | Refresh Token 签名密钥 | - |
| JWT_ACCESS_EXPIRATION | Access Token 有效期 | 2h |
| JWT_REFRESH_EXPIRATION | Refresh Token 有效期 | 7d |

**安全建议**:
- 使用至少 256 位的随机字符串作为密钥
- 生产环境 Access Token 和 Refresh Token 使用不同的密钥
- 定期轮换密钥（Refresh Token 密钥可更频繁轮换）

---

## Token 刷新流程

```
┌──────────┐                              ┌──────────┐
│  客户端   │                              │  服务器   │
└────┬─────┘                              └────┬─────┘
     │                                         │
     │  1. 使用 Access Token 请求 API          │
     │ ──────────────────────────────────────▶ │
     │                                         │
     │  2. Token 过期，返回 401                │
     │ ◀────────────────────────────────────── │
     │                                         │
     │  3. 使用 Refresh Token 请求新 Token     │
     │ ──────────────────────────────────────▶ │
     │                                         │
     │  4. 验证 Refresh Token                  │
     │     - 检查签名                          │
     │     - 检查过期时间                      │
     │     - 检查黑名单                        │
     │                                         │
     │  5. 生成新的 Token 对                   │
     │ ◀────────────────────────────────────── │
     │                                         │
     │  6. 使用新的 Access Token 重试请求      │
     │ ──────────────────────────────────────▶ │
     │                                         │
     │  7. 返回请求结果                        │
     │ ◀────────────────────────────────────── │
```

---

## 登出机制

### 单设备登出

将当前设备的 Refresh Token 加入黑名单：

```typescript
async logout(dto: LogoutDto): Promise<void> {
  const { refreshToken } = dto;

  if (refreshToken) {
    const payload = this.jwtService.decode(refreshToken) as TokenPayload;
    if (payload && payload.exp) {
      await this.prisma.tokenBlacklist.create({
        data: {
          token: refreshToken,
          expiresAt: new Date(payload.exp * 1000),
        },
      });
    }
  }
}
```

### 全设备登出

将所有该用户的 Token 加入黑名单（需要额外实现）：

```typescript
// TODO: 实现全设备登出
// 方案1: 使用 Redis 存储用户Token版本号
// 方案2: 在 Token 中加入 session ID，批量加入黑名单
```

---

## 安全建议

### 1. Token 存储

**客户端**:
- Access Token: 存储在内存中（React Context、Vuex、Redux 等）
- Refresh Token: 存储在安全存储中（Keychain、Keystore、HttpOnly Cookie）

**不推荐**:
- 不要将 Access Token 存储在 localStorage（XSS 风险）

### 2. HTTPS 传输

生产环境必须使用 HTTPS，防止 Token 被中间人窃取。

### 3. Token 有效期

- Access Token 不宜过长（建议 15 分钟 - 2 小时）
- Refresh Token 不宜过短（建议 7 - 30 天）

### 4. 密钥管理

- 使用环境变量存储密钥，不要硬编码
- 定期轮换密钥
- 不同环境使用不同的密钥

### 5. 黑名单清理

定期清理过期的黑名单记录：

```typescript
// 定时任务：每天清理过期 Token
async cleanExpiredTokens() {
  await this.prisma.tokenBlacklist.deleteMany({
    where: {
      expiresAt: {
        lt: new Date(),
      },
    },
  });
}
```

---

## 错误处理

### 认证错误码

| 错误码 | HTTP 状态码 | 说明 | 处理建议 |
|--------|-------------|------|----------|
| UNAUTHORIZED | 401 | 未提供 Token | 引导用户登录 |
| TOKEN_INVALID | 401 | Token 格式错误或类型错误 | 重新登录 |
| TOKEN_EXPIRED | 401 | Token 已过期 | 使用 Refresh Token 刷新 |
| TOKEN_BLACKLISTED | 401 | Token 已被注销 | 重新登录 |
| USER_NOT_FOUND | 401 | 用户不存在 | 重新登录 |

### 客户端处理示例

```typescript
// Axios 拦截器处理 Token 刷新
axios.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        const refreshToken = await getRefreshToken();
        const response = await axios.post('/auth/refresh', {
          refreshToken,
        });

        const { accessToken } = response.data.data;
        setAccessToken(accessToken);

        originalRequest.headers.Authorization = `Bearer ${accessToken}`;
        return axios(originalRequest);
      } catch (refreshError) {
        // 刷新失败，引导用户重新登录
        redirectToLogin();
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);
```

---

## 测试

### 单元测试

```bash
# 运行 JWT 相关测试
npm run test -- --testPathPattern="jwt"
```

### 集成测试

```bash
# 运行认证流程 e2e 测试
npm run test:e2e -- --testPathPattern="auth"
```

---

## 附录

### 相关文件列表

| 文件路径 | 说明 |
|----------|------|
| `src/modules/auth/strategies/jwt.strategy.ts` | JWT 策略实现 |
| `src/modules/auth/strategies/jwt.strategy.spec.ts` | JWT 策略测试 |
| `src/common/guards/jwt-auth.guard.ts` | JWT 认证守卫 |
| `src/common/guards/jwt-auth.guard.spec.ts` | 守卫测试 |
| `src/common/decorators/current-user.decorator.ts` | 当前用户装饰器 |
| `src/common/decorators/current-user.decorator.spec.ts` | 装饰器测试 |
| `src/modules/auth/auth.service.ts` | Token 生成与刷新服务 |
| `src/modules/auth/auth.service.spec.ts` | 认证服务测试 |
