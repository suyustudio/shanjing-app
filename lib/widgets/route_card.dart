import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../constants/design_system.dart';

enum RouteDifficulty { easy, moderate, hard }

class RouteCard extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String distance;
  final String duration;
  final RouteDifficulty? difficulty;
  final VoidCallback? onTap;

  const RouteCard({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.distance,
    required this.duration,
    this.difficulty,
    this.onTap,
  });

  Color _getDifficultyColor() {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return Colors.green;
      case RouteDifficulty.moderate:
        return Colors.orange;
      case RouteDifficulty.hard:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyLabel() {
    switch (difficulty) {
      case RouteDifficulty.easy:
        return '简单';
      case RouteDifficulty.moderate:
        return '中等';
      case RouteDifficulty.hard:
        return '困难';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(DesignSystem.spacingSmall + 4),
        decoration: BoxDecoration(
          color: DesignSystem.background,
          borderRadius: BorderRadius.circular(DesignSystem.radius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 左侧缩略图
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 80,
                height: 60,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80,
                  height: 60,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: DesignSystem.spacingSmall + 4),
            // 右侧信息
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          name,
                          style: const TextStyle(
                            fontSize: DesignSystem.fontHeading - 2,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (difficulty != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: _getDifficultyColor(),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _getDifficultyLabel(),
                            style: const TextStyle(
                              fontSize: DesignSystem.fontSmall,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$distance · $duration',
                    style: const TextStyle(
                      fontSize: DesignSystem.fontBody,
                      color: DesignSystem.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
