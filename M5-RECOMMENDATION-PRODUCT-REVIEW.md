# M5 推荐算法 Product 评审报告

**评审日期:** 2026-03-20  
**评审对象:** Dev Agent 完成的推荐算法实现  
**参考文档:** M5-PRD-RECOMMENDATION.md  

---

## 一、评审结论概览

| 评审项 | 状态 | 说明 |
|--------|------|------|
| 算法逻辑 | ⚠️ 部分通过 | 5因子基本实现，但存在数值精度问题 |
| 性能要求 | ⚠️ 部分通过 | Redis缓存实现，但TTL配置需优化 |
| 埋点追踪 | ⚠️ 部分通过 | 缺少曝光事件追踪 |
| 用户体验 | ✅ 通过 | 前端实现完整，UI符合PRD |

**总体结论:** 需要修改后重新验收 (P0问题需修复)

---

## 二、详细评审结果

### 2.1 算法逻辑评审

#### ✅ 已实现功能

| 因子 | 实现状态 | 代码位置 |
|------|----------|----------|
| 难度匹配 (25%) | ✅ | `recommendation-algorithm.service.ts:78-97` |
| 距离 (20%) | ✅ | `recommendation-algorithm.service.ts:99-121` |
| 评分 (20%) | ✅ | `recommendation-algorithm.service.ts:123-135` |
| 热度 (20%) | ✅ | `recommendation-algorithm.service.ts:137-168` |
| 新鲜度 (15%) | ✅ | `recommendation-algorithm.service.ts:170-180` |

#### ⚠️ 发现的问题

**P0 - 难度等级映射不完整**
```typescript
// 当前代码 (line 24-28)
const DIFFICULTY_MAP: Record<TrailDifficulty, number> = {
  [TrailDifficulty.EASY]: 1,
  [TrailDifficulty.MODERATE]: 2,
  [TrailDifficulty.HARD]: 3,
};
// ❌ 缺少 TrailDifficulty.EXPERT = 4 的映射
```
**PRD要求:** 难度等级为 简单=1, 适中=2, 困难=3, 专家=4  
**影响:** 专家级路线无法正确计算难度匹配分

**P1 - 热度计算公式权重不一致**
```typescript
// 当前代码 (line 155)
let score = Math.min(1, completionScore * 0.6 + bookmarkScore * 0.4);
// 执行数 * 0.6 + 收藏数 * 0.4

// PRD要求: 热度分 = min(1.0, 近30天完成人数 / 100 + 收藏数 / 50)
// 实际完成数权重应为 60%，收藏数权重 40% - 但计算方式应为除法而非乘法
```

**P1 - 评分保底分实现**
```typescript
// 当前代码 (line 131-133)
if (reviewCount < 10) {
  return 0.7;  // 直接返回0.7
}
// 应该是加权平均: (评价数/10)*实际评分 + (1-评价数/10)*0.7
```

**P2 - 距离因子最大参考距离**
```typescript
// 当前代码 (line 30)
const MAX_REFERENCE_DISTANCE_KM = 100;
// PRD定义的分级标准: <10km(0.9-1.0), 10-30km(0.7-0.9), 30-50km(0.5-0.7), 50-100km(0.2-0.5), >100km(0-0.2)
// 实际实现未完全按分级标准计算
```

#### ✅ 权重配置
```typescript
// DEFAULT_WEIGHTS 配置正确 (line 14-20)
const DEFAULT_WEIGHTS: AlgorithmWeights = {
  difficultyMatch: 0.25,
  distance: 0.20,
  rating: 0.20,
  popularity: 0.20,
  freshness: 0.15,
};

// NEARBY_WEIGHTS 附近场景正确提升距离权重 (line 22-28)
const NEARBY_WEIGHTS: AlgorithmWeights = {
  difficultyMatch: 0.20,
  distance: 0.40,
  rating: 0.15,
  popularity: 0.15,
  freshness: 0.10,
};
```

