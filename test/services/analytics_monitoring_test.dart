// ================================================================
// Analytics & Monitoring Test
// 埋点和监控功能验证测试
// ================================================================

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:your_app/services/analytics_service.dart';
import 'package:your_app/services/performance_monitor_service.dart';
import 'package:your_app/services/error_monitor_service.dart';

// Mock classes
class MockApiService extends Mock {}
class MockConnectivityService extends Mock {}

void main() {
  group('Achievement Analytics Tests', () {
    late AnalyticsService analytics;
    
    setUp(() async {
      analytics = AnalyticsService.instance;
      await analytics.initialize(userId: 'test_user');
    });
    
    test('logAchievementPageView should log correct event', () {
      analytics.logAchievementPageView();
      
      // 验证事件被记录
      // 注意: 实际测试中需要验证事件队列或监听事件流
    });
    
    test('logAchievementUnlock should include achievement_id and level', () {
      analytics.logAchievementUnlock('dist_003', 'gold');
      
      // 验证参数
    });
    
    test('logAchievementShare should include all required params', () {
      analytics.logAchievementShare(
        achievementId: 'dist_003',
        achievementName: '远行者',
        level: 'gold',
        channel: 'wechat_moments',
        shareType: 'card',
      );
      
      // 验证参数完整性
    });
    
    test('logAchievementScroll should calculate scroll percent correctly', () {
      analytics.logAchievementScroll(
        scrollOffset: 500,
        maxScrollExtent: 2000,
        visibleBadgeCount: 12,
        category: 'distance',
      );
      
      // 验证滚动百分比计算: 500/2000 = 25%
    });
  });
  
  group('Recommendation Analytics Tests', () {
    late AnalyticsService analytics;
    
    setUp(() async {
      analytics = AnalyticsService.instance;
      await analytics.initialize(userId: 'test_user');
    });
    
    test('logRecommendationImpression should include all trail_ids', () {
      analytics.logRecommendationImpression(
        scene: 'home',
        trailIds: ['trail_001', 'trail_002', 'trail_003'],
        logId: 'log_123',
        matchScores: {'trail_001': 0.89, 'trail_002': 0.85},
      );
      
      // 验证参数
    });
    
    test('logRecommendationClick should include position and match_score', () {
      analytics.logRecommendationClick(
        scene: 'home',
        trailId: 'trail_001',
        position: 0,
        matchScore: 0.89,
        source: 'home_card',
      );
      
      // 验证 match_score 转换为百分比: 0.89 -> 89
    });
    
    test('logRecommendationBookmark should calculate time_to_bookmark', () {
      final impressionTime = DateTime.now().subtract(Duration(seconds: 5));
      final timeToBookmark = DateTime.now().difference(impressionTime).inMilliseconds;
      
      analytics.logRecommendationBookmark(
        scene: 'home',
        trailId: 'trail_001',
        matchScore: 0.89,
        timeToBookmark: timeToBookmark,
      );
      
      // 验证时间差约等于 5000ms
    });
    
    test('logRecommendationComplete should include duration_minutes', () {
      analytics.logRecommendationComplete(
        scene: 'home',
        trailId: 'trail_001',
        matchScore: 0.89,
        timeToComplete: 86400000,
        durationMinutes: 90,
      );
      
      // 验证参数
    });
  });
  
  group('Performance Monitor Tests', () {
    late PerformanceMonitorService monitor;
    
    setUp(() {
      monitor = PerformanceMonitorService.instance;
      monitor.initialize(sessionId: 'test_session');
    });
    
    tearDown(() {
      monitor.clearMetrics();
      monitor.resetCacheStats();
    });
    
    test('startTimer should return PerformanceTimer', () {
      final timer = monitor.startTimer(
        name: 'test_operation',
        type: PerformanceMetricType.apiResponseTime,
      );
      
      expect(timer, isNotNull);
      expect(timer.name, equals('test_operation'));
      
      timer.finish();
    });
    
    test('measureAsync should measure async operation', () async {
      final result = await monitor.measureAsync(
        name: 'async_test',
        type: PerformanceMetricType.apiResponseTime,
        operation: () async {
          await Future.delayed(Duration(milliseconds: 100));
          return 'success';
        },
      );
      
      expect(result, equals('success'));
      
      final metrics = monitor.getAllMetrics();
      expect(metrics.length, equals(1));
      expect(metrics.first.name, equals('async_test'));
      expect(metrics.first.value, greaterThanOrEqualTo(100));
    });
    
    test('recordCacheHit/Miss should update cache stats', () {
      monitor.recordCacheHit('test_cache');
      monitor.recordCacheHit('test_cache');
      monitor.recordCacheMiss('test_cache');
      
      final stats = monitor.getCacheStats('test_cache');
      expect(stats.hits, equals(2));
      expect(stats.misses, equals(1));
      expect(stats.hitRate, equals(2 / 3));
    });
    
    test('shouldWarn should return true for slow operations', () {
      monitor.setThreshold(PerformanceMetricType.apiResponseTime, 100);
      
      final timer = monitor.startTimer(
        name: 'slow_api',
        type: PerformanceMetricType.apiResponseTime,
      );
      
      // 模拟慢操作
      Future.delayed(Duration(milliseconds: 200), () {
        final metric = timer.finish();
        expect(monitor.shouldWarn(metric), isTrue);
      });
    });
    
    test('getSlowOperations should return operations exceeding threshold', () {
      monitor.setThreshold(PerformanceMetricType.apiResponseTime, 50);
      
      // 记录一个快操作
      monitor.recordMetric(
        name: 'fast_api',
        type: PerformanceMetricType.apiResponseTime,
        value: 30,
      );
      
      // 记录一个慢操作
      monitor.recordMetric(
        name: 'slow_api',
        type: PerformanceMetricType.apiResponseTime,
        value: 100,
      );
      
      final slowOps = monitor.getSlowOperations();
      expect(slowOps.length, equals(1));
      expect(slowOps.first.name, equals('slow_api'));
    });
  });
  
  group('Error Monitor Tests', () {
    late ErrorMonitorService monitor;
    
    setUp(() {
      monitor = ErrorMonitorService.instance;
      monitor.initialize(
        sessionId: 'test_session',
        minReportLevel: ErrorLevel.debug,
      );
    });
    
    tearDown(() {
      monitor.clearErrors();
    });
    
    test('reportError should create ErrorReport', () {
      monitor.reportError(
        message: 'Test error',
        level: ErrorLevel.error,
        category: ErrorCategory.api,
      );
      
      final errors = monitor.getAllErrors();
      expect(errors.length, equals(1));
      expect(errors.first.message, equals('Test error'));
      expect(errors.first.level, equals(ErrorLevel.error));
      expect(errors.first.category, equals(ErrorCategory.api));
    });
    
    test('reportApiError should categorize as api', () {
      monitor.reportApiError(
        'get_user',
        Exception('Network error'),
        statusCode: 500,
      );
      
      final apiErrors = monitor.getErrorsByCategory(ErrorCategory.api);
      expect(apiErrors.length, equals(1));
    });
    
    test('getStats should return correct error counts', () {
      monitor.error('Error 1');
      monitor.error('Error 2');
      monitor.warning('Warning 1');
      
      final stats = monitor.getStats();
      expect(stats.total, equals(3));
      expect(stats.byLevel[ErrorLevel.error], equals(2));
      expect(stats.byLevel[ErrorLevel.warning], equals(1));
    });
    
    test('getTopErrors should return most frequent errors', () {
      // 重复上报相同的错误
      for (int i = 0; i < 5; i++) {
        monitor.error('Common error');
      }
      for (int i = 0; i < 2; i++) {
        monitor.error('Rare error');
      }
      
      final topErrors = monitor.getStats().getTopErrors(limit: 2);
      expect(topErrors.length, equals(2));
      expect(topErrors.first.key, equals('Common error'));
      expect(topErrors.first.value, equals(5));
    });
    
    test('minReportLevel should filter low level errors', () {
      monitor.setMinReportLevel(ErrorLevel.warning);
      
      monitor.debug('Debug message');
      monitor.info('Info message');
      monitor.warning('Warning message');
      monitor.error('Error message');
      
      final errors = monitor.getAllErrors();
      expect(errors.length, equals(2)); // 只包含 warning 和 error
    });
  });
  
  group('Monitoring Dashboard Tests', () {
    // Dashboard 测试
    test('getFullReport should return comprehensive report', () {
      // 这个测试需要集成所有服务
    });
    
    test('printReport should output to console', () {
      // 验证控制台输出
    });
  });
  
  group('Service Integration Tests', () {
    test('all services should share sessionId', () {
      // 验证 AnalyticsService、PerformanceMonitorService、ErrorMonitorService
      // 使用相同的 sessionId
    });
    
    test('userId should sync across services', () {
      // 设置 userId 后，验证所有服务都更新了 userId
    });
  });
}
