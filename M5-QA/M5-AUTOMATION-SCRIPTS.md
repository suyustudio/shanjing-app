# M5 阶段自动化测试脚本
## 山径 App M5 功能自动化测试

**版本:** v1.0  
**日期:** 2026-03-20  
**框架:** Flutter Integration Test + Dart Unit Test

---

## 目录

1. [成就系统 E2E 测试](#一成就系统-e2e-测试)
2. [推荐算法单元测试](#二推荐算法单元测试)
3. [分享功能测试](#三分享功能测试)
4. [运行指南](#四运行指南)

---

## 一、成就系统 E2E 测试

### 1.1 测试文件: test/achievement_e2e_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;
import 'package:shanjing/screens/achievement/achievement_wall_screen.dart';
import 'package:shanjing/screens/achievement/widgets/achievement_unlock_dialog.dart';
import 'package:shanjing/models/achievement.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('成就系统 E2E 测试', () {
    // 测试用户 ID
    const String testUserId = 'user_ach_test_001';

    setUp(() async {
      // 重置测试用户状态
      await _resetTestUser(testUserId);
    });

    tearDown(() async {
      // 清理测试数据
      await _cleanupTestData(testUserId);
    });

    /// TC-ACH-001: 首次徒步成就触发
    testWidgets('首次完成路线解锁"迈出第一步"成就', (WidgetTester tester) async {
      // 启动应用
      app.main();
      await tester.pumpAndSettle();

      // 登录测试用户
      await _loginAsUser(tester, testUserId);

      // 进入路线详情页
      await tester.tap(find.text('九溪十八涧'));
      await tester.pumpAndSettle();

      // 开始导航
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();

      // 模拟完成导航
      await _simulateNavigationComplete(tester);

      // 验证解锁弹窗显示
      expect(find.byType(AchievementUnlockDialog), findsOneWidget);
      expect(find.text('迈出第一步'), findsOneWidget);
      expect(find.text('恭喜解锁！'), findsOneWidget);

      // 关闭弹窗
      await tester.tap(find.text('查看详情'));
      await tester.pumpAndSettle();

      // 验证徽章墙页面
      expect(find.byType(AchievementWallScreen), findsOneWidget);
      
      // 验证徽章状态
      final badgeFinder = find.byKey(const Key('achievement_first_001'));
      expect(badgeFinder, findsOneWidget);
      
      // 截图记录
      await _takeScreenshot(tester, 'first_achievement_unlocked');
    });

    /// TC-ACH-002: 里程累计成就 - 铜级
    testWidgets('累计10km解锁"初出茅庐"成就', (WidgetTester tester) async {
      // 预设用户已有 9.5km 里程
      await _setUserProgress(testUserId, totalDistance: 9500);

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      // 完成一条 1km 的路线
      await _completeTrail(tester, trailId: 'trail_001', distance: 1000);

      // 验证解锁弹窗
      expect(find.text('初出茅庐'), findsOneWidget);
      expect(find.text('累计徒步 10km'), findsOneWidget);

      // 验证用户进度更新
      final progress = await _getUserProgress(testUserId);
      expect(progress.totalDistance, greaterThanOrEqualTo(10000));
    });

    /// TC-ACH-003: 里程累计成就 - 银级
    testWidgets('累计50km解锁"行路人"成就', (WidgetTester tester) async {
      await _setUserProgress(testUserId, totalDistance: 48500);

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      await _completeTrail(tester, trailId: 'trail_004', distance: 2000);

      expect(find.text('行路人'), findsOneWidget);
      expect(find.text('🥈'), findsOneWidget); // 银徽章图标
    });

    /// TC-ACH-006: 路线收集成就
    testWidgets('完成5条不同路线解锁"路线探索者"', (WidgetTester tester) async {
      // 预设用户已完成 4 条不同路线
      await _setUserProgress(testUserId, uniqueTrails: 4, totalTrails: 4);

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      // 完成第 5 条不同路线
      await _completeTrail(tester, trailId: 'trail_005', isNewTrail: true);

      expect(find.text('路线探索者'), findsOneWidget);
      expect(find.text('完成 5 条不同路线'), findsOneWidget);
    });

    /// TC-ACH-007: 连续打卡成就
    testWidgets('连续3天徒步解锁"坚持不懈"成就', (WidgetTester tester) async {
      // 预设连续 2 天有记录
      await _setConsecutiveDays(testUserId, days: 2);

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      // 完成今日徒步
      await _completeTrail(tester, trailId: 'trail_001');

      expect(find.text('坚持不懈'), findsOneWidget);
      expect(find.text('连续 3 天徒步'), findsOneWidget);
    });

    /// TC-ACH-010: 徽章解锁顺序验证
    testWidgets('徽章按铜→银→金→钻石顺序解锁', (WidgetTester tester) async {
      // 模拟快速完成大量路线
      await _simulateMultipleTrailCompletions(testUserId, count: 100);

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      // 进入徽章墙
      await tester.tap(find.text('我的成就'));
      await tester.pumpAndSettle();

      // 验证解锁顺序 - 检查解锁时间
      final achievements = await _getUserAchievements(testUserId, category: 'trail');
      
      final bronzeTime = achievements.firstWhere((a) => a.level == AchievementLevel.bronze).unlockedAt;
      final silverTime = achievements.firstWhere((a) => a.level == AchievementLevel.silver).unlockedAt;
      final goldTime = achievements.firstWhere((a) => a.level == AchievementLevel.gold).unlockedAt;
      final diamondTime = achievements.firstWhere((a) => a.level == AchievementLevel.diamond).unlockedAt;

      expect(bronzeTime.isBefore(silverTime), true);
      expect(silverTime.isBefore(goldTime), true);
      expect(goldTime.isBefore(diamondTime), true);
    });

    /// TC-ACH-015: 分类筛选功能
    testWidgets('徽章墙分类筛选功能正常', (WidgetTester tester) async {
      // 预设用户已解锁各类成就
      await _presetMultipleAchievements(testUserId);

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      // 进入徽章墙
      await tester.tap(find.text('我的成就'));
      await tester.pumpAndSettle();

      // 测试各分类筛选
      final tabs = ['全部', '首次', '里程', '路线', '打卡', '分享'];
      
      for (final tab in tabs) {
        await tester.tap(find.text(tab));
        await tester.pumpAndSettle();

        // 验证对应分类徽章显示
        final badges = find.byType(AchievementBadge);
        expect(badges, findsWidgets);
        
        await _takeScreenshot(tester, 'achievement_tab_$tab');
      }
    });

    /// TC-BND-001: 重复解锁测试
    testWidgets('已解锁成就不重复触发', (WidgetTester tester) async {
      // 预设用户已有首次成就
      await _grantAchievement(testUserId, 'first_001');

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      // 再次完成路线
      await _completeTrail(tester, trailId: 'trail_002');

      // 验证没有解锁弹窗
      expect(find.byType(AchievementUnlockDialog), findsNothing);

      // 验证数据库无重复记录
      final achievements = await _getUserAchievements(testUserId, achievementId: 'first_001');
      expect(achievements.length, 1);
    });

    /// TC-BND-003: 多成就同时触发
    testWidgets('单次操作可同时触发多个成就', (WidgetTester tester) async {
      // 预设用户同时满足多个成就条件
      await _setUserProgress(
        testUserId, 
        totalDistance: 9999,  // 接近 10km
        uniqueTrails: 4,      // 接近 5 条
        totalTrails: 4,
      );

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      // 完成一条新路线
      await _completeTrail(tester, trailId: 'trail_new', distance: 100, isNewTrail: true);

      // 验证多个解锁弹窗按顺序显示
      expect(find.byType(AchievementUnlockDialog), findsOneWidget);
      
      // 第一个弹窗
      await tester.tap(find.text('下一个'));
      await tester.pumpAndSettle();
      
      // 第二个弹窗
      expect(find.byType(AchievementUnlockDialog), findsOneWidget);
    });

    /// TC-ACH-014: 徽章墙页面加载性能
    testWidgets('徽章墙加载时间小于1秒', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      final stopwatch = Stopwatch()..start();
      
      await tester.tap(find.text('我的成就'));
      await tester.pumpAndSettle();

      stopwatch.stop();
      
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      
      // 记录性能数据
      await _logPerformance('achievement_wall_load_time', stopwatch.elapsedMilliseconds);
    });
  });
}

