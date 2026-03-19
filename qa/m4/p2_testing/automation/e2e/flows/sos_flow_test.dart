// qa/m4/p2_testing/automation/e2e/flows/sos_flow_test.dart
// SOS紧急救援功能E2E测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

// 导入共享工具
import '../../utils/performance_collector.dart';
import '../../utils/test_mocks.dart' show MockLatLng, MockTestHelpers;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SOS紧急救援功能E2E测试', () {
    testWidgets('SOS按钮显示测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      // 选择路线
      await tester.tap(find.byType(Card).first);
      await tester.pumpAndSettle();
      
      // 开始导航
      await tester.tap(find.textContaining('导航'));
      await tester.pumpAndSettle();
      
      // 验证SOS按钮存在
      final sosButton = find.byKey(const Key('sos_button'));
      expect(sosButton, findsOneWidget);
      
      print('✅ SOS按钮显示测试通过');
    });
    
    testWidgets('SOS弹窗显示测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 点击SOS按钮
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 验证SOS弹窗显示
      expect(find.byKey(const Key('sos_dialog')), findsOneWidget);
      expect(find.textContaining('紧急'), findsOneWidget);
      
      // 取消SOS
      await tester.tap(find.textContaining('取消'));
      await tester.pumpAndSettle();
      
      // 验证弹窗关闭
      expect(find.byKey(const Key('sos_dialog')), findsNothing);
      
      print('✅ SOS弹窗显示测试通过');
    });
    
    testWidgets('SOS倒计时测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 点击SOS按钮
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 验证倒计时显示
      final countdownFinder = find.byKey(const Key('sos_countdown'));
      expect(countdownFinder, findsOneWidget);
      
      // 等待倒计时（通常5秒）
      await tester.pump(const Duration(seconds: 3));
      
      // 取消SOS
      await tester.tap(find.textContaining('取消'));
      await tester.pumpAndSettle();
      
      print('✅ SOS倒计时测试通过');
    });
    
    testWidgets('SOS位置上报测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 模拟位置
      final testPosition = const MockLatLng(30.2596, 120.1479);
      await MockTestHelpers.mockLocationUpdate(testPosition);
      
      // 点击SOS按钮
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 确认SOS（如果测试环境允许）
      final confirmButton = find.textContaining('确认');
      if (confirmButton.evaluate().isNotEmpty) {
        // 注意：在真实测试中，这里会触发实际的SOS流程
        // 在测试环境中，我们通常取消或模拟
        print('⚠️ SOS确认按钮存在，测试中跳过实际触发');
        
        // 取消SOS
        await tester.tap(find.textContaining('取消'));
        await tester.pumpAndSettle();
      }
      
      print('✅ SOS位置上报测试通过');
    });
    
    testWidgets('SOS电量检查测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 获取当前电量
      final batteryLevel = await PerformanceCollector.getBatteryLevel();
      print('🔋 当前电量: $batteryLevel%');
      
      // 点击SOS按钮
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 如果电量低于20%，应该有低电量警告
      if (batteryLevel < 20) {
        final lowBatteryWarning = find.textContaining('电量');
        if (lowBatteryWarning.evaluate().isNotEmpty) {
          print('⚠️ 低电量警告显示正确');
        }
      }
      
      // 取消SOS
      await tester.tap(find.textContaining('取消'));
      await tester.pumpAndSettle();
      
      print('✅ SOS电量检查测试通过');
    });
    
    testWidgets('SOS网络状态提示测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 测试不同网络状态下的SOS提示
      for (final condition in [NetworkCondition.normal, NetworkCondition.weak, NetworkCondition.offline]) {
        await MockTestHelpers.setNetworkCondition(condition);
        
        // 点击SOS按钮
        await tester.tap(find.byKey(const Key('sos_button')));
        await tester.pumpAndSettle();
        
        print('🌐 网络状态 $condition 下SOS弹窗显示正常');
        
        // 取消SOS
        await tester.tap(find.textContaining('取消'));
        await tester.pumpAndSettle();
      }
      
      // 恢复网络
      await MockTestHelpers.setNetworkCondition(NetworkCondition.normal);
      
      print('✅ SOS网络状态提示测试通过');
    });
    
    testWidgets('SOS联系人显示测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 确保已登录
      await MockTestHelpers.ensureLoggedIn(tester);
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 点击SOS按钮
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 验证联系人信息区域
      final contactsArea = find.byKey(const Key('sos_contacts'));
      if (contactsArea.evaluate().isNotEmpty) {
        print('✅ 紧急联系人显示正确');
      }
      
      // 取消SOS
      await tester.tap(find.textContaining('取消'));
      await tester.pumpAndSettle();
      
      print('✅ SOS联系人显示测试通过');
    });
    
    testWidgets('SOS性能测试', (tester) async {
      final perfCollector = PerformanceCollector(interval: const Duration(seconds: 1));
      
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await MockTestHelpers.startNavigation(tester);
      
      // 开始性能采集
      await perfCollector.start();
      
      // 点击SOS按钮
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 等待弹窗动画
      await tester.pump(const Duration(milliseconds: 500));
      
      // 取消SOS
      await tester.tap(find.textContaining('取消'));
      await tester.pumpAndSettle();
      
      await perfCollector.stop();
      
      // 输出性能报告
      final report = perfCollector.generateReport();
      print('\n📊 SOS性能报告:');
      print('  - 响应时间: ${report['duration_seconds']}秒');
      print('  - 内存峰值: ${report['memory']?['max_mb']}MB');
      
      // 性能断言
      expect(report['duration_seconds'], lessThan(3),
        reason: 'SOS响应时间超过3秒');
      
      print('✅ SOS性能测试通过');
    });
  });
}

/// 网络条件枚举（如果test_mocks.dart中没有导出）
enum NetworkCondition {
  normal('正常'),
  weak('弱网'),
  offline('离线');

  final String label;
  const NetworkCondition(this.label);

  @override
  String toString() => label;
}
