# M6 社交功能接口定义

> **文档版本**: v1.0  
> **制定日期**: 2026-03-20  
> **文档状态**: 接口定义  
> **对应阶段**: M6 - 社交功能阶段

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
- **版本控制**: URL 中包含版本号 `/api/v1/`
- **统一响应**: 统一的返回格式
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
| GET | `/trails/{id}/reviews` | 获取路线评价列表 | 可选 |
| POST | `/trails/{id}/reviews` | 发表评价 | 是 |
| GET | `/reviews/{id}` | 获取评价详情 | 可选 |
| PUT | `/reviews/{id}` | 编辑评价 | 是 |
| DELETE | `/reviews/{id}` | 删除评价 | 是 |
| POST | `/reviews/{id}/like` | 点赞评价 | 是 |
| DELETE | `/reviews/{id}/like` | 取消点赞 | 是 |
| GET | `/reviews/{id}/replies` | 获取评价回复 | 可选 |
| POST | `/reviews/{id}/replies` | 回复评价 | 是 |
| DELETE | `/replies/{id}` | 删除回复 | 是 |

### 2.2 获取路线评价列表

```yaml
GET /api/v1/trails/{trailId}/reviews

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
          avatar: string
        rating: number           # 1-5
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

Response Example:
  {
    "success": true,
    "data": {
      "summary": {
        "average": 4.8,
        "count": 128,
        "distribution": {
          "5": 87,
          "4": 31,
          "3": 8,
          "2": 1,
          "1": 1
        },
        "tags": [
          { "name": "风景优美", "count": 56 },
          { "name": "适合新手", "count": 43 },
          { "name": "拍照圣地", "count": 38 }
        ]
      },
      "reviews": [
        {
          "id": "rev_001",
          "user": {
            "id": "user_123",
            "nickname": "山野行者",
            "avatar": "https://cdn.shanjing.app/avatars/user123.jpg"
          },
          "rating": 5,
          "content": "风景真的很棒！九溪的水特别清澈...",
          "difficulty": "easy",
          "tags": ["风景优美", "适合新手", "拍照圣地"],
          "photos": [
            {
              "id": "photo_001",
              "url": "https://cdn.shanjing.app/photos/001.jpg",
              "thumbnail": "https://cdn.shanjing.app/photos/001_thumb.jpg"
            }
          ],
          "isVerified": true,
          "likeCount": 23,
          "replyCount": 5,
          "isLiked": false,
          "createdAt": "2026-03-18T10:30:00Z"
        }
      ]
    },
    "meta": {
      "page": 1,
      "limit": 20,
      "total": 128,
      "totalPages": 7,
      "hasNext": true
    }
  }
```

### 2.3 发表评价

```yaml
POST /api/v1/trails/{trailId}/reviews

Description: 为指定路线发表评价

Path Parameters:
  trailId: string        # 路线ID

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  rating: number         # 评分 1-5 (必填)
  content: string        # 评价内容，最多500字 (必填)
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
    rating: number
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

Response 400:
  success: false
  error:
    code: "CONTENT_TOO_LONG"
    message: "评价内容不能超过500字"

Response 409:
  success: false
  error:
    code: "ALREADY_REVIEWED"
    message: "您已评价过该路线"
```

### 2.4 编辑评价

```yaml
PUT /api/v1/reviews/{reviewId}

Description: 编辑自己的评价

Path Parameters:
  reviewId: string       # 评价ID

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  content: string        # 新的评价内容
  difficulty: string     # 难度再评估
  tags: string[]         # 新的标签
  photoIds: string[]     # 新的照片列表

Response 200:
  success: true
  data:
    id: string
    # ... 完整评价信息
    updatedAt: string

Response 403:
  success: false
  error:
    code: "FORBIDDEN"
    message: "只能编辑自己的评价"

Response 404:
  success: false
  error:
    code: "REVIEW_NOT_FOUND"
    message: "评价不存在"
```

### 2.5 删除评价

```yaml
DELETE /api/v1/reviews/{reviewId}

Description: 删除自己的评价

Path Parameters:
  reviewId: string       # 评价ID

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    deleted: true

Response 403:
  success: false
  error:
    code: "FORBIDDEN"
    message: "只能删除自己的评价"
```

### 2.6 点赞/取消点赞评价

