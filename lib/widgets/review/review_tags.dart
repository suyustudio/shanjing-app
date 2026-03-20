/**
 * 评论标签组件
 * 
 * M6 评论系统 - 标签展示
 */

import 'package:flutter/material.dart';

/// 评论标签组件
class ReviewTags extends StatelessWidget {
  final List<String> tags;
  final int maxDisplay;
  final Function(String)? onTagTap;

  const ReviewTags({
    Key? key,
    required this.tags,
    this.maxDisplay = 3,
    this.onTagTap,
  }) : super(key: key);

  // 标签颜色配置
  static final Map<String, Map<String, Color>> _tagColors = {
    '风景优美': {'bg': Color(0xFFE8F5F3), 'text': Color(0xFF1D756B)},
    '视野开阔': {'bg': Color(0xFFE8F5F3), 'text': Color(0xFF1D756B)},
    '拍照圣地': {'bg': Color(0xFFE8F5F3), 'text': Color(0xFF1D756B)},
    '秋色迷人': {'bg': Color(0xFFE8F5F3), 'text': Color(0xFF1D756B)},
    '春花烂漫': {'bg': Color(0xFFE8F5F3), 'text': Color(0xFF1D756B)},
    '难度适中': {'bg': Color(0xFFEEF7FF), 'text': Color(0xFF2A8AE8)},
    '轻松休闲': {'bg': Color(0xFFEEF7FF), 'text': Color(0xFF2A8AE8)},
    '挑战性强': {'bg': Color(0xFFEEF7FF), 'text': Color(0xFF2A8AE8)},
    '适合新手': {'bg': Color(0xFFEEF7FF), 'text': Color(0xFF2A8AE8)},
    '需要体能': {'bg': Color(0xFFEEF7FF), 'text': Color(0xFF2A8AE8)},
    '设施完善': {'bg': Color(0xFFE8F5E9), 'text': Color(0xFF43A047)},
    '补给方便': {'bg': Color(0xFFE8F5E9), 'text': Color(0xFF43A047)},
    '厕所干净': {'bg': Color(0xFFE8F5E9), 'text': Color(0xFF43A047)},
    '指示牌清晰': {'bg': Color(0xFFE8F5E9), 'text': Color(0xFF43A047)},
    '适合亲子': {'bg': Color(0xFFFFF0F5), 'text': Color(0xFFE91E63)},
    '宠物友好': {'bg': Color(0xFFFFF0F5), 'text': Color(0xFFE91E63)},
    '人少清静': {'bg': Color(0xFFFFF0F5), 'text': Color(0xFFE91E63)},
    '团队建设': {'bg': Color(0xFFFFF0F5), 'text': Color(0xFFE91E63)},
    '历史文化': {'bg': Color(0xFFFFF3E0), 'text': Color(0xFFF57C00)},
    '古迹众多': {'bg': Color(0xFFFFF3E0), 'text': Color(0xFFF57C00)},
    '森林氧吧': {'bg': Color(0xFFFFF3E0), 'text': Color(0xFFF57C00)},
    '溪流潺潺': {'bg': Color(0xFFFFF3E0), 'text': Color(0xFFF57C00)},
  };

  Map<String, Color> _getTagColors(String tag) {
    return _tagColors[tag] ?? {
      'bg': Color(0xFFF3F4F6),
      'text': Color(0xFF6B7280),
    };
  }

  @override
  Widget build(BuildContext context) {
    final displayTags = tags.take(maxDisplay).toList();
    final remainingCount = tags.length - maxDisplay;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...displayTags.map((tag) {
          final colors = _getTagColors(tag);
          return GestureDetector(
            onTap: onTagTap != null ? () => onTagTap!(tag) : null,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors['bg'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: colors['text'],
                ),
              ),
            ),
          );
        }).toList(),
        
        if (remainingCount > 0)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+$remainingCount',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
      ],
    );
  }
}
