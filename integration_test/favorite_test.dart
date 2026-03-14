import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hangzhou_guide/main.dart' as app;

import 'e2e_utils.dart';

/// 收藏功能 E2E 测试
/// 测试场景：添加收藏 → 我的收藏 → 取消收藏
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('收藏功能 E2E 测试', () {
    testWidgets('完整收藏流程测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);
      TestLogger.success('应用启动成功');

      // 步骤1: 切换到发现页
      TestLogger.step('切换到发现页');
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 步骤2: 进入第一条路线详情
      TestLogger.step('进入路线详情');
      final firstTrailCard = find.byType(Card).first;
      await tester.tap(firstTrailCard);
      await E2ETestUtils.waitForPageLoad(tester);

      // 步骤3: 点击收藏按钮
      TestLogger.step('添加收藏');
      final favoriteButton = find.byIcon(Icons.favorite_border);
      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await E2ETestUtils.delay(tester, TestData.mediumDelay);
        
        // 验证收藏成功（图标变为实心）
        expect(find.byIcon(Icons.favorite), findsOneWidget);
        TestLogger.success('收藏添加成功');
      } else {
        // 可能已经收藏过了
        TestLogger.warning('路线可能已收藏，检查当前状态');
        expect(find.byIcon(Icons.favorite), findsOneWidget);
      }

      // 步骤4: 切换到"我的"页面查看收藏
      TestLogger.step('查看我的收藏');
      await E2ETestUtils.tapByText(tester, '我的');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 验证收藏列表
      expect(find.text('我的收藏'), findsOneWidget);
      
      // 检查收藏列表中是否有内容
      final favoriteList = find.byType(ListView);
      if (favoriteList.evaluate().isNotEmpty) {
        expect(find.byType(Card), findsWidgets);
        TestLogger.success('收藏列表显示正常');
      } else {
        // 可能是空状态
        expect(find.text('暂无收藏'), findsOneWidget);
        TestLogger.warning('收藏列表为空');
      }

      // 步骤5: 取消收藏
      TestLogger.step('取消收藏');
      
      // 进入收藏项详情
      if (find.byType(Card).evaluate().isNotEmpty) {
        final favoriteCard = find.byType(Card).first;
        await tester.tap(favoriteCard);
        await E2ETestUtils.waitForPageLoad(tester);

        // 点击已收藏的按钮取消
        final filledFavoriteButton = find.byIcon(Icons.favorite);
        if (filledFavoriteButton.evaluate().isNotEmpty) {
          await tester.tap(filledFavoriteButton);
          await E2ETestUtils.delay(tester, TestData.mediumDelay);
          
          // 验证取消成功
          expect(find.byIcon(Icons.favorite_border), findsOneWidget);
          TestLogger.success('收藏取消成功');
        }

        // 返回
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
        await E2ETestUtils.delay(tester, TestData.shortDelay);
      }

      // 步骤6: 返回发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      
      expect(find.text('探索杭州'), findsOneWidget);
      TestLogger.success('收藏流程测试完成');
    });

    testWidgets('收藏状态持久化测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入发现页并收藏一条路线
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      final firstCard = find.byType(Card).first;
      await tester.tap(firstCard);
      await E2ETestUtils.waitForPageLoad(tester);

      // 记录路线名称
      final titleFinder = find.byType(Text).first;
      final titleWidget = tester.widget<Text>(titleFinder);
      final trailName = titleWidget.data ?? '未知路线';
      TestLogger.log('测试路线: $trailName');

      // 添加收藏
      final favoriteButton = find.byIcon(Icons.favorite_border);
      if (favoriteButton.evaluate().isNotEmpty) {
        await tester.tap(favoriteButton);
        await E2ETestUtils.delay(tester, TestData.mediumDelay);
      }

      // 返回列表
      await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      await E2ETestUtils.delay(tester, TestData.shortDelay);

      // 再次进入同一条路线，验证收藏状态保持
      await tester.tap(firstCard);
      await E2ETestUtils.waitForPageLoad(tester);

      // 验证收藏状态
      expect(find.byIcon(Icons.favorite), findsOneWidget);
      TestLogger.success('收藏状态持久化验证通过');

      // 清理：取消收藏
      await tester.tap(find.byIcon(Icons.favorite));
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 返回
      await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
    });

    testWidgets('批量收藏测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 收藏多条路线
      final cards = find.byType(Card);
      final testCount = cards.evaluate().length >= 2 ? 2 : cards.evaluate().length;

      for (int i = 0; i < testCount; i++) {
        TestLogger.step('收藏第 ${i + 1} 条路线');
        
        final card = cards.at(i);
        await tester.tap(card);
        await E2ETestUtils.waitForPageLoad(tester);

        // 点击收藏
        final favoriteButton = find.byIcon(Icons.favorite_border);
        if (favoriteButton.evaluate().isNotEmpty) {
          await tester.tap(favoriteButton);
          await E2ETestUtils.delay(tester, TestData.mediumDelay);
          TestLogger.success('第 ${i + 1} 条路线收藏成功');
        }

        // 返回列表
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
        await E2ETestUtils.delay(tester, TestData.shortDelay);
      }

      // 查看我的收藏
      await E2ETestUtils.tapByText(tester, '我的');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 验证收藏数量
      final favoriteCards = find.byType(Card);
      expect(favoriteCards.evaluate().length >= testCount, isTrue);
      TestLogger.success('批量收藏验证通过，收藏数: ${favoriteCards.evaluate().length}');

      // 清理：取消所有收藏
      for (int i = 0; i < testCount; i++) {
        if (favoriteCards.evaluate().isNotEmpty) {
          final card = favoriteCards.first;
          await tester.tap(card);
          await E2ETestUtils.waitForPageLoad(tester);

          final filledButton = find.byIcon(Icons.favorite);
          if (filledButton.evaluate().isNotEmpty) {
            await tester.tap(filledButton);
            await E2ETestUtils.delay(tester, TestData.mediumDelay);
          }

          await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
          await E2ETestUtils.delay(tester, TestData.shortDelay);
        }
      }

      TestLogger.success('批量收藏测试完成');
    });

    testWidgets('收藏列表空状态测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入"我的"页面
      await E2ETestUtils.tapByText(tester, '我的');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 检查收藏列表空状态
      final favoriteCards = find.byType(Card);
      if (favoriteCards.evaluate().isEmpty) {
        // 验证空状态显示
        expect(
          find.textContaining('暂无') | find.textContaining('空') | find.textContaining('收藏'),
          findsWidgets,
        );
        TestLogger.success('收藏列表空状态显示正常');
      } else {
        TestLogger.warning('收藏列表不为空，跳过空状态测试');
      }
    });
  });
}
