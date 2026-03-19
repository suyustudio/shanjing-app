# Product-Dev Review 报告

> **Review 日期**: 2026-03-19  
> **Review 范围**: M4 埋点事件代码实现 + 分享/SOS 真实 API 接入  
> **Reviewer**: Product Agent  
> **Build**: #116 (成功)

---

## Review 结论

### ❌ 未通过 - 需要修改

当前实现存在多项与 `data-tracking-spec-v1.2.md` 规范不符的问题，需要在代码合并前修正。

---

## 问题列表

### 🚨 P0 - 严重问题（必须修复）

#### 1. 埋点事件名称与规范不符

| 规范定义 | 实际实现 | 问题等级 |
|---------|---------|---------|
| `share_trail` | `ShareEvents.shareTrail` | P0 |
| `sos_trigger` | `SosEvents.sosTriggered` | P0 |
| `navigation_start` | ❌ **未实现** | P0 |
| `trail_complete` | `TrailEvents.trailNavigateComplete` / `NavigationEvents.navigationComplete` | P0 |

**影响**: 事件名称不一致会导致数据分析平台无法正确识别和统计事件，影响数据报表准确性。

#### 2. `share_trail` 触发时机错误

**规范要求**:
- 触发时机：用户成功分享后（选择分享渠道并确认后）
- 位置：分享成功回调中

**实际实现** (`share_service.dart` L28-L32):
```dart
Future<ShareResponse> shareTrail(String trailId) async {
  // 埋点：分享开始  ← ❌ 错误：在开始时触发
  AnalyticsService().trackEvent(ShareEvents.shareTrail, params: {...});
  ...
}
```

**问题**: 事件在分享开始时触发，而非成功后。用户可能在分享面板取消，导致数据虚高。

#### 3. `sos_trigger` 触发时机错误

**规范要求**:
- 触发时机：后端 API 返回成功后
- 位置：API 成功回调中

**实际实现** (`sos_service.dart` L33-L37):
```dart
Future<bool> triggerSos(Location location) async {
  // 埋点：SOS 触发  ← ❌ 错误：在 API 调用前触发
  AnalyticsService().trackEvent(SosEvents.sosTriggered, params: {...});
  
  try {
    final response = await _client.post('/sos/trigger', ...);
    // 成功后触发 sosSuccess
  }
}
```

**问题**: 事件在 API 调用前触发，若 API 失败则数据不准确。

#### 4. `share_trail` 参数缺失

**规范要求参数**:
| 参数名 | 必填 | 实际状态 |
|--------|------|---------|
| `route_id` | ✅ | ✅ 已实现 |
| `route_name` | ✅ | ❌ **缺失** |
| `share_channel` | ✅ | ❌ **缺失** |
| `template_type` | ✅ | ❌ **缺失** |
| `share_time_ms` | ✅ | ❌ **缺失** |
| `poster_size_kb` | ❌ | ❌ 缺失 |
| `generation_duration_ms` | ❌ | ❌ 缺失 |

#### 5. `sos_trigger` 参数缺失

**规范要求参数**:
| 参数名 | 必填 | 实际状态 |
|--------|------|---------|
| `trigger_type` | ✅ | ❌ **缺失** |
| `countdown_remaining_sec` | ✅ | ❌ **缺失** |
| `location_lat` | ✅ | ⚠️ 有 lat/lng 但字段名不符 |
| `location_lng` | ✅ | ⚠️ 有 lat/lng 但字段名不符 |
| `location_accuracy` | ✅ | ✅ 已实现 |
| `route_id` | ❌ | ❌ 缺失 |
| `contact_count` | ✅ | ❌ **缺失** |
| `send_method` | ✅ | ❌ **缺失** |
| `api_response_ms` | ✅ | ❌ **缺失** |
| `trigger_timestamp` | ✅ | ❌ **缺失** |

#### 6. `navigation_start` 事件未实现

**规范要求**: 在导航界面成功加载、GPS 定位成功后触发

**实际状态**: `navigation_screen.dart` 中未找到该事件触发代码

#### 7. `trail_complete` 事件名称与参数不符

**规范要求**:
- 事件名: `trail_complete`
- 关键参数: `completion_type`, `actual_distance_m`, `actual_duration_sec`, `deviation_count` 等

**实际实现** (`navigation_screen.dart` L287-L299):
```dart
AnalyticsService().trackEvent(
  TrailEvents.trailNavigateComplete,  // ❌ 事件名不符
  params: {
    TrailEvents.paramRouteName: widget.routeName,
    TrailEvents.paramCompletionTime: duration,  // ❌ 字段名不符
  },
);
```

### ⚠️ P1 - 中等问题（建议修复）

#### 8. 分享 API 端点不一致

**后端 API 文档** (`shanjing-api-user-api-docs.md`): 未定义 `/share/trail` 端点

**实际实现** (`share_service.dart`):
```dart
final response = await _apiClient.post<Map<String, dynamic>>(
  '/share/trail',  // ⚠️ 后端文档中未找到此端点
  ...
);
```

