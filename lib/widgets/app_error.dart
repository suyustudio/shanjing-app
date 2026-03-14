import 'package:flutter/material.dart';

/// 通用错误状态组件
/// 
/// 显示错误信息和重试按钮
class AppError extends StatelessWidget {
  /// 错误消息
  final String message;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  /// 重试按钮文本
  final String retryText;
  
  /// 图标
  final IconData icon;
  
  /// 图标颜色
  final Color? iconColor;

  const AppError({
    super.key,
    required this.message,
    this.onRetry,
    this.retryText = '重试',
    this.icon = Icons.error_outline,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor ?? (isDark ? Colors.grey[600] : Colors.grey[400]),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onRetry,
                child: Text(retryText),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 网络错误组件
class AppNetworkError extends StatelessWidget {
  final VoidCallback? onRetry;

  const AppNetworkError({
    super.key,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return AppError(
      message: '网络连接失败，请检查网络',
      onRetry: onRetry,
      icon: Icons.wifi_off,
      iconColor: isDark ? Colors.grey[600] : Colors.grey[400],
    );
  }
}
