// collection_selection_manager.dart
// 山径APP - 收藏夹选择状态管理器（M7 P1）
// 管理列表项的多选状态

import 'package:flutter/foundation.dart';

/// 选择状态管理器
class CollectionSelectionManager extends ChangeNotifier {
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

/// 路线选择状态管理器（针对收藏夹内的路线）
class TrailSelectionManager extends ChangeNotifier {
  final Set<String> _selectedTrailIds = {};
  
  Set<String> get selectedTrailIds => Set.unmodifiable(_selectedTrailIds);
  bool get isSelectionMode => _selectedTrailIds.isNotEmpty;
  int get selectedCount => _selectedTrailIds.length;
  
  void toggle(String trailId) {
    if (_selectedTrailIds.contains(trailId)) {
      _selectedTrailIds.remove(trailId);
    } else {
      _selectedTrailIds.add(trailId);
    }
    notifyListeners();
  }
  
  void select(String trailId) {
    if (!_selectedTrailIds.contains(trailId)) {
      _selectedTrailIds.add(trailId);
      notifyListeners();
    }
  }
  
  void deselect(String trailId) {
    if (_selectedTrailIds.contains(trailId)) {
      _selectedTrailIds.remove(trailId);
      notifyListeners();
    }
  }
  
  void selectAll(List<String> trailIds) {
    _selectedTrailIds.addAll(trailIds);
    notifyListeners();
  }
  
  void deselectAll() {
    if (_selectedTrailIds.isNotEmpty) {
      _selectedTrailIds.clear();
      notifyListeners();
    }
  }
  
  void toggleAll(List<String> trailIds) {
    final allSelected = trailIds.isNotEmpty &&
        trailIds.every(_selectedTrailIds.contains);
    if (allSelected) {
      deselectAll();
    } else {
      selectAll(trailIds);
    }
  }
  
  void clear() {
    if (_selectedTrailIds.isNotEmpty) {
      _selectedTrailIds.clear();
      notifyListeners();
    }
  }
  
  bool isSelected(String trailId) => _selectedTrailIds.contains(trailId);
  
  @override
  void dispose() {
    _selectedTrailIds.clear();
    super.dispose();
  }
}

/// 选择模式提供者（简化版）
class SelectionProvider extends InheritedNotifier<CollectionSelectionManager> {
  const SelectionProvider({
    Key? key,
    required CollectionSelectionManager manager,
    required Widget child,
  }) : super(key: key, notifier: manager, child: child);
  
  static CollectionSelectionManager? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<SelectionProvider>()
        ?.notifier;
  }
}

/// 选择模式提供者（路线版）
class TrailSelectionProvider extends InheritedNotifier<TrailSelectionManager> {
  const TrailSelectionProvider({
    Key? key,
    required TrailSelectionManager manager,
    required Widget child,
  }) : super(key: key, notifier: manager, child: child);
  
  static TrailSelectionManager? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<TrailSelectionProvider>()
        ?.notifier;
  }
}
