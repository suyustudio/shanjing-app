# M5 技术架构设计文档

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **文档状态**: 技术规划  
> **对应阶段**: M5 - 体验优化阶段  
> **技术栈**: Flutter + Node.js/NestJS + PostgreSQL + Prisma

---

## 目录

1. [架构概述](#1-架构概述)
2. [M5 功能架构](#2-m5-功能架构)
3. [数据库 Schema 变更](#3-数据库-schema-变更)
4. [后端 API 设计](#4-后端-api-设计)
5. [客户端架构设计](#5-客户端架构设计)
6. [安全与性能](#6-安全与性能)
7. [附录](#7-附录)

---

## 1. 架构概述

### 1.1 M5 阶段定位

M5 阶段聚焦**用户体验优化**和**用户粘性提升**，通过三个核心功能实现：

| 功能 | 优先级 | 目标 | 技术关键词 |
|------|--------|------|-----------|
| 新手引导 | P1 | 降低首启流失率 | 本地存储、动态权限 |
| 成就系统 | P2 | 提升用户粘性 | 徽章算法、分享组件 |
| 路线推荐 | P2 | 个性化体验 | 5因子排序、冷启动策略 |

### 1.2 架构原则

```
┌─────────────────────────────────────────────────────────────────┐
│                     M5 架构设计原则                              │
├─────────────────────────────────────────────────────────────────┤
│ 1. 向后兼容：所有变更不破坏 M4 已有功能                          │
│ 2. 数据驱动：成就和推荐依赖埋点数据，复用已有 analytics 系统      │
│ 3. 渐进式实现：推荐算法从 V1 规则版开始，逐步迭代到 V2 ML版       │
│ 4. 离线优先：成就状态本地缓存，弱网环境下可正常展示               │
│ 5. 权限最小化：新手引导按需申请权限，不一次性索取                 │
└─────────────────────────────────────────────────────────────────┘
```

### 1.3 系统边界

```
┌─────────────────────────────────────────────────────────────────┐
│                         客户端 (Flutter)                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │ 新手引导     │  │ 成就系统     │  │ 路线推荐服务             │ │
│  │             │  │             │  │                         │ │
│  │ onboarding  │  │ achievement │  │ recommendation          │ │
│  │   - screen  │  │   - service │  │   - service             │ │
│  │   - service │  │   - repo    │  │   - screen              │ │
│  │   - local   │  │   - screen  │  │                         │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
│                              │                                  │
└──────────────────────────────┼──────────────────────────────────┘
                               │ HTTPS
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                         后端 (NestJS)                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────────┐ │
│  │ 用户配置     │  │ 成就管理     │  │ 推荐引擎                 │ │
│  │   /config   │  │   /achieve  │  │   /recommend            │ │
│  │             │  │             │  │   - rule-based V1       │ │
│  │             │  │             │  │   - scoring V2          │ │
│  └─────────────┘  └─────────────┘  └─────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────────┐
│                         数据层                                   │
│  ┌──────────────────┐  ┌──────────────────┐  ┌───────────────┐ │
│  │   PostgreSQL     │  │     Redis        │  │  Local SQLite │ │
│  │   - users        │  │   - hot data     │  │   - onboarding│ │
│  │   - achievements │  │   - cache        │  │   - achieve   │ │
│  │   - user_stats   │  │   - rate limit   │  │   - offline   │ │
│  └──────────────────┘  └──────────────────┘  └───────────────┘ │
└─────────────────────────────────────────────────────────────────┘
```

---

## 2. M5 功能架构

### 2.1 新手引导功能架构

```
┌──────────────────────────────────────────────────────────────┐
│                    新手引导功能架构                           │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              Onboarding Flow                        │   │
│   │                                                     │   │
│   │   ┌──────────┐   ┌──────────┐   ┌──────────────┐   │   │
│   │   │ 欢迎页面  │──▶│ 功能介绍  │──▶│ 权限申请页面  │   │   │
│   │   │          │   │ (轮播)    │   │              │   │   │
│   │   └──────────┘   └──────────┘   └──────┬───────┘   │   │
│   │                                        │           │   │
│   │                                        ▼           │   │
│   │                              ┌─────────────────┐   │   │
│   │                              │  首页场景化引导  │   │   │
│   │                              │  (spotlight)    │   │   │
│   │                              └─────────────────┘   │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              核心组件                               │   │
│   │                                                     │   │
│   │   ┌─────────────────────────────────────────────┐  │   │
│   │   │ OnboardingService (单例)                     │  │   │
│   │   │ ├─ checkOnboardingStatus()                  │  │   │
│   │   │ ├─ markCompleted()                          │  │   │
│   │   │ ├─ resetOnboarding()                        │  │   │
│   │   │ └─ shouldShowOnboarding()                   │  │   │
│   │   └─────────────────────────────────────────────┘  │   │
│   │                                                     │   │
│   │   ┌─────────────────────────────────────────────┐  │   │
│   │   │ PermissionManager                            │  │   │
│   │   │ ├─ requestLocationPermission()              │  │   │
│   │   │ ├─ requestStoragePermission()               │  │   │
│   │   │ ├─ requestNotificationPermission()          │  │   │
│   │   │ └─ checkPermissionStatus()                  │  │   │
│   │   └─────────────────────────────────────────────┘  │   │
│   │                                                     │   │
│   │   ┌─────────────────────────────────────────────┐  │   │
│   │   │ SpotlightOverlay (Widget)                    │  │   │
│   │   │ ├─ targetKey: GlobalKey                     │  │   │
│   │   │ ├─ description: String                      │  │   │
│   │   │ ├─ position: SpotlightPosition              │  │   │
│   │   │ └─ onDismiss: VoidCallback                  │  │   │
│   │   └─────────────────────────────────────────────┘  │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

#### 状态机设计

```dart
// 新手引导状态机
enum OnboardingState {
  notStarted,    // 从未启动
  inProgress,    // 进行中
  completed,     // 已完成
  skipped,       // 已跳过
}

// 状态流转
notStarted ──▶ inProgress ──▶ completed
                  │
                  ▼
               skipped
```

### 2.2 成就系统架构

```
┌──────────────────────────────────────────────────────────────┐
│                    成就系统架构                               │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              成就触发时机                            │   │
│   │                                                     │   │
│   │   轨迹完成 ──┬──▶ 探索类成就（路线收集家）            │   │
│   │              ├──▶ 里程类成就（行者无疆）              │   │
│   │              ├──▶ 频率类成就（周行者）                │   │
│   │              └──▶ 挑战类成就（夜行者/雨中行）         │   │
│   │                                                     │   │
│   │   分享行为 ─────▶ 社交类成就（分享达人）              │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              核心服务                                │   │
│   │                                                     │   │
│   │   ┌─────────────────────────────────────────────┐  │   │
│   │   │ AchievementService                          │  │   │
│   │   │ ├─ checkAchievements(UserStats)             │  │   │
│   │   │ ├─ unlockAchievement(id, level)             │  │   │
│   │   │ ├─ getUserAchievements(userId)              │  │   │
│   │   │ ├─ getAchievementProgress(id)               │  │   │
│   │   │ └─ generateShareImage(achievement)          │  │   │
│   │   └─────────────────────────────────────────────┘  │   │
│   │                                                     │   │
│   │   ┌─────────────────────────────────────────────┐  │   │
│   │   │ AchievementRepository (本地)                 │  │   │
│   │   │ ├─ getAllAchievements()                     │  │   │
│   │   │ ├─ getUnlockedAchievements(userId)          │  │   │
│   │   │ ├─ saveUserAchievement(achievement)         │  │   │
│   │   │ └─ updateAchievementProgress(id, progress)  │  │   │
│   │   └─────────────────────────────────────────────┘  │   │
│   │                                                     │   │
│   │   ┌─────────────────────────────────────────────┐  │   │
│   │   │ AchievementSyncService (同步)                │  │   │
│   │   │ ├─ syncToServer()                           │  │   │
│   │   │ ├─ syncFromServer()                         │  │   │
│   │   │ └─ resolveConflicts()                       │  │   │
│   │   └─────────────────────────────────────────────┘  │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              成就等级体系                            │   │
│   │                                                     │   │
│   │   explorer:    铜(5条) 银(15条) 金(30条) 钻(50条)    │   │
│   │   distance:    铜(10km) 银(50km) 金(100km) 钻(500km) │   │
│   │   frequency:   铜(2周) 银(4周) 金(8周) 钻(16周)      │   │
│   │   challenge:   铜(1次) 银(5次) 金(10次) 钻(20次)     │   │
│   │   social:      铜(1次) 银(5次) 金(10次) 钻(20次)     │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 2.3 路线推荐架构

```
┌──────────────────────────────────────────────────────────────┐
│                    路线推荐架构                               │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              5因子排序算法                           │   │
│   │                                                     │   │
│   │   Score = Σ(weight_i × factor_i)                   │   │
│   │                                                     │   │
│   │   ┌─────────────┬────────┬────────────────────────┐│   │
│   │   │ 因子        │ 权重   │ 计算方法               ││   │
│   │   ├─────────────┼────────┼────────────────────────┤│   │
│   │   │ 地理位置    │ 30%    │ 1 - distance/max_dist ││   │
│   │   │ 难度匹配    │ 25%    │ difficulty_match()    ││   │
│   │   │ 距离偏好    │ 20%    │ 1 - |pref-actual|/max ││   │
│   │   │ 路线评分    │ 15%    │ rating / 5.0          ││   │
│   │   │ 新鲜度      │ 10%    │ exp(-days_ago/30)     ││   │
│   │   └─────────────┴────────┴────────────────────────┘│   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              算法版本演进                            │   │
│   │                                                     │   │
│   │   V1 (M5早期)        V2 (M5后期)        V3 (未来)   │   │
│   │   ┌─────────┐       ┌─────────┐       ┌─────────┐  │   │
│   │   │规则排序 │  ──▶  │加权评分 │  ──▶  │协同过滤 │  │   │
│   │   │         │       │         │       │/ML模型  │  │   │
│   │   │附近优先 │       │用户画像 │       │深度学习 │  │   │
│   │   │热门补位 │       │匹配计算 │       │实时推荐 │  │   │
│   │   └─────────┘       └─────────┘       └─────────┘  │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
│   ┌─────────────────────────────────────────────────────┐   │
│   │              冷启动策略                              │   │
│   │                                                     │   │
│   │   无用户数据时：                                    │   │
│   │   1. 按距离排序（最近优先）                          │   │
│   │   2. 按热度排序（收藏数 + 完成数）                   │   │
│   │   3. 新路线加权（上线<7天 +20%）                     │   │
│   │                                                     │   │
│   └─────────────────────────────────────────────────────┘   │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## 3. 数据库 Schema 变更

### 3.1 变更摘要

M5 阶段需要对数据库进行以下扩展：

| 变更类型 | 对象 | 说明 | 影响级别 |
|----------|------|------|----------|
| 新增表 | `achievements` | 成就定义表 | 低 |
| 新增表 | `achievement_levels` | 成就等级表 | 低 |
| 新增表 | `user_achievements` | 用户成就关联表 | 低 |
| 新增表 | `user_stats` | 用户统计数据表 | 中 |
| 新增表 | `recommendation_logs` | 推荐日志表（可选） | 低 |
| 新增字段 | `users.settings` | 扩展用户设置JSON | 低 |
| 新增索引 | 多个 | 支持成就查询 | 低 |

### 3.2 完整 Schema 定义

```prisma
// ================================================================
// M5 Schema Extensions
// 山径APP M5阶段数据库扩展 - 成就系统 + 推荐服务
// ================================================================

// ==================== 成就系统 ====================

// 成就类别枚举
enum AchievementCategory {
  explorer    // 探索类：完成路线
  distance    // 里程类：累计距离
  frequency   // 频率类：坚持徒步
  challenge   // 挑战类：特殊条件
  social      // 社交类：分享互动
}

// 成就等级枚举
enum AchievementLevel {
  bronze      // 铜
  silver      // 银
  gold        // 金
  diamond     // 钻石
}

// 成就定义表
model Achievement {
  id          String              @id @default(cuid())
  key         String              @unique @db.VarChar(32)  // 成就唯一标识，如 "explorer"
  name        String              @db.VarChar(64)          // 显示名称，如 "路线收集家"
  description String              @db.Text                 // 成就描述
  category    AchievementCategory                          // 成就类别
  iconUrl     String?             @map("icon_url")         // 徽章图标URL
  isHidden    Boolean             @default(false) @map("is_hidden")  // 隐藏成就
  sortOrder   Int                 @default(0) @map("sort_order")     // 排序权重
  createdAt   DateTime            @default(now()) @map("created_at")
  
  // 关联
  levels      AchievementLevel[]
  userAchievements UserAchievement[]
  
  @@index([category])
  @@index([sortOrder])
  @@map("achievements")
}

// 成就等级定义表
model AchievementLevel {
  id              String          @id @default(cuid())
  achievementId   String          @map("achievement_id")
  level           AchievementLevel                                 // 等级
  requirement     Int                                              // 达成条件数值
  name            String          @db.VarChar(64)                  // 等级名称，如 "初级探索者"
  description     String?         @db.Text                         // 等级描述
  reward          String?         @db.VarChar(128)                 // 奖励说明
  iconUrl         String?         @map("icon_url")                 // 等级专属图标
  
  // 关联
  achievement     Achievement     @relation(fields: [achievementId], references: [id], onDelete: Cascade)
  userAchievements UserAchievement[]
  
  @@unique([achievementId, level])
  @@map("achievement_levels")
}

// 用户成就表
model UserAchievement {
  id              String           @id @default(cuid())
  userId          String           @map("user_id")
  achievementId   String           @map("achievement_id")
  levelId         String           @map("level_id")
  progress        Int              @default(0)                      // 当前进度（用于进度条）
  unlockedAt      DateTime         @default(now()) @map("unlocked_at")
  isNew           Boolean          @default(true) @map("is_new")    // 是否新解锁（未查看）
  isNotified      Boolean          @default(false) @map("is_notified") // 是否已通知
  
  // 关联
  user            User             @relation(fields: [userId], references: [id], onDelete: Cascade)
  achievement     Achievement      @relation(fields: [achievementId], references: [id], onDelete: Cascade)
  level           AchievementLevel @relation(fields: [levelId], references: [id], onDelete: Cascade)
  
  @@unique([userId, achievementId])  // 每个成就用户只能有一个最高等级
  @@index([userId, unlockedAt])
  @@index([userId, isNew])
  @@map("user_achievements")
}

// 用户统计表（用于成就计算和推荐）
model UserStats {
  userId                  String   @id @map("user_id")
  
  // 里程统计
  totalDistanceM          Int      @default(0) @map("total_distance_m")         // 总距离（米）
  totalDurationSec        Int      @default(0) @map("total_duration_sec")       // 总时长（秒）
  totalElevationGainM     Float    @default(0) @map("total_elevation_gain_m")   // 总爬升
  
  // 路线统计（用于探索类成就）
  uniqueTrailsCount       Int      @default(0) @map("unique_trails_count")      // 完成的不同路线数
  completedTrailIds       String[] @default([]) @map("completed_trail_ids")      // 已完成的路线ID数组
  
  // 频率统计
  currentWeeklyStreak     Int      @default(0) @map("current_weekly_streak")    // 当前连续周数
  longestWeeklyStreak     Int      @default(0) @map("longest_weekly_streak")    // 最长连续周数
  currentMonthlyStreak    Int      @default(0) @map("current_monthly_streak")   // 当前连续月数
  lastTrailDate           DateTime? @map("last_trail_date")                     // 上次徒步日期
  trailCountThisWeek      Int      @default(0) @map("trail_count_this_week")    // 本周徒步次数
  trailCountThisMonth     Int      @default(0) @map("trail_count_this_month")   // 本月徒步次数
  
  // 挑战类统计
  nightTrailCount         Int      @default(0) @map("night_trail_count")        // 夜间徒步次数
  rainTrailCount          Int      @default(0) @map("rain_trail_count")         // 雨天徒步次数
  soloTrailCount          Int      @default(0) @map("solo_trail_count")         // 独自徒步次数
  
  // 社交类统计
  shareCount              Int      @default(0) @map("share_count")              // 分享次数
  
  // 推荐用用户画像
  avgDistanceKm           Float?   @map("avg_distance_km")                       // 平均徒步距离
  avgDurationMin          Float?   @map("avg_duration_min")                      // 平均徒步时长
  preferredDifficulty     String?  @map("preferred_difficulty")                  // 偏好难度
  preferredTags           String[] @default([]) @map("preferred_tags")           // 偏好标签
  
  // 关联
  user                    User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  // 时间戳
  updatedAt               DateTime @updatedAt @map("updated_at")
  createdAt               DateTime @default(now()) @map("created_at")
  
  @@index([totalDistanceM])
  @@index([uniqueTrailsCount])
  @@index([currentWeeklyStreak])
  @@map("user_stats")
}

// ==================== 推荐服务（可选） ====================

// 推荐日志表（用于算法优化）
model RecommendationLog {
  id              String   @id @default(cuid())
  userId          String   @map("user_id")
  algorithm       String   @db.VarChar(32)          // 使用的算法版本
  context         Json                              // 推荐上下文（位置、时间等）
  results         Json                              // 推荐结果列表
  userAction      String?  @map("user_action")      // 用户行为：click/ignore/bookmark
  actionTime      DateTime? @map("action_time")
  createdAt       DateTime @default(now()) @map("created_at")
  
  @@index([userId, createdAt])
  @@index([algorithm])
  @@map("recommendation_logs")
}

// ==================== 扩展现有模型 ====================

// 扩展 User 模型
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
  //   "notificationSettings": {...},
  //   "privacySettings": {...},
  //   "recommendationEnabled": true,
  //   "achievementsPublic": false
  // }
  settings        Json?    @default("{}")
  
  // ... 已有字段 ...
}
```

### 3.3 数据迁移脚本

```sql
-- M5 数据库迁移脚本
-- 执行顺序：1. 创建表 2. 创建索引 3. 迁移数据

-- 1. 创建成就相关表
BEGIN;

-- 1.1 成就定义表
CREATE TABLE IF NOT EXISTS achievements (
    id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
    key VARCHAR(32) UNIQUE NOT NULL,
    name VARCHAR(64) NOT NULL,
    description TEXT,
    category VARCHAR(32) NOT NULL CHECK (category IN ('explorer', 'distance', 'frequency', 'challenge', 'social')),
    icon_url VARCHAR(256),
    is_hidden BOOLEAN DEFAULT FALSE,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 1.2 成就等级表
CREATE TABLE IF NOT EXISTS achievement_levels (
    id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
    achievement_id VARCHAR(32) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
    level VARCHAR(16) NOT NULL CHECK (level IN ('bronze', 'silver', 'gold', 'diamond')),
    requirement INTEGER NOT NULL,
    name VARCHAR(64) NOT NULL,
    description TEXT,
    reward VARCHAR(128),
    icon_url VARCHAR(256),
    UNIQUE(achievement_id, level)
);

-- 1.3 用户成就表
CREATE TABLE IF NOT EXISTS user_achievements (
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

-- 1.4 用户统计表
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

-- 1.5 推荐日志表（可选）
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

COMMIT;

-- 2. 创建索引
BEGIN;

-- 成就表索引
CREATE INDEX IF NOT EXISTS idx_achievements_category ON achievements(category);
CREATE INDEX IF NOT EXISTS idx_achievements_sort ON achievements(sort_order);

-- 用户成就表索引
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_time ON user_achievements(user_id, unlocked_at);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_new ON user_achievements(user_id, is_new);

-- 用户统计表索引
CREATE INDEX IF NOT EXISTS idx_user_stats_distance ON user_stats(total_distance_m);
CREATE INDEX IF NOT EXISTS idx_user_stats_trails ON user_stats(unique_trails_count);
CREATE INDEX IF NOT EXISTS idx_user_stats_streak ON user_stats(current_weekly_streak);

-- 推荐日志表索引
CREATE INDEX IF NOT EXISTS idx_rec_logs_user_time ON recommendation_logs(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_rec_logs_algorithm ON recommendation_logs(algorithm);

COMMIT;

-- 3. 初始化成就数据
BEGIN;

-- 探索类成就：路线收集家
INSERT INTO achievements (id, key, name, description, category, sort_order) VALUES
('ach_explorer', 'explorer', '路线收集家', '探索不同的徒步路线，收集你的足迹', 'explorer', 1);

INSERT INTO achievement_levels (achievement_id, level, requirement, name, description) VALUES
('ach_explorer', 'bronze', 5, '初级探索者', '完成5条不同路线'),
('ach_explorer', 'silver', 15, '资深行者', '完成15条不同路线'),
('ach_explorer', 'gold', 30, '山野达人', '完成30条不同路线'),
('ach_explorer', 'diamond', 50, '路线收藏家', '完成50条不同路线');

-- 里程类成就：行者无疆
INSERT INTO achievements (id, key, name, description, category, sort_order) VALUES
('ach_distance', 'distance', '行者无疆', '累计徒步里程，丈量世界', 'distance', 2);

INSERT INTO achievement_levels (achievement_id, level, requirement, name, description) VALUES
('ach_distance', 'bronze', 10000, '初试身手', '累计10公里'),
('ach_distance', 'silver', 50000, '步履不停', '累计50公里'),
('ach_distance', 'gold', 100000, '千里之行', '累计100公里'),
('ach_distance', 'diamond', 500000, '行者无疆', '累计500公里');

-- 频率类成就：周行者
INSERT INTO achievements (id, key, name, description, category, sort_order) VALUES
('ach_weekly', 'weekly', '周行者', '坚持每周徒步，养成运动习惯', 'frequency', 3);

INSERT INTO achievement_levels (achievement_id, level, requirement, name, description) VALUES
('ach_weekly', 'bronze', 2, '起步者', '连续2周每周徒步'),
('ach_weekly', 'silver', 4, '坚持者', '连续4周每周徒步'),
('ach_weekly', 'gold', 8, '习惯养成', '连续8周每周徒步'),
('ach_weekly', 'diamond', 16, '行者人生', '连续16周每周徒步');

COMMIT;
```

---

## 4. 后端 API 设计

### 4.1 API 概览

| 模块 | 接口路径 | 方法 | 说明 | 认证 |
|------|----------|------|------|------|
| 配置 | `/config/onboarding` | GET/PUT | 新手引导配置 | 是 |
| 成就 | `/achievements` | GET | 获取所有成就定义 | 是 |
| 成就 | `/achievements/user` | GET | 获取用户成就 | 是 |
| 成就 | `/achievements/check` | POST | 检查并解锁成就 | 是 |
| 推荐 | `/recommendations` | GET | 获取推荐路线 | 是 |
| 统计 | `/users/me/stats` | GET | 获取用户统计 | 是 |

### 4.2 详细接口定义

#### 4.2.1 配置服务

```yaml
# 获取新手引导状态
GET /api/v1/config/onboarding

Response:
{
  "success": true,
  "data": {
    "completed": false,
    "completedAt": null,
    "currentStep": 2,
    "skipped": false,
    "version": "1.0"
  }
}

# 更新新手引导状态
PUT /api/v1/config/onboarding

Request:
{
  "completed": true,
  "currentStep": 4,
  "skipped": false
}

Response:
{
  "success": true,
  "data": {
    "completed": true,
    "completedAt": "2026-03-19T10:30:00Z"
  }
}
```

#### 4.2.2 成就服务

```yaml
# 获取所有成就定义
GET /api/v1/achievements

Response:
{
  "success": true,
  "data": [
    {
      "id": "ach_explorer",
      "key": "explorer",
      "name": "路线收集家",
      "description": "探索不同的徒步路线",
      "category": "explorer",
      "iconUrl": "https://cdn.shanjing.app/badges/explorer.png",
      "levels": [
        {
          "level": "bronze",
          "requirement": 5,
          "name": "初级探索者",
          "iconUrl": "https://cdn.shanjing.app/badges/explorer_bronze.png"
        },
        {
          "level": "silver",
          "requirement": 15,
          "name": "资深行者",
          "iconUrl": "https://cdn.shanjing.app/badges/explorer_silver.png"
        }
      ]
    }
  ]
}

# 获取用户成就
GET /api/v1/achievements/user

Response:
{
  "success": true,
  "data": {
    "totalCount": 12,
    "unlockedCount": 5,
    "newUnlockedCount": 1,
    "achievements": [
      {
        "achievementId": "ach_explorer",
        "key": "explorer",
        "name": "路线收集家",
        "category": "explorer",
        "currentLevel": "silver",
        "currentProgress": 18,
        "nextRequirement": 30,
        "unlockedAt": "2026-03-15T08:00:00Z",
        "isNew": false
      },
      {
        "achievementId": "ach_distance",
        "key": "distance",
        "name": "行者无疆",
        "category": "distance",
        "currentLevel": "gold",
        "currentProgress": 125000,
        "nextRequirement": 500000,
        "unlockedAt": "2026-03-19T10:30:00Z",
        "isNew": true
      }
    ]
  }
}

# 检查并解锁成就（通常在轨迹完成时调用）
POST /api/v1/achievements/check

Request:
{
  "triggerType": "trail_completed",
  "trailId": "trail_001",
  "stats": {
    "distance": 8500,
    "duration": 7200,
    "isNight": false,
    "isRain": false,
    "isSolo": true
  }
}

Response:
{
  "success": true,
  "data": {
    "newlyUnlocked": [
      {
        "achievementId": "ach_explorer",
        "level": "gold",
        "name": "山野达人",
        "message": "恭喜！你已完成30条不同路线",
        "badgeUrl": "https://cdn.shanjing.app/badges/explorer_gold.png"
      }
    ],
    "progressUpdated": [
      {
        "achievementId": "ach_distance",
        "progress": 125000,
        "requirement": 500000,
        "percentage": 25
      }
    ]
  }
}

# 标记成就已查看（清除new标记）
PUT /api/v1/achievements/:id/viewed

Response:
{
  "success": true,
  "data": {
    "isNew": false
  }
}
```

#### 4.2.3 推荐服务

```yaml
# 获取推荐路线
GET /api/v1/recommendations?lat=30.25&lng=120.15&limit=10

Response:
{
  "success": true,
  "data": {
    "algorithm": "scoring_v2",
    "context": {
      "location": { "lat": 30.25, "lng": 120.15 },
      "time": "2026-03-19T14:00:00Z",
      "weather": "sunny"
    },
    "trails": [
      {
        "id": "trail_001",
        "name": "九溪十八涧",
        "coverImage": "https://cdn.shanjing.app/trails/jiuxi.jpg",
        "distanceKm": 8.5,
        "durationMin": 180,
        "difficulty": "moderate",
        "score": 92.5,
        "matchFactors": {
          "location": 95,
          "difficulty": 90,
          "preference": 85,
          "rating": 95,
          "freshness": 100
        },
        "recommendReason": "距离你2.5公里，符合你的难度偏好"
      }
    ]
  }
}
```

#### 4.2.4 用户统计服务

```yaml
# 获取用户统计
GET /api/v1/users/me/stats

Response:
{
  "success": true,
  "data": {
    "lifetime": {
      "totalDistanceM": 125000,
      "totalDurationSec": 54000,
      "totalElevationGainM": 3200,
      "uniqueTrailsCount": 18,
      "completedTrailIds": ["trail_001", "trail_002"]
    },
    "streaks": {
      "currentWeekly": 3,
      "longestWeekly": 8,
      "currentMonthly": 1,
      "lastTrailDate": "2026-03-18"
    },
    "challenges": {
      "nightTrailCount": 2,
      "rainTrailCount": 1,
      "soloTrailCount": 12
    },
    "social": {
      "shareCount": 5
    },
    "profile": {
      "avgDistanceKm": 6.9,
      "avgDurationMin": 150,
      "preferredDifficulty": "moderate",
      "preferredTags": ["溪流", "茶园", "古刹"]
    }
  }
}
```

### 4.3 DTO 定义

```typescript
// src/modules/achievements/dto/achievement.dto.ts

export class AchievementLevelDto {
  level: 'bronze' | 'silver' | 'gold' | 'diamond';
  requirement: number;
  name: string;
  description?: string;
  iconUrl?: string;
}

export class AchievementDto {
  id: string;
  key: string;
  name: string;
  description: string;
  category: 'explorer' | 'distance' | 'frequency' | 'challenge' | 'social';
  iconUrl?: string;
  isHidden: boolean;
  levels: AchievementLevelDto[];
}

export class UserAchievementDto {
  achievementId: string;
  key: string;
  name: string;
  category: string;
  currentLevel: string;
  currentProgress: number;
  nextRequirement: number;
  percentage: number;
  unlockedAt: string;
  isNew: boolean;
}

export class CheckAchievementsRequestDto {
  triggerType: 'trail_completed' | 'share' | 'manual';
  trailId?: string;
  stats?: {
    distance: number;
    duration: number;
    isNight: boolean;
    isRain: boolean;
    isSolo: boolean;
  };
}

export class NewlyUnlockedAchievementDto {
  achievementId: string;
  level: string;
  name: string;
  message: string;
  badgeUrl: string;
}

// src/modules/recommendations/dto/recommendation.dto.ts

export class RecommendationContextDto {
  lat: number;
  lng: number;
  time?: string;
  weather?: string;
}

export class TrailMatchFactorsDto {
  location: number;
  difficulty: number;
  preference: number;
  rating: number;
  freshness: number;
}

export class RecommendedTrailDto {
  id: string;
  name: string;
  coverImage: string;
  distanceKm: number;
  durationMin: number;
  difficulty: string;
  score: number;
  matchFactors: TrailMatchFactorsDto;
  recommendReason?: string;
}

export class RecommendationsResponseDto {
  algorithm: string;
  context: RecommendationContextDto;
  trails: RecommendedTrailDto[];
}
```

---

## 5. 客户端架构设计

### 5.1 项目结构扩展

```
lib/
├── main.dart
├── app.dart
├── config/
│   └── routes.dart
├── core/
│   └── utils/
├── data/
│   ├── models/
│   │   ├── achievement_model.dart       # 新增
│   │   ├── user_stats_model.dart        # 新增
│   │   └── recommendation_model.dart    # 新增
│   └── repositories/
│       ├── achievement_repository.dart  # 新增
│       └── onboarding_repository.dart   # 新增
├── services/
│   ├── achievement_service.dart         # 新增
│   ├── onboarding_service.dart          # 新增
│   ├── recommendation_service.dart      # 新增
│   └── user_stats_service.dart          # 新增
├── presentation/
│   ├── screens/
│   │   ├── onboarding/
│   │   │   ├── onboarding_screen.dart
│   │   │   ├── welcome_page.dart
│   │   │   ├── feature_page.dart
│   │   │   └── permission_page.dart
│   │   ├── achievements/
│   │   │   ├── achievement_screen.dart
│   │   │   ├── badge_wall_view.dart
│   │   │   ├── achievement_detail_page.dart
│   │   │   └── unlock_animation.dart
│   │   └── recommendations/
│   │       ├── recommendation_screen.dart
│   │       └── recommendation_card.dart
│   └── widgets/
│       ├── spotlight_overlay.dart       # 场景化引导
│       ├── badge_widget.dart            # 徽章组件
│       └── progress_ring.dart           # 进度环
└── providers/
    ├── onboarding_provider.dart
    ├── achievement_provider.dart
    └── recommendation_provider.dart
```

### 5.2 核心服务接口

```dart
// ============================================================
// onboarding_service.dart - 新手引导服务
// ============================================================

abstract class OnboardingService {
  /// 检查是否需要显示新手引导
  Future<bool> shouldShowOnboarding();
  
  /// 获取当前引导步骤
  Future<int> getCurrentStep();
  
  /// 更新当前步骤
  Future<void> updateStep(int step);
  
  /// 标记引导完成
  Future<void> markCompleted();
  
  /// 标记引导跳过
  Future<void> markSkipped();
  
  /// 重置引导状态（用于重新触发）
  Future<void> reset();
  
  /// 检查权限状态
  Future<PermissionStatus> checkPermission(PermissionType type);
  
  /// 请求权限
  Future<bool> requestPermission(PermissionType type);
}

// ============================================================
// achievement_service.dart - 成就服务
// ============================================================

abstract class AchievementService {
  /// 获取所有成就定义
  Future<List<Achievement>> getAllAchievements();
  
  /// 获取用户成就列表
  Future<UserAchievementSummary> getUserAchievements();
  
  /// 检查并解锁成就（在轨迹完成时调用）
  Future<AchievementCheckResult> checkAchievements({
    required String triggerType,
    String? trailId,
    TrailStats? stats,
  });
  
  /// 获取成就进度
  Future<double> getAchievementProgress(String achievementId);
  
  /// 标记成就已查看
  Future<void> markAchievementViewed(String achievementId);
  
  /// 生成成就分享图片
  Future<String> generateShareImage(Achievement achievement);
  
  /// 监听新成就解锁（用于显示动画）
  Stream<Achievement> get onAchievementUnlocked;
}

// ============================================================
// recommendation_service.dart - 推荐服务
// ============================================================

abstract class RecommendationService {
  /// 获取推荐路线
  Future<List<RecommendedTrail>> getRecommendations({
    required double lat,
    required double lng,
    int limit = 10,
  });
  
  /// 获取相似路线
  Future<List<RecommendedTrail>> getSimilarTrails(String trailId);
  
  /// 刷新推荐
  Future<List<RecommendedTrail>> refreshRecommendations();
  
  /// 记录用户行为（用于算法优化）
  Future<void> trackUserAction({
    required String trailId,
    required UserAction action,
  });
}

// ============================================================
// user_stats_service.dart - 用户统计服务
// ============================================================

abstract class UserStatsService {
  /// 获取用户统计
  Future<UserStats> getUserStats();
  
  /// 更新统计（轨迹完成后调用）
  Future<void> updateStats(TrailRecord record);
  
  /// 获取连续打卡状态
  Future<StreakInfo> getStreakInfo();
  
  /// 监听统计更新
  Stream<UserStats> get onStatsUpdated;
}
```

### 5.3 状态管理设计

```dart
// ============================================================
// onboarding_provider.dart - 新手引导状态管理
// ============================================================

@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  late final OnboardingService _service;
  
  @override
  Future<OnboardingState> build() async {
    _service = ref.read(onboardingServiceProvider);
    final shouldShow = await _service.shouldShowOnboarding();
    final currentStep = await _service.getCurrentStep();
    
    return OnboardingState(
      shouldShow: shouldShow,
      currentStep: currentStep,
    );
  }
  
  Future<void> nextStep() async {
    final current = state.value?.currentStep ?? 0;
    await _service.updateStep(current + 1);
    state = AsyncValue.data(state.value!.copyWith(currentStep: current + 1));
  }
  
  Future<void> complete() async {
    await _service.markCompleted();
    state = AsyncValue.data(state.value!.copyWith(
      shouldShow: false,
      isCompleted: true,
    ));
  }
  
  Future<void> skip() async {
    await _service.markSkipped();
    state = AsyncValue.data(state.value!.copyWith(
      shouldShow: false,
      isSkipped: true,
    ));
  }
}

// ============================================================
// achievement_provider.dart - 成就状态管理
// ============================================================

@riverpod
class AchievementNotifier extends _$AchievementNotifier {
  late final AchievementService _service;
  
  @override
  Future<UserAchievementSummary> build() async {
    _service = ref.read(achievementServiceProvider);
    return await _service.getUserAchievements();
  }
  
  Future<void> checkAndUnlock({
    required String triggerType,
    String? trailId,
    TrailStats? stats,
  }) async {
    final result = await _service.checkAchievements(
      triggerType: triggerType,
      trailId: trailId,
      stats: stats,
    );
    
    // 刷新列表
    state = AsyncValue.data(await _service.getUserAchievements());
    
    // 显示新解锁动画
    for (final unlocked in result.newlyUnlocked) {
      _showUnlockAnimation(unlocked);
    }
  }
  
  Future<void> markViewed(String achievementId) async {
    await _service.markAchievementViewed(achievementId);
    state = AsyncValue.data(await _service.getUserAchievements());
  }
}

// ============================================================
// recommendation_provider.dart - 推荐状态管理
// ============================================================

@riverpod
class RecommendationNotifier extends _$RecommendationNotifier {
  late final RecommendationService _service;
  
  @override
  Future<List<RecommendedTrail>> build() async {
    _service = ref.read(recommendationServiceProvider);
    final location = await ref.read(locationProvider.future);
    
    return await _service.getRecommendations(
      lat: location.latitude,
      lng: location.longitude,
    );
  }
  
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _service.refreshRecommendations());
  }
  
  Future<void> trackClick(String trailId) async {
    await _service.trackUserAction(
      trailId: trailId,
      action: UserAction.click,
    );
  }
}
```

---

## 6. 安全与性能

### 6.1 安全措施

```dart
// ============================================================
// 安全措施
// ============================================================

// 1. 用户设置加密存储（紧急联系人等敏感信息）
class SecureStorageService {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  
  Future<void> saveEmergencyContacts(List<Contact> contacts) async {
    final encrypted = await _encrypt(jsonEncode(contacts));
    await _storage.write(key: 'emergency_contacts', value: encrypted);
  }
}

// 2. 成就防篡改校验
class AchievementIntegrity {
  /// 验证成就数据完整性
  static bool verifyAchievement(Achievement achievement, String signature) {
    final data = '${achievement.id}:${achievement.unlockedAt.millisecondsSinceEpoch}';
    final expected = Hmac(sha256, secretKey).convert(utf8.encode(data)).toString();
    return signature == expected;
  }
}

// 3. API 限流保护
class RateLimiter {
  static final Map<String, int> _requestCounts = {};
  
  static bool canRequest(String endpoint) {
    final now = DateTime.now();
    final key = '${endpoint}_${now.minute}';
    final count = _requestCounts[key] ?? 0;
    
    if (count > 60) return false; // 每分钟最多60次
    
    _requestCounts[key] = count + 1;
    return true;
  }
}
```

### 6.2 性能优化

```dart
// ============================================================
// 性能优化策略
// ============================================================

// 1. 成就数据本地缓存
class AchievementCache {
  static const String CACHE_KEY = 'achievements_cache';
  static const Duration CACHE_TTL = Duration(hours: 24);
  
  Future<List<Achievement>> getCachedAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(CACHE_KEY);
    final cachedTime = prefs.getInt('${CACHE_KEY}_time') ?? 0;
    
    if (cached != null && DateTime.now().millisecondsSinceEpoch - cachedTime < CACHE_TTL.inMilliseconds) {
      return (jsonDecode(cached) as List).map((e) => Achievement.fromJson(e)).toList();
    }
    return [];
  }
}

// 2. 推荐结果预加载
class RecommendationPreloader {
  Future<void> preloadRecommendations(Location location) async {
    // 在首页加载完成后，后台预加载推荐数据
    final recommendations = await RecommendationService.getRecommendations(
      lat: location.latitude,
      lng: location.longitude,
    );
    
    // 缓存到本地
    await cacheRecommendations(recommendations);
  }
}

// 3. 图片懒加载与缓存
class BadgeImageCache {
  static final Map<String, Image> _memoryCache = {};
  
  static Widget loadBadge(String url) {
    if (_memoryCache.containsKey(url)) {
      return _memoryCache[url]!;
    }
    
    return CachedNetworkImage(
      imageUrl: url,
      placeholder: (context, url) => BadgePlaceholder(),
      errorWidget: (context, url, error) => BadgeError(),
      memCacheWidth: 200, // 限制内存缓存大小
    );
  }
}

// 4. 大列表优化
class AchievementList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: achievements.length,
      itemBuilder: (context, index) => AchievementCard(achievements[index]),
      // 使用 const 构造器减少重建
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: false,
      cacheExtent: 100,
    );
  }
}
```

---

## 7. 附录

### 7.1 技术选型说明

| 技术 | 选择 | 理由 |
|------|------|------|
| 本地存储 | SharedPreferences + SQLite | 简单配置用 SP，复杂数据用 SQLite |
| 图片缓存 | cached_network_image | 成熟的 Flutter 图片缓存方案 |
| 分享功能 | share_plus + path_provider | 支持多平台分享 |
| 权限管理 | permission_handler | 统一的权限申请接口 |
| 动画 | flutter_animate | 流畅的成就解锁动画 |

### 7.2 兼容性说明

| 项目 | M4 兼容 | 说明 |
|------|---------|------|
| 数据库 | ✅ | 新增表不影响已有数据 |
| API | ✅ | 新增接口，不修改已有接口 |
| 客户端 | ✅ | 新增模块，不影响已有页面 |
| 用户数据 | ✅ | 用户轨迹等核心数据不变 |

### 7.3 风险评估

| 风险 | 等级 | 应对措施 |
|------|------|----------|
| 成就计算错误 | 中 | 增加校验机制，支持手动修正 |
| 推荐算法效果差 | 低 | V1 规则版先上线，逐步迭代 |
| 权限申请被拒 | 中 | 提供降级方案，引导用户开启 |
| 数据同步冲突 | 低 | 时间戳+版本号解决冲突 |

### 7.4 变更记录

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2026-03-19 | 初始版本，完成 M5 技术架构设计 | Dev Agent |

---

> **文档说明**: 本文档作为 M5 阶段技术规划的交付物，包含完整的架构设计、数据库 Schema、API 定义和客户端设计。
