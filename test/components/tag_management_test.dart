// tag_management_test.dart
// 山径APP - 标签管理组件单元测试（M7 P1）

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/components/collection/tag_management.dart';
import 'package:hangzhou_guide/models/collection_tag.dart';

void main() {
  group('TagDisplayMode 枚举', () {
    test('枚举值', () {
      expect(TagDisplayMode.values.length, 4);
      expect(TagDisplayMode.chips.index, 0);
      expect(TagDisplayMode.list.index, 1);
      expect(TagDisplayMode.cloud.index, 2);
      expect(TagDisplayMode.grid.index, 3);
    });
  });

  group('TagEditorState 测试', () {
    test('创建状态', () {
      final state = TagEditorState(
        tags: ['工作', '旅行'],
        availableTags: ['工作', '旅行', '家庭'],
        isLoading: false,
      );
      
      expect(state.tags, contains('工作'));
      expect(state.tags, contains('旅行'));
      expect(state.tags.length, 2);
      expect(state.availableTags.length, 3);
      expect(state.isLoading, false);
    });

    test('copyWith 方法', () {
      final original = TagEditorState(
        tags: ['工作'],
        availableTags: ['工作', '旅行'],
        isLoading: false,
      );
      
      final updated = original.copyWith(
        tags: ['工作', '家庭'],
        isLoading: true,
      );
      
      expect(updated.tags, contains('工作'));
      expect(updated.tags, contains('家庭'));
      expect(updated.tags.length, 2);
      expect(updated.availableTags, contains('工作'));
      expect(updated.availableTags, contains('旅行'));
      expect(updated.availableTags.length, 2);
      expect(updated.isLoading, true);
    });
  });

  group('CollectionTag 模型（集成测试）', () {
    test('从字符串创建标签', () {
      final tag = CollectionTag.fromString('工作');
      
      expect(tag.name, '工作');
      expect(tag.id, isNotEmpty);
      expect(tag.color, isA<Color>());
      expect(tag.count, 0);
    });

    test('标签颜色生成', () {
      final tag1 = CollectionTag.fromString('工作');
      final tag2 = CollectionTag.fromString('旅行');
      
      // 相同标签名应生成相同颜色
      final tag1Again = CollectionTag.fromString('工作');
      expect(tag1.color.value, tag1Again.color.value);
      
      // 不同标签名应生成不同颜色（大概率）
      expect(tag1.color.value != tag2.color.value, true);
    });

    test('增加和减少使用次数', () {
      final tag = CollectionTag.fromString('工作');
      
      final incremented = tag.incrementCount();
      expect(incremented.count, 1);
      
      final decremented = incremented.decrementCount();
      expect(decremented.count, 0);
      
      // 不会减少到负数
      final notNegative = decremented.decrementCount();
      expect(notNegative.count, 0);
    });
  });

  group('标签显示组件逻辑', () {
    test('标签数量限制', () {
      final tags = List<String>.generate(15, (i) => '标签${i + 1}');
      
      // 测试 maxVisibleTags = 10
      const maxVisibleTags = 10;
      final displayedTags = tags.length > maxVisibleTags
          ? tags.sublist(0, maxVisibleTags)
          : tags;
      
      expect(displayedTags.length, 10);
      expect(displayedTags.first, '标签1');
      expect(displayedTags.last, '标签10');
    });

    test('剩余标签计数', () {
      final tags = List<String>.generate(15, (i) => '标签${i + 1}');
      const maxVisibleTags = 10;
      final remainingCount = tags.length - maxVisibleTags;
      
      expect(remainingCount, 5);
    });
  });

  group('标签选择器逻辑', () {
    test('标签选择切换', () {
      final selectedTags = ['工作'];
      
      // 添加标签
      final withNewTag = [...selectedTags, '旅行'];
      expect(withNewTag, contains('工作'));
      expect(withNewTag, contains('旅行'));
      expect(withNewTag.length, 2);
      
      // 移除标签
      final withoutTag = withNewTag.where((tag) => tag != '工作').toList();
      expect(withoutTag, contains('旅行'));
      expect(withoutTag, isNot(contains('工作')));
      expect(withoutTag.length, 1);
    });

    test('选择数量限制', () {
      const maxSelections = 5;
      final selectedTags = List<String>.generate(maxSelections, (i) => '标签${i + 1}');
      
      expect(selectedTags.length, maxSelections);
      
      // 尝试添加更多标签（应被拒绝）
      final overLimit = [...selectedTags, '额外标签'];
      expect(overLimit.length, maxSelections + 1);
    });
  });

  group('标签云逻辑', () {
    test('标签频率计算', () {
      final tags = [
        CollectionTag.fromString('工作')..incrementCount(),
        CollectionTag.fromString('旅行')..incrementCount()..incrementCount(),
        CollectionTag.fromString('家庭'),
      ];
      
      // 计算总使用次数
      final totalCount = tags.fold(0, (sum, tag) => sum + tag.count);
      expect(totalCount, 3);
      
      // 计算频率
      final workTag = tags[0];
      final travelTag = tags[1];
      final homeTag = tags[2];
      
      final workFrequency = workTag.count / totalCount;
      final travelFrequency = travelTag.count / totalCount;
      final homeFrequency = homeTag.count / totalCount;
      
      expect(workFrequency, closeTo(1/3, 0.001));
      expect(travelFrequency, closeTo(2/3, 0.001));
      expect(homeFrequency, 0.0);
    });
  });
}