// ============ 辅助函数 ============

Future<void> _resetTestUser(String userId) async {
  // 调用测试 API 重置用户状态
  // 实际实现需要调用后端测试接口
}

Future<void> _cleanupTestData(String userId) async {
  // 清理测试数据
}

Future<void> _loginAsUser(WidgetTester tester, String userId) async {
  // 模拟登录流程
  await tester.tap(find.byKey(const Key('login_button')));
  await tester.pumpAndSettle();
  // 输入测试用户凭证...
}

Future<void> _simulateNavigationComplete(WidgetTester tester) async {
  // 模拟导航完成
  await tester.tap(find.byKey(const Key('complete_navigation_button')));
  await tester.pumpAndSettle();
}

Future<void> _completeTrail(
  WidgetTester tester, {
  required String trailId,
  int? distance,
  bool isNewTrail = false,
}) async {
  // 完成路线流程
  await tester.tap(find.text('开始导航'));
  await tester.pumpAndSettle();
  
  // 模拟导航过程...
  
  await tester.tap(find.text('完成'));
  await tester.pumpAndSettle();
  
  // 等待成就检查
  await tester.pump(const Duration(seconds: 2));
}

Future<void> _setUserProgress(
  String userId, {
  int? totalDistance,
  int? totalTrails,
  int? uniqueTrails,
}) async {
  // 调用测试 API 设置用户进度
}

