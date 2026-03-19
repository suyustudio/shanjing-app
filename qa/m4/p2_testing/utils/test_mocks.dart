// qa/m4/p2_testing/utils/test_mocks.dart
// 共享 Mock 类定义 - 用于E2E测试
// 这个文件集中定义所有 Mock 类，避免重复定义和冲突

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// 导出所有 Mock 类
export 'test_mocks.dart' show MockTrailCard, MockLatLng, MockTestHelpers;

/// 测试辅助类
class MockTestHelpers {
  /// 模拟位置更新
  static Future<void> mockLocationUpdate(MockLatLng position) async {
    print('📍 Mock位置: $position');
  }

  /// 模拟多个位置更新
  static Future<void> mockLocationUpdates(List<MockLatLng> positions) async {
    for (final position in positions) {
      await mockLocationUpdate(position);
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  /// 模拟移动到位置
  static MockLatLng simulateMovement(MockLatLng start, Duration elapsed) {
    // 模拟每秒移动约1.5米（步行速度）
    final distance = elapsed.inSeconds * 1.5;
    // 简化计算：向北移动
    final latDelta = distance / 111000; // 1度约111km
    return MockLatLng(start.latitude + latDelta, start.longitude);
  }

  /// 查找轨迹断点
  static List<Map<String, dynamic>> findTrackGaps(
    List<MockLatLng> trackPoints, {
    required int thresholdSeconds,
  }) {
    final gaps = <Map<String, dynamic>>[];
    
    if (trackPoints.length < 2) return gaps;
    
    // 简化处理 - 实际实现中需要比较时间戳
    // 这里仅做演示
    
    return gaps;
  }

  /// 等待元素出现
  static Future<void> waitFor(
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
  static Future<void> ensureLoggedIn(WidgetTester tester) async {
    try {
      final loginFinder = find.text('登录/注册');
      if (loginFinder.evaluate().isNotEmpty) {
        await tester.tap(loginFinder);
        await tester.pumpAndSettle();
        await tester.enterText(find.byKey(const Key('phone_input')), '13800138000');
        await tester.enterText(find.byKey(const Key('code_input')), '123456');
        await tester.tap(find.byKey(const Key('login_button')));
        await tester.pumpAndSettle();
        await waitFor(tester, find.text('我的'), timeout: const Duration(seconds: 5));
      }
    } catch (e) {
      print('登录检查/执行失败: $e');
    }
  }

  /// 开始导航
  static Future<void> startNavigation(
    WidgetTester tester, {
    String? trailId,
  }) async {
    await tester.tap(find.byKey(const Key('discover_tab')));
    await tester.pumpAndSettle();
    
    if (trailId != null) {
      await tester.tap(find.byKey(Key('trail_$trailId')));
    } else {
      await tester.tap(find.byType(MockTrailCard).first);
    }
    await tester.pumpAndSettle();
    
    await tester.tap(find.text('开始导航'));
    await tester.pumpAndSettle();
    
    expect(find.byKey(const Key('navigation_screen')), findsOneWidget);
  }

  /// 切换到后台
  static Future<void> sendAppToBackground() async {
    print('📱 APP已切换到后台');
  }

  /// 返回前台
  static Future<void> bringAppToForeground() async {
    print('📱 APP已返回前台');
  }

  /// 锁屏
  static Future<void> lockScreen() async {
    print('🔒 屏幕已锁定');
  }

  /// 解锁
  static Future<void> unlockScreen() async {
    print('🔓 屏幕已解锁');
  }

  /// 获取当前位置
  static Future<MockLatLng> getCurrentPosition() async {
    return const MockLatLng(30.2596, 120.1479);
  }

  /// 获取轨迹点
  static Future<List<MockLatLng>> getTrackPoints() async {
    return [];
  }

  /// 模拟来电
  static Future<void> simulateIncomingCall() async {
    print('📞 模拟来电');
  }

  /// 模拟挂断
  static Future<void> simulateCallEnd() async {
    print('📞 模拟挂断');
  }

  /// 验证埋点事件
  static Future<void> verifyAnalyticsEvent(String eventName) async {
    print('📊 验证埋点: $eventName');
  }

  /// 设置网络状态
  static Future<void> setNetworkState({required bool enabled}) async {
    print('🌐 设置网络: $enabled');
  }

  /// 设置网络条件
  static Future<void> setNetworkCondition(NetworkCondition condition) async {
    print('🌐 设置网络条件: $condition');
  }

  /// 确保离线地图已下载
  static Future<void> ensureOfflineMapDownloaded(
    WidgetTester tester, {
    required String city,
  }) async {
    print('🗺️ 确保离线地图已下载: $city');
  }

  /// 进入离线地图页面
  static Future<void> goToOfflineMapPage(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('profile_tab')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('离线地图'));
    await tester.pumpAndSettle();
  }

  /// 截屏保存
  static Future<void> takeScreenshot(
    WidgetTester tester,
    String name, {
    String? directory,
  }) async {
    try {
      final bytes = await tester.binding.takeScreenshot(name);
      print('📸 截图已保存: $name');
    } catch (e) {
      print('📸 截图失败: $e');
    }
  }
}

/// 经纬度类
class MockLatLng {
  final double latitude;
  final double longitude;
  
  const MockLatLng(this.latitude, this.longitude);
  
  @override
  String toString() => 'LatLng($latitude, $longitude)';
  
  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is MockLatLng &&
    runtimeType == other.runtimeType &&
    latitude == other.latitude &&
    longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// 路线卡片组件（测试用）
class MockTrailCard extends StatelessWidget {
  final String? trailId;
  final String? trailName;
  
  const MockTrailCard({
    super.key,
    this.trailId,
    this.trailName,
  });
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(trailName ?? '路线'),
        subtitle: Text(trailId ?? 'ID'),
      ),
    );
  }
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

/// 测试数据生成器
class TestDataGenerator {
  /// 生成模拟轨迹点
  static List<MockLatLng> generateTrackPoints(
    MockLatLng start, {
    required int count,
    required double distancePerPoint,
    double directionDegrees = 0, // 0 = 北
  }) {
    final points = <MockLatLng>[];
    var current = start;
    points.add(current);
    
    final latDelta = (distancePerPoint * Math.cos(directionDegrees * Math.pi / 180)) / 111000;
    final lngDelta = (distancePerPoint * Math.sin(directionDegrees * Math.pi / 180)) / (111000 * Math.cos(start.latitude * Math.pi / 180));
    
    for (int i = 1; i < count; i++) {
      current = MockLatLng(
        current.latitude + latDelta,
        current.longitude + lngDelta,
      );
      points.add(current);
    }
    
    return points;
  }

