# M5 成就系统集成文档

> **文档版本**: v1.0  
> **制定日期**: 2026-03-20  
> **对应阶段**: M5 - 体验优化阶段

---

## 目录

1. [概述](#1-概述)
2. [数据库迁移](#2-数据库迁移)
3. [后端 API](#3-后端-api)
4. [客户端集成](#4-客户端集成)
5. [触发点集成](#5-触发点集成)
6. [测试验证](#6-测试验证)

---

## 1. 概述

### 1.1 功能概述

成就系统为山径 App 提供游戏化激励功能，包括：

- **5类成就**: 探索、里程、频率、挑战、社交
- **4级等级**: 铜、银、金、钻石
- **实时解锁**: 轨迹完成/分享时自动检查并解锁
- **徽章墙**: 展示用户所有成就状态

### 1.2 系统架构

```
┌─────────────────────────────────────────────────────────────┐
│                        客户端 (Flutter)                      │
│  ┌─────────────────┐  ┌─────────────────┐  ┌──────────────┐ │
│  │ AchievementScreen│  │AchievementService│  │ UnlockDialog │ │
│  └─────────────────┘  └─────────────────┘  └──────────────┘ │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ HTTPS
┌─────────────────────────────────────────────────────────────┐
│                      后端 (NestJS)                           │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              AchievementsModule                        │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌───────────────┐  │  │
│  │  │ Controller  │  │   Service   │  │     DTOs      │  │  │
│  │  └─────────────┘  └─────────────┘  └───────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      数据库 (PostgreSQL)                     │
│  ┌──────────────┐ ┌──────────────┐ ┌──────────────────────┐ │
│  │ achievements │ │user_achievements│ │     user_stats      │ │
│  └──────────────┘ └──────────────┘ └──────────────────────┘ │
└─────────────────────────────────────────────────────────────┘
```

---

## 2. 数据库迁移

### 2.1 执行迁移

```bash
# 1. 进入后端目录
cd shanjing-api

# 2. 生成 Prisma Client
npx prisma generate

# 3. 执行数据库迁移
npx prisma migrate dev --name add_m5_achievements

# 4. 导入种子数据
npx prisma db execute --file ./prisma/seed_achievements.sql
```

### 2.2 回滚迁移

```bash
# 如需回滚，执行回滚脚本
npx prisma migrate resolve --rolled-back add_m5_achievements
```

### 2.3 数据库表说明

| 表名 | 说明 | 关键字段 |
|------|------|----------|
| `achievements` | 成就定义表 | `key`, `category`, `is_hidden` |
| `achievement_levels` | 成就等级定义表 | `achievement_id`, `level`, `requirement` |
| `user_achievements` | 用户成就记录表 | `user_id`, `achievement_id`, `level_id` |
| `user_stats` | 用户统计表 | `total_distance_m`, `unique_trails_count` |

---

## 3. 后端 API

### 3.1 API 列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/api/achievements` | 获取所有成就定义 | 是 |
| GET | `/api/achievements/user/me` | 获取当前用户成就 | 是 |
| GET | `/api/achievements/user/:userId` | 获取指定用户成就 | 是 |
| POST | `/api/achievements/check` | 检查并解锁成就 | 是 |
| PUT | `/api/achievements/:id/viewed` | 标记成就已查看 | 是 |
| PUT | `/api/achievements/viewed/all` | 标记所有成就已查看 | 是 |
| GET | `/api/users/me/stats` | 获取用户统计 | 是 |

### 3.2 核心 API 示例

#### 获取用户成就

```http
GET /api/achievements/user/me
Authorization: Bearer {token}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "totalCount": 6,
    "unlockedCount": 3,
    "newUnlockedCount": 1,
    "achievements": [
      {
        "achievementId": "ach-1",
        "key": "explorer",
        "name": "路线收集家",
        "category": "EXPLORER",
        "currentLevel": "初级探索者",
        "currentProgress": 8,
        "nextRequirement": 15,
        "percentage": 60,
        "unlockedAt": "2026-03-15T08:00:00Z",
        "isNew": false,
        "isUnlocked": true
      }
    ]
  }
}
```

#### 检查并解锁成就

```http
POST /api/achievements/check
Authorization: Bearer {token}
Content-Type: application/json

{
  "triggerType": "trail_completed",
  "trailId": "trail-001",
  "stats": {
    "distance": 8500,
    "duration": 7200,
    "isNight": false,
    "isRain": false,
    "isSolo": true
  }
}
```

**响应:**
```json
{
  "success": true,
  "data": {
    "newlyUnlocked": [
      {
        "achievementId": "ach-1",
        "level": "SILVER",
        "name": "资深行者",
        "message": "恭喜升级！你已达到路线收集家 - 资深行者",
        "badgeUrl": "https://cdn.shanjing.app/badges/explorer_silver.png"
      }
    ],
    "progressUpdated": []
  }
}
```

---

## 4. 客户端集成

### 4.1 服务层调用

在 Flutter 客户端调用成就服务：

```dart
// 1. 导入服务
import 'package:shanjing/services/achievement_service.dart';

// 2. 获取用户成就
final achievements = await AchievementService.instance.getUserAchievements();

// 3. 检查并解锁成就（轨迹完成后调用）
final result = await AchievementService.instance.checkAchievements(
  triggerType: 'trail_completed',
  trailId: completedTrailId,
  stats: TrailStats(
    distance: recordedDistance,
    duration: recordedDuration,
    isNight: isNightHike,
    isRain: isRainyWeather,
    isSolo: isSoloHike,
  ),
);

// 4. 显示解锁弹窗
if (result.newlyUnlocked.isNotEmpty) {
  showAchievementUnlockDialog(result.newlyUnlocked.first);
}
```

### 4.2 徽章墙页面

```dart
// 跳转到徽章墙页面
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => const AchievementScreen()),
);
```

---

## 5. 触发点集成

### 5.1 导航完成时检查成就

在 `NavigationScreen` 的轨迹完成回调中添加：

```dart
void onTrailCompleted(TrailRecord record) async {
  // ... 原有代码 ...
  
  // 检查成就解锁
  final achievementService = AchievementService.instance;
  final result = await achievementService.checkAchievements(
    triggerType: 'trail_completed',
    trailId: record.trailId,
    stats: TrailStats(
      distance: record.totalDistanceM,
      duration: record.totalDurationSec,
      isNight: record.isNightHike,
      isRain: record.isRainyWeather,
      isSolo: record.isSoloHike,
    ),
  );
  
  // 显示解锁动画
  if (result.newlyUnlocked.isNotEmpty && mounted) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AchievementUnlockDialog(
        achievement: result.newlyUnlocked.first,
      ),
    );
  }
}
```

### 5.2 收藏路线时检查成就

```dart
void onFavoriteTrail(String trailId) async {
  // ... 原有代码 ...
  
  // 收藏行为不直接触发成就，但可以作为统计
  await AchievementService.instance.checkAchievements(
    triggerType: 'manual',
  );
}
```

### 5.3 分享功能触发成就

```dart
void onShareTrail(Trail trail) async {
  // ... 原有分享代码 ...
  
  // 触发分享成就检查
  final result = await AchievementService.instance.checkAchievements(
    triggerType: 'share',
  );
  
  if (result.newlyUnlocked.isNotEmpty) {
    // 显示解锁提示
  }
}
```

---

## 6. 测试验证

### 6.1 单元测试

```bash
# 运行成就系统单元测试
cd shanjing-api
npm test -- achievements
```

### 6.2 接口测试

使用 curl 或 Postman 测试：

```bash
# 获取成就列表
curl -X GET http://localhost:3000/api/achievements \
  -H "Authorization: Bearer YOUR_TOKEN"

# 检查成就
curl -X POST http://localhost:3000/api/achievements/check \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "triggerType": "trail_completed",
    "stats": {
      "distance": 5000,
      "duration": 3600,
      "isNight": false,
      "isRain": false,
      "isSolo": true
    }
  }'
```

### 6.3 验收检查清单

- [ ] 数据库表创建成功
- [ ] 种子数据导入成功
- [ ] API 响应正确
- [ ] 成就解锁逻辑正确
- [ ] 进度计算准确
- [ ] 并发情况下不重复解锁

---

## 附录

### A. 成就配置对照表

| 成就类别 | 成就名称 | 铜 | 银 | 金 | 钻石 |
|----------|----------|----|----|-----|-------|
| EXPLORER | 路线收集家 | 5条 | 15条 | 30条 | 50条 |
| DISTANCE | 行者无疆 | 10km | 50km | 100km | 500km |
| FREQUENCY | 周行者 | 2周 | 4周 | 8周 | 16周 |
| CHALLENGE | 夜行者 | 1次 | 5次 | 10次 | 20次 |
| SOCIAL | 分享达人 | 1次 | 5次 | 10次 | 20次 |

### B. 相关文档

- [M5-PRD-ACHIEVEMENT.md](./M5-PRD-ACHIEVEMENT.md) - 成就系统 PRD
- [M5-DATABASE-SCHEMA.md](./M5-DATABASE-SCHEMA.md) - 数据库设计
- [M5-TECH-ARCHITECTURE.md](./M5-TECH-ARCHITECTURE.md) - 技术架构
