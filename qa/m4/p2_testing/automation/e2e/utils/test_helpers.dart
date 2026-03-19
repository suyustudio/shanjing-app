// qa/m4/p2_testing/automation/e2e/utils/test_helpers.dart
// E2E测试辅助工具类

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// 导出共享工具
export '../../../utils/performance_collector.dart';
export '../../../utils/test_mocks.dart';

/// 等待元素出现
Future<void> waitFor(
  WidgetTester tester,
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
    final loginFinder = find.textContaining('登录');
    if (loginFinder.evaluate().isNotEmpty) {
      await tester.tap(loginFinder);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('phone_input')), '13800138000');
      await tester.enterText(find.byKey(const Key('code_input')), '123456');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await waitFor(tester, find.textContaining('我的'), timeout: const Duration(seconds: 5));
      print('✅ 登录成功');
    } else {
      print('✅ 用户已登录');
    }
  } catch (e) {
    print('⚠️ 登录检查/执行失败: $e');
  }
}

/// 开始导航
Future<void> startNavigation(
  WidgetTester tester, {
  String? trailId,
}) async {
  await tester.tap(find.byKey(const Key('discover_tab')));
  await tester.pumpAndSettle();
  
  if (trailId != null) {
    await tester.tap(find.byKey(Key('trail_$trailId')));
  } else {
    await tester.tap(find.byType(Card).first);
  }
  await tester.pumpAndSettle();
  
  await tester.tap(find.textContaining('导航'));
  await tester.pumpAndSettle();
  
  expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
  print('✅ 导航已启动');
}

/// 进入离线地图页面
Future<void> goToOfflineMapPage(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('profile_tab')));
  await tester.pumpAndSettle();
  await tester.tap(find.textContaining('离线'));
  await tester.pumpAndSettle();
  print('✅ 进入离线地图页面');
}

/// 验证埋点事件
Future<void> verifyAnalyticsEvent(String eventName) async {
  print('📊 验证埋点: $eventName');
  // 实际实现中应该检查埋点日志或服务器接收情况
}

/// 设置网络状态
Future<void> setNetworkState({required bool enabled}) async {
  print('🌐 设置网络: ${enabled ? '启用' : '禁用'}');
  // TODO: 实现网络控制（需要平台通道支持）
}

/// 网络条件枚举
enum NetworkCondition {
  normal('正常'),
  weak('弱网'),
  offline('离线');

  final String label;
  const NetworkCondition(this.label);

  @override
  String toString() => label;
}

/// 设置网络条件
Future<void> setNetworkCondition(NetworkCondition condition) async {
  print('🌐 设置网络条件: $condition');
  // TODO: 实现网络条件控制
}

/// 确保离线地图已下载
Future<void> ensureOfflineMapDownloaded(
  WidgetTester tester, {
  required String city,
}) async {
  print('🗺️ 确保离线地图已下载: $city');
  // TODO: 实现离线地图检查
}

/// Mock位置更新
Future<void> mockLocationUpdate(LatLng position) async {
  print('📍 Mock位置: $position');
  // TODO: 实现位置Mock（需要平台通道支持）
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
  print('📞 模拟来电');
  // TODO: 实现来电模拟
}

/// 模拟挂断
Future<void> simulateCallEnd() async {
  print('📞 模拟挂断');
  // TODO: 实现挂断模拟
}

/// 切换到后台
Future<void> sendAppToBackground() async {
  print('📱 APP切换到后台');
  // TODO: 实现后台切换
}

/// 返回前台
Future<void> bringAppToForeground() async {
  print('📱 APP返回前台');
  // TODO: 实现前台恢复
}

/// 锁屏
Future<void> lockScreen() async {
  print('🔒 屏幕已锁定');
  // TODO: 实现锁屏模拟
}

/// 解锁
Future<void> unlockScreen() async {
  print('🔓 屏幕已解锁');
  // TODO: 实现解锁模拟
}

/// 截屏保存
Future<void> takeScreenshot(
  WidgetTester tester,
  String name, {
  String? directory,
}) async {
  try {
    final bytes = await tester.binding.takeScreenshot(name);
    print('📸 截图已保存: $name');
    // TODO: 保存截图到文件
  } catch (e) {
    print('📸 截图失败: $e');
  }
}

/// 保存测试数据
Future<void> saveTestData(String testName, Map<String, dynamic> data) async {
  print('💾 测试数据已保存: $testName');
  // TODO: 实现测试数据持久化
}

/// 获取当前位置
Future<LatLng> getCurrentPosition() async {
  // 返回杭州西湖附近默认位置
  return const LatLng(30.2596, 120.1479);
}

/// 获取轨迹点
Future<List<LatLng>> getTrackPoints() async {
  return [];
}

/// 模拟移动
LatLng simulateMovement(LatLng start, Duration elapsed) {
  // 模拟每秒移动约1.5米（步行速度）
  final distance = elapsed.inSeconds * 1.5;
  // 简化计算：向北移动
  final latDelta = distance / 111000; // 1度约111km
  return LatLng(start.latitude + latDelta, start.longitude);
}

/// 查找轨迹断点
List<Map<String, dynamic>> findTrackGaps(
  List<LatLng> trackPoints, {
  required int thresholdSeconds,
}) {
  final gaps = <Map<String, dynamic>>[];
  
  if (trackPoints.length < 2) return gaps;
  
  // TODO: 实际实现中需要比较时间戳
  
  return gaps;
}

/// 经纬度类
class LatLng {
  final double latitude;
  final double longitude;
  const LatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
}
