# M5 数据埋点和监控集成文档

## 1. 快速开始

### 1.1 初始化服务

在应用启动时初始化所有监控服务：

```dart
import 'package:your_app/services/service_initializer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 初始化所有服务
  await ServiceInitializer.instance.initialize(
    userId: 'user_123', // 可选
    enableErrorReporting: true,
    enablePerformanceMonitoring: true,
    enableAnalytics: true,
  );
  
  runApp(MyApp());
}
```

### 1.2 用户登录/登出

```dart
// 用户登录
ServiceInitializer.instance.onUserLogin('user_123');

// 用户登出
ServiceInitializer.instance.onUserLogout();
```

### 1.3 页面路由追踪

```dart
// 在页面切换时更新当前路由
ServiceInitializer.instance.onRouteChanged('/achievements');
```

---

## 2. 成就系统埋点

### 2.1 已实现的埋点事件

| 事件 | 方法 | 参数 | 触发时机 |
|------|------|------|----------|
| achievement_page_view | `logAchievementPageView()` | - | 进入成就页面 |
| achievement_tab_click | `logAchievementTabClick(tabName)` | tab_name | 切换Tab |
| achievement_detail_view | `logAchievementDetailView(id)` | achievement_id | 查看详情 |
| achievement_unlock | `logAchievementUnlock(id, level)` | achievement_id, level | 解锁成就 |
| achievement_share_click | `logAchievementShareClick(id, channel)` | achievement_id, channel | 点击分享 |
| achievement_share_success | `logAchievementShareSuccess(id, channel)` | achievement_id, channel | 分享成功 |
| **achievement_share** (新增) | `logAchievementShare(...)` | achievement_id, achievement_name, level, channel, share_type | 分享徽章 |
| achievement_card_save | `logAchievementCardSave(id)` | achievement_id | 保存卡片 |
| **achievement_scroll** (新增) | `logAchievementScroll(...)` | scroll_offset, scroll_percent, visible_badge_count, category | 滚动徽章墙 |

### 2.2 使用示例

```dart
import 'package:your_app/services/analytics_service.dart';

// 页面访问
AnalyticsService.instance.logAchievementPageView();

// Tab 切换
AnalyticsService.instance.logAchievementTabClick('里程');

// 成就解锁
AnalyticsService.instance.logAchievementUnlock('dist_003', 'gold');

// 分享徽章
AnalyticsService.instance.logAchievementShare(
  achievementId: 'dist_003',
  achievementName: '远行者',
  level: 'gold',
  channel: 'wechat_moments',
  shareType: 'card',
);

// 徽章墙滚动 (自动在 AchievementScreen 中处理)
AnalyticsService.instance.logAchievementScroll(
  scrollOffset: 500,
  maxScrollExtent: 2000,
  visibleBadgeCount: 12,
  category: 'distance',
);
```

---

## 3. 推荐算法埋点

### 3.1 已实现的埋点事件

| 事件 | 方法 | 参数 | 触发时机 |
|------|------|------|----------|
| **recommendation_impression** (新增) | `logRecommendationImpression(...)` | scene, trail_ids, log_id, match_scores | 推荐列表展示 |
| **recommendation_click** (新增) | `logRecommendationClick(...)` | scene, trail_id, position, match_score | 点击推荐路线 |
| **recommendation_bookmark** (新增) | `logRecommendationBookmark(...)` | scene, trail_id, match_score, time_to_bookmark | 收藏推荐路线 |
| **recommendation_complete** (新增) | `logRecommendationComplete(...)` | scene, trail_id, match_score, time_to_complete, duration_minutes | 完成推荐路线 |
| recommendation_sort | `logRecommendationSort(...)` | sort_type, previous_sort | 切换排序 |

### 3.2 使用示例

