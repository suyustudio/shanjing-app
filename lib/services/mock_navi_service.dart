/// 增强版模拟导航服务 - 支持真实路径规划
/// 
/// 阶段1：当前位置 → 路线起点（使用后端API路径规划）
/// 阶段2：路线起点 → 路线终点（沿预设轨迹点导航）
/// 
/// 注意：由于高德导航SDK编译问题，导航过程使用模拟推进，
/// 但路径规划使用真实的高德API数据
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import 'map_service.dart';

/// 导航状态枚举
enum MockNaviState {
  idle,          // 空闲
  calculating,   // 路径计算中
  navigating,    // 导航中
  arrived,       // 已到达
  error,         // 错误
  offRoute,      // 偏航检测，需要重新规划
}

/// 导航信息
class MockNaviInfo {
  final double distance;      // 剩余距离（米）
  final int time;            // 剩余时间（秒）
  final double speed;        // 当前速度（米/秒）
  final String instruction;  // 导航指令
  final int stepIndex;       // 当前步骤索引
  final int totalSteps;      // 总步骤数
  final RouteStep? currentStep; // 当前步骤详情

  MockNaviInfo({
    required this.distance,
    required this.time,
    required this.speed,
    required this.instruction,
    required this.stepIndex,
    required this.totalSteps,
    this.currentStep,
  });

  @override
  String toString() {
    return 'MockNaviInfo(distance: ${distance}m, time: ${time}s, instruction: "$instruction", step: $stepIndex/$totalSteps)';
  }
}

/// 增强版模拟导航服务
class MockNaviService {
  static final MockNaviService _instance = MockNaviService._internal();
  factory MockNaviService() => _instance;
  MockNaviService._internal();

  // 地图服务（用于真实路径规划）
  final MapService _mapService = MapService();

  // 状态管理
  MockNaviState _state = MockNaviState.idle;
  MockNaviInfo? _currentInfo;
  Timer? _updateTimer;
  final StreamController<MockNaviInfo> _infoStreamController = StreamController<MockNaviInfo>.broadcast();
  final StreamController<MockNaviState> _stateStreamController = StreamController<MockNaviState>.broadcast();

  // 路线数据
  List<RouteStep> _steps = [];
  int _currentStepIndex = 0;
  double _totalDistance = 0;
  double _remainingDistance = 0;

  // 公共接口
  Stream<MockNaviInfo> get onNaviInfoUpdate => _infoStreamController.stream;
  Stream<MockNaviState> get onNaviStateChange => _stateStreamController.stream;
  MockNaviState get currentState => _state;
  MockNaviInfo? get currentInfo => _currentInfo;
  List<RouteStep> get steps => _steps;
  List<LatLng> get plannedPath {
    final points = <LatLng>[];
    for (final step in _steps) {
      points.addAll(step.polyline);
    }
    return points;
  }

  /// 计算步行路线到起点（使用真实路径规划API）
  Future<bool> calculateWalkRouteToStart({
    required double startLat,
    required double startLng,
    required double targetLat,
    required double targetLng,
  }) async {
    try {
      _setState(MockNaviState.calculating);
      
      debugPrint('🗺️ 调用后端API进行步行路径规划...');
      debugPrint('   起点: ($startLat, $startLng)');
      debugPrint('   终点: ($targetLat, $targetLng)');
      
      // 调用后端API进行路径规划
      final result = await _mapService.planWalkingRoute(
        origin: LatLng(startLat, startLng),
        destination: LatLng(targetLat, targetLng),
      );
      
      if (!result.success || result.paths.isEmpty) {
        debugPrint('❌ 路径规划失败: ${result.errorMessage}');
        _setState(MockNaviState.error);
        return false;
      }
      
      // 使用第一条路径
      final path = result.paths.first;
      _steps = path.steps;
      _currentStepIndex = 0;
      _totalDistance = path.distance.toDouble();
      _remainingDistance = _totalDistance;
      
      debugPrint('✅ 路径规划成功!');
      debugPrint('   总距离: ${path.distance}米');
      debugPrint('   预计时间: ${path.duration}秒');
      debugPrint('   步骤数: ${path.steps.length}');
      
      _currentInfo = MockNaviInfo(
        distance: _remainingDistance,
        time: path.duration,
        speed: 1.4,
        instruction: _steps.isNotEmpty ? _steps.first.instruction : '开始步行到路线起点',
        stepIndex: 0,
        totalSteps: _steps.length,
        currentStep: _steps.isNotEmpty ? _steps.first : null,
      );
      
      _infoStreamController.add(_currentInfo!);
      _setState(MockNaviState.navigating);
      
      // 启动模拟更新
      _startStepByStepUpdates();
      
      return true;
    } catch (e) {
      debugPrint('❌ MockNaviService.calculateWalkRouteToStart error: $e');
      _setState(MockNaviState.error);
      return false;
    }
  }

