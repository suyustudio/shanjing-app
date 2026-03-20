# M5 埋点快速参考卡片

## 🚀 初始化

```dart
// main.dart
await ServiceInitializer.instance.initialize(
  userId: 'user_123',
  enableErrorReporting: true,
  enablePerformanceMonitoring: true,
  enableAnalytics: true,
);
```

## 🏆 成就埋点

```dart
// 页面访问
Services.analytics.logAchievementPageView();

// Tab 切换
Services.analytics.logAchievementTabClick('里程');

// 查看详情
Services.analytics.logAchievementDetailView('dist_003');

// 成就解锁
Services.analytics.logAchievementUnlock('dist_003', 'gold');

// 分享徽章
Services.analytics.logAchievementShare(
  achievementId: 'dist_003',
  achievementName: '远行者',
  level: 'gold',
  channel: 'wechat_moments',
  shareType: 'card',
);

// 保存卡片
Services.analytics.logAchievementCardSave('dist_003');

// 滚动徽章墙 (自动)
// AnalyticsService.instance.logAchievementScroll(...)
```

## 🎯 推荐埋点

```dart
// 推荐曝光 (自动集成)
// AnalyticsService.instance.logRecommendationImpression(...)

// 推荐点击 (自动集成)
// AnalyticsService.instance.logRecommendationClick(...)

// 推荐收藏 (自动集成)
// AnalyticsService.instance.logRecommendationBookmark(...)

// 推荐完成 (自动集成)
// AnalyticsService.instance.logRecommendationComplete(...)
```

## ⏱️ 性能监控

```dart
// 方式1: Timer
final timer = Services.performance.startTimer(
  name: 'api_call',
  type: PerformanceMetricType.apiResponseTime,
);
// ... 操作
timer.finish();

// 方式2: 异步测量
final result = await Services.performance.measureAsync(
  name: 'fetch_data',
  type: PerformanceMetricType.apiResponseTime,
  operation: () async => await api.get('/data'),
);

// 方式3: 同步测量
final data = Services.performance.measureSync(
  name: 'process',
  type: PerformanceMetricType.databaseQueryTime,
  operation: () => processData(),
);

// 缓存统计
Services.performance.recordCacheHit('recommendations');
Services.performance.recordCacheMiss('recommendations');
```

## 🐛 错误监控

```dart
// 简单错误
Services.error.error('Something went wrong');

// 带分类
Services.error.reportApiError('get_user', exception, statusCode: 500);
Services.error.reportNetworkError('Timeout', url: 'https://api...');
Services.error.reportDatabaseError('Query failed', exception, table: 'users');

// 快捷方法
Services.error.debug('Debug message');
Services.error.info('Info message');
Services.error.warning('Warning');
Services.error.critical('Critical!', error: exception);
```

## 📊 监控仪表板

```dart
// 启动定时上报
MonitoringDashboard.instance.startPeriodicReporting(
  interval: Duration(minutes: 5),
);

// 获取报告
final report = MonitoringDashboard.instance.getFullReport();

// 打印到控制台
MonitoringDashboard.instance.printReport();
```

## 🔧 在 Widget 中使用

```dart
// 性能监控 Mixin
class MyPage extends State<MyPage> with PerformanceMonitorMixin {
  @override
  void initState() {
    super.initState();
    startPageLoadTimer('my_page');
    loadData();
  }
  
  Future<void> loadData() async {
    final data = await measureApiCall('fetch', () => api.get('/data'));
    finishPageLoadTimer('my_page');
  }
}

// 错误监控 Mixin
class MyPage extends State<MyPage> with ErrorMonitorMixin {
  Future<void> riskyOperation() async {
    await captureAsyncError(() async {
      await someRiskyCall();
    });
  }
}
```

## 📋 事件速查表

### 成就系统
| 事件 | 触发时机 |
|------|----------|
| achievement_page_view | 进入成就页面 |
| achievement_tab_click | 切换 Tab |
| achievement_detail_view | 查看详情 |
| achievement_unlock | 解锁成就 |
| achievement_share | 分享徽章 |
| achievement_card_save | 保存卡片 |
| achievement_scroll | 滚动徽章墙 |

### 推荐系统
| 事件 | 触发时机 |
|------|----------|
| recommendation_impression | 推荐列表展示 |
| recommendation_click | 点击推荐 |
| recommendation_bookmark | 收藏推荐 |
| recommendation_complete | 完成推荐路线 |

## ⚠️ 性能阈值

| 指标 | 阈值 |
|------|------|
| API 响应时间 | 500ms |
| 成就检查耗时 | 200ms |
| 推荐计算耗时 | 300ms |
| 页面加载时间 | 1000ms |

## 📁 文件位置

```
lib/services/
├── analytics_service.dart              # 埋点服务
├── performance_monitor_service.dart    # 性能监控
├── error_monitor_service.dart          # 错误监控
├── service_initializer.dart            # 初始化
└── monitoring_dashboard.dart           # 仪表板

docs/
├── M5_ANALYTICS_INTEGRATION.md         # 完整集成文档
└── M5_ANALYTICS_SUMMARY.md             # 完成总结
```

---
💡 提示: 使用 `Services.xxx` 简化访问，无需手动管理实例