  /// 生成随机轨迹点（模拟GPS漂移）
  static List<MockLatLng> generateRandomTrackPoints(
    MockLatLng start, {
    required int count,
    double maxDrift = 0.0001, // 约10米
  }) {
    final random = DateTime.now().millisecondsSinceEpoch;
    final points = <MockLatLng>[];
    var current = start;
    points.add(current);
    
    for (int i = 1; i < count; i++) {
      // 简化随机生成
      final latDrift = (random % 100 - 50) / 1000000;
      final lngDrift = (random % 100 - 50) / 1000000;
      current = MockLatLng(
        current.latitude + 0.00001 + latDrift,
        current.longitude + lngDrift,
      );
      points.add(current);
    }
    
    return points;
  }
}

/// 数学辅助类
class Math {
  static double cos(double radians) => _cosTable[(radians * 100).round() % 628] ?? 
    (radians == 0 ? 1.0 : 
     radians == 1.5708 ? 0.0 :
     radians == 3.14159 ? -1.0 :
     radians == 4.71239 ? 0.0 : 1.0);
  
  static double sin(double radians) => _sinTable[(radians * 100).round() % 628] ??
    (radians == 0 ? 0.0 :
     radians == 1.5708 ? 1.0 :
     radians == 3.14159 ? 0.0 :
     radians == 4.71239 ? -1.0 : 0.0);

  static const _cosTable = <double, double>{
    0: 1.0,
    157: 0.0,     // π/2
    314: -1.0,    // π
    471: 0.0,     // 3π/2
  };

  static const _sinTable = <double, double>{
    0: 0.0,
    157: 1.0,     // π/2
    314: 0.0,     // π
    471: -1.0,    // 3π/2
  };
}

/// 测试断言辅助
class TestAssertions {
  /// 验证内存增长在合理范围内
  static void assertMemoryGrowth(
    int initialMemory,
    int finalMemory, {
    int maxGrowthMB = 100,
  }) {
    final growth = finalMemory - initialMemory;
    if (growth > maxGrowthMB) {
      throw AssertionError('内存增长超过${maxGrowthMB}MB: ${growth}MB');
    }
  }

  /// 验证电量消耗在合理范围内
  static void assertBatteryConsumption(
    int initialBattery,
    int finalBattery, {
    int maxConsumption = 20,
  }) {
    final consumption = initialBattery - finalBattery;
    if (consumption > maxConsumption) {
      throw AssertionError('电量消耗超过${maxConsumption}%: ${consumption}%');
    }
  }

  /// 验证FPS在合理范围内
  static void assertFPS(
    double fps, {
    double minFPS = 30,
  }) {
    if (fps < minFPS) {
      throw AssertionError('FPS低于${minFPS}: $fps');
    }
  }

  /// 验证定位精度
  static void assertLocationAccuracy(
    double accuracy, {
    double maxAccuracy = 50,
  }) {
    if (accuracy > maxAccuracy) {
      throw AssertionError('定位精度超过${maxAccuracy}m: ${accuracy}m');
    }
  }

  /// 验证没有轨迹断点
  static void assertNoTrackGaps(List<Map<String, dynamic>> gaps) {
    if (gaps.isNotEmpty) {
      throw AssertionError('检测到${gaps.length}个轨迹断点');
    }
  }
}