```dart
import 'package:your_app/services/analytics_service.dart';

// 推荐曝光
AnalyticsService.instance.logRecommendationImpression(
  scene: 'home',
  trailIds: ['trail_001', 'trail_002', 'trail_003'],
  logId: 'log_123',
  matchScores: {'trail_001': 0.89, 'trail_002': 0.85},
);

// 推荐点击
AnalyticsService.instance.logRecommendationClick(
  scene: 'home',
  trailId: 'trail_001',
  position: 0,
  matchScore: 0.89,
  source: 'home_card',
);

// 推荐收藏转化
AnalyticsService.instance.logRecommendationBookmark(
  scene: 'home',
  trailId: 'trail_001',
  matchScore: 0.89,
  timeToBookmark: 5000, // 从曝光到收藏的毫秒数
);

// 推荐完成转化
AnalyticsService.instance.logRecommendationComplete(
  scene: 'home',
  trailId: 'trail_001',
  matchScore: 0.89,
  timeToComplete: 86400000, // 24小时后完成
  durationMinutes: 90,
);
```

### 3.3 自动集成

推荐服务的埋点已自动集成，无需额外调用：

```dart
// RecommendationService 会自动上报 impression 事件
final recommendations = await RecommendationService().getHomeRecommendations();

// 点击时自动上报 click 事件
await RecommendationService().trackClick(
  trailId: 'trail_001',
  scene: RecommendationScene.home,
  position: 0,
);

// 收藏时自动上报 bookmark 事件
await RecommendationService().trackBookmark(
  trailId: 'trail_001',
  scene: RecommendationScene.home,
);
```

---

## 4. 性能监控

### 4.1 监控指标

| 指标 | 类型 | 说明 | 阈值 |
|------|------|------|------|
| apiResponseTime | 计时 | API 响应时间 | 500ms |
| achievementCheckTime | 计时 | 成就检查耗时 | 200ms |
| recommendationComputeTime | 计时 | 推荐计算耗时 | 300ms |
| pageLoadTime | 计时 | 页面加载时间 | 1000ms |
| cacheHitRate | 比率 | 缓存命中率 | - |

### 4.2 使用示例

```dart
import 'package:your_app/services/performance_monitor_service.dart';

// 方法 1: 使用 Timer
final timer = PerformanceMonitorService.instance.startTimer(
  name: 'custom_operation',
  type: PerformanceMetricType.apiResponseTime,
  tags: {'operation': 'fetch_data'},
);
// ... 执行操作
timer.finish();

// 方法 2: 测量异步操作
final result = await PerformanceMonitorService.instance.measureAsync(
  name: 'fetch_user_data',
  type: PerformanceMetricType.apiResponseTime,
  operation: () async {
    return await apiService.get('/users/me');
  },
);

// 方法 3: 测量同步操作
final data = PerformanceMonitorService.instance.measureSync(
  name: 'process_data',
  type: PerformanceMetricType.databaseQueryTime,
  operation: () {
    return processLargeDataset();
  },
);

// 记录缓存命中/未命中
PerformanceMonitorService.instance.recordCacheHit('recommendations');
PerformanceMonitorService.instance.recordCacheMiss('recommendations');

// 获取缓存统计
final stats = PerformanceMonitorService.instance.getCacheStats('recommendations');
print('Cache hit rate: ${stats.hitRate}');
```

### 4.3 在 Widget 中使用

```dart
import 'package:your_app/services/performance_monitor_service.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with PerformanceMonitorMixin {
  @override
  void initState() {
    super.initState();
    startPageLoadTimer('my_page');
    loadData();
  }
  
  Future<void> loadData() async {
    final data = await measureApiCall('fetch_data', () async {
      return await api.get('/data');
    });
    
    setState(() {
      // 更新UI
    });
    
    finishPageLoadTimer('my_page');
  }
}
```

---

## 5. 错误监控

### 5.1 错误级别

| 级别 | 说明 |
|------|------|
| debug | 调试信息 |
| info | 一般信息 |
| warning | 警告 |
| error | 错误 |
| critical | 严重错误 |
| fatal | 致命错误 |

### 5.2 错误分类

