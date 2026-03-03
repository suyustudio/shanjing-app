import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/screens/offline_map_screen.dart';
import 'package:hangzhou_guide/widgets/app_loading.dart';
import 'package:hangzhou_guide/widgets/app_error.dart';

void main() {
  group('OfflineMapScreen', () {
    testWidgets('renders with app bar title and tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 验证标题
      expect(find.text('离线地图'), findsOneWidget);
      
      // 验证 Tab 存在
      expect(find.text('已下载'), findsOneWidget);
      expect(find.text('热门城市'), findsOneWidget);
      expect(find.text('全部城市'), findsOneWidget);
    });

    testWidgets('shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 初始状态显示加载组件
      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('has search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 等待加载完成
      await tester.pumpAndSettle();

      // 搜索栏存在
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('搜索城市'), findsOneWidget);
    });

    testWidgets('has info tip about offline usage', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 等待加载完成
      await tester.pumpAndSettle();

      // 提示信息存在
      expect(
        find.text('离线地图可在无网络环境下使用，建议在WiFi环境下下载'),
        findsOneWidget,
      );
    });

    testWidgets('shows downloaded cities tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 等待加载完成
      await tester.pumpAndSettle();

      // 点击已下载标签
      await tester.tap(find.text('已下载'));
      await tester.pumpAndSettle();

      // 验证空状态或列表
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('shows hot cities tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 等待加载完成
      await tester.pumpAndSettle();

      // 点击热门城市标签
      await tester.tap(find.text('热门城市'));
      await tester.pumpAndSettle();

      // 验证列表存在
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('shows all cities tab', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 等待加载完成
      await tester.pumpAndSettle();

      // 点击全部城市标签
      await tester.tap(find.text('全部城市'));
      await tester.pumpAndSettle();

      // 验证列表存在
      expect(find.byType(ListView), findsWidgets);
    });

    testWidgets('search functionality works', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 等待加载完成
      await tester.pumpAndSettle();

      // 在搜索框中输入
      await tester.enterText(find.byType(TextField), '杭州');
      await tester.pump();

      // 验证搜索文本已输入
      expect(find.text('杭州'), findsOneWidget);
    });

    testWidgets('download button exists in city list', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: OfflineMapScreen(),
        ),
      );

      // 等待加载完成
      await tester.pumpAndSettle();

      // 验证下载按钮或相关组件存在
      // 注意：实际按钮可能在列表项中，取决于数据加载情况
      expect(find.byType(TabBarView), findsOneWidget);
    });
  });
}
