// multi_select_checkbox.dart
// 山径APP - 多选复选框组件（M7 P1）
// 支持列表项多选的复选框

import 'package:flutter/material.dart';

/// 多选复选框位置
enum CheckboxPosition {
  leading,    // 左侧（列表项前面）
  trailing,   // 右侧（列表项后面）
  overlay,    // 悬浮覆盖（角标形式）
}

/// 多选复选框组件
class MultiSelectCheckbox extends StatelessWidget {
  final bool isSelected;
  final bool isSelectionMode;
  final CheckboxPosition position;
  final VoidCallback? onTap;
  final double size;
  final Color? selectedColor;
  final Color? unselectedColor;
  final bool showBorder;
  final Widget? child;

  const MultiSelectCheckbox({
    Key? key,
    required this.isSelected,
    required this.isSelectionMode,
    this.position = CheckboxPosition.leading,
    this.onTap,
    this.size = 24,
    this.selectedColor,
    this.unselectedColor,
    this.showBorder = false,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final checkbox = _buildCheckbox(theme);
    
    if (child == null) {
      return checkbox;
    }
    
    switch (position) {
      case CheckboxPosition.leading:
        return Row(
          children: [
            if (isSelectionMode) checkbox,
            const SizedBox(width: 12),
            Expanded(child: child!),
          ],
        );
      case CheckboxPosition.trailing:
        return Row(
          children: [
            Expanded(child: child!),
            if (isSelectionMode) checkbox,
          ],
        );
      case CheckboxPosition.overlay:
        return Stack(
          children: [
            child!,
            if (isSelectionMode)
              Positioned(
                top: 8,
                left: 8,
                child: checkbox,
              ),
          ],
        );
    }
  }
  
  Widget _buildCheckbox(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final selectedColor = this.selectedColor ?? colorScheme.primary;
    final unselectedColor = this.unselectedColor ?? colorScheme.outline;
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
          border: showBorder
              ? Border.all(
                  color: isSelected ? selectedColor : unselectedColor.withOpacity(0.3),
                  width: 2,
                )
              : null,
          borderRadius: BorderRadius.circular(size / 2),
        ),
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: isSelected ? 1.0 : 0.0,
            child: Icon(
              Icons.check,
              size: size * 0.6,
              color: selectedColor,
            ),
          ),
        ),
      ),
    );
  }
}

/// 带多选功能的列表项
class MultiSelectListItem extends StatelessWidget {
  final String id;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onSelectTap;
  final Widget leading;
  final Widget title;
  final Widget? subtitle;
  final Widget? trailing;
  final EdgeInsetsGeometry padding;
  final Color? selectedBackgroundColor;

  const MultiSelectListItem({
    Key? key,
    required this.id,
    required this.isSelected,
    required this.isSelectionMode,
    this.onTap,
    this.onSelectTap,
    required this.leading,
    required this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.selectedBackgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final backgroundColor = isSelected
        ? (selectedBackgroundColor ?? colorScheme.primary.withOpacity(0.05))
        : Colors.transparent;
    
    return Material(
      color: backgroundColor,
      child: InkWell(
        onTap: onTap,
        onLongPress: onSelectTap,
        child: Container(
          padding: padding,
          child: Row(
            children: [
              // 选择复选框
              GestureDetector(
                onTap: onSelectTap,
                child: MultiSelectCheckbox(
                  isSelected: isSelected,
                  isSelectionMode: isSelectionMode,
                  position: CheckboxPosition.leading,
                  size: 22,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 左侧内容
              leading,
              
              const SizedBox(width: 16),
              
              // 主内容
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    title,
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      subtitle!,
                    ],
                  ],
                ),
              ),
              
              // 右侧内容
              if (trailing != null) ...[
                const SizedBox(width: 12),
                trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// 带多选功能的卡片
class MultiSelectCard extends StatelessWidget {
  final String id;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback? onTap;
  final VoidCallback? onSelectTap;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final double elevation;
  final BorderRadius borderRadius;
  final Color? selectedBorderColor;

  const MultiSelectCard({
    Key? key,
    required this.id,
    required this.isSelected,
    required this.isSelectionMode,
    this.onTap,
    this.onSelectTap,
    required this.child,
    this.margin = const EdgeInsets.all(8),
    this.elevation = 1,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.selectedBorderColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final borderColor = isSelected
        ? (selectedBorderColor ?? colorScheme.primary)
        : Colors.transparent;
    
    return GestureDetector(
      onTap: onTap,
      onLongPress: onSelectTap,
      child: Container(
        margin: margin,
        child: Stack(
          children: [
            // 卡片内容
            Card(
              elevation: elevation,
              shape: RoundedRectangleBorder(
                borderRadius: borderRadius,
                side: BorderSide(
                  color: borderColor,
                  width: isSelected ? 2 : 0,
                ),
              ),
              child: child,
            ),
            
            // 选择复选框（悬浮）
            if (isSelectionMode)
              Positioned(
                top: 8,
                left: 8,
                child: GestureDetector(
                  onTap: onSelectTap,
                  child: MultiSelectCheckbox(
                    isSelected: isSelected,
                    isSelectionMode: isSelectionMode,
                    position: CheckboxPosition.overlay,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 全选/取消全选头部
class SelectAllHeader extends StatelessWidget {
  final bool isAllSelected;
  final bool isPartialSelected;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final int selectedCount;
  final int totalCount;
  final String title;

  const SelectAllHeader({
    Key? key,
    required this.isAllSelected,
    required this.isPartialSelected,
    required this.onSelectAll,
    required this.onDeselectAll,
    required this.selectedCount,
    required this.totalCount,
    this.title = '选择全部',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor)),
      ),
      child: Row(
        children: [
          // 选择全部复选框
          GestureDetector(
            onTap: isAllSelected ? onDeselectAll : onSelectAll,
            child: Container(
              padding: const EdgeInsets.all(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isAllSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isAllSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withOpacity(0.3),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Center(
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: isAllSelected ? 1.0 : (isPartialSelected ? 0.5 : 0.0),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 标题和计数
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (selectedCount > 0)
                  Text(
                    '已选择 $selectedCount/$totalCount',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
