// collection_tag.dart
// 山径APP - 收藏夹标签数据模型（M7 P1）
// 定义标签的数据结构，支持颜色编码和统计信息

import 'package:flutter/material.dart';

/// 标签模型
class CollectionTag {
  final String id;
  final String name;
  final Color color;
  final int count; // 使用次数

  const CollectionTag({
    required this.id,
    required this.name,
    required this.color,
    this.count = 0,
  });

  /// 从JSON解析（API响应）
  factory CollectionTag.fromJson(Map<String, dynamic> json) {
    return CollectionTag(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      color: _parseColor(json['color']),
      count: json['count'] ?? 0,
    );
  }

  /// 从字符串标签创建（无ID，用于本地临时标签）
  factory CollectionTag.fromString(String tag, {Color? color}) {
    return CollectionTag(
      id: tag.hashCode.toString(),
      name: tag,
      color: color ?? _generateColor(tag),
      count: 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color.value.toRadixString(16).padLeft(8, '0'),
      'count': count,
    };
  }

  CollectionTag copyWith({
    String? id,
    String? name,
    Color? color,
    int? count,
  }) {
    return CollectionTag(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      count: count ?? this.count,
    );
  }

  /// 增加使用次数
  CollectionTag incrementCount() {
    return copyWith(count: count + 1);
  }

  /// 减少使用次数
  CollectionTag decrementCount() {
    return copyWith(count: count > 0 ? count - 1 : 0);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionTag &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name;

  @override
  int get hashCode => id.hashCode ^ name.hashCode;

  @override
  String toString() => 'CollectionTag{name: $name, color: $color, count: $count}';

  // ==================== 颜色处理 ====================

  /// 解析颜色字符串（支持Hex, RGB, 颜色名）
  static Color _parseColor(dynamic colorValue) {
    if (colorValue == null) {
      return Colors.blue;
    }

    if (colorValue is String) {
      // 尝试解析Hex颜色
      if (colorValue.startsWith('#')) {
        final hex = colorValue.substring(1);
        if (hex.length == 6) {
          return Color(int.parse('0xFF$hex'));
        } else if (hex.length == 8) {
          return Color(int.parse('0x$hex'));
        }
      }

      // 尝试解析颜色名
      final colorMap = {
        'red': Colors.red,
        'pink': Colors.pink,
        'purple': Colors.purple,
        'deepPurple': Colors.deepPurple,
        'indigo': Colors.indigo,
        'blue': Colors.blue,
        'lightBlue': Colors.lightBlue,
        'cyan': Colors.cyan,
        'teal': Colors.teal,
        'green': Colors.green,
        'lightGreen': Colors.lightGreen,
        'lime': Colors.lime,
        'yellow': Colors.yellow,
        'amber': Colors.amber,
        'orange': Colors.orange,
        'deepOrange': Colors.deepOrange,
        'brown': Colors.brown,
        'grey': Colors.grey,
        'blueGrey': Colors.blueGrey,
      };

      if (colorMap.containsKey(colorValue)) {
        return colorMap[colorValue]!;
      }
    }

    if (colorValue is int) {
      return Color(colorValue);
    }

    return Colors.blue;
  }

  /// 根据标签名生成确定性颜色
  static Color _generateColor(String tag) {
    // 使用标签名的哈希值来选择颜色
    final hash = tag.hashCode.abs();
    final hue = hash % 360;
    final saturation = 60 + (hash % 20); // 60-80%
    final lightness = 50 + (hash % 10); // 50-60%
    
    return HSLColor.fromAHSL(1.0, hue.toDouble(), saturation / 100, lightness / 100).toColor();
  }

  /// 预定义颜色列表（用于颜色选择器）
  static List<Color> get predefinedColors => [
    Colors.red,
    Colors.pink,
    Colors.purple,
    Colors.deepPurple,
    Colors.indigo,
    Colors.blue,
    Colors.lightBlue,
    Colors.cyan,
    Colors.teal,
    Colors.green,
    Colors.lightGreen,
    Colors.lime,
    Colors.yellow,
    Colors.amber,
    Colors.orange,
    Colors.deepOrange,
    Colors.brown,
    Colors.grey,
    Colors.blueGrey,
  ];

  /// 预定义颜色名称
  static Map<Color, String> get colorNames => {
    Colors.red: '红色',
    Colors.pink: '粉色',
    Colors.purple: '紫色',
    Colors.deepPurple: '深紫',
    Colors.indigo: '靛蓝',
    Colors.blue: '蓝色',
    Colors.lightBlue: '浅蓝',
    Colors.cyan: '青色',
    Colors.teal: '蓝绿',
    Colors.green: '绿色',
    Colors.lightGreen: '浅绿',
    Colors.lime: '柠檬',
    Colors.yellow: '黄色',
    Colors.amber: '琥珀',
    Colors.orange: '橙色',
    Colors.deepOrange: '深橙',
    Colors.brown: '棕色',
    Colors.grey: '灰色',
    Colors.blueGrey: '蓝灰',
  };
}

/// 标签统计信息
class TagStatistics {
  final Map<String, int> frequency; // 标签名 -> 使用次数
  final int totalTags; // 总标签数
  final int uniqueTags; // 唯一标签数
  final List<CollectionTag> mostUsedTags; // 最常使用的标签

  TagStatistics({
    required this.frequency,
    required this.totalTags,
    required this.uniqueTags,
    required this.mostUsedTags,
  });

  /// 从标签列表计算统计信息
  factory TagStatistics.fromTags(List<CollectionTag> tags) {
    final frequency = <String, int>{};
    var totalTags = 0;
    
    for (final tag in tags) {
      frequency[tag.name] = (frequency[tag.name] ?? 0) + tag.count;
      totalTags += tag.count;
    }
    
    final sortedTags = tags.toList()
      ..sort((a, b) => b.count.compareTo(a.count));
    
    return TagStatistics(
      frequency: frequency,
      totalTags: totalTags,
      uniqueTags: frequency.keys.length,
      mostUsedTags: sortedTags.take(10).toList(),
    );
  }

  /// 获取标签使用频率（0-1）
  double getFrequency(String tagName) {
    if (totalTags == 0) return 0.0;
    return (frequency[tagName] ?? 0) / totalTags;
  }
}