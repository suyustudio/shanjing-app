# M5 数据库 Schema 设计文档

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **文档状态**: 设计完成  
> **对应阶段**: M5 - 体验优化阶段  
> **基础版本**: B2 数据库设计 v1.0

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
| 新增表 | `achievements` | 成就定义表 | 低 |
| 新增表 | `achievement_levels` | 成就等级定义表 | 低 |
| 新增表 | `user_achievements` | 用户成就关联表 | 低 |
| 新增表 | `user_stats` | 用户统计数据表 | 中 |
| 新增表 | `recommendation_logs` | 推荐日志表（可选） | 低 |
| 新增字段 | `users.settings` | 用户设置 JSON | 低 |
| 新增字段 | `users.onboardingCompleted` | 引导完成状态 | 低 |
| 新增索引 | 多个 | 支持成就查询 | 低 |

### 1.2 ER 关系图

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           M5 数据库 ER 图                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                             │
│   ┌─────────────────┐         ┌──────────────────┐                         │
│   │     users       │         │  achievements    │                         │
│   ├─────────────────┤         ├──────────────────┤                         │
│   │ PK id           │         │ PK id            │                         │
│   │    wx_openid    │         │    key           │                         │
│   │    settings     │         │    category      │                         │
│   │    onboarding   │         └──────────────────┘                         │
│   └────────┬────────┘              ▲                                        │
│            │                       │                                        │
│            │ 1:N                   │ 1:N                                     │
│            ▼                       ▼                                        │
│   ┌─────────────────┐         ┌──────────────────┐                         │
│   │ user_achievements│         │ achievement_levels│                        │
│   ├─────────────────┤         ├──────────────────┤                         │
│   │ PK id           │         │ PK id            │                         │
│   │ FK user_id      │         │ FK achievement_id│                         │
│   │ FK achievement_id│         │    level         │                         │
│   │ FK level_id     │         │    requirement   │                         │
│   │    progress     │         └──────────────────┘                         │
│   └─────────────────┘                                                       │
│                                                                             │
│   ┌─────────────────┐                                                       │
│   │   user_stats    │                                                       │
│   ├─────────────────┤                                                       │
│   │ PK user_id      │                                                       │
│   │    total_distance│                                                      │
│   │    unique_trails │                                                      │
│   │    weekly_streak │                                                      │
│   │    night_count   │                                                      │
│   └─────────────────┘                                                       │
│                                                                             │
│   ┌─────────────────┐                                                       │
│   │ recommendation_ │                                                       │
│   │      logs       │                                                       │
│   ├─────────────────┤                                                       │
│   │ PK id           │                                                       │
│   │ FK user_id      │                                                       │
│   │    algorithm    │                                                       │
│   │    context      │                                                       │
│   └─────────────────┘                                                       │
│                                                                             │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 1.3 关联关系说明

| 父表 | 子表 | 关系类型 | 级联策略 |
|------|------|----------|----------|
| users | user_achievements | 1:N | 删除用户时级联删除 |
| users | user_stats | 1:1 | 删除用户时级联删除 |
| users | recommendation_logs | 1:N | 删除用户时级联删除 |
| achievements | achievement_levels | 1:N | 删除成就时级联删除 |
| achievements | user_achievements | 1:N | 删除成就时级联删除 |
| achievement_levels | user_achievements | 1:N | 删除等级时级联删除 |

---

## 2. 数据模型

### 2.1 成就定义表 (achievements)

存储成就的基础定义信息，包括类别、名称、图标等。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(32) | PK | 成就唯一ID |
| key | VARCHAR(32) | UQ, NOT NULL | 成就标识符，如 "explorer" |
| name | VARCHAR(64) | NOT NULL | 显示名称，如 "路线收集家" |
| description | TEXT | - | 成就描述 |
| category | VARCHAR(32) | NOT NULL | 类别：explorer/distance/frequency/challenge/social |
| icon_url | VARCHAR(256) | - | 默认图标URL |
| is_hidden | BOOLEAN | DEFAULT FALSE | 是否为隐藏成就 |
| sort_order | INT | DEFAULT 0 | 排序权重 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |

### 2.2 成就等级表 (achievement_levels)

存储每个成就的具体等级定义和达成条件。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(32) | PK | 等级唯一ID |
| achievement_id | VARCHAR(32) | FK, NOT NULL | 关联成就ID |
| level | VARCHAR(16) | NOT NULL | 等级：bronze/silver/gold/diamond |
| requirement | INT | NOT NULL | 达成条件数值 |
| name | VARCHAR(64) | NOT NULL | 等级名称，如 "初级探索者" |
| description | TEXT | - | 等级描述 |
| reward | VARCHAR(128) | - | 奖励说明 |
| icon_url | VARCHAR(256) | - | 等级专属图标URL |

