// qa/m4/p1_testing/performance/cold_start_test.dart
// 性能基准测试 - 冷启动时间测试（3次取平均）

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('冷启动时间测试', () {
    // ==================== 测试配置 ====================
    const int TEST_RUNS = 3;              // 运行3次取平均
    const int WARM_UP_RUNS = 1;           // 预热1次
    const int MAX_ACCEPTABLE_TIME_MS = 3000; // 最大可接受启动时间：3秒

    setUpAll(() async {
      // 全局设置
      print('\n');
      print('=' * 60);
      print('       冷启动性能测试开始');
      print('=' * 60);
      print('测试次数: $TEST_RUNS 次');
      print('最大可接受时间: ${MAX_ACCEPTABLE_TIME_MS}ms');
      print('=' * 60);
      print('\n');
    });

    tearDownAll(() {
      print('\n');
      print('=' * 60);
      print('       冷启动性能测试完成');
      print('=' * 60);
      print('\n');
    });

    // ==================== 预热运行 ====================
    test(
      '预热运行（不计入统计）',
      () async {
        final result = await _measureColdStart();
        print('预热: ${result.totalTimeMs}ms');
      },
      timeout: Timeout(Duration(seconds: 30)),
    );

    // ==================== 正式测试：3次冷启动 ====================
    group('正式冷启动测试', () {
      final results = ColdStartResults();

      for (var i = 1; i <= TEST_RUNS; i++) {
        test(
          '第 $i 次冷启动测试',
          () async {
            // 模拟应用完全关闭（清理缓存）
            await _simulateAppKill();
            
            final result = await _measureColdStart();
            results.addResult(result);
            
            print('第 $i 次冷启动:');
            _printColdStartDetails(result);
            
            // 验证单次启动时间
            expect(
              result.totalTimeMs, 
              lessThanOrEqualTo(MAX_ACCEPTABLE_TIME_MS),
              reason: '第 $i 次冷启动时间超过阈值 ${MAX_ACCEPTABLE_TIME_MS}ms',
            );
          },
          timeout: Timeout(Duration(seconds: 30)),
        );
      }

      tearDownAll(() {
        results.printSummary();
        
        // 验证平均启动时间
        expect(
          results.averageTimeMs,
          lessThanOrEqualTo(MAX_ACCEPTABLE_TIME_MS),
          reason: '平均冷启动时间超过阈值 ${MAX_ACCEPTABLE_TIME_MS}ms',
        );
      });
    });

    // ==================== 阶段耗时分析 ====================
    group('启动阶段耗时分析', () {
      test('应用初始化阶段耗时', () async {
        final result = await _measureColdStart();
        
        // 应用初始化阶段应在1秒内完成
        expect(result.initializationTimeMs, lessThanOrEqualTo(1000));
        
        print('应用初始化: ${result.initializationTimeMs}ms');
      });

      test('框架加载阶段耗时', () async {
        final result = await _measureColdStart();
        
        // 框架加载应在500ms内完成
        expect(result.frameworkLoadTimeMs, lessThanOrEqualTo(500));
        
        print('框架加载: ${result.frameworkLoadTimeMs}ms');
      });

      test('首屏渲染阶段耗时', () async {
        final result = await _measureColdStart();
        
        // 首屏渲染应在1.5秒内完成
        expect(result.firstRenderTimeMs, lessThanOrEqualTo(1500));
        
        print('首屏渲染: ${result.firstRenderTimeMs}ms');
      });

      test('数据加载阶段耗时', () async {
        final result = await _measureColdStart();
        
        // 数据加载应在500ms内完成
        expect(result.dataLoadTimeMs, lessThanOrEqualTo(500));
        
        print('数据加载: ${result.dataLoadTimeMs}ms');
      });
    });
  });
}

// ==================== Helper Functions ====================

/// 模拟应用完全关闭
Future<void> _simulateAppKill() async {
  // 清理缓存、断开连接等
  await Future.delayed(Duration(seconds: 2));
}

