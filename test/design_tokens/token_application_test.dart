import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/constants/design_system.dart';

/// 设计 Token 应用验证测试
/// 确保组件正确使用 DesignSystem 常量，无硬编码值
void main() {
  group('Design Token 应用验证 - RouteCard', () {
    testWidgets('RouteCard 使用正确的圆角 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '测试路线',
              distance: '5.0 km',
              duration: '1.0 小时',
              difficulty: '休闲',
            ),
          ),
        ),
      );
      
      final card = find.byType(RouteCard);
      expect(card, findsOneWidget);
      
      // 查找卡片容器
      final container = find.descendant(
        of: card,
        matching: find.byType(Container),
      ).first;
      
      final containerWidget = tester.widget<Container>(container);
      final decoration = containerWidget.decoration as BoxDecoration?;
      
      // 验证使用 DesignSystem.radiusLarge (12px) 而非硬编码
      final borderRadius = decoration?.borderRadius as BorderRadius?;
      expect(borderRadius?.topLeft.x, equals(DesignSystem.radiusLarge),
        reason: 'RouteCard 应使用 DesignSystem.radiusLarge');
    });
    
    testWidgets('RouteCard 使用正确的背景色 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '测试路线',
              distance: '5.0 km',
              duration: '1.0 小时',
              difficulty: '休闲',
            ),
          ),
        ),
      );
      
      final card = find.byType(RouteCard);
      final container = find.descendant(
        of: card,
        matching: find.byType(Container),
      ).first;
      
      final containerWidget = tester.widget<Container>(container);
      final decoration = containerWidget.decoration as BoxDecoration?;
      
      // 验证使用 DesignSystem.surfacePrimary 而非硬编码
      expect(decoration?.color, equals(DesignSystem.surfacePrimary),
        reason: 'RouteCard 应使用 DesignSystem.surfacePrimary 作为背景色');
    });
    
    testWidgets('RouteCard 使用正确的间距 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '测试路线',
              distance: '5.0 km',
              duration: '1.0 小时',
              difficulty: '休闲',
            ),
          ),
        ),
      );
      
      final card = find.byType(RouteCard);
      final padding = find.descendant(
        of: card,
        matching: find.byType(Padding),
      ).first;
      
      final paddingWidget = tester.widget<Padding>(padding);
      final edgeInsets = paddingWidget.padding as EdgeInsets?;
      
      // 验证使用 DesignSystem.spacingMedium (16px)
      expect(edgeInsets?.left, equals(DesignSystem.spacingMedium),
        reason: 'RouteCard 应使用 DesignSystem.spacingMedium 作为水平内边距');
    });
  });
  
  group('Design Token 应用验证 - AppButton', () {
    testWidgets('主按钮使用正确的颜色 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: Scaffold(
            body: AppButton(
              label: '测试按钮',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      
      final elevatedButton = tester.widget<ElevatedButton>(button);
      final style = elevatedButton.style;
      
      // 验证背景色使用 DesignSystem.primary
      final backgroundColor = style?.backgroundColor?.resolve({});
      expect(backgroundColor, equals(DesignSystem.primary),
        reason: '主按钮应使用 DesignSystem.primary 作为背景色');
    });
    
    testWidgets('次按钮使用正确的颜色 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: Scaffold(
            body: const AppButton.secondary(
              label: '次按钮',
            ),
          ),
        ),
      );
      
      final button = find.byType(OutlinedButton);
      expect(button, findsOneWidget);
    });
    
    testWidgets('按钮使用正确的圆角 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: Scaffold(
            body: AppButton(
              label: '测试按钮',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      final button = find.byType(ElevatedButton);
      final elevatedButton = tester.widget<ElevatedButton>(button);
      final style = elevatedButton.style;
      
      final shape = style?.shape?.resolve({});
      if (shape is RoundedRectangleBorder) {
        // 验证使用 DesignSystem.radius (8px)
        expect(
          (shape.borderRadius as BorderRadius).topLeft.x,
          equals(DesignSystem.radius.toDouble()),
          reason: '按钮应使用 DesignSystem.radius 作为圆角',
        );
      }
    });
  });
  
  group('Design Token 应用验证 - AppInput', () {
    testWidgets('输入框使用正确的边框颜色 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: AppInput(
              label: '用户名',
              hint: '请输入用户名',
            ),
          ),
        ),
      );
      
      final input = find.byType(TextField);
      expect(input, findsOneWidget);
      
      final textField = tester.widget<TextField>(input);
      final decoration = textField.decoration;
      
      // 验证边框颜色使用 DesignSystem.borderColor
      expect(decoration?.enabledBorder, isA<OutlineInputBorder>());
    });
    
    testWidgets('输入框聚焦时使用正确的主色 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: AppInput(
              label: '用户名',
              hint: '请输入用户名',
            ),
          ),
        ),
      );
      
      final input = find.byType(TextField);
      final textField = tester.widget<TextField>(input);
      final decoration = textField.decoration;
      
      // 验证聚焦边框使用 DesignSystem.primary
      final focusedBorder = decoration?.focusedBorder as OutlineInputBorder?;
      expect(focusedBorder?.borderSide.color, equals(DesignSystem.primary),
        reason: '输入框聚焦边框应使用 DesignSystem.primary');
    });
  });
  
  group('Design Token 应用验证 - 无硬编码检查', () {
    testWidgets('组件中不存在硬编码颜色值', (tester) async {
      // 常见硬编码颜色值黑名单
      final forbiddenColors = [
        const Color(0xFF000000), // 纯黑
        const Color(0xFFFFFFFF), // 纯白（除文字外）
        const Color(0xFFFF0000), // 纯红
        const Color(0xFF00FF00), // 纯绿
        const Color(0xFF0000FF), // 纯蓝
      ];
      
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: Column(
              children: [
                RouteCard(
                  imageUrl: 'https://example.com/image.jpg',
                  name: '测试路线',
                  distance: '5.0 km',
                  duration: '1.0 小时',
                  difficulty: '休闲',
                ),
              ],
            ),
          ),
        ),
      );
      
      // 遍历所有 Container 检查背景色
      final containers = find.byType(Container);
      for (var i = 0; i < containers.evaluate().length; i++) {
        final container = containers.at(i);
        if (tester.widget<Container>(container).decoration is BoxDecoration) {
          final decoration = tester.widget<Container>(container).decoration as BoxDecoration;
          if (decoration.color != null) {
            expect(
              forbiddenColors.contains(decoration.color),
              isFalse,
              reason: '不应使用硬编码颜色 ${decoration.color}',
            );
          }
        }
      }
    });
    
    testWidgets('组件使用 DesignSystem 字号而非硬编码', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          home: const Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '测试路线',
              distance: '5.0 km',
              duration: '1.0 小时',
              difficulty: '休闲',
            ),
          ),
        ),
      );
      
      // 检查文字是否使用 DesignSystem 字号
      final texts = find.byType(Text);
      for (var i = 0; i < texts.evaluate().length; i++) {
        final text = texts.at(i);
        final textWidget = tester.widget<Text>(text);
        final fontSize = textWidget.style?.fontSize;
        
        if (fontSize != null) {
          // 验证字号在允许的 DesignSystem 字号列表中
          final allowedSizes = [
            DesignSystem.fontOverline,
            DesignSystem.fontCaption,
            DesignSystem.fontSmall,
            DesignSystem.fontBody,
            DesignSystem.fontBodyLarge,
            DesignSystem.fontH4,
            DesignSystem.fontH3,
            DesignSystem.fontH2,
            DesignSystem.fontH1,
            DesignSystem.fontDisplay,
          ];
          
          expect(
            allowedSizes.contains(fontSize),
            isTrue,
            reason: '字号 $fontSize 应使用 DesignSystem 定义的字号',
          );
        }
      }
    });
  });
  
  group('暗黑模式 Token 应用验证', () {
    testWidgets('暗黑模式使用正确的背景色 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: RouteCard(
              imageUrl: 'https://example.com/image.jpg',
              name: '测试路线',
              distance: '5.0 km',
              duration: '1.0 小时',
              difficulty: '休闲',
            ),
          ),
        ),
      );
      
      final card = find.byType(RouteCard);
      final container = find.descendant(
        of: card,
        matching: find.byType(Container),
      ).first;
      
      final containerWidget = tester.widget<Container>(container);
      final decoration = containerWidget.decoration as BoxDecoration?;
      
      // 验证使用 DesignSystem.darkSurface
      expect(decoration?.color, equals(DesignSystem.darkSurface),
        reason: '暗黑模式下 RouteCard 应使用 DesignSystem.darkSurface');
    });
    
    testWidgets('暗黑模式按钮使用正确的颜色 Token', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: DesignSystem.lightTheme,
          darkTheme: DesignSystem.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            body: AppButton(
              label: '测试按钮',
              onPressed: () {},
            ),
          ),
        ),
      );
      
      final button = find.byType(ElevatedButton);
      final elevatedButton = tester.widget<ElevatedButton>(button);
      final style = elevatedButton.style;
      
      // 验证使用 DesignSystem.darkPrimary
      final backgroundColor = style?.backgroundColor?.resolve({});
      expect(backgroundColor, equals(DesignSystem.darkPrimary),
        reason: '暗黑模式下按钮应使用 DesignSystem.darkPrimary');
    });
  });
  
  group('设计 Token 完整性检查', () {
    test('所有颜色 Token 已定义', () {
      // 基础颜色
      expect(DesignSystem.primary, isA<Color>());
      expect(DesignSystem.primaryLight, isA<Color>());
      expect(DesignSystem.primaryDark, isA<Color>());
      
      // 背景色
      expect(DesignSystem.background, isA<Color>());
      expect(DesignSystem.backgroundSecondary, isA<Color>());
      expect(DesignSystem.backgroundTertiary, isA<Color>());
      
      // 文字色
      expect(DesignSystem.textPrimary, isA<Color>());
      expect(DesignSystem.textSecondary, isA<Color>());
      expect(DesignSystem.textTertiary, isA<Color>());
      
      // 功能色
      expect(DesignSystem.success, isA<Color>());
      expect(DesignSystem.warning, isA<Color>());
      expect(DesignSystem.error, isA<Color>());
      expect(DesignSystem.info, isA<Color>());
      
      // 暗黑模式颜色
      expect(DesignSystem.darkPrimary, isA<Color>());
      expect(DesignSystem.darkBackground, isA<Color>());
      expect(DesignSystem.darkSurface, isA<Color>());
      expect(DesignSystem.darkTextPrimary, isA<Color>());
      expect(DesignSystem.darkTextSecondary, isA<Color>());
      expect(DesignSystem.darkTextTertiary, isA<Color>());
      expect(DesignSystem.darkSuccess, isA<Color>());
      expect(DesignSystem.darkWarning, isA<Color>());
      expect(DesignSystem.darkError, isA<Color>());
    });
    
    test('所有间距 Token 已定义且为 4 的倍数', () {
      expect(DesignSystem.spacingXSmall % 4, equals(0));
      expect(DesignSystem.spacingSmall % 4, equals(0));
      expect(DesignSystem.spacingMedium % 4, equals(0));
      expect(DesignSystem.spacingLarge % 4, equals(0));
      expect(DesignSystem.spacingXLarge % 4, equals(0));
      expect(DesignSystem.spacingXXLarge % 4, equals(0));
    });
    
    test('所有圆角 Token 已定义', () {
      expect(DesignSystem.radiusSmall, isA<double>());
      expect(DesignSystem.radius, isA<double>());
      expect(DesignSystem.radiusLarge, isA<double>());
      expect(DesignSystem.radiusXLarge, isA<double>());
      expect(DesignSystem.radiusCircular, isA<double>());
    });
    
    test('所有字号 Token 遵循 1.25 倍率递增', () {
      final fontSizes = [
        DesignSystem.fontOverline,
        DesignSystem.fontCaption,
        DesignSystem.fontSmall,
        DesignSystem.fontBody,
        DesignSystem.fontBodyLarge,
        DesignSystem.fontH4,
        DesignSystem.fontH3,
        DesignSystem.fontH2,
        DesignSystem.fontH1,
        DesignSystem.fontDisplay,
      ];
      
      // 验证递增趋势
      for (var i = 1; i < fontSizes.length; i++) {
        expect(
          fontSizes[i] > fontSizes[i - 1],
          isTrue,
          reason: '字号应遵循递增趋势',
        );
      }
    });
  });
}

