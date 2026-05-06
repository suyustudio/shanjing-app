import 'dart:async';
import 'package:flutter/foundation.dart';

/// 导航信息类
class AMapNaviInfo {
  final double remainingDistance;
  final int remainingTime;
  final double currentSpeed;
  final String nextRoadName;
  final String nextAction;

  AMapNaviInfo({
    required this.remainingDistance,
    required this.remainingTime,
    this.currentSpeed = 1.4,
    this.nextRoadName = '',
    this.nextAction = '直行',
  });
}

/// 高德导航监听器接口
abstract class AmapNaviListener {
  void onServiceInitialized(bool success);
  void onRouteCalculationSuccess(int routeId);
  void onRouteCalculationFailure(String error);
  void onNaviInfoUpdate(AMapNaviInfo naviInfo);
  void onOffRouteDetected();
  void onArrivedDestination();
  void onNaviStarted();
  void onNaviStopped();
}

/// 步行策略枚举
enum WalkStrategy {
  FASTEST,
  SHORTEST,
  AVOID_CONGESTION,
  MULTI_PATH,
}

/// 高德导航服务
///
/// 导航进度由 amap_flutter_location 真实 GPS 定位驱动，
/// 路径规划由 MapService 调用高德 Web API 完成。
/// 本服务负责导航状态管理和事件通知。
class AmapNaviService {
  static final AmapNaviService _instance = AmapNaviService._internal();
  factory AmapNaviService() => _instance;
  AmapNaviService._internal();

  bool _isInitialized = false;
  bool _isNavigating = false;

  final List<AmapNaviListener> _listeners = [];

  /// 初始化导航服务
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    await Future.delayed(const Duration(milliseconds: 500));

    _isInitialized = true;
    _notifyListeners((listener) => listener.onServiceInitialized(true));

    debugPrint('✅ 高德导航服务初始化成功');
    return true;
  }

  /// 停止导航
  Future<void> stopNavigation() async {
    if (!_isNavigating) return;

    _isNavigating = false;

    _notifyListeners((listener) => listener.onNaviStopped());
    debugPrint('🛑 导航停止');
  }

  /// 恢复导航（从后台恢复时调用）
  Future<bool> resume() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }

    debugPrint('🔄 导航服务已恢复');
    return true;
  }

  /// 销毁服务
  Future<void> dispose() async {
    await stopNavigation();
    _listeners.clear();
    _isInitialized = false;
    debugPrint('🗑️ 导航服务已销毁');
  }

  bool get isNavigating => _isNavigating;
  bool get isInitialized => _isInitialized;

  void addListener(AmapNaviListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }

  void removeListener(AmapNaviListener listener) {
    _listeners.remove(listener);
  }

  void _notifyListeners(void Function(AmapNaviListener) action) {
    for (final listener in List.from(_listeners)) {
      try {
        action(listener);
      } catch (e) {
        debugPrint('通知监听器失败: $e');
      }
    }
  }

  // -- 公共通知方法（由 navigation_screen 在 GPS 导航过程中调用）--

  void notifyInitialized(bool success) {
    _notifyListeners((listener) => listener.onServiceInitialized(success));
  }

  void notifyRouteCalculationSuccess(int routeId) {
    _notifyListeners((listener) => listener.onRouteCalculationSuccess(routeId));
  }

  void notifyRouteCalculationFailure(String error) {
    _notifyListeners((listener) => listener.onRouteCalculationFailure(error));
  }

  void notifyNaviInfoUpdate(AMapNaviInfo naviInfo) {
    _notifyListeners((listener) => listener.onNaviInfoUpdate(naviInfo));
  }

  void notifyOffRouteDetected() {
    _notifyListeners((listener) => listener.onOffRouteDetected());
  }

  void notifyArrivedDestination() {
    _notifyListeners((listener) => listener.onArrivedDestination());
  }

  void notifyNaviStarted() {
    _isNavigating = true;
    _notifyListeners((listener) => listener.onNaviStarted());
  }

  void notifyNaviStopped() {
    _isNavigating = false;
    _notifyListeners((listener) => listener.onNaviStopped());
  }
}
