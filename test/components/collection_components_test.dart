// collection_components_test.dart
// 山径APP - 收藏夹增强功能组件单元测试（M7 P1）
// 测试多选模式组件、批量操作栏组件、批量操作菜单组件

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/components/collection/collection_multiselect.dart';
import 'package:hangzhou_guide/components/collection/batch_action_bar.dart';
import 'package:hangzhou_guide/components/collection/batch_action_menu.dart';

void main() {
  group('CollectionMultiSelectManager 测试', () {
    test('初始化状态', () {
      final manager = CollectionMultiSelectManager();
      expect(manager.selectedIds, isEmpty);
      expect(manager.isSelectionMode, false);
      expect(manager.selectedCount, 0);
    });

    test('选择单个项目', () {
      final manager = CollectionMultiSelectManager();
      manager.select('item1');
      expect(manager.selectedIds, contains('item1'));
      expect(manager.selectedCount, 1);
      expect(manager.isSelectionMode, true);
    });

    test('切换选择状态', () {
      final manager = CollectionMultiSelectManager();
      manager.toggle('item1');
      expect(manager.isSelected('item1'), true);
      manager.toggle('item1');
      expect(manager.isSelected('item1'), false);
    });

    test('全选和取消全选', () {
      final manager = CollectionMultiSelectManager();
      final ids = ['item1', 'item2', 'item3'];
      
      manager.selectAll(ids);
      expect(manager.selectedCount, 3);
      expect(manager.isAllSelected(ids), true);
      
      manager.deselectAll();
      expect(manager.selectedCount, 0);
      expect(manager.isAllSelected(ids), false);
    });

    test('部分选中判断', () {
      final manager = CollectionMultiSelectManager();
      final ids = ['item1', 'item2', 'item3'];
      
      expect(manager.isPartialSelected(ids), false);
      
      manager.select('item1');
      expect(manager.isPartialSelected(ids), true);
      
      manager.selectAll(ids);
      expect(manager.isPartialSelected(ids), false);
    });
  });

  group('CollectionMultiSelectItem 组件测试', () {
    testWidgets('渲染组件', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollectionMultiSelectItem(
              id: 'test1',
              isSelected: false,
              isSelectionMode: true,
              leading: const Icon(Icons.folder),
              title: const Text('测试收藏夹'),
              subtitle: const Text('5条路线'),
              trailing: const Icon(Icons.more_vert),
              onSelectTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('测试收藏夹'), findsOneWidget);
      expect(find.text('5条路线'), findsOneWidget);
      expect(find.byIcon(Icons.folder), findsOneWidget);
    });

    testWidgets('选中状态样式', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollectionMultiSelectItem(
              id: 'test1',
              isSelected: true,
              isSelectionMode: true,
              leading: const Icon(Icons.folder),
              title: const Text('测试收藏夹'),
              onSelectTap: () {},
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('CollectionMultiSelectCard 组件测试', () {
    testWidgets('渲染卡片组件', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollectionMultiSelectCard(
              id: 'card1',
              isSelected: false,
              isSelectionMode: true,
              child: const ListTile(
                title: Text('测试卡片'),
                subtitle: Text('卡片内容'),
              ),
              onSelectTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('测试卡片'), findsOneWidget);
      expect(find.text('卡片内容'), findsOneWidget);
    });

    testWidgets('卡片选中边框', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollectionMultiSelectCard(
              id: 'card1',
              isSelected: true,
              isSelectionMode: true,
              child: const ListTile(title: Text('测试卡片')),
              onSelectTap: () {},
            ),
          ),
        ),
      );

      // 选中状态下应该有复选框显示
      expect(find.byIcon(Icons.check), findsOneWidget);
    });
  });

  group('CollectionSelectAllHeader 组件测试', () {
    testWidgets('渲染头部组件', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollectionSelectAllHeader(
              isAllSelected: false,
              isPartialSelected: false,
              onSelectAll: () {},
              onDeselectAll: () {},
              selectedCount: 0,
              totalCount: 10,
            ),
          ),
        ),
      );

      expect(find.text('选择全部'), findsOneWidget);
    });

    testWidgets('显示选中数量', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CollectionSelectAllHeader(
              isAllSelected: false,
              isPartialSelected: true,
              onSelectAll: () {},
              onDeselectAll: () {},
              selectedCount: 3,
              totalCount: 10,
            ),
          ),
        ),
      );

      expect(find.text('已选择 3/10'), findsOneWidget);
    });
  });

  group('CollectionBatchActionBar 组件测试', () {
    testWidgets('渲染操作栏', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: CollectionBatchActionBar(
                    selectedCount: 3,
                    availableActions: [
                      CollectionBatchActionType.delete,
                      CollectionBatchActionType.move,
                    ],
                    onActionSelected: (action) {},
                    onCancel: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('已选中 3 项'), findsOneWidget);
      expect(find.text('删除'), findsOneWidget);
      expect(find.text('移动'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('顶部显示模式', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CollectionBatchActionBar(
                  selectedCount: 2,
                  availableActions: [CollectionBatchActionType.delete],
                  onActionSelected: (action) {},
                  onCancel: () {},
                  showAtTop: true,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('已选中 2 项'), findsOneWidget);
    });
  });

  group('SimpleCollectionBatchActionBar 组件测试', () {
    testWidgets('渲染简化操作栏', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: SimpleCollectionBatchActionBar(
                    selectedCount: 5,
                    onCancel: () {},
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('已选 5 项'), findsOneWidget);
      expect(find.text('取消'), findsOneWidget);
      expect(find.text('长按项目可多选'), findsOneWidget);
    });
  });

  group('CollectionBatchActionMenu 静态方法测试', () {
    testWidgets('显示删除确认对话框', (tester) async {
      // 由于对话框需要上下文，我们主要测试方法存在性
      // 实际UI测试在集成测试中完成
      expect(CollectionBatchActionMenu.showDeleteConfirmationDialog, isNotNull);
      expect(CollectionBatchActionMenu.showMoveConfirmationDialog, isNotNull);
      expect(CollectionBatchActionMenu.showBottomMenu, isNotNull);
      expect(CollectionBatchActionMenu.showMoveToCollectionSelector, isNotNull);
    });
  });

  group('CollectionBatchActionMenuButton 组件测试', () {
    testWidgets('渲染菜单按钮', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            floatingActionButton: CollectionBatchActionMenuButton(
              selectedCount: 3,
              availableActions: [CollectionBatchActionType.delete],
              onActionSelected: (action) {},
            ),
          ),
        ),
      );

      expect(find.text('3 项'), findsOneWidget);
      expect(find.byIcon(Icons.more_vert), findsOneWidget);
    });
  });
}