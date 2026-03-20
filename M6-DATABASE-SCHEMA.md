# M6 数据库 Schema 设计文档

> **文档版本**: v1.0  
> **制定日期**: 2026-03-20  > **文档状态**: 设计中  > **对应阶段**: M6 - 社交互动阶段  
> **基础版本**: M5 数据库 Schema

---

## 目录

1. [变更概述](#1-变更概述)
2. [数据模型](#2-数据模型)
3. [完整 Schema](#3-完整-schema)
4. [索引设计](#4-索引设计)
5. [迁移脚本](#5-迁移脚本)
6. [数据初始化](#6-数据初始化)
7. [附录](#7-附录)

---

## 1. 变更概述

### 1.1 变更清单

| 变更类型 | 对象名称 | 说明 | 影响级别 |
|----------|----------|------|----------|
| 新增表 | `reviews` | 路线评论主表 | 中 |
| 新增表 | `review_replies` | 评论回复表 | 低 |
| 新增表 | `review_tags` | 评论标签表 | 低 |
| 新增表 | `review_photos` | 评论图片表 | 低 |
| 新增表 | `photos` | 用户照片表 | 中 |
| 新增表 | `photo_likes` | 照片点赞表 | 低 |
| 新增表 | `follows` | 用户关注关系表 | 中 |
| 新增表 | `user_activities` | 用户动态表 | 中 |
| 新增表 | `collections` | 收藏夹表 | 中 |
| 新增表 | `collection_trails` | 收藏夹-路线关联表 | 低 |
| 修改表 | `trails` | 增加评分统计字段 | 低 |
| 修改表 | `users` | 增加社交统计字段 | 低 |
| 新增索引 | 多个 | 支持查询优化 | 低 |

### 1.2 ER 关系图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           M6 数据库 ER 图                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────┐         ┌─────────────┐         ┌─────────────┐          │
│   │    users    │─────────│   reviews   │─────────│   trails    │          │
│   ├─────────────┤    1:N  ├─────────────┤    N:1  ├─────────────┤          │
│   │ PK id       │         │ PK id       │         │ PK id       │          │
│   │    nickname │         │ FK user_id  │         │    name     │          │
│   │    avatar   │         │ FK trail_id │         │    reviews_count    │  │
│   └──────┬──────┘         │    rating   │         │    avg_rating       │  │
│          │                │    content  │         └─────────────┘          │
│          │ 1:N            └──────┬──────┘                ▲                 │
│          │                       │ 1:N                     │                 │
│          ▼                       ▼                       │ N:M             │
│   ┌─────────────┐         ┌─────────────┐               │                 │
│   │   follows   │         │review_replies│               │                 │
│   ├─────────────┤         ├─────────────┤               │                 │
│   │ PK id       │         │ PK id       │               │                 │
│   │ FK follower_id       │ FK review_id│               │                 │
│   │ FK following_id      │ FK user_id  │               │                 │
│   └─────────────┘         │    content  │               │                 │
│                           └─────────────┘               │                 │
│                                                         │                 │
│   ┌─────────────┐         ┌─────────────┐               │                 │
│   │  collections│◄────────│collection_  │───────────────┘                 │
│   ├─────────────┤    1:N  │   trails    │         N:1                     │
│   │ PK id       │         ├─────────────┤                                 │
│   │ FK user_id  │         │ PK id       │                                 │
│   │    name     │         │ FK collection_id                              │
│   │    is_public│         │ FK trail_id │                                 │
│   └─────────────┘         └─────────────┘                                 │
│                                                                             │
│   ┌─────────────┐         ┌─────────────┐                                  │
│   │    photos   │◄────────│photo_likes  │                                  │
│   ├─────────────┤    1:N  ├─────────────┤                                  │
│   │ PK id       │         │ PK id       │                                  │
│   │ FK user_id  │         │ FK photo_id │                                  │
│   │ FK trail_id │         │ FK user_id  │                                  │
│   │    url      │         └─────────────┘                                  │
│   │    lat/lng  │                                                           │
│   └─────────────┘                                                           │
│                                                                             │
│   ┌─────────────┐                                                           │
│   │user_activity│                                                           │
│   ├─────────────┤                                                           │
│   │ PK id       │                                                           │
│   │ FK user_id  │                                                           │
│   │    type     │                                                           │
│   │    content  │                                                           │
│   └─────────────┘                                                           │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 关联关系说明

| 父表 | 子表 | 关系类型 | 级联策略 |
|------|------|----------|----------|
| users | reviews | 1:N | 删除用户时级联删除 |
| users | review_replies | 1:N | 删除用户时级联删除 |
| users | photos | 1:N | 删除用户时级联删除 |
| users | follows | 1:N (as follower) | 删除用户时级联删除 |
| users | follows | 1:N (as following) | 删除用户时级联删除 |
| users | collections | 1:N | 删除用户时级联删除 |
| users | user_activities | 1:N | 删除用户时级联删除 |
| trails | reviews | 1:N | 删除路线时级联删除 |
| trails | photos | 1:N | 删除路线时级联删除 |
| trails | collection_trails | 1:N | 删除路线时级联删除 |
| reviews | review_replies | 1:N | 删除评论时级联删除 |
| photos | photo_likes | 1:N | 删除照片时级联删除 |
| collections | collection_trails | 1:N | 删除收藏夹时级联删除 |

---

## 2. 数据模型

### 2.1 路线评论表 (reviews)

存储用户对路线的评分和评论内容。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 评论唯一ID |
| user_id | VARCHAR(36) | FK, NOT NULL | 评论用户ID |
| trail_id | VARCHAR(36) | FK, NOT NULL | 路线ID |
| rating | DECIMAL(2,1) | NOT NULL | 评分 1.0-5.0，支持半星 |
| content | VARCHAR(500) | - | 评论内容 |
| is_edited | BOOLEAN | DEFAULT FALSE | 是否已编辑 |
| is_reported | BOOLEAN | DEFAULT FALSE | 是否被举报 |
| report_reason | VARCHAR(100) | - | 举报原因 |
| like_count | INT | DEFAULT 0 | 点赞数 |
| reply_count | INT | DEFAULT 0 | 回复数 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |
| updated_at | TIMESTAMP | DEFAULT NOW() | 更新时间 |

**唯一约束**: (user_id, trail_id) - 每个用户对每条路线只能评论一次

### 2.2 评论回复表 (review_replies)

存储对评论的回复内容。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 回复唯一ID |
| review_id | VARCHAR(36) | FK, NOT NULL | 所属评论ID |
| user_id | VARCHAR(36) | FK, NOT NULL | 回复用户ID |
| parent_id | VARCHAR(36) | FK | 父回复ID（支持嵌套回复） |
| content | VARCHAR(500) | NOT NULL | 回复内容 |
| is_reported | BOOLEAN | DEFAULT FALSE | 是否被举报 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |
| updated_at | TIMESTAMP | DEFAULT NOW() | 更新时间 |

### 2.3 评论标签表 (review_tags)

存储预定义的评论标签。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 标签唯一ID |
| review_id | VARCHAR(36) | FK, NOT NULL | 评论ID |
| tag | VARCHAR(32) | NOT NULL | 标签内容 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |

### 2.4 评论图片表 (review_photos)

存储评论附带的图片。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 图片唯一ID |
| review_id | VARCHAR(36) | FK, NOT NULL | 评论ID |
| url | VARCHAR(512) | NOT NULL | 图片URL |
| sort_order | INT | DEFAULT 0 | 排序顺序 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |

### 2.5 用户照片表 (photos)

存储用户上传的照片。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 照片唯一ID |
| user_id | VARCHAR(36) | FK, NOT NULL | 上传用户ID |
| trail_id | VARCHAR(36) | FK | 关联路线ID |
| poi_id | VARCHAR(36) | FK | 关联POI ID |
| url | VARCHAR(512) | NOT NULL | 照片URL |
| thumbnail_url | VARCHAR(512) | - | 缩略图URL |
| width | INT | - | 图片宽度 |
| height | INT | - | 图片高度 |
| size_kb | INT | - | 文件大小(KB) |
| description | VARCHAR(100) | - | 照片描述 |
| latitude | DECIMAL(10,8) | - | 拍摄纬度 |
| longitude | DECIMAL(11,8) | - | 拍摄经度 |
| taken_at | TIMESTAMP | - | 拍摄时间 |
| device | VARCHAR(100) | - | 拍摄设备 |
| like_count | INT | DEFAULT 0 | 点赞数 |
| is_public | BOOLEAN | DEFAULT TRUE | 是否公开 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |

### 2.6 照片点赞表 (photo_likes)

存储照片点赞记录。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 点赞唯一ID |
| photo_id | VARCHAR(36) | FK, NOT NULL | 照片ID |
| user_id | VARCHAR(36) | FK, NOT NULL | 用户ID |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |

**唯一约束**: (photo_id, user_id) - 每个用户只能点赞一次

### 2.7 用户关注表 (follows)

存储用户间的关注关系。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 关注唯一ID |
| follower_id | VARCHAR(36) | FK, NOT NULL | 关注者ID |
| following_id | VARCHAR(36) | FK, NOT NULL | 被关注者ID |
| created_at | TIMESTAMP | DEFAULT NOW() | 关注时间 |

**唯一约束**: (follower_id, following_id) - 不能重复关注
**检查约束**: follower_id ≠ following_id - 不能关注自己

### 2.8 用户动态表 (user_activities)

存储用户动态，用于生成关注流。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 动态唯一ID |
| user_id | VARCHAR(36) | FK, NOT NULL | 用户ID |
| type | VARCHAR(32) | NOT NULL | 动态类型 |
| content | JSONB | NOT NULL | 动态内容 |
| is_public | BOOLEAN | DEFAULT TRUE | 是否公开 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |

**动态类型枚举**:
- `complete_trail` - 完成路线
- `post_review` - 发表评论
- `upload_photo` - 上传照片
- `unlock_achievement` - 解锁成就
- `create_collection` - 创建收藏夹

### 2.9 收藏夹表 (collections)

存储用户创建的收藏夹。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 收藏夹唯一ID |
| user_id | VARCHAR(36) | FK, NOT NULL | 创建用户ID |
| name | VARCHAR(50) | NOT NULL | 收藏夹名称 |
| description | VARCHAR(200) | - | 收藏夹描述 |
| cover_url | VARCHAR(512) | - | 封面图片URL |
| is_public | BOOLEAN | DEFAULT TRUE | 是否公开 |
| sort_order | INT | DEFAULT 0 | 排序顺序 |
| trail_count | INT | DEFAULT 0 | 路线数量 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |
| updated_at | TIMESTAMP | DEFAULT NOW() | 更新时间 |

### 2.10 收藏夹-路线关联表 (collection_trails)

存储收藏夹和路线的多对多关系。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(36) | PK | 关联唯一ID |
| collection_id | VARCHAR(36) | FK, NOT NULL | 收藏夹ID |
| trail_id | VARCHAR(36) | FK, NOT NULL | 路线ID |
| sort_order | INT | DEFAULT 0 | 排序顺序 |
| note | VARCHAR(100) | - | 个人备注 |
| created_at | TIMESTAMP | DEFAULT NOW() | 添加时间 |

**唯一约束**: (collection_id, trail_id) - 同一条路线在一个收藏夹中只能出现一次

---

## 3. 完整 Schema

### 3.1 Prisma Schema 扩展

```prisma
// ================================================================
// M6 Schema Extensions - Prisma Definition
// 山径APP M6阶段数据库扩展
// ================================================================

// ==================== 评论系统 ====================

model Review {
  id            String    @id @default(uuid())
  userId        String    @map("user_id")
  trailId       String    @map("trail_id")
  rating        Decimal   @db.Decimal(2, 1)
  content       String?   @db.VarChar(500)
  isEdited      Boolean   @default(false) @map("is_edited")
  isReported    Boolean   @default(false) @map("is_reported")
  reportReason  String?   @map("report_reason") @db.VarChar(100)
  likeCount     Int       @default(0) @map("like_count")
  replyCount    Int       @default(0) @map("reply_count")
  createdAt     DateTime  @default(now()) @map("created_at")
  updatedAt     DateTime  @updatedAt @map("updated_at")

  user          User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  trail         Trail     @relation(fields: [trailId], references: [id], onDelete: Cascade)
  replies       ReviewReply[]
  tags          ReviewTag[]
  photos        ReviewPhoto[]

  @@unique([userId, trailId])
  @@index([trailId, createdAt])
  @@index([userId, createdAt])
  @@index([rating])
  @@map("reviews")
}

model ReviewReply {
  id            String    @id @default(uuid())
  reviewId      String    @map("review_id")
  userId        String    @map("user_id")
  parentId      String?   @map("parent_id")
  content       String    @db.VarChar(500)
  isReported    Boolean   @default(false) @map("is_reported")
  createdAt     DateTime  @default(now()) @map("created_at")
  updatedAt     DateTime  @updatedAt @map("updated_at")

  review        Review    @relation(fields: [reviewId], references: [id], onDelete: Cascade)
  user          User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  parent        ReviewReply? @relation("ReplyParent", fields: [parentId], references: [id])
  children      ReviewReply[] @relation("ReplyParent")

  @@index([reviewId, createdAt])
  @@index([userId])
  @@map("review_replies")
}

model ReviewTag {
  id            String    @id @default(uuid())
  reviewId      String    @map("review_id")
  tag           String    @db.VarChar(32)
  createdAt     DateTime  @default(now()) @map("created_at")

  review        Review    @relation(fields: [reviewId], references: [id], onDelete: Cascade)

  @@index([reviewId])
  @@index([tag])
  @@map("review_tags")
}

model ReviewPhoto {
  id            String    @id @default(uuid())
  reviewId      String    @map("review_id")
  url           String    @db.VarChar(512)
  sortOrder     Int       @default(0) @map("sort_order")
  createdAt     DateTime  @default(now()) @map("created_at")

  review        Review    @relation(fields: [reviewId], references: [id], onDelete: Cascade)

  @@index([reviewId])
  @@map("review_photos")
}

// ==================== 照片系统 ====================

model Photo {
  id            String    @id @default(uuid())
  userId        String    @map("user_id")
  trailId       String?   @map("trail_id")
  poiId         String?   @map("poi_id")
  url           String    @db.VarChar(512)
  thumbnailUrl  String?   @map("thumbnail_url") @db.VarChar(512)
  width         Int?
  height        Int?
  sizeKb        Int?      @map("size_kb")
  description   String?   @db.VarChar(100)
  latitude      Decimal?  @db.Decimal(10, 8)
  longitude     Decimal?  @db.Decimal(11, 8)
  takenAt       DateTime? @map("taken_at")
  device        String?   @db.VarChar(100)
  likeCount     Int       @default(0) @map("like_count")
  isPublic      Boolean   @default(true) @map("is_public")
  createdAt     DateTime  @default(now()) @map("created_at")

  user          User      @relation(fields: [userId], references: [id], onDelete: Cascade)
  trail         Trail?    @relation(fields: [trailId], references: [id], onDelete: SetNull)
  likes         PhotoLike[]

  @@index([trailId, createdAt])
  @@index([userId, createdAt])
  @@index([latitude, longitude])
  @@map("photos")
}

model PhotoLike {
  id            String    @id @default(uuid())
  photoId       String    @map("photo_id")
  userId        String    @map("user_id")
  createdAt     DateTime  @default(now()) @map("created_at")

  photo         Photo     @relation(fields: [photoId], references: [id], onDelete: Cascade)
  user          User      @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@unique([photoId, userId])
  @@index([photoId])
  @@index([userId])
  @@map("photo_likes")
}

// ==================== 用户关注系统 ====================

model Follow {
  id            String    @id @default(uuid())
  followerId    String    @map("follower_id")
  followingId   String    @map("following_id")
  createdAt     DateTime  @default(now()) @map("created_at")

  follower      User      @relation("Follower", fields: [followerId], references: [id], onDelete: Cascade)
  following     User      @relation("Following", fields: [followingId], references: [id], onDelete: Cascade)

  @@unique([followerId, followingId])
  @@index([followerId, createdAt])
  @@index([followingId, createdAt])
  @@map("follows")
}

// ==================== 用户动态系统 ====================

enum ActivityType {
  COMPLETE_TRAIL
  POST_REVIEW
  UPLOAD_PHOTO
  UNLOCK_ACHIEVEMENT
  CREATE_COLLECTION
}

model UserActivity {
  id            String       @id @default(uuid())
  userId        String       @map("user_id")
  type          ActivityType
  content       Json
  isPublic      Boolean      @default(true) @map("is_public")
  createdAt     DateTime     @default(now()) @map("created_at")

  user          User         @relation(fields: [userId], references: [id], onDelete: Cascade)

  @@index([userId, createdAt])
  @@index([type, createdAt])
  @@map("user_activities")
}

// ==================== 收藏夹系统 ====================

model Collection {
  id            String             @id @default(uuid())
  userId        String             @map("user_id")
  name          String             @db.VarChar(50)
  description   String?            @db.VarChar(200)
  coverUrl      String?            @map("cover_url") @db.VarChar(512)
  isPublic      Boolean            @default(true) @map("is_public")
  sortOrder     Int                @default(0) @map("sort_order")
  trailCount    Int                @default(0) @map("trail_count")
  createdAt     DateTime           @default(now()) @map("created_at")
  updatedAt     DateTime           @updatedAt @map("updated_at")

  user          User               @relation(fields: [userId], references: [id], onDelete: Cascade)
  trails        CollectionTrail[]

  @@index([userId, sortOrder])
  @@index([isPublic, createdAt])
  @@map("collections")
}

model CollectionTrail {
  id            String      @id @default(uuid())
  collectionId  String      @map("collection_id")
  trailId       String      @map("trail_id")
  sortOrder     Int         @default(0) @map("sort_order")
  note          String?     @db.VarChar(100)
  createdAt     DateTime    @default(now()) @map("created_at")

  collection    Collection  @relation(fields: [collectionId], references: [id], onDelete: Cascade)
  trail         Trail       @relation(fields: [trailId], references: [id], onDelete: Cascade)

  @@unique([collectionId, trailId])
  @@index([collectionId, sortOrder])
  @@map("collection_trails")
}

// ==================== 扩展现有模型 ====================

model User {
  // ... 已有字段 ...
  
  // M6 新增关联
  reviews           Review[]
  reviewReplies     ReviewReply[]
  photos            Photo[]
  photoLikes        PhotoLike[]
  followers         Follow[] @relation("Following")
  following         Follow[] @relation("Follower")
  activities        UserActivity[]
  collections       Collection[]
  
  // M6 新增统计字段
  followersCount    Int       @default(0) @map("followers_count")
  followingCount    Int       @default(0) @map("following_count")
  photosCount       Int       @default(0) @map("photos_count")
  
  // ... 已有字段 ...
}

model Trail {
  // ... 已有字段 ...
  
  // M6 新增关联
  reviews           Review[]
  photos            Photo[]
  collectionTrails  CollectionTrail[]
  
  // M6 新增统计字段
  reviewsCount      Int       @default(0) @map("reviews_count")
  avgRating         Decimal?  @db.Decimal(2, 1) @map("avg_rating")
  rating5Count      Int       @default(0) @map("rating_5_count")
  rating4Count      Int       @default(0) @map("rating_4_count")
  rating3Count      Int       @default(0) @map("rating_3_count")
  rating2Count      Int       @default(0) @map("rating_2_count")
  rating1Count      Int       @default(0) @map("rating_1_count")
  
  // ... 已有字段 ...
}
```

---

## 4. 索引设计

### 4.1 索引清单

| 表名 | 索引名 | 字段 | 类型 | 说明 |
|------|--------|------|------|------|
| reviews | idx_reviews_trail_time | trail_id, created_at | B-tree | 路线评论列表 |
| reviews | idx_reviews_user_time | user_id, created_at | B-tree | 用户评论列表 |
| reviews | idx_reviews_rating | rating | B-tree | 评分筛选 |
| review_replies | idx_review_replies_review | review_id, created_at | B-tree | 评论回复列表 |
| review_tags | idx_review_tags_tag | tag | B-tree | 标签统计 |
| photos | idx_photos_trail | trail_id, created_at | B-tree | 路线照片列表 |
| photos | idx_photos_user | user_id, created_at | B-tree | 用户照片列表 |
| photos | idx_photos_location | latitude, longitude | B-tree | 地理位置查询 |
| photo_likes | idx_photo_likes_photo | photo_id | B-tree | 照片点赞查询 |
| follows | idx_follows_follower | follower_id, created_at | B-tree | 关注列表 |
| follows | idx_follows_following | following_id, created_at | B-tree | 粉丝列表 |
| user_activities | idx_activities_user | user_id, created_at | B-tree | 用户动态流 |
| user_activities | idx_activities_type | type, created_at | B-tree | 类型筛选 |
| collections | idx_collections_user | user_id, sort_order | B-tree | 用户收藏夹列表 |
| collections | idx_collections_public | is_public, created_at | B-tree | 公开收藏夹发现 |
| collection_trails | idx_collection_trails | collection_id, sort_order | B-tree | 收藏夹内路线排序 |

---

## 5. 迁移脚本

### 5.1 完整迁移脚本 (PostgreSQL)

```sql
-- ================================================================
-- M6 Database Migration Script
-- 执行前请备份数据库！
-- ================================================================

BEGIN;

-- ==================== 评论系统 ====================

-- 创建评论表
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trail_id UUID NOT NULL REFERENCES trails(id) ON DELETE CASCADE,
    rating DECIMAL(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    content VARCHAR(500),
    is_edited BOOLEAN DEFAULT FALSE,
    is_reported BOOLEAN DEFAULT FALSE,
    report_reason VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    reply_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, trail_id)
);

-- 创建评论回复表
CREATE TABLE review_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES review_replies(id) ON DELETE CASCADE,
    content VARCHAR(500) NOT NULL,
    is_reported BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建评论标签表
CREATE TABLE review_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    tag VARCHAR(32) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建评论图片表
CREATE TABLE review_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    url VARCHAR(512) NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 照片系统 ====================

-- 创建照片表
CREATE TABLE photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trail_id UUID REFERENCES trails(id) ON DELETE SET NULL,
    poi_id UUID,
    url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512),
    width INTEGER,
    height INTEGER,
    size_kb INTEGER,
    description VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    taken_at TIMESTAMP,
    device VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建照片点赞表
CREATE TABLE photo_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    photo_id UUID NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(photo_id, user_id)
);

-- ==================== 用户关注系统 ====================

-- 创建关注表
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- ==================== 用户动态系统 ====================

-- 创建动态类型枚举
CREATE TYPE activity_type AS ENUM (
    'COMPLETE_TRAIL',
    'POST_REVIEW',
    'UPLOAD_PHOTO',
    'UNLOCK_ACHIEVEMENT',
    'CREATE_COLLECTION'
);

-- 创建用户动态表
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type activity_type NOT NULL,
    content JSONB NOT NULL,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 收藏夹系统 ====================

-- 创建收藏夹表
CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    cover_url VARCHAR(512),
    is_public BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    trail_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建收藏夹-路线关联表
CREATE TABLE collection_trails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    trail_id UUID NOT NULL REFERENCES trails(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    note VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(collection_id, trail_id)
);

-- ==================== 扩展现有表 ====================

-- 扩展 users 表
ALTER TABLE users ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS photos_count INTEGER DEFAULT 0;

-- 扩展 trails 表
ALTER TABLE trails ADD COLUMN IF NOT EXISTS reviews_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS avg_rating DECIMAL(2,1);
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_5_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_4_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_3_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_2_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_1_count INTEGER DEFAULT 0;

-- ==================== 创建索引 ====================

-- 评论表索引
CREATE INDEX idx_reviews_trail_time ON reviews(trail_id, created_at DESC);
CREATE INDEX idx_reviews_user_time ON reviews(user_id, created_at DESC);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- 评论回复表索引
CREATE INDEX idx_review_replies_review ON review_replies(review_id, created_at);
CREATE INDEX idx_review_replies_user ON review_replies(user_id);

-- 评论标签表索引
CREATE INDEX idx_review_tags_review ON review_tags(review_id);
CREATE INDEX idx_review_tags_tag ON review_tags(tag);

-- 照片表索引
CREATE INDEX idx_photos_trail ON photos(trail_id, created_at DESC);
CREATE INDEX idx_photos_user ON photos(user_id, created_at DESC);
CREATE INDEX idx_photos_location ON photos(latitude, longitude);

-- 照片点赞表索引
CREATE INDEX idx_photo_likes_photo ON photo_likes(photo_id);
CREATE INDEX idx_photo_likes_user ON photo_likes(user_id);

-- 关注表索引
CREATE INDEX idx_follows_follower ON follows(follower_id, created_at DESC);
CREATE INDEX idx_follows_following ON follows(following_id, created_at DESC);

-- 用户动态表索引
CREATE INDEX idx_activities_user ON user_activities(user_id, created_at DESC);
CREATE INDEX idx_activities_type ON user_activities(type, created_at DESC);

-- 收藏夹表索引
CREATE INDEX idx_collections_user ON collections(user_id, sort_order);
CREATE INDEX idx_collections_public ON collections(is_public, created_at DESC);

-- 收藏夹-路线关联表索引
CREATE INDEX idx_collection_trails ON collection_trails(collection_id, sort_order);

COMMIT;
```

### 5.2 回滚脚本

```sql
-- ================================================================
-- M6 Migration Rollback Script
-- 仅在紧急情况下使用！
-- ================================================================

BEGIN;

-- 删除索引
DROP INDEX IF EXISTS idx_collection_trails;
DROP INDEX IF EXISTS idx_collections_public;
DROP INDEX IF EXISTS idx_collections_user;
DROP INDEX IF EXISTS idx_activities_type;
DROP INDEX IF EXISTS idx_activities_user;
DROP INDEX IF EXISTS idx_follows_following;
DROP INDEX IF EXISTS idx_follows_follower;
DROP INDEX IF EXISTS idx_photo_likes_user;
DROP INDEX IF EXISTS idx_photo_likes_photo;
DROP INDEX IF EXISTS idx_photos_location;
DROP INDEX IF EXISTS idx_photos_user;
DROP INDEX IF EXISTS idx_photos_trail;
DROP INDEX IF EXISTS idx_review_tags_tag;
DROP INDEX IF EXISTS idx_review_tags_review;
DROP INDEX IF EXISTS idx_review_replies_user;
DROP INDEX IF EXISTS idx_review_replies_review;
DROP INDEX IF EXISTS idx_reviews_rating;
DROP INDEX IF EXISTS idx_reviews_user_time;
DROP INDEX IF EXISTS idx_reviews_trail_time;

-- 删除列
ALTER TABLE trails DROP COLUMN IF EXISTS rating_1_count;
ALTER TABLE trails DROP COLUMN IF EXISTS rating_2_count;
ALTER TABLE trails DROP COLUMN IF EXISTS rating_3_count;
ALTER TABLE trails DROP COLUMN IF EXISTS rating_4_count;
ALTER TABLE trails DROP COLUMN IF EXISTS rating_5_count;
ALTER TABLE trails DROP COLUMN IF EXISTS avg_rating;
ALTER TABLE trails DROP COLUMN IF EXISTS reviews_count;
ALTER TABLE users DROP COLUMN IF EXISTS photos_count;
ALTER TABLE users DROP COLUMN IF EXISTS following_count;
ALTER TABLE users DROP COLUMN IF EXISTS followers_count;

-- 删除表
DROP TABLE IF EXISTS collection_trails;
DROP TABLE IF EXISTS collections;
DROP TABLE IF EXISTS user_activities;
DROP TYPE IF EXISTS activity_type;
DROP TABLE IF EXISTS follows;
DROP TABLE IF EXISTS photo_likes;
DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS review_photos;
DROP TABLE IF EXISTS review_tags;
DROP TABLE IF EXISTS review_replies;
DROP TABLE IF EXISTS reviews;

COMMIT;
```

---

## 6. 数据初始化

### 6.1 预定义评论标签

```sql
-- 预定义评论标签（用于前端展示和筛选）
-- 注意：实际标签存储在 review_tags 表中，此处仅作为参考

-- 风景类
-- '风景优美', '视野开阔', '拍照圣地', '秋色迷人', '春花烂漫'

-- 难度类
-- '难度适中', '轻松休闲', '挑战性强', '适合新手', '需要体能'

-- 设施类
-- '设施完善', '补给方便', '厕所干净', '指示牌清晰'

-- 人群类
-- '适合亲子', '宠物友好', '人少清静', '团队建设'

-- 特色类
-- '历史文化', '古迹众多', '森林氧吧', '溪流潺潺'
```

---

## 7. 附录

### 7.1 变更记录

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2026-03-20 | 初始版本，完成 M6 数据库 Schema 设计 | Dev Agent |

### 7.2 相关文档

| 文档 | 路径 | 说明 |
|------|------|------|
| M6 功能规划 | M6-FEATURE-PLAN.md | 功能规划文档 |
| M6 评论 API | M6-Review-API.md | 评论系统接口文档 |
| M6 照片 API | M6-Photo-API.md | 照片系统接口文档 |
| M5 数据库 | M5-DATABASE-SCHEMA.md | M5 基础数据库设计 |

### 7.3 数据库版本控制

```bash
# 生成 Prisma 迁移
npx prisma migrate dev --name add_m6_social_features

# 生成 Prisma Client
npx prisma generate

# 查看迁移状态
npx prisma migrate status
```

---

> **文档说明**: 本文档作为 M6 阶段数据库设计的交付物，包含完整的 Schema 定义、索引设计、迁移脚本。
