// ============================================
// 推荐卡片组件
// ============================================

import 'package:flutter/material.dart';
import '../../models/recommendation_model.dart';

/// 推荐卡片
class RecommendationCard extends StatelessWidget {
  final RecommendedTrail trail;
  final VoidCallback? onTap;
  final VoidCallback? onBookmarkTap;
  final bool showMatchScore;
  final double width;
  final double height;

  const RecommendationCard({
    Key? key,
    required this.trail,
    this.onTap,
    this.onBookmarkTap,
    this.showMatchScore = true,
    this.width = 280,
    this.height = 200,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // 背景图片
              _buildBackgroundImage(),
              
              // 渐变遮罩
              _buildGradientOverlay(),
              
              // 内容
              _buildContent(),
              
              // 匹配度标签
              if (showMatchScore) _buildMatchScoreBadge(),
              
              // 收藏按钮
              if (onBookmarkTap != null) _buildBookmarkButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundImage() {
    return Positioned.fill(
      child: trail.coverImage.isNotEmpty
          ? Image.network(
              trail.coverImage,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                );
              },
            )
          : Container(color: Colors.grey[300]),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.7),
            ],
            stops: const [0.5, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Positioned(
      left: 12,
      right: 12,
      bottom: 12,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 路线名称
          Text(
            trail.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          
          const SizedBox(height: 6),
          
          // 推荐理由
          if (trail.recommendReason != null)
            Text(
              trail.recommendReason!,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          
          const SizedBox(height: 8),
          
          // 路线信息
          Row(
            children: [
              _buildInfoItem(Icons.location_on, trail.formattedDistance),
              const SizedBox(width: 12),
              _buildInfoItem(Icons.timer, trail.formattedDuration),
              const SizedBox(width: 12),
              _buildInfoItem(Icons.trending_up, trail.difficultyText),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // 评分
          Row(
            children: [
              Icon(Icons.star, size: 14, color: Colors.amber[400]),
              const SizedBox(width: 4),
              Text(
                trail.rating.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.white70),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMatchScoreBadge() {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: _getMatchScoreColor().withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.star,
              size: 12,
              color: Colors.white.withOpacity(0.9),
            ),
            const SizedBox(width: 4),
            Text(
              trail.matchScoreText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookmarkButton() {
    return Positioned(
      top: 12,
      right: 12,
      child: GestureDetector(
        onTap: onBookmarkTap,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.bookmark_border,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Color _getMatchScoreColor() {
    if (trail.matchScore >= 80) {
      return Colors.green;
    } else if (trail.matchScore >= 60) {
      return Colors.orange;
    } else {
      return Colors.blue;
    }
  }
}

/// 横向推荐列表
class RecommendationHorizontalList extends StatelessWidget {
  final List<RecommendedTrail> trails;
  final String title;
  final VoidCallback? onViewAllTap;
  final Function(RecommendedTrail)? onTrailTap;
  final Function(RecommendedTrail)? onBookmarkTap;

  const RecommendationHorizontalList({
    Key? key,
    required this.trails,
    required this.title,
    this.onViewAllTap,
    this.onTrailTap,
    this.onBookmarkTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标题栏
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAllTap != null)
                TextButton(
                  onPressed: onViewAllTap,
                  child: const Text('查看更多 >'),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 12),
        
        // 横向列表
        SizedBox(
          height: 200,
          child: trails.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: trails.length,
                  itemBuilder: (context, index) {
                    final trail = trails[index];
                    return RecommendationCard(
                      trail: trail,
                      onTap: () => onTrailTap?.call(trail),
                      onBookmarkTap: onBookmarkTap != null
                          ? () => onBookmarkTap!.call(trail)
                          : null,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        '暂无推荐路线',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }
}