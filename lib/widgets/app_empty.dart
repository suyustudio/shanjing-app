import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// 空状态组件
class AppEmpty extends StatelessWidget {
  final String message;
  final IconData? icon;

  const AppEmpty({
    super.key,
    required this.message,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon ?? Icons.inbox_outlined,
            size: 64,
            color: DesignSystem.getTextTertiary(context),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: DesignSystem.fontBody,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}
