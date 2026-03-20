// ================================================================
// Achievement Error Widget
// 成就系统错误状态展示组件
// ================================================================

import 'package:flutter/material.dart';
import '../../services/achievement_errors.dart';
import 'achievement_state_manager.dart';

/// 成就错误展示组件
class AchievementErrorWidget extends StatelessWidget {
  final AchievementServiceError error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const AchievementErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorTitle = AchievementErrorLocalizations.getErrorTitle(error);
    final errorDesc = AchievementErrorLocalizations.getErrorDescription(error);
    final actionText = AchievementErrorLocalizations.getActionButtonText(error);

    // 根据错误类型选择图标
    IconData iconData;
    Color iconColor;
    
    switch (error.code) {
      case 'NETWORK_ERROR':
        iconData = Icons.wifi_off;
        iconColor = Colors.orange;
        break;
      case 'SERVER_ERROR':
        iconData = Icons.cloud_off;
        iconColor = Colors.red;
        break;
      case 'VALIDATION_ERROR':
        iconData = Icons.error_outline;
        iconColor = Colors.amber;
        break;
      case 'CONCURRENT_MODIFICATION':
        iconData = Icons.sync_problem;
        iconColor = Colors.blue;
        break;
      default:
        iconData = Icons.error_outline;
        iconColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              iconData,
              size: 48,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              errorTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorDesc,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (error.details != null && error.details!.isNotEmpty)
              _buildDetailsSection(error.details!),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (onDismiss != null)
                  TextButton(
                    onPressed: onDismiss,
                    child: const Text('取消'),
                  ),
                if (onRetry != null) ...[
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh, size: 18),
                    label: Text(actionText),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(Map<String, dynamic> details) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '详细信息:',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          ...details.entries.map((entry) => Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              '${entry.key}: ${entry.value}',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
                fontFamily: 'monospace',
              ),
            ),
          )),
        ],
      ),
    );
  }
}

/// 带错误处理的内容包装器
class AchievementContentWithError extends StatelessWidget {
  final LoadingState state;
  final AchievementServiceError? error;
  final Widget content;
  final Widget? loadingWidget;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const AchievementContentWithError({
    Key? key,
    required this.state,
    this.error,
    required this.content,
    this.loadingWidget,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 加载中
    if (state == LoadingState.loading) {
      return loadingWidget ?? const Center(
        child: CircularProgressIndicator(),
      );
    }

    // 错误状态
    if (state == LoadingState.error && error != null) {
      return Center(
        child: AchievementErrorWidget(
          error: error!,
          onRetry: onRetry,
          onDismiss: onDismiss,
        ),
      );
    }

    // 成功或空闲状态显示内容
    return content;
  }
}

/// 轻量级错误提示 Snackbar
class AchievementErrorSnackbar {
  static void show(
    BuildContext context, 
    AchievementServiceError error, {
    VoidCallback? onRetry,
  }) {
    final title = AchievementErrorLocalizations.getErrorTitle(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (error.message.isNotEmpty)
                    Text(
                      error.message,
                      style: const TextStyle(fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red[800],
        duration: const Duration(seconds: 4),
        action: onRetry != null
          ? SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
      ),
    );
  }
}
