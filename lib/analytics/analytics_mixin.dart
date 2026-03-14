import 'package:flutter/material.dart';
import '../analytics_service.dart';

/// 页面埋点 Mixin
/// 混入 StatefulWidget 自动处理页面浏览和离开事件
/// 
/// 使用示例：
/// ```dart
/// class _MyScreenState extends State<MyScreen> with AnalyticsMixin {
///   @override
///   String get pageId => 'my_screen';
///   
///   @override
///   String get pageName => '我的页面';
/// }
/// ```
mixin AnalyticsMixin<T extends StatefulWidget> on State<T> {
  /// 页面标识（子类必须实现）
  String get pageId;
  
  /// 页面名称（子类必须实现）
  String get pageName;
  
  /// 额外参数（可选）
  Map<String, dynamic>? get pageParams => null;

  DateTime? _pageEnterTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trackPageView();
    });
  }

  @override
  void dispose() {
    _trackPageExit();
    super.dispose();
  }

  /// 上报页面浏览事件
  void _trackPageView() {
    AnalyticsService().trackPageView(pageId, pageName, params: pageParams);
    _pageEnterTime = DateTime.now();
  }

  /// 上报页面离开事件
  void _trackPageExit() {
    AnalyticsService().trackPageExit(pageId);
  }

  /// 手动上报自定义事件（便捷方法）
  void trackEvent(String eventName, {Map<String, dynamic>? params}) {
    AnalyticsService().trackEvent(eventName, params: params);
  }
}
