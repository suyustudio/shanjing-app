// ================================================================
// M6: 照片瀑布流组件 (Masonry Layout)
// ================================================================

import 'package:flutter/material.dart';
import '../constants/design_system.dart';
import '../models/photo_model.dart';
import '../utils/image_lazy_loader.dart';

/// 瀑布流照片列表组件
class PhotoMasonryGrid extends StatelessWidget {
  final List<Photo> photos;
  final ScrollController? scrollController;
  final Function(Photo photo)? onPhotoTap;
  final Function(Photo photo)? onLikeTap;
  final bool isLoading;
  final bool hasMore;
  final VoidCallback? onLoadMore;
  final EdgeInsets padding;

  const PhotoMasonryGrid({
    Key? key,
    required this.photos,
    this.scrollController,
    this.onPhotoTap,
    this.onLikeTap,
    this.isLoading = false,
    this.hasMore = false,
    this.onLoadMore,
    this.padding = const EdgeInsets.all(4),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollEndNotification &&
            notification.metrics.extentAfter < 200 &&
            hasMore &&
            !isLoading &&
            onLoadMore != null) {
          onLoadMore!();
        }
        return false;
      },
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverPadding(
            padding: padding,
            sliver: _MasonryGrid(
              photos: photos,
              onPhotoTap: onPhotoTap,
              onLikeTap: onLikeTap,
            ),
          ),
          if (isLoading)
            SliverToBoxAdapter(
              child: _buildLoadingIndicator(),
            ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(DesignSystem.primaryColor),
      ),
    );
  }
}

/// 内部瀑布流网格实现
class _MasonryGrid extends StatelessWidget {
  final List<Photo> photos;
  final Function(Photo photo)? onPhotoTap;
  final Function(Photo photo)? onLikeTap;

  const _MasonryGrid({
    required this.photos,
    this.onPhotoTap,
    this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    return SliverLayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = _getCrossAxisCount(constraints.crossAxisExtent);
        final columnPhotos = _distributePhotos(crossAxisCount);

        return SliverToBoxAdapter(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(
              crossAxisCount,
              (index) => Expanded(
                child: Column(
                  children: columnPhotos[index]
                      .map((photo) => _PhotoCard(
                            photo: photo,
                            onTap: () => onPhotoTap?.call(photo),
                            onLikeTap: () => onLikeTap?.call(photo),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 600) return 4;
    if (width > 400) return 3;
    return 2;
  }

  List<List<Photo>> _distributePhotos(int columnCount) {
    final columns = List.generate(columnCount, (_) => <Photo>[]);
    final columnHeights = List.generate(columnCount, (_) => 0.0);

    for (final photo in photos) {
      // 找到高度最小的列
      var minColumn = 0;
      var minHeight = columnHeights[0];

      for (var i = 1; i < columnCount; i++) {
        if (columnHeights[i] < minHeight) {
          minHeight = columnHeights[i];
          minColumn = i;
        }
      }

      columns[minColumn].add(photo);

      // 估算高度（基于宽高比）
      final aspectRatio = (photo.width != null && photo.height != null && photo.height! > 0)
          ? photo.width! / photo.height!
          : 1.0;
      final estimatedHeight = 200 / aspectRatio;
      columnHeights[minColumn] += estimatedHeight + 4; // 4是间距
    }

    return columns;
  }
}

/// 照片卡片组件
class _PhotoCard extends StatelessWidget {
  final Photo photo;
  final VoidCallback? onTap;
  final VoidCallback? onLikeTap;

  const _PhotoCard({
    required this.photo,
    this.onTap,
    this.onLikeTap,
  });

  @override
  Widget build(BuildContext context) {
    // 计算高度（基于宽高比）
    final aspectRatio = (photo.width != null && photo.height != null && photo.width! > 0)
        ? photo.width! / photo.height!
        : 1.0;
    
    // 限制高度范围
    double estimatedHeight = 150 / aspectRatio;
    if (estimatedHeight < 120) estimatedHeight = 120;
    if (estimatedHeight > 300) estimatedHeight = 300;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Stack(
            children: [
              // 图片
              ImageLazyLoader(
                imageUrl: photo.thumbnailUrl ?? photo.url,
                width: double.infinity,
                height: estimatedHeight,
                fit: BoxFit.cover,
                borderRadius: 4,
              ),

              // 渐变遮罩
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.6),
                      ],
                    ),
                  ),
                ),
              ),

              // 点赞数和用户信息
              Positioned(
                left: 8,
                right: 8,
                bottom: 8,
                child: Row(
                  children: [
                    // 点赞数
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          photo.isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 14,
                          color: photo.isLiked
                              ? DesignSystem.errorColor
                              : Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${photo.likeCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // 用户头像（小）
                    if (photo.user.avatarUrl != null)
                      ClipOval(
                        child: ImageLazyLoader(
                          imageUrl: photo.user.avatarUrl!,
                          width: 16,
                          height: 16,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
              ),

              // 点赞按钮（点击区域）
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: onLikeTap,
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(
                      photo.isLiked ? Icons.favorite : Icons.favorite_border,
                      size: 20,
                      color: photo.isLiked
                          ? DesignSystem.errorColor
                          : Colors.white.withOpacity(0.8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 照片加载骨架屏 (Masonry 风格)
class PhotoSkeletonGrid extends StatefulWidget {
  final int itemCount;

  const PhotoSkeletonGrid({
    Key? key,
    this.itemCount = 12,
  }) : super(key: key);

  @override
  State<PhotoSkeletonGrid> createState() => _PhotoSkeletonGridState();
}

class _PhotoSkeletonGridState extends State<PhotoSkeletonGrid>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  // P1: 瀑布流骨架屏应模拟不同高度 (120px-280px)
  final List<double> _heights = [120.0, 180.0, 150.0, 200.0, 160.0, 220.0, 140.0, 260.0];

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600
            ? 4
            : constraints.maxWidth > 400
                ? 3
                : 2;

        // 分配照片到各列
        final columns = List.generate(crossAxisCount, (_) => <int>[]);
        for (var i = 0; i < widget.itemCount; i++) {
          columns[i % crossAxisCount].add(i);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: columns.map((indices) {
            return Expanded(
              child: Column(
                children: indices.map((index) {
                  final height = _heights[index % _heights.length];
                  return Padding(
                    padding: const EdgeInsets.all(2),
                    child: _buildShimmerItem(height),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildShimmerItem(double height) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return Container(
          height: height,
          decoration: BoxDecoration(
            color: DesignSystem.skeletonBaseColor,
            borderRadius: BorderRadius.circular(4),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                DesignSystem.skeletonBaseColor,
                DesignSystem.skeletonHighlightColor,
                DesignSystem.skeletonBaseColor,
              ],
              stops: [
                0.0,
                _shimmerController.value,
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
