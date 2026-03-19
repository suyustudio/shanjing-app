// M5 - 推荐算法自动化测试套件
// 测试范围: TC-RE-001 ~ TC-RE-020

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing_app/main.dart' as app;
import '../utils/test_helpers.dart';
import '../utils/test_data.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('推荐算法测试套件', () {
    
    setUp(() async {
      await TestHelpers.clearUserProfile();
      await TestHelpers.loadMockTrailData();
    });

    // TC-RE-001: 地理位置因子
    testWidgets('地理位置优先推荐', (WidgetTester tester) async {
      // 设置用户位置为杭州
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 获取推荐列表
      final recommendations = await TestHelpers.getRecommendations();
      
      // 验证前5条中杭州路线占多数
      final hangzhouTrails = recommendations
          .where((t) => t.city == '杭州')
          .take(5)
          .length;
      expect(hangzhouTrails, greaterThanOrEqualTo(4));
    });

    // TC-RE-002: 难度匹配因子
    testWidgets('难度偏好匹配', (WidgetTester tester) async {
      // 设置用户偏好easy
      await TestHelpers.setUserProfile(preferredDifficulty: 'easy');
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      final recommendations = await TestHelpers.getRecommendations();
      
      // 统计easy难度占比
      final easyCount = recommendations
          .where((t) => t.difficulty == 'easy')
          .length;
      final easyRatio = easyCount / recommendations.length;
      
      expect(easyRatio, greaterThan(0.5));
    });

    // TC-RE-003: 距离偏好因子
    testWidgets('距离偏好匹配', (WidgetTester tester) async {
      // 设置用户平均徒步3km
      await TestHelpers.setUserProfile(avgDistance: 3.0);
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      final recommendations = await TestHelpers.getRecommendations();
      
      // 计算推荐距离均值
      final avgRecDistance = recommendations
          .map((t) => t.distanceKm)
          .reduce((a, b) => a + b) / recommendations.length;
      
      // 均值应接近用户偏好
      expect(avgRecDistance, closeTo(3.0, 2.0));
    });

    // TC-RE-006: 5因子综合排序
    testWidgets('综合排序准确性', (WidgetTester tester) async {
      // 设置完整用户画像
      await TestHelpers.setUserProfile(
        avgDistance: 3.0,
        preferredDifficulty: 'easy',
        preferredScenery: 'forest',
      );
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      final recommendations = await TestHelpers.getRecommendations();
      
      // 验证推荐质量
      final firstTrail = recommendations.first;
      
      // 第一条应该是：杭州、easy难度、距离3km左右
      expect(firstTrail.city, '杭州');
      expect(firstTrail.difficulty, 'easy');
      expect(firstTrail.distanceKm, closeTo(3.0, 2.0));
    });

    // TC-RE-007: 推荐结果多样性
    testWidgets('推荐结果多样性', (WidgetTester tester) async {
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      final recommendations = await TestHelpers.getRecommendations(count: 10);
      
      // 验证难度多样性
      final difficulties = recommendations.map((t) => t.difficulty).toSet();
      expect(difficulties.length, greaterThan(1));
      
      // 验证景观类型多样性
      final sceneryTypes = recommendations.map((t) => t.sceneryType).toSet();
      expect(sceneryTypes.length, greaterThan(1));
    });

    // TC-RE-008: 冷启动推荐
    testWidgets('冷启动有默认推荐', (WidgetTester tester) async {
      // 全新用户，无历史数据
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 新用户注册
      await TestHelpers.registerNewUser();
      await tester.pumpAndSettle();
      
      // 获取推荐
      final recommendations = await TestHelpers.getRecommendations();
      
      // 验证有推荐列表
      expect(recommendations, isNotEmpty);
      expect(recommendations.length, greaterThan(5));
      
      // 验证包含热门路线
      expect(recommendations.any((t) => t.popularity > 100), true);
    });

    // TC-RE-009: 推荐刷新功能
    testWidgets('推荐刷新', (WidgetTester tester) async {
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 首次获取推荐
      final firstBatch = await TestHelpers.getRecommendations();
      
      // 下拉刷新
      await tester.fling(
        find.byType(RecommendationList),
        const Offset(0, 300),
        300,
      );
      await tester.pumpAndSettle();
      
      // 获取刷新后推荐
      final secondBatch = await TestHelpers.getRecommendations();
      
      // 验证列表有变化
      final firstIds = firstBatch.map((t) => t.id).toSet();
      final secondIds = secondBatch.map((t) => t.id).toSet();
      
      // 至少部分路线不同
      final intersection = firstIds.intersection(secondIds);
      expect(intersection.length, lessThan(firstIds.length));
    });

    // TC-RE-010: API响应时间
    testWidgets('推荐API响应时间', (WidgetTester tester) async {
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 测量响应时间
      final stopwatch = Stopwatch()..start();
      
      await TestHelpers.getRecommendations();
      
      stopwatch.stop();
      
      // 验证API响应时间
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    // TC-RE-011: 高并发性能
    testWidgets('推荐并发性能', (WidgetTester tester) async {
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      // 模拟并发请求
      final futures = List.generate(
        10,
        (_) => TestHelpers.getRecommendations(),
      );
      
      final stopwatch = Stopwatch()..start();
      
      await Future.wait(futures);
      
      stopwatch.stop();
      
      // 验证总时间
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    // TC-RE-013: 加载动画
    testWidgets('推荐加载动画', (WidgetTester tester) async {
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 触发推荐加载
      await TestHelpers.triggerRecommendationLoad();
      
      // 验证加载指示器显示
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      
      await tester.pumpAndSettle();
      
      // 验证加载完成后指示器消失
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    // TC-RE-014: 推荐失败容错
    testWidgets('推荐失败容错', (WidgetTester tester) async {
      // 模拟服务端异常
      await TestHelpers.simulateServerError('/recommendations');
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 尝试获取推荐
      await TestHelpers.getRecommendations();
      await tester.pumpAndSettle();
      
      // 验证错误提示
      expect(find.text('获取推荐失败'), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    // TC-RE-015: 无网络推荐
    testWidgets('无网络使用缓存推荐', (WidgetTester tester) async {
      // 先在有网络时加载推荐
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      await TestHelpers.getRecommendations();
      await tester.pumpAndSettle();
      
      // 断开网络
      await TestHelpers.setNetworkEnabled(false);
      
      // 重启APP
      await TestHelpers.restartApp(tester);
      
      // 验证显示缓存推荐
      final recommendations = await TestHelpers.getRecommendations();
      expect(recommendations, isNotEmpty);
      
      // 验证离线提示
      expect(find.text('当前离线，显示历史推荐'), findsOneWidget);
    });

    // TC-RE-016: 埋点完整性
    testWidgets('推荐埋点事件', (WidgetTester tester) async {
      await TestHelpers.clearAnalyticsEvents();
      await TestHelpers.setUserLocation(lat: 30.2741, lng: 120.1551);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 加载推荐
      await TestHelpers.getRecommendations();
      await tester.pump(Duration(seconds: 1));
      
      // 验证load事件
      var events = await TestHelpers.getAnalyticsEvents();
      expect(events, contains('recommendation_load'));
      
      // 点击推荐
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      // 验证click事件
      events = await TestHelpers.getAnalyticsEvents();
      expect(events, contains('recommendation_click'));
    });
  });
}
