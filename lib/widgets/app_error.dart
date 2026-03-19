import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// 优化后的通用错误状态组件
/// 
/// 显示错误信息和重试按钮
/// 设计原则：
/// - 不使用全屏红色背景，避免用户焦虑
/// - 使用应用标准背景色
/// - 提供明确的操作按钮
/// - 添加友好提示文案
class AppError extends StatelessWidget {
  /// 错误消息
  final String message;
  
  /// 错误标题（可选）
  final String? title;
  
  /// 重试回调
  final VoidCallback? onRetry;
  
  /// 重试按钮文本
  final String retryText;
  
  /// 图标
  final IconData icon;
  
  /// 是否显示返回按钮
  final bool showBackButton;

  const AppError({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.retryText = '重试',
    this.icon = Icons.error_outline,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 使用应用背景色，非红色
    return Container(
      color: DesignSystem.getBackground(context),
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 插画风格图标容器
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: isDark ? Colors.grey[500] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                
                // 标题
                Text(
                  title ?? '出错了',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 12),
                
                // 错误信息
                Text(
                  message,
                  style: TextStyle(
                    color: DesignSystem.getTextSecondary(context),
                    fontSize: 14,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                
                // 主要操作按钮（重试）
                if (onRetry != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(retryText),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: DesignSystem.getPrimary(context),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // 次要操作（返回）
                if (showBackButton)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).maybePop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: DesignSystem.getTextSecondary(context),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        side: BorderSide(
                          color: DesignSystem.getDivider(context),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('返回上一页'),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// 网络错误组件
class AppNetworkError extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool showBackButton;

  const AppNetworkError({
    super.key,
    this.onRetry,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppError(
      title: '网络连接失败',
      message: '请检查您的网络设置，或稍后重试',
      onRetry: onRetry,
      icon: Icons.wifi_off_outlined,
      showBackButton: showBackButton,
    );
  }
}

/// 服务器错误组件
class AppServerError extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool showBackButton;

  const AppServerError({
    super.key,
    this.onRetry,
    this.showBackButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return AppError(
      title: '服务器开小差了',
      message: '我们的服务器暂时无法响应，请稍后再试',
      onRetry: onRetry,
      icon: Icons.cloud_off_outlined,
      showBackButton: showBackButton,
    );
  }
}

/// 空状态组件（无数据）
class AppEmptyState extends StatelessWidget {
  final String message;
  final String? title;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const AppEmptyState({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      color: DesignSystem.getBackground(context),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[800] : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  size: 40,
                  color: isDark ? Colors.grey[500] : Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),
              if (title != null) ...[
                Text(
                  title!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 8),
              ],
              Text(
                message,
                style: TextStyle(
                  color: DesignSystem.getTextSecondary(context),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              if (onAction != null && actionText != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onAction,
                  child: Text(actionText!),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
