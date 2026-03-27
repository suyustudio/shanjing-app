import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';

/// 模拟导航信息类（替代 amap_flutter_navi 的 AMapNaviInfo）
class AMapNaviInfo {
  /// 剩余距离（米）
  final double remainingDistance;
  
  /// 剩余时间（秒）
  final int remainingTime;
  
  /// 当前速度（米/秒）
  final double currentSpeed;
  
  /// 下一道路名称
  final String nextRoadName;
  
  /// 下一动作（直行、左转、右转等）
  final String nextAction;
  
  AMapNaviInfo({
    required this.remainingDistance,
    required this.remainingTime,
    this.currentSpeed = 1.4, // 步行速度约1.4m/s
    this.nextRoadName = '',
    this.nextAction = '直行',
  });
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

/// 模拟高德导航服务
/// 由于 amap_flutter_navi 编译不通过，改用模拟实现
/// 保持相同接口，模拟导航流程和回调
class AmapNaviService {
  static final AmapNaviService _instance = AmapNaviService._internal();
  factory AmapNaviService() => _instance;
  AmapNaviService._internal();
  
  // 是否已初始化
  bool _isInitialized = false;
  
  // 当前导航状态
  bool _isNavigating = false;
  
  // 监听器列表
  final List<AmapNaviListener> _listeners = [];
  
  // 模拟定时器
  Timer? _simulationTimer;
  
  // 模拟导航参数
  double _simulatedDistance = 0.0;
  double _totalDistance = 1000.0; // 默认1公里
  double _walkingSpeed = 1.4; // 步行速度 1.4m/s ≈ 5km/h
  int _routeId = 0;
  
  /// 初始化导航服务（模拟，立即成功）
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    await Future.delayed(const Duration(milliseconds: 500)); // 模拟延迟
    
    _isInitialized = true;
    _notifyListeners((listener) => listener.onServiceInitialized(true));
    
    debugPrint('✅ 模拟导航服务初始化成功');
    return true;
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
    
    // 计算距离（简化模拟）
    final distance = _calculateDistance(currentLocation, routeStart);
    _totalDistance = distance;
    _simulatedDistance = 0.0;
    _routeId = DateTime.now().millisecondsSinceEpoch % 100000;
    
    // 模拟路径规划延迟
    await Future.delayed(const Duration(seconds: 1));
    
    // 模拟路径规划成功
    _notifyListeners((listener) => listener.onRouteCalculationSuccess(_routeId));
    
    debugPrint('🗺️ 模拟路径规划成功: 距离 ${distance.toStringAsFixed(1)}米, routeId=$_routeId');
    return _routeId;
  }
  
  /// 开始步行导航到起点（阶段1）
  Future<bool> startWalkToStart({int routeId = 0}) async {
    if (!_isInitialized) return false;
    
    _isNavigating = true;
    _routeId = routeId;
    
    // 通知导航开始
    _notifyListeners((listener) => listener.onNaviStarted());
    
    // 启动模拟定时器
    _startSimulationTimer();
    
    debugPrint('🚀 模拟步行导航开始 (routeId=$routeId)');
    return true;
  }
  
  /// 设置路线点并开始路线导航（阶段2）
  Future<bool> startRouteNavigation({
    required List<LatLng> routePoints,
    int routeId = 0,
    WalkStrategy strategy = WalkStrategy.MULTI_PATH,
  }) async {
    if (!_isInitialized) return false;
    
    // 计算路线总距离（简化：累计各段距离）
    double totalDistance = 0.0;
    for (int i = 0; i < routePoints.length - 1; i++) {
      totalDistance += _calculateDistance(routePoints[i], routePoints[i + 1]);
    }
    
    _totalDistance = totalDistance;
    _simulatedDistance = 0.0;
    _routeId = routeId;
    _isNavigating = true;
    
    // 通知导航开始
    _notifyListeners((listener) => listener.onNaviStarted());
    
    // 启动模拟定时器
    _startSimulationTimer();
    
    debugPrint('🗺️ 模拟路线导航开始: ${routePoints.length}个点, 总距离 ${totalDistance.toStringAsFixed(1)}米');
    return true;
  }
  
  /// 启动模拟定时器
  void _startSimulationTimer() {
    _stopSimulationTimer(); // 确保没有重复定时器
    
    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_isNavigating) {
        timer.cancel();
        return;
      }
      
      // 更新模拟距离（每2秒前进 walkingSpeed * 2 米）
      _simulatedDistance += _walkingSpeed * 2;
      
