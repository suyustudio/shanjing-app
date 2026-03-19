// qa/m4/p1_testing/analytics/analytics_network_test.dart
// 埋点专项测试 - 网络失败场景（6个场景）

import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../utils/network_simulator.dart';
import '../utils/analytics_verifier.dart';

@GenerateMocks([http.Client])
void main() {
  group('网络失败时埋点行为测试 - 6个场景', () {
    late NetworkSimulator networkSimulator;
    late AnalyticsVerifier analyticsVerifier;
    late MockClient mockClient;

    setUp(() {
      networkSimulator = NetworkSimulator();
      analyticsVerifier = AnalyticsVerifier();
      mockClient = MockClient();
    });

    tearDown(() async {
      await networkSimulator.restoreNetwork();
      await analyticsVerifier.clearCache();
    });

    // ==================== 场景1: 完全断网 ====================
    test('场景1: 完全断网时埋点应缓存到本地', () async {
      // 准备
      await networkSimulator.setNetworkState(NetworkState.disconnected);
      final testEvent = {
        'event_name': 'share_trail',
        'route_id': 'R001',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // 执行
      await analyticsVerifier.trackEvent(testEvent);

      // 验证
      final cachedEvents = await analyticsVerifier.getCachedEvents();
      expect(cachedEvents.length, equals(1));
      expect(cachedEvents[0]['event_name'], equals('share_trail'));
      expect(cachedEvents[0]['route_id'], equals('R001'));
      
      // 验证 analytics_cache_stored 事件已触发
      final cacheEvents = await analyticsVerifier.getEventsByName('analytics_cache_stored');
      expect(cacheEvents.length, equals(1));
      expect(cacheEvents[0]['params']['original_event'], equals('share_trail'));
      expect(cacheEvents[0]['params']['cache_size'], equals(1));
    });

    // ==================== 场景2: 弱网环境（2G模拟）====================
    test('场景2: 2G弱网环境下埋点应正常缓存', () async {
      // 准备
      await networkSimulator.setNetworkState(NetworkState.g2);
      final testEvent = {
        'event_name': 'sos_trigger',
        'trigger_type': 'manual',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // 执行
      await analyticsVerifier.trackEvent(testEvent);
      await Future.delayed(Duration(seconds: 15)); // 等待超时

      // 验证
      final cachedEvents = await analyticsVerifier.getCachedEvents();
      expect(cachedEvents.length, greaterThanOrEqualTo(1));
      
      // 验证超时重试逻辑
      final retryCount = cachedEvents[0]['retry_count'] ?? 0;
      expect(retryCount, greaterThanOrEqualTo(1));
    });

    // ==================== 场景3: 网络波动场景 ====================
    test('场景3: 网络波动时埋点应正确处理断点续传', () async {
      // 准备
      final events = List.generate(5, (i) => {
        'event_name': 'button_click',
        'button_id': 'btn_$i',
        'timestamp': DateTime.now().millisecondsSinceEpoch + i,
      });

      // 模拟网络波动：连接-断开-连接
      await networkSimulator.setNetworkState(NetworkState.wifi);
      await analyticsVerifier.trackEvent(events[0]);
      
      await networkSimulator.setNetworkState(NetworkState.disconnected);
      await analyticsVerifier.trackEvent(events[1]);
      await analyticsVerifier.trackEvent(events[2]);
      
      await networkSimulator.setNetworkState(NetworkState.wifi);
      await analyticsVerifier.trackEvent(events[3]);
      await analyticsVerifier.trackEvent(events[4]);

      // 验证
      final cachedEvents = await analyticsVerifier.getCachedEvents();
      expect(cachedEvents.length, equals(2)); // 网络断开时的2个事件
      
      // 网络恢复后批量上报
      await networkSimulator.flushPendingEvents();
      final pendingAfterFlush = await analyticsVerifier.getCachedEvents();
      expect(pendingAfterFlush.length, equals(0));
    });

    // ==================== 场景4: 缓存溢出场景 ====================
    test('场景4: 缓存满50条时应移除最旧数据', () async {
      // 准备
      await networkSimulator.setNetworkState(NetworkState.disconnected);
      
      // 生成51个事件
      for (var i = 0; i < 51; i++) {
        await analyticsVerifier.trackEvent({
          'event_name': 'page_view',
          'page_id': 'page_$i',
          'timestamp': DateTime.now().millisecondsSinceEpoch + i,
        });
      }

      // 验证
      final cachedEvents = await analyticsVerifier.getCachedEvents();
      expect(cachedEvents.length, equals(50)); // 最大缓存50条
      expect(cachedEvents[0]['page_id'], equals('page_1')); // 最旧的被移除
      expect(cachedEvents[49]['page_id'], equals('page_50')); // 最新的保留
    });

    // ==================== 场景5: 网络恢复后批量上报 ====================
    test('场景5: 网络恢复后应批量上报缓存事件', () async {
      // 准备
      await networkSimulator.setNetworkState(NetworkState.disconnected);
      
      final testEvents = List.generate(10, (i) => {
        'event_name': 'navigation_start',
        'route_id': 'R00$i',
        'timestamp': DateTime.now().millisecondsSinceEpoch + i * 1000,
      });

      // 缓存事件
      for (final event in testEvents) {
        await analyticsVerifier.trackEvent(event);
      }

      // 网络恢复
      await networkSimulator.setNetworkState(NetworkState.wifi);
      
      // 执行批量上报
      final flushResult = await networkSimulator.flushPendingEvents();

      // 验证
      expect(flushResult.successCount, equals(10));
      expect(flushResult.failedCount, equals(0));
      
      // 验证 analytics_batch_sent 事件
      final batchEvents = await analyticsVerifier.getEventsByName('analytics_batch_sent');
      expect(batchEvents.length, equals(1));
      expect(batchEvents[0]['params']['event_count'], equals(10));
    });

    // ==================== 场景6: 重试次数超限丢弃事件 ====================
    test('场景6: 超过5次重试后应丢弃事件并上报', () async {
      // 准备 - 模拟持续断网
      await networkSimulator.setNetworkState(NetworkState.disconnected);
      
      final testEvent = {
        'event_name': 'trail_complete',
        'route_id': 'R001',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      };

      // 执行
      await analyticsVerifier.trackEvent(testEvent);

      // 模拟5次重试失败
      for (var i = 0; i < 5; i++) {
        await networkSimulator.setNetworkState(NetworkState.wifi);
        await Future.delayed(Duration(milliseconds: 100));
        await networkSimulator.setNetworkState(NetworkState.disconnected);
        await Future.delayed(Duration(seconds: 2));
      }

      // 最终网络恢复
      await networkSimulator.setNetworkState(NetworkState.wifi);
      await networkSimulator.flushPendingEvents();

      // 验证
      final droppedEvents = await analyticsVerifier.getEventsByName('analytics_event_dropped');
      expect(droppedEvents.length, equals(1));
      expect(droppedEvents[0]['params']['original_event'], equals('trail_complete'));
      expect(droppedEvents[0]['params']['retry_count'], equals(5));
    });
  });

  group('网络状态转换边界测试', () {
    test('快速网络切换不应导致数据丢失', () async {
      final simulator = NetworkSimulator();
      final verifier = AnalyticsVerifier();
      
      for (var i = 0; i < 100; i++) {
        await simulator.setNetworkState(
          i % 2 == 0 ? NetworkState.wifi : NetworkState.disconnected
        );
        await verifier.trackEvent({
          'event_name': 'test_event',
          'sequence': i,
        });
      }
      
      // 验证所有事件都被正确处理
      final allEvents = await verifier.getAllEvents();
      expect(allEvents.length, equals(100));
    });
  });
}

// ==================== Mock Classes ====================
class MockClient extends Mock implements http.Client {}
