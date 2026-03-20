# M6 组件设计规范 - 社交互动组件

> **文档版本**: v1.0  
> **制定日期**: 2026-03-20  
> **关联文档**: M6-DESIGN-FIX-v1.0.md

---

## 1. LikeButton 点赞按钮组件

### 1.1 组件概览

一个带有动画效果的点赞按钮，支持点击状态切换和数字显示。

### 1.2 设计稿

```
初始状态              按下状态              已点赞状态
┌─────┐              ┌─────┐              ┌─────┐
│ 🖤  │              │ 🖤  │              │ ❤️  │
│ 23  │              │ 23  │              │ 24  │
└─────┘              └─────┘              └─────┘
 灰色                 收缩0.85x             品牌色
```

### 1.3 属性定义

| 属性 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| count | int | 是 | - | 点赞数量 |
| isLiked | bool | 是 | false | 是否已点赞 |
| onTap | VoidCallback? | 否 | null | 点击回调 |
| size | double | 否 | 24 | 图标尺寸 |
| showCount | bool | 否 | true | 是否显示数字 |

### 1.4 视觉规范

**颜色:**
| 状态 | 图标色 | 数字色 |
|------|--------|--------|
| 未点赞 | #9CA3AF | #9CA3AF |
| 已点赞 | #2D968A | #2D968A |
| 按下 | #6B7280 | #6B7280 |

**尺寸:**
| 元素 | 尺寸 |
|------|------|
| 图标 | 24px |
| 点击区域 | 44x44px |
| 数字间距 | 4px |
| 数字字号 | 13px |

### 1.5 动画规范

**Scale 动画:**
```
时间轴: 0ms    50ms    150ms   250ms   300ms
         │      │       │       │       │
Scale:  1.0 → 0.85 →  1.3  →  1.1  →  1.0
         按下    弹起    回弹    稳定
```

**曲线:**
- 按下: `Curves.easeOut` (50ms)
- 弹起: `Curves.elasticOut` (200ms, period: 0.4)

**粒子效果 (可选增强):**
```
触发时机: 点击时
粒子数: 8-12个
形状: 圆形/爱心
颜色: [#2D968A, #FFB800]
扩散半径: 30px
时长: 400ms
```

### 1.6 代码实现参考

