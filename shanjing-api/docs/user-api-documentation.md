# 山径APP - 用户系统 API 接口文档

> **版本**: v1.0  
> **更新日期**: 2026-02-27  
> **Base URL**: `https://api.shanjing.app/v1`

---

## 目录

1. [认证规范](#1-认证规范)
2. [通用规范](#2-通用规范)
3. [认证模块](#3-认证模块)
4. [用户模块](#4-用户模块)
5. [错误码说明](#5-错误码说明)

---

## 1. 认证规范

### 1.1 Token 认证

所有需要认证的接口都需要在请求头中携带 Bearer Token：

```
Authorization: Bearer <access_token>
```

### 1.2 Token 结构

| Token 类型 | 有效期 | 用途 |
|-----------|--------|------|
| Access Token | 2小时 | 访问受保护资源 |
| Refresh Token | 7天 | 刷新 Access Token |

---

## 2. 通用规范

### 2.1 请求格式

- **Content-Type**: `application/json`
- **编码**: UTF-8

### 2.2 响应格式

**成功响应**:
```json
{
  "success": true,
  "data": { ... },
  "meta": { ... }  // 分页信息（可选）
}
```

**错误响应**:
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

### 2.3 HTTP 状态码

| 状态码 | 含义 | 说明 |
|--------|------|------|
| 200 | 成功 | 请求成功处理 |
| 400 | 请求参数错误 | 参数校验失败 |
| 401 | 未授权 | Token 无效或已过期 |
| 403 | 禁止访问 | 权限不足 |
| 404 | 资源不存在 | 请求的资源不存在 |
| 409 | 资源冲突 | 数据已存在或冲突 |
| 500 | 服务器错误 | 服务器内部错误 |

---

## 3. 认证模块

### 3.1 手机号注册

**接口**: `POST /auth/register/phone`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号，格式：1[3-9]\d{9} |
| code | string | 是 | 短信验证码，6位数字 |
| nickname | string | 否 | 用户昵称，2-20字符 |

**请求示例**:
```json
{
  "phone": "13800138000",
  "code": "123456",
  "nickname": "山径用户"
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "nickname": "山径用户",
      "avatarUrl": null,
      "phone": "13800138000",
      "createdAt": "2026-02-27T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 7200
    }
  }
}
```

**错误码**:

| 错误码 | 说明 |
|--------|------|
| PHONE_ALREADY_EXISTS | 手机号已被注册 |
| INVALID_VERIFICATION_CODE | 验证码错误或已过期 |
| INVALID_PHONE_FORMAT | 手机号格式错误 |

---

### 3.2 微信 OAuth 注册

**接口**: `POST /auth/register/wechat`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| code | string | 是 | 微信授权临时凭证 |
| nickname | string | 否 | 用户昵称，2-20字符 |

**请求示例**:
```json
{
  "code": "wechat_auth_code_xxx",
  "nickname": "微信用户"
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "nickname": "微信用户",
      "avatarUrl": "https://thirdwx.qlogo.cn/...",
      "phone": null,
      "createdAt": "2026-02-27T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 7200
    }
  }
}
```

**错误码**:

| 错误码 | 说明 |
|--------|------|
| WECHAT_ALREADY_EXISTS | 该微信账号已被注册 |
| WECHAT_AUTH_FAILED | 微信授权失败 |

---

### 3.3 手机号+验证码登录

**接口**: `POST /auth/login/phone`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号，格式：1[3-9]\d{9} |
| code | string | 是 | 短信验证码，6位数字 |

**请求示例**:
```json
{
  "phone": "13800138000",
  "code": "123456"
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "nickname": "山径用户",
      "avatarUrl": null,
      "phone": "13800138000",
      "createdAt": "2026-02-27T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 7200
    }
  }
}
```

**说明**: 如果手机号未注册，会自动创建新用户。

**错误码**:

| 错误码 | 说明 |
|--------|------|
| INVALID_VERIFICATION_CODE | 验证码错误或已过期 |

---

### 3.4 微信一键登录

**接口**: `POST /auth/login/wechat`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| code | string | 是 | 微信授权临时凭证 |

**请求示例**:
```json
{
  "code": "wechat_auth_code_xxx"
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "clu1234567890abcdef",
      "nickname": "微信用户",
      "avatarUrl": "https://thirdwx.qlogo.cn/...",
      "phone": null,
      "createdAt": "2026-02-27T10:00:00.000Z"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIs...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
      "expiresIn": 7200
    }
  }
}
```

**说明**: 如果微信账号未注册，会自动创建新用户。

**错误码**:

| 错误码 | 说明 |
|--------|------|
| WECHAT_AUTH_FAILED | 微信授权失败 |

---

### 3.5 刷新 Token

**接口**: `POST /auth/refresh`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| refreshToken | string | 是 | 刷新令牌 |

**请求示例**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs..."
}
```

**响应示例**:
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

**错误码**:

| 错误码 | 说明 |
|--------|------|
| TOKEN_INVALID | Token 类型错误 |
| TOKEN_BLACKLISTED | Token 已被注销 |
| TOKEN_EXPIRED | Token 已过期或无效 |

---

### 3.6 退出登录

**接口**: `POST /auth/logout`

**请求头**: `Authorization: Bearer <access_token>`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| refreshToken | string | 否 | 刷新令牌（用于注销当前设备） |
| allDevices | boolean | 否 | 是否注销所有设备，默认 false |

**请求示例**:
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIs...",
  "allDevices": false
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "message": "退出登录成功"
  }
}
```

---

## 4. 用户模块

所有用户模块接口都需要认证，请求头中需携带 `Authorization: Bearer <access_token>`。

### 4.1 获取当前用户信息

**接口**: `GET /users/me`

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": "clu1234567890abcdef",
    "nickname": "山径用户",
    "avatarUrl": "https://api.shanjing.app/uploads/avatars/avatar_xxx.jpg",
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
    "createdAt": "2026-02-27T10:00:00.000Z",
    "updatedAt": "2026-02-27T12:00:00.000Z"
  }
}
```

---

### 4.2 更新用户信息

**接口**: `PUT /users/me`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| nickname | string | 否 | 用户昵称，2-20字符 |
| settings | object | 否 | 用户设置对象 |

**请求示例**:
```json
{
  "nickname": "新的昵称",
  "settings": {
    "notificationEnabled": true,
    "autoUpload": false
  }
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "id": "clu1234567890abcdef",
    "nickname": "新的昵称",
    "avatarUrl": "https://api.shanjing.app/uploads/avatars/avatar_xxx.jpg",
    "phone": "13800138000",
    "emergencyContacts": [],
    "settings": {
      "notificationEnabled": true,
      "autoUpload": false
    },
    "createdAt": "2026-02-27T10:00:00.000Z",
    "updatedAt": "2026-02-27T14:00:00.000Z"
  }
}
```

---

### 4.3 上传头像

**接口**: `PUT /users/me/avatar`

**Content-Type**: `multipart/form-data`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| avatar | file | 是 | 头像图片，支持 jpg、jpeg、png，最大 2MB |

**响应示例**:
```json
{
  "success": true,
  "data": {
    "avatarUrl": "https://api.shanjing.app/uploads/avatars/avatar_user-1_1709030400000.jpg",
    "updatedAt": "2026-02-27T14:00:00.000Z"
  }
}
```

**错误码**:

| 错误码 | 说明 |
|--------|------|
| FILE_REQUIRED | 请上传文件 |
| INVALID_FILE_TYPE | 仅支持 jpg、jpeg、png 格式的图片 |
| FILE_TOO_LARGE | 文件大小不能超过 2MB |

---

### 4.4 更新紧急联系人

**接口**: `PUT /users/me/emergency`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| contacts | array | 是 | 紧急联系人列表，最多3个 |
| contacts[].name | string | 是 | 联系人姓名，2-20字符 |
| contacts[].phone | string | 是 | 联系人电话，格式：1[3-9]\d{9} |
| contacts[].relation | string | 是 | 关系描述，1-20字符 |

**请求示例**:
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
      "phone": "13800138001",
      "relation": "朋友"
    }
  ]
}
```

**响应示例**:
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
        "phone": "13800138001",
        "relation": "朋友"
      }
    ],
    "updatedAt": "2026-02-27T14:00:00.000Z"
  }
}
```

**错误码**:

| 错误码 | 说明 |
|--------|------|
| TOO_MANY_CONTACTS | 紧急联系人最多只能添加 3 个 |
| INVALID_PHONE_FORMAT | 联系人的手机号格式错误 |

---

### 4.5 绑定手机号

**接口**: `PUT /users/me/phone`

**请求参数**:

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| phone | string | 是 | 手机号，格式：1[3-9]\d{9} |
| code | string | 是 | 短信验证码，6位数字 |

**请求示例**:
```json
{
  "phone": "13800138000",
  "code": "123456"
}
```

**响应示例**:
```json
{
  "success": true,
  "data": {
    "phone": "13800138000",
    "updatedAt": "2026-02-27T14:00:00.000Z"
  }
}
```

**错误码**:

| 错误码 | 说明 |
|--------|------|
| PHONE_ALREADY_EXISTS | 该手机号已被其他账号绑定 |
| INVALID_VERIFICATION_CODE | 验证码错误或已过期 |
| INVALID_PHONE_FORMAT | 手机号格式错误 |

---

## 5. 错误码说明

### 5.1 认证相关错误码

| 错误码 | HTTP 状态码 | 说明 |
|--------|-------------|------|
| UNAUTHORIZED | 401 | 请先登录 |
| TOKEN_INVALID | 401 | Token 类型错误或格式错误 |
| TOKEN_EXPIRED | 401 | Token 已过期 |
| TOKEN_BLACKLISTED | 401 | Token 已被注销 |

### 5.2 用户相关错误码

| 错误码 | HTTP 状态码 | 说明 |
|--------|-------------|------|
| USER_NOT_FOUND | 404 | 用户不存在 |
| PHONE_ALREADY_EXISTS | 409 | 手机号已被注册或绑定 |
| WECHAT_ALREADY_EXISTS | 409 | 微信账号已被注册 |
| INVALID_PHONE_FORMAT | 400 | 手机号格式错误 |
| INVALID_VERIFICATION_CODE | 400 | 验证码错误或已过期 |
| TOO_MANY_CONTACTS | 400 | 紧急联系人超过限制（最多3个） |

### 5.3 文件相关错误码

| 错误码 | HTTP 状态码 | 说明 |
|--------|-------------|------|
| FILE_REQUIRED | 400 | 请上传文件 |
| INVALID_FILE_TYPE | 400 | 不支持的文件类型 |
| FILE_TOO_LARGE | 400 | 文件大小超过限制 |

### 5.4 微信相关错误码

| 错误码 | HTTP 状态码 | 说明 |
|--------|-------------|------|
| WECHAT_AUTH_FAILED | 400 | 微信授权失败 |

---

## 附录 A: 测试环境验证码

在测试环境中，短信验证码固定为 `123456`。

---

## 附录 B: 接口调用示例

### 使用 cURL

```bash
# 手机号注册
curl -X POST https://api.shanjing.app/v1/auth/register/phone \
  -H "Content-Type: application/json" \
  -d '{
    "phone": "13800138000",
    "code": "123456",
    "nickname": "山径用户"
  }'

# 获取用户信息
curl -X GET https://api.shanjing.app/v1/users/me \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..."

# 上传头像
curl -X PUT https://api.shanjing.app/v1/users/me/avatar \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -F "avatar=@/path/to/avatar.jpg"
```

### 使用 JavaScript (Fetch)

```javascript
// 手机号登录
const login = async (phone, code) => {
  const response = await fetch('https://api.shanjing.app/v1/auth/login/phone', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ phone, code }),
  });
  return response.json();
};

// 获取用户信息
const getUserInfo = async (token) => {
  const response = await fetch('https://api.shanjing.app/v1/users/me', {
    headers: {
      'Authorization': `Bearer ${token}`,
    },
  });
  return response.json();
};
```
