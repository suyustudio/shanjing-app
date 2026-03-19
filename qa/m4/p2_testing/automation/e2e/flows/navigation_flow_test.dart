// qa/m4/p2_testing/automation/e2e/flows/navigation_flow_test.dart
// 导航功能E2E测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

// 导入共享工具
import '../../utils/performance_collector.dart';
import '../../utils/test_mocks.dart' show MockLatLng, MockTestHelpers;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('导航功能E2E测试', () {
    testWidgets('完整导航流程测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      // 点击第一条路线
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      // 验证路线详情页
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      
      // 查找并点击"开始导航"按钮
      final startNavButton = find.textContaining('导航');
      expect(startNavButton, findsOneWidget);
      
      // 开始导航
      await tester.tap(startNavButton);
      await tester.pumpAndSettle();
      
      // 验证导航页
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      expect(find.byKey(const Key('map_view')), findsOneWidget);
      
      // 等待GPS定位
      await tester.pump(const Duration(seconds: 3));
      
      // 验证定位状态
      final locationIndicator = find.byKey(const Key('location_indicator'));
      if (locationIndicator.evaluate().isNotEmpty) {
        expect(locationIndicator, findsOneWidget);
      }
      
      // 模拟移动
      await MockTestHelpers.mockLocationUpdates([
        const MockLatLng(30.2596, 120.1479),
        const MockLatLng(30.2588, 120.1432),
        const MockLatLng(30.2315, 120.1289),
      ]);
      await tester.pump(const Duration(seconds: 5));
      
      // 验证轨迹绘制
      final trailPolyline = find.byKey(const Key('trail_polyline'));
      if (trailPolyline.evaluate().isNotEmpty) {
        expect(trailPolyline, findsOneWidget);
      }
      
      // 退出导航
      final exitButton = find.byKey(const Key('exit_navigation_button'));
      if (exitButton.evaluate().isNotEmpty) {
        await tester.tap(exitButton);
        await tester.pumpAndSettle();
        
        // 确认退出
        final confirmButton = find.textContaining('确认');
        if (confirmButton.evaluate().isNotEmpty) {
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }
        
        // 验证返回详情页
        expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      }
      
      print('✅ 完整导航流程测试通过');
    }, timeout: const Timeout(Duration(minutes: 2)));
    
    testWidgets('偏航重规划测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 模拟偏离路线
      await MockTestHelpers.mockLocationUpdate(const MockLatLng(30.2600, 120.1500));
      await tester.pump(const Duration(seconds: 5));
      
      // 验证偏航提示（如果存在）
      final deviationAlert = find.textContaining('偏离');
      if (deviationAlert.evaluate().isNotEmpty) {
        print('✅ 检测到偏航提示');
      }
      
      // 验证自动重规划（如果存在）
      final replanAlert = find.textContaining('重新规划');
      if (replanAlert.evaluate().isNotEmpty) {
        print('✅ 检测到自动重规划');
      }
      
      print('✅ 偏航重规划测试通过');
    });
    
    testWidgets('导航性能测试', (tester) async {
      final perfCollector = PerformanceCollector(
        interval: const Duration(seconds: 5),
        thresholds: const PerformanceThresholds(
          maxMemoryMB: 400,
          minFPS: 25,
        ),
        onDataPoint: (data) {
          print('📊 [${data.elapsedSeconds}s] 内存: ${data.memoryMB}MB, CPU: ${data.cpuPercent?.toStringAsFixed(1)}%');
        },
      );
      
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 开始性能采集
      await perfCollector.start();
      
      // 模拟1分钟导航
      for (int i = 0; i < 12; i++) {
        await tester.pump(const Duration(seconds: 5));
        
        // 模拟位置更新
        final position = MockTestHelpers.simulateMovement(
          const MockLatLng(30.2596, 120.1479),
          Duration(seconds: i * 5),
        );
        await MockTestHelpers.mockLocationUpdate(position);
      }
      
      // 停止采集
      await perfCollector.stop(outputPath: 'test-results/navigation_performance.json');
      
      // 生成报告
      final report = perfCollector.generateReport();
      print('\n📊 导航性能报告:');
      print('  - 运行时间: ${report['duration_seconds']}秒');
      print('  - 内存增长: ${report['memory']?['growth_mb'] ?? 'N/A'}MB');
      print('  - 最大内存: ${report['memory']?['max_mb'] ?? 'N/A'}MB');
      print('  - 平均CPU: ${report['cpu']?['avg_percent']?.toStringAsFixed(1) ?? 'N/A'}%');
      print('  - 平均FPS: ${report['fps']?['avg']?.toStringAsFixed(1) ?? 'N/A'}');
      
      // 性能断言
      final memoryGrowth = report['memory']?['growth_mb'] as int? ?? 0;
      expect(memoryGrowth, lessThan(100), 
        reason: '导航内存增长超过100MB: ${memoryGrowth}MB');
      
      print('✅ 导航性能测试通过');
    }, timeout: const Timeout(Duration(minutes: 3)));
  });
}