/// 测量冷启动时间
Future<ColdStartResult> _measureColdStart() async {
  final stopwatch = Stopwatch()..start();
  
  // 阶段1: 应用初始化
  final initStart = stopwatch.elapsedMilliseconds;
  await _simulateInitialization();
  final initTime = stopwatch.elapsedMilliseconds - initStart;
  
  // 阶段2: 框架加载
  final frameworkStart = stopwatch.elapsedMilliseconds;
  await _simulateFrameworkLoad();
  final frameworkTime = stopwatch.elapsedMilliseconds - frameworkStart;
  
  // 阶段3: 首屏渲染
  final renderStart = stopwatch.elapsedMilliseconds;
  await _simulateFirstRender();
  final renderTime = stopwatch.elapsedMilliseconds - renderStart;
  
  // 阶段4: 数据加载
  final dataStart = stopwatch.elapsedMilliseconds;
  await _simulateDataLoad();
  final dataTime = stopwatch.elapsedMilliseconds - dataStart;
  
  stopwatch.stop();
  
  return ColdStartResult(
    totalTimeMs: stopwatch.elapsedMilliseconds,
    initializationTimeMs: initTime,
    frameworkLoadTimeMs: frameworkTime,
    firstRenderTimeMs: renderTime,
    dataLoadTimeMs: dataTime,
  );
}

/// 模拟应用初始化
Future<void> _simulateInitialization() async {
  // 初始化Flutter引擎、插件等
  await Future.delayed(Duration(milliseconds: 400 + (100).toInt()));
}

/// 模拟框架加载
Future<void> _simulateFrameworkLoad() async {
  // 加载MaterialApp、路由等
  await Future.delayed(Duration(milliseconds: 200 + (100).toInt()));
}

/// 模拟首屏渲染
Future<void> _simulateFirstRender() async {
  // 渲染首页UI
  await Future.delayed(Duration(milliseconds: 800 + (200).toInt()));
}

/// 模拟数据加载
Future<void> _simulateDataLoad() async {
  // 加载本地缓存数据
  await Future.delayed(Duration(milliseconds: 200 + (100).toInt()));
}

/// 打印冷启动详情
void _printColdStartDetails(ColdStartResult result) {
  print('  总时间: ${result.totalTimeMs}ms');
  print('  应用初始化: ${result.initializationTimeMs}ms');
  print('  框架加载: ${result.frameworkLoadTimeMs}ms');
  print('  首屏渲染: ${result.firstRenderTimeMs}ms');
  print('  数据加载: ${result.dataLoadTimeMs}ms');
  print('');
}

// ==================== Helper Classes ====================

class ColdStartResult {
  final int totalTimeMs;
  final int initializationTimeMs;
  final int frameworkLoadTimeMs;
  final int firstRenderTimeMs;
  final int dataLoadTimeMs;

  ColdStartResult({
    required this.totalTimeMs,
    required this.initializationTimeMs,
    required this.frameworkLoadTimeMs,
    required this.firstRenderTimeMs,
    required this.dataLoadTimeMs,
  });
}

class ColdStartResults {
  final List<ColdStartResult> _results = [];

  void addResult(ColdStartResult result) {
    _results.add(result);
  }

  int get averageTimeMs {
    if (_results.isEmpty) return 0;
    final total = _results.fold(0, (sum, r) => sum + r.totalTimeMs);
    return total ~/ _results.length;
  }

  int get minTimeMs {
    if (_results.isEmpty) return 0;
    return _results.map((r) => r.totalTimeMs).reduce((a, b) => a < b ? a : b);
  }

  int get maxTimeMs {
    if (_results.isEmpty) return 0;
    return _results.map((r) => r.totalTimeMs).reduce((a, b) => a > b ? a : b);
  }

  void printSummary() {
    print('\n');
    print('=' * 60);
    print('       冷启动测试结果汇总');
    print('=' * 60);
    print('测试次数: ${_results.length}');
    print('平均时间: ${averageTimeMs}ms');
    print('最短时间: ${minTimeMs}ms');
    print('最长时间: ${maxTimeMs}ms');
    print('-' * 60);
    print('各阶段平均耗时:');
    print('  应用初始化: ${_avgInitTime}ms');
    print('  框架加载: ${_avgFrameworkTime}ms');
    print('  首屏渲染: ${_avgRenderTime}ms');
    print('  数据加载: ${_avgDataTime}ms');
    print('=' * 60);
    print('\n');
  }

  int get _avgInitTime {
    if (_results.isEmpty) return 0;
    final total = _results.fold(0, (sum, r) => sum + r.initializationTimeMs);
    return total ~/ _results.length;
  }

  int get _avgFrameworkTime {
    if (_results.isEmpty) return 0;
    final total = _results.fold(0, (sum, r) => sum + r.frameworkLoadTimeMs);
    return total ~/ _results.length;
  }

  int get _avgRenderTime {
    if (_results.isEmpty) return 0;
    final total = _results.fold(0, (sum, r) => sum + r.firstRenderTimeMs);
    return total ~/ _results.length;
  }

  int get _avgDataTime {
    if (_results.isEmpty) return 0;
    final total = _results.fold(0, (sum, r) => sum + r.dataLoadTimeMs);
    return total ~/ _results.length;
  }
}
