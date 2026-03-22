// collection_multiselect.dart
// 山径APP - 收藏夹多选模式组件（M7 P1）
// 支持收藏夹列表项的多选功能（复选框/长按），选中状态管理，选中计数显示

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/design_system.dart';

/// 收藏夹多选状态管理器
class CollectionMultiSelectManager extends ChangeNotifier {
  final Set<String> _selectedIds = {};
  
  /// 选中的ID集合
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);
  
  /// 是否处于选择模式
  bool get isSelectionMode => _selectedIds.isNotEmpty;
  
  /// 选中数量
  int get selectedCount => _selectedIds.length;
  
  /// 是否全选（相对于传入的totalIds）
  bool isAllSelected(List<String> totalIds) {
    if (totalIds.isEmpty) return false;
    return _selectedIds.length == totalIds.length &&
        totalIds.every(_selectedIds.contains);
  }
  
  /// 是否部分选中
  bool isPartialSelected(List<String> totalIds) {
    if (totalIds.isEmpty) return false;
    return _selectedIds.isNotEmpty &&
        totalIds.any(_selectedIds.contains) &&
        !isAllSelected(totalIds);
  }
  
  /// 切换单个项目的选择状态
  void toggle(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
    } else {
      _selectedIds.add(id);
    }
    notifyListeners();
  }
  
  /// 选择单个项目
  void select(String id) {
    if (!_selectedIds.contains(id)) {
      _selectedIds.add(id);
      notifyListeners();
    }
  }
  
  /// 取消选择单个项目
  void deselect(String id) {
    if (_selectedIds.contains(id)) {
      _selectedIds.remove(id);
      notifyListeners();
    }
  }
  
  /// 全选（基于传入的ID列表）
  void selectAll(List<String> ids) {
    _selectedIds.addAll(ids);
    notifyListeners();
  }
  
  /// 取消全选
  void deselectAll() {
    if (_selectedIds.isNotEmpty) {
      _selectedIds.clear();
      notifyListeners();
    }
  }
  
  /// 切换全选状态
  void toggleAll(List<String> ids) {
    if (isAllSelected(ids)) {
      deselectAll();
    } else {
      selectAll(ids);
    }
  }
  
  /// 清除所有选择
  void clear() {
    if (_selectedIds.isNotEmpty) {
      _selectedIds.clear();
      notifyListeners();
    }
  }
  
  /// 检查是否选中
  bool isSelected(String id) => _selectedIds.contains(id);
  
  /// 批量选择
  void selectMultiple(List<String> ids) {
    _selectedIds.addAll(ids);
    notifyListeners();
  }
  
  /// 批量取消选择
  void deselectMultiple(List<String> ids) {
    for (final id in ids) {
      _selectedIds.remove(id);
    }
    notifyListeners();
  }
  
  @override
  void dispose() {
    _selectedIds.clear();
    super.dispose();
  }
}

/// 收藏夹多选列表项组件
class CollectionMultiSelectItem extends StatelessWidget {
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

  const CollectionMultiSelectItem({
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
    
    final backgroundColor = isSelected
        ? (selectedBackgroundColor ?? DesignSystem.getPrimary(context).withOpacity(0.05))
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
                child: _buildCheckbox(context),
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

  Widget _buildCheckbox(BuildContext context) {
    final selectedColor = DesignSystem.getPrimary(context);
    final unselectedColor = DesignSystem.getBorder(context);
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: isSelected ? selectedColor.withOpacity(0.1) : Colors.transparent,
        border: Border.all(
          color: isSelected ? selectedColor : unselectedColor.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isSelected ? 1.0 : 0.0,
          child: Icon(
            Icons.check,
            size: 14,
            color: selectedColor,
          ),
        ),
      ),
    );
  }
}

/// 收藏夹多选卡片组件
class CollectionMultiSelectCard extends StatelessWidget {
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

  const CollectionMultiSelectCard({
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
    
    final borderColor = isSelected
        ? (selectedBorderColor ?? DesignSystem.getPrimary(context))
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
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignSystem.getPrimary(context).withOpacity(0.1)
                          : Colors.transparent,
                      border: Border.all(
                        color: isSelected
                            ? DesignSystem.getPrimary(context)
                            : DesignSystem.getBorder(context).withOpacity(0.3),
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 200),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: Icon(
                          Icons.check,
                          size: 16,
                          color: DesignSystem.getPrimary(context),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// 全选/取消全选头部组件
class CollectionSelectAllHeader extends StatelessWidget {
  final bool isAllSelected;
  final bool isPartialSelected;
  final VoidCallback onSelectAll;
  final VoidCallback onDeselectAll;
  final int selectedCount;
  final int totalCount;
  final String title;

  const CollectionSelectAllHeader({
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
        color: DesignSystem.getBackground(context),
        border: Border(bottom: BorderSide(color: DesignSystem.getDivider(context))),
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
                      ? DesignSystem.getPrimary(context).withOpacity(0.1)
                      : Colors.transparent,
                  border: Border.all(
                    color: isAllSelected
                        ? DesignSystem.getPrimary(context)
                        : DesignSystem.getBorder(context).withOpacity(0.3),
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
                      color: DesignSystem.getPrimary(context),
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

/// 提供多选管理器的InheritedWidget
class CollectionMultiSelectProvider
    extends InheritedNotifier<CollectionMultiSelectManager> {
  const CollectionMultiSelectProvider({
    Key? key,
    required CollectionMultiSelectManager manager,
    required Widget child,
  }) : super(key: key, notifier: manager, child: child);
  
  static CollectionMultiSelectManager? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<CollectionMultiSelectProvider>()
        ?.notifier;
  }
}