Future<void> _setConsecutiveDays(String userId, {required int days}) async {
  // 设置连续打卡天数
}

Future<void> _simulateMultipleTrailCompletions(String userId, {required int count}) async {
  // 模拟完成多条路线
}

Future<void> _presetMultipleAchievements(String userId) async {
  // 预设多个已解锁成就
}

Future<void> _grantAchievement(String userId, String achievementId) async {
  // 直接授予成就
}

Future<Map<String, dynamic>> _getUserProgress(String userId) async {
  // 获取用户进度
  return {};
}

Future<List<Achievement>> _getUserAchievements(
  String userId, {
  String? category,
  String? achievementId,
}) async {
  // 获取用户成就列表
  return [];
}

Future<void> _takeScreenshot(WidgetTester tester, String name) async {
  // 截图
  await binding.takeScreenshot(name);
}

Future<void> _logPerformance(String metric, int value) async {
  // 记录性能指标
  print('PERFORMANCE: $metric = ${value}ms');
}
```

### 1.2 成就触发测试脚本: test/achievement_trigger_test.dart

```dart
// 成就触发条件单元测试
import 'package:flutter_test/flutter_test.dart';
import 'package:shanjing/services/achievement_service.dart';
import 'package:shanjing/models/achievement.dart';
import 'package:shanjing/models/user_progress.dart';

