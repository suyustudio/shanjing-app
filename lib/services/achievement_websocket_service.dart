// ================================================================
// Achievement WebSocket Service
// 成就系统 WebSocket 服务 - 修复版
//
// 修复内容:
// - P1-4: 添加 WebSocket 断线重连机制
// - P1-5: 添加离线解锁同步机制
// ================================================================

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/achievement_model.dart';
import 'analytics_service.dart';
import 'connectivity_service.dart';

/// 离线成就解锁事件
class PendingAchievementUnlock {
  final String userId;
  final String achievementId;
  final String level;
  final DateTime timestamp;
  final String? triggerType;
  final Map<String, dynamic>? metadata;
  
  PendingAchievementUnlock({
    required this.userId,
    required this.achievementId,
    required this.level,
    required this.timestamp,
    this.triggerType,
    this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'achievement_id': achievementId,
    'level': level,
    'timestamp': timestamp.toIso8601String(),
    'trigger_type': triggerType,
    'metadata': metadata,
  };
  
  factory PendingAchievementUnlock.fromJson(Map<String, dynamic> json) {
    return PendingAchievementUnlock(
      userId: json['user_id'],
      achievementId: json['achievement_id'],
      level: json['level'],
      timestamp: DateTime.parse(json['timestamp']),
      triggerType: json['trigger_type'],
      metadata: json['metadata'],
    );
  }
}

/// WebSocket 连接状态
enum WebSocketState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// 成就 WebSocket 服务
class AchievementWebSocketService {
  static final AchievementWebSocketService _instance = 
      AchievementWebSocketService._internal();
  static AchievementWebSocketService get instance => _instance;
  
  AchievementWebSocketService._internal();
  
  io.Socket? _socket;
  WebSocketState _state = WebSocketState.disconnected;
  String? _userId;
  String? _authToken;
  
  // 重连配置
  static const int _maxReconnectAttempts = 10;
  static const Duration _initialReconnectDelay = Duration(seconds: 1);
  static const Duration _maxReconnectDelay = Duration(seconds: 60);
  int _reconnectAttempts = 0;
  Timer? _reconnectTimer;
  Duration _currentReconnectDelay = _initialReconnectDelay;
  
  // 离线队列
  final List<PendingAchievementUnlock> _pendingUnlocks = [];
  static const String _prefsKey = 'achievement_pending_unlocks';
  
  // 流控制器
  final StreamController<WebSocketState> _stateController = 
      StreamController<WebSocketState>.broadcast();
  final StreamController<NewlyUnlockedAchievement> _unlockController = 
      StreamController<NewlyUnlockedAchievement>.broadcast();
  final StreamController<Map<String, dynamic>> _progressController = 
      StreamController<Map<String, dynamic>>.broadcast();
  
  // 服务依赖
  final ConnectivityService _connectivityService = ConnectivityService.instance;
  final AnalyticsService _analyticsService = AnalyticsService.instance;
  
  // Getters
  WebSocketState get state => _state;
  bool get isConnected => _state == WebSocketState.connected;
  Stream<WebSocketState> get stateStream => _stateController.stream;
  Stream<NewlyUnlockedAchievement> get unlockStream => _unlockController.stream;
  Stream<Map<String, dynamic>> get progressStream => _progressController.stream;
  
  /// 初始化服务
  Future<void> initialize({
    required String userId,
    required String authToken,
    String serverUrl = 'wss://api.shanjing.app',
  }) async {
    _userId = userId;
    _authToken = authToken;
    
    // 恢复离线事件
    await _restorePendingUnlocks();
    
    // 监听网络状态
    _connectivityService.onConnectivityChanged.listen(_onConnectivityChanged);
    
    // 初始连接
    if (await _connectivityService.isConnected()) {
      connect(serverUrl);
    }
  }
  
