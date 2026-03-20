# M5 推荐算法 P0 问题修复总结

**修复日期:** 2026-03-20
**修复人员:** Dev Agent
**预计工时:** 3h
**实际工时:** ~2.5h

---

## 修复问题清单

### ✅ P0-1: 难度等级映射缺少 EXPERT (已完成)

**问题:** 难度映射表缺少 `EXPERT: 4` 映射，导致专家级路线无法正确计算难度匹配分

**修复文件:**
- `shanjing-api/prisma/schema.prisma` - 添加 EXPERT 到 TrailDifficulty 枚举
- `shanjing-api/src/modules/recommendation/services/recommendation-algorithm.service.ts` - 添加 EXPERT: 4 映射
- `shanjing-api/src/modules/recommendation/services/user-profile.service.ts` - 添加 EXPERT: 4 映射

**代码变更:**
```typescript
// 难度映射
const DIFFICULTY_MAP: Record<TrailDifficulty, number> = {
  [TrailDifficulty.EASY]: 1,
  [TrailDifficulty.MODERATE]: 2,
  [TrailDifficulty.HARD]: 3,
  [TrailDifficulty.EXPERT]: 4,  // ✅ 新增
};
```

---

### ✅ P0-2: 曝光事件追踪缺失 (已完成)

**问题:** 无法计算推荐点击率等核心指标，缺少曝光(impression)事件追踪

**后端修复:**

1. **DTO 定义** (`recommendation.dto.ts`)
```typescript
export class ImpressionDto {
  @ApiProperty({ description: '推荐场景' })
  @IsEnum(RecommendationScene)
  scene: RecommendationScene;

  @ApiProperty({ description: '曝光的路线ID列表' })
  @IsArray()
  @IsString({ each: true })
  trailIds: string[];

  @ApiPropertyOptional({ description: '推荐日志ID' })
  logId?: string;

  @ApiPropertyOptional({ description: '曝光时间戳' })
  timestamp?: string;
}
```

2. **API 接口** (`recommendation.controller.ts`)
```typescript
@Post('impression')
@ApiOperation({ summary: '记录推荐曝光事件' })
async recordImpression(
  @Body() dto: ImpressionDto,
  @Req() req: Request,
): Promise<{ success: boolean; message: string }> {
  const userId = (req as any).user?.userId;
  return await this.recommendationService.recordImpression(dto, userId);
}
```

3. **服务实现** (`recommendation.service.ts`)
```typescript
async recordImpression(
  dto: ImpressionDto,
  currentUserId?: string,
): Promise<{ success: boolean; message: string }> {
  const { scene, trailIds, logId, timestamp } = dto;
  
  // 批量记录曝光日志
  const impressionData = trailIds.map(trailId => ({
    userId: currentUserId,
    trailId,
    scene,
    logId,
    timestamp: timestamp ? new Date(timestamp) : new Date(),
  }));

  // 使用事务批量创建曝光记录
  await this.prisma.$transaction(async (tx) => {
    for (const data of impressionData) {
      await tx.recommendationImpression.create({ data: { ... } });
    }
  });
  
  return { success: true, message: `Recorded ${trailIds.length} impressions` };
}
```

4. **数据库模型** (`prisma/schema.prisma`)
```prisma
model RecommendationImpression {
  id        String   @id @default(uuid())
  userId    String?  @map("user_id")
  trailId   String   @map("trail_id")
  scene     String   // home, list, similar, nearby
  logId     String?  @map("log_id")
  viewedAt  DateTime @default(now()) @map("viewed_at")
  createdAt DateTime @default(now()) @map("created_at")
  
  @@index([userId, viewedAt])
  @@index([trailId])
  @@index([scene])
  @@map("recommendation_impressions")
}
```

**前端修复:**

1. **服务方法** (`recommendation_service.dart`)
```dart
/// 记录推荐曝光事件
Future<bool> trackImpression({
  required List<String> trailIds,
  required RecommendationScene scene,
  String? logId,
}) async {
  if (trailIds.isEmpty) return false;

  final body = <String, dynamic>{
    'scene': scene.name,
    'trailIds': trailIds,
    'timestamp': DateTime.now().toIso8601String(),
    if (logId != null) 'logId': logId,
  };

  final response = await _post(
    '${ApiConfig.apiBaseUrl}/api/recommendations/impression',
    body: body,
  );

  return response != null && response['success'] == true;
}
```