| 分类 | 说明 |
|------|------|
| network | 网络错误 |
| api | API 错误 |
| database | 数据库错误 |
| ui | UI 错误 |
| businessLogic | 业务逻辑错误 |
| flutter | Flutter 框架错误 |
| native | 原生平台错误 |
| unknown | 未知错误 |

### 5.3 使用示例

```dart
import 'package:your_app/services/error_monitor_service.dart';

// 简单错误上报
ErrorMonitorService.instance.error(
  'Failed to load data',
  error: exception,
  stackTrace: stack,
);

// 分类上报
ErrorMonitorService.instance.reportApiError(
  'get_user_profile',
  exception,
  statusCode: 500,
);

ErrorMonitorService.instance.reportNetworkError(
  'Connection timeout',
  url: 'https://api.example.com/data',
  statusCode: 0,
);

ErrorMonitorService.instance.reportDatabaseError(
  'Query failed',
  exception,
  table: 'users',
);

// 快捷方法
ErrorMonitorService.instance.debug('Debug message');
ErrorMonitorService.instance.info('Info message');
ErrorMonitorService.instance.warning('Warning message');
ErrorMonitorService.instance.critical('Critical error', error: exception);
```

### 5.4 在 Widget 中使用

```dart
import 'package:your_app/services/error_monitor_service.dart';

class MyPage extends StatefulWidget {
  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> with ErrorMonitorMixin {
  Future<void> riskyOperation() async {
    await captureAsyncError(() async {
      // 可能抛出异常的操作
      await someRiskyAsyncCall();
    });
  }
  
  void anotherOperation() {
    try {
      // 某些操作
    } catch (e, stack) {
      captureError(e, stack, category: ErrorCategory.ui);
    }
  }
}
```

---

## 6. 监控仪表板

### 6.1 启动定时上报

```dart
import 'package:your_app/services/monitoring_dashboard.dart';

// 启动每5分钟自动上报
MonitoringDashboard.instance.startPeriodicReporting(
  interval: Duration(minutes: 5),
);

// 停止定时上报
MonitoringDashboard.instance.stopPeriodicReporting();
```

### 6.2 获取监控报告

```dart
// 获取完整报告
final report = MonitoringDashboard.instance.getFullReport();

// 打印报告到控制台
MonitoringDashboard.instance.printReport();

// 导出为JSON
final json = MonitoringDashboard.instance.exportToJson();
```

---

## 7. 简化访问

使用 `Services` 类简化服务访问：

```dart
import 'package:your_app/services/service_initializer.dart';

// 埋点
Services.analytics.logAchievementPageView();

// 性能监控
Services.performance.recordCacheHit('recommendations');

// 错误监控
Services.error.error('Something went wrong');

// 成就服务
final achievements = await Services.achievement.getUserAchievements();

// 推荐服务
final recommendations = await Services.recommendation.getHomeRecommendations();
```

---

## 8. 调试模式

在调试模式下，所有埋点和监控数据会输出到控制台：

```
📊 Analytics: achievement_unlock, params: {achievement_id: dist_003, level: gold}
⏱️ Performance: api_recommendations = 245ms
❌ [ERROR] api: Failed to load data
📊 Analytics flushed: 5 events
```

---

## 9. 最佳实践

1. **尽早初始化**: 在应用启动时立即初始化服务
2. **用户关联**: 用户登录后立即更新用户ID
3. **路由追踪**: 在页面切换时更新当前路由
4. **错误处理**: 使用 try-catch 包裹可能出错的代码，并上报错误
5. **性能测量**: 对关键操作添加性能测量
6. **定期上报**: 启动定时上报以监控长期趋势

---

## 10. 事件命名规范

- 使用小写字母和下划线: `achievement_unlock`
- 动词 + 名词: `recommendation_click`
- 保持一致性: `page_view`, `button_click`

---

## 11. 参数命名规范

- 使用小写字母和下划线: `achievement_id`
- 布尔值使用 `is_` 或 `has_` 前缀: `is_new`, `has_shared`
- 时间戳使用 ISO 8601 格式
- ID 字段使用 `_id` 后缀
