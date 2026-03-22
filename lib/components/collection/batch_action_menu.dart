// batch_action_menu.dart
// 山径APP - 收藏夹批量操作菜单组件（M7 P1）
// 弹出菜单：删除、移动、取消选择，移动目标收藏夹选择器，确认对话框

import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// 收藏夹模型（简化）
class CollectionItem {
  final String id;
  final String name;
  final int trailCount;
  final bool isDefault;

  const CollectionItem({
    required this.id,
    required this.name,
    required this.trailCount,
    this.isDefault = false,
  });
}

/// 批量操作菜单组件
class CollectionBatchActionMenu {
  /// 显示批量操作底部菜单
  static Future<CollectionBatchAction?> showBottomMenu({
    required BuildContext context,
    required int selectedCount,
    required List<CollectionBatchAction> availableActions,
    String title = '批量操作',
  }) async {
    return await showModalBottomSheet<CollectionBatchAction>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _BottomMenuContent(
          selectedCount: selectedCount,
          availableActions: availableActions,
          title: title,
        );
      },
    );
  }

  /// 显示移动目标收藏夹选择器
  static Future<String?> showMoveToCollectionSelector({
    required BuildContext context,
    required List<CollectionItem> collections,
    required String currentCollectionId,
    String title = '移动到收藏夹',
    String confirmText = '移动',
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _MoveToCollectionSelector(
          collections: collections,
          currentCollectionId: currentCollectionId,
          title: title,
          confirmText: confirmText,
        );
      },
    );
  }

  /// 显示批量删除确认对话框
  static Future<bool> showDeleteConfirmationDialog({
    required BuildContext context,
    required int selectedCount,
    String title = '确认删除',
    String? message,
    String confirmText = '删除',
    String cancelText = '取消',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(message ?? '确定要从收藏夹删除 $selectedCount 项吗？此操作不可撤销。'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelText),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  child: Text(confirmText),
                ),
              ],
            );
          },
        ) ??
        false;
  }

  /// 显示批量移动确认对话框
  static Future<bool> showMoveConfirmationDialog({
    required BuildContext context,
    required int selectedCount,
    required String targetCollectionName,
    String title = '确认移动',
    String? message,
    String confirmText = '移动',
    String cancelText = '取消',
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(title),
              content: Text(
                  message ?? '确定要将 $selectedCount 项移动到 "$targetCollectionName" 吗？'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(cancelText),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: Text(confirmText),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

/// 批量操作类型（用于菜单）
enum CollectionBatchAction {
  delete,
  move,
  tag,
  share,
  cancel,
  selectAll,
  deselectAll,
}

/// 底部菜单内容组件
class _BottomMenuContent extends StatelessWidget {
  final int selectedCount;
  final List<CollectionBatchAction> availableActions;
  final String title;

  const _BottomMenuContent({
    required this.selectedCount,
    required this.availableActions,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题栏
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '已选 $selectedCount 项',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),

        // 操作列表
        ...availableActions.map((action) {
          return _buildMenuItem(context, action);
        }).toList(),

        // 取消按钮
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextButton(
            onPressed: () => Navigator.of(context).pop(CollectionBatchAction.cancel),
            style: TextButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('取消'),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildMenuItem(BuildContext context, CollectionBatchAction action) {
    final theme = Theme.of(context);
    final (icon, label, color) = _getActionInfo(action, theme);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(color: color),
      ),
      trailing: action == CollectionBatchAction.selectAll ||
              action == CollectionBatchAction.deselectAll
          ? null
          : const Icon(Icons.chevron_right),
      onTap: () => Navigator.of(context).pop(action),
    );
  }

  (IconData, String, Color) _getActionInfo(
    CollectionBatchAction action,
    ThemeData theme,
  ) {
    switch (action) {
      case CollectionBatchAction.delete:
        return (
          Icons.delete_outline,
          '删除',
          theme.colorScheme.error,
        );
      case CollectionBatchAction.move:
        return (
          Icons.drive_file_move_outline,
          '移动到其他收藏夹',
          theme.colorScheme.primary,
        );
      case CollectionBatchAction.tag:
        return (
          Icons.tag_outlined,
          '添加标签',
          theme.colorScheme.primary,
        );
      case CollectionBatchAction.share:
        return (
          Icons.share_outlined,
          '分享',
          theme.colorScheme.primary,
        );
      case CollectionBatchAction.cancel:
        return (
          Icons.close,
          '取消选择',
          theme.colorScheme.onSurface.withOpacity(0.6),
        );
      case CollectionBatchAction.selectAll:
        return (
          Icons.check_box_outlined,
          '全选',
          theme.colorScheme.primary,
        );
      case CollectionBatchAction.deselectAll:
        return (
          Icons.check_box_outline_blank,
          '取消全选',
          theme.colorScheme.onSurface.withOpacity(0.6),
        );
    }
  }
}

/// 移动到收藏夹选择器组件
class _MoveToCollectionSelector extends StatefulWidget {
  final List<CollectionItem> collections;
  final String currentCollectionId;
  final String title;
  final String confirmText;

  const _MoveToCollectionSelector({
    required this.collections,
    required this.currentCollectionId,
    required this.title,
    required this.confirmText,
  });

  @override
  State<_MoveToCollectionSelector> createState() =>
      _MoveToCollectionSelectorState();
}

class _MoveToCollectionSelectorState extends State<_MoveToCollectionSelector> {
  String? _selectedCollectionId;

  @override
  void initState() {
    super.initState();
    // 默认不选中当前收藏夹
    _selectedCollectionId = null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 标题栏
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Text(
                widget.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close),
                iconSize: 20,
              ),
            ],
          ),
        ),

        // 收藏夹列表
        Expanded(
          child: ListView.builder(
            shrinkWrap: true,
            padding: const EdgeInsets.all(0),
            itemCount: widget.collections.length,
            itemBuilder: (context, index) {
              final collection = widget.collections[index];
              final isCurrent = collection.id == widget.currentCollectionId;
              final isSelected = _selectedCollectionId == collection.id;

              return ListTile(
                leading: isCurrent
                    ? Icon(
                        Icons.folder,
                        color: colorScheme.primary,
                      )
                    : const Icon(Icons.folder_outlined),
                title: Text(collection.name),
                subtitle: Text('${collection.trailCount} 条路线'),
                trailing: isSelected
                    ? Icon(
                        Icons.check_circle,
                        color: colorScheme.primary,
                      )
                    : null,
                onTap: isCurrent
                    ? null
                    : () {
                        setState(() {
                          _selectedCollectionId = collection.id;
                        });
                      },
                enabled: !isCurrent,
              );
            },
          ),
        ),

        // 底部操作栏
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: colorScheme.outline.withOpacity(0.1)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('取消'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedCollectionId != null
                      ? () => Navigator.of(context).pop(_selectedCollectionId)
                      : null,
                  child: Text(widget.confirmText),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 批量操作菜单按钮（浮动按钮）
class CollectionBatchActionMenuButton extends StatelessWidget {
  final int selectedCount;
  final List<CollectionBatchAction> availableActions;
  final Function(CollectionBatchAction) onActionSelected;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const CollectionBatchActionMenuButton({
    Key? key,
    required this.selectedCount,
    this.availableActions = const [
      CollectionBatchAction.delete,
      CollectionBatchAction.move,
      CollectionBatchAction.tag,
      CollectionBatchAction.share,
    ],
    required this.onActionSelected,
    this.backgroundColor,
    this.foregroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return FloatingActionButton.extended(
      onPressed: () async {
        final action = await CollectionBatchActionMenu.showBottomMenu(
          context: context,
          selectedCount: selectedCount,
          availableActions: availableActions,
        );
        if (action != null && action != CollectionBatchAction.cancel) {
          onActionSelected(action);
        }
      },
      backgroundColor: backgroundColor ?? colorScheme.primary,
      foregroundColor: foregroundColor ?? colorScheme.onPrimary,
      icon: const Icon(Icons.more_vert),
      label: Text('$selectedCount 项'),
      heroTag: 'batch_action_menu',
    );
  }
}