**唯一约束**: (achievement_id, level)

### 2.3 用户成就表 (user_achievements)

记录用户的成就解锁状态和进度。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(32) | PK | 记录唯一ID |
| user_id | VARCHAR(32) | FK, NOT NULL | 用户ID |
| achievement_id | VARCHAR(32) | FK, NOT NULL | 成就ID |
| level_id | VARCHAR(32) | FK, NOT NULL | 等级ID |
| progress | INT | DEFAULT 0 | 当前进度值 |
| unlocked_at | TIMESTAMP | DEFAULT NOW() | 解锁时间 |
| is_new | BOOLEAN | DEFAULT TRUE | 是否新解锁（未查看） |
| is_notified | BOOLEAN | DEFAULT FALSE | 是否已通知 |

**唯一约束**: (user_id, achievement_id) - 每个成就用户只能有一个最高等级

### 2.4 用户统计表 (user_stats)

存储用户的徒步统计数据和成就计算所需数据。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| user_id | VARCHAR(32) | PK, FK | 用户ID |
| total_distance_m | INT | DEFAULT 0 | 累计徒步距离（米） |
| total_duration_sec | INT | DEFAULT 0 | 累计徒步时长（秒） |
| total_elevation_gain_m | FLOAT | DEFAULT 0 | 累计爬升（米） |
| unique_trails_count | INT | DEFAULT 0 | 完成的不同路线数 |
| completed_trail_ids | TEXT[] | DEFAULT '{}' | 已完成的路线ID数组 |
| current_weekly_streak | INT | DEFAULT 0 | 当前连续周数 |
| longest_weekly_streak | INT | DEFAULT 0 | 最长连续周数 |
| current_monthly_streak | INT | DEFAULT 0 | 当前连续月数 |
| last_trail_date | DATE | - | 上次徒步日期 |
| trail_count_this_week | INT | DEFAULT 0 | 本周徒步次数 |
| trail_count_this_month | INT | DEFAULT 0 | 本月徒步次数 |
| night_trail_count | INT | DEFAULT 0 | 夜间徒步次数 |
| rain_trail_count | INT | DEFAULT 0 | 雨天徒步次数 |
| solo_trail_count | INT | DEFAULT 0 | 独自徒步次数 |
| share_count | INT | DEFAULT 0 | 分享次数 |
| avg_distance_km | FLOAT | - | 平均徒步距离（公里） |
| avg_duration_min | FLOAT | - | 平均徒步时长（分钟） |
| preferred_difficulty | VARCHAR(16) | - | 偏好难度 |
| preferred_tags | TEXT[] | DEFAULT '{}' | 偏好标签数组 |
| updated_at | TIMESTAMP | DEFAULT NOW() | 更新时间 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |

### 2.5 推荐日志表 (recommendation_logs)

记录推荐算法的行为数据，用于算法优化（可选）。

| 字段 | 类型 | 约束 | 说明 |
|------|------|------|------|
| id | VARCHAR(32) | PK | 记录唯一ID |
| user_id | VARCHAR(32) | FK, NOT NULL | 用户ID |
| algorithm | VARCHAR(32) | NOT NULL | 算法版本，如 "scoring_v2" |
| context | JSONB | NOT NULL | 推荐上下文（位置、时间等） |
| results | JSONB | NOT NULL | 推荐结果列表 |
| user_action | VARCHAR(32) | - | 用户行为：click/view/bookmark/ignore |
| action_time | TIMESTAMP | - | 行为时间 |
| created_at | TIMESTAMP | DEFAULT NOW() | 创建时间 |

---

## 3. 完整 Schema

### 3.1 Prisma Schema

