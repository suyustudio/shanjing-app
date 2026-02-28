# M2 Flutter 公共组件库 - 按钮组件

## 组件概述

极简按钮组件，支持三种变体和三种状态。

## 文件结构

```
lib/
└── components/
    └── button/
        ├── m2_button.dart          # 主入口
        ├── m2_button_theme.dart    # 主题配置
        └── m2_button_styles.dart   # 样式定义
```

## 核心代码

### m2_button.dart

```dart
import 'package:flutter/material.dart';
import 'm2_button_styles.dart';

/// 按钮变体类型
enum M2ButtonVariant {
  primary,    // 主按钮
  secondary,  // 次按钮
  ghost,      // 幽灵按钮
}

/// M2 按钮组件
class M2Button extends StatelessWidget {
  const M2Button({
    super.key,
    required this.label,
    this.variant = M2ButtonVariant.primary,
    this.onPressed,
    this.icon,
    this.size = M2ButtonSize.medium,
  });

  final String label;
  final M2ButtonVariant variant;
  final VoidCallback? onPressed;
  final Widget? icon;
  final M2ButtonSize size;

  bool get _isEnabled => onPressed != null;

  @override
  Widget build(BuildContext context) {
    final style = M2ButtonStyles.getStyle(variant, size, enabled: _isEnabled);

    return ElevatedButton(
      onPressed: onPressed,
      style: style,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon!,
            const SizedBox(width: 8),
          ],
          Text(label),
        ],
      ),
    );
  }
}
```

### m2_button_styles.dart

```dart
import 'package:flutter/material.dart';
import 'm2_button_theme.dart';

/// 按钮尺寸
enum M2ButtonSize {
  small,
  medium,
  large,
}

/// 按钮样式配置
class M2ButtonStyles {
  static ButtonStyle getStyle(
    M2ButtonVariant variant,
    M2ButtonSize size, {
    required bool enabled,
  }) {
    return ButtonStyle(
      backgroundColor: _backgroundColor(variant, enabled),
      foregroundColor: _foregroundColor(variant, enabled),
      overlayColor: _overlayColor(variant),
      elevation: WidgetStateProperty.all(0),
      padding: WidgetStateProperty.all(_padding(size)),
      minimumSize: WidgetStateProperty.all(_minSize(size)),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(M2ButtonTheme.borderRadius),
          side: _borderSide(variant, enabled),
        ),
      ),
    );
  }

  // 背景色
  static WidgetStateProperty<Color?> _backgroundColor(
    M2ButtonVariant variant,
    bool enabled,
  ) {
    final color = switch (variant) {
      M2ButtonVariant.primary => M2ButtonTheme.primaryBg,
      M2ButtonVariant.secondary => M2ButtonTheme.secondaryBg,
      M2ButtonVariant.ghost => Colors.transparent,
    };
    return WidgetStateProperty.resolveWith((states) {
      if (!enabled) return M2ButtonTheme.disabledBg;
      if (states.contains(WidgetState.pressed)) {
        return _pressedColor(color);
      }
      return color;
    });
  }

  // 前景色（文字/图标）
  static WidgetStateProperty<Color?> _foregroundColor(
    M2ButtonVariant variant,
    bool enabled,
  ) {
    final color = switch (variant) {
      M2ButtonVariant.primary => M2ButtonTheme.primaryFg,
      M2ButtonVariant.secondary => M2ButtonTheme.secondaryFg,
      M2ButtonVariant.ghost => M2ButtonTheme.ghostFg,
    };
    return WidgetStateProperty.resolveWith((states) {
      if (!enabled) return M2ButtonTheme.disabledFg;
      return color;
    });
  }

  // 按下时的水波纹/遮罩色
  static WidgetStateProperty<Color?> _overlayColor(M2ButtonVariant variant) {
    return WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.pressed)) {
        return M2ButtonTheme.pressedOverlay;
      }
      return null;
    });
  }

  // 边框
  static BorderSide _borderSide(M2ButtonVariant variant, bool enabled) {
    if (!enabled) return BorderSide(color: M2ButtonTheme.disabledBorder);
    return switch (variant) {
      M2ButtonVariant.primary => BorderSide.none,
      M2ButtonVariant.secondary => BorderSide(color: M2ButtonTheme.secondaryBorder),
      M2ButtonVariant.ghost => BorderSide.none,
    };
  }

  // 按下时颜色变暗
  static Color _pressedColor(Color color) {
    return color.withOpacity(0.8);
  }

  // 内边距
  static EdgeInsets _padding(M2ButtonSize size) {
    return switch (size) {
      M2ButtonSize.small => const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      M2ButtonSize.medium => const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      M2ButtonSize.large => const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
    };
  }

  // 最小尺寸
  static Size _minSize(M2ButtonSize size) {
    return switch (size) {
      M2ButtonSize.small => const Size(64, 32),
      M2ButtonSize.medium => const Size(80, 40),
      M2ButtonSize.large => const Size(96, 48),
    };
  }
}
```

### m2_button_theme.dart

```dart
import 'package:flutter/material.dart';

/// M2 按钮主题配置
class M2ButtonTheme {
  // 圆角
  static const double borderRadius = 6.0;

  // 主按钮
  static const Color primaryBg = Color(0xFF1677FF);
  static const Color primaryFg = Colors.white;

  // 次按钮
  static const Color secondaryBg = Colors.white;
  static const Color secondaryFg = Color(0xFF1677FF);
  static const Color secondaryBorder = Color(0xFFD9D9D9);

  // 幽灵按钮
  static const Color ghostFg = Color(0xFF1677FF);

  // 禁用状态
  static const Color disabledBg = Color(0xFFF5F5F5);
  static const Color disabledFg = Color(0xFFBFBFBF);
  static const Color disabledBorder = Color(0xFFD9D9D9);

  // 按下遮罩
  static const Color pressedOverlay = Color(0x1A000000);
}
```

## 使用示例

```dart
// 主按钮
M2Button(
  label: '确认',
  onPressed: () {},
)

// 次按钮
M2Button(
  label: '取消',
  variant: M2ButtonVariant.secondary,
  onPressed: () {},
)

// 幽灵按钮
M2Button(
  label: '查看更多',
  variant: M2ButtonVariant.ghost,
  onPressed: () {},
)

// 禁用状态
M2Button(
  label: '提交中...',
  onPressed: null,  // 禁用
)

// 带图标
M2Button(
  label: '保存',
  icon: const Icon(Icons.save, size: 16),
  onPressed: () {},
)

// 大尺寸
M2Button(
  label: '立即购买',
  size: M2ButtonSize.large,
  onPressed: () {},
)
```

## 状态说明

| 状态 | 表现 |
|------|------|
| 正常 | 显示对应变体的标准颜色 |
| 按下 | 背景色透明度降至 80%，叠加遮罩 |
| 禁用 | 灰色背景，无边框（主/幽灵）或灰色边框（次按钮）|

## 设计规范

- 主按钮：用于主要操作，蓝色背景白字
- 次按钮：用于次要操作，白底蓝字带边框
- 幽灵按钮：用于弱操作，透明背景蓝字
- 统一圆角：6px
- 统一主色：#1677FF
