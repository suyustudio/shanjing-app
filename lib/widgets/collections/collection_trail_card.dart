// collection_trail_card.dart
// 山径APP - 收藏夹内路线卡片

import 'package:flutter/material.dart';
import '../../models/collection_model.dart';
import '../../utils/format_utils.dart';

/// 收藏夹内路线卡片
class CollectionTrailCard extends StatelessWidget {
  final CollectionTrail trail;
  final VoidCallback onTap;
  final VoidCallback? onRemove;

  const CollectionTrailCard({
    Key? key,
    required this.trail,
    required this.onTap,
    this.onRemove,
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
                    Text(
                      trail.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      Text(
                        trail.note!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
