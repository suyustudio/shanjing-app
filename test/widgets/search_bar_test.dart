import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/widgets/search_bar.dart';

void main() {
  group('SearchBar 单元测试', () {
    testWidgets('搜索栏渲染正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              hintText: '搜索测试',
              onSearch: (value) {},
            ),
          ),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('输入文字时显示清除按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              onSearch: (value) {},
            ),
          ),
        ),
      );

      // 初始状态没有清除按钮
      expect(find.byIcon(Icons.clear), findsNothing);

      // 输入文字
      await tester.enterText(find.byType(TextField), '测试文字');
      await tester.pump();

      // 显示清除按钮
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('清除按钮清空文字', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              onSearch: (value) {},
            ),
          ),
        ),
      );

      // 输入文字
      await tester.enterText(find.byType(TextField), '测试文字');
      await tester.pump();

      // 点击清除按钮
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // 文字被清空
      final textField = tester.widget<TextField>(find.byType(TextField));
      final controller = textField.controller;
      expect(controller?.text, isEmpty);
    });

    testWidgets('搜索回调触发正确', (WidgetTester tester) async {
      String? searchedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              onSearch: (value) {
                searchedValue = value;
              },
            ),
          ),
        ),
      );

      // 输入文字并提交
      await tester.enterText(find.byType(TextField), '搜索关键词');
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      expect(searchedValue, equals('搜索关键词'));
    });

    testWidgets('自定义提示文字显示正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SearchBar(
              hintText: '自定义提示',
              onSearch: (value) {},
            ),
          ),
        ),
      );

      // 查找包含提示文字的 InputDecoration
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals('自定义提示'));
    });
  });
}