```prisma
// ================================================================
// M5 Schema Extensions - Prisma Definition
// 山径APP M5阶段数据库扩展
// ================================================================

// ==================== 枚举定义 ====================

enum AchievementCategory {
  explorer    // 探索类：完成路线
  distance    // 里程类：累计距离
  frequency   // 频率类：坚持徒步
  challenge   // 挑战类：特殊条件
  social      // 社交类：分享互动
}

enum AchievementLevel {
  bronze      // 铜
  silver      // 银
  gold        // 金
  diamond     // 钻石
}

// ==================== 成就系统 ====================

// 成就定义表
model Achievement {
  id          String              @id @default(cuid())
  key         String              @unique @db.VarChar(32)
  name        String              @db.VarChar(64)
  description String?             @db.Text
  category    AchievementCategory
  iconUrl     String?             @map("icon_url") @db.VarChar(256)
  isHidden    Boolean             @default(false) @map("is_hidden")
  sortOrder   Int                 @default(0) @map("sort_order")
  createdAt   DateTime            @default(now()) @map("created_at")
  
  levels      AchievementLevel[]
  userAchievements UserAchievement[]
  
  @@index([category])
  @@index([sortOrder])
  @@map("achievements")
}

// 成就等级定义表
model AchievementLevel {
  id              String           @id @default(cuid())
  achievementId   String           @map("achievement_id") @db.VarChar(32)
  level           AchievementLevel
  requirement     Int
  name            String           @db.VarChar(64)
  description     String?          @db.Text
  reward          String?          @db.VarChar(128)
  iconUrl         String?          @map("icon_url") @db.VarChar(256)
  
  achievement     Achievement      @relation(fields: [achievementId], references: [id], onDelete: Cascade)
  userAchievements UserAchievement[]
  
  @@unique([achievementId, level])
  @@map("achievement_levels")
}

// 用户成就表
model UserAchievement {
  id              String           @id @default(cuid())
  userId          String           @map("user_id") @db.VarChar(32)
  achievementId   String           @map("achievement_id") @db.VarChar(32)
  levelId         String           @map("level_id") @db.VarChar(32)
  progress        Int              @default(0)
  unlockedAt      DateTime         @default(now()) @map("unlocked_at")
  isNew           Boolean          @default(true) @map("is_new")
  isNotified      Boolean          @default(false) @map("is_notified")
  
  user            User             @relation(fields: [userId], references: [id], onDelete: Cascade)
  achievement     Achievement      @relation(fields: [achievementId], references: [id], onDelete: Cascade)
  level           AchievementLevel @relation(fields: [levelId], references: [id], onDelete: Cascade)
  
  @@unique([userId, achievementId])
  @@index([userId, unlockedAt])
  @@index([userId, isNew])
  @@map("user_achievements")
}

// 用户统计表
model UserStats {
  userId                  String   @id @map("user_id") @db.VarChar(32)
  
  // 里程统计
  totalDistanceM          Int      @default(0) @map("total_distance_m")
  totalDurationSec        Int      @default(0) @map("total_duration_sec")
  totalElevationGainM     Float    @default(0) @map("total_elevation_gain_m")
  
  // 路线统计
  uniqueTrailsCount       Int      @default(0) @map("unique_trails_count")
  completedTrailIds       String[] @default([]) @map("completed_trail_ids")
  
  // 频率统计
  currentWeeklyStreak     Int      @default(0) @map("current_weekly_streak")
  longestWeeklyStreak     Int      @default(0) @map("longest_weekly_streak")
  currentMonthlyStreak    Int      @default(0) @map("current_monthly_streak")
  lastTrailDate           DateTime? @map("last_trail_date")
  trailCountThisWeek      Int      @default(0) @map("trail_count_this_week")
  trailCountThisMonth     Int      @default(0) @map("trail_count_this_month")
  
  // 挑战统计
  nightTrailCount         Int      @default(0) @map("night_trail_count")
  rainTrailCount          Int      @default(0) @map("rain_trail_count")
  soloTrailCount          Int      @default(0) @map("solo_trail_count")
  
  // 社交统计
  shareCount              Int      @default(0) @map("share_count")
  
  // 用户画像（用于推荐）
  avgDistanceKm           Float?   @map("avg_distance_km")
  avgDurationMin          Float?   @map("avg_duration_min")
  preferredDifficulty     String?  @map("preferred_difficulty") @db.VarChar(16)
  preferredTags           String[] @default([]) @map("preferred_tags")
  
  updatedAt               DateTime @updatedAt @map("updated_at")
  createdAt               DateTime @default(now()) @map("created_at")
  
  user                    User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([totalDistanceM])
  @@index([uniqueTrailsCount])
  @@index([currentWeeklyStreak])
  @@map("user_stats")
}

// 推荐日志表（可选）
model RecommendationLog {
  id              String   @id @default(cuid())
  userId          String   @map("user_id") @db.VarChar(32)
  algorithm       String   @db.VarChar(32)
  context         Json
  results         Json
  userAction      String?  @map("user_action") @db.VarChar(32)
  actionTime      DateTime? @map("action_time")
  createdAt       DateTime @default(now()) @map("created_at")
  
  user            User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  @@index([userId, createdAt])
  @@index([algorithm])
  @@map("recommendation_logs")
}

// ==================== 扩展现有模型 ====================

model User {
  // ... 已有字段 ...
  
  // M5 新增关联
  achievements    UserAchievement[]
  stats           UserStats?
  recommendationLogs RecommendationLog[]
  
  // 用户设置扩展（JSON格式）
  // {
  //   "onboardingCompleted": true,
  //   "onboardingVersion": "1.0",
  //   "onboardingStep": 4,
  //   "notificationSettings": {...},
  //   "privacySettings": {...},
  //   "recommendationEnabled": true,
  //   "achievementsPublic": false
  // }
  settings        Json?    @default("{}")
  
  // ... 已有字段 ...
}
```

