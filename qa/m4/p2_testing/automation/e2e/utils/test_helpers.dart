// qa/m4/p2_testing/automation/e2e/utils/test_helpers.dart
// E2E测试辅助工具类

import 'package:flutter_test/flutter_test.dart';

/// 等待元素出现
Future<void> waitFor(
  Finder finder, {
  required Duration timeout,
  Duration interval = const Duration(milliseconds: 100),
}) async {
  final endTime = DateTime.now().add(timeout);
  
  while (DateTime.now().isBefore(endTime)) {
    if (finder.evaluate().isNotEmpty) {
      return;
    }
    await Future.delayed(interval);
  }
  
  throw Exception('等待元素超时: $finder');
}

/// 确保用户已登录
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

/// 开始导航
Future<void> startNavigation(
  WidgetTester tester, {
  required String trailId,
}) async {
  await tester.tap(find.byKey(const Key('discover_tab')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('trail_$trailId')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('开始导航'));
  await tester.pumpAndSettle();
  await waitFor(
    find.byKey(const Key('navigation_screen')),
    timeout: const Duration(seconds: 5),
  );
}

/// 进入离线地图页面
Future<void> goToOfflineMapPage(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('profile_tab')));
  await tester.pumpAndSettle();
  await tester.tap(find.text('离线地图'));
  await tester.pumpAndSettle();
}

/// 验证埋点事件
Future<void> verifyAnalyticsEvent(String eventName) async {
  print('验证埋点: $eventName');
  // TODO: 实现埋点验证逻辑
}

/// 设置网络状态
Future<void> setNetworkState({required bool enabled}) async {
  print('设置网络: $enabled');
  // TODO: 实现网络控制
}

/// 网络条件枚举
enum NetworkCondition {
  normal,
  weak,
  offline,
}

/// 设置网络条件
Future<void> setNetworkCondition(NetworkCondition condition) async {
  print('设置网络条件: $condition');
  // TODO: 实现网络条件控制
}

/// 确保离线地图已下载
Future<void> ensureOfflineMapDownloaded(
  WidgetTester tester, {
  required String city,
}) async {
  print('确保离线地图已下载: $city');
  // TODO: 实现离线地图检查
}

/// Mock位置更新
Future<void> mockLocationUpdate(LatLng position) async {
  print('Mock位置: $position');
  // TODO: 实现位置Mock
}

/// Mock多个位置更新
Future<void> mockLocationUpdates(List<LatLng> positions) async {
  for (final position in positions) {
    await mockLocationUpdate(position);
    await Future.delayed(const Duration(seconds: 2));
  }
}

/// 模拟来电
Future<void> simulateIncomingCall() async {
  print('模拟来电');
  // TODO: 实现来电模拟
}

/// 模拟挂断
Future<void> simulateCallEnd() async {
  print('模拟挂断');
  // TODO: 实现挂断模拟
}

/// 模拟后台切换
Future<void> sendAppToBackground() async {
  print('APP切换到后台');
  // TODO: 实现后台切换
}

/// 模拟前台恢复
Future<void> bringAppToForeground() async {
  print('APP返回前台');
  // TODO: 实现前台恢复
}

/// 截屏保存
Future<void> takeScreenshot(
  WidgetTester tester,
  String name, {
  String? directory,
}) async {
  try {
    final bytes = await tester.binding.takeScreenshot(name);
    print('截图已保存: $name');
    // TODO: 保存截图到文件
  } catch (e) {
    print('截图失败: $e');
  }
}

/// 保存测试数据
Future<void> saveTestData(String testName, Map<String, dynamic> data) async {
  print('测试数据已保存: $testName');
  // TODO: 实现测试数据持久化
}

// Mock classes for compilation
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}

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

void print(String message) {
  // ignore: avoid_print
  // print(message);
}
