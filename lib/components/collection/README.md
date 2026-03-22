# 收藏夹增强功能组件库（M7 P1）

本库提供收藏夹增强功能的前端核心组件，支持批量操作、多选模式等功能。

## 组件列表

### 1. CollectionMultiSelect（多选模式组件）
- **文件**: `collection_multiselect.dart`
- **功能**: 列表项多选支持（复选框/长按）、选中状态管理、选中计数显示
- **核心组件**:
  - `CollectionMultiSelectManager`: 选择状态管理器
  - `CollectionMultiSelectItem`: 带多选功能的列表项
  - `CollectionMultiSelectCard`: 带多选功能的卡片
  - `CollectionSelectAllHeader`: 全选/取消全选头部
  - `CollectionMultiSelectProvider`: 选择状态提供者

### 2. CollectionBatchActionBar（批量操作栏）
- **文件**: `batch_action_bar.dart`
- **功能**: 浮动操作栏，显示选中数量，提供删除、移动到、取消等操作按钮
- **核心组件**:
  - `CollectionBatchActionBar`: 完整功能操作栏（支持动画）
  - `SimpleCollectionBatchActionBar`: 简化版操作栏

### 3. CollectionBatchActionMenu（批量操作菜单）
- **文件**: `batch_action_menu.dart`
- **功能**: 弹出菜单（删除、移动、取消选择）、移动目标收藏夹选择器、确认对话框
- **核心组件**:
  - `CollectionBatchActionMenu`: 静态方法集合
  - `CollectionBatchActionMenuButton`: 浮动菜单按钮

## 快速开始

### 安装依赖
确保在 `pubspec.yaml` 中已添加 `provider` 依赖：

```yaml
dependencies:
  provider: ^6.1.1
```

### 基本用法示例

#### 1. 多选列表实现

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hangzhou_guide/components/collection/collection_multiselect.dart';

class CollectionListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CollectionMultiSelectManager(),
      child: Scaffold(
        appBar: AppBar(title: Text('我的收藏夹')),
        body: _buildList(),
        bottomSheet: _buildActionBar(context),
      ),
    );
  }

  Widget _buildList() {
    final collections = [
      {'id': '1', 'name': '工作路线', 'count': 5},
      {'id': '2', 'name': '周末徒步', 'count': 3},
      {'id': '3', 'name': '家庭出行', 'count': 7},
    ];

    return Consumer<CollectionMultiSelectManager>(
      builder: (context, manager, child) {
        return ListView.builder(
          itemCount: collections.length,
          itemBuilder: (context, index) {
            final collection = collections[index];
            final isSelected = manager.isSelected(collection['id']!);

            return CollectionMultiSelectItem(
              id: collection['id']!,
              isSelected: isSelected,
              isSelectionMode: manager.isSelectionMode,
              onSelectTap: () => manager.toggle(collection['id']!),
              onTap: () {
                if (manager.isSelectionMode) {
                  manager.toggle(collection['id']!);
                } else {
                  // 正常点击逻辑
                }
              },
              leading: Icon(Icons.folder, color: Colors.blue),
              title: Text(collection['name']!),
              subtitle: Text('${collection['count']} 条路线'),
              trailing: Icon(Icons.more_vert),
            );
          },
        );
      },
    );
  }

  Widget _buildActionBar(BuildContext context) {
    return Consumer<CollectionMultiSelectManager>(
      builder: (context, manager, child) {
        if (!manager.isSelectionMode) return SizedBox.shrink();

        return CollectionBatchActionBar(
          selectedCount: manager.selectedCount,
          availableActions: [
            CollectionBatchActionType.delete,
            CollectionBatchActionType.move,
          ],
          onActionSelected: (action) {
            switch (action) {
              case CollectionBatchActionType.delete:
                // 处理删除逻辑
                break;
              case CollectionBatchActionType.move:
                // 处理移动逻辑
                break;
            }
          },
          onCancel: () => manager.clear(),
        );
      },
    );
  }
}
```

#### 2. 批量操作菜单使用

```dart
import 'package:flutter/material.dart';
import 'package:hangzhou_guide/components/collection/batch_action_menu.dart';

class BatchOperationsExample extends StatelessWidget {
  final int selectedCount = 3;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: CollectionBatchActionMenuButton(
        selectedCount: selectedCount,
        availableActions: [
          CollectionBatchAction.delete,
          CollectionBatchAction.move,
          CollectionBatchAction.tag,
        ],
        onActionSelected: (action) async {
          switch (action) {
            case CollectionBatchAction.delete:
              final confirm = await CollectionBatchActionMenu
                  .showDeleteConfirmationDialog(
                context: context,
                selectedCount: selectedCount,
              );
              if (confirm) {
                // 执行删除
              }
              break;
              
            case CollectionBatchAction.move:
              final collections = [
                CollectionItem(id: '1', name: '收藏夹1', trailCount: 5),
                CollectionItem(id: '2', name: '收藏夹2', trailCount: 3),
              ];
              final targetId = await CollectionBatchActionMenu
                  .showMoveToCollectionSelector(
                context: context,
                collections: collections,
                currentCollectionId: 'current',
              );
              if (targetId != null) {
                final confirm = await CollectionBatchActionMenu
                    .showMoveConfirmationDialog(
                  context: context,
                  selectedCount: selectedCount,
                  targetCollectionName: '目标收藏夹',
                );
                if (confirm) {
                  // 执行移动
                }
              }
              break;
          }
        },
      ),
    );
  }
}
```

#### 3. 卡片多选模式

```dart
import 'package:flutter/material.dart';
import 'package:hangzhou_guide/components/collection/collection_multiselect.dart';

class CollectionGridScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return CollectionMultiSelectCard(
          id: 'card_$index',
          isSelected: false,
          isSelectionMode: true,
          onSelectTap: () {
            // 处理选择逻辑
          },
          child: Column(
            children: [
              Image.asset('assets/collection_cover.jpg'),
              ListTile(
                title: Text('收藏夹 $index'),
                subtitle: Text('${index * 2 + 1} 条路线'),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## API 兼容性

组件设计兼容后端新API：
- **批量移除**: 使用 `CollectionBatchActionType.delete`
- **批量移动**: 使用 `CollectionBatchActionType.move` + `CollectionBatchActionMenu.showMoveToCollectionSelector`
- **搜索**: 搜索功能需配合搜索组件实现（不在此组件库范围内）
- **标签支持**: 使用 `CollectionBatchActionType.tag`

## 设计规范

组件遵循山径 DesignSystem (`lib/constants/design_system.dart`)：
- 支持亮色/暗黑模式
- 使用标准间距、圆角、字体层级
- 一致的交互动画

## 单元测试

运行组件单元测试：

```bash
flutter test test/components/collection_components_test.dart
```

## 注意事项

1. **性能优化**: 对于长列表，建议使用 `ListView.builder` 或 `GridView.builder`
2. **状态管理**: 多选状态管理器应在适当的生命周期中创建和销毁
3. **动画**: 批量操作栏支持淡入淡出动画，可通过 `showAnimation` 参数控制
4. **无障碍**: 组件支持屏幕阅读器和键盘导航

## 更新日志

### v1.0.0 (M7 P1)
- 初始版本发布
- 支持收藏夹多选、批量操作功能
- 兼容后端新API扩展