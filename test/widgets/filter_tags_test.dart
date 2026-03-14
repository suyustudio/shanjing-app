import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/widgets/filter_tags.dart';

void main() {
  group('FilterTags 单元测试', () {
    testWidgets('渲染所有标签', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterTags(
              selectedTag: '全部',
              onSelect: (_) {},
            ),
          ),
        ),
      );

      // 验证所有标签都显示
      expect(find.text('全部'), findsOneWidget);
      expect(find.text('简单'), findsOneWidget);
      expect(find.text('中等'), findsOneWidget);
      expect(find.text('困难'), findsOneWidget);
    });

    testWidgets('选中标签高亮显示', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterTags(
              selectedTag: '困难',
              onSelect: (_) {},
            ),
          ),
        ),
      );

      // 查找所有 ChoiceChip
      final chips = tester.widgetList<ChoiceChip>(find.byType(ChoiceChip));
      
      // 验证有4个标签
      expect(chips.length, equals(4));

      // 找到选中的标签
      final selectedChip = chips.firstWhere((c) => c.label.toString().contains('困难'));
      expect(selectedChip.selected, isTrue);
    });

    testWidgets('点击标签触发回调', (WidgetTester tester) async {
      String? selectedValue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterTags(
              selectedTag: '全部',
              onSelect: (tag) {
                selectedValue = tag;
              },
            ),
          ),
        ),
      );

      // 点击"简单"标签
      await tester.tap(find.text('简单'));
      await tester.pump();

      expect(selectedValue, equals('简单'));
    });

    testWidgets('支持水平滚动', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 100, // 设置小宽度强制滚动
              child: FilterTags(
                selectedTag: '全部',
                onSelect: (_) {},
              ),
            ),
          ),
        ),
      );

      // 验证 SingleChildScrollView 存在
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('每个标签都是 ChoiceChip', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FilterTags(
              selectedTag: '全部',
              onSelect: (_) {},
            ),
          ),
        ),
      );

      // 验证有4个 ChoiceChip
      expect(find.byType(ChoiceChip), findsNWidgets(4));
    });
  });
}
