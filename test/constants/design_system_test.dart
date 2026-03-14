import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/constants/design_system.dart';

void main() {
  group('DesignSystem 单元测试', () {
    
    test('颜色常量已定义', () {
      // 亮色模式颜色
      expect(DesignSystem.primary, isA<Color>());
      expect(DesignSystem.primaryLight, isA<Color>());
      expect(DesignSystem.primaryDark, isA<Color>());
      
      // 背景色
      expect(DesignSystem.background, isA<Color>());
      expect(DesignSystem.backgroundSecondary, isA<Color>());
      expect(DesignSystem.backgroundTertiary, isA<Color>());
      
      // 文字颜色
      expect(DesignSystem.textPrimary, isA<Color>());
      expect(DesignSystem.textSecondary, isA<Color>());
      expect(DesignSystem.textTertiary, isA<Color>());
      expect(DesignSystem.textInverse, isA<Color>());
      
      // 功能色
      expect(DesignSystem.success, isA<Color>());
      expect(DesignSystem.warning, isA<Color>());
      expect(DesignSystem.error, isA<Color>());
      expect(DesignSystem.info, isA<Color>());
    });

    test('暗黑模式颜色常量已定义', () {
      expect(DesignSystem.primaryDarkMode, isA<Color>());
      expect(DesignSystem.backgroundDark, isA<Color>());
      expect(DesignSystem.textPrimaryDark, isA<Color>());
    });

    test('字体大小常量已定义', () {
      expect(DesignSystem.fontHeading, equals(18));
      expect(DesignSystem.fontBody, equals(14));
      expect(DesignSystem.fontSmall, equals(12));
      expect(DesignSystem.fontLarge, equals(20));
      expect(DesignSystem.fontXLarge, equals(24));
    });

    test('间距常量已定义', () {
      expect(DesignSystem.spacingSmall, equals(8));
      expect(DesignSystem.spacingMedium, equals(16));
      expect(DesignSystem.spacingLarge, equals(24));
      expect(DesignSystem.spacingXLarge, equals(32));
    });

    test('圆角常量已定义', () {
      expect(DesignSystem.radius, equals(8));
      expect(DesignSystem.radiusLarge, equals(12));
      expect(DesignSystem.radiusXLarge, equals(16));
      expect(DesignSystem.radiusCircular, equals(999));
    });

    test('主题数据已定义', () {
      expect(DesignSystem.lightTheme, isA<ThemeData>());
      expect(DesignSystem.darkTheme, isA<ThemeData>());
    });

    test('亮色主题使用 Material3', () {
      expect(DesignSystem.lightTheme.useMaterial3, isTrue);
    });

    test('暗黑主题使用 Material3', () {
      expect(DesignSystem.darkTheme.useMaterial3, isTrue);
    });

    test('亮色主题亮度设置正确', () {
      expect(DesignSystem.lightTheme.brightness, equals(Brightness.light));
    });

    test('暗黑主题亮度设置正确', () {
      expect(DesignSystem.darkTheme.brightness, equals(Brightness.dark));
    });
  });
}
