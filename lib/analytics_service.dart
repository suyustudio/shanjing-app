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
  /// [pageId] 页面ID
  /// [pageName] 页面名称
  /// [params] 额外参数
  void trackPageView(String pageId, String pageName, {Map<String, dynamic>? params}) {
    trackEvent('page_view', params: {
      'page_id': pageId,
      'page_name': pageName,
      ...?params,
    });
  }
  
  /// 追踪页面离开
  /// 
  /// [pageId] 页面ID
  void trackPageExit(String pageId) {
    trackEvent('page_exit', params: {
      'page_id': pageId,
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

/// 地图相关事件常量
class MapEvents {
  static const String mapView = 'map_view';
  static const String mapDownloadStart = 'map_download_start';
  static const String mapDownloadComplete = 'map_download_complete';
  static const String mapDownloadCancel = 'map_download_cancel';
  static const String mapCitySelect = 'map_city_select';
  static const String offlineMapDownload = 'offline_map_download';
  static const String offlineMapDelete = 'offline_map_delete';
  
  // 参数名
  static const String paramCityName = 'city_name';
  static const String paramCityCode = 'city_code';
  static const String paramDownloadSize = 'download_size';
  static const String paramDownloadResult = 'download_result';
}

/// 路线相关事件常量
class TrailEvents {
  static const String trailView = 'trail_view';
  static const String trailFavorite = 'trail_favorite';
  static const String trailShare = 'trail_share';
  static const String trailNavigate = 'trail_navigate';
  static const String trailNavigateComplete = 'trail_navigate_complete';

  // 参数名
  static const String paramTrailId = 'trail_id';
  static const String paramTrailName = 'trail_name';
  static const String paramCompletionTime = 'completion_time';
}

/// 认证相关事件常量
class AuthEvents {
  static const String loginSuccess = 'login_success';
  static const String loginFailed = 'login_failed';
  static const String registerSuccess = 'register_success';
  static const String registerFailed = 'register_failed';
  static const String logout = 'logout';

  // 参数名
  static const String paramUserId = 'user_id';
  static const String paramPhone = 'phone';
  static const String paramMethod = 'method'; // phone, password, wechat
  static const String paramErrorCode = 'error_code';
  static const String paramErrorMessage = 'error_message';
}

/// 分享相关事件常量
class ShareEvents {
  static const String shareTrail = 'share_trail';
  static const String shareTrailSuccess = 'share_trail_success';
  static const String shareTrailFailed = 'share_trail_failed';

  // 参数名
  static const String paramTrailId = 'trail_id';
  static const String paramShareCode = 'share_code';
  static const String paramErrorCode = 'error_code';
}

/// SOS 相关事件常量
class SosEvents {
  static const String sosTriggered = 'sos_triggered';
  static const String sosSuccess = 'sos_success';
  static const String sosFailed = 'sos_failed';

  // 参数名
  static const String paramLatitude = 'latitude';
  static const String paramLongitude = 'longitude';
  static const String paramAccuracy = 'accuracy';
  static const String paramErrorCode = 'error_code';
}

/// 页面相关事件常量
class PageEvents {
  static const String pageDiscovery = 'page_discovery';
  static const String pageTrailDetail = 'page_trail_detail';
  static const String pageNavigation = 'page_navigation';
  static const String pageProfile = 'page_profile';
  static const String pageOfflineMap = 'page_offline_map';

  // 页面名称
  static const String nameDiscovery = '发现';
  static const String nameTrailDetail = '路线详情';
  static const String nameNavigation = '导航';
  static const String nameProfile = '我的';
  static const String nameOfflineMap = '离线地图';
}

/// 用户行为事件常量
class UserEvents {
  static const String appBackground = 'app_background';
  static const String appForeground = 'app_foreground';
}
