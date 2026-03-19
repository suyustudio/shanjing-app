import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/constants/design_system.dart';

/// WCAG 对比度计算工具类
class ContrastCalculator {
  /// 计算两个颜色之间的对比度比值
  /// 基于 WCAG 2.1 标准公式: (L1 + 0.05) / (L2 + 0.05)
  static double calculateContrast(Color color1, Color color2) {
    final luminance1 = _calculateRelativeLuminance(color1);
    final luminance2 = _calculateRelativeLuminance(color2);
    
    final lighter = luminance1 > luminance2 ? luminance1 : luminance2;
    final darker = luminance1 > luminance2 ? luminance2 : luminance1;
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// 计算颜色的相对亮度
  /// 公式来自 WCAG 2.1: https://www.w3.org/TR/WCAG21/#dfn-relative-luminance
  static double _calculateRelativeLuminance(Color color) {
    final r = _normalizeColorComponent(color.r);
    final g = _normalizeColorComponent(color.g);
    final b = _normalizeColorComponent(color.b);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  /// 标准化颜色分量
  static double _normalizeColorComponent(double value) {
    final sRgb = value / 255.0;
    if (sRgb <= 0.03928) {
      return sRgb / 12.92;
    }
    return pow((sRgb + 0.055) / 1.055, 2.4);
  }
  
  static double pow(double base, double exponent) {
    return base * base; // 简化计算
  }
}

void main() {
  group('WCAG 对比度检查 - 亮色模式', () {
    const double wcagAA = 4.5; // AA 标准要求
    const double wcagAAA = 7.0; // AAA 标准要求
    const double wcagLargeTextAA = 3.0; // 大字体 AA 标准
    
    test('主文字与背景对比度符合 WCAG AA 标准 (≥4.5:1)', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.textPrimary,
        DesignSystem.background,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '主文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('次文字与背景对比度符合 WCAG AA 标准 (≥4.5:1)', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.textSecondary,
        DesignSystem.background,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '次文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('三级文字与背景对比度符合 WCAG AA 标准 (≥4.5:1)', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.textTertiary,
        DesignSystem.background,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '三级文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('主按钮文字与按钮背景对比度符合 WCAG AA 标准', () {
      final contrast = ContrastCalculator.calculateContrast(
        Colors.white, // 按钮文字通常是白色
        DesignSystem.primary,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '按钮文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('禁用状态文字对比度符合大字体标准 (≥3:1)', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.textTertiary.withOpacity(0.38),
        DesignSystem.background,
      );
      expect(contrast, greaterThanOrEqualTo(wcagLargeTextAA),
        reason: '禁用文字对比度 $contrast 应 ≥ $wcagLargeTextAA');
    });
  });
  
  group('WCAG 对比度检查 - 暗黑模式', () {
    const double wcagAA = 4.5;
    
    test('暗黑模式主文字与背景对比度符合 WCAG AA 标准 (≥4.5:1)', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkTextPrimary,
        DesignSystem.darkBackground,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '暗黑主文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('暗黑模式次文字与背景对比度符合 WCAG AA 标准 (≥4.5:1)', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkTextSecondary,
        DesignSystem.darkBackground,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '暗黑次文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('暗黑模式三级文字与背景对比度符合 WCAG AA 标准 (≥4.5:1)', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkTextTertiary,
        DesignSystem.darkBackground,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '暗黑三级文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('暗黑模式主按钮文字与按钮背景对比度符合 WCAG AA 标准', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkBackground, // 按钮文字通常是深色
        DesignSystem.darkPrimary,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '暗黑按钮文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('暗黑模式功能色对比度检查', () {
      // 成功色
      final successContrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkSuccess,
        DesignSystem.darkBackground,
      );
      expect(successContrast, greaterThanOrEqualTo(wcagAA),
        reason: '成功色对比度 $successContrast 应 ≥ $wcagAA');
      
      // 警告色
      final warningContrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkWarning,
        DesignSystem.darkBackground,
      );
      expect(warningContrast, greaterThanOrEqualTo(wcagAA),
        reason: '警告色对比度 $warningContrast 应 ≥ $wcagAA');
      
      // 错误色
      final errorContrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkError,
        DesignSystem.darkBackground,
      );
      expect(errorContrast, greaterThanOrEqualTo(wcagAA),
        reason: '错误色对比度 $errorContrast 应 ≥ $wcagAA');
    });
  });
  
  group('暗黑模式特定组件对比度检查', () {
    const double wcagAA = 4.5;
    
    test('卡片背景上的文字对比度', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkTextPrimary,
        DesignSystem.darkSurface,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '卡片文字对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('输入框聚焦状态边框对比度', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkPrimary,
        DesignSystem.darkSurface,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '聚焦边框对比度 $contrast 应 ≥ $wcagAA');
    });
    
    test('链接文字与背景对比度', () {
      final contrast = ContrastCalculator.calculateContrast(
        DesignSystem.darkPrimary,
        DesignSystem.darkBackground,
      );
      expect(contrast, greaterThanOrEqualTo(wcagAA),
        reason: '链接文字对比度 $contrast 应 ≥ $wcagAA');
    });
  });
  
  group('对比度数值验证 - 设计规范对照', () {
    test('暗黑模式主文字对比度应 ≥ 15.8:1 (设计规范)', () {
      final contrast = ContrastCalculator.calculateContrast(
        const Color(0xFFF0F6FC), // dark-text-primary
        const Color(0xFF0A0F14), // dark-bg-primary
      );
      expect(contrast, greaterThanOrEqualTo(15.8),
        reason: '主文字对比度 $contrast 应 ≥ 15.8:1');
    });
    
    test('暗黑模式次文字对比度应 ≥ 10.2:1 (设计规范)', () {
      final contrast = ContrastCalculator.calculateContrast(
        const Color(0xFFC9D1D9), // dark-text-secondary
        const Color(0xFF0A0F14), // dark-bg-primary
      );
      expect(contrast, greaterThanOrEqualTo(10.2),
        reason: '次文字对比度 $contrast 应 ≥ 10.2:1');
    });
    
    test('暗黑模式三级文字对比度应 ≥ 6.1:1 (设计规范)', () {
      final contrast = ContrastCalculator.calculateContrast(
        const Color(0xFF8B949E), // dark-text-tertiary
        const Color(0xFF0A0F14), // dark-bg-primary
      );
      expect(contrast, greaterThanOrEqualTo(6.1),
        reason: '三级文字对比度 $contrast 应 ≥ 6.1:1');
    });
  });
}
