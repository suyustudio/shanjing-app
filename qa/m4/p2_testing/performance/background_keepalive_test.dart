// qa/m4/p2_testing/performance/background_keepalive_test.dart
// 后台保活测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

// 导入共享工具
import '../utils/performance_collector.dart';
import '../utils/test_mocks.dart' show MockLatLng, MockTestHelpers;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('后台保活测试', () {
    testWidgets('5分钟后台保活测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 记录初始位置和时间
      final initialPosition = await MockTestHelpers.getCurrentPosition();
      
      print('📍 初始位置: $initialPosition');
      
      // 模拟轨迹点
      final trackPoints = [initialPosition];
      
      // 切换到后台
      await PerformanceCollector.simulateBackgroundSwitch();
      print('📱 APP已切换到后台');
      
      // 模拟5分钟后台运行
      final backgroundDuration = const Duration(minutes: 5);
      final checkInterval = const Duration(seconds: 30);
      var elapsed = Duration.zero;
      
      while (elapsed < backgroundDuration) {
        await Future.delayed(checkInterval);
        elapsed += checkInterval;
        
        // 模拟位置更新
        final newPosition = MockTestHelpers.simulateMovement(initialPosition, elapsed);
        trackPoints.add(newPosition);
        
        print('⏱️  后台运行中... ${elapsed.inSeconds}秒, 位置: $newPosition');
      }
      
      // 返回前台
      await PerformanceCollector.simulateForegroundReturn();
      await tester.pumpAndSettle();
      print('📱 APP已返回前台');
      
      // 获取实际轨迹数据
      final actualTrackPoints = await MockTestHelpers.getTrackPoints();
      
      // 分析轨迹连续性
      final gaps = MockTestHelpers.findTrackGaps(actualTrackPoints, thresholdSeconds: 30);
      
      print('\n========== 📊 5分钟后台保活测试报告 ==========');
      print('⏱️  后台运行时长: ${elapsed.inMinutes}分钟');
      print('📍 预期轨迹点数: ${trackPoints.length}');
      print('📍 实际轨迹点数: ${actualTrackPoints.length}');
      print('❌ 轨迹断点数: ${gaps.length}');
      
      if (gaps.isNotEmpty) {
        print('断点详情:');
        for (final gap in gaps) {
          print('  - ${gap['start']} 到 ${gap['end']}, 持续 ${gap['duration']}秒');
        }
      }
      print('========================================');
      
      // 断言验证
      expect(actualTrackPoints.isNotEmpty, true, 
        reason: '后台期间无轨迹数据');
      expect(gaps.isEmpty, true, 
        reason: '检测到轨迹断点: ${gaps.length}个');
      
      // 保存测试数据
      await PerformanceCollector.saveTestData('background_keepalive_5min', {
        'duration_seconds': elapsed.inSeconds,
        'expected_points': trackPoints.length,
        'actual_points': actualTrackPoints.length,
        'gap_count': gaps.length,
        'gaps': gaps,
      });
      
      print('✅ 5分钟后台保活测试通过');
    }, timeout: const Timeout(Duration(minutes: 10)));
    
    testWidgets('15分钟后台保活测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 记录初始位置
      final initialPosition = await MockTestHelpers.getCurrentPosition();
      
      // 切换到后台
      await PerformanceCollector.simulateBackgroundSwitch();
      print('📱 APP已切换到后台 - 开始15分钟测试');
      
      // 初始化性能采集
      final perfCollector = PerformanceCollector(interval: const Duration(minutes: 1));
      await perfCollector.start();
      
      // 模拟15分钟后台运行
      final backgroundDuration = const Duration(minutes: 15);
      final checkInterval = const Duration(minutes: 1);
      var elapsed = Duration.zero;
      
      while (elapsed < backgroundDuration) {
        await Future.delayed(checkInterval);
        elapsed += checkInterval;
        print('⏱️  后台运行中... ${elapsed.inMinutes}分钟');
      }
      
      // 返回前台
      await PerformanceCollector.simulateForegroundReturn();
      await tester.pumpAndSettle();
      print('📱 APP已返回前台');
      
      await perfCollector.stop();
      
      // 获取轨迹数据
      final trackPoints = await MockTestHelpers.getTrackPoints();
      final gaps = MockTestHelpers.findTrackGaps(trackPoints, thresholdSeconds: 60);
      
      print('\n========== 📊 15分钟后台保活测试报告 ==========');
      print('⏱️  后台运行时长: ${elapsed.inMinutes}分钟');
      print('📍 轨迹点数: ${trackPoints.length}');
      print('❌ 轨迹断点数: ${gaps.length}');
      print('========================================');
      
      // 15分钟允许最多2个断点（系统限制）
      expect(gaps.length, lessThanOrEqualTo(2), 
        reason: '断点数超过2个: ${gaps.length}个');
      
      // 保存测试数据
      await PerformanceCollector.saveTestData('background_keepalive_15min', {
        'duration_seconds': elapsed.inSeconds,
        'track_point_count': trackPoints.length,
        'gap_count': gaps.length,
        'gaps': gaps,
      });
      
      print('✅ 15分钟后台保活测试通过');
    }, timeout: const Timeout(Duration(minutes: 20)));
    
    testWidgets('多任务切换测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      const switchCount = 5;
      
      for (int i = 0; i < switchCount; i++) {
        print('🔄 切换 ${i + 1}/$switchCount');
        
        // 切换到后台
        await PerformanceCollector.simulateBackgroundSwitch();
        await Future.delayed(const Duration(seconds: 10));
        
        // 返回前台
        await PerformanceCollector.simulateForegroundReturn();
        await tester.pumpAndSettle();
        
        // 验证导航状态
        expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
        
        // 短暂停留
        await Future.delayed(const Duration(seconds: 5));
      }
      
      print('✅ 多任务切换测试完成');
      
      // 获取最终轨迹
      final trackPoints = await MockTestHelpers.getTrackPoints();
      expect(trackPoints.length >= switchCount, true,
        reason: '轨迹点不足，可能存在定位丢失');
    }, timeout: const Timeout(Duration(minutes: 5)));
    
    testWidgets('锁屏保活测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 初始化性能采集
      final perfCollector = PerformanceCollector(interval: const Duration(seconds: 30));
      await perfCollector.start();
      
      // 锁屏
      await MockTestHelpers.lockScreen();
      print('🔒 屏幕已锁定');
      
      // 等待5分钟
      await Future.delayed(const Duration(minutes: 5));
      
      // 解锁
      await MockTestHelpers.unlockScreen();
      await tester.pumpAndSettle();
      print('🔓 屏幕已解锁');
      
      await perfCollector.stop();
      
      // 验证导航状态
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      
      // 获取轨迹数据
      final trackPoints = await MockTestHelpers.getTrackPoints();
      final gaps = MockTestHelpers.findTrackGaps(trackPoints, thresholdSeconds: 30);
      
      print('📊 锁屏保活测试完成 - 轨迹点数: ${trackPoints.length}, 断点数: ${gaps.length}');
      
      expect(gaps.isEmpty, true, reason: '锁屏期间出现轨迹断点');
      
      print('✅ 锁屏保活测试通过');
    }, timeout: const Timeout(Duration(minutes: 10)));
    
    testWidgets('后台保活内存测试', (tester) async {
      final memoryMonitor = MemoryMonitor();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航并采集初始内存
      await MockTestHelpers.startNavigation(tester);
      final initialSnapshot = await memoryMonitor.takeSnapshot();
      print('🧠 初始内存: ${initialSnapshot.memoryMB}MB');
      
      // 切换到后台5分钟
      await PerformanceCollector.simulateBackgroundSwitch();
      print('📱 切换到后台');
      
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed.inMinutes < 5) {
        await Future.delayed(const Duration(minutes: 1));
        await memoryMonitor.takeSnapshot();
        print('🧠 [${stopwatch.elapsed.inMinutes}分钟] 内存: ${memoryMonitor.snapshots.last.memoryMB}MB');
      }
      
      // 返回前台
      await PerformanceCollector.simulateForegroundReturn();
      await tester.pumpAndSettle();
      
      final finalSnapshot = await memoryMonitor.takeSnapshot();
      print('🧠 返回前台后内存: ${finalSnapshot.memoryMB}MB');
      
      // 分析内存变化
      final trend = memoryMonitor.getTrend();
      final growth = finalSnapshot.memoryMB - initialSnapshot.memoryMB;
      
      print('\n📊 后台内存报告:');
      print('  - 趋势: $trend');
      print('  - 增长: ${growth}MB');
      
      // 后台内存应该保持稳定或有所下降
      expect(growth, lessThan(50), 
        reason: '后台内存增长超过50MB: ${growth}MB');
      
      print('✅ 后台保活内存测试通过');
    }, timeout: const Timeout(Duration(minutes: 10)));
  });
}
