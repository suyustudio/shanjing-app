// collection_enhanced_test.dart
// 山径APP - 收藏夹增强功能单元测试（M7 P1）

import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/models/collection_enhanced_model.dart';
import 'package:hangzhou_guide/widgets/collections/collection_selection_manager.dart';

void main() {
  group('增强收藏夹模型测试', () {
    test('EnhancedCollection 从JSON解析', () {
      final json = {
        'id': 'collection_001',
        'name': '测试收藏夹',
        'description': '测试描述',
        'coverUrl': 'https://example.com/cover.jpg',
        'trailCount': 5,
        'isPublic': true,
        'isDefault': false,
        'sortOrder': 1,
        'tags': ['工作', '旅行'],
        'createdAt': '2024-01-01T00:00:00Z',
        'updatedAt': '2024-01-02T00:00:00Z',
      };

      final collection = EnhancedCollection.fromJson(json);

      expect(collection.id, 'collection_001');
      expect(collection.name, '测试收藏夹');
      expect(collection.description, '测试描述');
      expect(collection.coverUrl, 'https://example.com/cover.jpg');
      expect(collection.trailCount, 5);
      expect(collection.isPublic, true);
      expect(collection.isDefault, false);
      expect(collection.sortOrder, 1);
      expect(collection.tags, contains('工作'));
      expect(collection.tags, contains('旅行'));
      expect(collection.tags.length, 2);
      expect(collection.createdAt, DateTime.utc(2024, 1, 1));
      expect(collection.updatedAt, DateTime.utc(2024, 1, 2));
    });

    test('EnhancedCollection 转换为JSON', () {
      final collection = EnhancedCollection(
        id: 'collection_001',
        name: '测试收藏夹',
        description: '测试描述',
        coverUrl: 'https://example.com/cover.jpg',
        trailCount: 5,
        isPublic: true,
        isDefault: false,
        sortOrder: 1,
        tags: ['工作', '旅行'],
        createdAt: DateTime.utc(2024, 1, 1),
        updatedAt: DateTime.utc(2024, 1, 2),
      );

      final json = collection.toJson();

      expect(json['id'], 'collection_001');
      expect(json['name'], '测试收藏夹');
      expect(json['description'], '测试描述');
      expect(json['coverUrl'], 'https://example.com/cover.jpg');
      expect(json['trailCount'], 5);
      expect(json['isPublic'], true);
      expect(json['isDefault'], false);
      expect(json['sortOrder'], 1);
      expect(json['tags'], ['工作', '旅行']);
      expect(json['createdAt'], '2024-01-01T00:00:00.000Z');
      expect(json['updatedAt'], '2024-01-02T00:00:00.000Z');
    });

    test('EnhancedCollection 标签操作', () {
      final collection = EnhancedCollection(
        id: 'collection_001',
        name: '测试',
        trailCount: 0,
        isPublic: true,
        isDefault: false,
        sortOrder: 0,
        tags: ['工作'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 检查是否包含标签
      expect(collection.hasTag('工作'), true);
      expect(collection.hasTag('旅行'), false);

      // 添加标签
      final withNewTag = collection.withTag('旅行');
      expect(withNewTag.tags, contains('工作'));
      expect(withNewTag.tags, contains('旅行'));
      expect(withNewTag.tags.length, 2);

      // 添加重复标签（应去重）
      final withDuplicateTag = withNewTag.withTag('旅行');
      expect(withDuplicateTag.tags.length, 2);

      // 移除标签
      final withoutTag = withNewTag.withoutTag('工作');
      expect(withoutTag.tags, contains('旅行'));
      expect(withoutTag.tags, isNot(contains('工作')));
      expect(withoutTag.tags.length, 1);

      // 批量设置标签
      final withMultipleTags = collection.withTags(['旅行', '周末']);
      expect(withMultipleTags.tags, contains('工作'));
      expect(withMultipleTags.tags, contains('旅行'));
      expect(withMultipleTags.tags, contains('周末'));
      expect(withMultipleTags.tags.length, 3);
    });

    test('BatchOperationRequest 序列化', () {
      final request = BatchOperationRequest(
        ids: ['item_001', 'item_002', 'item_003'],
        extraData: {'note': '测试备注'},
      );

      final json = request.toJson();
      expect(json['ids'], ['item_001', 'item_002', 'item_003']);
      expect(json['extraData'], {'note': '测试备注'});

      final fromJson = BatchOperationRequest.fromJson(json);
      expect(fromJson.ids, ['item_001', 'item_002', 'item_003']);
      expect(fromJson.extraData, {'note': '测试备注'});
    });

    test('BatchAddTrailsRequest 序列化', () {
      final request = BatchAddTrailsRequest(
        trailIds: ['trail_001', 'trail_002'],
        note: '批量添加',
      );

      final json = request.toJson();
      expect(json['trailIds'], ['trail_001', 'trail_002']);
      expect(json['note'], '批量添加');

      final fromJson = BatchAddTrailsRequest.fromJson(json);
      expect(fromJson.trailIds, ['trail_001', 'trail_002']);
      expect(fromJson.note, '批量添加');
    });

    test('CollectionSearchFilter 查询参数转换', () {
      final filter = CollectionSearchFilter(
        searchQuery: '杭州',
        tags: ['工作', '旅行'],
        isPublic: true,
        sortBy: 'updated',
        sortAscending: false,
        page: 2,
        limit: 20,
      );

      final params = filter.toQueryParams();
      expect(params['search'], '杭州');
      expect(params['tags'], '工作,旅行');
      expect(params['isPublic'], 'true');
      expect(params['sort'], 'updated:desc');
      expect(params['page'], '2');
      expect(params['limit'], '20');

      final fromParams = CollectionSearchFilter.fromQueryParams(params);
      expect(fromParams.searchQuery, '杭州');
      expect(fromParams.tags, ['工作', '旅行']);
      expect(fromParams.isPublic, true);
      expect(fromParams.sortBy, 'updated');
      expect(fromParams.sortAscending, false);
      expect(fromParams.page, 2);
      expect(fromParams.limit, 20);
    });
  });

  group('选择状态管理器测试', () {
    test('CollectionSelectionManager 基本操作', () {
      final manager = CollectionSelectionManager();
      final itemIds = ['item_001', 'item_002', 'item_003'];

      // 初始状态
      expect(manager.isSelectionMode, false);
      expect(manager.selectedCount, 0);
      expect(manager.isAllSelected(itemIds), false);
      expect(manager.isPartialSelected(itemIds), false);

      // 选择单个项目
      manager.toggle('item_001');
      expect(manager.isSelectionMode, true);
      expect(manager.selectedCount, 1);
      expect(manager.isSelected('item_001'), true);
      expect(manager.isSelected('item_002'), false);
      expect(manager.isAllSelected(itemIds), false);
      expect(manager.isPartialSelected(itemIds), true);

      // 选择所有项目
      manager.selectAll(itemIds);
      expect(manager.selectedCount, 3);
      expect(manager.isAllSelected(itemIds), true);
      expect(manager.isPartialSelected(itemIds), false);

      // 取消选择所有项目
      manager.deselectAll();
      expect(manager.isSelectionMode, false);
      expect(manager.selectedCount, 0);
      expect(manager.isAllSelected(itemIds), false);

      // 切换全选状态
      manager.toggleAll(itemIds);
      expect(manager.isAllSelected(itemIds), true);
      manager.toggleAll(itemIds);
      expect(manager.isAllSelected(itemIds), false);

      // 批量选择和取消选择
      manager.selectMultiple(['item_001', 'item_002']);
      expect(manager.selectedCount, 2);
      manager.deselectMultiple(['item_001']);
      expect(manager.selectedCount, 1);
      expect(manager.isSelected('item_002'), true);

      // 清除选择
      manager.clear();
      expect(manager.selectedCount, 0);
    });

    test('TrailSelectionManager 基本操作', () {
      final manager = TrailSelectionManager();
      final trailIds = ['trail_001', 'trail_002', 'trail_003'];

      // 初始状态
      expect(manager.isSelectionMode, false);
      expect(manager.selectedCount, 0);

      // 选择单个路线
      manager.toggle('trail_001');
      expect(manager.isSelectionMode, true);
      expect(manager.selectedCount, 1);
      expect(manager.isSelected('trail_001'), true);

      // 选择所有路线
      manager.selectAll(trailIds);
      expect(manager.selectedCount, 3);

      // 取消选择所有路线
      manager.deselectAll();
      expect(manager.isSelectionMode, false);

      // 切换全选状态
      manager.toggleAll(trailIds);
      expect(manager.selectedCount, 3);
      manager.toggleAll(trailIds);
      expect(manager.selectedCount, 0);

      // 清除选择
      manager.clear();
      expect(manager.selectedCount, 0);
    });
  });

  group('批量操作结果测试', () {
    test('BatchOperationResult 计算成功比例', () {
      final result = BatchOperationResult(
        success: true,
        message: '测试',
        successCount: 8,
        totalCount: 10,
        failedIds: ['item_003', 'item_007'],
      );

      expect(result.successRate, 0.8);
      expect(result.success, true);
      expect(result.message, '测试');
      expect(result.successCount, 8);
      expect(result.totalCount, 10);
      expect(result.failedIds, ['item_003', 'item_007']);

      // 边界情况：总数为0
      final zeroResult = BatchOperationResult(
        success: false,
        successCount: 0,
        totalCount: 0,
      );
      expect(zeroResult.successRate, 0.0);
    });

    test('BatchOperationResult 序列化', () {
      final result = BatchOperationResult(
        success: true,
        message: '部分成功',
        successCount: 3,
        totalCount: 5,
        failedIds: ['item_002', 'item_004'],
        data: {'additional': 'info'},
      );

      final json = result.toJson();
      expect(json['success'], true);
      expect(json['message'], '部分成功');
      expect(json['successCount'], 3);
      expect(json['totalCount'], 5);
      expect(json['failedIds'], ['item_002', 'item_004']);
      expect(json['data'], {'additional': 'info'});

      final fromJson = BatchOperationResult.fromJson(json);
      expect(fromJson.success, true);
      expect(fromJson.message, '部分成功');
      expect(fromJson.successCount, 3);
      expect(fromJson.totalCount, 5);
      expect(fromJson.failedIds, ['item_002', 'item_004']);
      expect(fromJson.data, {'additional': 'info'});
    });
  });
}