```yaml
POST /api/v1/reviews/{reviewId}/like
DELETE /api/v1/reviews/{reviewId}/like

Description: 点赞或取消点赞评价

Path Parameters:
  reviewId: string       # 评价ID

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    reviewId: string
    likeCount: number
    isLiked: boolean      # true for POST, false for DELETE
```

### 2.7 获取评价回复

```yaml
GET /api/v1/reviews/{reviewId}/replies

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
      content: string
      likeCount: number
      isLiked: boolean
      createdAt: string
  meta:
    page: number
    limit: number
    total: number
```

### 2.8 回复评价

```yaml
POST /api/v1/reviews/{reviewId}/replies

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

### 2.9 客户端服务接口

```dart
// ============================================================
// ReviewService
// ============================================================

abstract class ReviewService {
  /// 获取路线评价列表
  Future<PagedResult<Review>> getTrailReviews({
    required String trailId,
    ReviewSort sort = ReviewSort.newest,
    ReviewFilter filter = ReviewFilter.all,
    int page = 1,
    int limit = 20,
  });
  
  /// 发表评价
  Future<Review> createReview({
    required String trailId,
    required int rating,
    required String content,
    Difficulty? difficulty,
    List<String>? tags,
    List<String>? photoIds,
  });
  
  /// 编辑评价
  Future<Review> updateReview({
    required String reviewId,
    String? content,
    Difficulty? difficulty,
    List<String>? tags,
    List<String>? photoIds,
  });
  
  /// 删除评价
  Future<void> deleteReview(String reviewId);
  
  /// 点赞/取消点赞
  Future<void> toggleLike(String reviewId, bool isLiked);
  
  /// 获取评价回复
  Future<PagedResult<ReviewReply>> getReplies({
    required String reviewId,
    int page = 1,
    int limit = 20,
  });
  
  /// 回复评价
  Future<ReviewReply> replyToReview({
    required String reviewId,
    required String content,
    String? parentId,
  });
  
  /// 删除回复
  Future<void> deleteReply(String replyId);
}

enum ReviewSort {
  newest,      // 最新
  highest,     // 评分最高
  lowest,      // 评分最低
  mostLiked,   // 最多点赞
}

enum ReviewFilter {
  all,         // 全部
  withPhoto,   // 有图
  verified,    // 已验证
}

class Review {
  final String id;
  final UserBrief user;
  final int rating;
  final String content;
  final Difficulty? difficulty;
  final List<String> tags;
  final List<ReviewPhoto> photos;
  final bool isVerified;
  final int likeCount;
  final int replyCount;
  final bool isLiked;
  final DateTime createdAt;
}

class ReviewSummary {
  final double average;
  final int count;
  final Map<String, int> distribution;
  final List<TagCount> tags;
}

class ReviewReply {
  final String id;
  final UserBrief user;
  final String? parentId;
  final UserBrief? replyTo;
  final String content;
  final int likeCount;
  final bool isLiked;
  final DateTime createdAt;
}
```

---

## 3. 照片系统模块

### 3.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/photos/upload` | 获取上传凭证 | 是 |
| POST | `/photos` | 创建照片记录 | 是 |
| GET | `/photos` | 获取照片列表 | 可选 |
| GET | `/photos/{id}` | 获取照片详情 | 可选 |
| DELETE | `/photos/{id}` | 删除照片 | 是 |
| POST | `/photos/{id}/like` | 点赞照片 | 是 |
| DELETE | `/photos/{id}/like` | 取消点赞 | 是 |
| GET | `/photos/{id}/comments` | 获取照片评论 | 可选 |
| POST | `/photos/{id}/comments` | 评论照片 | 是 |

### 3.2 获取上传凭证

```yaml
POST /api/v1/photos/upload

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

Response Example:
  {
    "success": true,
    "data": [
      {
        "uploadId": "upload_001",
        "uploadUrl": "https://shanjing-oss.oss-cn-hangzhou.aliyuncs.com",
        "formData": {
          "key": "photos/2026/03/20/photo_001.jpg",
          "policy": "eyJleHBpcmF0aW9uIj...",
          "signature": "xxxxxxxx",
          "OSSAccessKeyId": "LTAIxxxxx"
        },
        "previewUrl": "https://cdn.shanjing.app/photos/2026/03/20/photo_001.jpg"
      }
    ]
  }
```

### 3.3 创建照片记录

