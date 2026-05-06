// ================================================================
// Connectivity Service
// 网络连接状态监控服务
// ================================================================

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 网络连接状态监控服务
class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  late StreamSubscription<ConnectivityResult> _subscription;

  /// 初始化
  Future<void> initialize() async {
    final result = await _connectivity.checkConnectivity();
    _controller.add(_isConnectedResult(result));

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _controller.add(_isConnectedResult(result));
    });
  }

  /// 是否已连接
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnectedResult(result);
  }

  /// 网络状态变化流
  Stream<bool> get onConnectivityChanged => _controller.stream;

  bool _isConnectedResult(ConnectivityResult result) {
    return result != ConnectivityResult.none;
  }

  /// 释放资源
  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