**建议**: 确认后端是否已实现此接口，或更新 API 文档。

#### 9. SOS API 错误处理不完善

**实际实现** (`sos_service.dart` L50-L66):
```dart
try {
  final response = await _client.post('/sos/trigger', ...);
  // ...
} catch (e) {
  // 埋点：SOS 发送失败（异常）
  AnalyticsService().trackEvent(SosEvents.sosFailed, ...);
  return false;
}
```

**问题**: 
- 未区分网络错误和服务器错误
- 缺少重试机制
- 失败时未向用户展示详细错误信息

#### 10. 缺少倒计时确认流程

**规范要求** (`data-tracking-spec-v1.2.md` 2.2节):
> SOS 触发流程应包含 5 秒倒计时确认页面，用户可取消

**实际实现**: `SosService.triggerSos()` 直接调用 API，无倒计时逻辑

---

## 建议优化项

### 💡 代码质量优化

1. **统一事件常量命名**
   ```dart
   // 当前：大小写不一致
   ShareEvents.shareTrail      // snake_case
   SosEvents.sosTriggered      // camelCase
   TrailEvents.trailNavigateComplete  // camelCase
   
   // 建议：统一使用 snake_case 与规范保持一致
   ShareEvents.share_trail
   SosEvents.sos_trigger
   ```

2. **参数收集封装**
   建议创建专门的参数收集器，避免参数遗漏：
   ```dart
   class ShareTrailParams {
     static Map<String, dynamic> build({
       required String routeId,
       required String routeName,
       required String shareChannel,
       required String templateType,
       required int shareTimeMs,
     }) => {
       'route_id': routeId,
       'route_name': routeName,
       'share_channel': shareChannel,
       'template_type': templateType,
       'share_time_ms': shareTimeMs,
     };
   }
   ```

3. **API 响应时间统计**
   ```dart
   final stopwatch = Stopwatch()..start();
   final response = await _client.post(...);
   final apiResponseMs = stopwatch.elapsedMilliseconds;
   ```

### 💡 功能优化

4. **分享渠道选择**
   当前 `ShareSheet` 组件中分享按钮为 TODO 状态，需要实现真实的渠道选择和回调。

5. **SOS 倒计时页面**
   建议新增 `SosCountdownScreen` 组件，实现：
   - 5 秒倒计时显示
   - 用户取消按钮
   - 立即发送按钮
   - 倒计时结束后自动触发

6. **导航统计追踪**
   建议新增 `NavigationTracker` 类，统一管理：
   - 偏航次数统计
   - 暂停次数和时长
   - 实际行走距离
   - 拍照次数

---

## 修复检查清单

### 必须完成（P0）

- [ ] 修改 `ShareEvents.shareTrail` → `'share_trail'`
- [ ] 修改 `SosEvents.sosTriggered` → `'sos_trigger'`
- [ ] 修改 `TrailEvents.trailNavigateComplete` → `'trail_complete'`
- [ ] 将 `share_trail` 触发时机移至分享成功后
- [ ] 将 `sos_trigger` 触发时机移至 API 成功后
- [ ] 实现 `navigation_start` 事件触发
- [ ] 补全 `share_trail` 参数：`route_name`, `share_channel`, `template_type`, `share_time_ms`
- [ ] 补全 `sos_trigger` 参数：`trigger_type`, `countdown_remaining_sec`, `contact_count`, `send_method`, `api_response_ms`, `trigger_timestamp`
- [ ] 补全 `trail_complete` 参数：`completion_type`, `actual_distance_m`, `actual_duration_sec`, `deviation_count`, `avg_speed_ms`

### 建议完成（P1）

- [ ] 确认 `/share/trail` API 端点已实现或更新文档
- [ ] 完善 SOS 错误处理和重试机制
- [ ] 实现 SOS 倒计时确认页面
- [ ] 添加 API 响应时间统计

---

## 附件

### 参考文档

1. `data-tracking-spec-v1.2.md` - 埋点规范（标准依据）
2. `shanjing-api-user-api-docs.md` - 后端 API 文档
3. `lib/analytics/events/*.dart` - 事件定义文件
4. `lib/services/share_service.dart` - 分享服务
5. `lib/services/sos_service.dart` - SOS 服务
6. `lib/screens/navigation_screen.dart` - 导航页面

### 代码位置汇总

| 文件 | 相关代码行 |
|------|-----------|
| `lib/services/share_service.dart` | L28-66 |
| `lib/services/sos_service.dart` | L33-66 |
| `lib/screens/navigation_screen.dart` | L287-299, L315-325 |
| `lib/analytics/events/share_events.dart` | L6-16 |
| `lib/analytics/events/sos_events.dart` | L6-17 |
| `lib/analytics/events/navigation_events.dart` | L7-25 |
| `lib/analytics/events/trail_events.dart` | L8-22 |

---

*Review 完成时间: 2026-03-19 17:55*
