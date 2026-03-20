// ================================================================
// Analytics Service
// 数据埋点服务 - 完整版 (M5)
//
// 埋点事件列表:
// ============ 成就系统 ============
// - achievement_page_view: 成就页面访问
// - achievement_tab_click: Tab切换
// - achievement_detail_view: 查看成就详情
// - achievement_unlock: 成就解锁
// - achievement_share_click: 点击分享按钮
// - achievement_share_success: 分享成功
// - achievement_share: 徽章分享 (新增)
// - achievement_card_save: 保存分享卡片
// - achievement_scroll: 徽章墙滚动 (新增)
//
// ============ 推荐算法 ============
// - recommendation_impression: 推荐曝光 (新增)
// - recommendation_click: 推荐点击 (新增)
// - recommendation_bookmark: 推荐收藏转化 (新增)
// - recommendation_complete: 推荐完成转化 (新增)
// ================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/connectivity_service.dart';
import '../services/performance_monitor_service.dart';
import '../services/error_monitor_service.dart';

/// 埋点事件
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;
  final String? userId;
  final String sessionId;
  
  AnalyticsEvent({
    required this.name,
    this.parameters = const {},
    DateTime? timestamp,
    this.userId,
    required this.sessionId,
  }) : timestamp = timestamp ?? DateTime.now();
  
  Map<String, dynamic> toJson() => {
    'name': name,
    'parameters': parameters,
    'timestamp': timestamp.toIso8601String(),
    'user_id': userId,
    'session_id': sessionId,
  };
  
  factory AnalyticsEvent.fromJson(Map<String, dynamic> json) {
    return AnalyticsEvent(
      name: json['name'],
      parameters: json['parameters'] ?? {},
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['user_id'],
      sessionId: json['session_id'],
    );
  }
}

