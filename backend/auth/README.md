# 山径APP - 用户注册 API 接口文档

> **文档版本**: v1.0  
> **制定日期**: 2026-02-27  
> **文档状态**: 已完成  
> **对应任务**: B3-1 用户注册 API 开发

---

## 目录

1. [接口概览](#1-接口概览)
2. [手机号注册 API](#2-手机号注册-api)
3. [微信 OAuth 注册 API](#3-微信-oauth-注册-api)
4. [登录 API](#4-登录-api)
5. [Token 管理 API](#5-token-管理-api)
6. [错误码定义](#6-错误码定义)
7. [数据模型](#7-数据模型)

---

## 1. 接口概览

### 1.1 基础信息

| 项目 | 说明 |
|------|------|
| 基础URL | `https://api.shanjing.app/v1` |
| 协议 | HTTPS |
| 数据格式 | JSON |
| 认证方式 | Bearer Token（注册/登录接口除外） |
| 字符编码 | UTF-8 |

### 1.2 请求头规范

```http
Content-Type: application/json
Authorization: Bearer <jwt_token>  // 需要认证的接口
X-Request-ID: <uuid>              // 可选，用于请求追踪
```

### 1.3 响应格式

**成功响应:**
```json
{
  "success": true,
  "data": { ... }
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述"
  }
}
```

### 1.4 接口清单

| 模块 | 方法 | 路径 | 认证 | 说明 |
|------|------|------|------|------|
| 验证码 | POST | `/auth/sms/send` | 否 | 发送短信验证码 |
| 注册 | POST | `/auth/register/phone` | 否 | 手机号注册 |
| 注册 | POST | `/auth/register/wechat` | 否 | 微信OAuth注册 |
| 登录 | POST | `/auth/login/phone` | 否 | 手机号登录（自动注册） |
| 登录 | POST | `/auth/login/wechat` | 否 | 微信登录（自动注册） |
| Token | POST | `/auth/refresh` | 否 | 刷新Token |
| Token | POST | `/auth/logout` | 是 | 退出登录 |

---

## 2. 手机号注册 API

### 2.1 发送短信验证码

**接口:** `POST /auth/sms/send`

**说明:** 向指定手机号发送6位数字验证码，用于注册或登录。验证码有效期10分钟，60秒内不能重复发送。

**请求体:**
```json
{
  "phone": "13800138000"
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号，11位数字，以1开头 |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "message": "验证码发送成功",
    "expireSeconds": 600
  }
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "RATE_LIMITED",
    "message": "发送过于频繁，请45秒后再试"
  }
}
```

**HTTP状态码:**
- `200` - 发送成功
- `400` - 手机号格式错误
- `429` - 发送过于频繁

---

### 2.2 手机号注册

**接口:** `POST /auth/register/phone`

**说明:** 使用手机号和验证码注册新账号。注册成功后自动登录，返回用户信息和Token。

**请求体:**
```json
{
  "phone": "13800138000",
  "code": "123456",
  "nickname": "山径用户"
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号，11位数字 |
| code | string | 是 | 短信验证码，6位数字 |
| nickname | string | 否 | 用户昵称，2-20字符，默认"用户XXXX" |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "phone": "13800138000",
      "nickname": "山径用户",
      "avatarUrl": null,
      "createdAt": "2026-02-27T10:30:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 7200
    }
  }
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "PHONE_ALREADY_EXISTS",
    "message": "该手机号已被注册"
  }
}
```

**HTTP状态码:**
- `200` - 注册成功
- `400` - 验证码错误或已过期
- `409` - 手机号已存在

**业务流程:**
1. 验证短信验证码
2. 检查手机号是否已注册
3. 创建用户账号
4. 生成JWT Token
5. 返回用户信息和Token

---

## 3. 微信 OAuth 注册 API

### 3.1 微信OAuth注册

**接口:** `POST /auth/register/wechat`

**说明:** 使用微信授权code注册新账号。系统自动获取微信用户信息（openid、昵称、头像）。

**请求体:**
```json
{
  "code": "wechat_auth_code",
  "nickname": "微信用户"
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| code | string | 是 | 微信授权code，通过微信小程序/公众号授权获取 |
| nickname | string | 否 | 自定义昵称，默认使用微信昵称 |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "nickname": "微信用户",
      "avatarUrl": "https://thirdwx.qlogo.cn/mmopen/...",
      "phone": null,
      "createdAt": "2026-02-27T10:30:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 7200
    }
  }
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "WECHAT_AUTH_FAILED",
    "message": "微信授权失败: code已过期"
  }
}
```

**HTTP状态码:**
- `200` - 注册成功
- `400` - 微信授权失败
- `409` - 该微信账号已被注册

**业务流程:**
1. 使用code换取微信access_token和openid
2. 使用access_token获取微信用户信息（昵称、头像）
3. 检查微信用户是否已注册
4. 创建用户账号
5. 生成JWT Token
6. 返回用户信息和Token

**微信授权流程:**
```
┌─────────┐                    ┌─────────┐                    ┌─────────┐
│  客户端  │ ── 1. 请求授权 ──▶ │  微信   │ ── 2. 用户授权 ──▶ │  用户   │
└─────────┘                    └─────────┘                    └────┬────┘
     │                              │                              │
     │                              │◀─ 3. 授权同意 ───────────────┤
     │                              │                              │
     │◀─ 4. 返回auth code ──────────┤                              │
     │                              │                              │
     │── 5. 发送code到后端 ────────▶│                              │
     │                              │                              │
     │◀─ 6. 返回用户信息+Token ──────┤                              │
```

---

## 4. 登录 API

### 4.1 手机号登录

**接口:** `POST /auth/login/phone`

**说明:** 使用手机号和验证码登录。如果手机号未注册，自动创建新用户并登录。

**请求体:**
```json
{
  "phone": "13800138000",
  "code": "123456"
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号 |
| code | string | 是 | 短信验证码 |

**成功响应:** (与注册相同)
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "tokens": { ... }
  }
}
```

**HTTP状态码:**
- `200` - 登录成功
- `400` - 验证码错误

---

### 4.2 微信一键登录

**接口:** `POST /auth/login/wechat`

**说明:** 使用微信授权code登录。如果微信用户未注册，自动创建新用户并登录。

**请求体:**
```json
{
  "code": "wechat_auth_code"
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| code | string | 是 | 微信授权code |

**成功响应:** (与注册相同)
```json
{
  "success": true,
  "data": {
    "user": { ... },
    "tokens": { ... }
  }
}
```

**HTTP状态码:**
- `200` - 登录成功
- `400` - 微信授权失败

---

## 5. Token 管理 API

### 5.1 刷新Token

**接口:** `POST /auth/refresh`

**说明:** 使用refreshToken换取新的accessToken和refreshToken。

**请求体:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| refreshToken | string | 是 | 刷新令牌 |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIs...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
    "expiresIn": 7200
  }
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "TOKEN_EXPIRED",
    "message": "Token已过期或无效"
  }
}
```

**HTTP状态码:**
- `200` - 刷新成功
- `401` - Token无效或已过期

---

### 5.2 退出登录

**接口:** `POST /auth/logout`

**认证:** 需要Bearer Token

**说明:** 注销当前Token，可选择是否登出所有设备。

**请求体:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "allDevices": false
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| refreshToken | string | 否 | 要注销的刷新令牌 |
| allDevices | boolean | 否 | true时登出所有设备，默认false |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "message": "退出登录成功"
  }
}
```

---

## 6. 错误码定义

### 6.1 通用错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |
| `BAD_REQUEST` | 400 | 请求参数错误 |
| `UNAUTHORIZED` | 401 | 未授权，Token无效或过期 |
| `FORBIDDEN` | 403 | 禁止访问 |
| `NOT_FOUND` | 404 | 资源不存在 |
| `RATE_LIMITED` | 429 | 请求过于频繁 |

### 6.2 注册/登录错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INVALID_VERIFICATION_CODE` | 400 | 验证码错误或已过期 |
| `PHONE_ALREADY_EXISTS` | 409 | 手机号已被注册 |
| `WECHAT_ALREADY_EXISTS` | 409 | 该微信账号已被注册 |
| `WECHAT_AUTH_FAILED` | 400 | 微信授权失败 |
| `INVALID_PHONE_FORMAT` | 400 | 手机号格式错误 |
| `INVALID_NICKNAME` | 400 | 昵称格式错误 |

### 6.3 Token错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `TOKEN_EXPIRED` | 401 | Token已过期 |
| `TOKEN_INVALID` | 401 | Token无效 |
| `TOKEN_BLACKLISTED` | 401 | Token已被注销 |

---

## 7. 数据模型

### 7.1 User 模型

```typescript
interface User {
  id: string;                    // 用户唯一ID (CUID)
  wxOpenid?: string;             // 微信OpenID
  wxUnionid?: string;            // 微信UnionID
  nickname?: string;             // 用户昵称
  avatarUrl?: string;            // 头像URL
  phone?: string;                // 手机号
  emergencyContacts?: EmergencyContact[];  // 紧急联系人
  settings?: UserSettings;       // 用户设置
  createdAt: string;             // 创建时间 (ISO 8601)
  updatedAt: string;             // 更新时间 (ISO 8601)
}

interface EmergencyContact {
  name: string;                  // 联系人姓名
  phone: string;                 // 联系人电话
  relation: string;              // 关系
}

interface UserSettings {
  notificationEnabled?: boolean; // 是否开启通知
  autoUpload?: boolean;          // 是否自动上传轨迹
}
```

### 7.2 Token 模型

```typescript
interface TokenPair {
  accessToken: string;           // 访问令牌
  refreshToken: string;          // 刷新令牌
  expiresIn: number;             // 访问令牌有效期（秒）
}

interface AccessTokenPayload {
  sub: string;                   // 用户ID
  type: 'access';                // Token类型
  iat: number;                   // 签发时间
  exp: number;                   // 过期时间
}

interface RefreshTokenPayload {
  sub: string;                   // 用户ID
  type: 'refresh';               // Token类型
  jti: string;                   // Token唯一ID
  iat: number;                   // 签发时间
  exp: number;                   // 过期时间
}
```

### 7.3 API 响应模型

```typescript
// 成功响应
interface ApiSuccessResponse<T> {
  success: true;
  data: T;
}

// 错误响应
interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
  };
}
```

---

## 附录

### A. 测试账号

| 类型 | 手机号 | 验证码 | 说明 |
|------|--------|--------|------|
| 测试账号 | 13800138000 | 123456 | 万能测试验证码 |
| 新用户 | 13900139000 | 123456 | 未注册手机号 |

### B. 微信测试

微信登录/注册需要在微信开放平台配置测试账号，测试时使用微信开发者工具的登录模拟功能。

**测试code:** `test_code`

### C. 环境变量配置

```bash
# JWT配置
JWT_ACCESS_SECRET=your_access_secret_key
JWT_REFRESH_SECRET=your_refresh_secret_key
JWT_ACCESS_EXPIRATION=2h
JWT_REFRESH_EXPIRATION=7d

# 微信配置
WECHAT_APPID=your_wechat_appid
WECHAT_SECRET=your_wechat_secret
```

### D. 代码文件清单

| 文件路径 | 说明 |
|----------|------|
| `auth.controller.ts` | 注册API Controller |
| `auth.service.ts` | 注册业务逻辑 Service |
| `dto/index.ts` | 请求参数DTO定义 |
| `interfaces/auth.interface.ts` | 类型定义 |

---

> **文档说明**: 本文档作为B3-1任务的交付物，包含完整的用户注册API接口定义。所有接口实现以此文档为准。