  /// 启动路线导航（阶段2）
  Future<bool> startRouteNavigation({
    required List<Map<String, double>> routePoints,
  }) async {
    try {
      _setState(MockNaviState.calculating);
      
      // 阶段2使用预设的路线点，不需要额外路径规划
      // 将路线点转换为步骤
      _steps = _convertPointsToSteps(routePoints);
      _currentStepIndex = 0;
      _totalDistance = _calculateTotalDistance(routePoints);
      _remainingDistance = _totalDistance;
      
      final totalTime = (_totalDistance / 1.4).round();
      
      _currentInfo = MockNaviInfo(
        distance: _totalDistance,
        time: totalTime,
        speed: 1.4,
        instruction: '开始路线导航',
        stepIndex: 0,
        totalSteps: _steps.length,
        currentStep: _steps.isNotEmpty ? _steps.first : null,
      );
      
      _infoStreamController.add(_currentInfo!);
      _setState(MockNaviState.navigating);
      
      // 启动模拟更新
      _startRouteStepUpdates();
      
      return true;
    } catch (e) {
      debugPrint('❌ MockNaviService.startRouteNavigation error: $e');
      _setState(MockNaviState.error);
      return false;
    }
  }

  /// 将路线点转换为步骤
  List<RouteStep> _convertPointsToSteps(List<Map<String, double>> points) {
    final steps = <RouteStep>[];
    
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final distance = _calculateDistance(
        p1['lat']!, p1['lng']!,
        p2['lat']!, p2['lng']!,
      );
      final duration = (distance / 1.4).round();
      
      steps.add(RouteStep(
        instruction: i == 0 ? '从路线起点出发' : '前往第${i + 1}个轨迹点',
        road: '路线轨迹',
        distance: distance.round(),
        duration: duration,
        polyline: [
          LatLng(p1['lat']!, p1['lng']!),
          LatLng(p2['lat']!, p2['lng']!),
        ],
      ));
    }
    