/// 埋点服务
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  static AnalyticsService get instance => _instance;
  
  AnalyticsService._internal();
  
  final ApiService _apiService = ApiService.instance;
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final PerformanceMonitorService _performanceMonitor = PerformanceMonitorService.instance;
  final ErrorMonitorService _errorMonitor = ErrorMonitorService.instance;
  
  // 事件队列
  final List<AnalyticsEvent> _eventQueue = [];
  final StreamController<AnalyticsEvent> _eventController = 
      StreamController<AnalyticsEvent>.broadcast();
  
  // 配置
  static const int _maxQueueSize = 100;
  static const Duration _flushInterval = Duration(seconds: 30);
  static const String _prefsKey = 'analytics_offline_events';
  
  // 会话ID
  late final String _sessionId;
  String? _userId;
  Timer? _flushTimer;
  bool _isInitialized = false;
  
  Stream<AnalyticsEvent> get eventStream => _eventController.stream;
  
  /// 初始化
  Future<void> initialize({String? userId}) async {
    if (_isInitialized) return;
    
    _sessionId = _generateSessionId();
    _userId = userId;
    
    // 恢复离线事件
    await _restoreOfflineEvents();
    
    // 启动定时上传
    _flushTimer = Timer.periodic(_flushInterval, (_) => _flush());
    
    // 监听网络状态，联网时上传
    _connectivityService.onConnectivityChanged.listen((isConnected) {
      if (isConnected && _eventQueue.isNotEmpty) {
        _flush();
      }
    });
    
    _isInitialized = true;
    debugPrint('AnalyticsService initialized, session: $_sessionId');
  }
  
  /// 设置用户ID
  void setUserId(String? userId) {
    _userId = userId;
  }
  
  /// 获取会话ID
  String get sessionId => _sessionId;
  
  /// 记录事件
  void logEvent(String name, {Map<String, dynamic>? parameters}) {
    if (!_isInitialized) {
      debugPrint('AnalyticsService not initialized, event dropped: $name');
      return;
    }
    
    final event = AnalyticsEvent(
      name: name,
      parameters: parameters ?? {},
      userId: _userId,
      sessionId: _sessionId,
    );
    
    // 添加到队列
    _eventQueue.add(event);
    _eventController.add(event);
    
    // 队列满时立即上传
    if (_eventQueue.length >= _maxQueueSize) {
      _flush();
    }
    
    if (kDebugMode) {
      debugPrint('📊 Analytics: $name, params: $parameters');
    }
  }
  
  /// 页面访问埋点
  void logPageView(String pageName, {Map<String, dynamic>? parameters}) {
    logEvent('${pageName}_page_view', parameters: parameters);
  }
  
  /// 按钮点击埋点
  void logButtonClick(String buttonName, {Map<String, dynamic>? parameters}) {
    logEvent('${buttonName}_click', parameters: parameters);
  }
  
  /// 立即上传所有事件
  Future<void> flush() async {
    await _flush();
  }
  
  /// 上传事件
  Future<void> _flush() async {
    if (_eventQueue.isEmpty) return;
    if (!await _connectivityService.isConnected()) {
      // 离线状态，保存到本地
      await _saveOfflineEvents();
      return;
    }
    
    final eventsToSend = List<AnalyticsEvent>.from(_eventQueue);
    _eventQueue.clear();
    
    try {
      final payload = eventsToSend.map((e) => e.toJson()).toList();
      
      await _apiService.post('/analytics/events', body: {
        'events': payload,
        'session_id': _sessionId,
        'device_info': await _getDeviceInfo(),
      });
      
      if (kDebugMode) {
        debugPrint('📊 Analytics flushed: ${eventsToSend.length} events');
      }
    } catch (e) {
      // 上传失败，重新加入队列
      _eventQueue.insertAll(0, eventsToSend);
      await _saveOfflineEvents();
      
      // 记录错误
      _errorMonitor.reportApiError('analytics_flush', e);
      debugPrint('Analytics flush failed: $e');
    }
  }
  
  /// 保存离线事件
  Future<void> _saveOfflineEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = _eventQueue.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList(_prefsKey, eventsJson);
  }
  
  /// 恢复离线事件
  Future<void> _restoreOfflineEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventsJson = prefs.getStringList(_prefsKey);
    
    if (eventsJson != null && eventsJson.isNotEmpty) {
      for (final json in eventsJson) {
        try {
          final event = AnalyticsEvent.fromJson(jsonDecode(json));
          _eventQueue.add(event);
        } catch (e) {
          debugPrint('Failed to restore analytics event: $e');
        }
      }
      
      // 清空已保存的
      await prefs.remove(_prefsKey);
      
      debugPrint('Restored ${_eventQueue.length} offline analytics events');
    }
  }
  
  /// 获取设备信息
  Future<Map<String, dynamic>> _getDeviceInfo() async {
    return {
      'platform': 'mobile',
      'app_version': '1.0.0', // 从 package_info 获取
      'os_version': '', // 从 device_info 获取
      'device_model': '',
    };
  }
  
  /// 生成会话ID
  String _generateSessionId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(10000)}';
  }
  
  /// 释放资源
  void dispose() {
    _flushTimer?.cancel();
    _eventController.close();
    _saveOfflineEvents();
  }
}

// ================================================================
// 成就系统专用埋点扩展
// ================================================================
extension AchievementAnalytics on AnalyticsService {
  /// 成就页面访问
  void logAchievementPageView() {
    logPageView('achievement');
  }
  
  /// 成就Tab点击
  void logAchievementTabClick(String tabName) {
    logEvent('achievement_tab_click', parameters: {'tab_name': tabName});
  }
  
  /// 成就详情查看
  void logAchievementDetailView(String achievementId) {
    logEvent('achievement_detail_view', parameters: {
      'achievement_id': achievementId,
    });
  }
  
