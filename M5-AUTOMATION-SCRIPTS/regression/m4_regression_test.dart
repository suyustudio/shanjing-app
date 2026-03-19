// M5 - M4功能回归测试套件
// 确保M5升级不影响M4功能

import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shanjing_app/main.dart' as app;
import '../utils/test_helpers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('M4功能回归测试套件', () {
    
    setUp(() async {
      // 加载M4测试数据
      await TestHelpers.loadM4TestData();
    });

    // TC-RG-001: 用户登录回归
    testWidgets('微信登录功能正常', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 点击微信登录
      await tester.tap(find.text('微信登录'));
      await tester.pumpAndSettle();
      
      // 模拟登录成功
      await TestHelpers.simulateWechatLoginSuccess();
      await tester.pumpAndSettle();
      
      // 验证登录成功
      expect(find.text('个人中心'), findsOneWidget);
      expect(find.byType(UserAvatar), findsOneWidget);
    });

    // TC-RG-002: 路线发现回归
    testWidgets('路线发现功能正常', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 验证发现页
      expect(find.text('发现'), findsOneWidget);
      expect(find.byType(TrailList), findsOneWidget);
      
      // 测试筛选
      await tester.tap(find.text('难度'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('简单'));
      await tester.pumpAndSettle();
      
      // 验证筛选结果
      expect(find.byType(TrailCard), findsWidgets);
    });

    // TC-RG-003: 导航功能回归
    testWidgets('导航功能正常', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入路线详情
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      // 开始导航
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();
      
      // 验证导航页
      expect(find.byType(NavigationScreen), findsOneWidget);
      expect(find.byType(MapView), findsOneWidget);
      
      // 验证定位
      expect(find.byType(LocationIndicator), findsOneWidget);
    });

    // TC-RG-004: 路线详情回归
    testWidgets('路线详情页正常', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      // 验证详情页元素
      expect(find.byType(ElevationChart), findsOneWidget);
      expect(find.byType(POIList), findsOneWidget);
      expect(find.text('收藏'), findsOneWidget);
      expect(find.text('分享'), findsOneWidget);
    });

    // TC-RG-005: 离线地图回归
    testWidgets('离线地图功能正常', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入离线地图管理
      await tester.tap(find.byIcon(Icons.download));
      await tester.pumpAndSettle();
      
      // 验证离线地图列表
      expect(find.byType(OfflineMapList), findsOneWidget);
      
      // 测试下载
      await tester.tap(find.text('下载').first);
      await tester.pumpAndSettle();
      
      // 验证下载状态
      expect(find.byType(DownloadProgress), findsOneWidget);
    });

    // TC-RG-006: SOS功能回归
    testWidgets('SOS功能正常', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 触发SOS
      await TestHelpers.triggerSOS();
      await tester.pumpAndSettle();
      
      // 验证SOS弹窗
      expect(find.text('紧急求助'), findsOneWidget);
      expect(find.text('倒计时'), findsOneWidget);
      
      // 取消SOS
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      
      // 验证取消成功
      expect(find.text('紧急求助'), findsNothing);
    });

    // TC-RG-007: 分享功能回归
    testWidgets('分享功能正常', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      // 点击分享
      await tester.tap(find.text('分享'));
      await tester.pumpAndSettle();
      
      // 验证分享面板
      expect(find.byType(ShareSheet), findsOneWidget);
      expect(find.text('微信'), findsOneWidget);
      expect(find.text('保存图片'), findsOneWidget);
    });

    // TC-RG-008: 个人中心回归
    testWidgets('个人中心功能正常', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 进入个人中心
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      
      // 验证统计信息
      expect(find.text('累计里程'), findsOneWidget);
      expect(find.text('徒步次数'), findsOneWidget);
      
      // 验证设置入口
      expect(find.byIcon(Icons.settings), findsOneWidget);
    });

    // TC-RG-009: 暗黑模式回归
    testWidgets('暗黑模式适配正常', (WidgetTester tester) async {
      // 设置暗黑模式
      await TestHelpers.setDarkMode(true);
      
      app.main();
      await tester.pumpAndSettle();
      
      // 验证各页面
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, isDarkColor);
    });

    // TC-RG-013: 数据兼容性
    testWidgets('M4数据兼容性', (WidgetTester tester) async {
      // 模拟M4数据
      await TestHelpers.loadM4UserData();
      
      app.main();
      await tester.pumpAndSettle();
      
      // 验证M4数据保留
      final userStats = await TestHelpers.getUserStats();
      expect(userStats.totalDistance, greaterThan(0));
      expect(userStats.completedTrails, isNotEmpty);
      
      // 验证收藏保留
      final favorites = await TestHelpers.getFavorites();
      expect(favorites, isNotEmpty);
    });

    // TC-RG-014: 升级流程
    testWidgets('M4升级M5流程正常', (WidgetTester tester) async {
      // 模拟M4已安装
      await TestHelpers.simulateM4Installed();
      
      // 启动M5
      app.main();
      await tester.pumpAndSettle();
      
      // 验证升级提示
      expect(find.text('已更新至最新版本'), findsOneWidget);
      
      // 验证功能正常
      expect(find.text('发现'), findsOneWidget);
    });

    // 综合回归测试
    testWidgets('核心流程回归', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // 1. 登录
      await tester.tap(find.text('微信登录'));
      await TestHelpers.simulateWechatLoginSuccess();
      await tester.pumpAndSettle();
      
      // 2. 浏览路线
      expect(find.byType(TrailList), findsOneWidget);
      
      // 3. 查看详情
      await tester.tap(find.byType(TrailCard).first);
      await tester.pumpAndSettle();
      
      // 4. 收藏
      await tester.tap(find.text('收藏'));
      await tester.pumpAndSettle();
      
      // 5. 分享
      await tester.tap(find.text('分享'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('取消'));
      await tester.pumpAndSettle();
      
      // 6. 开始导航
      await tester.tap(find.text('开始导航'));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationScreen), findsOneWidget);
      
      // 7. 结束导航
      await tester.tap(find.text('结束'));
      await tester.pumpAndSettle();
      
      // 8. 验证回到详情
      expect(find.byType(TrailDetailScreen), findsOneWidget);
    }, timeout: const Timeout(Duration(minutes: 3)));
  });
}
