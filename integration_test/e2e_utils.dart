import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hangzhou_guide/main.dart' as app;

/// E2E 测试基础工具类
/// 提供常用的测试辅助方法和封装
class E2ETestUtils {
  /// 等待指定时间
  static Future<void> delay(WidgetTester tester, int milliseconds) async {
    await Future.delayed(Duration(milliseconds: milliseconds));
    await tester.pump();
  }

  /// 等待页面加载完成
  static Future<void> waitForPageLoad(WidgetTester tester) async {
    await tester.pumpAndSettle(const Duration(seconds: 3));
  }

  /// 查找并点击组件
  static Future<void> tapByKey(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget, reason: 'Key "$key" not found');
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// 查找并点击文本
  static Future<void> tapByText(WidgetTester tester, String text) async {
    final finder = find.text(text);
    expect(finder, findsOneWidget, reason: 'Text "$text" not found');
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// 查找并点击图标
  static Future<void> tapByIcon(WidgetTester tester, IconData icon) async {
    final finder = find.byIcon(icon);
    expect(finder, findsOneWidget, reason: 'Icon not found');
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  /// 输入文本
  static Future<void> enterText(WidgetTester tester, String key, String text) async {
    final finder = find.byKey(Key(key));
    expect(finder, findsOneWidget, reason: 'TextField with key "$key" not found');
    await tester.enterText(finder, text);
    await tester.pumpAndSettle();
  }

  /// 清空搜索框
  static Future<void> clearSearch(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    if (finder.evaluate().isNotEmpty) {
      await tester.enterText(finder, '');
      await tester.pumpAndSettle();
    }
  }

  /// 验证文本存在
  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget, reason: 'Text "$text" not found');
  }

  /// 验证文本不存在
  static void expectTextNotExists(String text) {
    expect(find.text(text), findsNothing, reason: 'Text "$text" should not exist');
  }

  /// 验证组件存在
  static void expectWidgetExists(String key) {
    expect(find.byKey(Key(key)), findsOneWidget, reason: 'Widget with key "$key" not found');
  }

  /// 滚动列表直到找到文本
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    String listKey,
    String targetText, {
    double delta = 200.0,
  }) async {
    final listFinder = find.byKey(Key(listKey));
    final targetFinder = find.text(targetText);
    
    await tester.scrollUntilVisible(
      targetFinder,
      delta,
      scrollable: listFinder,
      duration: const Duration(milliseconds: 500),
    );
    await tester.pumpAndSettle();
  }

  /// 截图保存（用于调试）
  static Future<void> takeScreenshot(
    WidgetTester tester,
    IntegrationTestWidgetsFlutterBinding binding,
    String name,
  ) async {
    await binding.takeScreenshot(name);
  }

  /// 模拟网络状态（通过修改连接状态）
  static Future<void> simulateNetworkState(bool isConnected) async {
    // 在实际测试中，可以通过 Mock NetworkManager 来实现
    // 这里提供接口定义
  }

  /// 模拟 GPS 信号强度
  static Future<void> simulateGPSSignal(double accuracy) async {
    // 在实际测试中，可以通过 Mock LocationManager 来实现
    // accuracy < 10: 强信号, 10-50: 中等, > 50: 弱信号
  }
}

/// 测试数据常量
class TestData {
  // 路线搜索关键词
  static const String searchKeywordTrail = '九溪';
  static const String searchKeywordLocation = '西湖';
  static const String searchNoResults = '不存在的路线名称';
  
  // 等待时间
  static const int shortDelay = 500;    // 0.5s
  static const int mediumDelay = 1500;  // 1.5s
  static const int longDelay = 3000;    // 3s
  
  // 重试次数
  static const int maxRetries = 3;
}

/// 测试配置
class TestConfig {
  // 是否启用截图
  static const bool enableScreenshots = true;
  
  // 是否打印详细日志
  static const bool verboseLogging = true;
  
  // 默认超时时间
  static const Duration defaultTimeout = Duration(seconds: 10);
  
  // 动画持续时间
  static const Duration animationDuration = Duration(milliseconds: 300);
}

/// 日志工具
class TestLogger {
  static void log(String message) {
    if (TestConfig.verboseLogging) {
      print('[E2E TEST] $message');
    }
  }
  
  static void step(String stepName) {
    log('▶️ 执行步骤: $stepName');
  }
  
  static void success(String message) {
    log('✅ $message');
  }
  
  static void error(String message) {
    log('❌ $message');
  }
  
  static void warning(String message) {
    log('⚠️ $message');
  }
}