```yaml
POST /api/v1/photos

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
  description: string    # 照片描述 (可选)
  isPublic: boolean      # 是否公开 (默认true)

Request Example:
  {
    "uploadIds": ["upload_001", "upload_002"],
    "trailId": "trail_001",
    "location": {
      "lat": 30.2084,
      "lng": 120.1180,
      "name": "九溪烟树"
    },
    "description": "春天的九溪真的太美了！",
    "isPublic": true
  }

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

### 3.4 获取照片列表

```yaml
GET /api/v1/photos

Description: 获取照片瀑布流列表

Query Parameters:
  type: string           # 类型: recommended|newest|nearby|following (默认recommended)
  lat: number            # 纬度（nearby时必填）
  lng: number            # 经度（nearby时必填）
  trailId: string        # 指定路线的照片
  userId: string         # 指定用户的照片
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
      trail:               # 关联路线信息
        id: string
        name: string
      location:            # 位置信息
        lat: number
        lng: number
        name: string
      url: string
      thumbnail: string
      width: number
      height: number
      description: string
      likeCount: number
      commentCount: number
      isLiked: boolean
      isPublic: boolean
      createdAt: string
  meta:
    page: number
    limit: number
    total: number
    hasNext: boolean
```

### 3.5 获取照片详情

```yaml
GET /api/v1/photos/{photoId}

Description: 获取照片详情

Path Parameters:
  photoId: string        # 照片ID

Response 200:
  success: true
  data:
    id: string
    user:
      id: string
      nickname: string
      avatar: string
    trail: object|null
    location: object|null
    url: string
    thumbnail: string
    width: number
    height: number
    description: string
    likeCount: number
    commentCount: number
    isLiked: boolean
    isPublic: boolean
    createdAt: string
    relatedPhotos:         # 相关照片（同路线或同用户）
      - id: string
        thumbnail: string
```

### 3.6 客户端服务接口

```dart
// ============================================================
// PhotoService
// ============================================================

abstract class PhotoService {
  /// 获取上传凭证
  Future<List<UploadCredentials>> getUploadCredentials({
    required int count,
    String fileType = 'image/jpeg',
  });
  
  /// 上传照片到OSS（客户端直传）
  Future<List<String>> uploadPhotos({
    required List<File> files,
    required List<UploadCredentials> credentials,
    ProgressCallback? onProgress,
  });
  
  /// 创建照片记录
  Future<List<Photo>> createPhotoRecords({
    required List<String> uploadIds,
    String? trailId,
    Location? location,
    String? description,
    bool isPublic = true,
  });
  
  /// 获取照片列表（瀑布流）
  Future<PagedResult<Photo>> getPhotos({
    PhotoType type = PhotoType.recommended,
    double? lat,
    double? lng,
    String? trailId,
    String? userId,
    int page = 1,
    int limit = 20,
  });
  
  /// 获取照片详情
  Future<Photo> getPhotoDetail(String photoId);
  
  /// 删除照片
  Future<void> deletePhoto(String photoId);
  
  /// 点赞/取消点赞
  Future<void> toggleLike(String photoId, bool isLiked);
  
  /// 获取照片评论
  Future<PagedResult<PhotoComment>> getComments({
    required String photoId,
    int page = 1,
    int limit = 20,
  });
  
  /// 评论照片
  Future<PhotoComment> addComment({
    required String photoId,
    required String content,
  });
}

enum PhotoType {
  recommended,  // 推荐
  newest,       // 最新
  nearby,       // 附近
  following,    // 关注
}

class UploadCredentials {
  final String uploadId;
  final String uploadUrl;
  final Map<String, String> formData;
  final String previewUrl;
}

class Photo {
  final String id;
  final UserBrief user;
  final TrailBrief? trail;
  final Location? location;
  final String url;
  final String thumbnail;
  final int width;
  final int height;
  final String? description;
  final int likeCount;
  final int commentCount;
  final bool isLiked;
  final bool isPublic;
  final DateTime createdAt;
  final List<PhotoBrief>? relatedPhotos;
}
```

---

## 4. 关注系统模块

### 4.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/users/{id}/follow` | 关注用户 | 是 |
| DELETE | `/users/{id}/follow` | 取消关注 | 是 |
| GET | `/users/{id}/following` | 获取关注列表 | 可选 |
| GET | `/users/{id}/followers` | 获取粉丝列表 | 可选 |
| GET | `/users/{id}` | 获取用户详情 | 可选 |
| GET | `/users/me/follow-recommendations` | 获取推荐关注 | 是 |
| GET | `/users/search` | 搜索用户 | 是 |

