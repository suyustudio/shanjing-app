# 山径APP - 用户系统 API 接口文档

> **文档版本**: v1.0  
> **制定日期**: 2026-02-27  
> **文档状态**: 已完成  
> **对应阶段**: Week 2 - B3 用户系统 API 开发

---

## 目录

1. [接口概览](#1-接口概览)
2. [认证模块](#2-认证模块)
3. [用户模块](#3-用户模块)
4. [错误码定义](#4-错误码定义)
5. [数据模型](#5-数据模型)

---

## 1. 接口概览

### 1.1 基础信息

| 项目 | 说明 |
|------|------|
| 基础URL | `https://api.shanjing.app/v1` |
| 协议 | HTTPS |
| 数据格式 | JSON |
| 认证方式 | Bearer Token |
| 字符编码 | UTF-8 |

### 1.2 请求头规范

```http
Content-Type: application/json
Authorization: Bearer <jwt_token>
X-Request-ID: <uuid>  // 可选，用于请求追踪
```

### 1.3 响应格式

**成功响应:**
```json
{
  "success": true,
  "data": { ... },
  "meta": { ... }  // 分页信息（可选）
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": { ... }  // 详细错误信息（可选）
  }
}
```

### 1.4 接口清单

| 模块 | 方法 | 路径 | 认证 | 说明 |
|------|------|------|------|------|
| 认证 | POST | `/auth/register/phone` | 否 | 手机号注册 |
| 认证 | POST | `/auth/register/wechat` | 否 | 微信OAuth注册 |
| 认证 | POST | `/auth/login/phone` | 否 | 手机号+验证码登录 |
| 认证 | POST | `/auth/login/wechat` | 否 | 微信一键登录 |
| 认证 | POST | `/auth/refresh` | 否 | 刷新Token |
| 认证 | POST | `/auth/logout` | 是 | 退出登录 |
| 用户 | GET | `/users/me` | 是 | 获取当前用户信息 |
| 用户 | PUT | `/users/me` | 是 | 更新用户信息 |
| 用户 | PUT | `/users/me/avatar` | 是 | 上传头像 |
| 用户 | PUT | `/users/me/emergency` | 是 | 更新紧急联系人 |
| 用户 | PUT | `/users/me/phone` | 是 | 绑定手机号 |

---

## 2. 认证模块

### 2.1 手机号注册

**接口:** `POST /auth/register/phone`

**请求体:**
```json
{
  "phone": "13800138000",
  "code": "123456",
  "nickname": "山径用户"  // 可选
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号，11位数字 |
| code | string | 是 | 短信验证码，6位数字 |
| nickname | string | 否 | 用户昵称，2-20字符 |

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
    "code": "INVALID_VERIFICATION_CODE",
    "message": "验证码错误或已过期"
  }
}
```

---

### 2.2 微信OAuth注册

**接口:** `POST /auth/register/wechat`

**请求体:**
```json
{
  "code": "wechat_auth_code",
  "nickname": "微信用户"  // 可选，默认使用微信昵称
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| code | string | 是 | 微信授权code |
| nickname | string | 否 | 自定义昵称 |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "wxOpenid": "o1234567890abcdef",
      "nickname": "微信用户",
      "avatarUrl": "https://thirdwx.qlogo.cn/...",
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

---

### 2.3 手机号+验证码登录

**接口:** `POST /auth/login/phone`

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

**成功响应:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "phone": "13800138000",
      "nickname": "山径用户",
      "avatarUrl": "https://...",
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

**注意:** 如果手机号未注册，自动创建新用户并登录。

---

### 2.4 微信一键登录

**接口:** `POST /auth/login/wechat`

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

**成功响应:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "wxOpenid": "o1234567890abcdef",
      "nickname": "微信用户",
      "avatarUrl": "https://thirdwx.qlogo.cn/...",
      "phone": "13800138000",
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

**注意:** 如果微信用户未注册，自动创建新用户并登录。

---

### 2.5 刷新Token

**接口:** `POST /auth/refresh`

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

---

### 2.6 退出登录

**接口:** `POST /auth/logout`

**认证:** 需要Bearer Token

**请求体:**
```json
{
  "allDevices": false  // 是否登出所有设备，默认false
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| allDevices | boolean | 否 | true时登出所有设备 |

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

## 3. 用户模块

### 3.1 获取当前用户信息

**接口:** `GET /users/me`

**认证:** 需要Bearer Token

**成功响应:**
```json
{
  "success": true,
  "data": {
    "id": "clu1234567890abcdef",
    "wxOpenid": null,
    "nickname": "山径用户",
    "avatarUrl": "https://cdn.shanjing.app/avatars/xxx.jpg",
    "phone": "13800138000",
    "emergencyContacts": [
      {
        "name": "张三",
        "phone": "13900139000",
        "relation": "配偶"
      }
    ],
    "settings": {
      "notificationEnabled": true,
      "autoUpload": false
    },
    "createdAt": "2026-02-27T10:30:00.000Z",
    "updatedAt": "2026-02-27T12:00:00.000Z"
  }
}
```

---

### 3.2 更新用户信息

**接口:** `PUT /users/me`

**认证:** 需要Bearer Token

**请求体:**
```json
{
  "nickname": "新的昵称",
  "settings": {
    "notificationEnabled": true,
    "autoUpload": false
  }
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| nickname | string | 否 | 用户昵称，2-20字符 |
| settings | object | 否 | 用户设置JSON对象 |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "id": "clu1234567890abcdef",
    "nickname": "新的昵称",
    "avatarUrl": "https://cdn.shanjing.app/avatars/xxx.jpg",
    "phone": "13800138000",
    "settings": {
      "notificationEnabled": true,
      "autoUpload": false
    },
    "updatedAt": "2026-02-27T12:30:00.000Z"
  }
}
```

---

### 3.3 上传头像

**接口:** `PUT /users/me/avatar`

**认证:** 需要Bearer Token

**Content-Type:** `multipart/form-data`

**请求体:**
```
avatar: <图片文件>
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| avatar | file | 是 | 头像图片，支持jpg/png，最大2MB |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "avatarUrl": "https://cdn.shanjing.app/avatars/xxx.jpg",
    "updatedAt": "2026-02-27T12:30:00.000Z"
  }
}
```

---

### 3.4 更新紧急联系人

**接口:** `PUT /users/me/emergency`

**认证:** 需要Bearer Token

**请求体:**
```json
{
  "contacts": [
    {
      "name": "张三",
      "phone": "13900139000",
      "relation": "配偶"
    },
    {
      "name": "李四",
      "phone": "13700137000",
      "relation": "朋友"
    }
  ]
}
```

**参数说明:**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| contacts | array | 是 | 紧急联系人列表，最多3个 |
| contacts[].name | string | 是 | 联系人姓名，2-20字符 |
| contacts[].phone | string | 是 | 联系人手机号 |
| contacts[].relation | string | 是 | 关系，如：配偶、父母、朋友 |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "emergencyContacts": [
      {
        "name": "张三",
        "phone": "13900139000",
        "relation": "配偶"
      },
      {
        "name": "李四",
        "phone": "13700137000",
        "relation": "朋友"
      }
    ],
    "updatedAt": "2026-02-27T12:30:00.000Z"
  }
}
```

---

### 3.5 绑定手机号

**接口:** `PUT /users/me/phone`

**认证:** 需要Bearer Token

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
| phone | string | 是 | 要绑定的手机号 |
| code | string | 是 | 短信验证码 |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "phone": "13800138000",
    "updatedAt": "2026-02-27T12:30:00.000Z"
  }
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "PHONE_ALREADY_EXISTS",
    "message": "该手机号已被其他账号绑定"
  }
}
```

---

## 4. 错误码定义

### 4.1 通用错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |
| `BAD_REQUEST` | 400 | 请求参数错误 |
| `UNAUTHORIZED` | 401 | 未授权，Token无效或过期 |
| `FORBIDDEN` | 403 | 禁止访问 |
| `NOT_FOUND` | 404 | 资源不存在 |
| `RATE_LIMITED` | 429 | 请求过于频繁 |

### 4.2 认证错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INVALID_CREDENTIALS` | 401 | 登录凭证无效 |
| `INVALID_VERIFICATION_CODE` | 400 | 验证码错误或已过期 |
| `TOKEN_EXPIRED` | 401 | Token已过期 |
| `TOKEN_INVALID` | 401 | Token无效 |
| `TOKEN_BLACKLISTED` | 401 | Token已被注销 |
| `WECHAT_AUTH_FAILED` | 400 | 微信授权失败 |

### 4.3 用户错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `USER_NOT_FOUND` | 404 | 用户不存在 |
| `PHONE_ALREADY_EXISTS` | 409 | 手机号已被注册 |
| `INVALID_PHONE_FORMAT` | 400 | 手机号格式错误 |
| `INVALID_NICKNAME` | 400 | 昵称格式错误 |
| `FILE_TOO_LARGE` | 400 | 文件过大 |
| `INVALID_FILE_TYPE` | 400 | 文件类型不支持 |

---

## 5. 数据模型

### 5.1 User 模型

```typescript
interface User {
  id: string;                    // 用户唯一ID
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

### 5.2 Token 模型

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

### 5.3 API 响应模型

```typescript
// 成功响应
interface ApiSuccessResponse<T> {
  success: true;
  data: T;
  meta?: PaginationMeta;
}

// 错误响应
interface ApiErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: Record<string, any>;
  };
}

// 分页元数据
interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}
```

---

## 附录

### A. 测试账号

| 类型 | 手机号 | 验证码 | 说明 |
|------|--------|--------|------|
| 测试账号 | 13800138000 | 123456 | 已注册测试用户 |
| 新用户 | 13900139000 | 123456 | 未注册手机号 |

### B. 微信测试

微信登录/注册需要在微信开放平台配置测试账号，测试时使用微信开发者工具的登录模拟功能。

### C. 文件上传限制

| 类型 | 最大大小 | 支持格式 |
|------|----------|----------|
| 头像 | 2MB | jpg, jpeg, png |
| 轨迹图片 | 5MB | jpg, jpeg, png |
| GPX文件 | 10MB | gpx |

---

> **文档说明**: 本文档作为Week 2 B3任务的交付物，包含完整的用户系统API接口定义。所有接口实现以此文档为准。
