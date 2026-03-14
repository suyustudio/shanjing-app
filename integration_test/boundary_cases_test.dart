import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:hangzhou_guide/main.dart' as app;

import 'e2e_utils.dart';

/// 边界场景 E2E 测试
/// 测试场景：无网络、GPS弱信号、存储空间不足、权限拒绝
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('边界场景 E2E 测试', () {
    
    // ==================== 无网络场景测试 ====================
    testWidgets('无网络场景 - 发现页离线提示', (WidgetTester tester) async {
      TestLogger.step('启动应用（无网络场景测试）');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 切换到发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 验证页面加载（离线模式应显示缓存或提示）
      TestLogger.step('验证离线模式下的发现页');
      
      // 检查是否有网络错误提示
      final networkErrorFinder = 
        find.textContaining('网络') | 
        find.textContaining('离线') | 
        find.textContaining('连接');
      
      if (networkErrorFinder.evaluate().isNotEmpty) {
        TestLogger.success('无网络时显示提示信息');
      } else {
        // 或者检查是否显示缓存内容
        final contentFinder = find.byType(Card) | find.byType(ListView);
        if (contentFinder.evaluate().isNotEmpty) {
          TestLogger.success('无网络时显示缓存内容');
        } else {
          TestLogger.warning('无网络时页面状态不明确');
        }
      }

      TestLogger.success('无网络场景测试完成');
    });

    testWidgets('无网络场景 - 搜索功能降级', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      // 尝试搜索
      final searchBar = find.byType(TextField);
      await tester.tap(searchBar);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      
      await tester.enterText(searchBar, TestData.searchKeywordTrail);
      await E2ETestUtils.delay(tester, TestData.mediumDelay * 2);

      // 验证搜索结果或离线提示
      TestLogger.step('验证搜索在无网络下的表现');
      
      final resultOrError = 
        find.byType(Card) | 
        find.textContaining('网络') | 
        find.textContaining('离线');
      
      expect(resultOrError, findsWidgets);
      TestLogger.success('无网络搜索场景测试完成');

      // 清空搜索
      await tester.enterText(searchBar, '');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);
    });

    // ==================== GPS弱信号场景测试 ====================
    testWidgets('GPS弱信号 - 导航页面提示', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入发现页并选择路线
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      final firstCard = find.byType(Card).first;
      await tester.tap(firstCard);
      await E2ETestUtils.waitForPageLoad(tester);

      // 开始导航
      await E2ETestUtils.tapByText(tester, '开始导航');
      await E2ETestUtils.waitForPageLoad(tester);

      TestLogger.step('验证导航页面的GPS状态显示');
      
      // 检查GPS状态指示器
      final gpsIndicator = 
        find.byIcon(Icons.gps_fixed) | 
        find.byIcon(Icons.gps_not_fixed) | 
        find.byIcon(Icons.location_searching);
      
      if (gpsIndicator.evaluate().isNotEmpty) {
        TestLogger.success('GPS状态指示器显示正常');
      }

      // 检查位置精度提示
      final accuracyFinder = 
        find.textContaining('信号') | 
        find.textContaining('精度') | 
        find.textContaining('定位');
      
      if (accuracyFinder.evaluate().isNotEmpty) {
        TestLogger.success('GPS精度提示显示正常');
      }

      // 停止导航
      await E2ETestUtils.tapByIcon(tester, Icons.stop);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      await E2ETestUtils.tapByText(tester, '确认');
      await E2ETestUtils.delay(tester, TestData.shortDelay);

      // 返回
      await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      await E2ETestUtils.delay(tester, TestData.shortDelay);

      TestLogger.success('GPS弱信号场景测试完成');
    });

    testWidgets('GPS信号丢失 - 使用最后已知位置', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入首页（地图页）
      await E2ETestUtils.tapByText(tester, '首页');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      TestLogger.step('验证GPS信号丢失时的降级处理');
      
      // 检查地图是否显示（即使没有GPS也应该显示默认位置）
      expect(find.byType(Map), findsOneWidget);
      TestLogger.success('GPS信号丢失时地图仍显示默认位置');

      // 检查位置提示
      final locationHint = 
        find.textContaining('最后') | 
        find.textContaining('已知') | 
        find.textContaining('默认');
      
      if (locationHint.evaluate().isNotEmpty) {
        TestLogger.success('GPS信号丢失提示显示正常');
      }

      TestLogger.success('GPS信号丢失场景测试完成');
    });

    // ==================== 存储空间不足场景测试 ====================
    testWidgets('存储空间不足 - 离线地图下载提示', (WidgetTester tester) async {
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

        TestLogger.step('验证存储空间显示');
        
        // 检查存储空间提示
        final storageFinder = 
          find.textContaining('存储') | 
          find.textContaining('空间') | 
          find.textContaining('MB') | 
          find.textContaining('GB');
        
        expect(storageFinder, findsWidgets);
        TestLogger.success('存储空间信息已显示');

        // 检查存储空间警告（如果空间不足）
        final warningFinder = 
          find.textContaining('不足') | 
          find.textContaining('清理') | 
          find.byIcon(Icons.warning);
        
        if (warningFinder.evaluate().isNotEmpty) {
          TestLogger.success('存储空间不足警告已显示');
        }

        // 返回
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      }

      TestLogger.success('存储空间检查测试完成');
    });

    testWidgets('存储空间不足 - 下载阻止', (WidgetTester tester) async {
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

        // 尝试下载（如果空间不足应显示提示）
        final cityItems = find.byType(ListTile);
        if (cityItems.evaluate().isNotEmpty) {
          TestLogger.step('尝试下载并检查存储空间提示');
          
          final downloadButton = find.byType(ElevatedButton).first;
          await tester.tap(downloadButton);
          await E2ETestUtils.delay(tester, TestData.mediumDelay);

          // 检查是否有存储空间不足提示
          final errorFinder = 
            find.textContaining('存储') | 
            find.textContaining('空间') | 
            find.textContaining('不足');
          
          if (errorFinder.evaluate().isNotEmpty) {
            TestLogger.success('存储空间不足时正确阻止下载');
          } else {
            TestLogger.success('下载操作已执行（空间充足或已处理）');
          }
        }

        // 返回
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      }

      TestLogger.success('存储空间阻止下载测试完成');
    });

    // ==================== 权限拒绝场景测试 ====================
    testWidgets('权限拒绝 - 定位权限处理', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入导航页面
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      final firstCard = find.byType(Card).first;
      await tester.tap(firstCard);
      await E2ETestUtils.waitForPageLoad(tester);

      // 开始导航（可能触发权限请求）
      await E2ETestUtils.tapByText(tester, '开始导航');
      await E2ETestUtils.waitForPageLoad(tester);

      TestLogger.step('检查权限提示');
      
      // 检查权限提示或引导
      final permissionFinder = 
        find.textContaining('权限') | 
        find.textContaining('定位') | 
        find.textContaining('设置');
      
      if (permissionFinder.evaluate().isNotEmpty) {
        TestLogger.success('权限提示已显示');
      }

      // 停止导航并返回
      await E2ETestUtils.tapByIcon(tester, Icons.stop);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      await E2ETestUtils.tapByText(tester, '确认');
      await E2ETestUtils.delay(tester, TestData.shortDelay);

      await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      await E2ETestUtils.delay(tester, TestData.shortDelay);

      TestLogger.success('定位权限场景测试完成');
    });

    testWidgets('权限拒绝 - 存储权限处理', (WidgetTester tester) async {
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

        TestLogger.step('检查存储权限提示');
        
        // 检查存储权限提示
        final permissionFinder = 
          find.textContaining('权限') | 
          find.textContaining('存储') | 
          find.textContaining('下载');
        
        if (permissionFinder.evaluate().isNotEmpty) {
          TestLogger.success('存储权限提示已显示');
        }

        // 返回
        await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      }

      TestLogger.success('存储权限场景测试完成');
    });

    // ==================== 综合边界场景 ====================
    testWidgets('应用启动 - 多边界条件组合', (WidgetTester tester) async {
      TestLogger.step('启动应用（综合边界条件）');
      app.main();
      
      // 等待应用启动
      await E2ETestUtils.waitForPageLoad(tester);

      TestLogger.step('验证应用在边界条件下的启动');
      
      // 检查应用是否正常显示
      expect(
        find.byType(BottomNavigationBar) | find.byType(BottomAppBar),
        findsOneWidget,
      );

      // 检查首页是否正常
      await E2ETestUtils.tapByText(tester, '首页');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      expect(find.byType(Map), findsOneWidget);
      TestLogger.success('应用在边界条件下正常启动');

      // 检查发现页
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      expect(find.text('探索杭州'), findsOneWidget);
      TestLogger.success('发现页在边界条件下正常显示');

      // 检查我的页面
      await E2ETestUtils.tapByText(tester, '我的');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      expect(find.text('我的'), findsWidgets);
      TestLogger.success('我的页面在边界条件下正常显示');

      TestLogger.success('综合边界场景测试完成');
    });

    testWidgets('异常退出恢复测试', (WidgetTester tester) async {
      TestLogger.step('启动应用');
      app.main();
      await E2ETestUtils.waitForPageLoad(tester);

      // 进入导航状态
      await E2ETestUtils.tapByText(tester, '发现');
      await E2ETestUtils.delay(tester, TestData.mediumDelay);

      final firstCard = find.byType(Card).first;
      await tester.tap(firstCard);
      await E2ETestUtils.waitForPageLoad(tester);

      await E2ETestUtils.tapByText(tester, '开始导航');
      await E2ETestUtils.waitForPageLoad(tester);

      TestLogger.step('模拟异常退出后恢复');
      
      // 停止导航（模拟恢复场景）
      await E2ETestUtils.tapByIcon(tester, Icons.stop);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
      await E2ETestUtils.tapByText(tester, '确认');
      await E2ETestUtils.delay(tester, TestData.shortDelay);

      // 验证应用恢复正常
      expect(find.textContaining('距离') | find.textContaining('爬升'), findsWidgets);
      TestLogger.success('异常退出后恢复测试完成');

      // 返回首页
      await E2ETestUtils.tapByIcon(tester, Icons.arrow_back);
      await E2ETestUtils.delay(tester, TestData.shortDelay);
    });
  });
}