### 3.2 纯 SQL Schema

```sql
-- ================================================================
-- M5 Schema Extensions - SQL Definition
-- ================================================================

-- 1. 创建成就类别枚举类型
CREATE TYPE achievement_category AS ENUM (
  'explorer', 'distance', 'frequency', 'challenge', 'social'
);

-- 2. 创建成就等级枚举类型
CREATE TYPE achievement_level AS ENUM (
  'bronze', 'silver', 'gold', 'diamond'
);

-- 3. 创建成就定义表
CREATE TABLE achievements (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  key VARCHAR(32) UNIQUE NOT NULL,
  name VARCHAR(64) NOT NULL,
  description TEXT,
  category achievement_category NOT NULL,
  icon_url VARCHAR(256),
  is_hidden BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. 创建成就等级表
CREATE TABLE achievement_levels (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  achievement_id VARCHAR(32) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  level achievement_level NOT NULL,
  requirement INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  description TEXT,
  reward VARCHAR(128),
  icon_url VARCHAR(256),
  UNIQUE(achievement_id, level)
);

-- 5. 创建用户成就表
CREATE TABLE user_achievements (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(32) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_id VARCHAR(32) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  level_id VARCHAR(32) NOT NULL REFERENCES achievement_levels(id) ON DELETE CASCADE,
  progress INTEGER DEFAULT 0,
  unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_new BOOLEAN DEFAULT TRUE,
  is_notified BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

-- 6. 创建用户统计表
CREATE TABLE user_stats (
  user_id VARCHAR(32) PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  total_distance_m INTEGER DEFAULT 0,
  total_duration_sec INTEGER DEFAULT 0,
  total_elevation_gain_m FLOAT DEFAULT 0,
  unique_trails_count INTEGER DEFAULT 0,
  completed_trail_ids TEXT[] DEFAULT '{}',
  current_weekly_streak INTEGER DEFAULT 0,
  longest_weekly_streak INTEGER DEFAULT 0,
  current_monthly_streak INTEGER DEFAULT 0,
  last_trail_date DATE,
  trail_count_this_week INTEGER DEFAULT 0,
  trail_count_this_month INTEGER DEFAULT 0,
  night_trail_count INTEGER DEFAULT 0,
  rain_trail_count INTEGER DEFAULT 0,
  solo_trail_count INTEGER DEFAULT 0,
  share_count INTEGER DEFAULT 0,
  avg_distance_km FLOAT,
  avg_duration_min FLOAT,
  preferred_difficulty VARCHAR(16),
  preferred_tags TEXT[] DEFAULT '{}',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. 创建推荐日志表（可选）
CREATE TABLE recommendation_logs (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(32) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  algorithm VARCHAR(32) NOT NULL,
  context JSONB NOT NULL,
  results JSONB NOT NULL,
  user_action VARCHAR(32),
  action_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. 扩展 users 表
ALTER TABLE users ADD COLUMN IF NOT EXISTS settings JSONB DEFAULT '{}';
```

---

## 4. 索引设计

### 4.1 索引清单

| 表名 | 索引名 | 字段 | 类型 | 说明 |
|------|--------|------|------|------|
| achievements | idx_achievements_category | category | B-tree | 按类别查询 |
| achievements | idx_achievements_sort | sort_order | B-tree | 按排序权重 |
| achievement_levels | idx_levels_achievement | achievement_id | B-tree | 外键索引 |
| user_achievements | idx_user_achievements_user_time | user_id, unlocked_at | B-tree | 用户成就列表排序 |
| user_achievements | idx_user_achievements_user_new | user_id, is_new | B-tree | 新解锁成就查询 |
| user_achievements | idx_user_achievements_achievement | achievement_id | B-tree | 成就统计 |
| user_stats | idx_user_stats_distance | total_distance_m | B-tree | 里程排行 |
| user_stats | idx_user_stats_trails | unique_trails_count | B-tree | 路线排行 |
| user_stats | idx_user_stats_streak | current_weekly_streak | B-tree | 连续打卡排行 |
| recommendation_logs | idx_rec_logs_user_time | user_id, created_at | B-tree | 用户行为日志查询 |
| recommendation_logs | idx_rec_logs_algorithm | algorithm | B-tree | 算法效果分析 |

