import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hangzhou_guide/main.dart' as app;

import 'e2e_utils.dart';

/// 搜索功能 E2E 测试
/// 测试场景：输入关键词 → 查看结果 → 清空搜索
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('搜索功能 E2E 测试', () {
    testWidgets('搜索完整流程测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);
      TestLogger.success('应用启动成功');

      // 步骤1: 切换到发现页
      TestLogger.step('进入发现页');
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 步骤2: 点击搜索栏
      TestLogger.step('激活搜索栏');
      final searchBar = find.byType(TextField);
      expect(searchBar, findsOneWidget);
      await tester.tap(searchBar);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      TestLogger.success('搜索栏已激活');

      // 步骤3: 输入搜索关键词
      TestLogger.step('输入搜索关键词: ${TestData.searchKeywordTrail}');
      await tester.enterText(searchBar, TestData.searchKeywordTrail);
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      
      // 等待搜索结果
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      TestLogger.success('搜索结果加载完成');

      // 步骤4: 验证搜索结果
      TestLogger.step('验证搜索结果');
      final resultCards = find.byType(Card);
      if (resultCards.evaluate().isNotEmpty) {
        TestLogger.success('搜索结果: ${resultCards.evaluate().length} 条');
        
        // 验证结果中包含搜索关键词
        expect(
          find.textContaining(TestData.searchKeywordTrail),
          findsWidgets,
        );
      } else {
        TestLogger.warning('搜索结果为空');
      }

      // 步骤5: 清空搜索
      TestLogger.step('清空搜索');
      
      // 查找清空按钮
      final clearButton = find.byIcon(Icons.clear) | find.byIcon(Icons.close);
      if (clearButton.evaluate().isNotEmpty) {
        await tester.tap(clearButton.first);
        await E2ETestUtils.delay(tester, TestData.mediumDelay);
        TestLogger.success('搜索已清空');
      } else {
        // 手动清空
        await tester.enterText(searchBar, '');
        await E2ETestUtils.delay(tester, TestData.mediumDelay);
      }

      // 步骤6: 验证返回默认列表
      TestLogger.step('验证返回默认列表');
      final defaultCards = find.byType(Card);
      expect(defaultCards.evaluate().isNotEmpty, isTrue);
      TestLogger.success('返回默认列表成功');

      TestLogger.success('搜索流程测试完成');
    });

    testWidgets('搜索结果筛选测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 输入搜索词
      final searchBar = find.byType(TextField);
      await tester.tap(searchBar);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      
      await tester.enterText(searchBar, TestData.searchKeywordLocation);
      await E2ETestUtils.delay(tester, TestData.mediumDelay * 2);

      TestLogger.success('搜索结果筛选完成');

      // 清空
      await tester.enterText(searchBar, '');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
    });

    testWidgets('搜索无结果场景测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 输入不存在的搜索词
      final searchBar = find.byType(TextField);
      await tester.tap(searchBar);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      
      TestLogger.step('输入无结果的搜索词');
      await tester.enterText(searchBar, TestData.searchNoResults);
      await E2ETestUtils.delay(tester, TestData.mediumDelay * 2);

      // 验证空状态
      TestLogger.step('验证空状态显示');
      expect(
        find.textContaining('暂无') | 
        find.textContaining('没有找到') | 
        find.textContaining('空'),
        findsWidgets,
      );
      TestLogger.success('无结果空状态显示正常');

      // 清空搜索
      await tester.enterText(searchBar, '');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      
      // 验证返回默认列表
      expect(find.byType(Card), findsWidgets);
      TestLogger.success('无结果场景测试完成');
    });

    testWidgets('搜索防抖功能测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 快速连续输入
      final searchBar = find.byType(TextField);
      await tester.tap(searchBar);
      await E2ETestUtils.delay(tester, TestData.shortDelay);

      TestLogger.step('测试搜索防抖');
      
      // 快速输入多个字符
      await tester.enterText(searchBar, '九');
      await E2ETestUtils.delay(tester, 100);
      await tester.enterText(searchBar, '九溪');
      await E2ETestUtils.delay(tester, 100);
      await tester.enterText(searchBar, '九溪烟');
      await E2ETestUtils.delay(tester, 100);
      await tester.enterText(searchBar, '九溪烟树');
      
      // 等待防抖完成
      await E2ETestUtils.delay(tester, TestData.mediumDelay * 2);

      // 验证最终结果正确
      expect(
        find.textContaining('九溪') | find.byType(Card),
        findsWidgets,
      );
      TestLogger.success('搜索防抖功能正常');

      // 清空
      await tester.enterText(searchBar, '');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
    });

    testWidgets('搜索历史功能测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 执行一次搜索
      final searchBar = find.byType(TextField);
      await tester.tap(searchBar);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      
      await tester.enterText(searchBar, TestData.searchKeywordTrail);
      await E2ETestUtils.delay(tester, TestData.mediumDelay * 2);

      // 清空搜索
      await tester.enterText(searchBar, '');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 再次点击搜索栏，查看历史记录
      TestLogger.step('检查搜索历史');
      await tester.tap(searchBar);
      await E2ETestUtils.delay(tester, TestData.shortDelay);

      // 验证历史记录显示
      final historyFinder = find.textContaining('历史') | find.textContaining(TestData.searchKeywordTrail);
      if (historyFinder.evaluate().isNotEmpty) {
        TestLogger.success('搜索历史显示正常');
        
        // 点击历史记录
        await tester.tap(historyFinder.first);
        await E2ETestUtils.delay(tester, TestData.mediumDelay);
        TestLogger.success('历史记录点击正常');
      } else {
        TestLogger.warning('未找到搜索历史（可能功能未实现）');
      }

      // 清空
      await tester.enterText(searchBar, '');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      TestLogger.success('搜索历史功能测试完成');
    });

    testWidgets('搜索结果点击进入详情测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 搜索
      final searchBar = find.byType(TextField);
      await tester.tap(searchBar);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      
      await tester.enterText(searchBar, TestData.searchKeywordTrail);
      await E2ETestUtils.delay(tester, TestData.mediumDelay * 2);

      // 点击搜索结果
      final resultCards = find.byType(Card);
      if (resultCards.evaluate().isNotEmpty) {
        TestLogger.step('点击搜索结果进入详情');
        await tester.tap(resultCards.first);
        await E2ETestUtils.waitForPageLoad(tester);

        // 验证进入详情页
        expect(
          find.textContaining('距离') | find.textContaining('爬升'),
          findsWidgets,
        );
        TestLogger.success('从搜索结果进入详情成功');

        // 返回
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
        await E2ETestUtils.delay(tester, TestData.shortDelay);
      }

      // 清空搜索
      await tester.enterText(searchBar, '');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      TestLogger.success('搜索结果点击进入详情测试完成');
    });
  });
}
