import 'package:flutter/material.dart';

/// 通用 AppBar 组件
/// 
/// 提供统一的标题栏样式，支持自定义标题、操作按钮和返回行为
class AppAppBar extends StatelessWidget implements PreferredSizeWidget {
  /// 页面标题
  final String title;
  
  /// 是否显示返回按钮
  final bool showBack;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 背景色
  final Color? backgroundColor;
  
  /// 标题颜色
  final Color? foregroundColor;
  
  /// 是否居中标题
  final bool centerTitle;
  
  /// 返回按钮回调
  final VoidCallback? onBack;

  const AppAppBar({
    super.key,
    required this.title,
    this.showBack = false,
    this.actions,
    this.backgroundColor,
    this.foregroundColor,
    this.centerTitle = true,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: centerTitle,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      automaticallyImplyLeading: showBack,
      leading: showBack
          ? IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: onBack ?? () => Navigator.pop(context),
            )
          : null,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
