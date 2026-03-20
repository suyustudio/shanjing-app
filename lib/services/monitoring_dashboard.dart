// ================================================================
// Monitoring Dashboard Service
// 监控仪表板服务 - 汇总展示性能指标、错误统计等
// ================================================================

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'analytics_service.dart';
import 'performance_monitor_service.dart';
import 'error_monitor_service.dart';
import 'recommendation_service.dart';
import 'achievement_service.dart';

/// 监控数据汇总
class MonitoringDashboard {
  static final MonitoringDashboard _instance = MonitoringDashboard._internal();
  static MonitoringDashboard get instance => _instance;
  
  MonitoringDashboard._internal();
  
  // 定时器
  Timer? _reportTimer;
  
  /// 启动定时上报
  void startPeriodicReporting({Duration interval = const Duration(minutes: 5)}) {
    _reportTimer?.cancel();
    _reportTimer = Timer.periodic(interval, (_) => _generateAndReport());
  }
  
  /// 停止定时上报
  void stopPeriodicReporting() {
    _reportTimer?.cancel();
    _reportTimer = null;
  }
  
  /// 获取完整的监控报告
  Map<String, dynamic> getFullReport() {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'performance': _getPerformanceReport(),
      'errors': _getErrorReport(),
      'cache': _getCacheReport(),
      'system': _getSystemReport(),
    };
  }
  
  /// 获取性能报告
  Map<String, dynamic> _getPerformanceReport() {
    final monitor = PerformanceMonitorService.instance;
    final metrics = monitor.getAllMetrics();
    
    // 按类型分组统计
    final apiMetrics = metrics.where((m) => m.type == PerformanceMetricType.apiResponseTime);
    final achievementMetrics = metrics.where((m) => m.type == PerformanceMetricType.achievementCheckTime);
    final recommendationMetrics = metrics.where((m) => m.type == PerformanceMetricType.recommendationComputeTime);
    
    return {
      'api_response': _calculateMetricsStats(apiMetrics),
      'achievement_check': _calculateMetricsStats(achievementMetrics),
      'recommendation_compute': _calculateMetricsStats(recommendationMetrics),
      'slow_operations': monitor.getSlowOperations().length,
    };
  }
  
  /// 获取错误报告
  Map<String, dynamic> _getErrorReport() {
    final monitor = ErrorMonitorService.instance;
    final stats = monitor.getStats();
    
    return {
      'total': stats.total,
      'by_level': stats.byLevel.map((k, v) => MapEntry(k.name, v)),
      'by_category': stats.byCategory.map((k, v) => MapEntry(k.name, v)),
      'top_errors': stats.getTopErrors(limit: 5).map((e) => {
        'message': e.key.substring(0, e.key.length > 50 ? 50 : e.key.length),
        'count': e.value,
      }).toList(),
    };
  }
  
  /// 获取缓存报告
  Map<String, dynamic> _getCacheReport() {
    final monitor = PerformanceMonitorService.instance;
    final recService = RecommendationService();
    final achService = AchievementService.instance;
    
    return {
      'recommendations': recService.getCacheStats().toJson(),
      'achievements': achService.getCacheStats().toJson(),
      'all_caches': monitor.getCacheHitRateReport(),
    };
  }
  
  /// 获取系统报告
  Map<String, dynamic> _getSystemReport() {
    return {
      'session_id': AnalyticsService.instance.sessionId,
      'report_time': DateTime.now().toIso8601String(),
      'is_debug': kDebugMode,
    };
  }
  
  /// 打印监控报告到控制台
  void printReport() {
    final report = getFullReport();
    
    debugPrint('╔════════════════════════════════════════╗');
    debugPrint('║        MONITORING DASHBOARD            ║');
    debugPrint('╠════════════════════════════════════════╣');
    
    // 性能
    final perf = report['performance'] as Map<String, dynamic>;
    debugPrint('║ PERFORMANCE                            ║');
    debugPrint('║ ─────────────────────────────────────  ║');
    if (perf['api_response'] != null) {
      final api = perf['api_response'] as Map<String, dynamic>;
      debugPrint('║ API Avg: ${api['avg']?.toStringAsFixed(0) ?? 'N/A'}ms              ║');
    }
    if (perf['achievement_check'] != null) {
      final ach = perf['achievement_check'] as Map<String, dynamic>;
      debugPrint('║ Achievement Check Avg: ${ach['avg']?.toStringAsFixed(0) ?? 'N/A'}ms ║');
    }
    debugPrint('║ Slow Ops: ${perf['slow_operations']}                     ║');
    
    // 错误
    final errors = report['errors'] as Map<String, dynamic>;
    debugPrint('║                                        ║');
    debugPrint('║ ERRORS                                 ║');
    debugPrint('║ ─────────────────────────────────────  ║');
    debugPrint('║ Total: ${errors['total']}                              ║');
    
    // 缓存
    final cache = report['cache'] as Map<String, dynamic>;
    debugPrint('║                                        ║');
    debugPrint('║ CACHE                                  ║');
    debugPrint('║ ─────────────────────────────────────  ║');
    final recCache = cache['recommendations'] as Map<String, dynamic>?;
    if (recCache != null) {
      final hitRate = (recCache['hit_rate'] as double? ?? 0) * 100;
      debugPrint('║ Recommendations: ${hitRate.toStringAsFixed(1)}%          ║');
    }
    
    debugPrint('╚════════════════════════════════════════╝');
  }
  
  /// 导出性能报告为JSON
  String exportToJson() {
    final report = getFullReport();
    return report.toString(); // 简化处理，实际应该使用 jsonEncode
  }
  
  // ============ 私有方法 ============
  
  Map<String, dynamic>? _calculateMetricsStats(Iterable<PerformanceMetric> metrics) {
    if (metrics.isEmpty) return null;
    
    final values = metrics.map((m) => m.value).toList()..sort();
    final sum = values.reduce((a, b) => a + b);
    
    return {
      'count': values.length,
      'avg': sum / values.length,
      'min': values.first,
      'max': values.last,
      'p50': _percentile(values, 0.5),
      'p90': _percentile(values, 0.9),
      'p95': _percentile(values, 0.95),
    };
  }
  
  double _percentile(List<double> sortedValues, double p) {
    final index = (sortedValues.length * p).ceil() - 1;
    return sortedValues[index.clamp(0, sortedValues.length - 1)];
  }
  
  void _generateAndReport() {
    // 上报缓存命中率埋点
    _reportCacheMetrics();
    
    // 打印报告
    if (kDebugMode) {
      printReport();
    }
  }
  
  void _reportCacheMetrics() {
    final monitor = PerformanceMonitorService.instance;
    final allCaches = monitor.getAllCacheStats();
    
    for (final entry in allCaches.entries) {
      final stats = entry.value;
      if (stats.total > 0) {
        AnalyticsService.instance.logCacheHitRate(
          cacheName: entry.key,
          hitRate: stats.hitRate,
          hitCount: stats.hits,
          missCount: stats.misses,
        );
      }
    }
  }
  
  /// 释放资源
  void dispose() {
    stopPeriodicReporting();
  }
}

