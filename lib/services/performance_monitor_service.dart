// ================================================================
// Performance Monitoring Service
// 性能监控服务 - 测量 API 响应时间、操作耗时、缓存命中率等
// ================================================================

import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';

/// 性能指标类型
enum PerformanceMetricType {
  apiResponseTime,      // API 响应时间
  achievementCheckTime, // 成就检查耗时
  cacheHitRate,         // 缓存命中率
  recommendationComputeTime, // 推荐计算耗时
  pageLoadTime,         // 页面加载时间
  databaseQueryTime,    // 数据库查询时间
}

/// 性能指标记录
class PerformanceMetric {
  final String name;
  final PerformanceMetricType type;
  final double value; // 毫秒或百分比
  final DateTime timestamp;
  final Map<String, dynamic>? tags;
  final String? sessionId;

  PerformanceMetric({
    required this.name,
    required this.type,
    required this.value,
    this.tags,
    this.sessionId,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.name,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'tags': tags,
    'session_id': sessionId,
  };
}

/// 性能计时器
class PerformanceTimer {
  final Stopwatch _stopwatch = Stopwatch();
  final String name;
  final PerformanceMetricType type;
  final Map<String, dynamic>? tags;
  final String? sessionId;
  final void Function(PerformanceMetric)? onComplete;

  PerformanceTimer({
    required this.name,
    required this.type,
    this.tags,
    this.sessionId,
    this.onComplete,
  });

  void start() => _stopwatch.start();
  void stop() => _stopwatch.stop();

  PerformanceMetric finish() {
    _stopwatch.stop();
    final metric = PerformanceMetric(
      name: name,
      type: type,
      value: _stopwatch.elapsedMilliseconds.toDouble(),
      tags: tags,
      sessionId: sessionId,
    );
    onComplete?.call(metric);
    return metric;
  }

  Duration get elapsed => _stopwatch.elapsed;
}

/// 缓存统计
class CacheStats {
  int hits = 0;
  int misses = 0;
  final String cacheName;

  CacheStats(this.cacheName);

  int get total => hits + misses;
  double get hitRate => total > 0 ? hits / total : 0.0;
  double get missRate => total > 0 ? misses / total : 0.0;

  void recordHit() => hits++;
  void recordMiss() => misses++;

  Map<String, dynamic> toJson() => {
    'cache_name': cacheName,
    'hits': hits,
    'misses': misses,
    'hit_rate': hitRate,
    'miss_rate': missRate,
    'total': total,
  };

  void reset() {
    hits = 0;
    misses = 0;
  }
}

/// 性能监控服务
class PerformanceMonitorService {
  static final PerformanceMonitorService _instance = PerformanceMonitorService._internal();
  static PerformanceMonitorService get instance => _instance;

  PerformanceMonitorService._internal();

  // 指标历史记录 (最多保留1000条)
  final List<PerformanceMetric> _metrics = [];
  static const int _maxMetricsSize = 1000;

  // 缓存统计
  final Map<String, CacheStats> _cacheStats = {};

  // 性能阈值配置 (毫秒)
  final Map<PerformanceMetricType, double> _thresholds = {
    PerformanceMetricType.apiResponseTime: 500,        // API 响应 > 500ms 警告
    PerformanceMetricType.achievementCheckTime: 200,   // 成就检查 > 200ms 警告
    PerformanceMetricType.recommendationComputeTime: 300, // 推荐计算 > 300ms 警告
    PerformanceMetricType.pageLoadTime: 1000,          // 页面加载 > 1s 警告
    PerformanceMetricType.databaseQueryTime: 100,      // 数据库查询 > 100ms 警告
  };

  // 会话ID
  String? _sessionId;

  // 流控制器
  final _metricController = StreamController<PerformanceMetric>.broadcast();
  Stream<PerformanceMetric> get metricStream => _metricController.stream;

  /// 初始化
  void initialize({String? sessionId}) {
    _sessionId = sessionId ?? _generateSessionId();
  }

  /// 设置会话ID
  void setSessionId(String sessionId) {
    _sessionId = sessionId;
  }