#### ✅ 冷启动策略
```typescript
// 冷启动处理 (recommendation.service.ts:47-52)
if (userProfile.isColdStart && scene !== RecommendationScene.SIMILAR) {
  candidateTrails = await this.profileService.getColdStartRecommendations(limit * 3);
}

// 默认匹配分 0.8 (recommendation-algorithm.service.ts:85-87)
if (!prefs.preferredDifficulty || prefs.preferredDifficulty === 0) {
  return 0.8;
}

// 新路线保护期热度保底 0.5 (line 161-165)
if (daysSinceCreated <= 30) {
  score = Math.max(0.5, score);
}
```

#### ✅ 推荐多样性
```typescript
// 首页策略实现 (recommendation.service.ts:157-189)
private applyHomeStrategy(scoredTrails: any[], limit: number): any[] {
  // 前3条：综合得分最高
  // 第4-5条：新鲜度高的新路线
  // 避免连续展示同难度路线
}
```

---

### 2.2 性能要求评审

#### ✅ Redis缓存实现
```typescript
// 缓存配置 (recommendation.service.ts:13-14)
const CACHE_PREFIX = 'recommendation:';
const CACHE_TTL_SECONDS = 300; // 5分钟缓存

// 缓存操作 (line 231-253)
private buildCacheKey(...)
private async getFromCache(key: string)
private async setCache(key: string, value: RecommendationsResponseDto)
private async clearUserCache(userId: string)
```

#### ⚠️ P1 - 缓存TTL配置
- **当前:** 5分钟固定缓存
- **PRD要求:** 响应时间 < 200ms，缓存命中率 > 80%
- **建议:** 
  - 首页推荐缓存 10分钟
  - 附近推荐缓存 2分钟（位置敏感）
  - 相似推荐缓存 30分钟（相对稳定）

#### ✅ 用户画像更新机制
```typescript
// 用户画像服务 (user-profile.service.ts:34-107)
async updateProfile(userId: string): Promise<void>
// 在完成或评分后自动更新 (line 140-142)
if (interactionType === 'complete' || interactionType === 'rate') {
  await this.updateProfile(userId);
}
```

---

### 2.3 埋点追踪评审

#### ✅ 已实现追踪

| 事件 | 实现位置 | 状态 |
|------|----------|------|
| 点击 (click) | `recommendation.service.ts:72-88` | ✅ |
| 收藏 (bookmark) | `recommendation.service.ts:72-88` | ✅ |
| 完成 (complete) | `recommendation.service.ts:72-88` | ✅ |
| 推荐日志记录 | `recommendation.service.ts:100-108` | ✅ |

#### ❌ P0 - 曝光事件缺失

**问题:** 没有实现推荐列表展示时的曝光(impression)事件追踪

**PRD要求:**
```
| 事件 | 参数 | 说明 |
| recommendation_view | scene, trail_ids[] | 推荐列表展示 |
```

**当前实现只记录服务端日志，未触发客户端埋点:**
```typescript
// 当前只创建了服务端日志 (recommendation.service.ts:100-108)
const log = await this.prisma.recommendationLog.create({...})
```

**需要的修改:**
1. 前端需要在推荐列表展示时调用曝光追踪API
2. 后端需要提供曝光事件接收接口
3. 需要区分「推荐生成」和「用户实际看到」

---

### 2.4 用户体验评审

#### ✅ 推荐卡片设计
```dart
// lib/presentation/widgets/recommendations/recommendation_card.dart
// 实现了:
// - 封面图片展示
// - 匹配度标签 (>=80绿色, >=60橙色, <60蓝色)
// - 推荐理由展示
// - 路线信息 (距离/时长/难度)
// - 评分展示
// - 收藏按钮
```