2. **页面曝光追踪** (`recommendation_screen.dart`)
```dart
// 曝光追踪相关
Timer? _impressionDebounceTimer;
final Set<String> _reportedTrailIds = {};
static const Duration _impressionDebounceDuration = Duration(seconds: 1);

/// 防抖处理曝光上报
void _debouncedReportImpression() {
  _impressionDebounceTimer?.cancel();
  _impressionDebounceTimer = Timer(_impressionDebounceDuration, () {
    _reportImpression();
  });
}

/// 上报推荐曝光事件
void _reportImpression() {
  if (_trails.isEmpty) return;

  // 获取可见的路线（前5条）且未上报过的
  final visibleTrails = _trails.take(5).where((trail) {
    return !_reportedTrailIds.contains(trail.id);
  }).toList();

  if (visibleTrails.isEmpty) return;

  final trailIds = visibleTrails.map((t) => t.id).toList();
  final logId = _recommendationService.getCachedLogId();

  // 标记为已上报
  for (final trail in visibleTrails) {
    _reportedTrailIds.add(trail.id);
  }

  // 发送曝光追踪请求
  _recommendationService.trackImpression(
    trailIds: trailIds,
    scene: RecommendationScene.home,
    logId: logId,
  );
}
```

---

### ✅ 缓存 TTL 优化 (已完成)

**修复文件:** `shanjing-api/src/modules/recommendation/services/recommendation.service.ts`

**代码变更:**
```typescript
// 按场景配置缓存 TTL（秒）
const CACHE_TTL_BY_SCENE: Record<RecommendationScene, number> = {
  [RecommendationScene.HOME]: 300,      // 首页推荐: 5分钟
  [RecommendationScene.LIST]: 600,      // 列表推荐: 10分钟
  [RecommendationScene.SIMILAR]: 1800,  // 详情推荐(相似路线): 30分钟
  [RecommendationScene.NEARBY]: 120,    // 附近推荐: 2分钟（位置敏感）
};
```

---

## 文件变更清单

| 文件路径 | 变更类型 | 说明 |
|----------|----------|------|
| `shanjing-api/prisma/schema.prisma` | 修改 | 添加 EXPERT 枚举值和 RecommendationImpression 模型 |
| `shanjing-api/src/modules/recommendation/dto/recommendation.dto.ts` | 修改 | 添加 ImpressionDto |
| `shanjing-api/src/modules/recommendation/recommendation.controller.ts` | 修改 | 添加 POST /impression 接口 |
| `shanjing-api/src/modules/recommendation/services/recommendation.service.ts` | 修改 | 添加 recordImpression 方法和场景化 TTL |
| `shanjing-api/src/modules/recommendation/services/recommendation-algorithm.service.ts` | 修改 | 添加 EXPERT: 4 映射 |
| `shanjing-api/src/modules/recommendation/services/user-profile.service.ts` | 修改 | 添加 EXPERT: 4 映射 |
| `lib/services/recommendation_service.dart` | 修改 | 添加 trackImpression 方法 |
| `lib/presentation/screens/recommendation_screen.dart` | 修改 | 添加曝光追踪逻辑 |

---

## 后续步骤

1. **数据库迁移:** 运行 `prisma migrate dev` 创建 RecommendationImpression 表
2. **部署:** 重新部署后端服务
3. **测试:** 验证曝光事件是否正确记录到数据库
4. **监控:** 观察推荐点击率指标

---

## 验证清单

- [x] EXPERT 难度映射已添加
- [x] 后端 POST /api/recommendations/impression 接口已实现
- [x] 前端 trackImpression() 方法已实现
- [x] 防抖处理已添加（1秒延迟）
- [x] 场景化缓存 TTL 已配置
- [x] Prisma schema 已更新
- [x] Prisma client 已重新生成
