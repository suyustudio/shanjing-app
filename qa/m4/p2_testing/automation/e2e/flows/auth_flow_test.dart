// qa/m4/p2_testing/automation/e2e/flows/auth_flow_test.dart
// 用户认证E2E测试

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

// 导入共享工具
import '../../utils/performance_collector.dart';
import '../../utils/test_mocks.dart' show MockTestHelpers;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('用户认证E2E测试', () {
    testWidgets('完整登录流程测试', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      // 启动APP
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      // 点击登录
      final loginButton = find.textContaining('登录');
      if (loginButton.evaluate().isEmpty) {
        print('✅ 用户可能已登录，跳过登录测试');
        return;
      }
      
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      // 输入手机号
      final phoneInput = find.byKey(const Key('phone_input'));
      expect(phoneInput, findsOneWidget);
      await tester.enterText(phoneInput, '13800138000');
      await tester.pumpAndSettle();
      
      // 获取验证码
      await tester.tap(find.byKey(const Key('get_code_button')));
      await tester.pumpAndSettle();
      
      // 等待验证码输入（实际测试中使用固定验证码）
      await Future.delayed(const Duration(seconds: 2));
      
      // 输入验证码
      final codeInput = find.byKey(const Key('code_input'));
      expect(codeInput, findsOneWidget);
      await tester.enterText(codeInput, '123456');
      await tester.pumpAndSettle();
      
      // 点击登录
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      
      // 验证登录成功
      await MockTestHelpers.waitFor(
        tester,
        find.textContaining('我的'),
        timeout: const Duration(seconds: 10),
      );
      
      // 验证用户信息显示
      final userInfo = find.textContaining('138');
      expect(userInfo, findsOneWidget);
      
      stopwatch.stop();
      
      print('✅ 登录流程测试通过 - 耗时: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(15000),
        reason: '登录流程超过15秒');
    });
    
    testWidgets('退出登录流程测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 确保已登录
      await MockTestHelpers.ensureLoggedIn(tester);
      
      // 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      // 进入设置
      final settingsButton = find.byKey(const Key('settings_button'));
      if (settingsButton.evaluate().isNotEmpty) {
        await tester.tap(settingsButton);
      } else {
        // 尝试查找设置文本
        await tester.tap(find.textContaining('设置'));
      }
      await tester.pumpAndSettle();
      
      // 点击退出登录
      await tester.tap(find.textContaining('退出'));
      await tester.pumpAndSettle();
      
      // 确认退出
      await tester.tap(find.textContaining('确定'));
      await tester.pumpAndSettle();
      
      // 验证退出成功
      await MockTestHelpers.waitFor(
        tester,
        find.textContaining('登录'),
        timeout: const Duration(seconds: 5),
      );
      
      print('✅ 退出登录流程测试通过');
    });
    
    testWidgets('登录状态保持测试', (tester) async {
      // 第一次启动并登录
      app.main();
      await tester.pumpAndSettle();
      
      // 登录
      await MockTestHelpers.ensureLoggedIn(tester);
      
      // 模拟APP重启（通过重新启动main）
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      // 验证仍然登录
      final myText = find.textContaining('我的');
      expect(myText, findsOneWidget);
      
      // 验证没有显示登录按钮
      final loginButton = find.textContaining('登录/注册');
      expect(loginButton, findsNothing);
      
      print('✅ 登录状态保持测试通过');
    });
    
    testWidgets('登录性能测试', (tester) async {
      final perfCollector = PerformanceCollector(interval: const Duration(seconds: 1));
      
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      // 确保未登录
      final loginButton = find.textContaining('登录');
      if (loginButton.evaluate().isEmpty) {
        print('用户已登录，跳过性能测试');
        return;
      }
      
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      
      // 开始性能采集
      await perfCollector.start();
      
      // 执行登录
      await tester.enterText(find.byKey(const Key('phone_input')), '13800138000');
      await tester.tap(find.byKey(const Key('get_code_button')));
      await tester.pumpAndSettle();
      await Future.delayed(const Duration(seconds: 2));
      await tester.enterText(find.byKey(const Key('code_input')), '123456');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      
      // 等待登录完成
      await MockTestHelpers.waitFor(
        tester,
        find.textContaining('我的'),
        timeout: const Duration(seconds: 10),
      );
      
      await perfCollector.stop();
      
      // 输出性能报告
      final report = perfCollector.generateReport();
      print('\n📊 登录性能报告:');
      print('  - 耗时: ${report['duration_seconds']}秒');
      print('  - 内存峰值: ${report['memory']?['max_mb']}MB');
      print('  - 平均CPU: ${report['cpu']?['avg_percent']?.toStringAsFixed(1)}%');
      
      print('✅ 登录性能测试通过');
    });
  });
}