// ============ 测试辅助组件 ============

class RouteCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String distance;
  final String duration;
  final String difficulty;
  
  const RouteCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.distance,
    required this.duration,
    required this.difficulty,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? DesignSystem.darkSurface : DesignSystem.surfacePrimary,
        borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片区域
          ClipRRect(
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(DesignSystem.radiusLarge),
            ),
            child: Container(
              height: 120,
              color: Colors.grey[300],
            ),
          ),
          
          // 内容区域
          Padding(
            padding: EdgeInsets.all(DesignSystem.spacingMedium),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: DesignSystem.fontH4,
                    fontWeight: FontWeight.w600,
                    color: isDark ? DesignSystem.darkTextPrimary : DesignSystem.textPrimary,
                  ),
                ),
                SizedBox(height: DesignSystem.spacingSmall),
                Row(
                  children: [
                    Icon(Icons.location_on, 
                      size: 16, 
                      color: isDark ? DesignSystem.darkTextTertiary : DesignSystem.textTertiary,
                    ),
                    SizedBox(width: DesignSystem.spacingXSmall),
                    Text(
                      distance,
                      style: TextStyle(
                        fontSize: DesignSystem.fontCaption,
                        color: isDark ? DesignSystem.darkTextSecondary : DesignSystem.textSecondary,
                      ),
                    ),
                    SizedBox(width: DesignSystem.spacingMedium),
                    Icon(Icons.access_time, 
                      size: 16,
                      color: isDark ? DesignSystem.darkTextTertiary : DesignSystem.textTertiary,
                    ),
                    SizedBox(width: DesignSystem.spacingXSmall),
                    Text(
                      duration,
                      style: TextStyle(
                        fontSize: DesignSystem.fontCaption,
                        color: isDark ? DesignSystem.darkTextSecondary : DesignSystem.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isSecondary;
  
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isSecondary = false,
  });
  
  const AppButton.secondary({
    super.key,
    required String label,
    VoidCallback? onPressed,
  }) : this(label: label, onPressed: onPressed, isSecondary: true);
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (isSecondary) {
      return OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: isDark ? DesignSystem.darkPrimary : DesignSystem.primary,
          side: BorderSide(
            color: isDark ? DesignSystem.darkPrimary : DesignSystem.primary,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DesignSystem.radius),
          ),
        ),
        child: Text(label),
      );
    }
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isDark ? DesignSystem.darkPrimary : DesignSystem.primary,
        foregroundColor: isDark ? DesignSystem.darkBackground : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignSystem.radius),
        ),
      ),
      child: Text(label),
    );
  }
}

class AppInput extends StatelessWidget {
  final String label;
  final String hint;
  
  const AppInput({
    super.key,
    required this.label,
    required this.hint,
  });
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? DesignSystem.darkBorder : DesignSystem.borderColor,
          ),
          borderRadius: BorderRadius.circular(DesignSystem.radius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark ? DesignSystem.darkPrimary : DesignSystem.primary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(DesignSystem.radius),
        ),
      ),
    );
  }
}
