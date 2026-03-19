// M5 - 成就系统自动化测试套件
// 测试范围: TC-AC-001 ~ TC-AC-030

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing_app/main.dart' as app;
import '../utils/test_helpers.dart';
import '../utils/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('成就系统测试套件', () {
    
    setUp(() async {
      // 每个测试前重置成就数据
      await TestHelpers.clearAchievementData();
    });

    // TC-AC-001: 探索类成就 - 铜级触发
    testWidgets('探索类铜级成就触发', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 模拟完成5条不同路线
      for (int i = 0; i < 5; i++) {
        await TestHelpers.simulateTrailComplete(
          trailId: 'trail_$i',
          distance: 2000,
        );
      }
      
      await tester.pumpAndSettle();
      
      // 验证解锁动画显示
      expect(find.text('解锁成就'), findsOneWidget);
      expect(find.text('路线收集家·铜'), findsOneWidget);
      expect(find.byType(AchievementUnlockAnimation), findsOneWidget);
    });

    // TC-AC-002: 探索类升级路径
    testWidgets('探索类成就升级路径', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 模拟完成15条路线（银级）
      for (int i = 0; i < 15; i++) {
        await TestHelpers.simulateTrailComplete(
          trailId: 'trail_$i',
          distance: 2000,
        );
      }
      
      await tester.pumpAndSettle();
      
      // 验证银级成就
      final achievements = await TestHelpers.getUserAchievements();
      final exploreAchievement = achievements.firstWhere(
        (a) => a.id == 'explorer',
      );
      expect(exploreAchievement.currentLevel, 'silver');
    });

    // TC-AC-003: 里程类成就累计计算
    testWidgets('里程类成就累计计算', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 模拟完成多条路线累计10km
      await TestHelpers.simulateTrailComplete(
        trailId: 'trail_1',
        distance: 4000,
      );
      await TestHelpers.simulateTrailComplete(
        trailId: 'trail_2',
        distance: 3500,
      );
      await TestHelpers.simulateTrailComplete(
        trailId: 'trail_3',
        distance: 2500,
      );
      
      await tester.pumpAndSettle();
      
      // 验证行者无疆·铜触发（10km）
      expect(find.text('行者无疆·铜'), findsOneWidget);
    });

    // TC-AC-004: 频率类连续周计算
    testWidgets('频率类连续周计算', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 模拟连续2周徒步记录
      await TestHelpers.simulateWeeklyTrailComplete(
        weeks: 2,
        trailsPerWeek: 1,
      );
      
      await tester.pumpAndSettle();
      
      // 验证周行者·铜触发
      expect(find.text('周行者·铜'), findsOneWidget);
    });

    // TC-AC-007: 社交类分享计数
    testWidgets('社交类分享成就', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 模拟分享10次
      for (int i = 0; i < 10; i++) {
        await TestHelpers.simulateShare(
          trailId: 'trail_$i',
          channel: 'wechat',
        );
      }
      
      await tester.pumpAndSettle();
      
      // 验证分享达人·铜触发
      expect(find.text('分享达人·铜'), findsOneWidget);
    });

    // TC-AC-008: 解锁动画流畅度
    testWidgets('成就解锁动画流畅度', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 触发成就
      await TestHelpers.simulateTrailComplete(
        trailId: 'trail_1',
        distance: 2000,
      );
      
      // 记录FPS
      final fps = await TestHelpers.measureFPS(
        duration: Duration(seconds: 3),
        tester: tester,
      );
      
      // 验证动画流畅度
      expect(fps, greaterThan(55));
    });

    // TC-AC-009: 成就页面展示
    testWidgets('成就列表页面', (WidgetTester tester) async {
      // 先解锁一些成就
      await TestHelpers.unlockMockAchievements([
        Achievement(id: 'explorer', level: 'bronze'),
        Achievement(id: 'distance', level: 'silver'),
      ]);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // 点击我的成就
      await tester.tap(find.text('我的成就'));
      await tester.pumpAndSettle();
      
      // 验证成就列表显示
      expect(find.text('路线收集家'), findsOneWidget);
      expect(find.text('行者无疆'), findsOneWidget);
      
      // 验证已解锁和未解锁状态
      expect(find.byType(AchievementBadge), findsWidgets);
    });

    // TC-AC-011: 成就分享功能
    testWidgets('成就分享海报生成', (WidgetTester tester) async {
      await TestHelpers.unlockMockAchievements([
        Achievement(id: 'explorer', level: 'gold'),
      ]);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 进入成就详情
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      await tester.tap(find.text('我的成就'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('路线收集家'));
      await tester.pumpAndSettle();
      
      // 点击分享
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      
      // 验证海报生成
      expect(find.byType(ShareSheet), findsOneWidget);
      expect(find.text('分享到'), findsOneWidget);
    });

    // TC-AC-012: 本地数据持久化
    testWidgets('成就数据持久化', (WidgetTester tester) async {
      await TestHelpers.unlockMockAchievements([
        Achievement(id: 'explorer', level: 'bronze'),
      ]);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 重启APP
      await TestHelpers.restartApp(tester);
      
      // 验证成就数据保留
      final achievements = await TestHelpers.getUserAchievements();
      expect(achievements.length, greaterThan(0));
      expect(achievements.any((a) => a.id == 'explorer'), true);
    });

    // TC-AC-014: 离线解锁延迟同步
    testWidgets('离线解锁同步', (WidgetTester tester) async {
      // 断开网络
      await TestHelpers.setNetworkEnabled(false);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 完成路线（离线）
      await TestHelpers.simulateTrailComplete(
        trailId: 'trail_1',
        distance: 2000,
      );
      
      // 验证本地解锁
      var achievements = await TestHelpers.getUserAchievements();
      expect(achievements.any((a) => a.id == 'explorer'), true);
      
      // 恢复网络
      await TestHelpers.setNetworkEnabled(true);
      await tester.pump(Duration(seconds: 3));
      
      // 验证服务端同步
      final serverAchievements = await TestHelpers.getServerAchievements();
      expect(serverAchievements.any((a) => a.id == 'explorer'), true);
    });

    // TC-AC-015: 重复路线不计数
    testWidgets('重复路线探索成就不计数', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 完成同一条路线5次
      for (int i = 0; i < 5; i++) {
        await TestHelpers.simulateTrailComplete(
          trailId: 'same_trail',
          distance: 2000,
        );
      }
      
      await tester.pumpAndSettle();
      
      // 验证探索类成就未触发（需要5条不同路线）
      expect(find.text('路线收集家'), findsNothing);
      
      // 验证里程类成就累计了距离
      final stats = await TestHelpers.getUserStats();
      expect(stats.totalDistance, 10000); // 5 * 2000
    });

    // TC-AC-016: 并发成就解锁
    testWidgets('多个成就同时解锁', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 创造条件同时满足多个成就
      await TestHelpers.simulateTrailComplete(
        trailId: 'trail_1',
        distance: 10000, // 同时触发探索、里程
      );
      
      await tester.pumpAndSettle();
      
      // 验证动画按序显示
      expect(find.byType(AchievementUnlockAnimation), findsOneWidget);
      
      // 等待第一个动画完成
      await tester.pump(Duration(seconds: 3));
      
      // 验证第二个成就动画显示
      expect(find.byType(AchievementUnlockAnimation), findsOneWidget);
    });

    // TC-AC-019: 成就埋点完整性
    testWidgets('成就埋点事件', (WidgetTester tester) async {
      await TestHelpers.clearAnalyticsEvents();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 触发成就
      await TestHelpers.simulateTrailComplete(
        trailId: 'trail_1',
        distance: 2000,
      );
      
      await tester.pump(Duration(seconds: 1));
      
      // 验证埋点上报
      final events = await TestHelpers.getAnalyticsEvents();
      expect(events, contains('achievement_unlock'));
      
      // 点击分享
      await tester.tap(find.byIcon(Icons.share));
      await tester.pumpAndSettle();
      
      final updatedEvents = await TestHelpers.getAnalyticsEvents();
      expect(updatedEvents, contains('achievement_share'));
    });
  });
}
