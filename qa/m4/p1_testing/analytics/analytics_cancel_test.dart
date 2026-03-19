// qa/m4/p1_testing/analytics/analytics_cancel_test.dart
// 埋点专项测试 - 用户取消分享/SOS时的埋点（2个场景）

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import '../utils/analytics_verifier.dart';

void main() {
  group('用户取消操作埋点测试 - 2个场景', () {
    late AnalyticsVerifier analyticsVerifier;

    setUp(() {
      analyticsVerifier = AnalyticsVerifier();
    });

    tearDown(() async {
      await analyticsVerifier.clearCache();
    });

    // ==================== 场景1: 分享取消埋点 ====================
    group('分享取消埋点 - 4个阶段测试', () {
      test('阶段1: 模板选择阶段取消', () async {
        // 模拟用户进入分享面板
        final openTime = DateTime.now();
        
        // 用户预览了2个模板后取消
        await Future.delayed(Duration(seconds: 2));
        
        // 触发取消埋点
        await analyticsVerifier.trackEvent({
          'event_name': 'share_cancel',
          'route_id': 'R001',
          'route_name': '九溪十八涧',
          'cancel_stage': 'template_select',
          'cancel_reason': 'user_cancel',
          'time_spent_ms': DateTime.now().difference(openTime).inMilliseconds,
          'template_previewed': 2,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证
        final cancelEvents = await analyticsVerifier.getEventsByName('share_cancel');
        expect(cancelEvents.length, equals(1));
        
        final event = cancelEvents[0];
        expect(event['cancel_stage'], equals('template_select'));
        expect(event['cancel_reason'], equals('user_cancel'));
        expect(event['time_spent_ms'], greaterThanOrEqualTo(2000));
        expect(event['template_previewed'], equals(2));
      });

      test('阶段2: 渠道选择阶段取消', () async {
        final openTime = DateTime.now();
        
        // 选择模板后，在渠道选择阶段取消
        await Future.delayed(Duration(seconds: 3));
        
        await analyticsVerifier.trackEvent({
          'event_name': 'share_cancel',
          'route_id': 'R002',
          'route_name': '龙井村步道',
          'cancel_stage': 'channel_select',
          'cancel_reason': 'back_pressed',
          'time_spent_ms': DateTime.now().difference(openTime).inMilliseconds,
          'template_previewed': 1,
          'selected_template': 'nature',
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证
        final cancelEvents = await analyticsVerifier.getEventsByName('share_cancel');
        expect(cancelEvents[0]['cancel_stage'], equals('channel_select'));
        expect(cancelEvents[0]['cancel_reason'], equals('back_pressed'));
      });

      test('阶段3: 海报生成阶段取消', () async {
        final openTime = DateTime.now();
        
        // 海报生成过程中取消
        await Future.delayed(Duration(seconds: 5));
        
        await analyticsVerifier.trackEvent({
          'event_name': 'share_cancel',
          'route_id': 'R003',
          'route_name': '宝石山环线',
          'cancel_stage': 'generation',
          'cancel_reason': 'outside_tap',
          'time_spent_ms': DateTime.now().difference(openTime).inMilliseconds,
          'template_previewed': 3,
          'selected_template': 'film',
          'generation_progress': 45, // 生成进度45%
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证
        final cancelEvents = await analyticsVerifier.getEventsByName('share_cancel');
        expect(cancelEvents[0]['cancel_stage'], equals('generation'));
        expect(cancelEvents[0]['generation_progress'], equals(45));
      });

      test('阶段4: 确认分享阶段取消', () async {
        final openTime = DateTime.now();
        
        // 海报生成完成后，在最后确认阶段取消
        await Future.delayed(Duration(seconds: 8));
        
        await analyticsVerifier.trackEvent({
          'event_name': 'share_cancel',
          'route_id': 'R004',
          'route_name': '云栖竹径',
          'cancel_stage': 'confirm',
          'cancel_reason': 'user_cancel',
          'time_spent_ms': DateTime.now().difference(openTime).inMilliseconds,
          'template_previewed': 2,
          'selected_template': 'minimal',
          'selected_channel': 'wechat_timeline',
          'poster_size_kb': 245,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证
        final cancelEvents = await analyticsVerifier.getEventsByName('share_cancel');
        expect(cancelEvents[0]['cancel_stage'], equals('confirm'));
        expect(cancelEvents[0]['selected_channel'], equals('wechat_timeline'));
        expect(cancelEvents[0]['poster_size_kb'], equals(245));
      });

      test('分享取消漏斗分析数据完整性', () async {
        // 模拟100次分享操作，记录各阶段取消数据
        final stages = ['template_select', 'channel_select', 'generation', 'confirm'];
        final reasons = ['user_cancel', 'back_pressed', 'outside_tap'];
        
        for (var i = 0; i < 100; i++) {
          await analyticsVerifier.trackEvent({
            'event_name': 'share_cancel',
            'route_id': 'R${i.toString().padLeft(3, '0')}',
            'cancel_stage': stages[i % 4],
            'cancel_reason': reasons[i % 3],
            'time_spent_ms': (i + 1) * 1000,
            'template_previewed': (i % 3) + 1,
            'timestamp': DateTime.now().millisecondsSinceEpoch + i,
          });
        }

        // 验证数据完整性
        final allCancelEvents = await analyticsVerifier.getEventsByName('share_cancel');
        expect(allCancelEvents.length, equals(100));
        
        // 按阶段统计
        for (final stage in stages) {
          final stageEvents = allCancelEvents.where((e) => e['cancel_stage'] == stage).toList();
          expect(stageEvents.length, equals(25)); // 100 / 4 = 25
        }
      });
    });

    // ==================== 场景2: SOS取消埋点 ====================
    group('SOS取消埋点 - 3个阶段测试', () {
      test('阶段1: SOS按钮点击后立即取消', () async {
        final sosOpenTime = DateTime.now();
        
        // 用户点击SOS按钮后立即取消
        await Future.delayed(Duration(milliseconds: 500));
        
        await analyticsVerifier.trackEvent({
          'event_name': 'sos_cancel',
          'trigger_stage': 'button_click',
          'cancel_reason': 'user_cancel',
          'countdown_remaining_sec': 5,
          'location_lat': 30.2741,
          'location_lng': 120.1551,
          'time_since_open_ms': DateTime.now().difference(sosOpenTime).inMilliseconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证
        final cancelEvents = await analyticsVerifier.getEventsByName('sos_cancel');
        expect(cancelEvents.length, equals(1));
        
        final event = cancelEvents[0];
        expect(event['trigger_stage'], equals('button_click'));
        expect(event['countdown_remaining_sec'], equals(5));
        expect(event['location_lat'], closeTo(30.2741, 0.0001));
      });

      test('阶段2: 倒计时期间取消', () async {
        final sosOpenTime = DateTime.now();
        
        // 倒计时进行2秒后取消
        await Future.delayed(Duration(seconds: 2));
        final remainingSeconds = 3; // 5 - 2 = 3
        
        await analyticsVerifier.trackEvent({
          'event_name': 'sos_cancel',
          'trigger_stage': 'countdown',
          'cancel_reason': 'back_pressed',
          'countdown_remaining_sec': remainingSeconds,
          'location_lat': 30.2741,
          'location_lng': 120.1551,
          'location_accuracy': 8.5,
          'time_since_open_ms': DateTime.now().difference(sosOpenTime).inMilliseconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证
        final cancelEvents = await analyticsVerifier.getEventsByName('sos_cancel');
        expect(cancelEvents[0]['trigger_stage'], equals('countdown'));
        expect(cancelEvents[0]['countdown_remaining_sec'], equals(3));
      });

      test('阶段3: 确认对话框阶段取消', () async {
        final sosOpenTime = DateTime.now();
        
        // 倒计时结束后，在确认对话框阶段取消
        await Future.delayed(Duration(seconds: 6));
        
        await analyticsVerifier.trackEvent({
          'event_name': 'sos_cancel',
          'trigger_stage': 'confirm_dialog',
          'cancel_reason': 'user_cancel',
          'countdown_remaining_sec': 0,
          'location_lat': 30.2741,
          'location_lng': 120.1551,
          'location_accuracy': 5.2,
          'route_id': 'R001',
          'contact_count': 2,
          'time_since_open_ms': DateTime.now().difference(sosOpenTime).inMilliseconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证
        final cancelEvents = await analyticsVerifier.getEventsByName('sos_cancel');
        expect(cancelEvents[0]['trigger_stage'], equals('confirm_dialog'));
        expect(cancelEvents[0]['route_id'], equals('R001'));
        expect(cancelEvents[0]['contact_count'], equals(2));
      });

      test('倒计时中断场景（应用退出/锁屏）', () async {
        final sosOpenTime = DateTime.now();
        
        await Future.delayed(Duration(seconds: 1));
        
        await analyticsVerifier.trackEvent({
          'event_name': 'sos_cancel',
          'trigger_stage': 'countdown',
          'cancel_reason': 'countdown_interrupted',
          'countdown_remaining_sec': 4,
          'interruption_type': 'app_background', // app_background / screen_lock / phone_call
          'location_lat': 30.2741,
          'location_lng': 120.1551,
          'time_since_open_ms': DateTime.now().difference(sosOpenTime).inMilliseconds,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 验证
        final cancelEvents = await analyticsVerifier.getEventsByName('sos_cancel');
        expect(cancelEvents[0]['cancel_reason'], equals('countdown_interrupted'));
        expect(cancelEvents[0]['interruption_type'], equals('app_background'));
      });

      test('SOS取消位置信息精度验证', () async {
        // 测试不同精度下的位置信息记录
        final testCases = [
          {'accuracy': 5.0, 'lat': 30.274100, 'lng': 120.155100},
          {'accuracy': 50.0, 'lat': 30.274000, 'lng': 120.155000},
          {'accuracy': 200.0, 'lat': 30.273900, 'lng': 120.154900},
        ];

        for (final testCase in testCases) {
          await analyticsVerifier.trackEvent({
            'event_name': 'sos_cancel',
            'trigger_stage': 'countdown',
            'cancel_reason': 'user_cancel',
            'countdown_remaining_sec': 3,
            'location_lat': testCase['lat'],
            'location_lng': testCase['lng'],
            'location_accuracy': testCase['accuracy'],
            'time_since_open_ms': 2000,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });
        }

        // 验证所有事件都记录了位置信息
        final cancelEvents = await analyticsVerifier.getEventsByName('sos_cancel');
        expect(cancelEvents.length, equals(3));
        
        for (var i = 0; i < cancelEvents.length; i++) {
          expect(cancelEvents[i]['location_lat'], isNotNull);
          expect(cancelEvents[i]['location_lng'], isNotNull);
          expect(cancelEvents[i]['location_accuracy'], isNotNull);
        }
      });
    });

    group('取消操作埋点边界测试', () {
      test('快速重复取消操作', () async {
        // 模拟用户快速多次取消
        for (var i = 0; i < 10; i++) {
          await analyticsVerifier.trackEvent({
            'event_name': i % 2 == 0 ? 'share_cancel' : 'sos_cancel',
            'cancel_stage': 'template_select',
            'cancel_reason': 'user_cancel',
            'timestamp': DateTime.now().millisecondsSinceEpoch + i * 100,
          });
        }

        final shareCancels = await analyticsVerifier.getEventsByName('share_cancel');
        final sosCancels = await analyticsVerifier.getEventsByName('sos_cancel');
        
        expect(shareCancels.length, equals(5));
        expect(sosCancels.length, equals(5));
      });

      test('时间戳精度验证', () async {
        final startTime = DateTime.now().millisecondsSinceEpoch;
        
        await analyticsVerifier.trackEvent({
          'event_name': 'share_cancel',
          'cancel_stage': 'confirm',
          'timestamp': startTime,
        });

        final events = await analyticsVerifier.getEventsByName('share_cancel');
        expect(events[0]['timestamp'], equals(startTime));
      });
    });
  });
}
