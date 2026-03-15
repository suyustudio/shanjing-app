import 'package:flutter/material.dart';
// 暂时注释友盟 SDK，解决构建问题
// import 'package:umeng_analytics_plugin/umeng_analytics_plugin.dart';

/// 埋点服务统一接口
/// 采用适配器模式封装友盟 SDK，便于未来切换其他埋点方案
/// 
/// TODO: 恢复友盟 SDK 集成（移除注释）
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();

  bool _initialized = false;
  bool _debugMode = false;
  String? _currentUserId;
  String? _currentPageId;
  DateTime? _pageEnterTime;

  /// 是否已初始化
  bool get isInitialized => _initialized;

  /// 当前用户ID
  String? get currentUserId => _currentUserId;

  /// 初始化埋点 SDK
  /// 
  /// [androidKey] - Android 应用的友盟 AppKey
  /// [iosKey] - iOS 应用的友盟 AppKey
  /// [channel] - 渠道标识，如 'App Store', '应用宝' 等
  /// [debugMode] - 是否开启调试模式（DEBUG 模式关闭、发布模式开启）
  Future<void> initialize({
    required String androidKey,
    required String iosKey,
    String channel = 'official',
    bool debugMode = false,
  }) async {
    if (_initialized) return;

    _debugMode = debugMode;

    // TODO: 恢复友盟 SDK 初始化
    // try {
    //   await UmengAnalyticsPlugin.init(
    //     androidKey: androidKey,
    //     iosKey: iosKey,
    //     channel: channel,
    //     logEnabled: debugMode,
    //   );
    //   _initialized = true;
    //   _log('AnalyticsService 初始化成功');
    // } catch (e) {
    //   _log('AnalyticsService 初始化失败: $e', isError: true);
    // }
    
    // 临时：标记为已初始化但不实际调用 SDK
    _initialized = true;
    _log('AnalyticsService 初始化成功（友盟 SDK 已禁用）');
  }

  /// 设置用户身份（登录后调用）
  /// 
  /// [userId] - 用户唯一标识
  /// [properties] - 用户属性，如会员等级、地区等
  Future<void> setUserId(String userId, {Map<String, dynamic>? properties}) async {
    if (!_initialized) return;

    _currentUserId = userId;
    
    // TODO: 恢复友盟 SDK 调用
    // try {
    //   if (properties != null) {
    //     await UmengAnalyticsPlugin.profileSignInWithPUID(userId);
    //   } else {
    //     await UmengAnalyticsPlugin.profileSignInWithPUID(userId);
    //   }
    //   _log('设置用户 ID: $userId');
    // } catch (e) {
    //   _log('设置用户 ID 失败: $e', isError: true);
    // }
    
    _log('设置用户 ID: $userId（友盟 SDK 已禁用）');
  }

  /// 清除用户身份（退出登录后调用）
  Future<void> clearUserId() async {
    if (!_initialized) return;

    // TODO: 恢复友盟 SDK 调用
    // try {
    //   await UmengAnalyticsPlugin.profileSignOff();
    //   _currentUserId = null;
    //   _log('清除用户 ID');
    // } catch (e) {
    //   _log('清除用户 ID 失败: $e', isError: true);
    // }
    
    _currentUserId = null;
    _log('清除用户 ID（友盟 SDK 已禁用）');
  }

  /// 页面浏览事件
  /// 
  /// [pageId] - 页面标识，如 'map', 'discovery', 'trail_detail'
  /// [pageName] - 页面名称（中文）
  /// [params] - 额外参数，如路线 ID、搜索关键词等
  void trackPageView(
    String pageId,
    String pageName, {
    Map<String, dynamic>? params,
  }) {
    if (!_initialized) return;

    _currentPageId = pageId;
    _pageEnterTime = DateTime.now();

    final eventParams = <String, dynamic>{
      'page_id': pageId,
      'page_name': pageName,
      'timestamp': _pageEnterTime!.millisecondsSinceEpoch,
      if (_currentUserId != null) 'user_id': _currentUserId,
      if (params != null) ...params,
    };

    _trackEvent('page_view', eventParams);
    _log('页面浏览: $pageId ($pageName)');
  }

  /// 页面离开事件
  /// 
  /// [pageId] - 页面标识
  void trackPageExit(String pageId) {
    if (!_initialized) return;
    if (_pageEnterTime == null) return;

    final duration = DateTime.now().difference(_pageEnterTime!).inMilliseconds;

    final eventParams = <String, dynamic>{
      'page_id': pageId,
      'duration': duration,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (_currentUserId != null) 'user_id': _currentUserId,
    };

    _trackEvent('page_exit', eventParams);
    _log('页面离开: $pageId, 停留 ${duration}ms');

    _currentPageId = null;
    _pageEnterTime = null;
  }

  /// 自定义事件埋点
  /// 
  /// [eventName] - 事件名称
  /// [params] - 事件参数
  void trackEvent(String eventName, {Map<String, dynamic>? params}) {
    if (!_initialized) return;

    final eventParams = <String, dynamic>{
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      if (_currentUserId != null) 'user_id': _currentUserId,
      if (_currentPageId != null) 'page_id': _currentPageId,
      if (params != null) ...params,
    };

    _trackEvent(eventName, eventParams);
    _log('事件: $eventName, 参数: $eventParams');
  }

  /// 上报事件到友盟
  void _trackEvent(String eventName, Map<String, dynamic> params) {
    // TODO: 恢复友盟 SDK 调用
    // try {
    //   final paramsString = params.entries
    //       .map((e) => '${e.key}:${e.value}')
    //       .join('|');
    //   UmengAnalyticsPlugin.event(eventName, label: paramsString);
    // } catch (e) {
    //   _log('事件上报失败: $e', isError: true);
    // }
  }

  /// 日志输出
  void _log(String message, {bool isError = false}) {
    if (_debugMode) {
      final prefix = isError ? '❌ [Analytics]' : '✅ [Analytics]';
      debugPrint('$prefix $message');
    }
  }
}
