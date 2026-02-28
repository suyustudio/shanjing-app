import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/screens/discovery_screen.dart';
import 'package:hangzhou_guide/widgets/app_loading.dart';

void main() {
  group('DiscoveryScreen', () {
    testWidgets('renders with app bar title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryScreen(),
        ),
      );

      expect(find.text('发现'), findsOneWidget);
    });

    testWidgets('shows loading state initially', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryScreen(),
        ),
      );

      // 初始状态显示加载
      expect(find.byType(AppLoading), findsOneWidget);
    });

    testWidgets('has search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryScreen(),
        ),
      );

      // 搜索栏存在
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('has filter tags', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: DiscoveryScreen(),
        ),
      );

      // 筛选标签存在（"全部"标签）
      expect(find.text('全部'), findsOneWidget);
    });
  });
}
