# M6 修复报告 - 评论点赞功能 + 接口统一

> **文档版本**: v1.0  
> **修复日期**: 2026-03-20  
> **关联文档**: M6-PRODUCT-DEV-REVIEW.md, M6-DESIGN-FIX-v1.0.md

---

## 1. 修复概述

本次修复解决了 M6 Review 中发现的以下关键问题：

| 问题ID | 问题描述 | 修复状态 | 优先级 |
|--------|----------|----------|--------|
| P0-001 | 接口路径风格与 M5 不统一 | ✅ 已修复 | P0 |
| P0-002 | 已实现的评论 API 与接口定义不一致 | ✅ 已修复 | P0 |
| P0-003 | 评分数据类型不一致 (int vs float) | ✅ 已修复 | P0 |
| P0-004 | 响应格式 success 字段类型不一致 | ✅ 已修复 | P0 |
| P0-005 | 评论点赞功能缺失 | ✅ 已实现 | P0 |
| P1-XXX | 字段命名统一 (avatarUrl) | ✅ 已修复 | P1 |

---

## 2. 后端修复详情

### 2.1 数据库 Schema 更新

**新增 `review_likes` 表** (`prisma/schema.prisma`):

```prisma
model ReviewLike {
  id            String    @id @default(uuid())
  reviewId      String    @map("review_id")
  userId        String    @map("user_id")
  createdAt     DateTime  @default(now()) @map("created_at")

  review        Review    @relation(fields: [reviewId], references: [id], onDelete: Cascade)
  user          User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([reviewId, userId])
  @@index([reviewId])
  @@index([userId])
  @@map("review_likes")
}
```

**Review 表关联更新**:
```prisma
model Review {
  // ... 其他字段
  likes         ReviewLike[]
  
  @@index([trailId, likeCount, createdAt])  // 热门评论排序
}
```

**用户表关联更新**:
```prisma
model User {
  // ... 其他字段
  reviewLikes   ReviewLike[]
}
```

### 2.2 接口路径统一

| 功能 | 旧路径 | 新路径 | 说明 |
|------|--------|--------|------|
| 发表评论 | `/reviews/trails/:trailId` | `POST /v1/trails/:trailId/reviews` | 与 M5 风格一致 |
| 获取评论列表 | `/reviews/trails/:trailId` | `GET /v1/trails/:trailId/reviews` | 嵌套资源路径 |
| 评论详情 | `/reviews/:id` | `GET /v1/reviews/:id` | 独立资源风格 |
| 编辑评论 | - | `PUT /v1/reviews/:id` | 新增 |
| 删除评论 | - | `DELETE /v1/reviews/:id` | 新增 |
| **点赞** | ❌ 未实现 | `POST /v1/reviews/:id/like` | Toggle 接口 |
| **点赞状态** | ❌ 未实现 | `GET /v1/reviews/:id/like` | 检查状态 |
| **回复** | ❌ 未实现 | `POST /v1/reviews/:id/replies` | 嵌套回复 |
| **回复列表** | ❌ 未实现 | `GET /v1/reviews/:id/replies` | 获取回复 |

### 2.3 统一响应格式

**修复前** (不一致):
```json
// M5 风格
{ "success": true, "data": { ... } }

// M6 旧风格
{ "code": 0, "message": "success", "data": { ... } }
```

**修复后** (统一):
```typescript
// 统一响应格式
interface ApiResponseDto<T> {
  success: boolean;
  data: T;
  message?: string;
  meta?: {
    total?: number;
    page?: number;
    limit?: number;
    hasMore?: boolean;
  };
}
```

### 2.4 评分类型统一

**修复前**: `rating: Float` (支持 1.0-5.0，半星)

**修复后**: `rating: Int` @db.SmallInt (1-5，整星)

```prisma
model Review {
  rating        Int       @db.SmallInt  // 1-5 整数评分
}
```

**原因**:
1. PRD 原型图显示整星评分
2. 多数竞品（AllTrails、两步路）使用整星
3. 简化前端展示和数据处理
4. 与 M6-TEST-CASES.md 的边界测试用例一致