  /// 开始计时
  PerformanceTimer startTimer({
    required String name,
    required PerformanceMetricType type,
    Map<String, dynamic>? tags,
  }) {
    final timer = PerformanceTimer(
      name: name,
      type: type,
      tags: tags,
      sessionId: _sessionId,
      onComplete: _onMetricComplete,
    );
    timer.start();
    return timer;
  }

  /// 测量异步操作耗时
  Future<T> measureAsync<T>({
    required String name,
    required PerformanceMetricType type,
    required Future<T> Function() operation,
    Map<String, dynamic>? tags,
  }) async {
    final timer = startTimer(name: name, type: type, tags: tags);
    try {
      final result = await operation();
      return result;
    } finally {
      timer.finish();
    }
  }

  /// 测量同步操作耗时
  T measureSync<T>({
    required String name,
    required PerformanceMetricType type,
    required T Function() operation,
    Map<String, dynamic>? tags,
  }) {
    final timer = startTimer(name: name, type: type, tags: tags);
    try {
      final result = operation();
      return result;
    } finally {
      timer.finish();
    }
  }

  /// 记录 API 响应时间
  void recordApiResponseTime(String apiName, int milliseconds, {bool success = true}) {
    recordMetric(
      name: 'api_$apiName',
      type: PerformanceMetricType.apiResponseTime,
      value: milliseconds.toDouble(),
      tags: {'api': apiName, 'success': success},
    );
  }

  /// 记录成就检查耗时
  void recordAchievementCheckTime(int milliseconds, {String? triggerType}) {
    recordMetric(
      name: 'achievement_check',
      type: PerformanceMetricType.achievementCheckTime,
      value: milliseconds.toDouble(),
      tags: {'trigger': triggerType ?? 'unknown'},
    );
  }

  /// 记录推荐计算耗时
  void recordRecommendationComputeTime(int milliseconds, {String? scene}) {
    recordMetric(
      name: 'recommendation_compute',
      type: PerformanceMetricType.recommendationComputeTime,
      value: milliseconds.toDouble(),
      tags: {'scene': scene ?? 'unknown'},
    );
  }

  /// 记录缓存命中
  void recordCacheHit(String cacheName) {
    _getCacheStats(cacheName).recordHit();
  }

  /// 记录缓存未命中
  void recordCacheMiss(String cacheName) {
    _getCacheStats(cacheName).recordMiss();
  }

  /// 记录自定义指标
  void recordMetric({
    required String name,
    required PerformanceMetricType type,
    required double value,
    Map<String, dynamic>? tags,
  }) {
    final metric = PerformanceMetric(
      name: name,
      type: type,
      value: value,
      tags: tags,
      sessionId: _sessionId,
    );
    _onMetricComplete(metric);
  }

  /// 获取缓存统计
  CacheStats getCacheStats(String cacheName) {
    return _getCacheStats(cacheName);
  }

  /// 获取所有缓存统计
  Map<String, CacheStats> getAllCacheStats() {
    return Map.unmodifiable(_cacheStats);
  }

  /// 获取缓存命中率报告
  Map<String, dynamic> getCacheHitRateReport() {
    final report = <String, dynamic>{};
    _cacheStats.forEach((name, stats) {
      report[name] = stats.toJson();
    });
    return report;
  }

  /// 获取性能报告
  Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{
      'session_id': _sessionId,
      'generated_at': DateTime.now().toIso8601String(),
      'cache_stats': _cacheStats.map((k, v) => MapEntry(k, v.toJson())),
      'metrics_summary': _generateMetricsSummary(),
    };
    return report;
  }

  /// 获取所有指标
  List<PerformanceMetric> getAllMetrics() {
    return List.unmodifiable(_metrics);
  }

  /// 获取慢操作列表 (超过阈值的)
  List<PerformanceMetric> getSlowOperations() {
    return _metrics.where((m) {
      final threshold = _thresholds[m.type];
      if (threshold == null) return false;
      return m.value > threshold;
    }).toList();
  }

  /// 清空历史记录
  void clearMetrics() {
    _metrics.clear();
  }

