// M5 - 新手引导自动化测试套件
// 测试范围: TC-OB-001 ~ TC-OB-020

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing_app/main.dart' as app;
import '../utils/test_helpers.dart';
import '../utils/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('新手引导测试套件', () {
    
    // TC-OB-001: 首次启动显示引导
    testWidgets('首次启动显示欢迎页', (WidgetTester tester) async {
      // 清除本地数据模拟首次启动
      await TestHelpers.clearAppData();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 验证欢迎页显示
      expect(find.text('发现城市中的自然'), findsOneWidget);
      expect(find.text('开始探索'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget); // Logo
    });

    // TC-OB-002: 升级安装不显示引导
    testWidgets('非首次启动直接进入首页', (WidgetTester tester) async {
      // 设置已引导完成标志
      await TestHelpers.setOnboardingCompleted();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 验证直接进入首页
      expect(find.text('发现'), findsOneWidget);
      expect(find.text('附近路线'), findsWidgets);
    });

    // TC-OB-005: 权限允许流程
    testWidgets('权限申请流程', (WidgetTester tester) async {
      await TestHelpers.clearAppData();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 点击开始探索
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle();
      
      // 验证权限说明页
      expect(find.text('位置权限'), findsOneWidget);
      expect(find.text('用于导航和记录您的徒步路线'), findsOneWidget);
      expect(find.text('允许'), findsOneWidget);
      expect(find.text('稍后'), findsOneWidget);
    });

    // TC-OB-008: 跳过功能
    testWidgets('引导跳过功能', (WidgetTester tester) async {
      await TestHelpers.clearAppData();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 点击开始探索
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle();
      
      // 点击跳过
      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();
      
      // 验证进入首页
      expect(find.text('发现'), findsOneWidget);
      
      // 验证引导完成状态已保存
      final isCompleted = await TestHelpers.isOnboardingCompleted();
      expect(isCompleted, true);
    });

    // TC-OB-009: 场景化引导高亮
    testWidgets('首页高亮引导', (WidgetTester tester) async {
      await TestHelpers.clearAppData();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 完整走一遍引导
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle();
      
      // 允许权限
      await tester.tap(find.text('允许'));
      await tester.pumpAndSettle();
      
      // 滑动功能介绍
      for (int i = 0; i < 3; i++) {
        await tester.fling(find.byType(PageView), const Offset(-300, 0), 300);
        await tester.pumpAndSettle();
      }
      
      // 点击进入
      await tester.tap(find.text('进入山径'));
      await tester.pumpAndSettle();
      
      // 验证高亮遮罩显示
      expect(find.byType(SpotlightOverlay), findsOneWidget);
      expect(find.text('点击这里发现附近路线'), findsOneWidget);
    });

    // TC-OB-010: 引导完成状态持久化
    testWidgets('引导完成状态持久化', (WidgetTester tester) async {
      await TestHelpers.clearAppData();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 快速跳过引导
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();
      
      // 重启APP
      await TestHelpers.restartApp(tester);
      
      // 验证不再显示引导
      expect(find.text('发现'), findsOneWidget);
      expect(find.text('发现城市中的自然'), findsNothing);
    });

    // TC-OB-011: 引导重置功能
    testWidgets('引导重置功能', (WidgetTester tester) async {
      await TestHelpers.setOnboardingCompleted();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 进入设置页
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      
      // 找到重新显示引导选项
      await tester.tap(find.text('重新显示引导'));
      await tester.pumpAndSettle();
      
      // 确认重置
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      
      // 重启APP
      await TestHelpers.restartApp(tester);
      
      // 验证引导重新显示
      expect(find.text('发现城市中的自然'), findsOneWidget);
    });

    // TC-OB-017: 低内存设备引导
    testWidgets('低内存设备引导性能', (WidgetTester tester) async {
      await TestHelpers.clearAppData();
      await TestHelpers.simulateLowMemory();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 记录启动时间
      final stopwatch = Stopwatch()..start();
      
      // 完成引导流程
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('跳过'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证完成时间
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    }, timeout: const Timeout(Duration(minutes: 2)));

    // TC-OB-019: 埋点完整性测试
    testWidgets('引导埋点事件上报', (WidgetTester tester) async {
      await TestHelpers.clearAppData();
      await TestHelpers.clearAnalyticsEvents();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 验证onboarding_start上报
      final events = await TestHelpers.getAnalyticsEvents();
      expect(events, contains('onboarding_start'));
      
      // 点击开始探索
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle();
      
      // 验证step_view上报
      await tester.pump(Duration(seconds: 1));
      final updatedEvents = await TestHelpers.getAnalyticsEvents();
      expect(updatedEvents, contains('onboarding_step_view'));
    });
  });
}
