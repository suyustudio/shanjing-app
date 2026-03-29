import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// 通用 AppBar 组件
/// 
/// 提供统一的标题栏样式，支持自定义标题、操作按钮和返回行为
/// 自动适配暗黑模式
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 页面标题
  final String title;
  
  /// 是否显示返回按钮
  final bool showBack;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 背景色（如不指定则自动根据主题选择）
  final Color? backgroundColor;
  
  /// 标题颜色（如不指定则自动根据主题选择）
  final Color? foregroundColor;
  
  /// 是否居中标题
  final bool centerTitle;
  
  /// 返回按钮回调
  /// 可以是同步或异步函数，返回 Future<bool> 表示是否应该返回
  final Future<bool> Function()? onBackAsync;
  
  /// 同步返回按钮回调（兼容旧代码）
  final VoidCallback? onBack;
  
  /// 底部阴影高度
  final double? elevation;

  const AppAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.onBack,
    this.onBackAsync,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 自动选择默认颜色
    final defaultBgColor = isDark 
        ? DesignSystem.backgroundSecondaryDark 
        : DesignSystem.primary;
    final defaultFgColor = isDark 
        ? DesignSystem.textPrimaryDark 
        : DesignSystem.textInverse;
    
    return AppBar(
      title: Text(
        title,
        style: TextStyle(
          color: foregroundColor ?? defaultFgColor,
        ),
      ),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? defaultBgColor,
      foregroundColor: foregroundColor ?? defaultFgColor,
      elevation: elevation ?? 0,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: foregroundColor ?? defaultFgColor,
              ),
              onPressed: () async {
                if (onBackAsync != null) {
                  final shouldPop = await onBackAsync!();
                  if (shouldPop && context.mounted) {
                    Navigator.pop(context);
                  }
                } else if (onBack != null) {
                  onBack!();
                } else {
                  Navigator.pop(context);
                }
              },
            )
          : null,
      actions: actions?.map((action) {
        // 为 IconButton 包装颜色
        if (action is IconButton && action.color == null) {
          return IconButton(
            icon: action.icon,
            onPressed: action.onPressed,
            color: foregroundColor ?? defaultFgColor,
          );
        }
        return action;
      }).toList(),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