### 4.2 索引创建脚本

```sql
-- 成就表索引
CREATE INDEX idx_achievements_category ON achievements(category);
CREATE INDEX idx_achievements_sort ON achievements(sort_order);

-- 成就等级表索引
CREATE INDEX idx_levels_achievement ON achievement_levels(achievement_id);

-- 用户成就表索引
CREATE INDEX idx_user_achievements_user_time ON user_achievements(user_id, unlocked_at);
CREATE INDEX idx_user_achievements_user_new ON user_achievements(user_id, is_new);
CREATE INDEX idx_user_achievements_achievement ON user_achievements(achievement_id);

-- 用户统计表索引
CREATE INDEX idx_user_stats_distance ON user_stats(total_distance_m);
CREATE INDEX idx_user_stats_trails ON user_stats(unique_trails_count);
CREATE INDEX idx_user_stats_streak ON user_stats(current_weekly_streak);

-- 推荐日志表索引
CREATE INDEX idx_rec_logs_user_time ON recommendation_logs(user_id, created_at);
CREATE INDEX idx_rec_logs_algorithm ON recommendation_logs(algorithm);
```

---

## 5. 迁移脚本

### 5.1 完整迁移脚本

```sql
-- ================================================================
-- M5 Database Migration Script
-- 执行前请备份数据库！
-- ================================================================

BEGIN;

-- 1. 创建枚举类型
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'achievement_category') THEN
    CREATE TYPE achievement_category AS ENUM (
      'explorer', 'distance', 'frequency', 'challenge', 'social'
    );
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'achievement_level') THEN
    CREATE TYPE achievement_level AS ENUM (
      'bronze', 'silver', 'gold', 'diamond'
    );
  END IF;
END $$;

-- 2. 创建成就定义表
CREATE TABLE IF NOT EXISTS achievements (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  key VARCHAR(32) UNIQUE NOT NULL,
  name VARCHAR(64) NOT NULL,
  description TEXT,
  category achievement_category NOT NULL,
  icon_url VARCHAR(256),
  is_hidden BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. 创建成就等级表
CREATE TABLE IF NOT EXISTS achievement_levels (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  achievement_id VARCHAR(32) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  level achievement_level NOT NULL,
  requirement INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  description TEXT,
  reward VARCHAR(128),
  icon_url VARCHAR(256),
  UNIQUE(achievement_id, level)
);

-- 4. 创建用户成就表
CREATE TABLE IF NOT EXISTS user_achievements (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(32) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_id VARCHAR(32) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  level_id VARCHAR(32) NOT NULL,
  progress INTEGER DEFAULT 0,
  unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_new BOOLEAN DEFAULT TRUE,
  is_notified BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

-- 5. 创建用户统计表
CREATE TABLE IF NOT EXISTS user_stats (
  user_id VARCHAR(32) PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  total_distance_m INTEGER DEFAULT 0,
  total_duration_sec INTEGER DEFAULT 0,
  total_elevation_gain_m FLOAT DEFAULT 0,
  unique_trails_count INTEGER DEFAULT 0,
  completed_trail_ids TEXT[] DEFAULT '{}',
  current_weekly_streak INTEGER DEFAULT 0,
  longest_weekly_streak INTEGER DEFAULT 0,
  current_monthly_streak INTEGER DEFAULT 0,
  last_trail_date DATE,
  trail_count_this_week INTEGER DEFAULT 0,
  trail_count_this_month INTEGER DEFAULT 0,
  night_trail_count INTEGER DEFAULT 0,
  rain_trail_count INTEGER DEFAULT 0,
  solo_trail_count INTEGER DEFAULT 0,
  share_count INTEGER DEFAULT 0,
  avg_distance_km FLOAT,
  avg_duration_min FLOAT,
  preferred_difficulty VARCHAR(16),
  preferred_tags TEXT[] DEFAULT '{}',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. 创建推荐日志表
CREATE TABLE IF NOT EXISTS recommendation_logs (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(32) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  algorithm VARCHAR(32) NOT NULL,
  context JSONB NOT NULL,
  results JSONB NOT NULL,
  user_action VARCHAR(32),
  action_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. 扩展 users 表
ALTER TABLE users ADD COLUMN IF NOT EXISTS settings JSONB DEFAULT '{}';

-- 8. 创建索引
CREATE INDEX IF NOT EXISTS idx_achievements_category ON achievements(category);
CREATE INDEX IF NOT EXISTS idx_achievements_sort ON achievements(sort_order);
CREATE INDEX IF NOT EXISTS idx_levels_achievement ON achievement_levels(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_time ON user_achievements(user_id, unlocked_at);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_new ON user_achievements(user_id, is_new);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement ON user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_distance ON user_stats(total_distance_m);
CREATE INDEX IF NOT EXISTS idx_user_stats_trails ON user_stats(unique_trails_count);
CREATE INDEX IF NOT EXISTS idx_user_stats_streak ON user_stats(current_weekly_streak);
CREATE INDEX IF NOT EXISTS idx_rec_logs_user_time ON recommendation_logs(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_rec_logs_algorithm ON recommendation_logs(algorithm);

-- 9. 添加外键约束（如果还没有）
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_user_achievements_level'
  ) THEN
    ALTER TABLE user_achievements 
    ADD CONSTRAINT fk_user_achievements_level 
    FOREIGN KEY (level_id) REFERENCES achievement_levels(id) ON DELETE CASCADE;
  END IF;
END $$;

COMMIT;
```

