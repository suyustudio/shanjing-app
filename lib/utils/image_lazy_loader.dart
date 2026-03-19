import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// 图片懒加载配置
class ImageLazyLoadConfig {
  /// 是否启用懒加载
  static const bool enableLazyLoad = true;
  
  /// 预加载偏移量（屏幕高度倍数）
  static const double preloadOffset = 0.5;
  
  /// 图片缓存最大数量
  static const int maxCacheImages = 100;
  
  /// 图片最大缓存大小（MB）
  static const int maxCacheSizeMB = 50;
}

/// 懒加载图片组件
/// 
/// 特性：
/// - 自动懒加载：进入视口才加载
/// - 预加载：提前加载即将进入视口的图片
/// - 淡入动画：加载完成时平滑过渡
class LazyLoadImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Duration fadeInDuration;
  final int? memCacheWidth;
  final int? memCacheHeight;

  const LazyLoadImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.memCacheWidth,
    this.memCacheHeight,
  });

  @override
  State<LazyLoadImage> createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  bool _isVisible = false;
  final GlobalKey _key = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: _VisibilityDetector(
        onVisibilityChanged: (visible) {
          if (visible && !_isVisible) {
            setState(() {
              _isVisible = true;
            });
          }
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: _isVisible
              ? CachedNetworkImage(
                  imageUrl: widget.imageUrl,
                  width: widget.width,
                  height: widget.height,
                  fit: widget.fit,
                  memCacheWidth: widget.memCacheWidth,
                  memCacheHeight: widget.memCacheHeight,
                  placeholder: (context, url) => 
                      widget.placeholder ?? _defaultPlaceholder(),
                  errorWidget: (context, url, error) => 
                      widget.errorWidget ?? _defaultErrorWidget(),
                  fadeInDuration: widget.fadeInDuration,
                )
              : (widget.placeholder ?? _defaultPlaceholder()),
        ),
      ),
    );
  }

  void _checkVisibility() {
    final RenderObject? renderObject = _key.currentContext?.findRenderObject();
    if (renderObject is RenderBox) {
      final bool visible = renderObject.hasSize;
      if (visible && !_isVisible) {
        setState(() {
          _isVisible = true;
        });
      }
    }
  }

  Widget _defaultPlaceholder() {
    return Container(
      color: Colors.grey.shade200,
      child: Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade400),
        ),
      ),
    );
  }

  Widget _defaultErrorWidget() {
    return Container(
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }
}

/// 可见性检测器
class _VisibilityDetector extends StatefulWidget {
  final Widget child;
  final Function(bool visible) onVisibilityChanged;

  const _VisibilityDetector({
    required this.child,
    required this.onVisibilityChanged,
  });

  @override
  State<_VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<_VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    final RenderObject? renderObject = context.findRenderObject();
    if (renderObject is RenderBox && renderObject.hasSize) {
      final Size size = renderObject.size;
      final Offset position = renderObject.localToGlobal(Offset.zero);
      
      final screenHeight = MediaQuery.of(context).size.height;
      final preloadOffset = screenHeight * ImageLazyLoadConfig.preloadOffset;
      
      final bool visible = position.dy < screenHeight + preloadOffset &&
                           position.dy + size.height > -preloadOffset;
      
      widget.onVisibilityChanged(visible);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// 图片预加载管理器
class ImagePreloader {
  static final ImagePreloader _instance = ImagePreloader._internal();
  factory ImagePreloader() => _instance;
  ImagePreloader._internal();

  final Set<String> _preloadingUrls = {};

  /// 预加载单张图片
  Future<void> preloadImage(BuildContext context, String url) async {
    if (_preloadingUrls.contains(url)) return;
    
    _preloadingUrls.add(url);
    
    final ImageConfiguration config = createLocalImageConfiguration(context);
    final NetworkImage provider = NetworkImage(url);
    
    try {
      await provider.obtainKey(config);
    } catch (e) {
      // 预加载失败，不影响主流程
    } finally {
      _preloadingUrls.remove(url);
    }
  }

  /// 预加载多张图片
  Future<void> preloadImages(BuildContext context, List<String> urls) async {
    for (final url in urls) {
      await preloadImage(context, url);
    }
  }
}

/// 性能优化的网络图片
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      // 限制内存缓存大小，避免OOM
      memCacheWidth: _calculateCacheWidth(context),
      memCacheHeight: _calculateCacheHeight(context),
      placeholder: (context, url) => Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      errorWidget: (context, url, error) => Container(
        color: Colors.grey.shade200,
        child: Icon(Icons.image_not_supported, color: Colors.grey.shade400),
      ),
    );

    if (borderRadius != null) {
      image = ClipRRect(
        borderRadius: borderRadius!,
        child: image,
      );
    }

    return image;
  }

  int? _calculateCacheWidth(BuildContext context) {
    if (width == null) {
      // 使用屏幕宽度
      return (MediaQuery.of(context).size.width * 2).toInt().clamp(0, 1440);
    }
    return (width! * 2).toInt().clamp(0, 1440);
  }

  int? _calculateCacheHeight(BuildContext context) {
    if (height == null) return null;
    return (height! * 2).toInt().clamp(0, 2560);
  }
}