### 4.2 关注/取消关注

```yaml
POST /api/v1/users/{userId}/follow
DELETE /api/v1/users/{userId}/follow

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

Response 404:
  success: false
  error:
    code: "USER_NOT_FOUND"
    message: "用户不存在"
```

### 4.3 获取关注/粉丝列表

```yaml
GET /api/v1/users/{userId}/following
GET /api/v1/users/{userId}/followers

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
      avatar: string
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

### 4.4 获取用户详情

```yaml
GET /api/v1/users/{userId}

Description: 获取用户详情

Path Parameters:
  userId: string         # 用户ID，me 表示当前用户

Response 200:
  success: true
  data:
    id: string
    nickname: string
    avatar: string
    bio: string
    location: string       # 所在地
    stats:
      followingCount: number
      followerCount: number
      photoCount: number
      reviewCount: number
      likeReceived: number
    isFollowing: boolean   # 当前用户是否关注该用户
    isFollower: boolean
    isMutual: boolean
    createdAt: string      # 注册时间

Response 404:
  success: false
  error:
    code: "USER_NOT_FOUND"
    message: "用户不存在"
```

### 4.5 获取推荐关注

```yaml
GET /api/v1/users/me/follow-recommendations

Description: 获取推荐关注列表

Request Headers:
  Authorization: Bearer {token}

Query Parameters:
  type: string           # 推荐类型: popular|contacts|interest (默认mixed)
  limit: number          # 返回数量 (默认10, 最大20)

Response 200:
  success: true
  data:
    sections:            # 分组推荐
      - title: string    # 分组标题
        type: string     # 分组类型
        users:
          - id: string
            nickname: string
            avatar: string
            bio: string
            stats:
              followerCount: number
              photoCount: number
            reason: string   # 推荐理由
```

### 4.6 搜索用户

```yaml
GET /api/v1/users/search

Description: 搜索用户

Request Headers:
  Authorization: Bearer {token}

Query Parameters:
  q: string              # 搜索关键词（昵称或用户名）
  page: number           # 页码 (默认1)
  limit: number          # 每页数量 (默认20)

Response 200:
  success: true
  data:
    - id: string
      nickname: string
      avatar: string
      bio: string
      isFollowing: boolean
  meta:
    page: number
    limit: number
    total: number
```

### 4.7 客户端服务接口

```dart
// ============================================================
// FollowService
// ============================================================

abstract class FollowService {
  /// 关注用户
  Future<FollowResult> followUser(String userId);
  
  /// 取消关注
  Future<FollowResult> unfollowUser(String userId);
  
  /// 获取关注列表
  Future<PagedResult<UserFollow>> getFollowing({
    String userId = 'me',
    int page = 1,
    int limit = 20,
  });
  
  /// 获取粉丝列表
  Future<PagedResult<UserFollow>> getFollowers({
    String userId = 'me',
    int page = 1,
    int limit = 20,
  });
  
  /// 获取用户详情
  Future<UserProfile> getUserProfile(String userId);
  
  /// 获取推荐关注
  Future<List<FollowRecommendation>> getRecommendations({
    RecommendationType type = RecommendationType.mixed,
    int limit = 10,
  });
  
  /// 搜索用户
  Future<PagedResult<UserSearchResult>> searchUsers({
    required String query,
    int page = 1,
    int limit = 20,
  });
  
  /// 检查关注状态
  Future<Map<String, bool>> checkFollowStatus(List<String> userIds);
}

class FollowResult {
  final String userId;
  final bool isFollowing;
  final int followingCount;
  final int followerCount;
  final bool isMutual;
}

class UserFollow {
  final String id;
  final String nickname;
  final String avatar;
  final String? bio;
  final UserStats stats;
  final bool isFollowing;
  final bool isFollower;
  final bool isMutual;
}

class UserProfile {
  final String id;
  final String nickname;
  final String avatar;
  final String? bio;
  final String? location;
  final UserStats stats;
  final bool isFollowing;
  final bool isFollower;
  final bool isMutual;
  final DateTime createdAt;
}

class UserStats {
  final int followingCount;
  final int followerCount;
  final int photoCount;
  final int reviewCount;
  final int likeReceived;
}

