import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/widgets/app_button.dart';
import 'package:hangzhou_guide/widgets/app_card.dart';
import 'package:hangzhou_guide/widgets/app_input.dart';
import 'package:hangzhou_guide/widgets/app_app_bar.dart';
import 'package:hangzhou_guide/widgets/app_loading.dart';
import 'package:hangzhou_guide/widgets/app_error.dart';
import 'package:hangzhou_guide/widgets/app_shimmer.dart';
import 'package:hangzhou_guide/widgets/route_card.dart';
import 'package:hangzhou_guide/widgets/search_bar.dart';
import 'package:hangzhou_guide/widgets/filter_tags.dart';
import 'package:hangzhou_guide/constants/design_system.dart';

void main() {
  group('暗黑模式适配测试', () {
    
    // 测试 AppButton 暗黑模式
    testWidgets('AppButton 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: Center(
              child: Column(
                children: [
                  AppButton(
                    label: '主按钮',
                    onPressed: () {},
                  ),
                  const AppButton.secondary(
                    label: '次按钮',
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('主按钮'), findsOneWidget);
      expect(find.text('次按钮'), findsOneWidget);
    });

    // 测试 AppCard 暗黑模式
    testWidgets('AppCard 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: AppCard(
              child: Text('卡片内容'),
            ),
          ),
        ),
      );

      expect(find.text('卡片内容'), findsOneWidget);
    });

    // 测试 AppInput 暗黑模式
    testWidgets('AppInput 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: AppInput(
              label: '用户名',
              hint: '请输入用户名',
            ),
          ),
        ),
      );

      expect(find.text('用户名'), findsOneWidget);
    });

    // 测试 AppAppBar 暗黑模式
    testWidgets('AppAppBar 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            appBar: AppAppBar(
              title: '测试标题',
              showBack: true,
            ),
          ),
        ),
      );

      expect(find.text('测试标题'), findsOneWidget);
    });

    // 测试 AppLoading 暗黑模式
    testWidgets('AppLoading 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: AppLoading(
              message: '加载中...',
            ),
          ),
        ),
      );

      expect(find.text('加载中...'), findsOneWidget);
    });

    // 测试 AppError 暗黑模式
    testWidgets('AppError 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: AppError(
              message: '出错了',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('出错了'), findsOneWidget);
    });

    // 测试 AppShimmer 暗黑模式
    testWidgets('AppShimmer 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: AppShimmer(
              child: Container(
                width: 100,
                height: 100,
                color: Colors.white,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(AppShimmer), findsOneWidget);
    });

    // 测试 RouteCard 暗黑模式
    testWidgets('RouteCard 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '测试路线',
              distance: '5.0 km',
              duration: '1.0 小时',
              difficulty: RouteDifficulty.easy,
            ),
          ),
        ),
      );

      expect(find.text('测试路线'), findsOneWidget);
      expect(find.text('简单'), findsOneWidget);
    });

    // 测试 SearchBar 暗黑模式
    testWidgets('SearchBar 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: SearchBar(
              hintText: '搜索景点',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    // 测试 FilterTags 暗黑模式
    testWidgets('FilterTags 在暗黑模式下正确显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: FilterTags(
              selectedTag: '全部',
              onSelect: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('全部'), findsOneWidget);
      expect(find.text('简单'), findsOneWidget);
      expect(find.text('中等'), findsOneWidget);
      expect(find.text('困难'), findsOneWidget);
    });
  });
}
