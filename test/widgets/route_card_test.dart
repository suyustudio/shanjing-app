import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/widgets/route_card.dart';

void main() {
  group('RouteCard', () {
    testWidgets('renders correctly with required props', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '西湖环湖路线',
              distance: '10.5 km',
              duration: '2.5 小时',
            ),
          ),
        ),
      );

      expect(find.text('西湖环湖路线'), findsOneWidget);
      expect(find.text('10.5 km · 2.5 小时'), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    });

    testWidgets('displays difficulty badge when provided', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '灵隐寺徒步',
              distance: '5.2 km',
              duration: '1.5 小时',
              difficulty: RouteDifficulty.hard,
            ),
          ),
        ),
      );

      expect(find.text('灵隐寺徒步'), findsOneWidget);
      expect(find.text('hard'), findsOneWidget);
    });

    testWidgets('triggers onTap callback when tapped', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '九溪烟树',
              distance: '3.0 km',
              duration: '1.0 小时',
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(RouteCard));
      expect(tapped, isTrue);
    });
  });
}
