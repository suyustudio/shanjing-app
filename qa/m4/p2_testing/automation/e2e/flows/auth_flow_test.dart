// qa/m4/p2_testing/automation/e2e/flows/auth_flow_test.dart
// 用户认证E2E测试

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('用户认证E2E测试', () {
    testWidgets('完整登录流程测试', (tester) async {
      // 启动APP
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      // 点击登录
      await tester.tap(find.text('登录/注册'));
      await tester.pumpAndSettle();
      
      // 输入手机号
      await tester.enterText(
        find.byKey(const Key('phone_input')), 
        '13800138000'
      );
      await tester.pumpAndSettle();
      
      // 获取验证码
      await tester.tap(find.byKey(const Key('get_code_button')));
      await tester.pumpAndSettle();
      
      // 输入验证码
      await tester.enterText(
        find.byKey(const Key('code_input')), 
        '123456'
      );
      await tester.pumpAndSettle();
      
      // 点击登录
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      
      // 验证登录成功
      await waitFor(find.text('我的'), timeout: const Duration(seconds: 5));
      expect(find.text('138****8000'), findsOneWidget);
      
      print('✅ 登录流程测试通过');
    });
    
    testWidgets('退出登录流程测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 确保已登录（如果需要先登录）
      await ensureLoggedIn(tester);
      
      // 进入设置
      await tester.tap(find.byKey(const Key('settings_button')));
      await tester.pumpAndSettle();
      
      // 点击退出登录
      await tester.tap(find.text('退出登录'));
      await tester.pumpAndSettle();
      
      // 确认退出
      await tester.tap(find.text('确定'));
      await tester.pumpAndSettle();
      
      // 验证退出成功
      expect(find.text('登录/注册'), findsOneWidget);
      
      print('✅ 退出登录流程测试通过');
    });
  });
}

// 辅助函数
Future<void> waitFor(
  Finder finder, {
  required Duration timeout,
}) async {
  final endTime = DateTime.now().add(timeout);
  
  while (DateTime.now().isBefore(endTime)) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await Future.delayed(const Duration(milliseconds: 100));
  }
  
  throw Exception('等待元素超时: $finder');
}

Future<void> ensureLoggedIn(WidgetTester tester) async {
  try {
    if (find.text('登录/注册').evaluate().isNotEmpty) {
      await tester.tap(find.text('登录/注册'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('phone_input')), '13800138000');
      await tester.enterText(find.byKey(const Key('code_input')), '123456');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await waitFor(find.text('我的'), timeout: const Duration(seconds: 5));
    }
  } catch (e) {
    print('登录检查/执行失败: $e');
  }
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
