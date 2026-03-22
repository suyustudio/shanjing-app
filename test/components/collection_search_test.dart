// collection_search_test.dart
// 山径APP - 收藏夹搜索组件单元测试（M7 P1）

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/components/collection/collection_search.dart';
import 'package:hangzhou_guide/models/collection_enhanced_model.dart';

void main() {
  group('SearchResultItem 测试', () {
    test('创建基本对象', () {
      final item = SearchResultItem(
        id: 'test-id',
        title: '测试标题',
      );
      
      expect(item.id, 'test-id');
      expect(item.title, '测试标题');
      expect(item.subtitle, isNull);
      expect(item.description, isNull);
      expect(item.metadata, isNull);
      expect(item.highlightFields, isNull);
    });

    test('创建完整对象', () {
      final item = SearchResultItem(
        id: 'test-id',
        title: '测试标题',
        subtitle: '副标题',
        description: '描述文本',
        metadata: {'key': 'value'},
        highlightFields: ['title'],
      );
      
      expect(item.subtitle, '副标题');
      expect(item.description, '描述文本');
      expect(item.metadata!['key'], 'value');
      expect(item.highlightFields, contains('title'));
    });
  });

  group('CollectionSearchController 测试', () {
    late CollectionSearchController controller;
    
    setUp(() {
      controller = CollectionSearchController();
      controller.init(collectionId: 'test-collection');
    });
    
    tearDown(() {
      controller.dispose();
    });

    test('初始化状态', () {
      expect(controller.state.value, SearchState.idle);
      expect(controller.results.value, isEmpty);
      expect(controller.textController.text, isEmpty);
    });

    test('搜索防抖功能', () async {
      var searchCalled = false;
      // 由于防抖，我们需要监听状态变化
      controller.state.addListener(() {
        if (controller.state.value == SearchState.loading) {
          searchCalled = true;
        }
      });
      
      controller.search('测试查询');
      expect(searchCalled, false); // 防抖延迟，不会立即调用
      
      // 等待防抖时间
      await Future.delayed(const Duration(milliseconds: 600));
      expect(searchCalled, true);
    });

    test('立即搜索', () async {
      var searchCalled = false;
      controller.state.addListener(() {
        if (controller.state.value == SearchState.loading) {
          searchCalled = true;
        }
      });
      
      controller.search('测试查询', immediate: true);
      expect(searchCalled, true);
    });

    test('重置搜索', () {
      controller.textController.text = '测试文本';
      controller.state.value = SearchState.success;
      
      controller.reset();
      
      expect(controller.textController.text, isEmpty);
      expect(controller.state.value, SearchState.idle);
      expect(controller.results.value, isEmpty);
    });

    test('筛选器更新', () {
      final newFilter = CollectionTrailSearchFilter(
        searchQuery: '新查询',
        minDistance: 5.0,
        maxDistance: 20.0,
      );
      
      controller.filter.value = newFilter;
      
      expect(controller.filter.value.searchQuery, '新查询');
      expect(controller.filter.value.minDistance, 5.0);
      expect(controller.filter.value.maxDistance, 20.0);
    });
  });

  group('搜索状态枚举', () {
    test('枚举值', () {
      expect(SearchState.values.length, 5);
      expect(SearchState.idle.index, 0);
      expect(SearchState.loading.index, 1);
      expect(SearchState.empty.index, 2);
      expect(SearchState.success.index, 3);
      expect(SearchState.error.index, 4);
    });
  });
}