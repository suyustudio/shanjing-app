// collection_trail_card.dart
// 山径APP - 收藏夹内路线卡片

import 'package:flutter/material.dart';
import '../../models/collection_model.dart';
import '../../utils/format_utils.dart';
import '../collections/tag_chip.dart';

/// 收藏夹内路线卡片
class CollectionTrailCard extends StatelessWidget {
  final CollectionTrail trail;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final String? searchQuery;

  const CollectionTrailCard({
    Key? key,
    required this.trail,
    required this.onTap,
    this.onRemove,
    this.searchQuery,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // 封面图
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    image: trail.coverImage != null
                        ? DecorationImage(
                            image: NetworkImage(trail.coverImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: trail.coverImage == null
                      ? Icon(Icons.image, color: Colors.grey.shade400)
                      : null,
                ),
              ),
              
              const SizedBox(width: 12),
              
              // 信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHighlightedText(
                      trail.name,
                      const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.straighten, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          FormatUtils.formatDistance(trail.distanceKm),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(Icons.schedule, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          FormatUtils.formatDuration(trail.durationMin),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildDifficultyBadge(trail.difficulty),
                        if (trail.rating != null) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 2),
                          Text(
                            trail.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (trail.note != null && trail.note!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      _buildHighlightedText(
                        trail.note!,
                        TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (trail.tags.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 4,
                        runSpacing: 2,
                        children: trail.tags.map((tag) => TagChip(
                          tag: tag,
                          style: TagChipStyle.normal,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              
              // 移除按钮
              if (onRemove != null)
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                  onPressed: onRemove,
                  tooltip: '移除',
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建高亮文本（如果searchQuery不为空且匹配）
  Widget _buildHighlightedText(String text, TextStyle style) {
    if (searchQuery == null || searchQuery!.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    final query = searchQuery!.toLowerCase();
    final lowerText = text.toLowerCase();
    final matches = <TextSpan>[];
    int lastMatchEnd = 0;
    
    // 查找所有匹配位置
    for (int i = 0; i <= lowerText.length - query.length; i++) {
      if (lowerText.substring(i, i + query.length) == query) {
        // 添加非匹配部分
        if (i > lastMatchEnd) {
          matches.add(TextSpan(
            text: text.substring(lastMatchEnd, i),
            style: style,
          ));
        }
        
        // 添加匹配部分（高亮）
        matches.add(TextSpan(
          text: text.substring(i, i + query.length),
          style: style.copyWith(
            backgroundColor: Colors.yellow.withOpacity(0.3),
            fontWeight: FontWeight.bold,
          ),
        ));
        
        lastMatchEnd = i + query.length;
        i += query.length - 1; // 跳过已匹配的部分
      }
    }
    
    // 添加剩余部分
    if (lastMatchEnd < text.length) {
      matches.add(TextSpan(
        text: text.substring(lastMatchEnd),
        style: style,
      ));
    }
    
    // 如果没有匹配，返回普通文本
    if (matches.isEmpty) {
      return Text(
        text,
        style: style,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    
    return RichText(
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: matches,
        style: style,
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    String label;
    
    switch (difficulty.toLowerCase()) {
      case 'easy':
        color = Colors.green;
        label = '简单';
        break;
      case 'moderate':
        color = Colors.orange;
        label = '中等';
        break;
      case 'hard':
        color = Colors.red;
        label = '困难';
        break;
      default:
        color = Colors.grey;
        label = difficulty;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
