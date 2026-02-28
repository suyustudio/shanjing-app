// README.md - 用户信息管理 API 接口文档
// 山径APP - 用户模块

# 用户信息管理 API 文档

## 概述

本文档描述用户信息管理相关的 API 接口，包括获取用户信息、更新用户信息、上传头像等功能。

**Base URL:** `/users`

**认证方式:** Bearer Token (JWT)

---

## 接口列表

### 1. 获取当前用户信息

获取当前登录用户的详细信息。

**请求**

```http
GET /users/me
Authorization: Bearer {accessToken}
```

**响应**

```json
{
  "success": true,
  "data": {
    "id": "clx1234567890abcdef",
    "nickname": "山径行者",
    "avatarUrl": "https://example.com/avatar.jpg",
    "phone": "13800138000",
    "gender": "male",
    "birthday": "1990-01-01T00:00:00.000Z",
    "bio": "热爱户外徒步，喜欢探索未知的路径",
    "emergencyContacts": [
      {
        "name": "张三",
        "phone": "13800138000",
        "relation": "配偶"
      }
    ],
    "settings": {},
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-01T00:00:00.000Z"
  }
}
```

**错误响应**

```json
{
  "success": false,
  "error": {
    "code": "UNAUTHORIZED",
    "message": "请先登录"
  }
}
```

---

### 2. 更新当前用户信息

更新当前登录用户的个人信息，支持更新：昵称、头像、性别、生日、简介。

**请求**

```http
PATCH /users/me
Authorization: Bearer {accessToken}
Content-Type: application/json

{
  "nickname": "山径行者",
  "avatarUrl": "https://example.com/avatar.jpg",
  "gender": "male",
  "birthday": "1990-01-01",
  "bio": "热爱户外徒步，喜欢探索未知的路径"
}
```

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| nickname | string | 否 | 用户昵称，2-20个字符 |
| avatarUrl | string | 否 | 头像URL |
| gender | string | 否 | 性别，可选值：male、female、other |
| birthday | string | 否 | 生日，格式：YYYY-MM-DD |
| bio | string | 否 | 个人简介，最多500个字符 |

**响应**

```json
{
  "success": true,
  "data": {
    "id": "clx1234567890abcdef",
    "nickname": "山径行者",
    "avatarUrl": "https://example.com/avatar.jpg",
    "phone": "13800138000",
    "gender": "male",
    "birthday": "1990-01-01T00:00:00.000Z",
    "bio": "热爱户外徒步，喜欢探索未知的路径",
    "emergencyContacts": null,
    "settings": {},
    "createdAt": "2024-01-01T00:00:00.000Z",
    "updatedAt": "2024-01-02T10:30:00.000Z"
  }
}
```

**错误响应**

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "昵称长度必须在2-20个字符之间"
  }
}
```

---

### 3. 上传用户头像

上传用户头像图片，支持 JPG、PNG、WebP 格式，最大 5MB。

**请求**

```http
POST /users/avatar
Authorization: Bearer {accessToken}
Content-Type: multipart/form-data

file: [二进制图片文件]
```

**请求参数**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| file | File | 是 | 头像图片文件，支持 JPG、PNG、WebP 格式，最大 5MB |

**响应**

```json
{
  "success": true,
  "data": {
    "avatarUrl": "http://localhost:3000/uploads/avatars/xxx.jpg",
    "fileName": "xxx.jpg",
    "size": 102400,
    "mimeType": "image/jpeg"
  }
}
```

**错误响应**

```json
{
  "success": false,
  "error": {
    "code": "INVALID_FILE_TYPE",
    "message": "不支持的文件格式，仅支持: .jpeg, .jpg, .png, .webp"
  }
}
```

```json
{
  "success": false,
  "error": {
    "code": "FILE_TOO_LARGE",
    "message": "文件过大，最大支持 5MB"
  }
}
```

---

## 数据模型

### UserResponse

| 字段 | 类型 | 说明 |
|------|------|------|
| id | string | 用户ID |
| nickname | string | 用户昵称 |
| avatarUrl | string | 头像URL |
| phone | string | 手机号 |
| gender | string | 性别（male/female/other） |
| birthday | Date | 生日 |
| bio | string | 个人简介 |
| emergencyContacts | JSON | 紧急联系人 |
| settings | JSON | 用户设置 |
| createdAt | Date | 创建时间 |
| updatedAt | Date | 更新时间 |

### AvatarUploadResponse

| 字段 | 类型 | 说明 |
|------|------|------|
| avatarUrl | string | 头像URL |
| fileName | string | 文件名 |
| size | number | 文件大小（字节） |
| mimeType | string | 文件类型 |

---

## 错误码

| 错误码 | 说明 |
|--------|------|
| UNAUTHORIZED | 未登录或Token无效 |
| USER_NOT_FOUND | 用户不存在 |
| VALIDATION_ERROR | 参数验证错误 |
| FILE_REQUIRED | 未选择文件 |
| INVALID_FILE_TYPE | 不支持的文件格式 |
| FILE_TOO_LARGE | 文件过大 |
| UPLOAD_FAILED | 文件上传失败 |

---

## 模块集成

### 1. 导入模块

在 `app.module.ts` 中导入 UsersModule：

```typescript
import { Module } from '@nestjs/common';
import { UsersModule } from './users/users.module';

@Module({
  imports: [
    // ... 其他模块
    UsersModule,
  ],
})
export class AppModule {}
```

### 2. 配置静态文件服务

在 `main.ts` 中配置静态文件服务以提供头像访问：

```typescript
import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { NestExpressApplication } from '@nestjs/platform-express';
import { join } from 'path';

async function bootstrap() {
  const app = await NestFactory.create<NestExpressApplication>(AppModule);
  
  // 配置静态文件服务
  app.useStaticAssets(join(__dirname, '..', 'uploads'), {
    prefix: '/uploads',
  });
  
  await app.listen(3000);
}
bootstrap();
```

### 3. 环境变量配置

```env
# 应用基础URL（用于生成头像URL）
APP_URL=http://localhost:3000
```

---

## 文件结构

```
backend/users/
├── users.controller.ts          # 控制器
├── users.service.ts             # 服务
├── users.module.ts              # 模块定义
├── dto/
│   └── update-user.dto.ts       # 更新用户DTO
├── interfaces/
│   └── user.interface.ts        # 用户接口定义
├── decorators/
│   └── current-user.decorator.ts # 当前用户装饰器
└── README.md                    # 接口文档
```
