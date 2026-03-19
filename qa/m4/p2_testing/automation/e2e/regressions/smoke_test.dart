// qa/m4/p2_testing/automation/e2e/regressions/smoke_test.dart
// 烟雾测试 - 快速验证核心流程

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('烟雾测试 - 核心流程快速验证', () {
    testWidgets('APP启动测试', (tester) async {
      final stopwatch = Stopwatch()..start();
      
      app.main();
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证首页加载
      expect(find.byKey(const Key('home_page')), findsOneWidget);
      
      print('APP启动时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(3000),
        reason: 'APP启动时间超过3秒');
    });
    
    testWidgets('发现页加载测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证路线列表加载
      expect(find.byType(TrailCard), findsWidgets);
      
      print('发现页加载时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
        reason: '发现页加载时间超过2秒');
    });
    
    testWidgets('路线详情页加载测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证详情页加载
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      expect(find.text('开始导航'), findsOneWidget);
      
      print('路线详情页加载时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
        reason: '路线详情页加载时间超过2秒');
    });
    
    testWidgets('导航页启动测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证导航页加载
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      
      print('导航页启动时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(2000),
        reason: '导航页启动时间超过2秒');
      
      // 退出导航
      await tester.tap(find.byKey(const Key('exit_navigation')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
    });
    
    testWidgets('个人中心加载测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      
      stopwatch.stop();
      
      // 验证个人中心加载
      expect(find.text('我的'), findsOneWidget);
      
      print('个人中心加载时间: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1500),
        reason: '个人中心加载时间超过1.5秒');
    });
    
    testWidgets('全量烟雾测试', (tester) async {
      final totalStopwatch = Stopwatch()..start();
      
      // 1. 启动APP
      app.main();
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('home_page')), findsOneWidget);
      
      // 2. 进入发现页
      await tester.tap(find.byKey(const Key('discover_tab')));
      await tester.pumpAndSettle();
      expect(find.byType(TrailCard), findsWidgets);
      
      // 3. 进入路线详情
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      
      // 4. 返回发现页
      await tester.tap(find.byKey(const Key('back_button')));
      await tester.pumpAndSettle();
      
      // 5. 进入个人中心
      await tester.tap(find.byKey(const Key('profile_tab')));
      await tester.pumpAndSettle();
      expect(find.text('我的'), findsOneWidget);
      
      totalStopwatch.stop();
      
      print('全量烟雾测试完成，总耗时: ${totalStopwatch.elapsedMilliseconds}ms');
      expect(totalStopwatch.elapsedMilliseconds, lessThan(10000),
        reason: '全量烟雾测试超过10秒');
    }, timeout: const Timeout(Duration(minutes: 2)));
  });
}

// Mock classes
class TrailCard {
  const TrailCard();
}

class Key {
  final String value;
  const Key(this.value);
}

Finder find = Finder();

class Finder {
  Finder byKey(Key key) => this;
  Finder byType(Type type) => this;
  Finder text(String text) => this;
  Finder get first => this;
  dynamic get evaluate => [];
}