class FollowRecommendation {
  final String title;
  final String type;
  final List<UserBrief> users;
}
```

---

## 5. 收藏夹模块

### 5.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/collections` | 获取收藏夹列表 | 是 |
| POST | `/collections` | 创建收藏夹 | 是 |
| GET | `/collections/{id}` | 获取收藏夹详情 | 可选 |
| PUT | `/collections/{id}` | 更新收藏夹 | 是 |
| DELETE | `/collections/{id}` | 删除收藏夹 | 是 |
| POST | `/collections/{id}/trails` | 添加路线 | 是 |
| DELETE | `/collections/{id}/trails/{trailId}` | 移除路线 | 是 |
| PUT | `/collections/{id}/sort` | 排序路线 | 是 |
| POST | `/trails/{id}/collect` | 快速收藏（添加到默认收藏夹） | 是 |

### 5.2 获取收藏夹列表

```yaml
GET /api/v1/collections

Description: 获取用户的收藏夹列表

Request Headers:
  Authorization: Bearer {token}

Query Parameters:
  userId: string         # 用户ID（查看他人收藏夹时）

Response 200:
  success: true
  data:
    - id: string
      name: string
      description: string
      coverUrl: string
      trailCount: number
      isPublic: boolean
      isDefault: boolean     # 是否默认收藏夹
      sortOrder: number
      createdAt: string
      updatedAt: string

Response Example:
  {
    "success": true,
    "data": [
      {
        "id": "col_001",
        "name": "想去",
        "description": "",
        "coverUrl": "https://cdn.shanjing.app/covers/default.jpg",
        "trailCount": 12,
        "isPublic": false,
        "isDefault": true,
        "sortOrder": 0,
        "createdAt": "2026-01-15T10:00:00Z",
        "updatedAt": "2026-03-18T14:30:00Z"
      },
      {
        "id": "col_002",
        "name": "杭州周边必去",
        "description": "精选杭州周边最值得去的徒步路线",
        "coverUrl": "https://cdn.shanjing.app/covers/col002.jpg",
        "trailCount": 8,
        "isPublic": true,
        "isDefault": false,
        "sortOrder": 1,
        "createdAt": "2026-02-20T08:00:00Z",
        "updatedAt": "2026-03-15T16:45:00Z"
      }
    ]
  }
```

### 5.3 创建收藏夹

```yaml
POST /api/v1/collections

Description: 创建新的收藏夹

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  name: string           # 收藏夹名称，最多20字 (必填)
  description: string    # 描述，最多200字 (可选)
  isPublic: boolean      # 是否公开 (默认true)

Request Example:
  {
    "name": "亲子友好路线",
    "description": "适合带孩子一起去的轻松路线",
    "isPublic": true
  }

Response 201:
  success: true
  data:
    id: string
    name: string
    description: string
    coverUrl: string|null
    trailCount: number
    isPublic: boolean
    isDefault: false
    sortOrder: number
    createdAt: string

Response 400:
  success: false
  error:
    code: "NAME_TOO_LONG"
    message: "收藏夹名称不能超过20字"

Response 409:
  success: false
  error:
    code: "NAME_EXISTS"
    message: "收藏夹名称已存在"
```

### 5.4 获取收藏夹详情

```yaml
GET /api/v1/collections/{collectionId}

Description: 获取收藏夹详情及路线列表

Path Parameters:
  collectionId: string   # 收藏夹ID

Query Parameters:
  page: number           # 页码 (默认1)
  limit: number          # 每页数量 (默认20)

Response 200:
  success: true
  data:
    id: string
    name: string
    description: string
    coverUrl: string
    user:
      id: string
      nickname: string
      avatar: string
    trailCount: number
    isPublic: boolean
    isOwner: boolean       # 当前用户是否是创建者
    createdAt: string
    updatedAt: string
    trails:
      - id: string
        name: string
        coverImage: string
        distanceKm: number
        durationMin: number
        difficulty: string
        rating: number
        reviewCount: number
        note: string       # 收藏备注
        addedAt: string
        sortOrder: number
  meta:
    page: number
    limit: number
    total: number

Response 403:
  success: false
  error:
    code: "PRIVATE_COLLECTION"
    message: "该收藏夹为私密"

Response 404:
  success: false
  error:
    code: "COLLECTION_NOT_FOUND"
    message: "收藏夹不存在"
```

