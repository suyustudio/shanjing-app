// tag_service_test.dart
// 山径APP - 标签服务单元测试（M7 P2-06 测试覆盖率提升）

import 'package:flutter_test/flutter_test.dart';
import 'package:hangzhou_guide/services/tag_service.dart';
import 'package:hangzhou_guide/models/collection_tag.dart';

void main() {
  late TagService tagService;

  setUp(() {
    tagService = TagService();
  });

  group('TagService 纯函数方法测试', () {
    test('convertStringTags - 字符串数组转CollectionTag数组', () {
      final input = ['工作', '旅行', '家庭'];
      final result = tagService.convertStringTags(input);
      
      expect(result, hasLength(3));
      expect(result[0].name, '工作');
      expect(result[1].name, '旅行');
      expect(result[2].name, '家庭');
      
      // 验证生成的标签有ID和颜色
      for (final tag in result) {
        expect(tag.id, isNotEmpty);
        expect(tag.color, isA<Color>());
        expect(tag.count, 0);
      }
    });

    test('convertStringTags - 空数组', () {
      final result = tagService.convertStringTags([]);
      expect(result, isEmpty);
    });

    test('extractTagNames - CollectionTag数组转标签名数组', () {
      final tags = [
        CollectionTag.fromString('工作'),
        CollectionTag.fromString('旅行'),
        CollectionTag.fromString('家庭'),
      ];
      
      final result = tagService.extractTagNames(tags);
      
      expect(result, hasLength(3));
      expect(result, contains('工作'));
      expect(result, contains('旅行'));
      expect(result, contains('家庭'));
      expect(result, orderedEquals(['工作', '旅行', '家庭']));
    });

    test('extractTagNames - 空数组', () {
      final result = tagService.extractTagNames([]);
      expect(result, isEmpty);
    });

    test('clearCache - 清空缓存', () {
      // 由于TagService的缓存是私有的，我们只能验证调用不抛出异常
      expect(() => tagService.clearCache(), returnsNormally);
    });
  });

  group('CollectionTag 模型扩展测试', () {
    test('预定义颜色列表', () {
      final predefinedColors = CollectionTag.predefinedColors;
      expect(predefinedColors, isNotEmpty);
      expect(predefinedColors.length, greaterThan(10));
      
      // 验证所有颜色都是Color类型
      for (final color in predefinedColors) {
        expect(color, isA<Color>());
      }
    });

    test('颜色名称映射', () {
      final colorNames = CollectionTag.colorNames;
      expect(colorNames, isNotEmpty);
      
      // 验证常见颜色有名称
      expect(colorNames[Colors.red], '红色');
      expect(colorNames[Colors.blue], '蓝色');
      expect(colorNames[Colors.green], '绿色');
    });

    test('颜色解析 - 私有方法测试（通过fromString间接测试）', () {
      // 通过fromString测试颜色生成的一致性
      final tag1 = CollectionTag.fromString('工作');
      final tag2 = CollectionTag.fromString('工作');
      final tag3 = CollectionTag.fromString('旅行');
      
      // 相同标签名应生成相同颜色
      expect(tag1.color.value, tag2.color.value);
      
      // 不同标签名很可能生成不同颜色
      expect(tag1.color.value != tag3.color.value, true);
    });

    test('颜色生成确定性', () {
      final tag1 = CollectionTag.fromString('工作');
      final tag2 = CollectionTag.fromString('工作'); // 相同标签名
      final tag3 = CollectionTag.fromString('旅行'); // 不同标签名
      
      // 相同标签名应生成相同颜色
      expect(tag1.color.value, tag2.color.value);
      
      // 不同标签名很可能生成不同颜色
      expect(tag1.color.value != tag3.color.value, true);
    });

    test('标签相等性', () {
      final tag1 = CollectionTag.fromString('工作');
      final tag2 = CollectionTag.fromString('工作');
      final tag3 = CollectionTag.fromString('旅行');
      
      // 相同名称的标签应相等（基于id和name的hashCode）
      expect(tag1 == tag2, true);
      expect(tag1 == tag3, false);
      expect(tag1.hashCode == tag2.hashCode, true);
      expect(tag1.hashCode == tag3.hashCode, false);
    });

    test('标签copyWith方法', () {
      final original = CollectionTag.fromString('工作');
      
      final updated = original.copyWith(
        name: '新工作',
        count: 5,
      );
      
      expect(updated.name, '新工作');
      expect(updated.count, 5);
      expect(updated.color.value, original.color.value); // 颜色不变
      expect(updated.id, original.id); // ID不变
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

  group('TagStatistics 统计测试', () {
    test('从标签列表计算统计信息', () {
      final tags = [
        CollectionTag.fromString('工作')..incrementCount()..incrementCount(),
        CollectionTag.fromString('旅行')..incrementCount(),
        CollectionTag.fromString('家庭'),
      ];
      
      final stats = TagStatistics.fromTags(tags);
      
      expect(stats.totalTags, 3);
      expect(stats.uniqueTags, 3);
      expect(stats.mostUsedTags, hasLength(3));
      expect(stats.mostUsedTags[0].name, '工作');
      expect(stats.mostUsedTags[0].count, 2);
      expect(stats.mostUsedTags[1].name, '旅行');
      expect(stats.mostUsedTags[1].count, 1);
      expect(stats.mostUsedTags[2].name, '家庭');
      expect(stats.mostUsedTags[2].count, 0);
      
      // 验证频率映射
      expect(stats.frequency['工作'], 2);
      expect(stats.frequency['旅行'], 1);
      expect(stats.frequency['家庭'], 0);
    });

    test('获取标签使用频率', () {
      final tags = [
        CollectionTag.fromString('工作')..incrementCount()..incrementCount(),
        CollectionTag.fromString('旅行')..incrementCount(),
      ];
      
      final stats = TagStatistics.fromTags(tags);
      
      expect(stats.getFrequency('工作'), closeTo(2/3, 0.001));
      expect(stats.getFrequency('旅行'), closeTo(1/3, 0.001));
      expect(stats.getFrequency('不存在'), 0.0);
    });

    test('空标签列表', () {
      final stats = TagStatistics.fromTags([]);
      
      expect(stats.totalTags, 0);
      expect(stats.uniqueTags, 0);
      expect(stats.mostUsedTags, isEmpty);
      expect(stats.frequency, isEmpty);
    });
  });

  // 注意：TagService的API相关方法需要模拟网络请求，
  // 这需要更复杂的测试设置。建议后续添加集成测试。
}