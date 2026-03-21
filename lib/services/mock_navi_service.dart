/// 模拟导航服务 - 替代高德导航 SDK
/// 用于绕过 SDK 依赖问题，今天完成导航改造任务
import 'dart:async';
import 'package:flutter/material.dart';

/// 导航状态枚举
enum MockNaviState {
  idle,          // 空闲
  calculating,   // 路径计算中
  navigating,    // 导航中
  arrived,       // 已到达
  error,         // 错误
}

/// 导航信息
class MockNaviInfo {
  final double distance;      // 剩余距离（米）
  final int time;            // 剩余时间（秒）
  final double speed;        // 当前速度（米/秒）
  final String instruction;  // 导航指令
  final int stepIndex;       // 当前步骤索引
  final int totalSteps;      // 总步骤数

  MockNaviInfo({
    required this.distance,
    required this.time,
    required this.speed,
    required this.instruction,
    required this.stepIndex,
    required this.totalSteps,
  });

  @override
  String toString() {
    return 'MockNaviInfo(distance: ${distance}m, time: ${time}s, instruction: "$instruction", step: $stepIndex/$totalSteps)';
  }
}

/// 模拟导航服务
class MockNaviService {
  static final MockNaviService _instance = MockNaviService._internal();
  factory MockNaviService() => _instance;
  MockNaviService._internal();

  // 状态管理
  MockNaviState _state = MockNaviState.idle;
  MockNaviInfo? _currentInfo;
  Timer? _updateTimer;
  final StreamController<MockNaviInfo> _infoStreamController = StreamController<MockNaviInfo>.broadcast();
  final StreamController<MockNaviState> _stateStreamController = StreamController<MockNaviState>.broadcast();

  // 公共接口
  Stream<MockNaviInfo> get onNaviInfoUpdate => _infoStreamController.stream;
  Stream<MockNaviState> get onNaviStateChange => _stateStreamController.stream;
  MockNaviState get currentState => _state;
  MockNaviInfo? get currentInfo => _currentInfo;

  /// 计算步行路线到起点
  Future<bool> calculateWalkRouteToStart({
    required double startLat,
    required double startLng,
    required double targetLat,
    required double targetLng,
  }) async {
    try {
      _setState(MockNaviState.calculating);
      
      // 模拟计算延迟
      await Future.delayed(const Duration(seconds: 1));
      
      // 计算距离（简化版）
      final distance = _calculateDistance(startLat, startLng, targetLat, targetLng);
      final time = (distance / 1.4).round(); // 步行速度 1.4m/s
      
      _currentInfo = MockNaviInfo(
        distance: distance,
        time: time,
        speed: 1.4,
        instruction: '开始步行到路线起点',
        stepIndex: 0,
        totalSteps: 1,
      );
      
      _infoStreamController.add(_currentInfo!);
      _setState(MockNaviState.navigating);
      
      // 启动模拟更新
      _startMockUpdates(distance, time);
      
      return true;
    } catch (e) {
      debugPrint('MockNaviService.calculateWalkRouteToStart error: $e');
      _setState(MockNaviState.error);
      return false;
    }
  }

  /// 启动路线导航
  Future<bool> startRouteNavigation({
    required List<Map<String, double>> routePoints,
  }) async {
    try {
      _setState(MockNaviState.calculating);
      
      // 模拟计算延迟
      await Future.delayed(const Duration(seconds: 2));
      
      // 计算总距离
      double totalDistance = 0;
      for (int i = 0; i < routePoints.length - 1; i++) {
        final p1 = routePoints[i];
        final p2 = routePoints[i + 1];
        totalDistance += _calculateDistance(
          p1['lat']!, p1['lng']!,
          p2['lat']!, p2['lng']!,
        );
      }
      
      final totalTime = (totalDistance / 1.4).round();
      
      _currentInfo = MockNaviInfo(
        distance: totalDistance,
        time: totalTime,
        speed: 1.4,
        instruction: '开始路线导航',
        stepIndex: 0,
        totalSteps: routePoints.length,
      );
      
      _infoStreamController.add(_currentInfo!);
      _setState(MockNaviState.navigating);
      
      // 启动模拟更新
      _startRouteMockUpdates(routePoints);
      
      return true;
    } catch (e) {
      debugPrint('MockNaviService.startRouteNavigation error: $e');
      _setState(MockNaviState.error);
      return false;
    }
  }

