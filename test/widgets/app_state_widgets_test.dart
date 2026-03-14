import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/widgets/app_error.dart';
import 'package:hangzhou_guide/widgets/app_loading.dart';
import 'package:hangzhou_guide/widgets/app_empty.dart';

void main() {
  group('AppError 单元测试', () {
    testWidgets('渲染错误信息', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppError(
              message: '发生错误',
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('发生错误'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('重试'), findsOneWidget);
    });

    testWidgets('无重试回调时不显示按钮', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppError(
              message: '发生错误',
            ),
          ),
        ),
      );

      expect(find.text('发生错误'), findsOneWidget);
      expect(find.text('重试'), findsNothing);
    });

    testWidgets('自定义重试文本', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppError(
              message: '发生错误',
              onRetry: () {},
              retryText: '重新加载',
            ),
          ),
        ),
      );

      expect(find.text('重新加载'), findsOneWidget);
    });

    testWidgets('点击重试触发回调', (WidgetTester tester) async {
      var retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppError(
              message: '发生错误',
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('重试'));
      expect(retried, isTrue);
    });
  });

  group('AppNetworkError 单元测试', () {
    testWidgets('渲染网络错误信息', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNetworkError(
              onRetry: () {},
            ),
          ),
        ),
      );

      expect(find.text('网络连接失败，请检查网络'), findsOneWidget);
      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });
  });

  group('AppEmpty 单元测试', () {
    testWidgets('渲染空状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppEmpty(
              title: '暂无数据',
            ),
          ),
        ),
      );

      expect(find.text('暂无数据'), findsOneWidget);
    });

    testWidgets('自定义空状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmpty(
              title: '没有找到相关内容',
              description: '请尝试其他关键词',
              icon: Icons.search_off,
              primaryAction: AppEmptyAction(
                label: '刷新',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('没有找到相关内容'), findsOneWidget);
      expect(find.text('请尝试其他关键词'), findsOneWidget);
      expect(find.text('刷新'), findsOneWidget);
    });

    testWidgets('预设类型 - 网络错误', (WidgetTester tester) async {
      var retried = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmpty.network(
              onRetry: () {
                retried = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('网络好像断开了'), findsOneWidget);
      expect(find.text('重新加载'), findsOneWidget);
      
      await tester.tap(find.text('重新加载'));
      expect(retried, isTrue);
    });

    testWidgets('预设类型 - 搜索为空', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmpty.search(
              keyword: '测试',
              onClearFilter: () {},
            ),
          ),
        ),
      );

      expect(find.text('没有找到"测试"'), findsOneWidget);
      expect(find.text('清空筛选'), findsOneWidget);
    });

    testWidgets('预设类型 - 收藏为空', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmpty.favorite(
              onExplore: () {},
            ),
          ),
        ),
      );

      expect(find.text('还没有收藏任何路线'), findsOneWidget);
      expect(find.text('去发现'), findsOneWidget);
    });

    testWidgets('预设类型 - 下载为空', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppEmpty.download(
              onGoDownload: () {},
            ),
          ),
        ),
      );

      expect(find.text('还没有下载离线地图'), findsOneWidget);
      expect(find.text('去下载'), findsOneWidget);
    });
  });

  group('AppLoading 单元测试', () {
    testWidgets('渲染加载指示器', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoading(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('渲染带消息的加载状态', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoading(
              message: '加载中...',
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('加载中...'), findsOneWidget);
    });

    testWidgets('自定义大小和颜色', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoading(
              size: 48,
              color: Colors.red,
            ),
          ),
        ),
      );

      final indicator = tester.widget<CircularProgressIndicator>(
        find.byType(CircularProgressIndicator),
      );
      expect(indicator.color, equals(Colors.red));
    });
  });

  group('AppLoadingSmall 单元测试', () {
    testWidgets('渲染小型加载指示器', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingSmall(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('自定义大小', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppLoadingSmall(
              size: 24,
            ),
          ),
        ),
      );

      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, equals(24));
      expect(sizedBox.height, equals(24));
    });
  });
}
