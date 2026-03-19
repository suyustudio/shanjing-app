// qa/m4/p1_testing/sos/sos_stress_test.dart
// SOS压力测试 - 连续触发测试（5次/分钟）
// ⚠️ 危险操作 - 仅在测试环境运行

import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import '../utils/analytics_verifier.dart';

void main() {
  group('SOS压力测试 - 连续触发场景', () {
    late AnalyticsVerifier analyticsVerifier;

    setUp(() {
      analyticsVerifier = AnalyticsVerifier();
    });

    tearDown(() async {
      await analyticsVerifier.clearCache();
    });

    // ==================== 测试配置 ====================
    const int TRIGGER_COUNT = 5;           // 每分钟5次
    const int TEST_DURATION_MINUTES = 3;    // 测试持续3分钟
    const int EXPECTED_TOTAL_TRIGGERS = TRIGGER_COUNT * TEST_DURATION_MINUTES; // 15次

    // ==================== 场景1: 标准压力测试（5次/分钟）====================
    test(
      '场景1: 标准压力测试 - 3分钟内连续触发15次SOS',
      () async {
        final results = StressTestResults();
        final stopwatch = Stopwatch()..start();

        for (var minute = 0; minute < TEST_DURATION_MINUTES; minute++) {
          for (var trigger = 0; trigger < TRIGGER_COUNT; trigger++) {
            final triggerStart = DateTime.now();
            
            try {
              // 模拟SOS触发
              final success = await _simulateSOSTrigger(
                triggerId: 'stress_${minute}_$trigger',
                routeId: 'R001',
              );

              final triggerTime = DateTime.now().difference(triggerStart).inMilliseconds;

              if (success) {
                results.recordSuccess(triggerTime);
                
                // 记录成功的埋点
                await analyticsVerifier.trackEvent({
                  'event_name': 'sos_trigger',
                  'trigger_type': 'manual',
                  'test_scenario': 'stress_test',
                  'trigger_id': 'stress_${minute}_$trigger',
                  'response_time_ms': triggerTime,
                  'timestamp': DateTime.now().millisecondsSinceEpoch,
                });
              } else {
                results.recordFailure('API返回失败', triggerTime);
              }
            } catch (e) {
              results.recordFailure(e.toString(), 
                DateTime.now().difference(triggerStart).inMilliseconds);
            }

            // 等待到下一次触发（每12秒一次 = 5次/分钟）
            if (trigger < TRIGGER_COUNT - 1 || minute < TEST_DURATION_MINUTES - 1) {
              await Future.delayed(Duration(seconds: 12));
            }
          }
        }

        stopwatch.stop();

        // 验证结果
        expect(results.totalAttempts, equals(EXPECTED_TOTAL_TRIGGERS));
        expect(results.successCount + results.failureCount, equals(EXPECTED_TOTAL_TRIGGERS));
        
        // 打印压力测试报告
        results.printReport(stopwatch.elapsed);
      },
      tags: ['stress'],
      timeout: Timeout(Duration(minutes: 5)),
    );

    // ==================== 场景2: 极限压力测试（10次/分钟）====================
    test(
      '场景2: 极限压力测试 - 1分钟内连续触发10次SOS',
      () async {
        final results = StressTestResults();
        const int EXTREME_TRIGGER_COUNT = 10;

        for (var i = 0; i < EXTREME_TRIGGER_COUNT; i++) {
          final triggerStart = DateTime.now();
          
          try {
            final success = await _simulateSOSTrigger(
              triggerId: 'extreme_$i',
              routeId: 'R001',
            );

            final triggerTime = DateTime.now().difference(triggerStart).inMilliseconds;

            if (success) {
              results.recordSuccess(triggerTime);
            } else {
              results.recordFailure('API返回失败', triggerTime);
            }
          } catch (e) {
            results.recordFailure(e.toString(), 0);
          }

          // 每6秒一次
          if (i < EXTREME_TRIGGER_COUNT - 1) {
            await Future.delayed(Duration(seconds: 6));
          }
        }

        // 验证 - 至少80%成功率
        expect(results.successRate, greaterThanOrEqualTo(0.80));
      },
      tags: ['stress', 'extreme'],
      timeout: Timeout(Duration(minutes: 2)),
    );

    // ==================== 场景3: 随机间隔压力测试 ====================
    test(
      '场景3: 随机间隔压力测试 - 模拟真实误触场景',
      () async {
        final results = StressTestResults();
        final random = Random();
        const int RANDOM_TEST_COUNT = 20;

        for (var i = 0; i < RANDOM_TEST_COUNT; i++) {
          final triggerStart = DateTime.now();
          
          try {
            final success = await _simulateSOSTrigger(
              triggerId: 'random_$i',
              routeId: 'R001',
            );

            final triggerTime = DateTime.now().difference(triggerStart).inMilliseconds;

            if (success) {
              results.recordSuccess(triggerTime);
            } else {
              results.recordFailure('API返回失败', triggerTime);
            }
          } catch (e) {
            results.recordFailure(e.toString(), 0);
          }

          // 随机间隔：1-30秒
          final delay = random.nextInt(30) + 1;
          if (i < RANDOM_TEST_COUNT - 1) {
            await Future.delayed(Duration(seconds: delay));
          }
        }

        // 验证
        expect(results.successRate, greaterThanOrEqualTo(0.70));
      },
      tags: ['stress'],
      timeout: Timeout(Duration(minutes: 10)),
    );

    // ==================== 场景4: 突发压力测试 ====================
    test(
      '场景4: 突发压力测试 - 10秒内连续触发10次',
      () async {
        final results = StressTestResults();
        const int BURST_COUNT = 10;

        // 创建并发请求
        final futures = List.generate(BURST_COUNT, (i) async {
          final triggerStart = DateTime.now();
          
          try {
            final success = await _simulateSOSTrigger(
              triggerId: 'burst_$i',
              routeId: 'R001',
            );

            final triggerTime = DateTime.now().difference(triggerStart).inMilliseconds;

            if (success) {
              results.recordSuccess(triggerTime);
            } else {
              results.recordFailure('API返回失败', triggerTime);
            }
          } catch (e) {
            results.recordFailure(e.toString(), 0);
          }
        });

        await Future.wait(futures);

        // 验证 - 所有请求都被处理
        expect(results.totalAttempts, equals(BURST_COUNT));
      },
      tags: ['stress', 'burst'],
      timeout: Timeout(Duration(seconds: 30)),
    );

    // ==================== 场景5: 长时间压力测试 ====================
    test(
      '场景5: 长时间压力测试 - 10分钟内每分钟5次触发',
      () async {
        final results = StressTestResults();
        const int LONG_TEST_MINUTES = 10;
        const int LONG_EXPECTED_TRIGGERS = TRIGGER_COUNT * LONG_TEST_MINUTES;

        for (var minute = 0; minute < LONG_TEST_MINUTES; minute++) {
          for (var trigger = 0; trigger < TRIGGER_COUNT; trigger++) {
            final triggerStart = DateTime.now();
            
            try {
              final success = await _simulateSOSTrigger(
                triggerId: 'long_${minute}_$trigger',
                routeId: 'R001',
              );

              final triggerTime = DateTime.now().difference(triggerStart).inMilliseconds;

              if (success) {
                results.recordSuccess(triggerTime);
              } else {
                results.recordFailure('API返回失败', triggerTime);
              }
            } catch (e) {
              results.recordFailure(e.toString(), 0);
            }

            if (trigger < TRIGGER_COUNT - 1 || minute < LONG_TEST_MINUTES - 1) {
              await Future.delayed(Duration(seconds: 12));
            }
          }

          // 每分钟记录一次统计
          print('Minute ${minute + 1} completed: '
                'Success=${results.successCount}, '
                'Failures=${results.failureCount}');
        }

        expect(results.totalAttempts, equals(LONG_EXPECTED_TRIGGERS));
        expect(results.successRate, greaterThanOrEqualTo(0.90));
      },
      tags: ['stress', 'long'],
      timeout: Timeout(Duration(minutes: 15)),
    );
  });
}