  /// 连接 WebSocket
  void connect(String serverUrl) {
    if (_state == WebSocketState.connected || 
        _state == WebSocketState.connecting) {
      return;
    }
    
    _setState(WebSocketState.connecting);
    
    try {
      _socket = io.io(serverUrl, <io.OptionBuilder>[
        io.OptionBuilder()
          .setTransports(['websocket'])
          .enableAutoConnect()
          .enableReconnection()
          .setReconnectionDelay(1000)
          .setReconnectionDelayMax(5000)
          .setExtraHeaders({'Authorization': 'Bearer $_authToken'})
          .build(),
      ].toList());
      
      _setupSocketListeners();
      
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
      _setState(WebSocketState.error);
      _scheduleReconnect();
    }
  }
  
  /// 设置 Socket 监听器
  void _setupSocketListeners() {
    if (_socket == null) return;
    
    // 连接成功
    _socket!.onConnect((_) {
      debugPrint('WebSocket connected');
      _setState(WebSocketState.connected);
      _reconnectAttempts = 0;
      _currentReconnectDelay = _initialReconnectDelay;
      
      // 加入用户房间
      _socket!.emit('join', {'userId': _userId});
      
      // 同步离线事件
      _syncPendingUnlocks();
    });
    
    // 断开连接
    _socket!.onDisconnect((_) {
      debugPrint('WebSocket disconnected');
      _setState(WebSocketState.disconnected);
      _scheduleReconnect();
    });
    
    // 连接错误
    _socket!.onError((error) {
      debugPrint('WebSocket error: $error');
      _setState(WebSocketState.error);
      _scheduleReconnect();
    });
    
    // 连接超时
    _socket!.onConnectError((error) {
      debugPrint('WebSocket connect error: $error');
      _setState(WebSocketState.error);
      _scheduleReconnect();
    });
    
    // 成就解锁事件
    _socket!.on('achievement_unlocked', (data) {
      debugPrint('Achievement unlocked via WebSocket: $data');
      
      final achievement = NewlyUnlockedAchievement(
        achievementId: data['achievementId'],
        level: _parseLevel(data['level']),
        name: data['name'],
        message: data['message'],
        badgeUrl: data['badgeUrl'],
      );
      
      _unlockController.add(achievement);
      
      // 埋点
      _analyticsService.logAchievementUnlock(
        achievement.achievementId,
        achievement.level.toString(),
      );
    });
    
    // 进度更新事件
    _socket!.on('progress_updated', (data) {
      debugPrint('Progress updated via WebSocket: $data');
      _progressController.add(data);
    });
    
    // 同步确认
    _socket!.on('sync_confirmed', (data) {
      debugPrint('Pending unlocks synced: $data');
      _removeSyncedUnlocks(data['syncedIds'] as List<dynamic>);
    });
  }
  
  /// 网络状态变化处理
  void _onConnectivityChanged(bool isConnected) {
    if (isConnected && _state == WebSocketState.disconnected) {
      // 网络恢复，尝试重连
      _reconnectAttempts = 0;
      _currentReconnectDelay = _initialReconnectDelay;
      _cancelReconnect();
      connect('wss://api.shanjing.app');
    } else if (!isConnected && _state == WebSocketState.connected) {
      // 网络断开
      disconnect();
    }
  }
  
  /// 调度重连
  void _scheduleReconnect() {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('Max reconnect attempts reached');
      return;
    }
    
    _cancelReconnect();
    _setState(WebSocketState.reconnecting);
    
    // 指数退避
    final delay = _calculateReconnectDelay();
    debugPrint('Scheduling reconnect in ${delay.inSeconds}s (attempt ${_reconnectAttempts + 1})');
    
    _reconnectTimer = Timer(delay, () {
      _reconnectAttempts++;
      connect('wss://api.shanjing.app');
    });
  }
  
  /// 计算重连延迟（指数退避 + 抖动）
  Duration _calculateReconnectDelay() {
    // 指数退避
    final exponentialDelay = _initialReconnectDelay.inMilliseconds * 
        pow(2, _reconnectAttempts);
    final clampedDelay = min(exponentialDelay, _maxReconnectDelay.inMilliseconds);
    
    // 添加抖动 (±20%)
    final jitter = (clampedDelay * 0.2 * (Random().nextDouble() - 0.5)).toInt();
    
    return Duration(milliseconds: clampedDelay + jitter);
  }
  