### 5.2 回滚脚本

```sql
-- ================================================================
-- M5 Migration Rollback Script
-- 仅在紧急情况下使用！
-- ================================================================

BEGIN;

-- 1. 删除索引
DROP INDEX IF EXISTS idx_rec_logs_algorithm;
DROP INDEX IF EXISTS idx_rec_logs_user_time;
DROP INDEX IF EXISTS idx_user_stats_streak;
DROP INDEX IF EXISTS idx_user_stats_trails;
DROP INDEX IF EXISTS idx_user_stats_distance;
DROP INDEX IF EXISTS idx_user_achievements_achievement;
DROP INDEX IF EXISTS idx_user_achievements_user_new;
DROP INDEX IF EXISTS idx_user_achievements_user_time;
DROP INDEX IF EXISTS idx_levels_achievement;
DROP INDEX IF EXISTS idx_achievements_sort;
DROP INDEX IF EXISTS idx_achievements_category;

-- 2. 删除列
ALTER TABLE users DROP COLUMN IF EXISTS settings;

-- 3. 删除表
DROP TABLE IF EXISTS recommendation_logs;
DROP TABLE IF EXISTS user_stats;
DROP TABLE IF EXISTS user_achievements;
DROP TABLE IF EXISTS achievement_levels;
DROP TABLE IF EXISTS achievements;

-- 4. 删除枚举类型
DROP TYPE IF EXISTS achievement_level;
DROP TYPE IF EXISTS achievement_category;

COMMIT;
```

---

## 6. 数据初始化

### 6.1 成就数据种子

