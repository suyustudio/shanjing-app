import 'package:flutter/material.dart';
import '../constants/design_system.dart';

/// ============================================
/// 山径APP - 骨架屏组件 (Skeleton Component)
/// ============================================
///
/// 提供统一的加载骨架屏，用于内容加载中的占位显示
///
/// 使用示例:
/// ```dart
/// // 基础骨架屏
/// Skeleton()
///
/// // 卡片骨架屏
/// Skeleton.card()
///
/// // 列表骨架屏
/// SkeletonList(itemCount: 5)
///
/// // 路线卡片骨架屏
/// SkeletonRouteCard()
///
/// // 发现页骨架屏
/// SkeletonDiscovery()
/// ```

/// ============================================
/// 基础骨架屏组件
/// ============================================
class Skeleton extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final EdgeInsetsGeometry? margin;
  final Color? baseColor;
  final Color? highlightColor;

  const Skeleton({
    super.key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.margin,
    this.baseColor,
    this.highlightColor,
  });

  /// 圆形骨架屏
  factory Skeleton.circle({
    double? size = 48,
    EdgeInsetsGeometry? margin,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Skeleton(
      width: size,
      height: size,
      borderRadius: 999,
      margin: margin,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// 文本骨架屏
  factory Skeleton.text({
    double width = double.infinity,
    double height = 16,
    EdgeInsetsGeometry? margin,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Skeleton(
      width: width,
      height: height,
      borderRadius: 4,
      margin: margin,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// 卡片骨架屏
  factory Skeleton.card({
    double? width,
    double height = 120,
    EdgeInsetsGeometry? margin,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Skeleton(
      width: width,
      height: height,
      borderRadius: 12,
      margin: margin,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  /// 头像骨架屏
  factory Skeleton.avatar({
    double size = 48,
    EdgeInsetsGeometry? margin,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return Skeleton.circle(
      size: size,
      margin: margin,
      baseColor: baseColor,
      highlightColor: highlightColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ShimmerEffect(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

/// ============================================
/// 闪光动画效果
/// ============================================
class _ShimmerEffect extends StatefulWidget {
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const _ShimmerEffect({
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<_ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<_ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();
    _animation = Tween<double>(begin: -1, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = widget.baseColor ??
        (isDark ? const Color(0xFF2C2C2C) : const Color(0xFFF0F0F0));
    final highlight = widget.highlightColor ??
        (isDark ? const Color(0xFF3C3C3C) : const Color(0xFFE8E8E8));

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [base, highlight, base],
              stops: [
                _animation.value - 0.3,
                _animation.value,
                _animation.value + 0.3,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// ============================================
/// 列表骨架屏
/// ============================================
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? itemMargin;
  final bool hasLeading;
  final bool hasSubtitle;
  final int subtitleLines;

  const SkeletonList({
    super.key,
    this.itemCount = 5,
    this.itemHeight = 80,
    this.padding,
    this.itemMargin,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.all(16),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return SkeletonListItem(
          height: itemHeight,
          margin: itemMargin ?? const EdgeInsets.only(bottom: 12),
          hasLeading: hasLeading,
          hasSubtitle: hasSubtitle,
          subtitleLines: subtitleLines,
        );
      },
    );
  }
}

/// ============================================
/// 列表项骨架屏
/// ============================================
class SkeletonListItem extends StatelessWidget {
  final double? height;
  final EdgeInsetsGeometry? margin;
  final bool hasLeading;
  final bool hasSubtitle;
  final int subtitleLines;

  const SkeletonListItem({
    super.key,
    this.height = 80,
    this.margin,
    this.hasLeading = true,
    this.hasSubtitle = true,
    this.subtitleLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: margin,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // 左侧图片/图标占位
          if (hasLeading) ...[
            Skeleton.avatar(size: 56),
            const SizedBox(width: 12),
          ],
          // 文字区域
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 标题
                Skeleton.text(width: double.infinity, height: 16),
                // 副标题
                if (hasSubtitle) ...[
                  const SizedBox(height: 8),
                  for (int i = 0; i < subtitleLines; i++) ...[
                    if (i > 0) const SizedBox(height: 4),
                    Skeleton.text(width: i == subtitleLines - 1 ? 120 : double.infinity, height: 12),
                  ],
                ],
              ],
            ),
          ),
          // 右侧操作区域
          Skeleton(width: 24, height: 24, borderRadius: 4),
        ],
      ),
    );
  }
}

/// ============================================
/// 路线卡片骨架屏
/// ============================================
class SkeletonRouteCard extends StatelessWidget {
  final EdgeInsetsGeometry? margin;

  const SkeletonRouteCard({
    super.key,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: Row(
        children: [
          // 左侧缩略图占位
          Skeleton(width: 80, height: 60, borderRadius: 4),
          const SizedBox(width: 12),
          // 右侧信息占位
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton.text(width: double.infinity, height: 18),
                const SizedBox(height: 8),
                Skeleton.text(width: 120, height: 14),
              ],
            ),
          ),
          // 右侧箭头
          Skeleton(width: 24, height: 24, borderRadius: 4),
        ],
      ),
    );
  }
}

/// ============================================
/// 发现页骨架屏
/// ============================================
class SkeletonDiscovery extends StatelessWidget {
  const SkeletonDiscovery({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 搜索栏占位
          Skeleton(height: 48, borderRadius: 24),
          const SizedBox(height: 16),
          // 筛选标签占位
          Row(
            children: [
              Skeleton(width: 60, height: 32, borderRadius: 16),
              const SizedBox(width: 8),
              Skeleton(width: 60, height: 32, borderRadius: 16),
              const SizedBox(width: 8),
              Skeleton(width: 60, height: 32, borderRadius: 16),
              const SizedBox(width: 8),
              Skeleton(width: 60, height: 32, borderRadius: 16),
            ],
          ),
          const SizedBox(height: 24),
          // Banner占位
          Skeleton(width: double.infinity, height: 180, borderRadius: 12),
          const SizedBox(height: 24),
          // 区块标题占位
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 120, height: 22, borderRadius: 4),
              Skeleton(width: 60, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          // 路线卡片占位（2列网格）
          Row(
            children: [
              Expanded(
                child: _SkeletonGridCard(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _SkeletonGridCard(),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 另一个区块
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Skeleton(width: 100, height: 22, borderRadius: 4),
              Skeleton(width: 60, height: 16, borderRadius: 4),
            ],
          ),
          const SizedBox(height: 16),
          // 列表形式路线卡片
          SkeletonRouteCard(),
          SkeletonRouteCard(),
          SkeletonRouteCard(),
        ],
      ),
    );
  }
}

/// ============================================
/// 网格卡片骨架屏（用于发现页）
/// ============================================
class _SkeletonGridCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 图片占位（16:9比例）
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Skeleton(borderRadius: 8),
        ),
        const SizedBox(height: 8),
        // 标题占位
        Skeleton.text(width: double.infinity, height: 16),
        const SizedBox(height: 4),
        // 副标题占位
        Skeleton.text(width: 80, height: 12),
      ],
    );
  }
}

/// ============================================
/// 路线详情页骨架屏
/// ============================================
class SkeletonTrailDetail extends StatelessWidget {
  const SkeletonTrailDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头图占位
          Skeleton(width: double.infinity, height: 240, borderRadius: 0),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 标题占位
                Skeleton.text(width: 200, height: 24),
                const SizedBox(height: 8),
                // 副标题占位
                Skeleton.text(width: 150, height: 16),
                const SizedBox(height: 16),
                // 数据指标占位
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _SkeletonMetric(),
                    _SkeletonMetric(),
                    _SkeletonMetric(),
                    _SkeletonMetric(),
                  ],
                ),
                const SizedBox(height: 24),
                // 区块标题
                Skeleton.text(width: 80, height: 18),
                const SizedBox(height: 12),
                // 描述文字占位
                Skeleton.text(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                Skeleton.text(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                Skeleton.text(width: double.infinity, height: 14),
                const SizedBox(height: 4),
                Skeleton.text(width: 200, height: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ============================================
/// 数据指标骨架屏
/// ============================================
class _SkeletonMetric extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Skeleton.circle(size: 32),
        const SizedBox(height: 8),
        Skeleton(width: 40, height: 16, borderRadius: 4),
        const SizedBox(height: 4),
        Skeleton(width: 30, height: 12, borderRadius: 4),
      ],
    );
  }
}

/// ============================================
/// 离线地图页面骨架屏
/// ============================================
class SkeletonOfflineMap extends StatelessWidget {
  const SkeletonOfflineMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 搜索栏占位
        Padding(
          padding: const EdgeInsets.all(16),
          child: Skeleton(height: 48, borderRadius: 8),
        ),
        // 信息提示占位
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Skeleton(width: double.infinity, height: 50, borderRadius: 8),
        ),
        const SizedBox(height: 8),
        // 城市列表占位
        Expanded(
          child: SkeletonList(
            itemCount: 8,
            hasLeading: true,
            hasSubtitle: true,
          ),
        ),
      ],
    );
  }
}

/// ============================================
/// 个人中心骨架屏
/// ============================================
class SkeletonProfile extends StatelessWidget {
  const SkeletonProfile({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 头像占位
          Skeleton.circle(size: 80),
          const SizedBox(height: 16),
          // 昵称占位
          Skeleton(width: 120, height: 20, borderRadius: 4),
          const SizedBox(height: 8),
          // ID占位
          Skeleton(width: 80, height: 14, borderRadius: 4),
          const SizedBox(height: 24),
          // 统计卡片占位
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DesignSystem.getBackgroundElevated(context),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SkeletonStatItem(),
                _SkeletonStatItem(),
                _SkeletonStatItem(),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // 设置列表占位
          for (int i = 0; i < 4; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            Skeleton(width: double.infinity, height: 56, borderRadius: 8),
          ],
        ],
      ),
    );
  }
}

class _SkeletonStatItem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Skeleton(width: 40, height: 24, borderRadius: 4),
        const SizedBox(height: 4),
        Skeleton(width: 60, height: 12, borderRadius: 4),
      ],
    );
  }
}
