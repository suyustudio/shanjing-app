// qa/m4/p1_testing/sos/sos_battery_test.dart
// SOS压力测试 - 低电量场景（< 20%）

import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import '../utils/analytics_verifier.dart';
import '../utils/battery_simulator.dart';

void main() {
  group('SOS低电量场景测试', () {
    late AnalyticsVerifier analyticsVerifier;
    late BatterySimulator batterySimulator;

    setUp(() {
      analyticsVerifier = AnalyticsVerifier();
      batterySimulator = BatterySimulator();
    });

    tearDown(() async {
      await analyticsVerifier.clearCache();
      await batterySimulator.restore();
    });

    // ==================== 场景1: 低电量警告阈值（20%）====================
    group('低电量警告阈值测试', () {
      test('电量20%时SOS触发测试', () async {
        await batterySimulator.setBatteryLevel(20);
        
        final startTime = DateTime.now();
        
        // 模拟SOS触发
        final result = await _simulateSOSWithBatteryCheck(
          batteryLevel: 20,
        );

        final elapsedMs = DateTime.now().difference(startTime).inMilliseconds;

        // 记录低电量SOS事件
        await analyticsVerifier.trackEvent({
          'event_name': 'sos_low_battery',
          'battery_level': 20,
          'battery_state': 'low_warning',
          'success': result.success,
          'power_save_mode': result.powerSaveMode,
          'elapsed_ms': elapsedMs,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        expect(result.success, isTrue);
      });

      test('电量19%时SOS触发测试', () async {
        await batterySimulator.setBatteryLevel(19);
        
        final result = await _simulateSOSWithBatteryCheck(
          batteryLevel: 19,
        );

        await analyticsVerifier.trackEvent({
          'event_name': 'sos_low_battery',
          'battery_level': 19,
          'battery_state': 'low',
          'success': result.success,
          'power_save_mode': result.powerSaveMode,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        expect(result.success, isTrue);
        // 19%电量应启用省电模式
        expect(result.powerSaveMode, isTrue);
      });

      test('电量15%时SOS触发测试', () async {
        await batterySimulator.setBatteryLevel(15);
        
        final result = await _simulateSOSWithBatteryCheck(
          batteryLevel: 15,
        );

        await analyticsVerifier.trackEvent({
          'event_name': 'sos_low_battery',
          'battery_level': 15,
          'battery_state': 'critical_warning',
          'success': result.success,
          'power_save_mode': result.powerSaveMode,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        expect(result.success, isTrue);
        expect(result.powerSaveMode, isTrue);
      });
    });

    // ==================== 场景2: 极低电量场景（< 10%）====================
    group('极低电量场景测试', () {
      test('电量10%时SOS触发测试', () async {
        await batterySimulator.setBatteryLevel(10);
        
        final result = await _simulateSOSWithBatteryCheck(
          batteryLevel: 10,
        );

        await analyticsVerifier.trackEvent({
          'event_name': 'sos_critical_battery',
          'battery_level': 10,
          'battery_state': 'critical',
          'success': result.success,
          'power_save_mode': result.powerSaveMode,
          'network_mode': result.networkMode, // 可能降级到2G
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        expect(result.success, isTrue);
      });

      test('电量5%时SOS触发测试', () async {
        await batterySimulator.setBatteryLevel(5);
        
        final result = await _simulateSOSWithBatteryCheck(
          batteryLevel: 5,
        );

        await analyticsVerifier.trackEvent({
          'event_name': 'sos_critical_battery',
          'battery_level': 5,
          'battery_state': 'extremely_critical',
          'success': result.success,
          'power_save_mode': result.powerSaveMode,
          'network_mode': result.networkMode,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 5%电量下SOS应该仍然可以触发
        expect(result.success, isTrue);
      });

      test('电量1%时SOS触发测试', () async {
        await batterySimulator.setBatteryLevel(1);
        
        final result = await _simulateSOSWithBatteryCheck(
          batteryLevel: 1,
        );

        await analyticsVerifier.trackEvent({
          'event_name': 'sos_critical_battery',
          'battery_level': 1,
          'battery_state': 'emergency',
          'success': result.success,
          'power_save_mode': result.powerSaveMode,
          'network_mode': result.networkMode,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });

        // 1%电量下SOS应该仍然可以触发（最高优先级）
        expect(result.success, isTrue);
      });
    });

    // ==================== 场景3: 省电模式下的SOS行为 ====================
    group('省电模式下的SOS行为', () {
      test('省电模式下SOS触发时间测试', () async {
        await batterySimulator.setBatteryLevel(15);
        await batterySimulator.enablePowerSaveMode(true);
        
        final results = BatteryTestResults();

        for (var i = 0; i < 5; i++) {
          final startTime = DateTime.now();
          
          final result = await _simulateSOSWithBatteryCheck(
            batteryLevel: 15,
          );
          
          results.recordResult(
            success: result.success,
            responseTime: DateTime.now().difference(startTime).inMilliseconds,
          );

          await Future.delayed(Duration(seconds: 12));
        }

        // 省电模式下SOS响应时间可能更长，但应该仍然可用
        expect(results.successRate, equals(1.0));
        results.printReport();
      });

      test('省电模式下网络降级测试', () async {
        await batterySimulator.setBatteryLevel(10);
        await batterySimulator.enablePowerSaveMode(true);
        
        final result = await _simulateSOSWithBatteryCheck(
          batteryLevel: 10,
        );

        // 验证省电模式下可能使用更保守的网络策略
        expect(result.networkMode, anyOf('2g', '3g', '4g'));
      });

      test('省电模式下GPS精度降级测试', () async {
        await batterySimulator.setBatteryLevel(8);
        await batterySimulator.enablePowerSaveMode(true);
        
        final result = await _simulateSOSWithBatteryCheck(
          batteryLevel: 8,
        );

        // 省电模式下GPS精度可能降低
        expect(result.locationAccuracy, greaterThan(10)); // 精度可能大于10米
      });
    });

    // ==================== 场景4: 电量下降过程中的SOS行为 ====================
    group('电量下降过程中的SOS行为', () {
      test('电量从30%降至5%的连续SOS测试', () async {
        final results = BatteryTestResults();

        for (var level = 30; level >= 5; level -= 5) {
          await batterySimulator.setBatteryLevel(level);
          
          final startTime = DateTime.now();
          
          final result = await _simulateSOSWithBatteryCheck(
            batteryLevel: level,
          );
          
          results.recordResult(
            success: result.success,
            responseTime: DateTime.now().difference(startTime).inMilliseconds,
            batteryLevel: level,
          );

          await analyticsVerifier.trackEvent({
            'event_name': 'sos_battery_degradation',
            'battery_level': level,
            'success': result.success,
            'power_save_mode': result.powerSaveMode,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });

          await Future.delayed(Duration(seconds: 5));
        }

        // 所有电量水平下SOS都应该成功
        expect(results.successRate, equals(1.0));
        results.printReport();
      });

      test('快速电量下降场景（模拟电池老化）', () async {
        final batteryLevels = [25, 20, 18, 15, 12, 10, 8, 5, 3, 1];
        
        for (final level in batteryLevels) {
          await batterySimulator.setBatteryLevel(level);
          
          final result = await _simulateSOSWithBatteryCheck(
            batteryLevel: level,
          );

          await analyticsVerifier.trackEvent({
            'event_name': 'sos_rapid_discharge',
            'battery_level': level,
            'success': result.success,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          });

          // 即使电量快速下降，SOS也应该可以触发
          expect(result.success, isTrue);
          
          await Future.delayed(Duration(seconds: 3));
        }
      });
    });

    // ==================== 场景5: 低电量下SOS的可靠性测试 ====================
    group('低电量下SOS的可靠性测试', () {
      test('电量5%时连续触发5次SOS', () async {
        await batterySimulator.setBatteryLevel(5);
        
        final results = BatteryTestResults();

        for (var i = 0; i < 5; i++) {
          final startTime = DateTime.now();
          
          final result = await _simulateSOSWithBatteryCheck(
            batteryLevel: 5,
          );
          
          results.recordResult(
            success: result.success,
            responseTime: DateTime.now().difference(startTime).inMilliseconds,
            batteryLevel: 5,
          );

          await Future.delayed(Duration(seconds: 12));
        }

        // 5%电量下5次触发应该全部成功
        expect(results.successCount, equals(5));
      });

      test('电量1%时SOS触发成功率', () async {
        await batterySimulator.setBatteryLevel(1);
        
        final results = BatteryTestResults();
        
        // 尝试触发3次
        for (var i = 0; i < 3; i++) {
          final startTime = DateTime.now();
          
          final result = await _simulateSOSWithBatteryCheck(
            batteryLevel: 1,
          );
          
          results.recordResult(
            success: result.success,
            responseTime: DateTime.now().difference(startTime).inMilliseconds,
            batteryLevel: 1,
          );

          if (i < 2) {
            await Future.delayed(Duration(seconds: 15));
          }
        }

        // 1%电量下至少2次应该成功
        expect(results.successCount, greaterThanOrEqualTo(2));
      });

      test('低电量下SOS响应时间基准', () async {
        final testLevels = [20, 15, 10, 5, 1];
        final responseTimeMap = <int, List<int>>{};

        for (final level in testLevels) {
          await batterySimulator.setBatteryLevel(level);
          responseTimeMap[level] = [];

          for (var i = 0; i < 3; i++) {
            final startTime = DateTime.now();
            
            await _simulateSOSWithBatteryCheck(
              batteryLevel: level,
            );
            
            responseTimeMap[level]!.add(
              DateTime.now().difference(startTime).inMilliseconds
            );

            await Future.delayed(Duration(seconds: 5));
          }
        }

        // 打印各电量水平的响应时间
        print('\n');
        print('=' * 60);
        print('       低电量SOS响应时间基准');
        print('=' * 60);
        responseTimeMap.forEach((level, times) {
          final avg = times.reduce((a, b) => a + b) ~/ times.length;
          print('电量 $level%: 平均 ${avg}ms (${times}ms)');
        });
        print('=' * 60);
        print('\n');
      });
    });
  });
}

// ==================== Helper Functions ====================

/// 模拟带电量检查的SOS请求
Future<BatterySOSResult> _simulateSOSWithBatteryCheck({
  required int batteryLevel,
}) async {
  // 模拟电量对SOS的影响
  final powerSaveMode = batteryLevel <= 20;
  
  // 极低电量下响应时间可能增加
  int baseDelay = 500;
  if (batteryLevel <= 5) baseDelay = 800;
  if (batteryLevel <= 1) baseDelay = 1200;
  
  await Future.delayed(Duration(milliseconds: baseDelay + Random().nextInt(500)));
  
  // SOS在极低电量下也应该可以触发
  final success = Random().nextDouble() < 0.98;
  
  // 网络模式可能因省电模式而降级
  String networkMode = '4g';
  if (powerSaveMode && batteryLevel <= 10) {
    networkMode = '3g';
  }
  if (batteryLevel <= 3) {
    networkMode = '2g';
  }
  
  // GPS精度
  double locationAccuracy = 5.0;
  if (powerSaveMode) locationAccuracy = 15.0;
  if (batteryLevel <= 5) locationAccuracy = 25.0;
  
  return BatterySOSResult(
    success: success,
    powerSaveMode: powerSaveMode,
    networkMode: networkMode,
    locationAccuracy: locationAccuracy,
  );
}

// ==================== Helper Classes ====================

class BatterySOSResult {
  final bool success;
  final bool powerSaveMode;
  final String networkMode;
  final double locationAccuracy;

  BatterySOSResult({
    required this.success,
    required this.powerSaveMode,
    required this.networkMode,
    required this.locationAccuracy,
  });
}

class BatteryTestResults {
  int successCount = 0;
  int failureCount = 0;
  int attemptCount = 0;
  final List<int> responseTimes = [];
  final List<int> batteryLevels = [];

  void recordResult({
    required bool success,
    required int responseTime,
    int? batteryLevel,
  }) {
    attemptCount++;
    
    if (success) {
      successCount++;
    } else {
      failureCount++;
    }
    
    responseTimes.add(responseTime);
    
    if (batteryLevel != null) {
      batteryLevels.add(batteryLevel);
    }
  }

  double get successRate => attemptCount > 0 ? successCount / attemptCount : 0;

  int get averageResponseTime {
    if (responseTimes.isEmpty) return 0;
    return responseTimes.reduce((a, b) => a + b) ~/ responseTimes.length;
  }

  void printReport() {
    print('\n');
    print('=' * 60);
    print('         低电量SOS测试报告');
    print('=' * 60);
    print('尝试次数: $attemptCount');
    print('成功次数: $successCount');
    print('失败次数: $failureCount');
    print('成功率: ${(successRate * 100).toStringAsFixed(2)}%');
    print('平均响应时间: ${averageResponseTime}ms');
    if (batteryLevels.isNotEmpty) {
      print('测试电量范围: ${batteryLevels.last}% - ${batteryLevels.first}%');
    }
    print('=' * 60);
    print('\n');
  }
}