  /// 成就解锁
  void logAchievementUnlock(String achievementId, String level) {
    logEvent('achievement_unlock', parameters: {
      'achievement_id': achievementId,
      'level': level,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// 分享按钮点击
  void logAchievementShareClick(String achievementId, String channel) {
    logEvent('achievement_share_click', parameters: {
      'achievement_id': achievementId,
      'channel': channel,
    });
  }
  
  /// 分享成功
  void logAchievementShareSuccess(String achievementId, String channel) {
    logEvent('achievement_share_success', parameters: {
      'achievement_id': achievementId,
      'channel': channel,
    });
  }
  
  /// 保存分享卡片
  void logAchievementCardSave(String achievementId) {
    logEvent('achievement_card_save', parameters: {
      'achievement_id': achievementId,
    });
  }
  
  // ==================== M5 新增埋点 ====================
  
  /// 徽章分享事件 (achievement_share)
  /// 当用户分享徽章时触发
  void logAchievementShare({
    required String achievementId,
    required String achievementName,
    required String level,
    required String channel,
    String? shareType, // 'card', 'poster', 'link'
  }) {
    logEvent('achievement_share', parameters: {
      'achievement_id': achievementId,
      'achievement_name': achievementName,
      'level': level,
      'channel': channel,
      'share_type': shareType ?? 'card',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// 徽章墙滚动事件 (achievement_scroll)
  /// 当用户滚动徽章墙时触发，用于分析用户浏览深度
  void logAchievementScroll({
    required double scrollOffset,
    required double maxScrollExtent,
    required int visibleBadgeCount,
    String? category,
  }) {
    // 计算滚动深度百分比
    final scrollPercent = maxScrollExtent > 0 
        ? (scrollOffset / maxScrollExtent * 100).round() 
        : 0;
    
    // 每滚动25%触发一次，避免过多事件
    final depthBucket = (scrollPercent ~/ 25) * 25;
    
    logEvent('achievement_scroll', parameters: {
      'scroll_offset': scrollOffset.round(),
      'scroll_percent': scrollPercent,
      'depth_bucket': '${depthBucket}%-${depthBucket + 25}%',
      'visible_badge_count': visibleBadgeCount,
      'category': category ?? 'all',
    });
  }
}

// ================================================================
// 推荐算法专用埋点扩展
// ================================================================
extension RecommendationAnalytics on AnalyticsService {
  /// 推荐曝光事件 (recommendation_impression)
  /// 当推荐内容展示给用户时触发
  void logRecommendationImpression({
    required String scene, // 'home', 'list', 'similar', 'nearby'
    required List<String> trailIds,
    String? logId,
    Map<String, double>? matchScores,
  }) {
    if (trailIds.isEmpty) return;
    
    final params = {
      'scene': scene,
      'trail_ids': trailIds,
      'trail_count': trailIds.length,
      'log_id': logId,
      'timestamp': DateTime.now().toIso8601String(),
    };
    
    // 如果有匹配度分数，计算平均匹配度
    if (matchScores != null && matchScores.isNotEmpty) {
      final avgScore = matchScores.values.reduce((a, b) => a + b) / matchScores.length;
      params['avg_match_score'] = (avgScore * 100).round();
    }
    
    logEvent('recommendation_impression', parameters: params);
  }
  
  /// 推荐点击事件 (recommendation_click)
  /// 当用户点击推荐路线时触发
  void logRecommendationClick({
    required String scene,
    required String trailId,
    required int position, // 在列表中的位置 (0-based)
    double? matchScore,
    String? logId,
    String? source, // 'home_card', 'list_item', 'similar_card'
  }) {
    logEvent('recommendation_click', parameters: {
      'scene': scene,
      'trail_id': trailId,
      'position': position,
      'match_score': matchScore != null ? (matchScore * 100).round() : null,
      'log_id': logId,
      'source': source ?? 'unknown',
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// 推荐收藏转化 (recommendation_bookmark)
  /// 当用户收藏推荐路线时触发
  void logRecommendationBookmark({
    required String scene,
    required String trailId,
    double? matchScore,
    String? logId,
    int? timeToBookmark, // 从曝光到收藏的毫秒数
  }) {
    logEvent('recommendation_bookmark', parameters: {
      'scene': scene,
      'trail_id': trailId,
      'match_score': matchScore != null ? (matchScore * 100).round() : null,
      'log_id': logId,
      'time_to_bookmark_ms': timeToBookmark,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// 推荐完成转化 (recommendation_complete)
  /// 当用户完成推荐路线时触发
  void logRecommendationComplete({
    required String scene,
    required String trailId,
    double? matchScore,
    String? logId,
    int? timeToComplete, // 从曝光到完成的毫秒数
    int? durationMinutes, // 实际徒步时长
  }) {
    logEvent('recommendation_complete', parameters: {
      'scene': scene,
      'trail_id': trailId,
      'match_score': matchScore != null ? (matchScore * 100).round() : null,
      'log_id': logId,
      'time_to_complete_ms': timeToComplete,
      'duration_minutes': durationMinutes,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  /// 推荐排序切换
  void logRecommendationSort({
    required String sortType, // 'recommend', 'distance', 'rating', 'newest'
    String? previousSort,
  }) {
    logEvent('recommendation_sort', parameters: {
      'sort_type': sortType,
      'previous_sort': previousSort,
    });
  }
}

// ================================================================
// 性能监控埋点扩展
// ================================================================
extension PerformanceAnalytics on AnalyticsService {
  /// API 响应时间埋点
  void logApiPerformance({
    required String apiName,
    required int responseTimeMs,
    required bool success,
    int? statusCode,
  }) {
    logEvent('api_performance', parameters: {
      'api_name': apiName,
      'response_time_ms': responseTimeMs,
      'success': success,
      'status_code': statusCode,
    });
  }
  
  /// 成就检查耗时埋点
  void logAchievementCheckPerformance({
    required int checkTimeMs,
    String? triggerType,
    int? unlockedCount,
  }) {
    logEvent('achievement_check_performance', parameters: {
      'check_time_ms': checkTimeMs,
      'trigger_type': triggerType ?? 'unknown',
      'unlocked_count': unlockedCount ?? 0,
    });
  }
  
  /// 缓存命中率埋点 (定期上报)
  void logCacheHitRate({
    required String cacheName,
    required double hitRate,
    required int hitCount,
    required int missCount,
  }) {
    logEvent('cache_hit_rate', parameters: {
      'cache_name': cacheName,
      'hit_rate': (hitRate * 100).round(),
      'hit_count': hitCount,
      'miss_count': missCount,
      'total_requests': hitCount + missCount,
    });
  }
}

// ================================================================
// 错误监控埋点扩展
// ================================================================
extension ErrorAnalytics on AnalyticsService {
  /// 错误上报埋点
  void logError({
    required String errorType,
    required String errorMessage,
    String? stackTrace,
    String? category, // 'network', 'api', 'database', 'ui', 'unknown'
  }) {
    logEvent('app_error', parameters: {
      'error_type': errorType,
      'error_message': errorMessage.substring(0, errorMessage.length > 200 ? 200 : errorMessage.length),
      'has_stack_trace': stackTrace != null,
      'category': category ?? 'unknown',
    });
  }
  
  /// API 错误埋点
  void logApiError({
    required String apiName,
    required int statusCode,
    String? errorMessage,
  }) {
    logEvent('api_error', parameters: {
      'api_name': apiName,
      'status_code': statusCode,
      'error_message': errorMessage,
    });
  }
  
  /// 推荐系统错误埋点
  void logRecommendationError({
    required String scene,
    required String errorType,
    String? errorMessage,
  }) {
    logEvent('recommendation_error', parameters: {
      'scene': scene,
      'error_type': errorType,
      'error_message': errorMessage,
    });
  }
}
