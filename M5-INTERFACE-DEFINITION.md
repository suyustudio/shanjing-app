# M5 功能模块接口定义

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **文档状态**: 接口定义  
> **对应阶段**: M5 - 体验优化阶段

---

## 目录

1. [概述](#1-概述)
2. [新手引导模块](#2-新手引导模块)
3. [成就系统模块](#3-成就系统模块)
4. [路线推荐模块](#4-路线推荐模块)
5. [用户统计模块](#5-用户统计模块)
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

## 2. 新手引导模块

### 2.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/config/onboarding` | 获取引导配置 | 是 |
| PUT | `/config/onboarding` | 更新引导状态 | 是 |

### 2.2 获取引导配置

```yaml
GET /api/v1/config/onboarding

Description: 获取当前用户的新手引导配置和状态

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    completed: boolean          # 是否已完成引导
    completedAt: string|null    # ISO 8601 完成时间
    currentStep: number         # 当前步骤（0-4）
    skipped: boolean            # 是否已跳过
    version: string             # 引导版本号

Response 401:
  success: false
  error:
    code: "UNAUTHORIZED"
    message: "未提供有效的认证信息"
```

### 2.3 更新引导状态

```yaml
PUT /api/v1/config/onboarding

Description: 更新用户的新手引导状态

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  completed: boolean            # 是否完成
  currentStep: number           # 当前步骤
  skipped: boolean              # 是否跳过

Response 200:
  success: true
  data:
    completed: boolean
    completedAt: string         # ISO 8601 时间
    currentStep: number
    skipped: boolean

Response 400:
  success: false
  error:
    code: "INVALID_PARAMS"
    message: "参数错误"
    details:
      field: "currentStep"
      message: "currentStep 必须在 0-4 之间"

Response 401:
  success: false
  error:
    code: "UNAUTHORIZED"
    message: "未提供有效的认证信息"
```

### 2.4 客户端服务接口

```dart
// ============================================================
// OnboardingService
// ============================================================

abstract class OnboardingService {
  /// 检查是否需要显示新手引导
  /// 
  /// 检查逻辑：
  /// 1. 本地未完成且不跳过
  /// 2. 服务端 completed = false
  /// 
  /// Returns: true 表示需要显示引导
  Future<bool> shouldShowOnboarding();
  
  /// 获取当前引导步骤
  /// 
  /// Returns: 当前步骤（0-4），0 表示未开始
  Future<int> getCurrentStep();
  
  /// 更新当前步骤
  /// 
  /// [step] 当前步骤（0-4）
  /// 
  /// 同时更新本地缓存和服务端
  Future<void> updateStep(int step);
  
  /// 标记引导完成
  /// 
  /// 更新本地缓存和服务端状态
  /// 记录完成时间
  Future<void> markCompleted();
  
  /// 标记引导跳过
  /// 
  /// 用户选择跳过时调用
  Future<void> markSkipped();
  
  /// 重置引导状态
  /// 
  /// 用于测试或重新触发引导
  Future<void> reset();
  
  /// 检查权限状态
  /// 
  /// [type] 权限类型
  Future<PermissionStatus> checkPermission(PermissionType type);
  
  /// 请求权限
  /// 
  /// [type] 权限类型
  /// 
  /// Returns: true 表示权限已授予
  Future<bool> requestPermission(PermissionType type);
}

enum PermissionType {
  location,       // 位置权限
  storage,        // 存储权限
  notification,   // 通知权限
  camera,         // 相机权限（拍照）
}

enum PermissionStatus {
  granted,        // 已授权
  denied,         // 已拒绝
  permanentlyDenied, // 永久拒绝
  restricted,     // 受限（iOS）
  limited,        // 有限授权（iOS 14+ 位置）
}
```

---

## 3. 成就系统模块

### 3.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/achievements` | 获取所有成就定义 | 是 |
| GET | `/achievements/user` | 获取用户成就 | 是 |
| POST | `/achievements/check` | 检查并解锁成就 | 是 |
| PUT | `/achievements/:id/viewed` | 标记成就已查看 | 是 |

### 3.2 获取所有成就定义

```yaml
GET /api/v1/achievements

Description: 获取所有成就的定义信息（等级、条件等）

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    - id: string              # 成就ID
      key: string             # 成就标识符
      name: string            # 显示名称
      description: string     # 成就描述
      category: string        # 类别: explorer|distance|frequency|challenge|social
      iconUrl: string         # 图标URL
      isHidden: boolean       # 是否隐藏成就
      sortOrder: number       # 排序权重
      levels:                 # 等级定义
        - level: string       # bronze|silver|gold|diamond
          requirement: number # 达成条件数值
          name: string        # 等级名称
          description: string # 等级描述
          iconUrl: string     # 等级图标URL

Response Example:
  {
    "success": true,
    "data": [
      {
        "id": "ach_explorer",
        "key": "explorer",
        "name": "路线收集家",
        "description": "探索不同的徒步路线，收集你的足迹",
        "category": "explorer",
        "iconUrl": "https://cdn.shanjing.app/badges/explorer.png",
        "isHidden": false,
        "sortOrder": 1,
        "levels": [
          {
            "level": "bronze",
            "requirement": 5,
            "name": "初级探索者",
            "description": "完成5条不同路线",
            "iconUrl": "https://cdn.shanjing.app/badges/explorer_bronze.png"
          },
          {
            "level": "silver",
            "requirement": 15,
            "name": "资深行者",
            "description": "完成15条不同路线",
            "iconUrl": "https://cdn.shanjing.app/badges/explorer_silver.png"
          },
          {
            "level": "gold",
            "requirement": 30,
            "name": "山野达人",
            "description": "完成30条不同路线",
            "iconUrl": "https://cdn.shanjing.app/badges/explorer_gold.png"
          },
          {
            "level": "diamond",
            "requirement": 50,
            "name": "路线收藏家",
            "description": "完成50条不同路线",
            "iconUrl": "https://cdn.shanjing.app/badges/explorer_diamond.png"
          }
        ]
      }
    ]
  }
```

### 3.3 获取用户成就

```yaml
GET /api/v1/achievements/user

Description: 获取当前用户的成就解锁状态和进度

Request Headers:
  Authorization: Bearer {token}

Query Parameters:
  includeHidden: boolean    # 是否包含隐藏成就（默认false）

Response 200:
  success: true
  data:
    totalCount: number          # 总成就数
    unlockedCount: number       # 已解锁成就数
    newUnlockedCount: number    # 新解锁未查看数
    achievements:
      - achievementId: string   # 成就ID
        key: string             # 成就标识
        name: string            # 成就名称
        category: string        # 类别
        currentLevel: string    # 当前等级（null表示未解锁）
        currentProgress: number # 当前进度值
        nextRequirement: number # 下一等级要求
        percentage: number      # 进度百分比（0-100）
        unlockedAt: string|null # 解锁时间
        isNew: boolean          # 是否新解锁未查看

Response Example:
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
          "percentage": 60,
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
          "percentage": 25,
          "unlockedAt": "2026-03-19T10:30:00Z",
          "isNew": true
        }
      ]
    }
  }
```

### 3.4 检查并解锁成就

```yaml
POST /api/v1/achievements/check

Description: 检查是否满足成就解锁条件，触发解锁
            通常在轨迹完成、分享等行为后调用

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  triggerType: string         # 触发类型: trail_completed|share|manual
  trailId: string|null        # 路线ID（trail_completed时必填）
  stats:                      # 轨迹统计（trail_completed时）
    distance: number          # 距离（米）
    duration: number          # 时长（秒）
    isNight: boolean          # 是否夜间
    isRain: boolean           # 是否雨天
    isSolo: boolean           # 是否独自

Request Example:
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

Response 200:
  success: true
  data:
    newlyUnlocked:              # 新解锁的成就
      - achievementId: string
        level: string
        name: string
        message: string         # 祝贺消息
        badgeUrl: string        # 徽章图片URL
    progressUpdated:            # 进度更新的成就
      - achievementId: string
        progress: number
        requirement: number
        percentage: number

Response Example:
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

Response 400:
  success: false
  error:
    code: "INVALID_TRIGGER_TYPE"
    message: "无效的触发类型"
```

### 3.5 标记成就已查看

```yaml
PUT /api/v1/achievements/{id}/viewed

Description: 将成就标记为已查看，清除isNew标记

Path Parameters:
  id: string          # 成就ID

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    achievementId: string
    isNew: false

Response 404:
  success: false
  error:
    code: "ACHIEVEMENT_NOT_FOUND"
    message: "成就不存在"
```

### 3.6 客户端服务接口

```dart
// ============================================================
// AchievementService
// ============================================================

abstract class AchievementService {
  /// 获取所有成就定义
  /// 
  /// 通常缓存到本地，不频繁请求
  Future<List<Achievement>> getAllAchievements();
  
  /// 获取用户成就列表
  /// 
  /// [includeHidden] 是否包含隐藏成就
  Future<UserAchievementSummary> getUserAchievements({bool includeHidden = false});
  
  /// 检查并解锁成就
  /// 
  /// 在轨迹完成时调用，自动检查并解锁满足条件的成就
  /// 
  /// [triggerType] 触发类型
  /// [trailId] 路线ID（trail_completed时）
  /// [stats] 轨迹统计（trail_completed时）
  /// 
  /// Returns: 新解锁的成就和进度更新
  Future<AchievementCheckResult> checkAchievements({
    required String triggerType,
    String? trailId,
    TrailStats? stats,
  });
  
  /// 获取单个成就的进度
  /// 
  /// [achievementId] 成就ID
  /// 
  /// Returns: 进度百分比（0-100）
  Future<double> getAchievementProgress(String achievementId);
  
  /// 标记成就已查看
  /// 
  /// 用户查看成就详情后调用，清除isNew标记
  Future<void> markAchievementViewed(String achievementId);
  
  /// 生成成就分享图片
  /// 
  /// [achievement] 要分享的成就
  /// 
  /// Returns: 图片的本地路径
  Future<String> generateShareImage(Achievement achievement);
  
  /// 新成就解锁事件流
  /// 
  /// 用于显示解锁动画
  Stream<Achievement> get onAchievementUnlocked;
}

// ============================================================
// 数据模型
// ============================================================

class Achievement {
  final String id;
  final String key;
  final String name;
  final String description;
  final AchievementCategory category;
  final String? iconUrl;
  final bool isHidden;
  final int sortOrder;
  final List<AchievementLevel> levels;
  
  Achievement({
    required this.id,
    required this.key,
    required this.name,
    required this.description,
    required this.category,
    this.iconUrl,
    this.isHidden = false,
    this.sortOrder = 0,
    required this.levels,
  });
}

class AchievementLevel {
  final AchievementLevelType level;
  final int requirement;
  final String name;
  final String? description;
  final String? iconUrl;
  
  AchievementLevel({
    required this.level,
    required this.requirement,
    required this.name,
    this.description,
    this.iconUrl,
  });
}

enum AchievementCategory {
  explorer,   // 探索类
  distance,   // 里程类
  frequency,  // 频率类
  challenge,  // 挑战类
  social,     // 社交类
}

enum AchievementLevelType {
  bronze,     // 铜
  silver,     // 银
  gold,       // 金
  diamond,    // 钻石
}

class UserAchievementSummary {
  final int totalCount;
  final int unlockedCount;
  final int newUnlockedCount;
  final List<UserAchievement> achievements;
  
  UserAchievementSummary({
    required this.totalCount,
    required this.unlockedCount,
    required this.newUnlockedCount,
    required this.achievements,
  });
}

class UserAchievement {
  final String achievementId;
  final String key;
  final String name;
  final AchievementCategory category;
  final AchievementLevelType? currentLevel;
  final int currentProgress;
  final int nextRequirement;
  final double percentage;
  final DateTime? unlockedAt;
  final bool isNew;
  
  UserAchievement({
    required this.achievementId,
    required this.key,
    required this.name,
    required this.category,
    this.currentLevel,
    required this.currentProgress,
    required this.nextRequirement,
    required this.percentage,
    this.unlockedAt,
    this.isNew = false,
  });
}

class AchievementCheckResult {
  final List<NewlyUnlockedAchievement> newlyUnlocked;
  final List<ProgressUpdatedAchievement> progressUpdated;
  
  AchievementCheckResult({
    required this.newlyUnlocked,
    required this.progressUpdated,
  });
}

class NewlyUnlockedAchievement {
  final String achievementId;
  final AchievementLevelType level;
  final String name;
  final String message;
  final String badgeUrl;
  
  NewlyUnlockedAchievement({
    required this.achievementId,
    required this.level,
    required this.name,
    required this.message,
    required this.badgeUrl,
  });
}

class ProgressUpdatedAchievement {
  final String achievementId;
  final int progress;
  final int requirement;
  final double percentage;
  
  ProgressUpdatedAchievement({
    required this.achievementId,
    required this.progress,
    required this.requirement,
    required this.percentage,
  });
}

class TrailStats {
  final int distance;     // 米
  final int duration;     // 秒
  final bool isNight;
  final bool isRain;
  final bool isSolo;
  
  TrailStats({
    required this.distance,
    required this.duration,
    required this.isNight,
    required this.isRain,
    required this.isSolo,
  });
}
```

---

## 4. 路线推荐模块

### 4.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/recommendations` | 获取推荐路线 | 是 |
| POST | `/recommendations/track` | 记录用户行为 | 是 |

### 4.2 获取推荐路线

```yaml
GET /api/v1/recommendations

Description: 获取个性化的路线推荐列表

Request Headers:
  Authorization: Bearer {token}

Query Parameters:
  lat: number           # 当前纬度（必填）
  lng: number           # 当前经度（必填）
  limit: number         # 返回数量（默认10，最大20）
  algorithm: string     # 算法版本（可选，默认v2）

Response 200:
  success: true
  data:
    algorithm: string           # 使用的算法版本
    context:                    # 推荐上下文
      location:
        lat: number
        lng: number
      time: string              # ISO 8601
      weather: string           # 天气状况
    trails:
      - id: string              # 路线ID
        name: string            # 路线名称
        coverImage: string      # 封面图URL
        distanceKm: number      # 距离（公里）
        durationMin: number     # 预计时长（分钟）
        difficulty: string      # 难度: easy|moderate|hard
        score: number           # 推荐分数（0-100）
        matchFactors:           # 匹配因子得分
          location: number      # 地理位置（30%）
          difficulty: number    # 难度匹配（25%）
          preference: number    # 偏好匹配（20%）
          rating: number        # 路线评分（15%）
          freshness: number     # 新鲜度（10%）
        recommendReason: string # 推荐理由

Response Example:
  {
    "success": true,
    "data": {
      "algorithm": "scoring_v2",
      "context": {
        "location": {
          "lat": 30.25,
          "lng": 120.15
        },
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

Response 400:
  success: false
  error:
    code: "MISSING_PARAMS"
    message: "缺少必要参数: lat, lng"
```

### 4.3 记录用户行为

```yaml
POST /api/v1/recommendations/track

Description: 记录用户对推荐结果的交互行为，用于算法优化

Request Headers:
  Authorization: Bearer {token}
  Content-Type: application/json

Request Body:
  trailId: string           # 路线ID
  action: string            # 行为类型: click|view|bookmark|ignore|complete
  context:                  # 上下文（可选）
    recommendationId: string # 推荐ID
    position: number        # 列表位置
    timestamp: string       # 行为时间

Request Example:
  {
    "trailId": "trail_001",
    "action": "click",
    "context": {
      "position": 1,
      "timestamp": "2026-03-19T14:05:00Z"
    }
  }

Response 200:
  success: true
  data:
    tracked: true

Response 400:
  success: false
  error:
    code: "INVALID_ACTION"
    message: "无效的行为类型"
```

### 4.4 客户端服务接口

```dart
// ============================================================
// RecommendationService
// ============================================================

abstract class RecommendationService {
  /// 获取推荐路线
  /// 
  /// [lat] 当前纬度
  /// [lng] 当前经度
  /// [limit] 返回数量
  /// 
  /// Returns: 按推荐分数排序的路线列表
  Future<List<RecommendedTrail>> getRecommendations({
    required double lat,
    required double lng,
    int limit = 10,
  });
  
  /// 获取相似路线
  /// 
  /// 基于指定路线推荐相似路线
  /// 
  /// [trailId] 参考路线ID
  /// 
  /// Returns: 相似路线列表
  Future<List<RecommendedTrail>> getSimilarTrails(String trailId);
  
  /// 刷新推荐
  /// 
  /// 重新获取推荐，可能会返回不同的结果
  Future<List<RecommendedTrail>> refreshRecommendations();
  
  /// 记录用户行为
  /// 
  /// 用于算法优化和效果统计
  /// 
  /// [trailId] 路线ID
  /// [action] 用户行为
  Future<void> trackUserAction({
    required String trailId,
    required UserAction action,
  });
}

enum UserAction {
  click,      // 点击
  view,       // 查看详情
  bookmark,   // 收藏
  ignore,     // 忽略
  complete,   // 完成路线
}

class RecommendedTrail {
  final String id;
  final String name;
  final String coverImage;
  final double distanceKm;
  final int durationMin;
  final Difficulty difficulty;
  final double score;
  final MatchFactors matchFactors;
  final String? recommendReason;
  
  RecommendedTrail({
    required this.id,
    required this.name,
    required this.coverImage,
    required this.distanceKm,
    required this.durationMin,
    required this.difficulty,
    required this.score,
    required this.matchFactors,
    this.recommendReason,
  });
}

class MatchFactors {
  final double location;    // 地理位置匹配（0-100）
  final double difficulty;  // 难度匹配（0-100）
  final double preference;  // 偏好匹配（0-100）
  final double rating;      // 评分（0-100）
  final double freshness;   // 新鲜度（0-100）
  
  MatchFactors({
    required this.location,
    required this.difficulty,
    required this.preference,
    required this.rating,
    required this.freshness,
  });
  
  /// 计算加权总分
  double get weightedScore {
    return location * 0.30 +
           difficulty * 0.25 +
           preference * 0.20 +
           rating * 0.15 +
           freshness * 0.10;
  }
}

enum Difficulty {
  easy,
  moderate,
  hard,
}
```

---

## 5. 用户统计模块

### 5.1 接口列表

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| GET | `/users/me/stats` | 获取用户统计 | 是 |

### 5.2 获取用户统计

```yaml
GET /api/v1/users/me/stats

Description: 获取用户的徒步统计数据和成就进度

Request Headers:
  Authorization: Bearer {token}

Response 200:
  success: true
  data:
    lifetime:                   # 累计统计
      totalDistanceM: number    # 总距离（米）
      totalDurationSec: number  # 总时长（秒）
      totalElevationGainM: number # 总爬升（米）
      uniqueTrailsCount: number # 完成的不同路线数
      completedTrailIds: [string] # 已完成的路线ID列表
    streaks:                    # 连续记录
      currentWeekly: number     # 当前连续周数
      longestWeekly: number     # 最长连续周数
      currentMonthly: number    # 当前连续月数
      lastTrailDate: string|null # 上次徒步日期
    challenges:                 # 挑战统计
      nightTrailCount: number   # 夜间徒步次数
      rainTrailCount: number    # 雨天徒步次数
      soloTrailCount: number    # 独自徒步次数
    social:                     # 社交统计
      shareCount: number        # 分享次数
    profile:                    # 用户画像（用于推荐）
      avgDistanceKm: number     # 平均徒步距离
      avgDurationMin: number    # 平均徒步时长
      preferredDifficulty: string # 偏好难度
      preferredTags: [string]   # 偏好标签

Response Example:
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

### 5.3 客户端服务接口

```dart
// ============================================================
// UserStatsService
// ============================================================

abstract class UserStatsService {
  /// 获取用户统计
  Future<UserStats> getUserStats();
  
  /// 更新统计
  /// 
  /// 在轨迹完成后调用，自动更新相关统计数据
  /// 
  /// [record] 轨迹记录
  Future<void> updateStats(TrailRecord record);
  
  /// 获取连续打卡状态
  Future<StreakInfo> getStreakInfo();
  
  /// 统计更新事件流
  /// 
  /// 用于实时更新UI
  Stream<UserStats> get onStatsUpdated;
}

class UserStats {
  final LifetimeStats lifetime;
  final StreakInfo streaks;
  final ChallengeStats challenges;
  final SocialStats social;
  final UserProfile profile;
  
  UserStats({
    required this.lifetime,
    required this.streaks,
    required this.challenges,
    required this.social,
    required this.profile,
  });
}

class LifetimeStats {
  final int totalDistanceM;
  final int totalDurationSec;
  final double totalElevationGainM;
  final int uniqueTrailsCount;
  final List<String> completedTrailIds;
  
  LifetimeStats({
    required this.totalDistanceM,
    required this.totalDurationSec,
    required this.totalElevationGainM,
    required this.uniqueTrailsCount,
    required this.completedTrailIds,
  });
  
  double get totalDistanceKm => totalDistanceM / 1000;
  double get totalDurationHours => totalDurationSec / 3600;
}

class StreakInfo {
  final int currentWeekly;
  final int longestWeekly;
  final int currentMonthly;
  final DateTime? lastTrailDate;
  
  StreakInfo({
    required this.currentWeekly,
    required this.longestWeekly,
    required this.currentMonthly,
    this.lastTrailDate,
  });
  
  /// 检查今天是否已徒步
  bool get hasHikedToday {
    if (lastTrailDate == null) return false;
    final today = DateTime.now();
    return lastTrailDate!.year == today.year &&
           lastTrailDate!.month == today.month &&
           lastTrailDate!.day == today.day;
  }
}

class ChallengeStats {
  final int nightTrailCount;
  final int rainTrailCount;
  final int soloTrailCount;
  
  ChallengeStats({
    required this.nightTrailCount,
    required this.rainTrailCount,
    required this.soloTrailCount,
  });
}

class SocialStats {
  final int shareCount;
  
  SocialStats({
    required this.shareCount,
  });
}

class UserProfile {
  final double? avgDistanceKm;
  final double? avgDurationMin;
  final String? preferredDifficulty;
  final List<String> preferredTags;
  
  UserProfile({
    this.avgDistanceKm,
    this.avgDurationMin,
    this.preferredDifficulty,
    this.preferredTags = const [],
  });
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
| MISSING_PARAMS | 400 | 缺少参数 |
| SERVER_ERROR | 500 | 服务器错误 |
| ACHIEVEMENT_NOT_FOUND | 404 | 成就不存在 |
| INVALID_TRIGGER_TYPE | 400 | 无效的触发类型 |
| INVALID_ACTION | 400 | 无效的操作 |
| RATE_LIMIT | 429 | 请求过于频繁 |

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
示例: 2026-03-19T10:30:00Z
```

### 6.4 枚举值定义

```typescript
// 路线难度
enum Difficulty {
  EASY = 'easy',           // 简单
  MODERATE = 'moderate',   // 中等
  HARD = 'hard',           // 困难
}

// 成就类别
enum AchievementCategory {
  EXPLORER = 'explorer',     // 探索类
  DISTANCE = 'distance',     // 里程类
  FREQUENCY = 'frequency',   // 频率类
  CHALLENGE = 'challenge',   // 挑战类
  SOCIAL = 'social',         // 社交类
}

// 成就等级
enum AchievementLevel {
  BRONZE = 'bronze',       // 铜
  SILVER = 'silver',       // 银
  GOLD = 'gold',           // 金
  DIAMOND = 'diamond',     // 钻石
}

// 推荐算法版本
enum RecommendationAlgorithm {
  V1_RULES = 'rules_v1',       // 规则版
  V2_SCORING = 'scoring_v2',   // 5因子排序版
}

// 用户行为类型
enum UserAction {
  CLICK = 'click',           // 点击
  VIEW = 'view',             // 查看
  BOOKMARK = 'bookmark',     // 收藏
  IGNORE = 'ignore',         // 忽略
  COMPLETE = 'complete',     // 完成
}

// 成就触发类型
enum AchievementTriggerType {
  TRAIL_COMPLETED = 'trail_completed',  // 轨迹完成
  SHARE = 'share',                      // 分享
  MANUAL = 'manual',                    // 手动触发
}
```

---

> **文档说明**: 本文档定义了 M5 阶段所有功能模块的接口规范，包括 REST API 和客户端服务接口。
