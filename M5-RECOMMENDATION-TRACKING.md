# M5 推荐算法效果埋点文档

## 一、埋点概述

### 1.1 埋点目的
- 追踪推荐算法效果
- 分析用户行为偏好
- 优化推荐排序策略
- 支持 A/B 测试

### 1.2 埋点范围
| 类型 | 说明 | 数量 |
|------|------|------|
| 曝光埋点 | 推荐列表展示 | 1 |
| 点击埋点 | 推荐项点击 | 1 |
| 行为埋点 | 收藏/完成等 | 2 |
| 反馈埋点 | 用户反馈记录 | 1 |

---

## 二、埋点事件详情

### 2.1 recommendation_view（推荐曝光）

**触发时机:**
- 首页推荐卡片展示
- 推荐列表页面展示

**事件参数:**
```json
{
  "event": "recommendation_view",
  "params": {
    "scene": "home|list|similar|nearby",
    "algorithm": "v1_rule_based",
    "log_id": "rec_log_uuid",
    "trail_count": 10,
    "trail_ids": ["trail_001", "trail_002"],
    "match_scores": [89, 76]
  }
}
```

### 2.2 recommendation_click（推荐点击）

**触发时机:**
- 用户点击推荐路线卡片

**事件参数:**
```json
{
  "event": "recommendation_click",
  "params": {
    "scene": "home|list|similar|nearby",
    "trail_id": "trail_001",
    "position": 0,
    "match_score": 89,
    "match_factors": {
      "difficulty": 90,
      "distance": 95,
      "rating": 96,
      "popularity": 90,
      "freshness": 67
    },
    "log_id": "rec_log_uuid",
    "recommend_reason": "距离你2.5公里"
  }
}
```

### 2.3 recommendation_bookmark（推荐收藏）

**触发时机:**
- 用户从推荐列表收藏路线

**事件参数:**
```json
{
  "event": "recommendation_bookmark",
  "params": {
    "scene": "home",
    "trail_id": "trail_001",
    "match_score": 89,
    "log_id": "rec_log_uuid"
  }
}
```

### 2.4 recommendation_complete（推荐完成）

**触发时机:**
- 用户完成从推荐进入的路线

**事件参数:**
```json
{
  "event": "recommendation_complete",
  "params": {
    "scene": "home",
    "trail_id": "trail_001",
    "match_score": 89,
    "log_id": "rec_log_uuid",
    "duration_min": 120
  }
}
```

### 2.5 recommendation_feedback（显式反馈）

**触发时机:**
- 用户点击"不感兴趣"
- 用户点击"相似推荐"

**事件参数:**
```json
{
  "event": "recommendation_feedback",
  "params": {
    "trail_id": "trail_001",
    "feedback_type": "not_interested|similar",
    "log_id": "rec_log_uuid"
  }
}
```

---

## 三、效果评估指标

### 3.1 核心指标

| 指标 | 计算公式 | 目标值 | 采集方式 |
|------|----------|--------|----------|
| 曝光点击率 (CTR) | 点击数 / 曝光数 | > 20% | recommendation_click / recommendation_view |
| 推荐完成率 | 完成数 / 点击数 | > 40% | recommendation_complete / recommendation_click |
| 推荐收藏率 | 收藏数 / 点击数 | > 15% | recommendation_bookmark / recommendation_click |
| 平均匹配度 | 点击项匹配分数均值 | > 75 | AVG(match_score) |

### 3.2 算法效果指标

| 指标 | 说明 | 计算方式 |
|------|------|----------|
| 因子相关性 | 各因子与点击的关系 | 点击项 vs 未点击项因子对比 |
| 多样性评分 | 推荐结果多样性 | 难度/距离/标签分布熵 |
| 新鲜度曝光 | 新路线占比 | 新鲜度 > 0.7 的占比 |
| 冷启动转化率 | 新用户点击转化 | 冷启动用户 CTR |

---

## 四、数据上报方式

### 4.1 客户端上报
```dart
// 使用现有的 AnalyticsService
AnalyticsService().logEvent(
  name: 'recommendation_click',
  parameters: {
    'trail_id': trail.id,
    'match_score': trail.matchScore,
    'position': index,
  },
);
```

### 4.2 服务端记录
- 推荐日志表 (recommendation_logs) 记录每次推荐
- 用户交互表 (user_trail_interactions) 记录行为
- 支持通过 log_id 关联曝光和点击

---

## 五、数据分析维度

### 5.1 按场景分析
- 首页推荐 vs 附近推荐 CTR 对比
- 不同场景的完成率差异

### 5.2 按因子分析
- 各因子与点击率的相关性
- 最优因子权重调整方向

### 5.3 按用户分群
- 冷启动用户 vs 老用户转化差异
- 不同难度偏好用户的点击率

### 5.4 时间维度
- 每日推荐效果趋势
- 周中 vs 周末推荐效果

---

## 六、监控告警

### 6.1 监控项
| 监控项 | 阈值 | 告警级别 |
|--------|------|----------|
| 推荐接口失败率 | > 5% | P1 |
| 推荐平均响应时间 | > 500ms | P2 |
| CTR 日环比下降 | > 30% | P1 |
| 缓存命中率 | < 70% | P2 |

### 6.2 告警方式
- 飞书群机器人通知
- 邮件通知

---

## 七、埋点实现检查清单

### 后端
- [x] recommendation_logs 表创建
- [x] 推荐结果写入日志
- [x] 用户反馈接口
- [x] 埋点数据聚合查询接口

### 客户端
- [x] 推荐卡片曝光埋点
- [x] 推荐点击埋点
- [x] 推荐收藏埋点
- [x] log_id 传递追踪

---

## 八、附录

### 8.1 数据库查询示例

```sql
-- 计算 CTR
SELECT 
  DATE(created_at) as date,
  COUNT(DISTINCT CASE WHEN user_action IS NOT NULL THEN id END) * 1.0 / 
  COUNT(DISTINCT id) as ctr
FROM recommendation_logs
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at);

-- 各因子与点击率的相关性
SELECT 
  AVG((results -> 0 -> 'factors' ->> 'difficultyMatch')::float) as avg_difficulty_click,
  AVG((results -> 0 -> 'factors' ->> 'distance')::float) as avg_distance_click
FROM recommendation_logs
WHERE user_action = 'click'
  AND created_at > NOW() - INTERVAL '7 days';
```