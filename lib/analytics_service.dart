import 'package:flutter/foundation.dart';

/// 全局 Analytics 服务单例
/// 
/// 使用示例：
/// ```dart
/// AnalyticsService().trackEvent('page_view', params: {'page': 'home'});
/// ```
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  
  factory AnalyticsService() => _instance;
  
  AnalyticsService._internal();
  
  bool _initialized = false;
  
  /// 初始化 Analytics
  Future<void> initialize() async {
    if (_initialized) return;
    
    // TODO: 接入实际的埋点 SDK（友盟、神策等）
    if (kDebugMode) {
      print('[Analytics] 初始化完成');
    }
    
    _initialized = true;
  }
  
  /// 追踪事件
  /// 
  /// [eventName] 事件名称
  /// [params] 事件参数
  void trackEvent(String eventName, {Map<String, dynamic>? params}) {
    if (!_initialized) {
      initialize();
    }
    
    if (kDebugMode) {
      print('[Analytics] Event: $eventName, Params: $params');
    }
    
    // TODO: 调用实际的埋点 SDK
  }
  
  /// 追踪页面浏览
  /// 
  /// [pageName] 页面名称
  /// [params] 额外参数
  void trackPageView(String pageName, {Map<String, dynamic>? params}) {
    trackEvent('page_view', params: {
      'page': pageName,
      ...?params,
    });
  }
  
  /// 设置用户属性
  /// 
  /// [userId] 用户ID
  /// [properties] 用户属性
  void setUserProperties(String userId, {Map<String, dynamic>? properties}) {
    if (kDebugMode) {
      print('[Analytics] Set User: $userId, Properties: $properties');
    }
    
    // TODO: 调用实际的埋点 SDK
  }
}

/// 导航相关事件常量
class NavigationEvents {
  static const String navigationStart = 'navigation_start';
  static const String navigationPause = 'navigation_pause';
  static const String navigationResume = 'navigation_resume';
  static const String navigationComplete = 'navigation_complete';
  static const String navigationOffRoute = 'navigation_off_route';
  static const String navigationSosTriggered = 'navigation_sos_triggered';
  
  // 参数名
  static const String paramRouteName = 'route_name';
  static const String paramDuration = 'duration';
  static const String paramDistance = 'distance';
}

/// 路线相关事件常量
class TrailEvents {
  static const String trailView = 'trail_view';
  static const String trailFavorite = 'trail_favorite';
  static const String trailShare = 'trail_share';
  static const String trailNavigate = 'trail_navigate';
  
  // 参数名
  static const String paramTrailId = 'trail_id';
  static const String paramTrailName = 'trail_name';
}