  /// 取消重连
  void _cancelReconnect() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }
  
  /// 断开连接
  void disconnect() {
    _cancelReconnect();
    _socket?.disconnect();
    _socket = null;
    _setState(WebSocketState.disconnected);
  }
  
  /// 重新连接
  void reconnect() {
    disconnect();
    _reconnectAttempts = 0;
    _currentReconnectDelay = _initialReconnectDelay;
    connect('wss://api.shanjing.app');
  }
  
  // ==================== 离线同步机制 (P1-5 Fix) ====================
  
  /// 添加待同步的解锁事件
  Future<void> queuePendingUnlock({
    required String achievementId,
    required String level,
    String? triggerType,
    Map<String, dynamic>? metadata,
  }) async {
    if (_userId == null) return;
    
    final pendingUnlock = PendingAchievementUnlock(
      userId: _userId!,
      achievementId: achievementId,
      level: level,
      timestamp: DateTime.now(),
      triggerType: triggerType,
      metadata: metadata,
    );
    
    _pendingUnlocks.add(pendingUnlock);
    await _savePendingUnlocks();
    
    debugPrint('Queued pending unlock: $achievementId - $level');
    
    // 如果在线，立即同步
    if (isConnected) {
      _syncPendingUnlocks();
    }
  }
  
  /// 同步离线解锁事件
  Future<void> _syncPendingUnlocks() async {
    if (!isConnected || _pendingUnlocks.isEmpty) return;
    
    final unlocksToSync = List<PendingAchievementUnlock>.from(_pendingUnlocks);
    
    try {
      _socket!.emit('sync_pending_unlocks', {
        'userId': _userId,
        'unlocks': unlocksToSync.map((u) => u.toJson()).toList(),
      });
      
      debugPrint('Syncing ${unlocksToSync.length} pending unlocks');
    } catch (e) {
      debugPrint('Failed to sync pending unlocks: $e');
    }
  }
  
  /// 移除已同步的事件
  Future<void> _removeSyncedUnlocks(List<dynamic> syncedIds) async {
    _pendingUnlocks.removeWhere((unlock) => 
      syncedIds.contains('${unlock.achievementId}_${unlock.timestamp.millisecondsSinceEpoch}'),
    );
    await _savePendingUnlocks();
  }
  
  /// 保存待同步事件到本地
  Future<void> _savePendingUnlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = _pendingUnlocks.map((u) => jsonEncode(u.toJson())).toList();
    await prefs.setStringList(_prefsKey, jsonList);
  }
  
  /// 从本地恢复待同步事件
  Future<void> _restorePendingUnlocks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_prefsKey);
    
    if (jsonList != null) {
      for (final json in jsonList) {
        try {
          final unlock = PendingAchievementUnlock.fromJson(jsonDecode(json));
          // 只保留7天内的事件
          if (DateTime.now().difference(unlock.timestamp).inDays <= 7) {
            _pendingUnlocks.add(unlock);
          }
        } catch (e) {
          debugPrint('Failed to restore pending unlock: $e');
        }
      }
      
      debugPrint('Restored ${_pendingUnlocks.length} pending unlocks');
    }
  }
  
  // ==================== 辅助方法 ====================
  
  void _setState(WebSocketState state) {
    if (_state != state) {
      _state = state;
      _stateController.add(state);
    }
  }
  
  AchievementLevel _parseLevel(String level) {
    switch (level.toLowerCase()) {
      case 'bronze':
        return AchievementLevel.bronze;
      case 'silver':
        return AchievementLevel.silver;
      case 'gold':
        return AchievementLevel.gold;
      case 'diamond':
        return AchievementLevel.diamond;
      default:
        return AchievementLevel.bronze;
    }
  }
  
  /// 释放资源
  void dispose() {
    disconnect();
    _stateController.close();
    _unlockController.close();
    _progressController.close();
  }
}

/// 随机数辅助类
class Random {
  static final _random = DateTime.now().millisecondsSinceEpoch;
  double nextDouble() => (_random % 10000) / 10000;
}
