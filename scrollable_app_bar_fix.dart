import 'package:flutter/material.dart';

/// ScrollableAppBar - 带滚动效果的导航栏组件
/// 
/// 修复记录:
/// - 修复 P1: 在 dispose 中移除 ScrollController 监听器，防止内存泄漏
/// - 修复 P2: 使用 ValueNotifier 优化，避免频繁的 setState 重建
/// 
/// 特性:
/// - 滚动时自动调整高度和透明度
/// - 支持背景模糊效果
/// - 支持自定义标题和操作按钮
/// - 响应式适配

class ScrollableAppBar extends StatefulWidget {
  const ScrollableAppBar({
    Key? key,
    required this.scrollController,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.elevation = 0,
    this.expandedHeight = 120.0,
    this.collapsedHeight = kToolbarHeight,
    this.backgroundImage,
    this.blurEnabled = true,
    this.showShadowOnCollapse = true,
    this.flexibleSpace,
    this.onCollapsed,
  }) : assert(title != null || titleWidget != null || flexibleSpace != null),
       super(key: key);

  /// 滚动控制器 - 必须传入外部控制器
  final ScrollController scrollController;
  
  /// 标题文本
  final String? title;
  
  /// 自定义标题组件（优先级高于 title）
  final Widget? titleWidget;
  
  /// 左侧按钮
  final Widget? leading;
  
  /// 右侧操作按钮
  final List<Widget>? actions;
  
  /// 背景颜色
  final Color? backgroundColor;
  
  /// 阴影高度
  final double elevation;
  
  /// 展开高度
  final double expandedHeight;
  
  /// 折叠高度
  final double collapsedHeight;
  
  /// 背景图片
  final String? backgroundImage;
  
  /// 是否启用背景模糊
  final bool blurEnabled;
  
  /// 折叠时是否显示阴影
  final bool showShadowOnCollapse;
  
  /// 自定义弹性空间
  final Widget? flexibleSpace;
  
  /// 折叠状态回调
  final ValueChanged<bool>? onCollapsed;

  @override
  State<ScrollableAppBar> createState() => _ScrollableAppBarState();
}

class _ScrollableAppBarState extends State<ScrollableAppBar> {
  /// 使用 ValueNotifier 替代 setState 优化性能
  final ValueNotifier<double> _scrollProgressNotifier = ValueNotifier<double>(0.0);
  final ValueNotifier<bool> _isCollapsedNotifier = ValueNotifier<bool>(false);
  
  /// 滚动监听器的引用，用于 dispose 时移除
  VoidCallback? _scrollListener;

  @override
  void initState() {
    super.initState();
    _attachScrollListener();
    
    // 监听折叠状态变化，触发回调
    _isCollapsedNotifier.addListener(_onCollapsedChanged);
  }

  /// 附加滚动监听器
  void _attachScrollListener() {
    _scrollListener = () {
      if (!widget.scrollController.hasClients) return;
      
      final scrollOffset = widget.scrollController.offset;
      final maxScroll = widget.expandedHeight - widget.collapsedHeight;
      
      // 计算滚动进度 (0.0 ~ 1.0)
      final progress = (scrollOffset / maxScroll).clamp(0.0, 1.0);
      _scrollProgressNotifier.value = progress;
      
      // 更新折叠状态
      final isCollapsed = scrollOffset >= maxScroll;
      if (_isCollapsedNotifier.value != isCollapsed) {
        _isCollapsedNotifier.value = isCollapsed;
      }
    };
    
    widget.scrollController.addListener(_scrollListener!);
  }

  /// 折叠状态变化回调
  void _onCollapsedChanged() {
    widget.onCollapsed?.call(_isCollapsedNotifier.value);
  }

  @override
  void didUpdateWidget(ScrollableAppBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 如果控制器发生变化，重新附加监听器
    if (widget.scrollController != oldWidget.scrollController) {
      _removeScrollListener();
      _attachScrollListener();
    }
  }

  @override
  void dispose() {
    // ============================================
    // 修复 P1: 内存泄漏问题
    // 必须移除监听器，防止控制器 dispose 后仍有回调引用
    // ============================================
    _removeScrollListener();
    
    // 移除折叠状态监听
    _isCollapsedNotifier.removeListener(_onCollapsedChanged);
    
    // 释放 ValueNotifier
    _scrollProgressNotifier.dispose();
    _isCollapsedNotifier.dispose();
    
    super.dispose();
  }