```dart
class LikeButton extends StatefulWidget {
  final int count;
  final bool isLiked;
  final VoidCallback? onTap;
  final double size;
  final bool showCount;

  const LikeButton({
    Key? key,
    required this.count,
    required this.isLiked,
    this.onTap,
    this.size = 24,
    this.showCount = true,
  }) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.3)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 2,
      ),
    ]).animate(_controller);
  }

  void _handleTap() {
    if (widget.onTap != null) {
      widget.onTap!();
    }
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = widget.isLiked
        ? const Color(0xFF2D968A)
        : const Color(0xFF9CA3AF);

    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        child: AnimatedBuilder(
          animation: _scaleAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.isLiked
                        ? Icons.thumb_up
                        : Icons.thumb_up_outlined,
                    color: iconColor,
                    size: widget.size,
                  ),
                  if (widget.showCount && widget.count > 0) ...[
                    const SizedBox(width: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder: (child, animation) {
                        return FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween<Offset>(
                              begin: const Offset(0, -0.5),
                              end: Offset.zero,
                            ).animate(animation),
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        _formatCount(widget.count),
                        key: ValueKey(widget.count),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: widget.isLiked
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  String _formatCount(int count) {
    if (count < 1000) return count.toString();
    if (count < 10000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '${(count / 10000).floor()}w+';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

---

## 2. CommentItem 评论项组件

### 2.1 组件概览

展示单条评论的完整信息，包括用户头像、昵称、评分、内容、图片和互动按钮。

### 2.2 设计稿

```
┌─────────────────────────────────────────────┐
│ 16px padding                                │
│ ┌────┐  山野行者          [👍 23]           │
│ │ 😊 │   ⭐⭐⭐⭐⭐ 4.8                       │
│ └────┘                                      │
│                                             │
│         [风景] [路况] [适合亲子]              │
│                                             │
│         风景真的很棒，全程石板路很好走       │
│         适合带小朋友一起。                   │
│         龙井村的茶叶特别香！                 │
│                                             │
│         ┌────────┐ ┌────────┐              │
│         │  图片1 │ │  图片2 │              │
│         └────────┘ └────────┘              │
│                                             │
│         2024-03-15  ·  回复                 │
│                                             │
│ ┌─────────────────────────────────────┐    │
│ │ 回复区域 (可选)                      │    │
│ │ ...                                  │    │
│ └─────────────────────────────────────┘    │
└─────────────────────────────────────────────┘
```

### 2.3 属性定义

| 属性 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| comment | Comment | 是 | - | 评论数据模型 |
| onLike | Function(String)? | 否 | null | 点赞回调(传入评论ID) |
| onReply | Function(String)? | 否 | null | 回复回调(传入评论ID) |
| onImageTap | Function(int)? | 否 | null | 图片点击(传入索引) |
| maxLines | int | 否 | 5 | 内容最大行数 |
| showReply | bool | 否 | true | 是否显示回复区域 |

### 2.4 视觉规范

**布局间距:**
| 元素 | 尺寸/间距 |
|------|-----------|
| 卡片内边距 | 16px |
| 卡片圆角 | 12px |
| 头像尺寸 | 40px |
| 头像右边距 | 12px |
| 内容左对齐 | 52px (40+12) |
| 内容上边距 | 12px |

**文字样式:**
| 元素 | 字号 | 字重 | 颜色 |
|------|------|------|------|
| 用户名 | 15px | 500 | #374151 |
| 评分星星 | 12px | - | #FFB800 |
| 评分分数 | 13px | 600 | #FFB800 |
| 评论内容 | 15px | 400 | #4B5563 |
| 展开按钮 | 14px | 400 | #2D968A |
| 时间 | 12px | 400 | #9CA3AF |
| 回复按钮 | 12px | 500 | #6B7280 |

**图片规格:**
| 属性 | 数值 |
|------|------|
| 高度 | 120px |
| 宽度 | auto (最大200px) |
| 圆角 | 8px |
| 间距 | 8px |

### 2.5 展开/收起交互

**状态切换:**
```
收起状态 (5行以上):
"风景真的很棒，全程石板路很好走
适合带小朋友一起。龙井村的茶...
                         [展开]"

点击展开:
"风景真的很棒，全程石板路很好走
适合带小朋友一起。龙井村的茶叶
特别香！十里琅珰的视野开阔。
                         [收起]"
```

**动画:**
- 时长: 200ms
- 曲线: Curves.easeInOut
- 高度: 从 maxLines * lineHeight 到自然高度

### 2.6 代码实现参考

```dart
class CommentItem extends StatefulWidget {
  final Comment comment;
  final Function(String)? onLike;
  final Function(String)? onReply;
  final Function(int)? onImageTap;
  final int maxLines;
  final bool showReply;

  const CommentItem({
    Key? key,
    required this.comment,
    this.onLike,
    this.onReply,
    this.onImageTap,
    this.maxLines = 5,
    this.showReply = true,
  }) : super(key: key);

  @override
  State<CommentItem> createState() => _CommentItemState();
}

