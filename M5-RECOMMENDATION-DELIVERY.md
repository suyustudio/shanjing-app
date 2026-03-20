# M5 路线推荐算法 V1 开发交付报告

**日期:** 2026-03-20  
**开发者:** Dev Agent  
**状态:** ✅ 已完成

---

## 一、交付物清单

### 1. 数据库迁移文件
| 文件 | 路径 | 说明 |
|------|------|------|
| 迁移脚本 | `shanjing-api/prisma/migrations/20250320000000_add_recommendation_tables/migration.sql` | 包含用户画像表、推荐日志表、用户交互表 |
| Schema更新 | `shanjing-api/prisma/schema.prisma` | 新增模型定义 |

**新增表:**
- `user_profiles` - 用户画像表（偏好、统计、向量）
- `recommendation_logs` - 推荐日志表（上下文、结果、反馈）
- `user_trail_interactions` - 用户路线交互表（点击、收藏、完成）

### 2. 后端 API 代码
| 文件 | 路径 | 说明 |
|------|------|------|
| 控制器 | `shanjing-api/src/modules/recommendation/recommendation.controller.ts` | REST API 接口 |
| 服务主文件 | `shanjing-api/src/modules/recommendation/services/recommendation.service.ts` | 推荐业务逻辑 |
| 算法服务 | `shanjing-api/src/modules/recommendation/services/recommendation-algorithm.service.ts` | 5因子排序算法 |
| 用户画像服务 | `shanjing-api/src/modules/recommendation/services/user-profile.service.ts` | 画像计算更新 |
| DTO | `shanjing-api/src/modules/recommendation/dto/recommendation.dto.ts` | 数据类型定义 |
| 模块 | `shanjing-api/src/modules/recommendation/recommendation.module.ts` | NestJS 模块 |
| Redis服务 | `shanjing-api/src/shared/redis/redis.service.ts` | 缓存服务 |

**API 接口:**
```
GET  /api/recommendations?scene=home&lat=30.25&lng=120.15&limit=10
POST /api/recommendations/feedback
```

### 3. 推荐算法服务代码
**5因子排序算法实现:**
- 难度匹配 (25%): 与用户历史选择难度的匹配度
- 距离 (20%): 与用户当前位置的距离
- 评分 (20%): 路线综合评分
- 热度 (20%): 近期完成数 + 收藏数
- 新鲜度 (15%): 路线上线时间

**冷启动策略:**
- 新用户：使用热门路线
- 新路线：保护期内热度保底分0.5

**缓存策略:**
- 推荐结果缓存5分钟
- 用户反馈后自动清除缓存

### 4. 客户端推荐组件
| 文件 | 路径 | 说明 |
|------|------|------|
| 数据模型 | `lib/models/recommendation_model.dart` | RecommendedTrail, MatchFactors |
| 推荐服务 | `lib/services/recommendation_service.dart` | API调用、缓存管理、埋点 |
| 推荐卡片 | `lib/presentation/widgets/recommendations/recommendation_card.dart` | UI组件 |
| 推荐页面 | `lib/presentation/screens/recommendation_screen.dart` | "为你推荐"页面 |
| 定位服务 | `lib/services/location_service.dart` | 位置获取 |

### 5. 算法效果埋点
| 文件 | 路径 | 说明 |
|------|------|------|
| 埋点文档 | `M5-RECOMMENDATION-TRACKING.md` | 埋点事件、指标、分析维度 |

**埋点事件:**
- `recommendation_view` - 推荐曝光
- `recommendation_click` - 推荐点击
- `recommendation_bookmark` - 推荐收藏
- `recommendation_complete` - 推荐完成
- `recommendation_feedback` - 显式反馈

---

## 二、API 使用示例

### 获取推荐
```typescript
// 请求
GET /api/recommendations?scene=home&lat=30.25&lng=120.15&limit=10

// 响应
{
  "success": true,
  "data": {
    "algorithm": "v1_rule_based",
    "scene": "home",
    "logId": "uuid",
    "trails": [
      {
        "id": "trail_001",
        "name": "九溪十八涧",
        "coverImage": "...",
        "distanceKm": 8.5,
        "durationMin": 180,
        "difficulty": "MODERATE",
        "rating": 4.8,
        "matchScore": 89,
        "matchFactors": {
          "difficultyMatch": 90,
          "distance": 95,
          "rating": 96,
          "popularity": 90,
          "freshness": 67
        },
        "recommendReason": "距离你2.5公里，符合你的难度偏好"
      }
    ]
  }
}
```

### 记录反馈
```typescript
// 请求
POST /api/recommendations/feedback
{
  "action": "click",
  "trailId": "trail_001",
  "logId": "uuid",
  "durationSec": 30
}

// 响应
{ "success": true }
```

---

## 三、客户端使用示例

```dart
// 获取首页推荐
final recommendations = await RecommendationService().getHomeRecommendations(
  limit: 10,
  lat: 30.25,
  lng: 120.15,
);

// 使用推荐卡片
RecommendationHorizontalList(
  trails: recommendations,
  title: '为你推荐',
  onViewAllTap: () => Navigator.pushNamed(context, '/recommendations'),
  onTrailTap: (trail) => _onTrailTap(trail),
)

// 记录点击（自动追踪）
_recommendationService.trackClick(
  trailId: trail.id,
  logId: _recommendationService.getCachedLogId(),
);
```

---

## 四、技术实现要点

### 后端
1. ✅ 5因子加权评分算法实现
2. ✅ 冷启动处理（热门路线兜底）
3. ✅ 结果缓存（Redis，5分钟TTL）
4. ✅ 用户画像自动更新
5. ✅ 埋点数据持久化

### 客户端
1. ✅ 推荐结果本地缓存
2. ✅ 推荐卡片UI组件
3. ✅ 推荐页面完整实现
4. ✅ 用户行为自动追踪
5. ✅ log_id 传递机制

---

## 五、后续优化方向

### V1.1 优化项
- [ ] A/B 测试框架
- [ ] 权重动态调整
- [ ] 推荐结果去重
- [ ] 更多推荐场景

### V2.0 规划
- [ ] 协同过滤算法
- [ ] 深度学习模型
- [ ] 实时推荐流
- [ ] 个性化推荐解释

---

## 六、部署检查清单

### 后端部署
- [ ] 执行数据库迁移
- [ ] 安装 Redis（如使用真实Redis）
- [ ] 部署 NestJS 服务
- [ ] 配置环境变量

### 客户端部署
- [ ] 运行 `flutter pub get`
- [ ] 确保 API 地址配置正确
- [ ] 测试推荐功能

---

**交付完成时间:** 2026-03-20 17:01 GMT+8