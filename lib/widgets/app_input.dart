import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// 带标签的文本输入框组件
/// 支持验证错误提示和密码模式，适配暗黑模式
class AppInput extends StatelessWidget {
  /// 输入框标签
  final String label;

  /// 提示文本
  final String? hint;

  /// 控制器
  final TextEditingController? controller;

  /// 是否为密码模式
  final bool isPassword;

  /// 验证错误提示
  final String? errorText;

  /// 输入类型
  final TextInputType? keyboardType;

  /// 值变化回调
  final ValueChanged<String>? onChanged;

  /// 提交回调
  final ValueChanged<String>? onSubmitted;

  const AppInput({
    super.key,
    required this.label,
    this.hint,
    this.controller,
    this.isPassword = false,
    this.errorText,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标签
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: DesignSystem.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 6),
        // 输入框
        TextField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          onChanged: onChanged,
          onSubmitted: onSubmitted,
          style: TextStyle(
            color: DesignSystem.getTextPrimary(context),
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: DesignSystem.getTextTertiary(context),
            ),
            errorText: errorText,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: true,
            fillColor: isDark ? DesignSystem.backgroundTertiaryDark : theme.colorScheme.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.error,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
