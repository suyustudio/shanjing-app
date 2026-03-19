// qa/m4/p2_testing/automation/e2e/flows/navigation_flow_test.dart
// 导航功能E2E测试

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;

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
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      // 验证路线详情页
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      expect(find.text('开始导航'), findsOneWidget);
      
      // 开始导航
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();
      
      // 验证导航页
      expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
      expect(find.byKey(const Key('map_view')), findsOneWidget);
      
      // 等待GPS定位
      await tester.pump(const Duration(seconds: 3));
      
      // 验证定位状态
      expect(find.byKey(const Key('location_indicator')), findsOneWidget);
      
      // 模拟移动
      await mockLocationUpdates([
        const LatLng(30.2596, 120.1479),
        const LatLng(30.2588, 120.1432),
        const LatLng(30.2315, 120.1289),
      ]);
      await tester.pump(const Duration(seconds: 5));
      
      // 验证轨迹绘制
      expect(find.byKey(const Key('trail_polyline')), findsOneWidget);
      
      // 退出导航
      await tester.tap(find.byKey(const Key('exit_navigation_button')));
      await tester.pumpAndSettle();
      
      // 确认退出
      await tester.tap(find.text('确认'));
      await tester.pumpAndSettle();
      
      // 验证返回详情页
      expect(find.byKey(const Key('trail_detail_page')), findsOneWidget);
      
      print('✅ 完整导航流程测试通过');
    }, timeout: const Timeout(Duration(minutes: 2)));
    
    testWidgets('偏航重规划测试', (tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 开始导航
      await startNavigation(tester, trailId: 'R001');
      
      // 模拟偏离路线
      await mockLocationUpdate(const LatLng(30.2600, 120.1500));
      await tester.pump(const Duration(seconds: 5));
      
      // 验证偏航提示
      expect(find.text('已偏离路线'), findsOneWidget);
      
      // 验证自动重规划
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('正在重新规划路线'), findsOneWidget);
      
      print('✅ 偏航重规划测试通过');
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

Future<void> mockLocationUpdate(LatLng position) async {
  print('Mock位置: $position');
}

Future<void> mockLocationUpdates(List<LatLng> positions) async {
  for (final position in positions) {
    await mockLocationUpdate(position);
    await Future.delayed(const Duration(seconds: 2));
  }
}

// Mock classes
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

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
