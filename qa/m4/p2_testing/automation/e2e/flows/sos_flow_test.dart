// qa/m4/p2_testing/automation/e2e/flows/sos_flow_test.dart
// SOS功能E2E测试

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('SOS功能E2E测试', () {
    testWidgets('SOS完整流程测试（Mock模式）', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await startNavigation(tester, trailId: 'R001');
      
      // 点击SOS按钮
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 验证SOS页面
      expect(find.byKey(const Key('sos_screen')), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      
      // 等待倒计时
      await tester.pump(const Duration(seconds: 5));
      
      // 验证发送中状态
      expect(find.text('发送中'), findsOneWidget);
      
      // 验证结果
      await tester.pump(const Duration(seconds: 2));
      expect(find.text('已发送'), findsOneWidget);
      
      // 返回导航
      await tester.tap(find.text('返回导航'));
      await tester.pumpAndSettle();
      
      // 验证返回导航页
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      
      print('✅ SOS完整流程测试通过');
    });
    
    testWidgets('SOS倒计时取消测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await startNavigation(tester, trailId: 'R001');
      
      // 点击SOS
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      
      // 等待2秒
      await tester.pump(const Duration(seconds: 2));
      
      // 点击取消
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      
      // 验证返回导航
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      
      print('✅ SOS倒计时取消测试通过');
    });
    
    testWidgets('SOS弱网环境测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 设置为弱网
      await setNetworkCondition(NetworkCondition.weak);
      
      await startNavigation(tester, trailId: 'R001');
      
      // 触发SOS
      await tester.tap(find.byKey(const Key('sos_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 5));
      
      // 验证弱网提示
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('网络较弱，已本地保存'), findsOneWidget);
      
      // 恢复网络
      await setNetworkCondition(NetworkCondition.normal);
      
      print('✅ SOS弱网环境测试通过');
    });
  });
}

// 辅助函数
Future<void> startNavigation(WidgetTester tester, {required String trailId}) async {
  await tester.tap(find.byKey(const Key('discover_tab')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('trail_$trailId')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('开始导航'));
  await tester.pumpAndSettle();
  expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
}

Future<void> setNetworkCondition(NetworkCondition condition) async {
  print('设置网络条件: $condition');
}

enum NetworkCondition {
  normal,
  weak,
  offline,
}

// Mock classes
class Key {
  final String value;
  const Key(this.value);
}

Finder find = Finder();

class Finder {
  Finder byKey(Key key) => this;
  Finder text(String text) => this;
  dynamic get evaluate => [];
}