void main() {
  group('AchievementService 单元测试', () {
    late AchievementService achievementService;

    setUp(() {
      achievementService = AchievementService();
    });

    group('5类成就触发条件验证', () {
      test('首次徒步成就 - 首次完成触发', () {
        final progress = UserProgress(
          totalTrails: 1,
          totalDistance: 5000,
          uniqueTrails: 1,
        );

        final result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.trailComplete,
        );

        expect(result.unlockedIds, contains('first_001'));
      });

      test('里程累计成就 - 各级别触发', () {
        final testCases = [
          {'distance': 10000, 'expected': 'dist_001'},  // 铜
          {'distance': 50000, 'expected': 'dist_002'},  // 银
          {'distance': 100000, 'expected': 'dist_003'}, // 金
          {'distance': 500000, 'expected': 'dist_004'}, // 钻石
          {'distance': 1000000, 'expected': 'dist_005'}, // 钻石
        ];

        for (final testCase in testCases) {
          final progress = UserProgress(
            totalDistance: testCase['distance'] as int,
          );

          final result = achievementService.checkAchievements(
            progress: progress,
            activityType: ActivityType.trailComplete,
          );

          expect(result.unlockedIds, contains(testCase['expected']));
        }
      });

      test('路线收集成就 - 不重复计数', () {
        final progress = UserProgress(
          totalTrails: 5,
          uniqueTrails: 3, // 只有3条不同路线
        );

        final result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.trailComplete,
        );

        expect(result.unlockedIds, isNot(contains('trail_001_ach')));
      });

      test('连续打卡成就 - 中断后重置', () {
        final progress = UserProgress(
          currentStreak: 0,
          maxStreak: 5,
        );

        final result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.trailComplete,
        );

        expect(result.unlockedIds, isNot(contains('streak_001')));
      });

      test('分享达人成就 - 分享次数统计', () {
        final progress = UserProgress(
          totalShares: 5,
          totalLikes: 0,
        );

        final result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.share,
        );

        expect(result.unlockedIds, contains('share_001'));
      });

      test('分享达人成就 - 点赞数统计', () {
        final progress = UserProgress(
          totalShares: 0,
          totalLikes: 100,
        );

        final result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.likeReceived,
        );

        expect(result.unlockedIds, contains('share_003'));
      });
    });

    group('4级徽章解锁逻辑', () {
      test('徽章按顺序解锁，不跳过中间等级', () {
        final progress = UserProgress(
          totalDistance: 100000, // 已达金级
          uniqueTrails: 30,      // 已达金级
        );

        final result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.trailComplete,
        );

        // 验证所有低等级也已解锁
        expect(result.unlockedIds, contains('dist_001')); // 铜
        expect(result.unlockedIds, contains('dist_002')); // 银
        expect(result.unlockedIds, contains('dist_003')); // 金
      });

      test('徽章等级映射正确', () {
        final achievement = Achievement(
          id: 'test_001',
          level: AchievementLevel.gold,
        );

        expect(achievement.level.color, equals('#FFD700'));
        expect(achievement.level.hasGlowEffect, equals(true));
        expect(achievement.level.hasSparkleAnimation, equals(true));
      });
    });

    group('边界场景处理', () {
      test('重复解锁 - 已解锁成就不再触发', () {
        final alreadyUnlocked = {'first_001', 'dist_001'};
        final progress = UserProgress(
          totalDistance: 15000, // 已超过 10km
          totalTrails: 2,
        );

        final result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.trailComplete,
          alreadyUnlocked: alreadyUnlocked,
        );

        expect(result.unlockedIds, isNot(contains('first_001')));
        expect(result.unlockedIds, isNot(contains('dist_001')));
      });

      test('并发解锁 - 多个成就同时触发', () {
        final progress = UserProgress(
          totalDistance: 10000,
          totalTrails: 5,
          uniqueTrails: 5,
        );

        final result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.trailComplete,
        );

        expect(result.unlockedIds.length, greaterThan(1));
        expect(result.unlockedIds, contains('dist_001'));
        expect(result.unlockedIds, contains('trail_001_ach'));
      });

      test('边界值 - 刚好达到阈值', () {
        final progress = UserProgress(
          totalDistance: 9999, // 刚好不到 10km
        );

        var result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.trailComplete,
        );
        expect(result.unlockedIds, isNot(contains('dist_001')));

        // 再加 1米
        progress.totalDistance = 10000;
        result = achievementService.checkAchievements(
          progress: progress,
          activityType: ActivityType.trailComplete,
        );
        expect(result.unlockedIds, contains('dist_001'));
      });
    });
  });
}
```

---

## 二、推荐算法单元测试

### 2.1 测试文件: test/recommendation_algorithm_test.dart

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shanjing/services/recommendation_service.dart';
import 'package:shanjing/models/trail.dart';
import 'package:shanjing/models/user_preferences.dart';
import 'package:shanjing/models/recommendation_factors.dart';

void main() {
  group('推荐算法单元测试', () {
    late RecommendationService recommendationService;

    setUp(() {
      recommendationService = RecommendationService();
    });

    group('TC-REC-005: 难度匹配因子计算', () {
      test('难度匹配分计算 - 完全匹配', () {
        final userPref = UserPreferences(preferredDifficulty: 2);
        final trail = Trail(difficulty: 2);

        final score = recommendationService.calculateDifficultyMatch(
          trail: trail,
          userPreferences: userPref,
        );

        expect(score, equals(1.0)); // 完全匹配
      });

      test('难度匹配分计算 - 部分匹配', () {
        final userPref = UserPreferences(preferredDifficulty: 2);
        final trail = Trail(difficulty: 4); // 差 2 级

        final score = recommendationService.calculateDifficultyMatch(
          trail: trail,
          userPreferences: userPref,
        );

        expect(score, equals(0.33)); // 1 - 2/3
      });

      test('难度匹配分计算 - 新用户默认值', () {
        final userPref = UserPreferences(preferredDifficulty: null); // 无偏好
        final trail = Trail(difficulty: 2);

        final score = recommendationService.calculateDifficultyMatch(
          trail: trail,
          userPreferences: userPref,
        );

        expect(score, equals(0.8)); // 新用户默认
      });
    });

    group('TC-REC-006: 距离因子计算', () {
      test('距离分计算 - 近距离', () {
        final userLocation = Location(lat: 30.25, lng: 120.15);
        final trail = Trail(
          startLocation: Location(lat: 30.26, lng: 120.16), // 约 1.5km
        );

        final score = recommendationService.calculateDistanceScore(
          trail: trail,
          userLocation: userLocation,
        );

        expect(score, greaterThan(0.95));
        expect(score, lessThanOrEqualTo(1.0));
      });

      test('距离分计算 - 远距离', () {
        final userLocation = Location(lat: 30.25, lng: 120.15);
        final trail = Trail(
          startLocation: Location(lat: 31.0, lng: 121.0), // 约 100km+
        );

        final score = recommendationService.calculateDistanceScore(
          trail: trail,
          userLocation: userLocation,
        );

        expect(score, equals(0)); // 超过最大参考距离
      });

      test('距离分计算 - 无位置权限', () {
        final trail = Trail();

        final score = recommendationService.calculateDistanceScore(
          trail: trail,
          userLocation: null,
        );

        expect(score, equals(0.5)); // 默认值
      });
    });

    group('TC-REC-007: 评分因子计算', () {
      test('评分分计算 - 高评分', () {
        final trail = Trail(rating: 5.0, ratingCount: 50);

        final score = recommendationService.calculateRatingScore(trail: trail);

        expect(score, equals(1.0));
      });

      test('评分分计算 - 低评价数保底', () {
        final trail = Trail(rating: 2.0, ratingCount: 5); // 评价数 < 10

        final score = recommendationService.calculateRatingScore(trail: trail);

        expect(score, equals(0.7)); // 保底分
      });

      test('评分分计算 - 正常情况', () {
        final trail = Trail(rating: 4.0, ratingCount: 20);

        final score = recommendationService.calculateRatingScore(trail: trail);

        expect(score, equals(0.8)); // 4.0 / 5.0
      });
    });

    group('TC-REC-008: 热度因子计算', () {
      test('热度分计算 - 热门路线', () {
        final trailStats = TrailStats(
          monthlyCompletions: 150,
          totalFavorites: 400,
        );

        final score = recommendationService.calculatePopularityScore(
          stats: trailStats,
        );

        expect(score, greaterThan(0.8));
        expect(score, lessThanOrEqualTo(1.0));
      });

      test('热度分计算 - 冷门路线', () {
        final trailStats = TrailStats(
          monthlyCompletions: 5,
          totalFavorites: 10,
        );

        final score = recommendationService.calculatePopularityScore(
          stats: trailStats,
        );

        expect(score, lessThan(0.3));
      });

      test('热度分计算 - 封顶限制', () {
        final trailStats = TrailStats(
          monthlyCompletions: 1000, // 超过计算上限
          totalFavorites: 1000,
        );

        final score = recommendationService.calculatePopularityScore(
          stats: trailStats,
        );

        expect(score, equals(1.0)); // 封顶
      });
    });

    group('TC-REC-009: 新鲜度因子计算', () {
      test('新鲜度分计算 - 全新路线', () {
        final trail = Trail(createdAt: DateTime.now().subtract(Duration(days: 3)));

        final score = recommendationService.calculateFreshnessScore(trail: trail);

        expect(score, greaterThan(0.9));
      });

      test('新鲜度分计算 - 旧路线', () {
        final trail = Trail(createdAt: DateTime.now().subtract(Duration(days: 100)));

        final score = recommendationService.calculateFreshnessScore(trail: trail);

        expect(score, equals(0)); // 超过 90 天
      });

      test('新鲜度分计算 - 30天路线', () {
        final trail = Trail(createdAt: DateTime.now().subtract(Duration(days: 30)));

        final score = recommendationService.calculateFreshnessScore(trail: trail);

        expect(score, equals(0.67)); // 1 - 30/90
      });
    });

    group('TC-REC-010: 综合评分计算', () {
      test('综合评分 - 各因子加权', () {
        final factors = RecommendationFactors(
          difficultyMatch: 0.9,
          distance: 0.8,
          rating: 0.7,
          popularity: 0.6,
          freshness: 0.5,
        );

        final score = recommendationService.calculateOverallScore(factors: factors);

        // 0.9*0.25 + 0.8*0.20 + 0.7*0.20 + 0.6*0.20 + 0.5*0.15 = 0.71
        expect(score, closeTo(0.71, 0.01));
      });

      test('综合评分 - 保留两位小数', () {
        final factors = RecommendationFactors(
          difficultyMatch: 1.0,
          distance: 1.0,
          rating: 1.0,
          popularity: 1.0,
          freshness: 1.0,
        );

        final score = recommendationService.calculateOverallScore(factors: factors);

        expect(score, equals(1.0));
      });
    });

    group('TC-REC-011: 冷启动用户测试', () {
      test('新用户推荐策略 - 无历史数据', () async {
        final user = User(id: 'new_user', history: []);
        
        final recommendations = await recommendationService.getRecommendations(
          user: user,
          scene: RecommendationScene.home,
        );

        expect(recommendations.length, greaterThanOrEqualTo(5));
        expect(recommendations.length, lessThanOrEqualTo(10));
      });

      test('新用户默认难度匹配分', () {
        final user = User(id: 'new_user', history: []);
        final trail = Trail(difficulty: 2);

        final score = recommendationService.calculateDifficultyMatch(
          trail: trail,
          userPreferences: user.preferences,
        );

        expect(score, equals(0.8));
      });
    });

    group('TC-REC-015: 性能测试', () {
      test('推荐接口响应时间 < 200ms', () async {
        final stopwatch = Stopwatch()..start();
        
        await recommendationService.getRecommendations(
          user: User(id: 'test_user'),
          scene: RecommendationScene.home,
        );

        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(200));
      });

      test('大规模路线排序性能', () async {
        final trails = List.generate(1000, (i) => Trail(
          id: 'trail_$i',
          difficulty: (i % 4) + 1,
          rating: 3.0 + (i % 3),
        ));

        final stopwatch = Stopwatch()..start();
        
        recommendationService.sortTrails(
          trails: trails,
          user: User(id: 'test_user'),
        );

        stopwatch.stop();
        
        expect(stopwatch.elapsedMilliseconds, lessThan(500));
      });
    });

    group('推荐排序验证', () {
      test('按综合得分降序排列', () async {
        final trails = [
          Trail(id: 'low', rating: 2.0),
          Trail(id: 'high', rating: 5.0),
          Trail(id: 'medium', rating: 3.5),
        ];

        final sorted = recommendationService.sortTrails(
          trails: trails,
          user: User(id: 'test_user'),
        );

        expect(sorted[0].id, equals('high'));
        expect(sorted[1].id, equals('medium'));
        expect(sorted[2].id, equals('low'));
      });

      test('同分路线按热度 > 评分 > 距离排序', () {
        final trails = [
          Trail(id: 'a', rating: 4.0, monthlyCompletions: 50),
          Trail(id: 'b', rating: 4.0, monthlyCompletions: 100),
          Trail(id: 'c', rating: 4.5, monthlyCompletions: 50),
        ];

        final sorted = recommendationService.sortTrails(
          trails: trails,
          user: User(id: 'test_user'),
        );

        // b 热度更高，排在前面
        // c 评分更高，排在 a 前面
        expect(sorted[0].id, equals('b'));
        expect(sorted[1].id, equals('c'));
        expect(sorted[2].id, equals('a'));
      });
    });
  });
}
```

