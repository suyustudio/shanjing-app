// qa/m4/p1_testing/utils/network_simulator.dart
// 网络模拟器 - 用于模拟各种网络环境

import 'dart:async';

/// 网络状态枚举
enum NetworkState {
  wifi,          // WiFi
  g4,           // 4G
  g3,           // 3G
  g2,           // 2G
  disconnected, // 无网络
}

/// 网络模拟器
class NetworkSimulator {
  NetworkState _currentState = NetworkState.wifi;
  final List<Map<String, dynamic>> _pendingEvents = [];
  
  static const int MAX_RETRY_COUNT = 5;
  static const int MAX_CACHE_SIZE = 50;

  /// 获取当前网络状态
  NetworkState get currentState => _currentState;

  /// 设置网络状态
  Future<void> setNetworkState(NetworkState state) async {
    _currentState = state;
    
    // 模拟状态切换延迟
    await Future.delayed(Duration(milliseconds: 100));
    
    // 如果网络恢复，尝试批量上报
    if (state == NetworkState.wifi || state == NetworkState.g4) {
      await flushPendingEvents();
    }
  }

  /// 恢复网络到默认状态
  Future<void> restoreNetwork() async {
    await setNetworkState(NetworkState.wifi);
  }

  /// 模拟网络延迟
  Future<void> simulateDelay() async {
    final delayMs = _getNetworkDelay();
    await Future.delayed(Duration(milliseconds: delayMs));
  }

  /// 获取当前网络类型的延迟
  int _getNetworkDelay() {
    switch (_currentState) {
      case NetworkState.wifi:
        return 50 + (100); // 50-150ms
      case NetworkState.g4:
        return 100 + (200); // 100-300ms
      case NetworkState.g3:
        return 300 + (500); // 300-800ms
      case NetworkState.g2:
        return 2000 + (6000); // 2-8s
      case NetworkState.disconnected:
        return 0; // 无网络
    }
  }

  /// 检查当前是否有网络连接
  bool get hasConnection => _currentState != NetworkState.disconnected;

  /// 检查当前网络是否稳定（WiFi/4G）
  bool get isStableConnection => 
    _currentState == NetworkState.wifi || _currentState == NetworkState.g4;

  /// 缓存事件（网络失败时使用）
  Future<void> cacheEvent(Map<String, dynamic> event) async {
    if (_pendingEvents.length >= MAX_CACHE_SIZE) {
      // 缓存满时，移除最旧的数据
      _pendingEvents.removeAt(0);
    }
    
    event['retry_count'] = event['retry_count'] ?? 0;
    _pendingEvents.add(event);
  }

  /// 获取缓存的事件数量
  int get pendingEventCount => _pendingEvents.length;

  /// 获取缓存的事件列表
  List<Map<String, dynamic>> getCachedEvents() => List.from(_pendingEvents);

  /// 清空缓存
  Future<void> clearCache() async {
    _pendingEvents.clear();
  }

  /// 批量上报缓存的事件
  Future<FlushResult> flushPendingEvents() async {
    if (_pendingEvents.isEmpty) {
      return FlushResult(successCount: 0, failedCount: 0);
    }

    var successCount = 0;
    var failedCount = 0;
    final List<Map<String, dynamic>> stillPending = [];

    for (final event in _pendingEvents) {
      // 检查网络状态
      if (!hasConnection) {
        stillPending.add(event);
        continue;
      }

      try {
        // 模拟网络延迟
        await simulateDelay();
        
        // 模拟发送成功（95%成功率）
        if (DateTime.now().millisecond % 100 < 95) {
          successCount++;
        } else {
          throw Exception('Network error');
        }
      } catch (e) {
        event['retry_count'] = (event['retry_count'] ?? 0) + 1;
        
        if (event['retry_count'] < MAX_RETRY_COUNT) {
          stillPending.add(event);
        } else {
          failedCount++;
        }
      }
    }

    // 更新待处理列表
    _pendingEvents.clear();
    _pendingEvents.addAll(stillPending);

    return FlushResult(
      successCount: successCount,
      failedCount: failedCount,
    );
  }

  /// 获取网络类型字符串
  String get networkTypeString {
    switch (_currentState) {
      case NetworkState.wifi:
        return 'wifi';
      case NetworkState.g4:
        return '4g';
      case NetworkState.g3:
        return '3g';
      case NetworkState.g2:
        return '2g';
      case NetworkState.disconnected:
        return 'none';
    }
  }
}

/// 批量上报结果
class FlushResult {
  final int successCount;
  final int failedCount;

  FlushResult({
    required this.successCount,
    required this.failedCount,
  });

  int get total => successCount + failedCount;
}
