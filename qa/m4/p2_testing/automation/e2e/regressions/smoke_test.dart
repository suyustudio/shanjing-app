// qa/m4/p2_testing/automation/e2e/regressions/smoke_test.dart
// 烟雾测试 - 快速验证核心流程

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

// 导入共享工具
import '../../utils/performance_collector.dart';
import '../../utils/test_mocks.dart' show MockTestHelpers;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('烟雾测试 - 核心流程快速验证', () {
    testWidgets('APP启动测试', (tester) async {
      final stopwatch = Stopwatch()..start();
      final perfCollector = PerformanceCollector(interval: const Duration(seconds: 1));
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证首页加载
      expect(find.byKey(const Key('home_page')), findsOneWidget);
      
      print('✅ APP启动时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
        reason: 'APP启动时间超过3秒');
      
      // 性能检查
      final memory = await PerformanceCollector.getMemoryUsageMB();
      print('📊 启动后内存使用: ${memory}MB');
      expect(memory, lessThan(300), reason: '启动内存超过300MB');
    });
    
    testWidgets('发现页加载测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证路线列表加载
      expect(find.byType(Card), findsWidgets);
      
      print('✅ 发现页加载时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
        reason: '发现页加载时间超过2秒');
    });
    
    testWidgets('路线详情页加载测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      // 点击第一个路线卡片
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证详情页加载
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      
      // 查找"开始导航"按钮（文字可能略有不同）
      final navigationButton = find.textContaining('导航');
      expect(navigationButton, findsOneWidget);
      
      print('✅ 路线详情页加载时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
        reason: '路线详情页加载时间超过2秒');
    });
    
    testWidgets('导航页启动测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      // 点击导航按钮
      await tester.tap(find.textContaining('导航'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证导航页加载
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      
      print('✅ 导航页启动时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
        reason: '导航页启动时间超过2秒');
      
      // 退出导航
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
    });
    
    testWidgets('个人中心加载测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证个人中心加载
      expect(find.textContaining('我的'), findsOneWidget);
      
      print('✅ 个人中心加载时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1500),
        reason: '个人中心加载时间超过1.5秒');
    });
    
    testWidgets('全量烟雾测试', (tester) async {
      final totalStopwatch = Stopwatch()..start();
      final perfCollector = PerformanceCollector(
        interval: const Duration(seconds: 5),
        onDataPoint: (data) {
          print('📊 [${data.elapsedSeconds}s] 内存: ${data.memoryMB}MB, 电量: ${data.batteryPercent}%');
        },
      );
      
      await perfCollector.start();
      
      // 1. 启动APP
      app.main();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_page')), findsOneWidget);
      print('✅ 步骤1: APP启动成功');
      
      // 2. 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      expect(find.byType(Card), findsWidgets);
      print('✅ 步骤2: 发现页加载成功');
      
      // 3. 进入路线详情
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      print('✅ 步骤3: 路线详情页加载成功');
      
      // 4. 返回发现页
      final backButton = find.byKey(const Key('back_button'));
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        print('✅ 步骤4: 返回发现页成功');
      }
      
      // 5. 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      expect(find.textContaining('我的'), findsOneWidget);
      print('✅ 步骤5: 个人中心加载成功');
      
      totalStopwatch.stop();
      await perfCollector.stop(outputPath: 'test-results/smoke_test_performance.json');
      
      print('✅ 全量烟雾测试完成，总耗时: ${totalStopwatch.elapsedMilliseconds}ms');
      expect(totalStopwatch.elapsedMilliseconds, lessThan(10000),
        reason: '全量烟雾测试超过10秒');
      
      // 输出性能报告
      final report = perfCollector.generateReport();
      print('\n📊 性能报告:');
      print('  - 内存增长: ${report['memory']?['growth_mb'] ?? 'N/A'}MB');
      print('  - 电量消耗: ${report['battery']?['consumption_percent'] ?? 'N/A'}%');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}