#### ✅ "为你推荐"页面
```dart
// lib/presentation/screens/recommendation_screen.dart
// 实现了:
// - 下拉刷新
// - 位置获取
// - 加载状态
// - 错误处理
// - 空状态处理
// - 点击/收藏追踪
```

#### ✅ 推荐理由展示
```typescript
// recommendation-algorithm.service.ts:200-224
generateRecommendReason(scoredTrail: ScoredTrail, scene: RecommendationScene): string {
  // 根据场景和因子生成不同理由:
  // - 附近场景: "距离你 X 公里"
  // - 新鲜度高: "新上线的路线"
  // - 难度+距离匹配: "符合你的难度偏好，距离合适"
  // - 热度高: "近期热门路线"
  // - 评分高: "高分推荐路线"
}
```

---

## 三、问题列表

### P0 关键问题 (必须修复)

| 编号 | 问题 | 影响 | 建议修复方案 |
|------|------|------|--------------|
| P0-1 | 难度等级映射缺少 EXPERT | 专家级路线匹配分计算错误 | 添加 `EXPERT: 4` 到 DIFFICULTY_MAP |
| P0-2 | 曝光事件追踪缺失 | 无法计算推荐点击率等核心指标 | 前端添加曝光追踪，后端添加曝光接口 |

### P1 重要问题 (建议修复)

| 编号 | 问题 | 影响 | 建议修复方案 |
|------|------|------|--------------|
| P1-1 | 评分保底分实现过于简单 | 评价数<10的路线评分分固定0.7 | 改为线性插值计算 |
| P1-2 | 缓存TTL未按场景区分 | 附近推荐缓存时间过长 | 按场景配置不同TTL |
| P1-3 | 热度计算公式与PRD不符 | 热度分计算可能有偏差 | 确认PRD公式并调整 |

### P2 优化建议 (可选)

| 编号 | 问题 | 建议修复方案 |
|------|------|--------------|
| P2-1 | 距离因子分级标准未完全实现 | 按PRD分级标准精确计算 |
| P2-2 | 缺少权重动态调整接口 | 添加管理员权重配置API |
| P2-3 | 前端缓存未考虑场景隔离 | 按scene隔离前端缓存 |

---

## 四、修改建议

### 4.1 后端修改

**文件:** `recommendation-algorithm.service.ts`

```typescript
// 1. 修复难度映射 (P0-1)
const DIFFICULTY_MAP: Record<TrailDifficulty, number> = {
  [TrailDifficulty.EASY]: 1,
  [TrailDifficulty.MODERATE]: 2,
  [TrailDifficulty.HARD]: 3,
  [TrailDifficulty.EXPERT]: 4,  // 添加
};

// 2. 修复评分保底分 (P1-1)
private calculateRatingScore(trail: any): number {
  const baseRating = trail.avgRating || 3.5;
  const reviewCount = trail.reviewCount || 0;
  
  if (reviewCount < 10) {
    const weight = reviewCount / 10;
    return (baseRating / 5.0) * weight + 0.7 * (1 - weight);
  }
  return Math.min(1, baseRating / 5.0);
}

// 3. 添加曝光事件接口 (P0-2)
// 在 recommendation.controller.ts 添加:
@Post('impression')
async recordImpression(@Body() dto: ImpressionDto, @Req() req: Request) {
  // 记录曝光事件到 analytics
}
```

**文件:** `recommendation.service.ts`

```typescript
// 4. 按场景配置缓存TTL (P1-2)
const CACHE_TTL_BY_SCENE: Record<RecommendationScene, number> = {
  [RecommendationScene.HOME]: 600,    // 10分钟
  [RecommendationScene.LIST]: 300,    // 5分钟
  [RecommendationScene.SIMILAR]: 1800, // 30分钟
  [RecommendationScene.NEARBY]: 120,   // 2分钟
};
```

### 4.2 前端修改

**文件:** `recommendation_service.dart`