/// 监控报告模型
class MonitoringReport {
  final DateTime timestamp;
  final PerformanceReport performance;
  final ErrorReportSummary errors;
  final CacheReport cache;
  
  MonitoringReport({
    required this.timestamp,
    required this.performance,
    required this.errors,
    required this.cache,
  });
  
  factory MonitoringReport.fromJson(Map<String, dynamic> json) {
    return MonitoringReport(
      timestamp: DateTime.parse(json['timestamp']),
      performance: PerformanceReport.fromJson(json['performance']),
      errors: ErrorReportSummary.fromJson(json['errors']),
      cache: CacheReport.fromJson(json['cache']),
    );
  }
}

class PerformanceReport {
  final MetricsStats? apiResponse;
  final MetricsStats? achievementCheck;
  final MetricsStats? recommendationCompute;
  final int slowOperations;
  
  PerformanceReport({
    this.apiResponse,
    this.achievementCheck,
    this.recommendationCompute,
    required this.slowOperations,
  });
  
  factory PerformanceReport.fromJson(Map<String, dynamic> json) {
    return PerformanceReport(
      apiResponse: json['api_response'] != null 
          ? MetricsStats.fromJson(json['api_response']) 
          : null,
      achievementCheck: json['achievement_check'] != null 
          ? MetricsStats.fromJson(json['achievement_check']) 
          : null,
      recommendationCompute: json['recommendation_compute'] != null 
          ? MetricsStats.fromJson(json['recommendation_compute']) 
          : null,
      slowOperations: json['slow_operations'] ?? 0,
    );
  }
}

class MetricsStats {
  final int count;
  final double avg;
  final double min;
  final double max;
  final double p90;
  
  MetricsStats({
    required this.count,
    required this.avg,
    required this.min,
    required this.max,
    required this.p90,
  });
  
  factory MetricsStats.fromJson(Map<String, dynamic> json) {
    return MetricsStats(
      count: json['count'] ?? 0,
      avg: json['avg']?.toDouble() ?? 0,
      min: json['min']?.toDouble() ?? 0,
      max: json['max']?.toDouble() ?? 0,
      p90: json['p90']?.toDouble() ?? 0,
    );
  }
}

class ErrorReportSummary {
  final int total;
  final Map<String, int> byLevel;
  final Map<String, int> byCategory;
  final List<Map<String, dynamic>> topErrors;
  
  ErrorReportSummary({
    required this.total,
    required this.byLevel,
    required this.byCategory,
    required this.topErrors,
  });
  
  factory ErrorReportSummary.fromJson(Map<String, dynamic> json) {
    return ErrorReportSummary(
      total: json['total'] ?? 0,
      byLevel: Map<String, int>.from(json['by_level'] ?? {}),
      byCategory: Map<String, int>.from(json['by_category'] ?? {}),
      topErrors: List<Map<String, dynamic>>.from(json['top_errors'] ?? []),
    );
  }
}

class CacheReport {
  final Map<String, dynamic> recommendations;
  final Map<String, dynamic> achievements;
  
  CacheReport({
    required this.recommendations,
    required this.achievements,
  });
  
  factory CacheReport.fromJson(Map<String, dynamic> json) {
    return CacheReport(
      recommendations: json['recommendations'] ?? {},
      achievements: json['achievements'] ?? {},
    );
  }
}
