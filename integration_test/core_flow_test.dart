import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hangzhou_guide/main.dart' as app;

import 'e2e_utils.dart';

/// 核心流程 E2E 测试
/// 测试场景：发现页 → 路线列表 → 路线详情 → 开始导航（完整流程）
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('核心流程 E2E 测试', () {
    testWidgets('完整导航流程测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);
      TestLogger.success('应用启动成功');

      // 步骤1: 切换到发现页
      TestLogger.step('切换到发现页');
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      
      // 验证发现页加载
      expect(find.text('探索杭州'), findsOneWidget);
      TestLogger.success('发现页加载成功');

      // 步骤2: 验证路线列表显示
      TestLogger.step('验证路线列表');
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(Card), findsWidgets);
      TestLogger.success('路线列表显示正常');

      // 步骤3: 点击第一条路线进入详情
      TestLogger.step('进入路线详情');
      final firstTrailCard = find.byType(Card).first;
      expect(firstTrailCard, findsOneWidget);
      await tester.tap(firstTrailCard);
      await E2ETestUtils.waitForPageLoad(tester);
      TestLogger.success('进入路线详情页');

      // 步骤4: 验证详情页内容
      TestLogger.step('验证详情页内容');
      
      // 检查基础信息
      expect(find.text('距离'), findsOneWidget);
      expect(find.text('爬升'), findsOneWidget);
      expect(find.text('难度'), findsOneWidget);
      TestLogger.success('详情页基础信息完整');

      // 检查 Tab 导航
      expect(find.text('简介'), findsOneWidget);
      expect(find.text('轨迹'), findsOneWidget);
      expect(find.text('评价'), findsOneWidget);
      TestLogger.success('详情页 Tab 导航完整');

      // 步骤5: 点击开始导航
      TestLogger.step('开始导航');
      await E2ETestUtils.tapByText(tester, '开始导航');
      await E2ETestUtils.waitForPageLoad(tester);
      TestLogger.success('进入导航页面');

      // 步骤6: 验证导航页面
      TestLogger.step('验证导航页面');
      expect(find.byType(Map), findsOneWidget);
      TestLogger.success('导航地图显示正常');

      // 步骤7: 停止导航并返回
      TestLogger.step('停止导航');
      await E2ETestUtils.tapByIcon(tester, Icons.stop);
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      
      // 确认停止
      await E2ETestUtils.tapByText(tester, '确认');
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      TestLogger.success('导航已停止');

      // 步骤8: 返回发现页
      TestLogger.step('返回发现页');
      await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      
      expect(find.text('探索杭州'), findsOneWidget);
      TestLogger.success('返回发现页成功');
    });

    testWidgets('路线详情 Tab 切换测试', (WidgetTester tester) async {
      TestLogger.step('启动应用并进入发现页');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);
      
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 进入路线详情
      final firstTrailCard = find.byType(Card).first;
      await tester.tap(firstTrailCard);
      await E2ETestUtils.waitForPageLoad(tester);

      // 测试 Tab 切换
      TestLogger.step('测试 Tab 切换 - 轨迹');
      await E2ETestUtils.tapByText(tester, '轨迹');
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      expect(find.textContaining('轨迹概览'), findsWidgets);
      TestLogger.success('轨迹 Tab 切换成功');

      TestLogger.step('测试 Tab 切换 - 评价');
      await E2ETestUtils.tapByText(tester, '评价');
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      expect(find.textContaining('评分'), findsWidgets);
      TestLogger.success('评价 Tab 切换成功');

      TestLogger.step('测试 Tab 切换 - 攻略');
      await E2ETestUtils.tapByText(tester, '攻略');
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      expect(find.textContaining('最佳徒步时间'), findsWidgets);
      TestLogger.success('攻略 Tab 切换成功');

      // 返回简介 Tab
      await E2ETestUtils.tapByText(tester, '简介');
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      TestLogger.success('Tab 切换测试完成');
    });

    testWidgets('路线筛选功能测试', (WidgetTester tester) async {
      TestLogger.step('启动应用并进入发现页');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);
      
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 测试筛选标签
      TestLogger.step('测试筛选功能');
      
      // 点击难度筛选
      await E2ETestUtils.tapByText(tester, '简单');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      TestLogger.success('筛选标签点击成功');

      // 验证筛选后列表
      expect(find.byType(ListView), findsOneWidget);
      TestLogger.success('筛选后列表显示正常');

      // 清除筛选
      await E2ETestUtils.tapByText(tester, '全部');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
      TestLogger.success('清除筛选成功');
    });

    testWidgets('不同路线进入导航测试', (WidgetTester tester) async {
      TestLogger.step('启动应用并进入发现页');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);
      
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 测试多条路线的导航
      final cards = find.byType(Card);
      final cardCount = cards.evaluate().length;
      
      if (cardCount >= 2) {
        // 测试第二条路线
        TestLogger.step('测试第二条路线导航');
        final secondCard = cards.at(1);
        await tester.tap(secondCard);
        await E2ETestUtils.waitForPageLoad(tester);

        await E2ETestUtils.tapByText(tester, '开始导航');
        await E2ETestUtils.waitForPageLoad(tester);
        
        expect(find.byType(Map), findsOneWidget);
        TestLogger.success('第二条路线导航正常');

        // 返回
        await E2ETestUtils.tapByIcon(tester, Icons.stop);
        await E2ETestUtils.delay(tester, TestData.shortDelay);
        await E2ETestUtils.tapByText(tester, '确认');
        await E2ETestUtils.delay(tester, TestData.shortDelay);
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
        await E2ETestUtils.delay(tester, TestData.shortDelay);
        await E2ETestUtils.tapByText(tester, '发现');
      }
      
      TestLogger.success('多条路线导航测试完成');
    });
  });
}
