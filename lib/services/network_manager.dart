import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// 网络状态管理器
/// 监听网络状态变化，自动切换在线/离线模式
class NetworkManager {
  static final NetworkManager _instance = NetworkManager._internal();
  factory NetworkManager() => _instance;
  NetworkManager._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription? _subscription;
  
  bool _isOnline = true;
  bool get isOnline => _isOnline;
  
  final List<Function(bool isOnline)> _listeners = [];

  /// 初始化网络监听
  Future<void> initialize() async {
    // 获取初始网络状态
    final result = await _connectivity.checkConnectivity();
    _updateNetworkStatus(result);

    // 监听网络变化
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _updateNetworkStatus(result);
    });
  }

  /// 更新网络状态
  void _updateNetworkStatus(ConnectivityResult result) {
    final wasOnline = _isOnline;
    _isOnline = result != ConnectivityResult.none;
    
    if (wasOnline != _isOnline) {
      // 网络状态发生变化，通知所有监听器
      for (final listener in _listeners) {
        listener(_isOnline);
      }
    }
  }

  /// 添加网络状态监听器
  void addListener(Function(bool isOnline) listener) {
    _listeners.add(listener);
  }

  /// 移除网络状态监听器
  void removeListener(Function(bool isOnline) listener) {
    _listeners.remove(listener);
  }

  /// 释放资源
  void dispose() {
    _subscription?.cancel();
    _listeners.clear();
  }
}