  /// 停止导航
  Future<void> stopNavi() async {
    _updateTimer?.cancel();
    _updateTimer = null;
    _setState(MockNaviState.idle);
    _currentInfo = null;
  }

  /// 暂停导航
  Future<void> pauseNavi() async {
    _updateTimer?.cancel();
    _updateTimer = null;
    // 保持当前状态，但停止更新
  }

  /// 继续导航
  Future<void> resumeNavi() async {
    if (_currentInfo != null && _state == MockNaviState.navigating) {
      // 重新启动模拟更新
      _startMockUpdates(_currentInfo!.distance, _currentInfo!.time);
    }
  }

  // 私有方法
  void _setState(MockNaviState newState) {
    if (_state != newState) {
      _state = newState;
      _stateStreamController.add(newState);
    }
  }

  void _startMockUpdates(double initialDistance, int initialTime) {
    double remainingDistance = initialDistance;
    int remainingTime = initialTime;
    
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (remainingDistance <= 0 || remainingTime <= 0) {
        timer.cancel();
        _setState(MockNaviState.arrived);
        _currentInfo = MockNaviInfo(
          distance: 0,
          time: 0,
          speed: 0,
          instruction: '已到达目的地',
          stepIndex: 1,
          totalSteps: 1,
        );
        _infoStreamController.add(_currentInfo!);
        return;
      }
      
      // 模拟前进
      final progress = 5 * 1.4; // 5秒前进距离
      remainingDistance = (remainingDistance - progress).clamp(0, double.infinity);
      remainingTime = (remainingTime - 5).clamp(0, 999999);
      
      _currentInfo = MockNaviInfo(
        distance: remainingDistance,
        time: remainingTime,
        speed: 1.4,
        instruction: _getRandomInstruction(),
        stepIndex: 0,
        totalSteps: 1,
      );
      
      _infoStreamController.add(_currentInfo!);
    });
  }

  void _startRouteMockUpdates(List<Map<String, double>> routePoints) {
    int currentStep = 0;
    int totalSteps = routePoints.length;
    
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (currentStep >= totalSteps - 1) {
        timer.cancel();
        _setState(MockNaviState.arrived);
        _currentInfo = MockNaviInfo(
          distance: 0,
          time: 0,
          speed: 0,
          instruction: '路线导航完成',
          stepIndex: totalSteps,
          totalSteps: totalSteps,
        );
        _infoStreamController.add(_currentInfo!);
        return;
      }
      
      currentStep++;
      
      // 计算剩余距离（简化）
      double remainingDistance = 0;
      for (int i = currentStep; i < routePoints.length - 1; i++) {
        final p1 = routePoints[i];
        final p2 = routePoints[i + 1];
        remainingDistance += _calculateDistance(
          p1['lat']!, p1['lng']!,
          p2['lat']!, p2['lng']!,
        );
      }
      
      final remainingTime = (remainingDistance / 1.4).round();
      
      _currentInfo = MockNaviInfo(
        distance: remainingDistance,
        time: remainingTime,
        speed: 1.4,
        instruction: '沿路线前进，第${currentStep + 1}个点',
        stepIndex: currentStep,
        totalSteps: totalSteps,
      );
      
      _infoStreamController.add(_currentInfo!);
    });
  }

  String _getRandomInstruction() {
    final instructions = [
      '直行前进',
      '保持当前方向',
      '注意路况',
      '前方有转弯',
      '接近目的地',
    ];
    return instructions[DateTime.now().second % instructions.length];
  }

  double _calculateDistance(double lat1, double lng1, double lat2, double lng2) {
    // 简化版距离计算（球面余弦公式）
    const R = 6371000.0; // 地球半径（米）
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