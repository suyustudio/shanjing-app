// batch_action_bar.dart
// 山径APP - 收藏夹批量操作栏组件（M7 P1）
// 浮动操作栏，显示选中数量，提供删除、移动到、取消等操作按钮，支持动画显示/隐藏

import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// 批量操作类型（收藏夹专用）
enum CollectionBatchActionType {
  delete,    // 删除
  move,      // 移动到其他收藏夹
  tag,       // 添加标签
  share,     // 分享
  cancel,    // 取消选择
}

/// 批量操作栏组件
class CollectionBatchActionBar extends StatefulWidget {
  final int selectedCount;
  final List<CollectionBatchActionType> availableActions;
  final Function(CollectionBatchActionType) onActionSelected;
  final Function(CollectionBatchActionType)? onActionLongPressed;
  final VoidCallback onCancel;
  final String? title;
  final bool showAtTop;
  final bool showAnimation;

  const CollectionBatchActionBar({
    Key? key,
    required this.selectedCount,
    this.availableActions = const [
      CollectionBatchActionType.delete,
      CollectionBatchActionType.move,
      CollectionBatchActionType.tag,
    ],
    required this.onActionSelected,
    this.onActionLongPressed,
    required this.onCancel,
    this.title,
    this.showAtTop = false,
    this.showAnimation = true,
  }) : super(key: key);

  @override
  State<CollectionBatchActionBar> createState() => _CollectionBatchActionBarState();
}

class _CollectionBatchActionBarState extends State<CollectionBatchActionBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    
    if (widget.showAnimation) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CollectionBatchActionBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedCount == 0 && oldWidget.selectedCount > 0) {
      // 选中数量变为0时隐藏动画
      if (widget.showAnimation) {
        _animationController.reverse();
      }
    } else if (widget.selectedCount > 0 && oldWidget.selectedCount == 0) {
      // 从0变为有选中时显示动画
      if (widget.showAnimation) {
        _animationController.forward();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final content = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DesignSystem.getBackground(context),
        border: Border(
          top: widget.showAtTop ? BorderSide.none : BorderSide(color: DesignSystem.getBorder(context).withOpacity(0.1)),
          bottom: widget.showAtTop ? BorderSide(color: DesignSystem.getBorder(context).withOpacity(0.1)) : BorderSide.none,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, widget.showAtTop ? 2 : -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 取消按钮
          IconButton(
            onPressed: widget.onCancel,
            icon: const Icon(Icons.close),
            tooltip: '取消选择',
            color: DesignSystem.getTextPrimary(context).withOpacity(0.6),
          ),
          
          const SizedBox(width: 8),
          
          // 选中数量
          Expanded(
            child: Text(
              widget.title ?? '已选中 ${widget.selectedCount} 项',
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
    
    Widget animatedContent = widget.showAnimation
        ? SizeTransition(
            sizeFactor: _animation,
            axisAlignment: widget.showAtTop ? -1 : 1,
            child: content,
          )
        : content;
    
    if (widget.showAtTop) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          animatedContent,
        ],
      );
    }
    
    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: animatedContent,
      ),
    );
  }
  
  List<Widget> _buildActionButtons(BuildContext context) {
    final buttons = <Widget>[];
    final theme = Theme.of(context);
    
    for (final action in widget.availableActions) {
      if (action == CollectionBatchActionType.cancel) {
        continue; // 取消按钮已经在左侧
      }
      
      final (icon, label, color) = _getActionInfo(action, context);
      
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
            onPressed: () => widget.onActionSelected(action),
            onLongPress: widget.onActionLongPressed != null
                ? () => widget.onActionLongPressed!(action)
                : null,
          ),
        ),
      );
    }
    
    return buttons;
  }
  
  (IconData, String, Color?) _getActionInfo(
    CollectionBatchActionType action,
    BuildContext context,
  ) {
    switch (action) {
      case CollectionBatchActionType.delete:
        return (
          Icons.delete_outline,
          '删除',
          DesignSystem.getError(context),
        );
      case CollectionBatchActionType.move:
        return (
          Icons.drive_file_move_outline,
          '移动',
          DesignSystem.getPrimary(context),
        );
      case CollectionBatchActionType.tag:
        return (
          Icons.tag_outlined,
          '标签',
          DesignSystem.getPrimary(context),
        );
      case CollectionBatchActionType.share:
        return (
          Icons.share_outlined,
          '分享',
          DesignSystem.getPrimary(context),
        );
      case CollectionBatchActionType.cancel:
        return (
          Icons.close,
          '取消',
          DesignSystem.getTextPrimary(context).withOpacity(0.6),
        );
    }
  }
}

/// 简化版批量操作栏（仅显示选中数量和取消按钮）
class SimpleCollectionBatchActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onCancel;
  final bool showAtTop;

  const SimpleCollectionBatchActionBar({
    Key? key,
    required this.selectedCount,
    required this.onCancel,
    this.showAtTop = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DesignSystem.getBackground(context),
        border: Border(
          top: showAtTop ? BorderSide.none : BorderSide(color: DesignSystem.getDivider(context)),
          bottom: showAtTop ? BorderSide(color: DesignSystem.getDivider(context)) : BorderSide.none,
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
            '已选 $selectedCount 项',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          
          const Spacer(),
          
          // 提示文本
          Text(
            '长按项目可多选',
            style: theme.textTheme.bodySmall?.copyWith(
              color: DesignSystem.getTextPrimary(context).withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}