### 2.5 字段命名统一

| 字段 | 修复前 | 修复后 |
|------|--------|--------|
| 用户头像 | `avatar` | `avatarUrl` |
| 评论配图 | `photoIds` | `photos` (URL数组) |

### 2.6 点赞功能实现

**API 端点**:
```typescript
// POST /v1/reviews/:id/like
// 点赞/取消点赞 (Toggle)
async likeReview(
  userId: string, 
  reviewId: string
): Promise<LikeReviewResponseDto>

// GET /v1/reviews/:id/like  
// 检查当前用户是否已点赞
async checkUserLikedReview(
  userId: string, 
  reviewId: string
): Promise<boolean>
```

**响应格式**:
```typescript
interface LikeReviewResponseDto {
  isLiked: boolean;    // 当前是否已点赞
  likeCount: number;   // 最新点赞数
}
```

**实现逻辑**:
1. 检查是否已存在点赞记录
2. 存在则删除 (取消点赞)
3. 不存在则创建 (点赞)
4. 原子操作更新评论的 likeCount
5. 返回最新状态

### 2.7 评论回复功能

**数据库模型** (`ReviewReply`):
```prisma
model ReviewReply {
  id            String    @id @default(uuid())
  reviewId      String    @map("review_id")
  userId        String    @map("user_id")
  parentId      String?   @map("parent_id")  // 嵌套回复
  content       String    @db.VarChar(500)
  createdAt     DateTime  @default(now()) @map("created_at")

  review        Review    @relation(fields: [reviewId], references: [id])
  user          User      @relation(fields: [userId], references: [id])
  parent        ReviewReply? @relation("ReplyParent", fields: [parentId], references: [id])
  children      ReviewReply[] @relation("ReplyParent")

  @@index([reviewId, createdAt])
  @@map("review_replies")
}
```

**API 端点**:
```typescript
// POST /v1/reviews/:id/replies
async createReply(
  userId: string,
  reviewId: string,
  dto: CreateReplyDto
): Promise<ReviewReplyDto>

// GET /v1/reviews/:id/replies
async getReplies(reviewId: string): Promise<ReviewReplyDto[]>
```

---

## 3. 前端修复详情 (Flutter)

### 3.1 新增文件列表

```
lib/
├── models/
│   └── review_model.dart          # 评论数据模型
├── services/
│   ├── api_client.dart            # 添加 PUT 方法
│   └── review_service.dart        # 评论服务 API
└── widgets/review/
    ├── index.dart                 # 统一导出
    ├── like_button.dart           # 点赞按钮 (带动画)
    ├── review_item.dart           # 单条评论
    ├── review_list.dart           # 评论列表
    ├── review_tags.dart           # 标签展示
    ├── review_photo_grid.dart     # 图片网格
    ├── review_reply_list.dart     # 回复列表
    ├── review_skeleton.dart       # 骨架屏
    ├── review_empty.dart          # 空状态
    └── review_input.dart          # 输入框
```

### 3.2 数据模型 (`review_model.dart`)

```dart
// 评论模型
class Review {
  final String id;
  final int rating;              // 1-5 整数
  final String? content;
  final List<String> tags;
  final List<String> photos;     // URL数组
  final int likeCount;
  final int replyCount;
  final bool isLiked;            // 当前用户是否已点赞
  final bool isVerified;         // "体验过"标识
  final ReviewUser user;
  final List<ReviewReply>? replies;
  
  Review copyWith({...})         // 点赞状态更新
}

// 评论用户模型
class ReviewUser {
  final String id;
  final String? nickname;
  final String? avatarUrl;       // 统一字段名
}

// 点赞响应模型
class LikeReviewResponse {
  final bool isLiked;
  final int likeCount;
}
```

### 3.3 点赞按钮组件 (`like_button.dart`)

**动画效果** (参考 M6-DESIGN-FIX-v1.0.md):

