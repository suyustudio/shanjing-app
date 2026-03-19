// qa/m4/p2_testing/performance/long_navigation_test.dart
// 长时间导航稳定性测试 - 60分钟

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

// 导入共享工具
import '../utils/performance_collector.dart';
import '../utils/test_mocks.dart' show MockLatLng, MockTestHelpers;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('长时间导航稳定性测试 (60分钟)', () {
    testWidgets('60分钟连续导航无崩溃测试', (tester) async {
      // 启动APP
      app.main();
      await tester.pumpAndSettle();
      
      // 进入发现页并选择路线
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      // 点击第一条路线
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      // 开始导航
      await tester.tap(find.textContaining('导航'));
      await tester.pumpAndSettle();
      
      // 验证导航页显示
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      
      // 初始化性能采集器
      final perfCollector = PerformanceCollector(
        interval: const Duration(seconds: 10),
        thresholds: const PerformanceThresholds(
          maxMemoryMB: 500,
          minBatteryPercent: 10,
          minFPS: 20,
          maxLocationAccuracy: 100,
        ),
        onDataPoint: (data) {
          if (data.elapsedSeconds % 60 == 0) { // 每分钟输出一次
            print('📊 [${data.elapsedSeconds ~/ 60}分钟] '
                  '内存: ${data.memoryMB}MB, '
                  '电量: ${data.batteryPercent}%, '
                  'CPU: ${data.cpuPercent?.toStringAsFixed(1)}%, '
                  'FPS: ${data.fps?.toStringAsFixed(1)}');
          }
        },
      );
      
      // 开始性能采集
      await perfCollector.start(outputPath: 'test-results/long_navigation_60min.json');
      
      // 记录测试状态
      int crashCount = 0;
      int locationLostCount = 0;
      final stopwatch = Stopwatch()..start();
      
      print('🚀 60分钟导航测试开始 - 初始内存: ${await PerformanceCollector.getMemoryUsageMB()}MB');
      
      // 60分钟持续测试
      while (stopwatch.elapsed.inMinutes < 60) {
        final elapsedMinutes = stopwatch.elapsed.inMinutes;
        
        try {
          // 每10分钟模拟用户操作（后台切换）
          if (stopwatch.elapsed.inMinutes % 10 == 0 && stopwatch.elapsed.inMinutes > 0) {
            print('🔄 [${elapsedMinutes}分钟] 模拟后台切换...');
            await PerformanceCollector.simulateBackgroundSwitch();
            await tester.pump(const Duration(seconds: 5));
            await PerformanceCollector.simulateForegroundReturn();
            await tester.pumpAndSettle();
            print('✅ [${elapsedMinutes}分钟] 后台切换完成');
          }
          
          // 每30秒模拟位置更新
          if (stopwatch.elapsed.inSeconds % 30 == 0) {
            final position = MockTestHelpers.simulateMovement(
              const MockLatLng(30.2596, 120.1479),
              stopwatch.elapsed,
            );
            await MockTestHelpers.mockLocationUpdate(position);
          }
          
          // 每秒pump一次保持活跃
          await tester.pump(const Duration(seconds: 1));
          
        } catch (e) {
          crashCount++;
          print('❌ 异常捕获: $e');
          
          // 尝试恢复
          try {
            await tester.pumpAndSettle();
            if (find.byKey(const Key('navigation_screen')).evaluate().isEmpty) {
              print('⚠️ 导航页面丢失，尝试恢复...');
              locationLostCount++;
            }
          } catch (recoveryError) {
            print('❌ 恢复失败: $recoveryError');
          }
        }
      }
      
      stopwatch.stop();
      await perfCollector.stop();
      
      // 生成测试报告
      final report = perfCollector.generateReport();
      
      // 测试结束，输出报告
      print('\n========== 📊 60分钟导航测试报告 ==========');
      print('⏱️  总运行时间: ${stopwatch.elapsed.inMinutes}分钟');
      print('💥 崩溃次数: $crashCount');
      print('📍 定位丢失次数: $locationLostCount');
      print('');
      
      // 内存分析
      final memoryData = report['memory'] as Map<String, dynamic>?;
      if (memoryData != null) {
        print('🧠 内存分析:');
        print('  - 初始内存: ${memoryData['initial_mb']}MB');
        print('  - 最终内存: ${memoryData['final_mb']}MB');
        print('  - 内存增长: ${memoryData['growth_mb']}MB');
        print('  - 最大内存: ${memoryData['max_mb']}MB');
        print('  - 平均内存: ${(memoryData['avg_mb'] as double).toStringAsFixed(1)}MB');
      }
      
      // 电量分析
      final batteryData = report['battery'] as Map<String, dynamic>?;
      if (batteryData != null) {
        print('');
        print('🔋 电量分析:');
        print('  - 初始电量: ${batteryData['initial_percent']}%');
        print('  - 最终电量: ${batteryData['final_percent']}%');
        print('  - 电量消耗: ${batteryData['consumption_percent']}%');
        print('  - 每小时消耗: ${batteryData['hourly_consumption_percent']}%');
      }
      
      // CPU分析
      final cpuData = report['cpu'] as Map<String, dynamic>?;
      if (cpuData != null) {
        print('');
        print('💻 CPU分析:');
        print('  - 平均CPU: ${(cpuData['avg_percent'] as double).toStringAsFixed(1)}%');
        print('  - 最大CPU: ${cpuData['max_percent']}%');
      }
      
      // FPS分析
      final fpsData = report['fps'] as Map<String, dynamic>?;
      if (fpsData != null) {
        print('');
        print('🎮 FPS分析:');
        print('  - 平均FPS: ${(fpsData['avg'] as double).toStringAsFixed(1)}');
        print('  - 最低FPS: ${fpsData['min']}');
        print('  - 最高FPS: ${fpsData['max']}');
      }
      
      // 阈值违规统计
      final violations = report['threshold_violations'] as Map<String, dynamic>?;
      if (violations != null && violations.values.any((v) => v > 0)) {
        print('');
        print('⚠️  阈值告警:');
        if (violations['memory'] > 0) print('  - 内存告警: ${violations['memory']}次');
        if (violations['battery'] > 0) print('  - 电量告警: ${violations['battery']}次');
        if (violations['fps'] > 0) print('  - FPS告警: ${violations['fps']}次');
        if (violations['location_accuracy'] > 0) print('  - 定位精度告警: ${violations['location_accuracy']}次');
      }
      
      print('\n========================================');
      
      // 断言验证
      expect(crashCount, 0, reason: '测试期间发生$crashCount次崩溃');
      expect(locationLostCount, lessThanOrEqualTo(2), 
        reason: '定位丢失$locationLostCount次（超过2次）');
      
      final memoryGrowth = memoryData?['growth_mb'] as int? ?? 0;
      expect(memoryGrowth, lessThan(100), 
        reason: '内存增长超过100MB: ${memoryGrowth}MB');
      
      final hourlyConsumption = double.tryParse(batteryData?['hourly_consumption_percent']?.toString() ?? '0') ?? 0;
      expect(hourlyConsumption, lessThan(15.0), 
        reason: '每小时电量消耗超过15%: ${hourlyConsumption.toStringAsFixed(1)}%');
      
      print('✅ 60分钟导航测试通过！');
      
    }, timeout: const Timeout(Duration(minutes: 65)));
    
    testWidgets('30分钟导航内存泄漏检测', (tester) async {
      final memoryMonitor = MemoryMonitor();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 初始内存快照
      final initialSnapshot = await memoryMonitor.takeSnapshot();
      print('🧠 初始内存: ${initialSnapshot.memoryMB}MB');
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 30分钟测试
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed.inMinutes < 30) {
        await tester.pump(const Duration(seconds: 5));
        
        // 每分钟采集一次内存
        if (stopwatch.elapsed.inSeconds % 60 == 0) {
          final snapshot = await memoryMonitor.takeSnapshot();
          print('🧠 [${stopwatch.elapsed.inMinutes}分钟] 内存: ${snapshot.memoryMB}MB');
        }
      }
      stopwatch.stop();
      
      // 分析内存趋势
      final trend = memoryMonitor.getTrend();
      print('\n📊 内存趋势: $trend');
      
      final snapshots = memoryMonitor.snapshots;
      if (snapshots.length >= 2) {
        final initial = snapshots.first.memoryMB;
        final final_ = snapshots.last.memoryMB;
        final growth = final_ - initial;
        
        print('内存增长: ${growth}MB (${growth > 0 ? '⚠️' : '✅'})');
        
        // 持续增长超过50MB认为有内存泄漏
        if (trend == MemoryTrend.increasing && growth > 50) {
          print('⚠️ 警告: 检测到可能的内存泄漏');
        }
        
        expect(growth, lessThan(80), 
          reason: '30分钟内存增长超过80MB，可能存在内存泄漏');
      }
      
      print('✅ 内存泄漏检测通过');
    }, timeout: const Timeout(Duration(minutes: 35)));
    
    testWidgets('导航电量消耗测试', (tester) async {
      final batteryMonitor = BatteryMonitor();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 开始监控电量
      await batteryMonitor.start();
      print('🔋 初始电量: ${batteryMonitor.getTotalConsumption()}%');
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 20分钟测试
      final stopwatch = Stopwatch()..start();
      while (stopwatch.elapsed.inMinutes < 20) {
        await tester.pump(const Duration(seconds: 5));
        
        // 每分钟采集一次电量
        if (stopwatch.elapsed.inSeconds % 60 == 0) {
          await batteryMonitor.takeSnapshot();
          print('🔋 [${stopwatch.elapsed.inMinutes}分钟] 消耗: ${batteryMonitor.getTotalConsumption()}%');
        }
      }
      stopwatch.stop();
      
      final totalConsumption = batteryMonitor.getTotalConsumption();
      final hourlyConsumption = batteryMonitor.getHourlyConsumption();
      
      print('\n📊 电量消耗报告:');
      print('  - 总消耗: ${totalConsumption}%');
      print('  - 每小时消耗: ${hourlyConsumption.toStringAsFixed(1)}%');
      
      // 电量消耗断言
      expect(hourlyConsumption, lessThan(20.0), 
        reason: '每小时电量消耗过高: ${hourlyConsumption.toStringAsFixed(1)}%');
      
      print('✅ 电量消耗测试通过');
    }, timeout: const Timeout(Duration(minutes: 25)));
  });
}
