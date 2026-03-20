// ================================================================
// M6: 全屏图片查看器 (支持手势缩放)
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/design_system.dart';
import '../models/photo_model.dart';

/// 全屏图片查看器
class PhotoViewer extends StatefulWidget {
  final List<Photo> photos;
  final int initialIndex;
  final Function(Photo photo)? onLikeTap;
  final Function(Photo photo)? onShareTap;
  final VoidCallback? onClose;

  const PhotoViewer({
    Key? key,
    required this.photos,
    this.initialIndex = 0,
    this.onLikeTap,
    this.onShareTap,
    this.onClose,
  }) : super(key: key);

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer>
    with SingleTickerProviderStateMixin {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUI = true;
  double _dragStart = 0;
  double _dragPosition = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);

    // 隐藏状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    _pageController.dispose();
    // 恢复状态栏
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
    });
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _dragStart = details.globalPosition.dy;
    _isDragging = true;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (!_isDragging) return;
    setState(() {
      _dragPosition = details.globalPosition.dy - _dragStart;
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    _isDragging = false;
    if (_dragPosition.abs() > 100) {
      // 向下拖动超过阈值，关闭查看器
      _closeViewer();
    } else {
      setState(() {
        _dragPosition = 0;
      });
    }
  }

  void _closeViewer() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPhoto = widget.photos[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _toggleUI,
        onVerticalDragStart: _onVerticalDragStart,
        onVerticalDragUpdate: _onVerticalDragUpdate,
        onVerticalDragEnd: _onVerticalDragEnd,
        child: Stack(
          children: [
            // 图片轮播
            Transform.translate(
              offset: Offset(0, _dragPosition),
              child: Opacity(
                opacity: 1 - (_dragPosition.abs() / 300).clamp(0.0, 1.0),
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: widget.photos.length,
                  itemBuilder: (context, index) {
                    return _PhotoPage(
                      photo: widget.photos[index],
                    );
                  },
                ),
              ),
            ),

            // 顶部导航栏
            if (_showUI)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back, color: Colors.white),
                          onPressed: _closeViewer,
                        ),
                        const Spacer(),
                        Text(
                          '${_currentIndex + 1} / ${widget.photos.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Colors.white),
                          color: Colors.grey[900],
                          onSelected: (value) {
                            switch (value) {
                              case 'share':
                                widget.onShareTap?.call(currentPhoto);
                                break;
                              case 'download':
                                _downloadPhoto(currentPhoto);
                                break;
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'share',
                              child: Row(
                                children: [
                                  Icon(Icons.share, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('分享', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'download',
                              child: Row(
                                children: [
                                  Icon(Icons.download, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('保存图片', style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // 底部信息栏
            if (_showUI)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(16, 40, 16, 24),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // 用户信息
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundImage: currentPhoto.user.avatarUrl != null
                                  ? NetworkImage(currentPhoto.user.avatarUrl!)
                                  : null,
                              backgroundColor: DesignSystem.primaryColor,
                              child: currentPhoto.user.avatarUrl == null
                                  ? Text(
                                      currentPhoto.user.nickname?.substring(0, 1) ?? '',
                                      style: const TextStyle(color: Colors.white),
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    currentPhoto.user.nickname ?? '匿名用户',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (currentPhoto.createdAt != null)
                                    Text(
                                      _formatDate(currentPhoto.createdAt),
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.7),
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // 描述
                        if (currentPhoto.description != null &&
                            currentPhoto.description!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              currentPhoto.description!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),

                        // 互动按钮
                        Row(
                          children: [
                            _ActionButton(
                              icon: currentPhoto.isLiked
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              label: '${currentPhoto.likeCount}',
                              color: currentPhoto.isLiked
                                  ? DesignSystem.errorColor
                                  : Colors.white,
                              onTap: () => widget.onLikeTap?.call(currentPhoto),
                            ),
                            const SizedBox(width: 24),
                            _ActionButton(
                              icon: Icons.comment_outlined,
                              label: '评论',
                              color: Colors.white,
                              onTap: () {
                                // TODO: 打开评论
                              },
                            ),
                            const SizedBox(width: 24),
                            _ActionButton(
                              icon: Icons.bookmark_border,
                              label: '收藏',
                              color: Colors.white,
                              onTap: () {
                                // TODO: 收藏
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}年前';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}个月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }

  void _downloadPhoto(Photo photo) {
    // TODO: 实现图片下载
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('图片保存功能开发中')),
    );
  }
}

/// 单张图片页面（支持缩放）
class _PhotoPage extends StatefulWidget {
  final Photo photo;

  const _PhotoPage({
    required this.photo,
  });

  @override
  State<_PhotoPage> createState() => _PhotoPageState();
}

class _PhotoPageState extends State<_PhotoPage>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformationController =
      TransformationController();
  late AnimationController _animationController;
  Animation<Matrix4>? _animation;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    if (_isZoomed) {
      _resetZoom();
    } else {
      _zoomIn();
    }
  }

  void _zoomIn() {
    final matrix = Matrix4.identity()..scale(2.0);
    _animateTo(matrix);
    setState(() {
      _isZoomed = true;
    });
  }

  void _resetZoom() {
    _animateTo(Matrix4.identity());
    setState(() {
      _isZoomed = false;
    });
  }

  void _animateTo(Matrix4 matrix) {
    _animation = Matrix4Tween(
      begin: _transformationController.value,
      end: matrix,
    ).animate(_animationController);

    _animationController.forward(from: 0);
    _animation!.addListener(() {
      _transformationController.value = _animation!.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: _onDoubleTap,
      child: InteractiveViewer(
        transformationController: _transformationController,
        minScale: 1.0,
        maxScale: 4.0,
        panEnabled: _isZoomed,
        boundaryMargin: const EdgeInsets.all(20),
        child: Center(
          child: Hero(
            tag: 'photo_${widget.photo.id}',
            child: Image.network(
              widget.photo.url,
              fit: BoxFit.contain,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      DesignSystem.primaryColor,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.broken_image,
                    color: Colors.white54,
                    size: 64,
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// 互动按钮
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 显示图片查看器的辅助方法
void showPhotoViewer({
  required BuildContext context,
  required List<Photo> photos,
  int initialIndex = 0,
  Function(Photo photo)? onLikeTap,
  Function(Photo photo)? onShareTap,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => PhotoViewer(
        photos: photos,
        initialIndex: initialIndex,
        onLikeTap: onLikeTap,
        onShareTap: onShareTap,
      ),
      fullscreenDialog: true,
    ),
  );
}