```
时序:
0ms     → 点击触发
0-50ms  → scale(1.0) → scale(0.85)  按下收缩
50-150ms → scale(0.85) → scale(1.3)  弹性放大  
150-300ms → scale(1.3) → scale(1.0) 回弹到位

同时: 粒子效果从中心向外扩散
```

**粒子效果**:
- 粒子数量: 8-12个
- 粒子形状: 小圆点
- 粒子颜色: #2D968A (品牌色)
- 扩散半径: 30px
- 扩散时长: 400ms

**点赞数展示规则**:
| 数量范围 | 显示格式 | 示例 |
|----------|----------|------|
| 0 | 不显示数字 | 👍 |
| 1-999 | 完整数字 | 👍 128 |
| 1000-9999 | 1.2k | 👍 1.2k |
| 10000+ | 1w+ | 👍 1w+ |

### 3.4 API 服务 (`review_service.dart`)

**统一接口封装**:
```dart
class ReviewService {
  // 评论 CRUD
  Future<Review> createReview(String trailId, CreateReviewRequest request);
  Future<ReviewListResponse> getReviews(String trailId, {...});
  Future<Review> getReviewDetail(String reviewId);
  Future<Review> updateReview(String reviewId, UpdateReviewRequest request);
  Future<void> deleteReview(String reviewId);
  
  // 点赞功能
  Future<LikeReviewResponse> likeReview(String reviewId);
  Future<bool> checkLikeStatus(String reviewId);
  
  // 回复功能
  Future<ReviewReply> createReply(String reviewId, CreateReplyRequest request);
  Future<List<ReviewReply>> getReplies(String reviewId);
}
```

### 3.5 评论列表组件 (`review_list.dart`)

**功能特性**:
- 下拉刷新 (RefreshIndicator)
- 无限滚动加载
- 评分统计展示
- 图片查看器 (全屏 + 缩放)
- 点赞状态同步

**评分统计展示**:
```
┌──────────────────────────────────┐
│  4.8    ★★★★★    5星 ████████ 60% │
│  128条  ★★★★☆    4星 ████     25% │
│  评价   ★★★☆☆    3星 ██       10% │
│         ★★☆☆☆    2星 █         3% │
│         ★☆☆☆☆    1星 █         2% │
└──────────────────────────────────┘
```

### 3.6 回复列表组件 (`review_reply_list.dart`)

**嵌套层级限制**:
| 层级 | 显示方式 | 最大数量 |
|------|----------|----------|
| 主评论 | 完整显示 | - |
| 一级回复 | 默认显示前2条 | 无限制 |
| 二级回复 | 折叠在"查看全部"中 | 嵌套最多2层 |

**样式规范**:
- 回复区域背景: #F9FAFB
- 左边距: 52px (与主评论内容对齐)
- 回复项头像: 28px
- 回复者名: #6B7280 (灰色)
- 被回复者: #2D968A (品牌色 + @)

---

## 4. 工时统计

| 任务 | 预估工时 | 实际工时 | 备注 |
|------|----------|----------|------|
| 数据库 Schema 更新 | 2h | 1h | Prisma 模型更新 |
| 后端 API 修复 | 4h | 3h | 接口统一 + 点赞/回复 |
| 前端数据模型 | 1h | 1h | Dart Model 定义 |
| 前端 API 服务 | 2h | 1.5h | ReviewService |
| 点赞按钮组件 | 3h | 2.5h | 动画 + 粒子效果 |
| 评论列表组件 | 4h | 3h | 列表 + 骨架屏 + 空状态 |
| 回复列表组件 | 2h | 1.5h | 嵌套回复展示 |
| 其他 UI 组件 | 2h | 1.5h | 标签、图片网格等 |
| **总计** | **20h** | **15h** | - |

---

## 5. 测试检查清单

### 5.1 后端测试

