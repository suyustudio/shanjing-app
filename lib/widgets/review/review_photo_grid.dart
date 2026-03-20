/**
 * 评论图片网格组件
 * 
 * M6 评论系统 - 评论配图展示
 */

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 评论图片网格
class ReviewPhotoGrid extends StatelessWidget {
  final List<String> photos;
  final Function(String)? onTap;
  final double maxHeight;

  const ReviewPhotoGrid({
    Key? key,
    required this.photos,
    this.onTap,
    this.maxHeight = 120,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (photos.isEmpty) return SizedBox.shrink();

    // 根据图片数量决定布局
    switch (photos.length) {
      case 1:
        return _buildSinglePhoto();
      case 2:
        return _buildTwoPhotos();
      case 3:
      case 4:
        return _buildGridPhotos(2);
      default:
        return _buildGridPhotos(3);
    }
  }

  /// 单张图片
  Widget _buildSinglePhoto() {
    return GestureDetector(
      onTap: () => onTap?.call(photos[0]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: CachedNetworkImage(
          imageUrl: photos[0],
          height: maxHeight,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
          fadeInDuration: Duration(milliseconds: 200),
        ),
      ),
    );
  }

  /// 两张图片
  Widget _buildTwoPhotos() {
    return Row(
      children: photos.asMap().entries.map((entry) {
        final index = entry.key;
        final photo = entry.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              right: index == 0 ? 4 : 0,
              left: index == 1 ? 4 : 0,
            ),
            child: GestureDetector(
              onTap: () => onTap?.call(photo),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: photo,
                  height: maxHeight,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(),
                  errorWidget: (context, url, error) => _buildErrorWidget(),
                  fadeInDuration: Duration(milliseconds: 200),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 网格布局
  Widget _buildGridPhotos(int crossAxisCount) {
    final displayPhotos = photos.take(9).toList();
    final remainingCount = photos.length - 9;

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: displayPhotos.length,
      itemBuilder: (context, index) {
        final photo = displayPhotos[index];
        final isLast = index == displayPhotos.length - 1 && remainingCount > 0;

        return GestureDetector(
          onTap: () => onTap?.call(photo),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: photo,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildPlaceholder(),
                  errorWidget: (context, url, error) => _buildErrorWidget(),
                  fadeInDuration: Duration(milliseconds: 200),
                ),
                if (isLast)
                  Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Text(
                        '+$remainingCount',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// 加载占位
  Widget _buildPlaceholder() {
    return Container(
      color: Color(0xFFF3F4F6),
      child: Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D968A)),
          ),
        ),
      ),
    );
  }

  /// 错误 widget
  Widget _buildErrorWidget() {
    return Container(
      color: Color(0xFFF3F4F6),
      child: Icon(
        Icons.broken_image,
        color: Color(0xFF9CA3AF),
        size: 32,
      ),
    );
  }
}