      // 如果到达目的地
      if (_simulatedDistance >= _totalDistance) {
        _simulatedDistance = _totalDistance;
        _isNavigating = false;
        timer.cancel();
        
        _notifyListeners((listener) => listener.onArrivedDestination());
        debugPrint('✅ 模拟导航到达目的地');
      } else {
        // 更新导航信息
        final remainingDistance = _totalDistance - _simulatedDistance;
        final remainingTime = (remainingDistance / _walkingSpeed).round();
        
        final naviInfo = AMapNaviInfo(
          remainingDistance: remainingDistance,
          remainingTime: remainingTime,
          currentSpeed: _walkingSpeed,
          nextRoadName: _getNextRoadName(),
          nextAction: _getNextAction(),
        );
        
        _notifyListeners((listener) => listener.onNaviInfoUpdate(naviInfo));
        
        // 随机模拟偏航（10%概率）
        if (Random().nextDouble() < 0.1 && _simulatedDistance > 100) {
          _notifyListeners((listener) => listener.onOffRouteDetected());
          debugPrint('⚠️ 模拟偏航检测');
        }
      }
    });
  }
  
  /// 停止模拟定时器
  void _stopSimulationTimer() {
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }
  
  /// 计算两点间距离（简化球面距离计算）
  double _calculateDistance(LatLng p1, LatLng p2) {
    const R = 6371000.0; // 地球半径（米）
    final lat1 = p1.latitude * pi / 180;
    final lat2 = p2.latitude * pi / 180;
    final dLat = (p2.latitude - p1.latitude) * pi / 180;
    final dLng = (p2.longitude - p1.longitude) * pi / 180;
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return R * c;
  }
  
  /// 获取下一道路名称（模拟）
  String _getNextRoadName() {
    final names = ['西湖大道', '南山路', '北山路', '苏堤', '白堤', '杨公堤'];
    return names[Random().nextInt(names.length)];
  }
  
  /// 获取下一动作（模拟）
  String _getNextAction() {
    final actions = ['直行', '左转', '右转', '前方路口', '靠左行驶', '靠右行驶'];
    return actions[Random().nextInt(actions.length)];
  }
  
  /// 停止导航
  Future<void> stopNavigation() async {
    if (!_isNavigating) return;
    
    _isNavigating = false;
    _stopSimulationTimer();
    
    _notifyListeners((listener) => listener.onNaviStopped());
    debugPrint('🛑 模拟导航停止');
  }
  
  /// 重新规划路线（偏航后）
  Future<void> recalculateRoute() async {
    if (!_isInitialized) return;
    
    // 模拟重新规划延迟
    await Future.delayed(const Duration(seconds: 2));
    
    // 重置模拟距离（假设重新规划后剩余距离减少10%）
    _simulatedDistance = _simulatedDistance * 0.9;
    _totalDistance = _totalDistance * 0.9;
    
    _notifyListeners((listener) => listener.onRouteCalculationSuccess(_routeId));
    debugPrint('🗺️ 模拟重新规划路线成功');
  }
  
  /// 恢复导航（从后台恢复时调用）
  Future<bool> resume() async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) return false;
    }
    
    // 如果之前在导航中，恢复导航状态
    if (!_isNavigating && _simulatedDistance > 0 && _simulatedDistance < _totalDistance) {
      _isNavigating = true;
      _startSimulationTimer();
      _notifyListeners((listener) => listener.onNaviStarted());
      debugPrint('🔄 模拟导航已恢复');
      return true;
    }
    
    // 如果已经到达或尚未开始，只是确保服务可用
    debugPrint('🔄 导航服务已恢复（无需重启导航）');
    return true;
  }
  
  /// 销毁服务
  Future<void> dispose() async {
    await stopNavigation();
    _listeners.clear();
    _isInitialized = false;
    debugPrint('🗑️ 模拟导航服务已销毁');
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
  
  /// 公共通知方法（用于外部触发）
  
  /// 通知服务初始化完成
  void notifyInitialized(bool success) {
    _notifyListeners((listener) => listener.onServiceInitialized(success));
  }
  
  /// 通知路径规划成功
  void notifyRouteCalculationSuccess(int routeId) {
    _notifyListeners((listener) => listener.onRouteCalculationSuccess(routeId));
  }
  
  /// 通知路径规划失败
  void notifyRouteCalculationFailure(String error) {
    _notifyListeners((listener) => listener.onRouteCalculationFailure(error));
  }
  
  /// 通知导航信息更新
  void notifyNaviInfoUpdate(AMapNaviInfo naviInfo) {
    _notifyListeners((listener) => listener.onNaviInfoUpdate(naviInfo));
  }
  
  /// 通知检测到偏航
  void notifyOffRouteDetected() {
    _notifyListeners((listener) => listener.onOffRouteDetected());
  }
  
  /// 通知到达目的地
  void notifyArrivedDestination() {
    _notifyListeners((listener) => listener.onArrivedDestination());
  }
  
  /// 通知导航开始
  void notifyNaviStarted() {
    _notifyListeners((listener) => listener.onNaviStarted());
  }
  
  /// 通知导航停止
  void notifyNaviStopped() {
    _notifyListeners((listener) => listener.onNaviStopped());
  }
}