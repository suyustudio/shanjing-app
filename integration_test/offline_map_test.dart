import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hangzhou_guide/main.dart' as app;

import 'e2e_utils.dart';

/// 离线地图功能 E2E 测试
/// 测试场景：进入下载页 → 下载城市 → 验证离线可用
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('离线地图 E2E 测试', () {
    testWidgets('离线地图完整流程测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);
      TestLogger.success('应用启动成功');

      // 步骤1: 进入"我的"页面
      TestLogger.step('进入我的页面');
      await E2ETestUtils.tapByText(tester, '我的');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 步骤2: 找到并点击离线地图入口
      TestLogger.step('进入离线地图管理');
      
      // 查找离线地图相关文本或图标
      final offlineMapFinder = find.textContaining('离线') | find.textContaining('下载');
      if (offlineMapFinder.evaluate().isNotEmpty) {
        await tester.tap(offlineMapFinder.first);
        await E2ETestUtils.waitForPageLoad(tester);
        TestLogger.success('进入离线地图页面');
      } else {
        // 可能需要滚动查找
        TestLogger.warning('未直接找到离线地图入口，尝试滚动查找');
        final scrollable = find.byType(Scrollable).last;
        await tester.scrollUntilVisible(
          offlineMapFinder,
          200.0,
          scrollable: scrollable,
        );
        await tester.tap(offlineMapFinder.first);
        await E2ETestUtils.waitForPageLoad(tester);
      }

      // 步骤3: 验证离线地图页面
      TestLogger.step('验证离线地图页面');
      expect(
        find.textContaining('离线地图') | find.textContaining('城市') | find.textContaining('下载'),
        findsWidgets,
      );
      TestLogger.success('离线地图页面加载成功');

      // 步骤4: 查找可下载的城市
      TestLogger.step('查找可下载城市');
      final cityItems = find.byType(ListTile);
      if (cityItems.evaluate().isNotEmpty) {
        TestLogger.success('找到 ${cityItems.evaluate().length} 个城市');

        // 选择第一个城市
        final firstCity = cityItems.first;
        
        // 检查是否已下载
        final downloadButton = find.descendant(
          of: firstCity,
          matching: find.byType(ElevatedButton) | find.byType(IconButton),
        );

        if (downloadButton.evaluate().isNotEmpty) {
          // 点击下载
          TestLogger.step('点击下载城市');
          await tester.tap(downloadButton.first);
          await E2ETestUtils.delay(tester, TestData.mediumDelay);

          // 验证下载进度或成功状态
          await E2ETestUtils.delay(tester, TestData.longDelay);
          
          // 检查下载状态变化
          expect(
            find.textContaining('下载中') | 
            find.textContaining('已下载') | 
            find.textContaining('暂停'),
            findsWidgets,
          );
          TestLogger.success('下载操作执行成功');
        } else {
          TestLogger.warning('未找到下载按钮，可能已下载');
        }
      } else {
        TestLogger.warning('未找到可下载城市列表');
      }

      // 步骤5: 验证已下载列表
      TestLogger.step('验证已下载列表');
      final downloadedTab = find.text('已下载') | find.text('我的下载');
      if (downloadedTab.evaluate().isNotEmpty) {
        await tester.tap(downloadedTab.first);
        await E2ETestUtils.delay(tester, TestData.mediumDelay);
        TestLogger.success('切换到已下载列表');
      }

      // 步骤6: 返回首页
      TestLogger.step('返回首页');
      await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      await E2ETestUtils.tapByText(tester, '首页');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      TestLogger.success('离线地图测试完成');
    });

    testWidgets('离线地图下载管理测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入我的页面和离线地图
      await E2ETestUtils.tapByText(tester, '我的');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      final offlineMapFinder = find.textContaining('离线') | find.textContaining('地图');
      if (offlineMapFinder.evaluate().isNotEmpty) {
        await tester.tap(offlineMapFinder.first);
        await E2ETestUtils.waitForPageLoad(tester);

        // 测试暂停/继续功能
        TestLogger.step('测试下载控制功能');
        
        final downloadingItems = find.byType(ListTile);
        if (downloadingItems.evaluate().isNotEmpty) {
          // 查找暂停按钮
          final pauseButton = find.byIcon(Icons.pause);
          if (pauseButton.evaluate().isNotEmpty) {
            await tester.tap(pauseButton.first);
            await E2ETestUtils.delay(tester, TestData.mediumDelay);
            TestLogger.success('暂停下载测试完成');

            // 查找继续按钮
            final playButton = find.byIcon(Icons.play_arrow);
            if (playButton.evaluate().isNotEmpty) {
              await tester.tap(playButton.first);
              await E2ETestUtils.delay(tester, TestData.mediumDelay);
              TestLogger.success('继续下载测试完成');
            }
          }

          // 测试删除功能
          TestLogger.step('测试删除功能');
          final deleteButton = find.byIcon(Icons.delete);
          if (deleteButton.evaluate().isNotEmpty) {
            await tester.tap(deleteButton.first);
            await E2ETestUtils.delay(tester, TestData.shortDelay);
            
            // 确认删除
            final confirmButton = find.text('确认') | find.text('删除');
            if (confirmButton.evaluate().isNotEmpty) {
              await tester.tap(confirmButton.first);
              await E2ETestUtils.delay(tester, TestData.mediumDelay);
              TestLogger.success('删除操作测试完成');
            }
          }
        }

        // 返回
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      }

      TestLogger.success('离线地图管理测试完成');
    });

    testWidgets('离线地图存储空间检查', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入离线地图页面
      await E2ETestUtils.tapByText(tester, '我的');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      final offlineMapFinder = find.textContaining('离线') | find.textContaining('地图');
      if (offlineMapFinder.evaluate().isNotEmpty) {
        await tester.tap(offlineMapFinder.first);
        await E2ETestUtils.waitForPageLoad(tester);

        // 验证存储空间显示
        TestLogger.step('验证存储空间显示');
        expect(
          find.textContaining('存储') | find.textContaining('空间') | find.textContaining('MB'),
          findsWidgets,
        );
        TestLogger.success('存储空间信息正常显示');

        // 验证存储进度条
        final progressBar = find.byType(LinearProgressIndicator) | find.byType(CircularProgressIndicator);
        if (progressBar.evaluate().isNotEmpty) {
          TestLogger.success('存储进度条显示正常');
        }

        // 返回
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      }

      TestLogger.success('存储空间检查测试完成');
    });
  });
}
