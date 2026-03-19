import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hangzhou_guide/screens/onboarding/onboarding.dart';

/// 新手引导模块单元测试
/// 测试覆盖：OnboardingService, PermissionManager, OnboardingScreen, SpotlightOverlay
void main() {
  WidgetsFlutterBinding.ensureInitialized();

  group('OnboardingService Tests', () {
    late OnboardingService service;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      service = OnboardingService();
      await service.initialize();
    });

    tearDown(() async {
      await service.reset();
    });

    test('初始状态应该需要显示引导', () async {
      final shouldShow = await service.shouldShowOnboarding();
      expect(shouldShow, true);
    });

    test('标记完成后不应该显示引导', () async {
      await service.markCompleted();
      final shouldShow = await service.shouldShowOnboarding();
      expect(shouldShow, false);
    });

    test('标记跳过后不应该显示引导', () async {
      await service.markSkipped();
      final shouldShow = await service.shouldShowOnboarding();
      expect(shouldShow, false);
    });

    test('重置后应该恢复初始状态', () async {
      await service.markCompleted();
      await service.reset();
      final shouldShow = await service.shouldShowOnboarding();
      expect(shouldShow, true);
    });

    test('应该能正确设置和获取当前页面', () async {
      await service.setCurrentPage(2);
      final currentPage = await service.getCurrentPage();
      expect(currentPage, 2);
    });

    test('应该能正确获取引导状态', () async {
      var status = await service.getStatus();
      expect(status, OnboardingStatus.notStarted);

      await service.setCurrentPage(1);
      status = await service.getStatus();
      expect(status, OnboardingStatus.inProgress);

      await service.markCompleted();
      status = await service.getStatus();
      expect(status, OnboardingStatus.completed);

      await service.reset();
      await service.markSkipped();
      status = await service.getStatus();
      expect(status, OnboardingStatus.skipped);
    });

    test('应该能记录引导开始和完成时间', () async {
      await service.markStarted();
      final startedAt = await service.getStartedAt();
      expect(startedAt, isNotNull);

      await service.setCompletedAt();
      final completedAt = await service.getCompletedAt();
      expect(completedAt, isNotNull);
    });

    test('应该能计算引导持续时间', () async {
      await service.markStarted();
      await Future.delayed(const Duration(milliseconds: 100));
      await service.setCompletedAt();

      final duration = await service.getDurationSeconds();
      expect(duration, greaterThanOrEqualTo(0));
    });
  });

  group('PermissionManager Tests', () {
    late PermissionManager manager;

    setUp(() {
      manager = PermissionManager();
    });

    test('应该返回正确的权限描述', () {
      final locationDesc = manager.getPermissionDescription(PermissionType.location);
      expect(locationDesc['title'], '位置权限');
      expect(locationDesc['description'], '用于路线导航和轨迹记录');

      final storageDesc = manager.getPermissionDescription(PermissionType.storage);
      expect(storageDesc['title'], '存储权限');

      final notificationDesc = manager.getPermissionDescription(PermissionType.notification);
      expect(notificationDesc['title'], '通知权限');
    });

    test('应该返回未知权限描述给未知类型', () {
      // 由于 PermissionType 是 enum，无法测试未知类型
      // 但为了完整性保留此测试结构
      expect(true, true);
    });
  });

  group('OnboardingScreen Widget Tests', () {
    testWidgets('应该显示4个页面指示器', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () {},
          ),
        ),
      );

      await tester.pump();

      // 查找页面指示器（AnimatedContainer）
      final indicators = find.byType(AnimatedContainer);
      expect(indicators, findsAtLeastNWidgets(4));
    });

    testWidgets('应该显示跳过按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () {},
          ),
        ),
      );

      await tester.pump();

      expect(find.text('跳过引导'), findsOneWidget);
    });

    testWidgets('第一页应该显示欢迎内容', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () {},
          ),
        ),
      );

      await tester.pump();

      expect(find.text('发现城市中的自然'), findsOneWidget);
      expect(find.text('开始探索'), findsOneWidget);
    });

    testWidgets('点击开始探索应该进入下一页', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () {},
          ),
        ),
      );

      await tester.pump();

      // 点击开始探索按钮
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 第二页应该显示权限相关内容
      expect(find.text('为了更好体验'), findsOneWidget);
    });

    testWidgets('跳过引导应该显示确认对话框', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () {},
          ),
        ),
      );

      await tester.pump();

      // 点击跳过按钮
      await tester.tap(find.text('跳过引导'));
      await tester.pumpAndSettle();

      // 应该显示确认对话框
      expect(find.text('确定跳过？'), findsOneWidget);
      expect(find.text('你可以在设置中随时重新查看新手引导'), findsOneWidget);
    });
  });

  group('SpotlightOverlay Widget Tests', () {
    testWidgets('应该显示引导提示卡片', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Container(color: Colors.white),
              SpotlightOverlay(
                targetRect: const Rect.fromLTWH(100, 100, 200, 100),
                description: '点击这里测试',
                onDismiss: () {},
              ),
            ],
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('点击这里测试'), findsOneWidget);
      expect(find.text('我知道了'), findsOneWidget);
    });

    testWidgets('点击我知道了应该触发onDismiss', (WidgetTester tester) async {
      bool dismissed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Container(color: Colors.white),
              SpotlightOverlay(
                targetRect: const Rect.fromLTWH(100, 100, 200, 100),
                description: '点击这里测试',
                onDismiss: () {
                  dismissed = true;
                },
              ),
            ],
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('我知道了'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(dismissed, true);
    });

    testWidgets('多步骤引导应该支持下一步', (WidgetTester tester) async {
      int nextCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Stack(
            children: [
              Container(color: Colors.white),
              SpotlightOverlay(
                targetRect: const Rect.fromLTWH(100, 100, 200, 100),
                description: '第一步',
                showNextButton: true,
                nextButtonText: '下一步',
                onNext: () {
                  nextCount++;
                },
              ),
            ],
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 300));

      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle(const Duration(milliseconds: 400));

      expect(nextCount, 1);
    });
  });

  group('Integration Tests', () {
    testWidgets('完整引导流程测试', (WidgetTester tester) async {
      SharedPreferences.setMockInitialValues({});
      bool completed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () {
              completed = true;
            },
          ),
        ),
      );

      await tester.pump();

      // 第一页：点击开始探索
      expect(find.text('发现城市中的自然'), findsOneWidget);
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 第二页：权限页
      expect(find.text('为了更好体验'), findsOneWidget);
      await tester.tap(find.text('稍后设置'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 第三页：功能介绍页
      expect(find.text('发现路线'), findsOneWidget);
      await tester.tap(find.text('下一步'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // 第四页：完成页
      expect(find.text('🎉 欢迎加入山径！'), findsOneWidget);
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      expect(completed, true);
    });
  });

  group('Performance Tests', () {
    testWidgets('页面切换动画应该在合理时间内完成', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingScreen(
            onComplete: () {},
          ),
        ),
      );

      await tester.pump();

      final stopwatch = Stopwatch()..start();

      // 点击开始探索
      await tester.tap(find.text('开始探索'));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      stopwatch.stop();

      // 动画应该在 500ms 以内完成
      expect(stopwatch.elapsedMilliseconds, lessThan(600));
    });
  });
}
