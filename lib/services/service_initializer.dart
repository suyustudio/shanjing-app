// ================================================================
// Service Initialization
// 服务初始化 - 统一初始化和配置所有监控服务
// ================================================================

import 'package:flutter/foundation.dart';
import 'analytics_service.dart';
import 'performance_monitor_service.dart';
import 'error_monitor_service.dart';
import 'recommendation_service.dart';
import 'achievement_service.dart';
import 'api_service.dart';
import 'auth_service.dart';

/// 服务初始化管理器
class ServiceInitializer {
  static final ServiceInitializer _instance = ServiceInitializer._internal();
  static ServiceInitializer get instance => _instance;
  
  ServiceInitializer._internal();
  
  bool _isInitialized = false;
  String? _userId;
  String? _sessionId;
  
  /// 是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 初始化所有服务
  Future<void> initialize({
    String? userId,
    bool enableErrorReporting = true,
    bool enablePerformanceMonitoring = true,
    bool enableAnalytics = true,
  }) async {
    if (_isInitialized) {
      debugPrint('Services already initialized');
      return;
    }
    
    _userId = userId;
    _sessionId = _generateSessionId();
    
    debugPrint('🚀 Initializing services...');
    
    // 1. 初始化错误监控 (最先初始化以捕获其他服务的错误)
    if (enableErrorReporting) {
      _initializeErrorMonitor();
    }
    
    // 2. 初始化性能监控
    if (enablePerformanceMonitoring) {
      _initializePerformanceMonitor();
    }
    
    // 3. 初始化埋点服务
    if (enableAnalytics) {
      await _initializeAnalytics();
    }
    
    // 4. 设置全局错误处理
    _setupGlobalErrorHandling();
    
    _isInitialized = true;
    debugPrint('✅ All services initialized successfully');
    debugPrint('   Session ID: $_sessionId');
  }
  
  /// 用户登录后更新服务配置
  void onUserLogin(String userId) {
    _userId = userId;
    
    // 更新各服务的用户ID
    AnalyticsService.instance.setUserId(userId);
    ErrorMonitorService.instance.setUserId(userId);
    
    debugPrint('👤 User logged in: $userId');
  }
  
  /// 用户登出时清理
  void onUserLogout() {
    _userId = null;
    
    // 清理用户相关数据
    AnalyticsService.instance.setUserId(null);
    ErrorMonitorService.instance.setUserId(null);
    
    // 重置缓存
    RecommendationService().clearCache();
    AchievementService.instance.clearCache();
    
    // 重置性能监控
    PerformanceMonitorService.instance.clearMetrics();
    PerformanceMonitorService.instance.resetCacheStats();
    
    debugPrint('👤 User logged out');
  }
  
  /// 页面切换时更新当前路由
  void onRouteChanged(String routeName) {
    ErrorMonitorService.instance.setCurrentRoute(routeName);
    debugPrint('📍 Route changed: $routeName');
  }
  
  /// 获取当前会话ID
  String? get sessionId => _sessionId;
  
  /// 获取当前用户ID
  String? get userId => _userId;
  
  // ============ 私有方法 ============
  
  void _initializeErrorMonitor() {
    ErrorMonitorService.instance.initialize(
      sessionId: _sessionId,
      userId: _userId,
      minReportLevel: kDebugMode ? ErrorLevel.error : ErrorLevel.warning,
      catchFlutterErrors: true,
      catchPlatformErrors: true,
    );
    
    debugPrint('✅ ErrorMonitor initialized');
  }
  
  void _initializePerformanceMonitor() {
    PerformanceMonitorService.instance.initialize(
      sessionId: _sessionId,
    );
    
    // 设置性能阈值
    PerformanceMonitorService.instance.setThreshold(
      PerformanceMetricType.apiResponseTime, 
      500, // API 响应 > 500ms 警告
    );
    PerformanceMonitorService.instance.setThreshold(
      PerformanceMetricType.achievementCheckTime, 
      200, // 成就检查 > 200ms 警告
    );
    PerformanceMonitorService.instance.setThreshold(
      PerformanceMetricType.recommendationComputeTime, 
      300, // 推荐计算 > 300ms 警告
    );
    
    debugPrint('✅ PerformanceMonitor initialized');
  }
  
  Future<void> _initializeAnalytics() async {
    await AnalyticsService.instance.initialize(userId: _userId);
    
    // 上报应用启动事件
    AnalyticsService.instance.logEvent('app_launch', parameters: {
      'session_id': _sessionId,
      'is_debug': kDebugMode,
    });
    
    debugPrint('✅ Analytics initialized');
  }
  
  void _setupGlobalErrorHandling() {
    // Flutter 错误处理
    FlutterError.onError = (FlutterErrorDetails details) {
      // 上报到错误监控
      ErrorMonitorService.instance.reportError(
        message: details.exceptionAsString(),
        level: ErrorLevel.error,
        category: ErrorCategory.flutter,
        error: details.exception,
        stackTrace: details.stack,
      );
      
      // 同时上报到埋点
      AnalyticsService.instance.logError(
        errorType: 'flutter_error',
        errorMessage: details.exceptionAsString(),
        stackTrace: details.stack.toString(),
        category: 'flutter',
      );
      
      // 调用默认处理器
      FlutterError.dumpErrorToConsole(details);
    };
    
    debugPrint('✅ Global error handling configured');
  }
  
  String _generateSessionId() {
    return 'sess_${DateTime.now().millisecondsSinceEpoch}_${(1000 + DateTime.now().millisecond).toString().padLeft(4, '0')}';
  }
}

/// 简化的服务访问
class Services {
  static AnalyticsService get analytics => AnalyticsService.instance;
  static PerformanceMonitorService get performance => PerformanceMonitorService.instance;
  static ErrorMonitorService get error => ErrorMonitorService.instance;
  static AchievementService get achievement => AchievementService.instance;
  static RecommendationService get recommendation => RecommendationService();
}