---

## 三、分享功能测试

### 3.1 测试文件: test/share_function_test.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing/main.dart' as app;
import 'package:shanjing/screens/share/achievement_share_screen.dart';
import 'package:shanjing/services/share_service.dart';
import 'package:shanjing/models/achievement.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('分享功能测试', () {
    const String testUserId = 'user_share_test_001';

    /// TC-ACH-018: 成就分享卡片生成
    testWidgets('成就分享卡片生成成功', (WidgetTester tester) async {
      // 预设已解锁成就
      final achievement = Achievement(
        id: 'dist_003',
        name: '远行者',
        level: AchievementLevel.gold,
        description: '累计徒步 100km',
      );

      app.main();
      await tester.pumpAndSettle();
      await _loginAsUser(tester, testUserId);

      // 进入成就墙
      await tester.tap(find.text('我的成就'));
      await tester.pumpAndSettle();

      // 点击已解锁成就
      await tester.tap(find.byKey(Key('achievement_${achievement.id}')));
      await tester.pumpAndSettle();

      // 点击分享按钮
      await tester.tap(find.text('分享成就'));
      await tester.pumpAndSettle();

      // 验证分享页面
      expect(find.byType(AchievementShareScreen), findsOneWidget);
      expect(find.text(achievement.name), findsOneWidget);
      expect(find.text(achievement.description), findsOneWidget);

      // 验证分享卡片内容
      expect(find.text('我的徒步成就'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget); // 二维码
    });

    testWidgets('分享卡片生成时间 < 2s', (WidgetTester tester) async {
      final achievement = Achievement(
        id: 'dist_003',
        name: '远行者',
        level: AchievementLevel.gold,
      );

      final stopwatch = Stopwatch()..start();

      await ShareService.generateShareCard(
        achievement: achievement,
        userProgress: UserProgress(totalDistance: 125000, totalTrails: 32),
      );

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });

    /// TC-ACH-019: 分享到各渠道
    testWidgets('分享渠道选择', (WidgetTester tester) async {
      final achievement = Achievement(
        id: 'dist_003',
        name: '远行者',
        level: AchievementLevel.gold,
      );

      // 验证支持的分享渠道
      final channels = ShareService.supportedChannels;
      
      expect(channels, contains('wechat_moments'));
      expect(channels, contains('wechat_friend'));
      expect(channels, contains('xiaohongshu'));
      expect(channels, contains('save_local'));
    });

    testWidgets('分享到微信朋友圈', (WidgetTester tester) async {
      final achievement = Achievement(
        id: 'dist_003',
        name: '远行者',
        level: AchievementLevel.gold,
      );

      final result = await ShareService.shareToWeChatMoments(
        achievement: achievement,
      );

      expect(result.success, true);
      expect(result.channel, equals('wechat_moments'));
    });

    testWidgets('保存到本地相册', (WidgetTester tester) async {
      final achievement = Achievement(
        id: 'dist_003',
        name: '远行者',
        level: AchievementLevel.gold,
      );

      final result = await ShareService.saveToLocal(
        achievement: achievement,
      );

      expect(result.success, true);
      expect(result.filePath, isNotNull);
    });

    /// TC-ACH-020: 分享数据埋点
    testWidgets('分享行为数据上报', (WidgetTester tester) async {
      final analytics = MockAnalyticsService();
      ShareService.analytics = analytics;

      final achievement = Achievement(id: 'dist_003', name: '远行者');

      await ShareService.share(
        achievement: achievement,
        channel: 'wechat_moments',
      );

      // 验证埋点上报
      expect(analytics.trackedEvents, contains('achievement_share_click'));
      expect(
        analytics.trackedEvents, 
        contains('achievement_share_success'),
      );
      
      // 验证参数
      final event = analytics.getEvent('achievement_share_success');
      expect(event['achievement_id'], equals('dist_003'));
      expect(event['channel'], equals('wechat_moments'));
    });

    testWidgets('分享失败处理', (WidgetTester tester) async {
      // 模拟分享失败
      ShareService.setMockFailure(true);

      final achievement = Achievement(id: 'dist_003');

      final result = await ShareService.share(
        achievement: achievement,
        channel: 'wechat_moments',
      );

      expect(result.success, false);
      expect(result.errorMessage, isNotNull);

      // 验证失败埋点
      final analytics = ShareService.analytics as MockAnalyticsService;
      expect(analytics.trackedEvents, contains('achievement_share_fail'));
    });

    /// 分享卡片样式测试
    testWidgets('分享卡片包含必要元素', (WidgetTester tester) async {
      final achievement = Achievement(
        id: 'dist_003',
        name: '远行者',
        level: AchievementLevel.gold,
        description: '累计徒步 100km',
      );

      final progress = UserProgress(
        totalDistance: 125000,
        totalTrails: 32,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: AchievementShareCard(
            achievement: achievement,
            userProgress: progress,
          ),
        ),
      );

      // 验证卡片元素
      expect(find.text('#山径App'), findsOneWidget);
      expect(find.text('远行者'), findsOneWidget);
      expect(find.text('累计徒步 100km'), findsOneWidget);
      expect(find.text('累计: 125km | 路线: 32条'), findsOneWidget);
      expect(find.text('扫描二维码，一起徒步'), findsOneWidget);
      expect(find.byType(QrImageView), findsOneWidget);
    });

    testWidgets('不同等级徽章卡片样式', (WidgetTester tester) async {
      final levels = [
        AchievementLevel.bronze,
        AchievementLevel.silver,
        AchievementLevel.gold,
        AchievementLevel.diamond,
      ];

      for (final level in levels) {
        final achievement = Achievement(
          id: 'test_$level',
          name: '测试成就',
          level: level,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: AchievementShareCard(
              achievement: achievement,
              userProgress: UserProgress(),
            ),
          ),
        );

        // 验证等级标识
        expect(find.text(level.displayName), findsOneWidget);
        
        // 截图对比
        await _takeScreenshot(tester, 'share_card_$level');
      }
    });
  });
}