  /// 重置缓存统计
  void resetCacheStats() {
    _cacheStats.forEach((_, stats) => stats.reset());
  }

  /// 设置性能阈值
  void setThreshold(PerformanceMetricType type, double milliseconds) {
    _thresholds[type] = milliseconds;
  }

  /// 检查是否需要警告 (超过阈值)
  bool shouldWarn(PerformanceMetric metric) {
    final threshold = _thresholds[metric.type];
    if (threshold == null) return false;
    return metric.value > threshold;
  }

  // ============ 私有方法 ============

  void _onMetricComplete(PerformanceMetric metric) {
    _metrics.add(metric);
    _metricController.add(metric);

    // 限制历史记录大小
    if (_metrics.length > _maxMetricsSize) {
      _metrics.removeAt(0);
    }

    // 调试输出
    if (kDebugMode) {
      final unit = metric.type == PerformanceMetricType.cacheHitRate ? '%' : 'ms';
      final value = metric.type == PerformanceMetricType.cacheHitRate
          ? (metric.value * 100).toStringAsFixed(1)
          : metric.value.toStringAsFixed(0);
      debugPrint('⏱️ Performance: ${metric.name} = $value$unit');

      // 慢操作警告
      if (shouldWarn(metric)) {
        final threshold = _thresholds[metric.type];
        debugPrint('⚠️ Slow operation: ${metric.name} took ${metric.value}ms (threshold: ${threshold}ms)');
      }
    }
  }

  CacheStats _getCacheStats(String cacheName) {
    return _cacheStats.putIfAbsent(cacheName, () => CacheStats(cacheName));
  }

  Map<String, dynamic> _generateMetricsSummary() {
    final summary = <String, dynamic>{};

    for (final type in PerformanceMetricType.values) {
      final typeMetrics = _metrics.where((m) => m.type == type).toList();
      if (typeMetrics.isEmpty) continue;

      final values = typeMetrics.map((m) => m.value).toList();
      values.sort();

      summary[type.name] = {
        'count': values.length,
        'avg': values.reduce((a, b) => a + b) / values.length,
        'min': values.first,
        'max': values.last,
        'p50': _percentile(values, 0.5),
        'p90': _percentile(values, 0.9),
        'p95': _percentile(values, 0.95),
        'p99': _percentile(values, 0.99),
      };
    }

    return summary;
  }

  double _percentile(List<double> sortedValues, double p) {
    if (sortedValues.isEmpty) return 0;
    final index = (sortedValues.length * p).ceil() - 1;
    return sortedValues[index.clamp(0, sortedValues.length - 1)];
  }

  String _generateSessionId() {
    return 'perf_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }

  /// 释放资源
  void dispose() {
    _metricController.close();
  }
}

/// 简化的 Random 类
class Random {
  static final _random = DateTime.now().millisecondsSinceEpoch;
  int nextInt(int max) => (_random % max).abs();
}

/// 性能监控 Mixin，方便在 State 类中使用
mixin PerformanceMonitorMixin<T extends StatefulWidget> on State<T> {
  final Map<String, PerformanceTimer> _timers = {};

  /// 开始页面加载计时
  void startPageLoadTimer(String pageName) {
    _timers['page_$pageName'] = PerformanceMonitorService.instance.startTimer(
      name: pageName,
      type: PerformanceMetricType.pageLoadTime,
      tags: {'page': pageName},
    );
  }

  /// 结束页面加载计时
  void finishPageLoadTimer(String pageName) {
    final timer = _timers.remove('page_$pageName');
    timer?.finish();
  }

  /// 测量 API 调用
  Future<R> measureApiCall<R>(String apiName, Future<R> Function() call) {
    return PerformanceMonitorService.instance.measureAsync(
      name: apiName,
      type: PerformanceMetricType.apiResponseTime,
      operation: call,
      tags: {'api': apiName},
    );
  }

  @override
  void dispose() {
    // 清理未完成的计时器
    for (final timer in _timers.values) {
      timer.finish();
    }
    _timers.clear();
    super.dispose();
  }
}