```sql
-- ================================================================
-- M5 Achievement Seed Data
-- ================================================================

BEGIN;

-- 1. 探索类成就：路线收集家
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('ach_explorer', 'explorer', '路线收集家', '探索不同的徒步路线，收集你的足迹', 'explorer', 'https://cdn.shanjing.app/badges/explorer.png', 1);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
(gen_random_uuid(), 'ach_explorer', 'bronze', 5, '初级探索者', '完成5条不同路线', 'https://cdn.shanjing.app/badges/explorer_bronze.png'),
(gen_random_uuid(), 'ach_explorer', 'silver', 15, '资深行者', '完成15条不同路线', 'https://cdn.shanjing.app/badges/explorer_silver.png'),
(gen_random_uuid(), 'ach_explorer', 'gold', 30, '山野达人', '完成30条不同路线', 'https://cdn.shanjing.app/badges/explorer_gold.png'),
(gen_random_uuid(), 'ach_explorer', 'diamond', 50, '路线收藏家', '完成50条不同路线', 'https://cdn.shanjing.app/badges/explorer_diamond.png');

-- 2. 里程类成就：行者无疆
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('ach_distance', 'distance', '行者无疆', '累计徒步里程，丈量世界', 'distance', 'https://cdn.shanjing.app/badges/distance.png', 2);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
(gen_random_uuid(), 'ach_distance', 'bronze', 10000, '初试身手', '累计10公里', 'https://cdn.shanjing.app/badges/distance_bronze.png'),
(gen_random_uuid(), 'ach_distance', 'silver', 50000, '步履不停', '累计50公里', 'https://cdn.shanjing.app/badges/distance_silver.png'),
(gen_random_uuid(), 'ach_distance', 'gold', 100000, '千里之行', '累计100公里', 'https://cdn.shanjing.app/badges/distance_gold.png'),
(gen_random_uuid(), 'ach_distance', 'diamond', 500000, '行者无疆', '累计500公里', 'https://cdn.shanjing.app/badges/distance_diamond.png');

-- 3. 频率类成就：周行者
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('ach_weekly', 'weekly', '周行者', '坚持每周徒步，养成运动习惯', 'frequency', 'https://cdn.shanjing.app/badges/weekly.png', 3);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
(gen_random_uuid(), 'ach_weekly', 'bronze', 2, '起步者', '连续2周每周徒步', 'https://cdn.shanjing.app/badges/weekly_bronze.png'),
(gen_random_uuid(), 'ach_weekly', 'silver', 4, '坚持者', '连续4周每周徒步', 'https://cdn.shanjing.app/badges/weekly_silver.png'),
(gen_random_uuid(), 'ach_weekly', 'gold', 8, '习惯养成', '连续8周每周徒步', 'https://cdn.shanjing.app/badges/weekly_gold.png'),
(gen_random_uuid(), 'ach_weekly', 'diamond', 16, '行者人生', '连续16周每周徒步', 'https://cdn.shanjing.app/badges/weekly_diamond.png');

-- 4. 挑战类成就：夜行者（隐藏成就）
INSERT INTO achievements (id, key, name, description, category, icon_url, is_hidden, sort_order) VALUES
('ach_night', 'night', '夜行者', '在夜晚探索山野，体验不一样的风景', 'challenge', 'https://cdn.shanjing.app/badges/night.png', true, 4);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
(gen_random_uuid(), 'ach_night', 'bronze', 1, '初探夜色', '完成1次夜间徒步', 'https://cdn.shanjing.app/badges/night_bronze.png'),
(gen_random_uuid(), 'ach_night', 'silver', 5, '夜行常客', '完成5次夜间徒步', 'https://cdn.shanjing.app/badges/night_silver.png'),
(gen_random_uuid(), 'ach_night', 'gold', 10, '暗夜行者', '完成10次夜间徒步', 'https://cdn.shanjing.app/badges/night_gold.png'),
(gen_random_uuid(), 'ach_night', 'diamond', 20, '月下独行者', '完成20次夜间徒步', 'https://cdn.shanjing.app/badges/night_diamond.png');

-- 5. 挑战类成就：雨中行（隐藏成就）
INSERT INTO achievements (id, key, name, description, category, icon_url, is_hidden, sort_order) VALUES
('ach_rain', 'rain', '雨中行', '在雨天徒步，感受自然的另一面', 'challenge', 'https://cdn.shanjing.app/badges/rain.png', true, 5);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
(gen_random_uuid(), 'ach_rain', 'bronze', 1, '雨中漫步', '完成1次雨天徒步', 'https://cdn.shanjing.app/badges/rain_bronze.png'),
(gen_random_uuid(), 'ach_rain', 'silver', 3, '风雨无阻', '完成3次雨天徒步', 'https://cdn.shanjing.app/badges/rain_silver.png'),
(gen_random_uuid(), 'ach_rain', 'gold', 5, '雨中山行', '完成5次雨天徒步', 'https://cdn.shanjing.app/badges/rain_gold.png'),
(gen_random_uuid(), 'ach_rain', 'diamond', 10, '雨夜行者', '完成10次雨天徒步', 'https://cdn.shanjing.app/badges/rain_diamond.png');

-- 6. 社交类成就：分享达人
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('ach_sharer', 'sharer', '分享达人', '分享你的徒步经历，传递户外乐趣', 'social', 'https://cdn.shanjing.app/badges/sharer.png', 6);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
(gen_random_uuid(), 'ach_sharer', 'bronze', 1, '初次分享', '分享1次徒步经历', 'https://cdn.shanjing.app/badges/sharer_bronze.png'),
(gen_random_uuid(), 'ach_sharer', 'silver', 5, '分享常客', '分享5次徒步经历', 'https://cdn.shanjing.app/badges/sharer_silver.png'),
(gen_random_uuid(), 'ach_sharer', 'gold', 10, '山径大使', '分享10次徒步经历', 'https://cdn.shanjing.app/badges/sharer_gold.png'),
(gen_random_uuid(), 'ach_sharer', 'diamond', 20, '户外博主', '分享20次徒步经历', 'https://cdn.shanjing.app/badges/sharer_diamond.png');

COMMIT;
```

