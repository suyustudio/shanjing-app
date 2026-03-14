import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/widgets/app_button.dart';
import 'package:hangzhou_guide/constants/design_system.dart';

void main() {
  group('AppButton 单元测试', () {
    testWidgets('主按钮渲染正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: '测试按钮',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('测试按钮'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('次按钮渲染正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppButton.secondary(
              label: '次按钮',
            ),
          ),
        ),
      );

      expect(find.text('次按钮'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('禁用状态显示正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const AppButton.secondary(
              label: '禁用按钮',
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('按钮带图标渲染正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: '带图标按钮',
              onPressed: () {},
              icon: const Icon(Icons.add),
            ),
          ),
        ),
      );

      expect(find.text('带图标按钮'), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('点击回调触发正确', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppButton(
              label: '点击测试',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('点击测试'));
      expect(tapped, isTrue);
    });

    testWidgets('不同尺寸渲染正确', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                AppButton(
                  label: '小号',
                  size: AppButtonSize.small,
                  onPressed: () {},
                ),
                AppButton(
                  label: '中号',
                  size: AppButtonSize.medium,
                  onPressed: () {},
                ),
                AppButton(
                  label: '大号',
                  size: AppButtonSize.large,
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('小号'), findsOneWidget);
      expect(find.text('中号'), findsOneWidget);
      expect(find.text('大号'), findsOneWidget);
    });
  });
}
