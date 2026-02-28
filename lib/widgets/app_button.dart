import 'package:flutter/material.dart';

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

  // 设计系统颜色 - 山青色
  static const Color _primaryColor = Color(0xFF2D968A);
  static const Color _primaryPressed = Color(0xFF25877C);
  static const Color _primaryDisabled = Color(0xFFB8E0DA);
  
  static const Color _secondaryFg = Color(0xFF2D968A);
  static const Color _secondaryBorder = Color(0xFF2D968A);
  static const Color _secondaryBgPressed = Color(0xFFF3F4F6);
  
  static const Color _ghostFg = Color(0xFF2D968A);
  static const Color _ghostFgDisabled = Color(0xFFA1A8B3);
  
  static const Color _disabledBg = Color(0xFFF3F4F6);
  static const Color _disabledFg = Color(0xFFA1A8B3);
  static const Color _disabledBorder = Color(0xFFD1D5DB);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: _buildStyle(),
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

  ButtonStyle _buildStyle() {
    return ButtonStyle(
      backgroundColor: _backgroundColor(),
      foregroundColor: _foregroundColor(),
      overlayColor: _overlayColor(),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(_padding()),
      minimumSize: WidgetStateProperty.all(_minSize()),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius()),
          side: _borderSide(),
        ),
      ),
      textStyle: WidgetStateProperty.all(_textStyle()),
    );
  }

  WidgetStateProperty<Color?> _backgroundColor() {
    return WidgetStateProperty.resolveWith((states) {
      if (!_isEnabled) return _disabledBg;
      if (states.contains(WidgetState.pressed)) {
        return switch (variant) {
          AppButtonVariant.primary => _primaryPressed,
          AppButtonVariant.secondary => _secondaryBgPressed,
          AppButtonVariant.ghost => Colors.transparent,
        };
      }
      return switch (variant) {
        AppButtonVariant.primary => _primaryColor,
        AppButtonVariant.secondary => Colors.white,
        AppButtonVariant.ghost => Colors.transparent,
      };
    });
  }

  WidgetStateProperty<Color?> _foregroundColor() {
    return WidgetStateProperty.resolveWith((states) {
      if (!_isEnabled) return _disabledFg;
      return switch (variant) {
        AppButtonVariant.primary => Colors.white,
        AppButtonVariant.secondary => _secondaryFg,
        AppButtonVariant.ghost => _ghostFg,
      };
    });
  }

  WidgetStateProperty<Color?> _overlayColor() {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return Colors.black.withOpacity(0.05);
      }
      return null;
    });
  }

  BorderSide _borderSide() {
    if (!_isEnabled) {
      return variant == AppButtonVariant.secondary 
          ? const BorderSide(color: _disabledBorder)
          : BorderSide.none;
    }
    return switch (variant) {
      AppButtonVariant.primary => BorderSide.none,
      AppButtonVariant.secondary => const BorderSide(color: _secondaryBorder),
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
    return switch (size) {
      AppButtonSize.small => 4,
      AppButtonSize.medium => 8,
      AppButtonSize.large => 8,
    };
  }

  TextStyle _textStyle() {
    return switch (size) {
      AppButtonSize.small => const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      AppButtonSize.medium => const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      AppButtonSize.large => const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    };
  }
}