### 6.2 Prisma Seed 脚本

```typescript
// prisma/seeds/m5_achievements.ts
import { PrismaClient, AchievementCategory, AchievementLevel } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // 清空现有成就数据
  await prisma.userAchievement.deleteMany();
  await prisma.achievementLevel.deleteMany();
  await prisma.achievement.deleteMany();

  // 成就定义
  const achievements = [
    {
      key: 'explorer',
      name: '路线收集家',
      description: '探索不同的徒步路线，收集你的足迹',
      category: AchievementCategory.explorer,
      iconUrl: 'https://cdn.shanjing.app/badges/explorer.png',
      sortOrder: 1,
      levels: [
        { level: AchievementLevel.bronze, requirement: 5, name: '初级探索者', description: '完成5条不同路线' },
        { level: AchievementLevel.silver, requirement: 15, name: '资深行者', description: '完成15条不同路线' },
        { level: AchievementLevel.gold, requirement: 30, name: '山野达人', description: '完成30条不同路线' },
        { level: AchievementLevel.diamond, requirement: 50, name: '路线收藏家', description: '完成50条不同路线' },
      ],
    },
    {
      key: 'distance',
      name: '行者无疆',
      description: '累计徒步里程，丈量世界',
      category: AchievementCategory.distance,
      iconUrl: 'https://cdn.shanjing.app/badges/distance.png',
      sortOrder: 2,
      levels: [
        { level: AchievementLevel.bronze, requirement: 10000, name: '初试身手', description: '累计10公里' },
        { level: AchievementLevel.silver, requirement: 50000, name: '步履不停', description: '累计50公里' },
        { level: AchievementLevel.gold, requirement: 100000, name: '千里之行', description: '累计100公里' },
        { level: AchievementLevel.diamond, requirement: 500000, name: '行者无疆', description: '累计500公里' },
      ],
    },
    {
      key: 'weekly',
      name: '周行者',
      description: '坚持每周徒步，养成运动习惯',
      category: AchievementCategory.frequency,
      iconUrl: 'https://cdn.shanjing.app/badges/weekly.png',
      sortOrder: 3,
      levels: [
        { level: AchievementLevel.bronze, requirement: 2, name: '起步者', description: '连续2周每周徒步' },
        { level: AchievementLevel.silver, requirement: 4, name: '坚持者', description: '连续4周每周徒步' },
        { level: AchievementLevel.gold, requirement: 8, name: '习惯养成', description: '连续8周每周徒步' },
        { level: AchievementLevel.diamond, requirement: 16, name: '行者人生', description: '连续16周每周徒步' },
      ],
    },
  ];

  // 创建成就和等级
  for (const achievementData of achievements) {
    const { levels, ...achievement } = achievementData;
    
    const created = await prisma.achievement.create({
      data: {
        ...achievement,
        levels: {
          create: levels.map(l => ({
            ...l,
            iconUrl: `https://cdn.shanjing.app/badges/${achievement.key}_${l.level}.png`,
          })),
        },
      },
    });
    
    console.log(`Created achievement: ${created.name}`);
  }

  console.log('Seed data created successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

---

## 7. 附录

### 7.1 变更记录

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2026-03-19 | 初始版本，完成 M5 数据库 Schema 设计 | Dev Agent |

### 7.2 相关文档

| 文档 | 路径 | 说明 |
|------|------|------|
| M5 技术架构 | M5-TECH-ARCHITECTURE.md | 技术架构设计 |
| M5 开发计划 | M5-DEV-PLAN.md | 开发任务分配 |
| M5 接口定义 | M5-INTERFACE-DEFINITION.md | 接口规范 |
| B2 数据库设计 | shanjing-b2-database-design.md | 基础数据库设计 |

### 7.3 数据库版本控制

```bash
# 生成 Prisma 迁移
npx prisma migrate dev --name add_m5_achievements

# 生成 Prisma Client
npx prisma generate

# 执行种子数据
npx prisma db seed

# 查看迁移状态
npx prisma migrate status
```

---

> **文档说明**: 本文档作为 M5 阶段数据库设计的交付物，包含完整的 Schema 定义、索引设计、迁移脚本和数据初始化。