### 5.5 添加/移除路线

```yaml
POST /api/v1/collections/{collectionId}/trails
DELETE /api/v1/collections/{collectionId}/trails/{trailId}

Description: 添加路线到收藏夹或从收藏夹移除

Path Parameters:
  collectionId: string   # 收藏夹ID
  trailId: string        # 路线ID（DELETE时）

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body (POST):
  trailId: string        # 路线ID (必填)
  note: string           # 收藏备注 (可选)

Response 200:
  success: true
  data:
    collectionId: string
    trailId: string
    action: string        # added|removed
    trailCount: number    # 收藏夹当前路线数

Response 409:
  success: false
  error:
    code: "ALREADY_IN_COLLECTION"
    message: "该路线已在收藏夹中"
```

### 5.6 快速收藏

```yaml
POST /api/v1/trails/{trailId}/collect

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

Response 401:
  success: false
  error:
    code: "UNAUTHORIZED"
    message: "请先登录"
```

### 5.7 客户端服务接口

```dart
// ============================================================
// CollectionService
// ============================================================

abstract class CollectionService {
  /// 获取收藏夹列表
  Future<List<Collection>> getCollections({String? userId});
  
  /// 创建收藏夹
  Future<Collection> createCollection({
    required String name,
    String? description,
    bool isPublic = true,
  });
  
  /// 更新收藏夹
  Future<Collection> updateCollection({
    required String collectionId,
    String? name,
    String? description,
    bool? isPublic,
  });
  
  /// 删除收藏夹
  Future<void> deleteCollection(String collectionId);
  
  /// 获取收藏夹详情
  Future<CollectionDetail> getCollectionDetail({
    required String collectionId,
    int page = 1,
    int limit = 20,
  });
  
  /// 添加路线到收藏夹
  Future<void> addTrailToCollection({
    required String collectionId,
    required String trailId,
    String? note,
  });
  
  /// 从收藏夹移除路线
  Future<void> removeTrailFromCollection({
    required String collectionId,
    required String trailId,
  });
  
  /// 快速收藏（添加到默认收藏夹）
  Future<QuickCollectResult> quickCollect(String trailId);
  
  /// 检查路线是否已收藏
  Future<bool> isTrailCollected(String trailId);
  
  /// 获取路线的收藏夹归属
  Future<List<String>> getTrailCollections(String trailId);
  
  /// 批量添加路线到收藏夹
  Future<void> batchAddTrails({
    required String collectionId,
    required List<String> trailIds,
  });
}

class Collection {
  final String id;
  final String name;
  final String? description;
  final String? coverUrl;
  final int trailCount;
  final bool isPublic;
  final bool isDefault;
  final int sortOrder;
  final DateTime createdAt;
  final DateTime updatedAt;
}

class CollectionDetail extends Collection {
  final UserBrief user;
  final bool isOwner;
  final List<CollectionTrail> trails;
  final PagingMeta meta;
}

class CollectionTrail {
  final String id;
  final String name;
  final String coverImage;
  final double distanceKm;
  final int durationMin;
  final Difficulty difficulty;
  final double rating;
  final int reviewCount;
  final String? note;
  final DateTime addedAt;
  final int sortOrder;
}

class QuickCollectResult {
  final String trailId;
  final String collectionId;
  final bool isCollected;
}
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
| INVALID_RATING | 400 | 评分无效 |
| CONTENT_TOO_LONG | 400 | 内容过长 |
| ALREADY_REVIEWED | 409 | 已评价过 |
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
limit: number     # 每页数量，默认20，最大100

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
  ALL = 'all',           // 全部
  WITH_PHOTO = 'with_photo', // 有图
  VERIFIED = 'verified', // 已验证
}

// 照片类型
enum PhotoType {
  RECOMMENDED = 'recommended',  // 推荐
  NEWEST = 'newest',            // 最新
  NEARBY = 'nearby',            // 附近
  FOLLOWING = 'following',      // 关注
}

// 推荐类型
enum RecommendationType {
  POPULAR = 'popular',      // 热门
  CONTACTS = 'contacts',    // 通讯录
  INTEREST = 'interest',    // 兴趣
  MIXED = 'mixed',          // 混合
}
```

---

> **文档说明**: 本文档定义了 M6 阶段社交功能的所有接口规范，包括评论系统、照片系统、关注系统和收藏夹模块。
