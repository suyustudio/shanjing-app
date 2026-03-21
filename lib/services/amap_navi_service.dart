import 'package:flutter/foundation.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'package:amap_flutter_navi/amap_flutter_navi.dart';

/// 高德导航服务封装
/// 封装高德导航SDK的所有功能，提供简洁的API给业务层使用
class AmapNaviService {
  static final AmapNaviService _instance = AmapNaviService._internal();
  factory AmapNaviService() => _instance;
  AmapNaviService._internal();
  
  // 高德导航控制器
  late AMapNaviController _naviController;
  
  // 是否已初始化
  bool _isInitialized = false;
  
  // 当前导航状态
  bool _isNavigating = false;
  
  // 监听器列表
  final List<AmapNaviListener> _listeners = [];
  
  /// 初始化导航服务
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // 创建导航控制器
      _naviController = AMapNaviController();
      
      // 设置监听器
      _setupListeners();
      
      // 初始化高德导航
      await _naviController.initialize();
      
      _isInitialized = true;
      _notifyListeners((listener) => listener.onServiceInitialized(true));
      
      debugPrint('✅ 高德导航服务初始化成功');
      return true;
    } catch (e) {
      debugPrint('❌ 高德导航服务初始化失败: $e');
      _notifyListeners((listener) => listener.onServiceInitialized(false));
      return false;
    }
  }
  
  /// 设置监听器
  void _setupListeners() {
    // 路径规划成功回调
    _naviController.onCalculateRouteSuccess = (routeId, errorInfo) {
      debugPrint('🗺️ 路径规划成功: routeId=$routeId');
      _notifyListeners((listener) => listener.onRouteCalculationSuccess(routeId));
    };
    
    // 路径规划失败回调
    _naviController.onCalculateRouteFailure = (errorInfo) {
      debugPrint('❌ 路径规划失败: $errorInfo');
      _notifyListeners((listener) => listener.onRouteCalculationFailure(errorInfo));
    };
    
    // 导航信息更新
    _naviController.onNaviInfoUpdate = (naviInfo) {
      _notifyListeners((listener) => listener.onNaviInfoUpdate(naviInfo));
    };
    
    // 偏航检测
    _naviController.onOffRouteDetected = () {
      debugPrint('⚠️ 检测到偏航');
      _notifyListeners((listener) => listener.onOffRouteDetected());
    };
    
    // 到达目的地
    _naviController.onArrivedDestination = () {
      debugPrint('✅ 到达目的地');
      _isNavigating = false;
      _notifyListeners((listener) => listener.onArrivedDestination());
    };
    
    // 导航开始
    _naviController.onStartNavi = () {
      debugPrint('🚀 导航开始');
      _isNavigating = true;
      _notifyListeners((listener) => listener.onNaviStarted());
    };
    
    // 导航结束
    _naviController.onStopNavi = () {
      debugPrint('🛑 导航结束');
      _isNavigating = false;
      _notifyListeners((listener) => listener.onNaviStopped());
    };
  }
  
  /// 计算步行路径（阶段1：当前位置 → 路线起点）
  Future<int?> calculateWalkRouteToStart({
    required LatLng currentLocation,
    required LatLng routeStart,
    WalkStrategy strategy = WalkStrategy.MULTI_PATH,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return null;
    }
    
    try {
      // 调用高德步行路径规划
      await _naviController.calculateWalkRoute(
        start: currentLocation,
        end: routeStart,
        strategy: strategy,
      );
      
      // 返回routeId（在实际API中，calculateWalkRoute可能返回routeId）
      return 0; // 简化返回，实际应从回调获取
    } catch (e) {
      debugPrint('❌ 计算步行路径失败: $e');
      _notifyListeners((listener) => listener.onRouteCalculationFailure(e.toString()));
      return null;
    }
  }
  
  /// 开始步行导航到起点（阶段1）
  Future<bool> startWalkToStart({int routeId = 0}) async {
    if (!_isInitialized) return false;
    
    try {
      await _naviController.startWalkNavi(routeIndex: routeId);
      _isNavigating = true;
      return true;
    } catch (e) {
      debugPrint('❌ 开始步行导航失败: $e');
      return false;
    }
  }
  
  /// 设置路线点并开始路线导航（阶段2）
  Future<bool> startRouteNavigation({
    required List<LatLng> routePoints,
    int routeId = 0,
    WalkStrategy strategy = WalkStrategy.MULTI_PATH,
  }) async {
    if (!_isInitialized) return false;
    
    try {
      // 1. 设置路线点
      await _naviController.setRoutePoints(routePoints);
      
      // 2. 开始路线导航
      await _naviController.startWalkNavi(
        routeIndex: routeId,
        strategy: strategy,
      );
      
      _isNavigating = true;
      return true;
    } catch (e) {
      debugPrint('❌ 开始路线导航失败: $e');
      return false;
    }
  }
  
  /// 停止导航
  Future<void> stopNavigation() async {
    if (!_isInitialized || !_isNavigating) return;
    
    try {
      await _naviController.stopNavi();
      _isNavigating = false;
    } catch (e) {
      debugPrint('❌ 停止导航失败: $e');
    }
  }
  
  /// 重新规划路线（偏航后）
  Future<void> recalculateRoute() async {
    if (!_isInitialized) return;
    
    try {
      await _naviController.recalculateRoute();
    } catch (e) {
      debugPrint('❌ 重新规划路线失败: $e');
    }
  }
  
  /// 获取当前导航状态
  bool get isNavigating => _isNavigating;
  
  /// 获取是否已初始化
  bool get isInitialized => _isInitialized;
  
  /// 添加监听器
  void addListener(AmapNaviListener listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
  }
  
  /// 移除监听器
  void removeListener(AmapNaviListener listener) {
    _listeners.remove(listener);
  }
  
  /// 通知所有监听器
  void _notifyListeners(void Function(AmapNaviListener) action) {
    for (final listener in List.from(_listeners)) {
      try {
        action(listener);
      } catch (e) {
        debugPrint('通知监听器失败: $e');
      }
    }
  }
  
  /// 销毁服务
  Future<void> dispose() async {
    if (_isNavigating) {
      await stopNavigation();
    }
    
    try {
      await _naviController.dispose();
    } catch (e) {
      debugPrint('销毁导航控制器失败: $e');
    }
    
    _listeners.clear();
    _isInitialized = false;
    _isNavigating = false;
  }
}

/// 高德导航监听器接口
abstract class AmapNaviListener {
  /// 服务初始化完成
  void onServiceInitialized(bool success);
  
  /// 路径规划成功
  void onRouteCalculationSuccess(int routeId);
  
  /// 路径规划失败
  void onRouteCalculationFailure(String error);
  
  /// 导航信息更新
  void onNaviInfoUpdate(AMapNaviInfo naviInfo);
  
  /// 检测到偏航
  void onOffRouteDetected();
  
  /// 到达目的地
  void onArrivedDestination();
  
  /// 导航开始
  void onNaviStarted();
  
  /// 导航停止
  void onNaviStopped();
}

/// 步行策略枚举
enum WalkStrategy {
  /// 最快捷
  FASTEST,
  /// 最短距离
  SHORTEST,
  /// 避开拥堵
  AVOID_CONGESTION,
  /// 多路径规划
  MULTI_PATH,
}