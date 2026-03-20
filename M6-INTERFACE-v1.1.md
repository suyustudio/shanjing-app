# M6 社交功能接口定义（修复验证后更新版）

> **文档版本**: v1.1  
> **制定日期**: 2026-03-20  
> **文档状态**: 已更新（与 M5 接口风格统一）  
> **对应阶段**: M6 - 社交功能阶段

---

## 更新摘要

本次更新解决了 M6 Review 发现的接口不一致问题：

1. ✅ **统一接口路径风格**: 统一使用 `/v1/` 前缀（与 M5 一致）
2. ✅ **统一响应格式**: 统一使用 `{success, data, meta}`（与 M5 一致）
3. ✅ **统一评分数据类型**: 统一使用 `integer 1-5`（不支持半星）
4. ✅ **统一字段命名**: `avatar`（统一），`rating`（integer）
5. ✅ **补充点赞功能接口**: 新增评论/照片点赞接口

---

## 目录

1. [概述](#1-概述)
2. [评论系统模块](#2-评论系统模块)
3. [照片系统模块](#3-照片系统模块)
4. [关注系统模块](#4-关注系统模块)
5. [收藏夹模块](#5-收藏夹模块)
6. [通用定义](#6-通用定义)

---

## 1. 概述

### 1.1 接口设计原则

- **RESTful 风格**: 资源导向，语义清晰
- **版本控制**: URL 中包含版本号 `/v1/`
- **统一响应**: 与 M5 保持一致的返回格式
- **错误处理**: 明确的错误码和消息

### 1.2 基础信息

| 项目 | 值 |
|------|-----|
| Base URL | `https://api.shanjing.app/v1` |
| 认证方式 | Bearer Token |
| 请求格式 | JSON |
| 响应格式 | JSON |
| 字符编码 | UTF-8 |

### 1.3 统一响应格式

```json
// 成功响应
{
  "success": true,
  "data": { /* 具体数据 */ },
  "meta": { /* 分页等元信息 */ }
}

// 错误响应
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": { /* 详细错误信息 */ }
  }
}
```

---

## 2. 评论系统模块

### 2.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/v1/trails/{trailId}/reviews` | 获取路线评价列表 | 可选 |
| POST | `/v1/trails/{trailId}/reviews` | 发表评价 | 是 |
| GET | `/v1/reviews/{reviewId}` | 获取评价详情 | 可选 |
| PUT | `/v1/reviews/{reviewId}` | 编辑评价 | 是 |
| DELETE | `/v1/reviews/{reviewId}` | 删除评价 | 是 |
| POST | `/v1/reviews/{reviewId}/like` | 点赞评价 | 是 |
| DELETE | `/v1/reviews/{reviewId}/like` | 取消点赞 | 是 |
| POST | `/v1/reviews/batch-check-like` | 批量检查点赞状态 | 是 |
| GET | `/v1/reviews/{reviewId}/replies` | 获取评价回复 | 可选 |
| POST | `/v1/reviews/{reviewId}/replies` | 回复评价 | 是 |
| DELETE | `/v1/replies/{replyId}` | 删除回复 | 是 |

### 2.2 获取路线评价列表

```yaml
GET /v1/trails/{trailId}/reviews

Description: 获取指定路线的用户评价列表

Path Parameters:
  trailId: string        # 路线ID

Query Parameters:
  sort: string           # 排序方式: newest|highest|lowest|most_liked (默认newest)
  filter: string         # 筛选: with_photo|verified|all (默认all)
  page: number           # 页码，从1开始 (默认1)
  limit: number          # 每页数量，默认20，最大50

Response 200:
  success: true
  data:
    summary:              # 评分统计
      average: number     # 平均分
      count: number       # 总评价数
      distribution:       # 评分分布
        "5": number
        "4": number
        "3": number
        "2": number
        "1": number
      tags:               # 标签统计
        - name: string
          count: number
    reviews:
      - id: string
        user:
          id: string
          nickname: string
          avatar: string  # 统一字段名
        rating: number           # 1-5，integer
        content: string          # 评价内容
        difficulty: string|null  # 难度再评估: easy|moderate|hard
        tags: string[]           # 标签
        photos:                  # 照片
          - id: string
            url: string
            thumbnail: string
        isVerified: boolean      # 是否体验过
        likeCount: number
        replyCount: number
        isLiked: boolean         # 当前用户是否点赞
        createdAt: string
  meta:
    page: number
    limit: number
    total: number
    totalPages: number
    hasNext: boolean
```

### 2.3 发表评价

```yaml
POST /v1/trails/{trailId}/reviews

Description: 为指定路线发表评价

Path Parameters:
  trailId: string        # 路线ID

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  rating: number         # 评分 1-5，integer (必填)
  content: string        # 评价内容，最多500字 (可选)
  difficulty: string     # 难度再评估: easy|moderate|hard (可选)
  tags: string[]         # 标签数组，最多5个 (可选)
  photoIds: string[]     # 已上传照片ID数组，最多9张 (可选)

Request Example:
  {
    "rating": 5,
    "content": "风景真的很棒！九溪的水特别清澈，春天去茶园特别美。",
    "difficulty": "easy",
    "tags": ["风景优美", "适合新手", "拍照圣地"],
    "photoIds": ["photo_001", "photo_002"]
  }

Response 201:
  success: true
  data:
    id: string
    user:
      id: string
      nickname: string
      avatar: string
    rating: number        # 1-5，integer
    content: string
    difficulty: string|null
    tags: string[]
    photos:
      - id: string
        url: string
        thumbnail: string
    isVerified: boolean
    likeCount: number
    replyCount: number
    createdAt: string

Response 400:
  success: false
  error:
    code: "INVALID_RATING"
    message: "评分必须在1-5之间"

Response 409:
  success: false
  error:
    code: "ALREADY_REVIEWED"
    message: "您已评价过该路线"
```

### 2.4 点赞/取消点赞评价

```yaml
POST /v1/reviews/{reviewId}/like
DELETE /v1/reviews/{reviewId}/like

Description: 点赞或取消点赞评价

Path Parameters:
  reviewId: string       # 评价ID

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    reviewId: string
    likeCount: number     # 更新后的点赞数
    isLiked: boolean      # true for POST, false for DELETE

Response 409 (重复点赞):
  success: false
  error:
    code: "ALREADY_LIKED"
    message: "您已点赞过该评价"
```

### 2.5 批量检查点赞状态

```yaml
POST /v1/reviews/batch-check-like

Description: 批量检查当前用户对多条评价的点赞状态（用于列表）

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  reviewIds: string[]    # 评价ID数组，最多100个

Response 200:
  success: true
  data:
    review_001: true     # 已点赞
    review_002: false    # 未点赞
    review_003: true
```

### 2.6 获取评价回复

```yaml
GET /v1/reviews/{reviewId}/replies

Description: 获取评价的回复列表

Path Parameters:
  reviewId: string       # 评价ID

Query Parameters:
  page: number           # 页码 (默认1)
  limit: number          # 每页数量 (默认20, 最大50)

Response 200:
  success: true
  data:
    - id: string
      user:
        id: string
        nickname: string
        avatar: string
      parentId: string|null     # 父回复ID（支持嵌套回复）
      replyTo:                  # 回复给的用户（如果是回复回复）
        id: string
        nickname: string
      content: string           # 最多200字
      likeCount: number
      isLiked: boolean
      createdAt: string
  meta:
    page: number
    limit: number
    total: number
```

### 2.7 回复评价

```yaml
POST /v1/reviews/{reviewId}/replies

Description: 回复评价或回复其他回复

Path Parameters:
  reviewId: string       # 评价ID

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  content: string        # 回复内容，最多200字 (必填)
  parentId: string       # 父回复ID（如果是回复回复）(可选)

Request Example:
  {
    "content": "请问周末人多吗？",
    "parentId": null
  }

Response 201:
  success: true
  data:
    id: string
    user:
      id: string
      nickname: string
      avatar: string
    parentId: string|null
    replyTo: object|null
    content: string
    likeCount: number
    createdAt: string
```

---

## 3. 照片系统模块

### 3.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/v1/photos/upload` | 获取上传凭证 | 是 |
| POST | `/v1/photos` | 创建照片记录 | 是 |
| GET | `/v1/photos` | 获取照片列表 | 可选 |
| GET | `/v1/photos/{photoId}` | 获取照片详情 | 可选 |
| DELETE | `/v1/photos/{photoId}` | 删除照片 | 是 |
| POST | `/v1/photos/{photoId}/like` | 点赞照片 | 是 |
| DELETE | `/v1/photos/{photoId}/like` | 取消点赞 | 是 |

### 3.2 获取上传凭证

```yaml
POST /v1/photos/upload

Description: 获取照片上传凭证（用于直传OSS）

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  count: number          # 上传数量 (1-9)
  fileType: string       # 文件类型: image/jpeg|image/png|image/heic

Response 200:
  success: true
  data:
    - uploadId: string    # 上传ID
      uploadUrl: string   # 直传URL（OSS直传地址）
      formData:           # 表单数据
        key: string       # OSS对象key
        policy: string
        signature: string
        OSSAccessKeyId: string
      previewUrl: string  # 上传后的访问URL（临时）
```

### 3.3 创建照片记录

```yaml
POST /v1/photos

Description: 照片上传完成后创建记录

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  uploadIds: string[]    # 上传ID数组
  trailId: string        # 关联路线ID (可选)
  location:              # 位置信息 (可选)
    lat: number
    lng: number
    name: string
  description: string    # 照片描述，最多200字 (可选)
  isPublic: boolean      # 是否公开 (默认true)

Response 201:
  success: true
  data:
    - id: string
      url: string
      thumbnail: string
      width: number
      height: number
      # ... 完整照片信息
```

### 3.4 照片点赞

```yaml
POST /v1/photos/{photoId}/like
DELETE /v1/photos/{photoId}/like

Description: 点赞或取消点赞照片

Path Parameters:
  photoId: string        # 照片ID

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    photoId: string
    likeCount: number
    isLiked: boolean
```

---

## 4. 关注系统模块

### 4.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/v1/users/{userId}/follow` | 关注用户 | 是 |
| DELETE | `/v1/users/{userId}/follow` | 取消关注 | 是 |
| GET | `/v1/users/{userId}/following` | 获取关注列表 | 可选 |
| GET | `/v1/users/{userId}/followers` | 获取粉丝列表 | 可选 |
| GET | `/v1/users/me/follow-recommendations` | 获取推荐关注 | 是 |

### 4.2 关注/取消关注

```yaml
POST /v1/users/{userId}/follow
DELETE /v1/users/{userId}/follow

Description: 关注或取消关注用户

Path Parameters:
  userId: string         # 用户ID

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    userId: string
    isFollowing: boolean   # true for POST, false for DELETE
    followingCount: number # 当前用户的关注数
    followerCount: number  # 目标用户的粉丝数
    isMutual: boolean      # 是否互相关注

Response 400:
  success: false
  error:
    code: "CANNOT_FOLLOW_SELF"
    message: "不能关注自己"
```

### 4.3 获取关注/粉丝列表

```yaml
GET /v1/users/{userId}/following
GET /v1/users/{userId}/followers

Description: 获取用户的关注列表或粉丝列表

Path Parameters:
  userId: string         # 用户ID，me 表示当前用户

Query Parameters:
  page: number           # 页码 (默认1)
  limit: number          # 每页数量 (默认20, 最大50)

Response 200:
  success: true
  data:
    - id: string
      nickname: string
      avatar: string      # 统一字段名
      bio: string          # 简介
      stats:
        followingCount: number
        followerCount: number
        photoCount: number
      isFollowing: boolean   # 当前用户是否关注
      isFollower: boolean    # 是否关注了当前用户（互相关注判断）
      isMutual: boolean      # 是否互相关注
  meta:
    page: number
    limit: number
    total: number
```

---

## 5. 收藏夹模块

### 5.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/v1/collections` | 获取收藏夹列表 | 是 |
| POST | `/v1/collections` | 创建收藏夹 | 是 |
| GET | `/v1/collections/{collectionId}` | 获取收藏夹详情 | 可选 |
| PUT | `/v1/collections/{collectionId}` | 更新收藏夹 | 是 |
| DELETE | `/v1/collections/{collectionId}` | 删除收藏夹 | 是 |
| POST | `/v1/collections/{collectionId}/trails` | 添加路线 | 是 |
| DELETE | `/v1/collections/{collectionId}/trails/{trailId}` | 移除路线 | 是 |
| POST | `/v1/trails/{trailId}/collect` | 快速收藏 | 是 |

### 5.2 快速收藏

```yaml
POST /v1/trails/{trailId}/collect

Description: 快速收藏路线到默认收藏夹

Path Parameters:
  trailId: string        # 路线ID

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    trailId: string
    collectionId: string   # 默认收藏夹ID
    isCollected: boolean   # true表示收藏成功，false表示取消收藏
```

---

## 6. 通用定义

### 6.1 错误码定义

| 错误码 | HTTP状态 | 说明 |
|--------|----------|------|
| SUCCESS | 200 | 成功 |
| UNAUTHORIZED | 401 | 未认证 |
| FORBIDDEN | 403 | 无权限 |
| NOT_FOUND | 404 | 资源不存在 |
| INVALID_PARAMS | 400 | 参数错误 |
| INVALID_RATING | 400 | 评分无效（必须在1-5之间）|
| CONTENT_TOO_LONG | 400 | 内容过长 |
| ALREADY_REVIEWED | 409 | 已评价过 |
| ALREADY_LIKED | 409 | 已点赞过 |
| REVIEW_NOT_FOUND | 404 | 评价不存在 |
| USER_NOT_FOUND | 404 | 用户不存在 |
| CANNOT_FOLLOW_SELF | 400 | 不能关注自己 |
| ALREADY_IN_COLLECTION | 409 | 已在收藏夹中 |
| COLLECTION_NOT_FOUND | 404 | 收藏夹不存在 |
| PRIVATE_COLLECTION | 403 | 私密收藏夹 |
| NAME_TOO_LONG | 400 | 名称过长 |
| NAME_EXISTS | 409 | 名称已存在 |
| SERVER_ERROR | 500 | 服务器错误 |

### 6.2 分页参数

```yaml
# 分页请求参数
page: number      # 页码，从1开始
limit: number     # 每页数量，默认20，最大50

# 分页响应元信息
meta:
  page: number        # 当前页
  limit: number       # 每页数量
  total: number       # 总数量
  totalPages: number  # 总页数
  hasNext: boolean    # 是否有下一页
  hasPrev: boolean    # 是否有上一页
```

### 6.3 时间格式

所有时间字段使用 ISO 8601 格式：

```
格式: YYYY-MM-DDTHH:mm:ssZ
示例: 2026-03-20T10:30:00Z
```

### 6.4 枚举值定义

```typescript
// 路线难度
enum Difficulty {
  EASY = 'easy',           // 简单
  MODERATE = 'moderate',   // 中等
  HARD = 'hard',           // 困难
}

// 评价排序
enum ReviewSort {
  NEWEST = 'newest',         // 最新
  HIGHEST = 'highest',       // 评分最高
  LOWEST = 'lowest',         // 评分最低
  MOST_LIKED = 'most_liked', // 最多点赞
}

// 评价筛选
enum ReviewFilter {
  ALL = 'all',               // 全部
  WITH_PHOTO = 'with_photo', // 有图
  VERIFIED = 'verified',     // 已验证
}

// 照片类型
enum PhotoType {
  RECOMMENDED = 'recommended',  // 推荐
  NEWEST = 'newest',            // 最新
  NEARBY = 'nearby',            // 附近
  FOLLOWING = 'following',      // 关注
}
```

---

## 附录：与 M5 接口风格对比

| 项目 | M5 风格 | M6 统一后 | 状态 |
|------|---------|-----------|------|
| 前缀 | `/v1/` | `/v1/` | ✅ 一致 |
| 响应格式 | `{success, data, meta}` | `{success, data, meta}` | ✅ 一致 |
| 错误格式 | `{success, error}` | `{success, error}` | ✅ 一致 |
| 认证方式 | Bearer Token | Bearer Token | ✅ 一致 |
| 字段命名 | avatar / nickname | avatar / nickname | ✅ 一致 |

---

## 版本更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-20 | 初始版本 |
| v1.1 | 2026-03-20 | 修复验证后更新：统一接口风格、补充点赞接口、统一评分数据类型 |

---

> **文档说明**: 本文档定义了 M6 阶段社交功能的所有接口规范，已与 M5 接口风格统一。