    return steps;
  }

  /// 计算总距离
  double _calculateTotalDistance(List<Map<String, double>> points) {
    double total = 0;
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      total += _calculateDistance(
        p1['lat']!, p1['lng']!,
        p2['lat']!, p2['lng']!,
      );
    }
    return total;
  }

  /// 停止导航
  Future<void> stopNavi() async {
    _updateTimer?.cancel();
    _updateTimer = null;
    _setState(MockNaviState.idle);
    _currentInfo = null;
    _steps = [];
    _currentStepIndex = 0;
  }

  /// 暂停导航
  Future<void> pauseNavi() async {
    _updateTimer?.cancel();
    _updateTimer = null;
  }

  /// 继续导航
  Future<void> resumeNavi() async {
    if (_currentInfo != null && _state == MockNaviState.navigating) {
      _startStepByStepUpdates();
    }
  }

  // 私有方法
  void _setState(MockNaviState newState) {
    if (_state != newState) {
      _state = newState;
      _stateStreamController.add(newState);
    }
  }

  /// 启动步骤级更新（阶段1：使用真实路径规划的步骤）
  void _startStepByStepUpdates() {
    _updateTimer?.cancel();
    
    if (_steps.isEmpty) return;
    
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentStepIndex >= _steps.length - 1) {
        timer.cancel();
        _setState(MockNaviState.arrived);
        _currentInfo = MockNaviInfo(
          distance: 0,
          time: 0,
          speed: 0,
          instruction: '已到达路线起点',
          stepIndex: _steps.length,
          totalSteps: _steps.length,
          currentStep: null,
        );
        _infoStreamController.add(_currentInfo!);
        return;
      }
      
      // 前进到下一步
      _currentStepIndex++;
      final currentStep = _steps[_currentStepIndex];
      
      // 计算剩余距离
      _remainingDistance = 0;
      for (int i = _currentStepIndex; i < _steps.length; i++) {
        _remainingDistance += _steps[i].distance;
      }
      
      final remainingTime = (_remainingDistance / 1.4).round();
      
      _currentInfo = MockNaviInfo(
        distance: _remainingDistance,
        time: remainingTime,
        speed: 1.4,
        instruction: currentStep.instruction,
        stepIndex: _currentStepIndex,
        totalSteps: _steps.length,
        currentStep: currentStep,
      );
      
      _infoStreamController.add(_currentInfo!);
    });
  }

  /// 启动路线步骤更新（阶段2）
  void _startRouteStepUpdates() {
    _updateTimer?.cancel();
    
    if (_steps.isEmpty) return;
    
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (_currentStepIndex >= _steps.length - 1) {
        timer.cancel();
        _setState(MockNaviState.arrived);
        _currentInfo = MockNaviInfo(
          distance: 0,
          time: 0,
          speed: 0,
          instruction: '路线导航完成',
          stepIndex: _steps.length,
          totalSteps: _steps.length,
          currentStep: null,
        );
        _infoStreamController.add(_currentInfo!);
        return;
      }
      
      // 偏航检测（10%概率）
      if (Random().nextDouble() < 0.1 && _state == MockNaviState.navigating) {
        _setState(MockNaviState.offRoute);
        _currentInfo = MockNaviInfo(
          distance: _remainingDistance,
          time: (_remainingDistance / 1.4).round(),
          speed: 1.4,
          instruction: '检测到偏航，正在重新规划',
          stepIndex: _currentStepIndex,
          totalSteps: _steps.length,
          currentStep: _steps[_currentStepIndex],
        );
        _infoStreamController.add(_currentInfo!);
        
        // 3秒后恢复导航
        Future.delayed(const Duration(seconds: 3), () {
          if (_state == MockNaviState.offRoute) {
            _setState(MockNaviState.navigating);
          }
        });
      }
      
      // 前进到下一步
      _currentStepIndex++;
      
      // 计算剩余距离
      _remainingDistance = 0;
      for (int i = _currentStepIndex; i < _steps.length; i++) {
        _remainingDistance += _steps[i].distance;
      }
      
      final remainingTime = (_remainingDistance / 1.4).round();
      
      _currentInfo = MockNaviInfo(
        distance: _remainingDistance,
        time: remainingTime,
        speed: 1.4,
        instruction: '沿路线前进，第${_currentStepIndex + 1}段',
        stepIndex: _currentStepIndex,
        totalSteps: _steps.length,
        currentStep: _steps[_currentStepIndex],
      );
      
      _infoStreamController.add(_currentInfo!);
    });
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    const R = 6371000.0;
    final dLat = _toRadians(lat2 - lat1);
    final dLng = _toRadians(lng2 - lng1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLng / 2) * sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return R * c;
  }

  double _toRadians(double degrees) {
    return degrees * pi / 180;
  }

  /// 清理资源
  void dispose() {
    _updateTimer?.cancel();
    _infoStreamController.close();
    _stateStreamController.close();
  }
}