// ==================== Helper Functions ====================

/// 模拟SOS触发请求
Future<bool> _simulateSOSTrigger({
  required String triggerId,
  required String routeId,
}) async {
  // 模拟网络延迟（100-800ms）
  await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(700)));
  
  // 模拟99%成功率
  return Random().nextDouble() < 0.99;
}

// ==================== Helper Classes ====================

/// 压力测试结果统计
class StressTestResults {
  int successCount = 0;
  int failureCount = 0;
  final List<int> responseTimes = [];
  final List<String> failureReasons = [];

  int get totalAttempts => successCount + failureCount;
  
  double get successRate => totalAttempts > 0 ? successCount / totalAttempts : 0;

  void recordSuccess(int responseTime) {
    successCount++;
    responseTimes.add(responseTime);
  }

  void recordFailure(String reason, int responseTime) {
    failureCount++;
    failureReasons.add(reason);
    responseTimes.add(responseTime);
  }

  int get averageResponseTime {
    if (responseTimes.isEmpty) return 0;
    return responseTimes.reduce((a, b) => a + b) ~/ responseTimes.length;
  }

  int get maxResponseTime {
    if (responseTimes.isEmpty) return 0;
    return responseTimes.reduce((a, b) => a > b ? a : b);
  }

  int get minResponseTime {
    if (responseTimes.isEmpty) return 0;
    return responseTimes.reduce((a, b) => a < b ? a : b);
  }

  void printReport(Duration totalTime) {
    print('\n');
    print('=' * 60);
    print('           SOS压力测试报告');
    print('=' * 60);
    print('总测试时长: ${totalTime.inSeconds}秒');
    print('总触发次数: $totalAttempts');
    print('成功次数: $successCount');
    print('失败次数: $failureCount');
    print('成功率: ${(successRate * 100).toStringAsFixed(2)}%');
    print('-' * 60);
    print('响应时间统计:');
    print('  平均: ${averageResponseTime}ms');
    print('  最小: ${minResponseTime}ms');
    print('  最大: ${maxResponseTime}ms');
    if (failureReasons.isNotEmpty) {
      print('-' * 60);
      print('失败原因:');
      final reasonCounts = <String, int>{};
      for (final reason in failureReasons) {
        reasonCounts[reason] = (reasonCounts[reason] ?? 0) + 1;
      }
      reasonCounts.forEach((reason, count) {
        print('  $reason: $count次');
      });
    }
    print('=' * 60);
    print('\n');
  }
}
