import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sos_event.dart';
import 'lifeline_service.dart';

/// 离线缓存服务
/// 管理SOS事件的离线缓存和网络恢复后的自动补发
class OfflineCacheService {
  static const String _cacheKey = 'offline_sos_cache';
  static const String _lastCleanupKey = 'offline_cache_last_cleanup';
  static const int _maxCacheDays = 7;
  static const int _maxRetryAttempts = 5;

  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  SharedPreferences? _prefs;
  final _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isRetrying = false;

  // 状态回调
  Function(SosEvent, bool)? onEventStatusChanged;
  Function(int pendingCount)? onPendingCountChanged;

  /// 初始化服务
  Future<void> initialize() async {
    _prefs ??= await SharedPreferences.getInstance();
    _startConnectivityMonitoring();
    await _performCleanupIfNeeded();
  }

  /// 开始网络状态监听
  void _startConnectivityMonitoring() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (results) {
        // 只要有非none的连接就尝试重发
        if (results.any((r) => r != ConnectivityResult.none)) {
          _onNetworkRestored();
        }
      },
    );
  }

  /// 网络恢复处理
  Future<void> _onNetworkRestored() async {
    if (_isRetrying) return;
    
    final pendingEvents = await getPendingEvents();
    if (pendingEvents.isNotEmpty) {
      await retryFailedEvents();
    }
  }

  /// 缓存SOS事件
  Future<bool> cacheSosEvent(SosEvent event) async {
    await initialize();
    
    try {
      final events = await _getAllCachedEvents();
      events.add(event);
      await _saveCachedEvents(events);
      
      onPendingCountChanged?.call(events.where((e) => e.canRetry).length);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 更新SOS事件状态
  Future<bool> updateEventStatus(
    String eventId, {
    required SosEventStatus status,
    DateTime? sentAt,
    String? errorMessage,
  }) async {
    await initialize();
    
    try {
      final events = await _getAllCachedEvents();
      final index = events.indexWhere((e) => e.id == eventId);
      
      if (index == -1) return false;
      
      final updatedEvent = events[index].copyWith(
        status: status,
        sentAt: sentAt,
        errorMessage: errorMessage,
      );
      
      events[index] = updatedEvent;
      await _saveCachedEvents(events);
      
      onEventStatusChanged?.call(updatedEvent, status == SosEventStatus.sent);
      onPendingCountChanged?.call(events.where((e) => e.canRetry).length);
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取所有缓存的事件
  Future<List<SosEvent>> getAllCachedEvents() async {
    await initialize();
    return _getAllCachedEvents();
  }

  /// 获取待发送的事件
  Future<List<SosEvent>> getPendingEvents() async {
    final events = await getAllCachedEvents();
    return events.where((e) => e.canRetry).toList();
  }

  /// 获取已发送的事件
  Future<List<SosEvent>> getSentEvents() async {
    final events = await getAllCachedEvents();
    return events.where((e) => e.status == SosEventStatus.sent).toList();
  }

  /// 获取统计信息
  Future<OfflineCacheStats> getStats() async {
    final events = await getAllCachedEvents();
    
    return OfflineCacheStats(
      totalCount: events.length,
      pendingCount: events.where((e) => e.canRetry).length,
      sentCount: events.where((e) => e.status == SosEventStatus.sent).length,
      failedCount: events.where((e) => e.status == SosEventStatus.failed).length,
      expiredCount: events.where((e) => e.isExpired).length,
    );
  }

  /// 尝试重发失败的事件
  Future<RetryResult> retryFailedEvents() async {
    if (_isRetrying) {
      return RetryResult(
        attempted: 0,
        succeeded: 0,
        failed: 0,
        message: '重发任务正在进行中',
      );
    }

    _isRetrying = true;
    
    try {
      // 检查网络连接
      final connectivityResult = await _connectivity.checkConnectivity();
      if (connectivityResult == ConnectivityResult.none) {
        _isRetrying = false;
        return RetryResult(
          attempted: 0,
          succeeded: 0,
          failed: 0,
          message: '无网络连接，无法重发',
        );
      }

      final pendingEvents = await getPendingEvents();
      
      if (pendingEvents.isEmpty) {
        _isRetrying = false;
        return RetryResult(
          attempted: 0,
          succeeded: 0,
          failed: 0,
          message: '没有待发送的事件',
        );
      }

      int succeeded = 0;
      int failed = 0;

      for (final event in pendingEvents) {
        try {
          // 更新状态为发送中
          await updateEventStatus(
            event.id,
            status: SosEventStatus.sending,
            lastRetryAt: DateTime.now(),
          );

          // 尝试发送
          final sent = await _sendSosEvent(event);

          if (sent) {
            await updateEventStatus(
              event.id,
              status: SosEventStatus.sent,
              sentAt: DateTime.now(),
            );
            succeeded++;
          } else {
            final retryCount = event.retryCount + 1;
            final isFinalRetry = retryCount >= _maxRetryAttempts;
            
            await updateEventStatus(
              event.id,
              status: isFinalRetry ? SosEventStatus.failed : SosEventStatus.pending,
              errorMessage: '发送失败，已重试 $retryCount 次',
              lastRetryAt: DateTime.now(),
            );
            failed++;
          }
        } catch (e) {
          failed++;
          await updateEventStatus(
            event.id,
            status: SosEventStatus.failed,
            errorMessage: '异常: $e',
            lastRetryAt: DateTime.now(),
          );
        }
      }

      _isRetrying = false;
      
      return RetryResult(
        attempted: pendingEvents.length,
        succeeded: succeeded,
        failed: failed,
        message: '重发完成: $succeeded 成功, $failed 失败',
      );
    } catch (e) {
      _isRetrying = false;
      return RetryResult(
        attempted: 0,
        succeeded: 0,
        failed: 0,
        message: '重发异常: $e',
      );
    }
  }

  /// 清理过期数据
  Future<int> cleanupExpiredCache() async {
    await initialize();
    
    try {
      final events = await _getAllCachedEvents();
      final originalCount = events.length;
      
      // 保留：未过期 或 7天内已发送的事件
      events.retainWhere((event) {
        // 保留待发送且未过期的
        if (event.status == SosEventStatus.pending && !event.isExpired) {
          return true;
        }
        
        // 保留最近7天内已发送的（用于历史查看）
        if (event.status == SosEventStatus.sent && event.sentAt != null) {
          final sevenDaysAgo = DateTime.now().subtract(const Duration(days: _maxCacheDays));
          return event.sentAt!.isAfter(sevenDaysAgo);
        }
        
        return false;
      });

      await _saveCachedEvents(events);
      
      final cleanedCount = originalCount - events.length;
      await _prefs?.setString(_lastCleanupKey, DateTime.now().toIso8601String());
      
      return cleanedCount;
    } catch (e) {
      return 0;
    }
  }

  /// 清除所有缓存
  Future<bool> clearAllCache() async {
    await initialize();
    
    try {
      await _prefs?.remove(_cacheKey);
      onPendingCountChanged?.call(0);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 获取上次清理时间
  Future<DateTime?> getLastCleanupTime() async {
    await initialize();
    
    final timeStr = _prefs?.getString(_lastCleanupKey);
    if (timeStr == null) return null;
    
    try {
      return DateTime.parse(timeStr);
    } catch (e) {
      return null;
    }
  }

  /// 释放资源
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  // ========== 私有方法 ==========

  /// 获取所有缓存的事件（内部方法）
  Future<List<SosEvent>> _getAllCachedEvents() async {
    final encryptedList = _prefs?.getStringList(_cacheKey) ?? [];
    final events = <SosEvent>[];

    for (final encrypted in encryptedList) {
      final event = SosEvent.decryptFromStorage(encrypted);
      if (event != null) {
        events.add(event);
      }
    }

    return events;
  }

  /// 保存缓存的事件
  Future<void> _saveCachedEvents(List<SosEvent> events) async {
    final encryptedList = events.map((e) => e.encryptForStorage()).toList();
    await _prefs?.setStringList(_cacheKey, encryptedList);
  }

  /// 发送SOS事件
  Future<bool> _sendSosEvent(SosEvent event) async {
    try {
      // 使用LifelineService发送SOS
      final lifelineService = LifelineService();
      
      final success = await lifelineService.sendSOS(
        note: event.note ?? '[离线缓存补发] ${event.createdAt}',
      );

      return success;
    } catch (e) {
      return false;
    }
  }

  /// 检查是否需要清理
  Future<void> _performCleanupIfNeeded() async {
    final lastCleanup = await getLastCleanupTime();
    final now = DateTime.now();
    
    // 每天最多清理一次
    if (lastCleanup == null || now.difference(lastCleanup).inHours >= 24) {
      await cleanupExpiredCache();
    }
  }
}

/// 重发结果
class RetryResult {
  final int attempted;
  final int succeeded;
  final int failed;
  final String message;

  RetryResult({
    required this.attempted,
    required this.succeeded,
    required this.failed,
    required this.message,
  });

  bool get success => succeeded > 0 && failed == 0;

  @override
  String toString() => message;
}

/// 缓存统计
class OfflineCacheStats {
  final int totalCount;
  final int pendingCount;
  final int sentCount;
  final int failedCount;
  final int expiredCount;

  OfflineCacheStats({
    required this.totalCount,
    required this.pendingCount,
    required this.sentCount,
    required this.failedCount,
    required this.expiredCount,
  });

  @override
  String toString() {
    return 'OfflineCacheStats(total: $totalCount, pending: $pendingCount, sent: $sentCount)';
  }
}