// ============ 辅助类和函数 ============

class MockAnalyticsService implements AnalyticsService {
  final List<Map<String, dynamic>> _events = [];

  List<String> get trackedEvents => 
    _events.map((e) => e['name'] as String).toList();

  Map<String, dynamic> getEvent(String name) =>
    _events.firstWhere((e) => e['name'] == name, orElse: () => {});

  @override
  void track(String name, Map<String, dynamic> params) {
    _events.add({'name': name, ...params});
  }
}

Future<void> _loginAsUser(WidgetTester tester, String userId) async {
  // 登录逻辑
}

Future<void> _takeScreenshot(WidgetTester tester, String name) async {
  await binding.takeScreenshot(name);
}
```

---

## 四、运行指南

### 4.1 环境准备

```bash
# 1. 确保 Flutter 环境正常
flutter doctor

# 2. 安装依赖
flutter pub get

# 3. 安装测试依赖
flutter pub add --dev integration_test
flutter pub add --dev mockito
flutter pub add --dev build_runner
```

### 4.2 运行单元测试

```bash
# 运行所有单元测试
flutter test

# 运行特定测试文件
flutter test test/achievement_trigger_test.dart
flutter test test/recommendation_algorithm_test.dart
flutter test test/share_function_test.dart

# 运行特定测试组
flutter test --name='难度匹配因子计算'
flutter test --name='推荐算法单元测试'

# 生成覆盖率报告
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### 4.3 运行 E2E 测试

```bash
# iOS 模拟器
flutter test integration_test/achievement_e2e_test.dart

# Android 模拟器
flutter test integration_test/achievement_e2e_test.dart -d emulator-5554

# 真机 (需要连接设备)
flutter test integration_test/achievement_e2e_test.dart -d <device_id>

# 截图模式
flutter test integration_test/achievement_e2e_test.dart --dart-define=SCREENSHOT=true
```

### 4.4 CI/CD 集成

```yaml
# .github/workflows/test.yml
name: M5 Feature Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit tests
        run: flutter test
      
      - name: Run widget tests
        run: flutter test test/widget
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

### 4.5 测试报告生成

```bash
# 生成 JUnit 格式报告
flutter test --reporter=json > test_results.json
# 使用转换工具生成 JUnit XML

# 生成 HTML 报告
flutter test --reporter=expanded > test_report.txt
```

---

**文档结束**