  /// 移除滚动监听器
  void _removeScrollListener() {
    if (_scrollListener != null) {
      widget.scrollController.removeListener(_scrollListener!);
      _scrollListener = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 默认背景色
    final defaultBackgroundColor = isDark 
        ? const Color(0xFF0F0F0F) 
        : const Color(0xFFFFFFFF);
    
    return ValueListenableBuilder<double>(
      valueListenable: _scrollProgressNotifier,
      builder: (context, progress, child) {
        // 计算动画值
        final currentHeight = lerpDouble(
          widget.expandedHeight,
          widget.collapsedHeight,
          progress,
        );
        
        final backgroundOpacity = progress;
        final titleOpacity = progress < 0.5 ? 0.0 : (progress - 0.5) * 2;
        final expandedTitleOpacity = 1.0 - progress * 2;
        
        return ValueListenableBuilder<bool>(
          valueListenable: _isCollapsedNotifier,
          builder: (context, isCollapsed, child) {
            return Container(
              height: currentHeight,
              decoration: BoxDecoration(
                color: (widget.backgroundColor ?? defaultBackgroundColor)
                    .withOpacity(backgroundOpacity),
                boxShadow: (widget.showShadowOnCollapse && isCollapsed)
                    ? [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: ClipRect(
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 背景图片
                    if (widget.backgroundImage != null)
                      _buildBackgroundImage(progress),
                    
                    // 背景模糊
                    if (widget.blurEnabled && progress > 0)
                      _buildBlurOverlay(progress),
                    
                    // 弹性空间内容
                    if (widget.flexibleSpace != null && expandedTitleOpacity > 0)
                      Opacity(
                        opacity: expandedTitleOpacity,
                        child: Align(
                          alignment: Alignment.bottomLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: widget.flexibleSpace,
                          ),
                        ),
                      ),
                    
                    // 导航栏内容
                    SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Row(
                          children: [
                            // 左侧按钮
                            if (widget.leading != null)
                              widget.leading!
                            else
                              const SizedBox(width: 48),
                            
                            // 标题
                            Expanded(
                              child: Opacity(
                                opacity: titleOpacity,
                                child: widget.titleWidget ??
                                    Text(
                                      widget.title ?? '',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        color: isDark 
                                            ? Colors.white 
                                            : Colors.black,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                              ),
                            ),
                            
                            // 右侧操作
                            if (widget.actions != null)
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: widget.actions!,
                              )
                            else
                              const SizedBox(width: 48),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 构建背景图片
  Widget _buildBackgroundImage(double progress) {
    return Positioned.fill(
      child: Opacity(
        opacity: 1.0 - progress,
        child: Image.network(
          widget.backgroundImage!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[800],
              child: const Center(
                child: Icon(Icons.image_not_supported, color: Colors.white54),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 构建模糊遮罩
  Widget _buildBlurOverlay(double progress) {
    return Positioned.fill(
      child: Container(
        color: (widget.backgroundColor ?? Colors.white)
            .withOpacity(progress * 0.8),
      ),
    );
  }
}

/// 线性插值工具函数
double lerpDouble(double a, double b, double t) {
  return a + (b - a) * t;
}

/// 使用示例
/// 
/// ```dart
/// class MyPage extends StatefulWidget {
///   @override
///   State<MyPage> createState() => _MyPageState();
/// }
/// 
/// class _MyPageState extends State<MyPage> {
///   // 重要：控制器必须在 State 级别定义
///   final ScrollController _scrollController = ScrollController();
///   
///   @override
///   void dispose() {
///     _scrollController.dispose();
///     super.dispose();
///   }
///   
///   @override
///   Widget build(BuildContext context) {
///     return Scaffold(
///       body: CustomScrollView(
///         controller: _scrollController,
///         slivers: [
///           SliverPersistentHeader(
///             pinned: true,
///             delegate: _SliverAppBarDelegate(
///               child: ScrollableAppBar(
///                 scrollController: _scrollController,
///                 title: '页面标题',
///                 expandedHeight: 200,
///                 flexibleSpace: Column(
///                   crossAxisAlignment: CrossAxisAlignment.start,
///                   mainAxisSize: MainAxisSize.min,
///                   children: [
///                     Text(
///                       '大标题',
///                       style: TextStyle(
///                         fontSize: 28,
///                         fontWeight: FontWeight.bold,
///                         color: Colors.white,
///                       ),
///                     ),
///                     Text(
///                       '副标题描述',
///                       style: TextStyle(
///                         fontSize: 14,
///                         color: Colors.white70,
///                       ),
///                     ),
///                   ],
///                 ),
///               ),
///             ),
///           ),
///           SliverList(
///             delegate: SliverChildBuilderDelegate(
///               (context, index) => ListTile(
///                 title: Text('Item $index'),
///               ),
///               childCount: 50,
///             ),
///           ),
///         ],
///       ),
///     );
///   }
/// }
/// 
/// class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
///   final Widget child;
///   
///   _SliverAppBarDelegate({required this.child});
///   
///   @override
///   double get minExtent => kToolbarHeight;
///   
///   @override
///   double get maxExtent => 200;
///   
///   @override
///   Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
///     return child;
///   }
///   
///   @override
///   bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) => false;
/// }
/// ```