class _CommentItemState extends State<CommentItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 用户信息和点赞按钮
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvatar(),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildUserName(),
                    const SizedBox(height: 4),
                    _buildRating(),
                  ],
                ),
              ),
              LikeButton(
                count: widget.comment.likeCount,
                isLiked: widget.comment.isLiked,
                onTap: () => widget.onLike?.call(widget.comment.id),
              ),
            ],
          ),
          
          // 标签
          if (widget.comment.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildTags(),
          ],
          
          // 内容
          const SizedBox(height: 12),
          _buildContent(),
          
          // 图片
          if (widget.comment.images.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildImages(),
          ],
          
          // 时间和回复按钮
          const SizedBox(height: 12),
          _buildFooter(),
          
          // 回复列表
          if (widget.showReply &&
              widget.comment.replies.isNotEmpty) ...[
            const SizedBox(height: 12),
            ReplyList(replies: widget.comment.replies),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return ClipOval(
      child: CachedNetworkImage(
        imageUrl: widget.comment.user.avatarUrl,
        width: 40,
        height: 40,
        placeholder: (_, __) => Container(
          color: const Color(0xFFE5E7EB),
          child: const Icon(Icons.person, color: Color(0xFF9CA3AF)),
        ),
        errorWidget: (_, __, ___) => Container(
          color: const Color(0xFFE5E7EB),
          child: const Icon(Icons.person, color: Color(0xFF9CA3AF)),
        ),
      ),
    );
  }

  Widget _buildUserName() {
    return Text(
      widget.comment.user.name,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: Color(0xFF374151),
      ),
    );
  }

  Widget _buildRating() {
    return Row(
      children: [
        ...List.generate(5, (i) {
          final rating = widget.comment.rating;
          return Icon(
            i < rating.floor()
                ? Icons.star
                : i < rating
                    ? Icons.star_half
                    : Icons.star_border,
            color: const Color(0xFFFFB800),
            size: 12,
          );
        }),
        const SizedBox(width: 8),
        Text(
          widget.comment.rating.toString(),
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFFFFB800),
          ),
        ),
      ],
    );
  }

  Widget _buildTags() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.comment.tags.map((tag) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            tag,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1D756B),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final text = widget.comment.content;
        final textSpan = TextSpan(
          text: text,
          style: const TextStyle(
            fontSize: 15,
            height: 1.6,
            color: Color(0xFF4B5563),
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          maxLines: widget.maxLines,
          textDirection: TextDirection.ltr,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
        
        final isOverflow = textPainter.didExceedMaxLines;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedCrossFade(
              firstChild: Text(
                text,
                maxLines: widget.maxLines,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF4B5563),
                ),
              ),
              secondChild: Text(
                text,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.6,
                  color: Color(0xFF4B5563),
                ),
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
            if (isOverflow) ...[
              const SizedBox(height: 4),
              GestureDetector(
                onTap: () => setState(() => _isExpanded = !_isExpanded),
                child: Text(
                  _isExpanded ? '收起' : '展开',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF2D968A),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _buildImages() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: widget.comment.images.asMap().entries.map((entry) {
          return GestureDetector(
            onTap: () => widget.onImageTap?.call(entry.key),
            child: Container(
              width: 120,
              height: 120,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: const Color(0xFFE5E7EB),
              ),
              clipBehavior: Clip.hardEdge,
              child: CachedNetworkImage(
                imageUrl: entry.value,
                fit: BoxFit.cover,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, __) => const ShimmerPlaceholder(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        Text(
          _formatDate(widget.comment.createdAt),
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(width: 8),
        const Text(
          '·',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF9CA3AF),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => widget.onReply?.call(widget.comment.id),
          child: const Text(
            '回复',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays == 0) {
      if (diff.inHours == 0) {
        return '${diff.inMinutes}分钟前';
      }
      return '${diff.inHours}小时前';
    } else if (diff.inDays == 1) {
      return '昨天';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}天前';
    } else if (diff.inDays < 30) {
      return '${(diff.inDays / 7).floor()}周前';
    } else {
      return '${date.month}-${date.day}';
    }
  }
}
```

---

## 3. CommentSkeleton 评论骨架屏

### 3.1 组件概览

评论加载时的占位效果，使用 shimmer 动画提升等待体验。

### 3.2 设计稿

```
┌─────────────────────────────────────────────┐
│                                             │
│  ◯  ████████████                   ▓▓▓▓    │
│     ▓▓▓▓▓▓▓▓▓▓▓▓                            │
│                                             │
│     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓    │
│     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓           │
│     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓                        │
│                                             │
│     ┌────────┐ ┌────────┐                  │
│     │▓▓▓▓▓▓▓▓│ │▓▓▓▓▓▓▓▓│                  │
│     └────────┘ └────────┘                  │
│                                             │
│     ▓▓▓▓▓▓▓▓▓▓▓▓▓▓   ▓▓▓▓▓▓              │
│                                             │
└─────────────────────────────────────────────┘

◯ = 圆形占位 (头像)
█ = 灰色块
▓ = shimmer 流光效果
```

### 3.3 实现参考

```dart
class CommentSkeleton extends StatelessWidget {
  final int itemCount;

  const CommentSkeleton({
    Key? key,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE5E7EB),
      highlightColor: const Color(0xFFF3F4F6),
      period: const Duration(milliseconds: 1500),
      child: Column(
        children: List.generate(itemCount, (_) => _buildSkeletonItem()),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像和用户名
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120,
                      height: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 80,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 40,
                height: 24,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // 内容行
          ...List.generate(3, (index) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: index == 2 ? 200 : double.infinity,
              height: 14,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
          const SizedBox(height: 12),
          // 图片占位
          Row(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

---

## 4. PhotoViewer 图片查看器

### 4.1 组件概览

全屏图片查看器，支持缩放、滑动切换、手势操作。

### 4.2 设计稿

```
┌─────────────────────────────────────────────┐
│ ←                           ⋮    ↗    │ 黑 │
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│         ┌─────────────────────────┐         │
│         │                         │         │
│         │       图片展示区        │         │
│         │       (可缩放)          │         │
│         │                         │         │
│         └─────────────────────────┘         │
│                                             │
│                                             │
├─────────────────────────────────────────────┤
│ 山野行者                          👍 128 💬 16│
│ 2024-03-15 上传                             │
└─────────────────────────────────────────────┘
```

### 4.3 属性定义

| 属性 | 类型 | 必填 | 默认值 | 说明 |
|------|------|------|--------|------|
| imageUrls | List<String> | 是 | - | 图片URL列表 |
| initialIndex | int | 否 | 0 | 初始显示索引 |
| onClose | VoidCallback? | 否 | null | 关闭回调 |
| heroTag | String? | 否 | null | Hero动画标签 |

### 4.4 手势规范

| 手势 | 功能 | 说明 |
|------|------|------|
| 单击 | 切换UI显示 | 隐藏/显示顶部和底部栏 |
| 双击 | 放大/还原 | 2x 缩放 |
| 捏合 | 自由缩放 | 范围 1x-3x |
| 左右滑动 | 切换图片 | 带动画过渡 |
| 下滑 | 退出查看器 | 当缩放为1x时 |

### 4.5 代码实现参考

```dart
class PhotoViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final VoidCallback? onClose;
  final String? heroTag;

  const PhotoViewer({
    Key? key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.onClose,
    this.heroTag,
  }) : super(key: key);

  @override
  State<PhotoViewer> createState() => _PhotoViewerState();
}

class _PhotoViewerState extends State<PhotoViewer> {
  late PageController _pageController;
  late int _currentIndex;
  bool _isUIVisible = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  void _toggleUI() {
    setState(() => _isUIVisible = !_isUIVisible);
  }

  void _close() {
    if (widget.onClose != null) {
      widget.onClose!();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 图片页面
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return PhotoView(
                imageProvider: NetworkImage(widget.imageUrls[index]),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                initialScale: PhotoViewComputedScale.contained,
                onTapUp: (_, __, ___) => _toggleUI(),
                heroAttributes: widget.heroTag != null
                    ? PhotoViewHeroAttributes(tag: widget.heroTag!)
                    : null,
              );
            },
          ),
          
          // 顶部导航栏
          AnimatedOpacity(
            opacity: _isUIVisible ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top,
              ),
              color: Colors.black.withOpacity(0.5),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: _close,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onPressed: () {
                      // 显示更多菜单
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.fullscreen, color: Colors.white),
                    onPressed: () {
                      // 全屏切换
                    },
                  ),
                ],
              ),
            ),
          ),
          
          // 底部信息栏
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _isUIVisible ? 0 : -100,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
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
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_currentIndex + 1} / ${widget.imageUrls.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.chat_bubble_outline,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.share,
                            color: Colors.white,
                          ),
                          onPressed: () {},
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
    );
  }
}
```

---

## 5. EmptyState 空状态组件

### 5.1 组件概览

数据为空时的占位界面，提供友好的引导和操作入口。

### 5.2 预设类型

| 类型 | 图标 | 标题 | 副标题 | 按钮 |
|------|------|------|--------|------|
| 无评论 | Icons.chat_bubble_outline | "还没有评论" | "成为第一个评论的人吧" | "发表评论" |
| 无照片 | Icons.photo_library_outlined | "还没有照片" | "去徒步，记录美好瞬间" | "去 upload" |
| 无收藏 | Icons.bookmark_border | "还没有收藏" | "看到喜欢的内容就收藏吧" | "去发现" |
| 无网络 | Icons.wifi_off | "网络开小差了" | "请检查网络后重试" | "重试" |
| 无结果 | Icons.search_off | "没有找到结果" | "换个关键词试试" | "清除筛选" |

### 5.3 代码实现

```dart
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const EmptyState({
    Key? key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionText,
    this.onAction,
  }) : super(key: key);

  // 预设工厂方法
  factory EmptyState.noComments({VoidCallback? onAction}) => EmptyState(
    icon: Icons.chat_bubble_outline,
    title: '还没有评论',
    subtitle: '成为第一个评论的人吧',
    actionText: '发表评论',
    onAction: onAction,
  );

  factory EmptyState.noPhotos({VoidCallback? onAction}) => EmptyState(
    icon: Icons.photo_library_outlined,
    title: '还没有照片',
    subtitle: '去徒步，记录美好瞬间',
    actionText: '去 upload',
    onAction: onAction,
  );

  factory EmptyState.noNetwork({VoidCallback? onRetry}) => EmptyState(
    icon: Icons.wifi_off,
    title: '网络开小差了',
    subtitle: '请检查网络后重试',
    actionText: '重试',
    onAction: onRetry,
  );

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(60),
              ),
              child: Icon(
                icon,
                size: 48,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF9CA3AF),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2D968A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(actionText!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

## 6. 组件使用示例

### 评论列表完整实现

```dart
class CommentList extends StatefulWidget {
  final String trailId;

  const CommentList({Key? key, required this.trailId}) : super(key: key);

  @override
  State<CommentList> createState() => _CommentListState();
}

class _CommentListState extends State<CommentList> {
  List<Comment> _comments = [];
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await CommentService.getComments(widget.trailId);
      setState(() {
        _comments = comments;
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const CommentSkeleton(itemCount: 3);
    }

    if (_hasError) {
      return EmptyState.noNetwork(onRetry: _loadComments);
    }

    if (_comments.isEmpty) {
      return EmptyState.noComments(
        onAction: () => _showCommentInput(),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadComments,
      color: const Color(0xFF2D968A),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _comments.length,
        itemBuilder: (context, index) {
          return CommentItem(
            comment: _comments[index],
            onLike: (id) => _handleLike(id),
            onReply: (id) => _handleReply(id),
            onImageTap: (imageIndex) => _showPhotoViewer(
              _comments[index].images,
              imageIndex,
            ),
          );
        },
      ),
    );
  }

  void _showPhotoViewer(List<String> images, int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PhotoViewer(
          imageUrls: images,
          initialIndex: initialIndex,
        ),
      ),
    );
  }

  void _showCommentInput() {
    // 显示评论输入框
  }

  void _handleLike(String id) {
    // 处理点赞
  }

  void _handleReply(String id) {
    // 处理回复
  }
}
```

---

## 7. 依赖包推荐

```yaml
dependencies:
  # 图片加载与缓存
  cached_network_image: ^3.3.0
  
  # 图片查看器
  photo_view: ^0.14.0
  
  # 骨架屏 shimmer
  shimmer: ^3.0.0
  
  # 下拉刷新
  pull_to_refresh: ^2.0.0
  
  # 时间格式化
  timeago: ^3.5.0
```

---

**文档完成**: 2026-03-20  
**版本**: v1.0
