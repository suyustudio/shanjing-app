// qa/m4/p2_testing/performance/route_switch_test.dart
// 多路线切换性能测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

// 导入共享工具
import '../utils/performance_collector.dart';
import '../utils/test_mocks.dart' show MockTestHelpers;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('多路线切换性能测试', () {
    testWidgets('10次路线切换性能测试', (tester) async {
      final perfCollector = PerformanceCollector(
        interval: const Duration(seconds: 5),
        onDataPoint: (data) {
          print('📊 [${data.elapsedSeconds}s] 内存: ${data.memoryMB}MB');
        },
      );
      
      app.main();
      await tester.pumpAndSettle();
      
      await perfCollector.start();
      
      // 测试路线列表
      final routes = [
        {'id': 'R001', 'name': '九溪烟树线'},
        {'id': 'R002', 'name': '龙井村线'},
        {'id': 'R003', 'name': '宝石山线'},
        {'id': 'R004', 'name': '云栖竹径'},
        {'id': 'R005', 'name': '满觉陇线'},
        {'id': 'R006', 'name': '玉皇山线'},
        {'id': 'R007', 'name': '灵隐寺线'},
        {'id': 'R008', 'name': '法喜寺线'},
        {'id': 'R009', 'name': '西湖环湖线'},
        {'id': 'R010', 'name': '断桥残雪线'},
      ];
      
      final results = <Map<String, dynamic>>[];
      
      for (int i = 0; i < routes.length; i++) {
        final route = routes[i];
        final stopwatch = Stopwatch()..start();
        
        print('\n--- 路线 ${i + 1}/${routes.length}: ${route['name']} ---');
        
        // 1. 进入发现页
        await tester.tap(find.byKey(const Key('discover_tab')));
        await tester.pumpAndSettle();
        
        // 2. 进入路线详情页
        final routeKey = find.byKey(Key('route_${route['id']}'));
        final cardFinder = find.byType(Card);
        
        if (routeKey.evaluate().isNotEmpty) {
          await tester.tap(routeKey);
        } else if (cardFinder.evaluate().isNotEmpty) {
          await tester.tap(cardFinder.first);
        }
        await tester.pumpAndSettle();
        
        final detailLoadTime = stopwatch.elapsedMilliseconds;
        print('📄 详情页加载: ${detailLoadTime}ms');
        
        // 验证详情页显示
        final routeNameFinder = find.textContaining(route['name']!);
        if (routeNameFinder.evaluate().isNotEmpty) {
          expect(routeNameFinder, findsOneWidget);
        }
        
        // 2. 开始导航
        await tester.tap(find.textContaining('导航'));
        await tester.pumpAndSettle();
        
        final navigationStartTime = stopwatch.elapsedMilliseconds;
        final navigationLoadDuration = navigationStartTime - detailLoadTime;
        print('🧭 导航启动耗时: ${navigationLoadDuration}ms');
        
        // 验证导航页显示
        expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
        
        // 等待3秒模拟导航
        await tester.pump(const Duration(seconds: 3));
        
        // 3. 退出导航
        final exitButton = find.byKey(const Key('exit_navigation'));
        if (exitButton.evaluate().isNotEmpty) {
          await tester.tap(exitButton);
          await tester.pumpAndSettle();
          
          // 确认退出
          final confirmButton = find.textContaining('确认');
          if (confirmButton.evaluate().isNotEmpty) {
            await tester.tap(confirmButton);
            await tester.pumpAndSettle();
          }
        }
        
        // 4. 返回路线列表
        final backButton = find.byKey(const Key('back_button'));
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
        
        stopwatch.stop();
        
        final totalTime = stopwatch.elapsedMilliseconds;
        print('⏱️  总切换时间: ${totalTime}ms');
        
        // 采集内存数据
        final memory = await PerformanceCollector.getMemoryUsageMB();
        print('🧠 当前内存: ${memory}MB');
        
        results.add({
          'round': i + 1,
          'route_id': route['id'],
          'route_name': route['name'],
          'detail_load_ms': detailLoadTime,
          'navigation_load_ms': navigationLoadDuration,
          'total_switch_ms': totalTime,
          'memory_mb': memory,
        });
      }
      
      await perfCollector.stop();
      
      // 分析结果
      print('\n========== 📊 路线切换性能报告 ==========');
      
      // 计算平均时间
      final avgDetailLoad = results.map((r) => r['detail_load_ms'] as int)
          .reduce((a, b) => a + b) / results.length;
      final avgNavLoad = results.map((r) => r['navigation_load_ms'] as int)
          .reduce((a, b) => a + b) / results.length;
      final avgTotal = results.map((r) => r['total_switch_ms'] as int)
          .reduce((a, b) => a + b) / results.length;
      
      print('📄 平均详情页加载时间: ${avgDetailLoad.toStringAsFixed(0)}ms');
      print('🧭 平均导航启动时间: ${avgNavLoad.toStringAsFixed(0)}ms');
      print('⏱️  平均总切换时间: ${avgTotal.toStringAsFixed(0)}ms');
      
      // 内存分析
      final firstMemory = results.first['memory_mb'] as int;
      final lastMemory = results.last['memory_mb'] as int;
      final memoryGrowth = lastMemory - firstMemory;
      
      print('');
      print('🧠 内存分析:');
      print('  - 初始内存: ${firstMemory}MB');
      print('  - 最终内存: ${lastMemory}MB');
      print('  - 内存增长: ${memoryGrowth}MB');
      
      // 使用性能报告数据
      final report = perfCollector.generateReport();
      final memoryData = report['memory'] as Map<String, dynamic>?;
      if (memoryData != null) {
        print('  - 峰值内存: ${memoryData['max_mb']}MB');
        print('  - 平均内存: ${(memoryData['avg_mb'] as double).toStringAsFixed(1)}MB');
      }
      
      // 检测内存泄漏
      final leakDetected = _detectMemoryLeak(results);
      print('');
      print(leakDetected ? '⚠️ 警告: 检测到内存泄漏趋势' : '✅ 内存趋势: 正常');
      
      print('========================================');
      
      // 断言验证
      expect(avgDetailLoad, lessThan(2000.0), 
        reason: '平均详情页加载时间超过2秒: ${avgDetailLoad.toStringAsFixed(0)}ms');
      expect(avgNavLoad, lessThan(2000.0), 
        reason: '平均导航启动时间超过2秒: ${avgNavLoad.toStringAsFixed(0)}ms');
      expect(avgTotal, lessThan(3000.0), 
        reason: '平均总切换时间超过3秒: ${avgTotal.toStringAsFixed(0)}ms');
      expect(leakDetected, false, reason: '检测到内存泄漏');
      expect(memoryGrowth, lessThan(80), 
        reason: '内存增长超过80MB: ${memoryGrowth}MB');
      
      // 保存测试数据
      await PerformanceCollector.saveTestData('route_switch_10rounds', {
        'routes_tested': routes.length,
        'results': results,
        'avg_detail_load_ms': avgDetailLoad,
        'avg_navigation_load_ms': avgNavLoad,
        'avg_total_switch_ms': avgTotal,
        'memory_growth_mb': memoryGrowth,
        'leak_detected': leakDetected,
      }, directory: 'test-results');
      
      print('✅ 10次路线切换性能测试通过');
      
    }, timeout: const Timeout(Duration(minutes: 5)));
    
    testWidgets('快速连续切换测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      final switchTimes = <int>[];
      final memorySnapshots = <int>[];
      
      // 快速连续切换5次
      for (int i = 0; i < 5; i++) {
        final stopwatch = Stopwatch()..start();
        
        // 进入详情
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();
        
        // 立即返回
        final backButton = find.byKey(const Key('back_button'));
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
        
        stopwatch.stop();
        switchTimes.add(stopwatch.elapsedMilliseconds);
        
        // 采集内存
        final memory = await PerformanceCollector.getMemoryUsageMB();
        memorySnapshots.add(memory);
        
        print('🔄 快速切换 ${i + 1}: ${stopwatch.elapsedMilliseconds}ms, 内存: ${memory}MB');
      }
      
      final avgTime = switchTimes.reduce((a, b) => a + b) / switchTimes.length;
      final memoryGrowth = memorySnapshots.last - memorySnapshots.first;
      
      print('');
      print('📊 快速切换报告:');
      print('  - 平均切换时间: ${avgTime.toStringAsFixed(0)}ms');
      print('  - 内存增长: ${memoryGrowth}MB');
      
      expect(avgTime, lessThan(1500.0), 
        reason: '快速切换时间超过1.5秒: ${avgTime.toStringAsFixed(0)}ms');
      expect(memoryGrowth, lessThan(50), 
        reason: '快速切换内存增长超过50MB: ${memoryGrowth}MB');
      
      print('✅ 快速连续切换测试通过');
    });
    
    testWidgets('路线切换内存稳定性测试', (tester) async {
      final memoryMonitor = MemoryMonitor();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 初始内存
      await memoryMonitor.takeSnapshot();
      print('🧠 初始内存: ${memoryMonitor.snapshots.first.memoryMB}MB');
      
      // 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      // 循环切换20次
      for (int i = 0; i < 20; i++) {
        // 进入详情
        await tester.tap(find.byType(Card).first);
        await tester.pumpAndSettle();
        
        // 采集内存
        await memoryMonitor.takeSnapshot();
        
        // 返回
        final backButton = find.byKey(const Key('back_button'));
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();
        }
        
        if ((i + 1) % 5 == 0) {
          print('🔄 切换 ${i + 1}/20 - 内存: ${memoryMonitor.snapshots.last.memoryMB}MB');
        }
      }
      
      // 分析内存趋势
      final trend = memoryMonitor.getTrend();
      final snapshots = memoryMonitor.snapshots;
      final growth = snapshots.last.memoryMB - snapshots.first.memoryMB;
      
      print('');
      print('📊 内存稳定性报告:');
      print('  - 趋势: $trend');
      print('  - 总增长: ${growth}MB');
      print('  - 快照数: ${snapshots.length}');
      
      // 内存应该保持稳定
      expect(trend != MemoryTrend.increasing || growth < 30, true,
        reason: '内存持续增长，可能存在内存泄漏: ${growth}MB');
      
      print('✅ 路线切换内存稳定性测试通过');
    });
  });
}

// 内存泄漏检测
bool _detectMemoryLeak(List<Map<String, dynamic>> results) {
  if (results.length < 3) return false;
  
  // 使用线性回归检测内存泄漏趋势
  final n = results.length;
  final memories = results.map((r) => r['memory_mb'] as int).toList();
  
  // 计算斜率
  final meanX = (n - 1) / 2;
  final meanY = memories.reduce((a, b) => a + b) / n;
  
  double numerator = 0;
  double denominator = 0;
  
  for (int i = 0; i < n; i++) {
    numerator += (i - meanX) * (memories[i] - meanY);
    denominator += (i - meanX) * (i - meanX);
  }
  
  final slope = numerator / denominator;
  
  // 如果每次切换平均增长超过5MB，认为有泄漏
  return slope > 5;
}