```dart
// 1. 添加曝光追踪方法 (P0-2)
Future<void> trackImpression({
  required List<String> trailIds,
  required String scene,
}) async {
  final body = {
    'scene': scene,
    'trailIds': trailIds,
    'timestamp': DateTime.now().toIso8601String(),
  };
  await _post('${ApiConfig.apiBaseUrl}/api/recommendations/impression', body: body);
}
```

**文件:** `recommendation_screen.dart`

```dart
// 2. 页面展示时上报曝光
@override
void didChangeDependencies() {
  super.didChangeDependencies();
  // 上报当前可见的推荐卡片曝光
  _reportImpression();
}

void _reportImpression() {
  if (_trails.isNotEmpty) {
    final visibleTrailIds = _trails.take(5).map((t) => t.id).toList();
    _recommendationService.trackImpression(
      trailIds: visibleTrailIds,
      scene: 'home',
    );
  }
}
```

---

## 五、验收结论

### 5.1 验收标准对照

| 验收项 | PRD要求 | 当前状态 | 结论 |
|--------|---------|----------|------|
| 5因子计算逻辑 | 正确实现 | 基本实现，有P0/P1问题 | ⚠️ 部分通过 |
| 各场景推荐 | 正常展示 | 4个场景均实现 | ✅ 通过 |
| 冷启动处理 | 正常 | 实现完整 | ✅ 通过 |
| 排序结果 | 符合预期 | 同分排序逻辑正确 | ✅ 通过 |
| 响应时间 | < 500ms | 依赖缓存实现 | ⚠️ 需压测验证 |
| 缓存命中率 | > 80% | 实现基础缓存 | ⚠️ 需数据验证 |
| 用户画像数据 | 准确 | 更新机制完整 | ✅ 通过 |
| 埋点数据上报 | 正常 | 缺少曝光事件 | ❌ 未通过 |

### 5.2 最终结论

**当前状态:** ❌ **不通过验收**

**必须修复后重新验收:**
1. **P0-1:** 添加 EXPERT 难度等级映射
2. **P0-2:** 实现曝光事件追踪（前后端均需修改）

**建议一并修复:**
- P1-1: 评分保底分线性插值计算
- P1-2: 按场景配置缓存TTL

**预计修复工时:** 4-6 小时

---

## 六、附录

### 6.1 代码文件清单

| 文件路径 | 说明 |
|----------|------|
| `shanjing-api/src/modules/recommendation/services/recommendation-algorithm.service.ts` | 核心算法 |
| `shanjing-api/src/modules/recommendation/services/recommendation.service.ts` | 推荐服务 |
| `shanjing-api/src/modules/recommendation/services/user-profile.service.ts` | 用户画像 |
| `shanjing-api/src/modules/recommendation/recommendation.controller.ts` | API控制器 |
| `shanjing-api/src/modules/recommendation/dto/recommendation.dto.ts` | DTO定义 |
| `lib/services/recommendation_service.dart` | 前端服务 |
| `lib/presentation/screens/recommendation_screen.dart` | 推荐页面 |
| `lib/presentation/widgets/recommendations/recommendation_card.dart` | 推荐卡片 |
| `lib/models/recommendation_model.dart` | 数据模型 |

### 6.2 测试用例建议

针对发现的问题，建议添加以下测试：

```typescript
// 1. EXPERT难度映射测试
it('should calculate correct score for EXPERT difficulty', () => {
  const expertTrail = { difficulty: 'EXPERT' };
  const score = service.calculateDifficultyMatch(expertTrail, prefs);
  expect(score).toBeDefined();
});

// 2. 曝光事件测试
it('should track impression when recommendations are displayed', async () => {
  await service.getRecommendations(dto);
  expect(analytics.track).toHaveBeenCalledWith('recommendation_view', expect.any(Object));
});
```

---

**报告生成时间:** 2026-03-20 17:45  
**评审人:** Product Agent  
**报告版本:** v1.0
