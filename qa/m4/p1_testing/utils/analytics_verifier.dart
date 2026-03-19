// qa/m4/p1_testing/utils/analytics_verifier.dart
// 埋点验证器 - 用于验证埋点数据的正确性

import 'dart:async';
import 'dart:convert';

/// 埋点验证器
class AnalyticsVerifier {
  final List<Map<String, dynamic>> _events = [];
  final List<Map<String, dynamic>> _cachedEvents = [];

  /// 记录埋点事件
  Future<void> trackEvent(Map<String, dynamic> event) async {
    // 确保事件包含必要字段
    if (!event.containsKey('timestamp')) {
      event['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    }
    
    _events.add(Map.from(event));
    
    // 模拟网络延迟
    await Future.delayed(Duration(milliseconds: 10));
  }

  /// 缓存事件（用于网络失败场景）
  Future<void> cacheEvent(Map<String, dynamic> event) async {
    if (!event.containsKey('timestamp')) {
      event['timestamp'] = DateTime.now().millisecondsSinceEpoch;
    }
    
    event['cached'] = true;
    _cachedEvents.add(Map.from(event));
    
    await Future.delayed(Duration(milliseconds: 10));
  }

  /// 根据事件名称获取事件列表
  List<Map<String, dynamic>> getEventsByName(String eventName) {
    return _events
      .where((e) => e['event_name'] == eventName)
      .toList();
  }

  /// 获取所有事件
  List<Map<String, dynamic>> getAllEvents() {
    return List.from(_events);
  }

  /// 获取缓存的事件
  List<Map<String, dynamic>> getCachedEvents() {
    return List.from(_cachedEvents);
  }

  /// 获取事件总数
  int get eventCount => _events.length;

  /// 获取缓存事件数量
  int get cachedEventCount => _cachedEvents.length;

  /// 清空所有事件
  Future<void> clearCache() async {
    _events.clear();
    _cachedEvents.clear();
    await Future.delayed(Duration(milliseconds: 10));
  }

  /// 验证事件参数
  bool verifyEventParams(
    String eventName, 
    Map<String, dynamic> expectedParams
  ) {
    final events = getEventsByName(eventName);
    if (events.isEmpty) return false;

    // 验证最新的事件
    final latestEvent = events.last;
    final params = latestEvent['params'] as Map<String, dynamic>? ?? {};

    for (final entry in expectedParams.entries) {
      if (params[entry.key] != entry.value) {
        return false;
      }
    }

    return true;
  }

  /// 验证事件时间戳顺序
  bool verifyTimestampOrder() {
    if (_events.length < 2) return true;

    for (var i = 1; i < _events.length; i++) {
      final current = _events[i]['timestamp'] as int? ?? 0;
      final previous = _events[i - 1]['timestamp'] as int? ?? 0;
      
      if (current < previous) {
        return false;
      }
    }

    return true;
  }

  /// 验证事件时间间隔
  bool verifyEventInterval(
    String eventName, 
    int minIntervalMs, 
    int maxIntervalMs
  ) {
    final events = getEventsByName(eventName);
    if (events.length < 2) return true;

    for (var i = 1; i < events.length; i++) {
      final current = events[i]['timestamp'] as int? ?? 0;
      final previous = events[i - 1]['timestamp'] as int? ?? 0;
      final interval = current - previous;

      if (interval < minIntervalMs || interval > maxIntervalMs) {
        return false;
      }
    }

    return true;
  }

  /// 导出事件数据为JSON
  String exportToJson() {
    return jsonEncode({
      'events': _events,
      'cached_events': _cachedEvents,
      'summary': {
        'total_events': _events.length,
        'cached_events': _cachedEvents.length,
        'unique_event_names': _events.map((e) => e['event_name']).toSet().toList(),
      },
    });
  }

  /// 生成验证报告
  Map<String, dynamic> generateReport() {
    final eventNames = _events.map((e) => e['event_name'] as String?).whereType<String>().toList();
    final uniqueNames = eventNames.toSet().toList();

    final eventCounts = <String, int>{};
    for (final name in eventNames) {
      eventCounts[name] = (eventCounts[name] ?? 0) + 1;
    }

    return {
      'total_events': _events.length,
      'cached_events': _cachedEvents.length,
      'unique_event_types': uniqueNames.length,
      'event_distribution': eventCounts,
      'timestamp_order_valid': verifyTimestampOrder(),
      'timestamp_range': _getTimestampRange(),
    };
  }

  /// 获取时间戳范围
  Map<String, int> _getTimestampRange() {
    if (_events.isEmpty) {
      return {'start': 0, 'end': 0};
    }

    final timestamps = _events
      .map((e) => e['timestamp'] as int? ?? 0)
      .toList();
    
    timestamps.sort();

    return {
      'start': timestamps.first,
      'end': timestamps.last,
    };
  }

  /// 打印验证报告
  void printReport() {
    final report = generateReport();
    
    print('\n');
    print('=' * 60);
    print('       埋点验证报告');
    print('=' * 60);
    print('总事件数: ${report['total_events']}');
    print('缓存事件数: ${report['cached_events']}');
    print('唯一事件类型: ${report['unique_event_types']}');
    print('时间戳顺序有效: ${report['timestamp_order_valid']}');
    print('-' * 60);
    print('事件分布:');
    (report['event_distribution'] as Map<String, dynamic>).forEach((name, count) {
      print('  $name: $count 次');
    });
    print('=' * 60);
    print('\n');
  }
}
