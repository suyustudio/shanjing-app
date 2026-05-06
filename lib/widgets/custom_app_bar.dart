// ================================================================
// Custom App Bar
// 通用自定义应用栏组件
// ================================================================

import 'package:flutter/material.dart';

/// 通用自定义应用栏
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final Widget? leading;
  final double height;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.bottom,
    this.leading,
    this.height = kToolbarHeight,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: actions,
      bottom: bottom,
      leading: leading,
    );
  }

  @override
  Size get preferredSize {
    final bottomHeight = bottom?.preferredSize.height ?? 0;
    return Size.fromHeight(height + bottomHeight);
  }
}
