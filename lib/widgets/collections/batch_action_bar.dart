// batch_action_bar.dart
// 山径APP - 批量操作工具栏（M7 P1）
// 显示在底部或顶部的批量操作工具栏

import 'package:flutter/material.dart';
import 'collection_selection_manager.dart';

/// 批量操作类型
enum BatchActionType {
  delete,    // 删除
  move,      // 移动
  addTo,     // 添加到其他收藏夹
  share,     // 分享
  export,    // 导出
  tag,       // 添加标签
}

/// 批量操作工具栏
class BatchActionBar extends StatelessWidget {
  final CollectionSelectionManager selectionManager;
  final List<BatchActionType> availableActions;
  final Function(BatchActionType) onActionSelected;
  final VoidCallback onCancel;
  final String? title;
  final bool showAtTop;

  const BatchActionBar({
    Key? key,
    required this.selectionManager,
    this.availableActions = const [
      BatchActionType.delete,
      BatchActionType.move,
      BatchActionType.addTo,
    ],
    required this.onActionSelected,
    required this.onCancel,
    this.title,
    this.showAtTop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: showAtTop ? BorderSide.none : BorderSide(color: colorScheme.outline.withOpacity(0.1)),
          bottom: showAtTop ? BorderSide(color: colorScheme.outline.withOpacity(0.1)) : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, showAtTop ? 2 : -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 取消按钮
          IconButton(
            onPressed: onCancel,
            icon: const Icon(Icons.close),
            tooltip: '取消选择',
          ),
          
          const SizedBox(width: 8),
          
          // 选中数量
          Expanded(
            child: Text(
              title ?? '已选中 ${selectionManager.selectedCount} 项',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          
          // 操作按钮
          ..._buildActionButtons(context),
        ],
      ),
    );
    
    if (showAtTop) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          content,
        ],
      );
    }
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: content,
      ),
    );
  }
  
  List<Widget> _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];
    final theme = Theme.of(context);
    
    for (final action in availableActions) {
      final (icon, label, color) = _getActionInfo(action, theme);
      
      buttons.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: ActionChip(
            avatar: Icon(icon, size: 18),
            label: Text(label),
            backgroundColor: color?.withOpacity(0.1),
            labelStyle: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
            onPressed: () => onActionSelected(action),
          ),
        ),
      );
    }
    
    return buttons;
  }
  
  (IconData, String, Color?) _getActionInfo(
    BatchActionType action,
    ThemeData theme,
  ) {
    switch (action) {
      case BatchActionType.delete:
        return (
          Icons.delete_outline,
          '删除',
          theme.colorScheme.error,
        );
      case BatchActionType.move:
        return (
          Icons.drive_file_move_outline,
          '移动',
          theme.colorScheme.primary,
        );
      case BatchActionType.addTo:
        return (
          Icons.add_to_photos_outline,
          '添加到',
          theme.colorScheme.primary,
        );
      case BatchActionType.share:
        return (
          Icons.share_outlined,
          '分享',
          theme.colorScheme.primary,
        );
      case BatchActionType.export:
        return (
          Icons.download_outlined,
          '导出',
          theme.colorScheme.primary,
        );
      case BatchActionType.tag:
        return (
          Icons.tag_outlined,
          '标签',
          theme.colorScheme.primary,
        );
    }
  }
}

/// 路线批量操作工具栏（简化版）
class TrailBatchActionBar extends StatelessWidget {
  final TrailSelectionManager selectionManager;
  final VoidCallback onDelete;
  final VoidCallback onMove;
  final VoidCallback onCancel;
  final bool showAtTop;

  const TrailBatchActionBar({
    Key? key,
    required this.selectionManager,
    required this.onDelete,
    required this.onMove,
    required this.onCancel,
    this.showAtTop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: showAtTop ? BorderSide.none : BorderSide(color: theme.dividerColor),
          bottom: showAtTop ? BorderSide(color: theme.dividerColor) : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          // 取消按钮
          TextButton(
            onPressed: onCancel,
            child: const Text('取消'),
          ),
          
          const Spacer(),
          
          // 选中数量
          Text(
            '已选 ${selectionManager.selectedCount} 条路线',
            style: theme.textTheme.bodyMedium,
          ),
          
          const Spacer(),
          
          // 移动按钮
          IconButton(
            onPressed: selectionManager.isSelectionMode ? onMove : null,
            icon: const Icon(Icons.drive_file_move_outline),
            tooltip: '移动到其他收藏夹',
          ),
          
          // 删除按钮
          IconButton(
            onPressed: selectionManager.isSelectionMode ? onDelete : null,
            icon: const Icon(Icons.delete_outline),
            tooltip: '从收藏夹移除',
            color: theme.colorScheme.error,
          ),
        ],
      ),
    );
  }
}

/// 批量操作确认对话框
class BatchActionConfirmationDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final Color? confirmColor;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const BatchActionConfirmationDialog({
    Key? key,
    required this.title,
    required this.message,
    this.confirmText = '确定',
    this.confirmColor,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: onCancel,
          child: const Text('取消'),
        ),
        TextButton(
          onPressed: onConfirm,
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? theme.colorScheme.error,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }
}
