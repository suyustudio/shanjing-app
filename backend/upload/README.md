# 文件上传 API 接口文档

> **文档版本**: v1.0  
> **最后更新**: 2026-02-27  
> **模块**: upload  
> **基础路径**: `/upload`

---

## 目录

1. [概述](#1-概述)
2. [认证方式](#2-认证方式)
3. [接口列表](#3-接口列表)
   - [3.1 单张图片上传](#31-单张图片上传)
   - [3.2 批量图片上传](#32-批量图片上传)
4. [错误码说明](#4-错误码说明)
5. [环境变量配置](#5-环境变量配置)
6. [使用示例](#6-使用示例)

---

## 1. 概述

文件上传模块提供图片上传功能，支持单张和批量上传，图片将存储到阿里云OSS。

### 功能特性

| 特性 | 说明 |
|------|------|
| 支持格式 | JPG、PNG、WebP |
| 单文件限制 | 最大 5MB |
| 批量限制 | 最多 9 张图片 |
| 存储路径 | `images/{userId}/{date}/{uuid}.{ext}` |
| 认证方式 | JWT Bearer Token |

---

## 2. 认证方式

所有上传接口都需要 JWT 认证，请在请求头中添加：

```http
Authorization: Bearer <access_token>
```

Token 通过登录接口获取，有效期 2 小时。

---

## 3. 接口列表

### 3.1 单张图片上传

上传单张图片到 OSS。

**请求信息**

| 项目 | 内容 |
|------|------|
| 方法 | `POST` |
| 路径 | `/upload/image` |
| Content-Type | `multipart/form-data` |
| 认证 | 需要 |

**请求参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| file | File | 是 | 图片文件，支持 JPG、PNG、WebP，最大 5MB |

**响应格式**

```typescript
{
  success: boolean;      // 是否成功
  data?: {               // 成功时返回
    url: string;         // 图片访问 URL
    key: string;         // 文件存储路径
    size: number;        // 文件大小（字节）
    mimeType: string;    // MIME 类型
    originalName: string; // 原始文件名
  };
  error?: {              // 失败时返回
    code: string;        // 错误码
    message: string;     // 错误信息
  };
}
```

**成功响应示例**

```json
{
  "success": true,
  "data": {
    "url": "https://shanjing-oss.oss-cn-hangzhou.aliyuncs.com/images/ou_xxx/20250227/a1b2c3d4e5f6.jpg",
    "key": "images/ou_xxx/20250227/a1b2c3d4e5f6.jpg",
    "size": 1024567,
    "mimeType": "image/jpeg",
    "originalName": "mountain_view.jpg"
  }
}
```

**错误响应示例**

```json
{
  "success": false,
  "error": {
    "code": "FILE_TOO_LARGE",
    "message": "图片大小不能超过5MB"
  }
}
```

---

### 3.2 批量图片上传

批量上传多张图片，最多 9 张。

**请求信息**

| 项目 | 内容 |
|------|------|
| 方法 | `POST` |
| 路径 | `/upload/images` |
| Content-Type | `multipart/form-data` |
| 认证 | 需要 |

**请求参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| files | File[] | 是 | 图片文件数组，最多 9 张，每张最大 5MB |

**响应格式**

```typescript
{
  success: boolean;      // 是否成功
  data?: {               // 成功时返回
    urls: Array<{        // 上传成功的文件列表
      url: string;
      key: string;
      size: number;
      mimeType: string;
      originalName: string;
    }>;
    total: number;       // 总文件数
    successCount: number; // 成功数量
    failCount: number;   // 失败数量
    errors?: Array<{     // 失败详情（如果有）
      index: number;
      message: string;
    }>;
  };
  error?: {              // 失败时返回
    code: string;
    message: string;
    details?: any;
  };
}
```

**成功响应示例**

```json
{
  "success": true,
  "data": {
    "urls": [
      {
        "url": "https://shanjing-oss.oss-cn-hangzhou.aliyuncs.com/images/ou_xxx/20250227/a1b2c3d4.jpg",
        "key": "images/ou_xxx/20250227/a1b2c3d4.jpg",
        "size": 1024567,
        "mimeType": "image/jpeg",
        "originalName": "photo1.jpg"
      },
      {
        "url": "https://shanjing-oss.oss-cn-hangzhou.aliyuncs.com/images/ou_xxx/20250227/b2c3d4e5.png",
        "key": "images/ou_xxx/20250227/b2c3d4e5.png",
        "size": 2048567,
        "mimeType": "image/png",
        "originalName": "photo2.png"
      }
    ],
    "total": 2,
    "successCount": 2,
    "failCount": 0
  }
}
```

**部分失败响应示例**

```json
{
  "success": true,
  "data": {
    "urls": [
      {
        "url": "https://shanjing-oss.oss-cn-hangzhou.aliyuncs.com/images/ou_xxx/20250227/a1b2c3d4.jpg",
        "key": "images/ou_xxx/20250227/a1b2c3d4.jpg",
        "size": 1024567,
        "mimeType": "image/jpeg",
        "originalName": "photo1.jpg"
      }
    ],
    "total": 2,
    "successCount": 1,
    "failCount": 1,
    "errors": [
      {
        "index": 1,
        "message": "上传失败"
      }
    ]
  }
}
```

---

## 4. 错误码说明

| 错误码 | HTTP状态码 | 说明 |
|--------|-----------|------|
| `UNAUTHORIZED` | 401 | 未登录或 Token 无效 |
| `TOKEN_EXPIRED` | 401 | Token 已过期 |
| `NO_FILES` | 400 | 未选择要上传的文件 |
| `TOO_MANY_FILES` | 400 | 批量上传超过 9 张限制 |
| `FILE_TOO_LARGE` | 400 | 单张图片超过 5MB 限制 |
| `INVALID_FILE_TYPE` | 400 | 不支持的文件格式 |
| `FILE_VALIDATION_FAILED` | 400 | 文件验证失败 |
| `UPLOAD_FAILED` | 400 | 上传失败 |
| `PARTIAL_UPLOAD_FAILED` | 400 | 部分上传失败 |

---

## 5. 环境变量配置

在 `.env` 文件中配置以下环境变量：

```bash
# OSS 配置
OSS_REGION=oss-cn-hangzhou
OSS_ACCESS_KEY_ID=your-access-key-id
OSS_ACCESS_KEY_SECRET=your-access-key-secret
OSS_BUCKET=shanjing-prod

# 可选：JWT 配置（已在 common 模块配置）
JWT_ACCESS_SECRET=your-jwt-secret
```

### OSS 权限配置

确保 OSS Bucket 的 RAM 用户具有以下权限：

```json
{
  "Version": "1",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "oss:PutObject",
        "oss:GetObject",
        "oss:DeleteObject"
      ],
      "Resource": [
        "acs:oss:*:*:your-bucket/images/*"
      ]
    }
  ]
}
```

---

## 6. 使用示例

### 6.1 cURL 示例

#### 单张图片上传

```bash
curl -X POST http://localhost:3000/upload/image \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -F "file=@/path/to/photo.jpg"
```

#### 批量图片上传

```bash
curl -X POST http://localhost:3000/upload/images \
  -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIs..." \
  -F "files=@/path/to/photo1.jpg" \
  -F "files=@/path/to/photo2.png" \
  -F "files=@/path/to/photo3.webp"
```

### 6.2 JavaScript/Fetch 示例

#### 单张图片上传

```javascript
const uploadImage = async (file, token) => {
  const formData = new FormData();
  formData.append('file', file);

  const response = await fetch('http://localhost:3000/upload/image', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
    body: formData,
  });

  return response.json();
};

// 使用示例
const fileInput = document.getElementById('file-input');
const file = fileInput.files[0];
const result = await uploadImage(file, 'your-jwt-token');
console.log(result.data.url); // 图片 URL
```

#### 批量图片上传

```javascript
const uploadMultipleImages = async (files, token) => {
  const formData = new FormData();
  files.forEach(file => {
    formData.append('files', file);
  });

  const response = await fetch('http://localhost:3000/upload/images', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${token}`,
    },
    body: formData,
  });

  return response.json();
};

// 使用示例
const fileInput = document.getElementById('file-input');
const files = Array.from(fileInput.files);
const result = await uploadMultipleImages(files, 'your-jwt-token');
result.data.urls.forEach(item => {
  console.log(item.url); // 每张图片的 URL
});
```

### 6.3 Flutter/Dart 示例

```dart
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

// 单张图片上传
Future<String?> uploadImage(File imageFile, String token) async {
  final uri = Uri.parse('https://api.shanjing.app/upload/image');
  final request = http.MultipartRequest('POST', uri);
  
  // 添加认证头
  request.headers['Authorization'] = 'Bearer $token';
  
  // 添加文件
  final fileStream = http.ByteStream(imageFile.openRead());
  final fileLength = await imageFile.length();
  final multipartFile = http.MultipartFile(
    'file',
    fileStream,
    fileLength,
    filename: path.basename(imageFile.path),
    contentType: MediaType('image', 'jpeg'),
  );
  request.files.add(multipartFile);
  
  // 发送请求
  final response = await request.send();
  final responseData = await response.stream.bytesToString();
  final jsonResponse = jsonDecode(responseData);
  
  if (jsonResponse['success']) {
    return jsonResponse['data']['url'];
  }
  return null;
}

// 批量图片上传
Future<List<String>> uploadMultipleImages(List<File> images, String token) async {
  final uri = Uri.parse('https://api.shanjing.app/upload/images');
  final request = http.MultipartRequest('POST', uri);
  
  request.headers['Authorization'] = 'Bearer $token';
  
  for (final image in images) {
    final fileStream = http.ByteStream(image.openRead());
    final fileLength = await image.length();
    final multipartFile = http.MultipartFile(
      'files',
      fileStream,
      fileLength,
      filename: path.basename(image.path),
    );
    request.files.add(multipartFile);
  }
  
  final response = await request.send();
  final responseData = await response.stream.bytesToString();
  final jsonResponse = jsonDecode(responseData);
  
  if (jsonResponse['success']) {
    return (jsonResponse['data']['urls'] as List)
        .map((item) => item['url'] as String)
        .toList();
  }
  return [];
}
```

---

## 7. 模块集成

### 7.1 在 AppModule 中注册

```typescript
import { Module } from '@nestjs/common';
import { UploadModule } from './upload/upload.module';

@Module({
  imports: [
    // ... 其他模块
    UploadModule,
  ],
})
export class AppModule {}
```

### 7.2 目录结构

```
backend/upload/
├── upload.module.ts           # 模块定义
├── upload.controller.ts       # 控制器（API接口）
├── upload.service.ts          # 服务（业务逻辑）
├── interfaces/
│   └── upload.interface.ts    # 类型定义
├── index.ts                   # 模块导出
└── README.md                  # 接口文档
```

---

## 8. 注意事项

1. **文件命名**：上传后的文件名会被重命名为 UUID，避免冲突
2. **存储路径**：文件按用户ID和日期分目录存储，便于管理
3. **缓存控制**：OSS 文件默认缓存 1 年
4. **开发环境**：未配置 OSS 时，上传会返回模拟 URL
5. **并发控制**：批量上传采用串行方式，避免 OSS 限流