- [x] Prisma migrate 成功
- [x] POST /v1/trails/:trailId/reviews 接口测试
- [x] GET /v1/trails/:trailId/reviews 接口测试
- [x] PUT /v1/reviews/:id 接口测试
- [x] DELETE /v1/reviews/:id 接口测试
- [x] POST /v1/reviews/:id/like 点赞/取消点赞测试
- [x] GET /v1/reviews/:id/like 状态检查测试
- [x] POST /v1/reviews/:id/replies 回复测试
- [x] 响应格式统一性验证
- [x] 评分类型 integer 验证

### 5.2 前端测试

- [x] 评论列表加载
- [x] 下拉刷新
- [x] 无限滚动加载
- [x] 点赞动画效果
- [x] 点赞数同步
- [x] 图片网格展示
- [x] 图片全屏查看
- [x] 回复列表展开
- [x] 骨架屏效果
- [x] 空状态展示

---

## 6. API 接口文档

### 6.1 评论相关

#### 发表评论
```
POST /v1/trails/:trailId/reviews

Request:
{
  "rating": 4,           // 1-5 整数
  "content": "评论内容",
  "tags": ["风景优美"],
  "photos": ["url1", "url2"]
}

Response:
{
  "success": true,
  "data": { ...ReviewDto... }
}
```

#### 获取评论列表
```
GET /v1/trails/:trailId/reviews?sort=newest&page=1&limit=10

Response:
{
  "success": true,
  "data": {
    "list": [...ReviewDto...],
    "total": 100,
    "page": 1,
    "limit": 10,
    "stats": { ...ReviewStatsDto... }
  }
}
```

#### 点赞/取消点赞
```
POST /v1/reviews/:id/like

Response:
{
  "success": true,
  "data": {
    "isLiked": true,
    "likeCount": 24
  }
}
```

#### 检查点赞状态
```
GET /v1/reviews/:id/like

Response:
{
  "success": true,
  "data": {
    "isLiked": false
  }
}
```

#### 回复评论
```
POST /v1/reviews/:id/replies

Request:
{
  "content": "回复内容",
  "parentId": "父回复ID"  // 可选，用于嵌套回复
}

Response:
{
  "success": true,
  "data": { ...ReviewReplyDto... }
}
```

---

## 7. 后续优化建议

### P1 级优化
1. **Redis 缓存**: 评论列表、点赞状态缓存
2. **限流**: 点赞、评论接口限流保护
3. **敏感词过滤**: 评论内容审核

### P2 级优化
1. **WebSocket 实时通知**: 新回复、点赞通知
2. **评论排序算法**: 基于时间+热度排序
3. **图片懒加载优化**: 瀑布流性能优化

---

## 8. 附录

### 8.1 相关文件路径

```
# 后端
shanjing-api/
├── prisma/schema.prisma                          # 数据库模型
├── src/modules/reviews/
│   ├── reviews.controller.ts                     # 控制器
│   ├── reviews.service.ts                        # 服务层
│   └── dto/review.dto.ts                         # DTO 定义

# 前端
lib/
├── models/review_model.dart                      # 数据模型
├── services/
│   ├── api_client.dart                           # API 客户端 (添加 PUT)
│   └── review_service.dart                       # 评论服务
└── widgets/review/                               # 评论组件目录
    ├── like_button.dart                          # 点赞按钮
    ├── review_item.dart                          # 评论项
    ├── review_list.dart                          # 评论列表
    ├── review_tags.dart                          # 标签
    ├── review_photo_grid.dart                    # 图片网格
    ├── review_reply_list.dart                    # 回复列表
    ├── review_skeleton.dart                      # 骨架屏
    ├── review_empty.dart                         # 空状态
    ├── review_input.dart                         # 输入框
    └── index.dart                                # 统一导出
```

### 8.2 参考文档

- [M6-PRODUCT-DEV-REVIEW.md](./M6-PRODUCT-DEV-REVIEW.md)
- [M6-DESIGN-FIX-v1.0.md](./design/M6-DESIGN-FIX-v1.0.md)
- [M6-INTERFACE.md](./M6-INTERFACE.md)

---

**报告完成时间**: 2026-03-20  
**修复负责人**: Dev Agent  
**审核状态**: 待 QA 验证
