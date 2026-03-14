import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// 按钮变体类型
enum AppButtonVariant {
  primary,    // 主按钮
  secondary,  // 次按钮
  ghost,      // 幽灵按钮
}

/// 按钮尺寸
enum AppButtonSize {
  small,
  medium,
  large,
}

/// App 按钮组件
/// 
/// 支持暗黑模式，自动根据当前主题调整颜色
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.variant = AppButtonVariant.primary,
    this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
  });

  const AppButton.secondary({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.size = AppButtonSize.medium,
  }) : variant = AppButtonVariant.secondary;

  final String label;
  final AppButtonVariant variant;
  final VoidCallback? onPressed;
  final Widget? icon;
  final AppButtonSize size;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return ElevatedButton(
      onPressed: onPressed,
      style: _buildStyle(context, isDark),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            SizedBox(width: size == AppButtonSize.small ? 4 : 8),
          ],
          Text(label),
        ],
      ),
    );
  }

  ButtonStyle _buildStyle(BuildContext context, bool isDark) {
    return ButtonStyle(
      backgroundColor: _backgroundColor(context, isDark),
      foregroundColor: _foregroundColor(context, isDark),
      overlayColor: _overlayColor(isDark),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(_padding()),
      minimumSize: WidgetStateProperty.all(_minSize()),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius()),
          side: _borderSide(context, isDark),
        ),
      ),
      textStyle: WidgetStateProperty.all(_textStyle()),
    );
  }

  WidgetStateProperty<Color?> _backgroundColor(BuildContext context, bool isDark) {
    final primaryColor = DesignSystem.getPrimary(context);
    final primaryPressed = isDark ? DesignSystem.primaryDarkDarkMode : DesignSystem.primaryDark;
    final disabledBg = isDark ? DesignSystem.backgroundTertiaryDark : const Color(0xFFF3F4F6);
    final secondaryBgPressed = isDark ? DesignSystem.backgroundTertiaryDark : const Color(0xFFF3F4F6);
    
    return WidgetStateProperty.resolveWith((states) {
      if (!_isEnabled) return disabledBg;
      if (states.contains(WidgetState.pressed)) {
        return switch (variant) {
          AppButtonVariant.primary => primaryPressed,
          AppButtonVariant.secondary => secondaryBgPressed,
          AppButtonVariant.ghost => Colors.transparent,
        };
      }
      return switch (variant) {
        AppButtonVariant.primary => primaryColor,
        AppButtonVariant.secondary => isDark ? DesignSystem.backgroundSecondaryDark : DesignSystem.background,
        AppButtonVariant.ghost => Colors.transparent,
      };
    });
  }

  WidgetStateProperty<Color?> _foregroundColor(BuildContext context, bool isDark) {
    final primaryColor = DesignSystem.getPrimary(context);
    final disabledFg = isDark ? DesignSystem.textTertiaryDark : const Color(0xFFA1A8B3);
    
    return WidgetStateProperty.resolveWith((states) {
      if (!_isEnabled) return disabledFg;
      return switch (variant) {
        AppButtonVariant.primary => isDark ? DesignSystem.textInverseDark : Colors.white,
        AppButtonVariant.secondary => primaryColor,
        AppButtonVariant.ghost => primaryColor,
      };
    });
  }

  WidgetStateProperty<Color?> _overlayColor(bool isDark) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return isDark 
            ? Colors.white.withOpacity(0.05) 
            : Colors.black.withOpacity(0.05);
      }
      return null;
    });
  }

  BorderSide _borderSide(BuildContext context, bool isDark) {
    final primaryColor = DesignSystem.getPrimary(context);
    final disabledBorder = isDark ? DesignSystem.borderDark : const Color(0xFFD1D5DB);
    
    if (!_isEnabled) {
      return variant == AppButtonVariant.secondary 
          ? BorderSide(color: disabledBorder)
          : BorderSide.none;
    }
    return switch (variant) {
      AppButtonVariant.primary => BorderSide.none,
      AppButtonVariant.secondary => BorderSide(color: primaryColor),
      AppButtonVariant.ghost => BorderSide.none,
    };
  }

  EdgeInsets _padding() {
    return switch (size) {
      AppButtonSize.small => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      AppButtonSize.medium => const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      AppButtonSize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    };
  }

  Size _minSize() {
    return switch (size) {
      AppButtonSize.small => const Size(64, 32),
      AppButtonSize.medium => const Size(80, 40),
      AppButtonSize.large => const Size(96, 48),
    };
  }

  double _borderRadius() {
    return DesignSystem.radius; // 统一使用设计系统圆角
  }

  TextStyle _textStyle() {
    return switch (size) {
      AppButtonSize.small => const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      AppButtonSize.medium => const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      AppButtonSize.large => const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    };
  }
}
