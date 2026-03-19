# 山径APP - 动画设计规范 v1.0

> **文档版本**: v1.0  
> **制定日期**: 2026-03-19  
> **文档状态**: M4 阶段 - P1  
> **适用范围**: 山径APP全功能交互动画  
> **基于**: 设计系统 v1.0, M3 动效基础

---

## 目录

1. [设计概述](#1-设计概述)
2. [动画原则](#2-动画原则)
3. [页面转场动画](#3-页面转场动画)
4. [交互动画规范](#4-交互动画规范)
5. [加载动画规范](#5-加载动画规范)
6. [微交互动画](#6-微交互动画)
7. [技术实现](#7-技术实现)
8. [性能规范](#8-性能规范)
9. [设计Token](#9-设计token)
10. [验收标准](#10-验收标准)

---

## 1. 设计概述

### 1.1 设计目标

建立一套自然、流畅、有品牌特色的动画系统：

| 目标 | 说明 | 关键指标 |
|------|------|----------|
| **自然流畅** | 动画符合物理规律，不生硬 | 使用自然缓动曲线 |
| **反馈明确** | 用户操作有即时视觉反馈 | 响应时间 < 100ms |
| **品牌传达** | 体现山径自然、诗意的品牌调性 | 柔和、有机的运动 |
| **性能优良** | 不影响应用性能 | 60fps 流畅运行 |

### 1.2 设计理念

**"山径流动"** - 动画如山间流水般自然：

- **流动性** - 动画过渡如溪水般流畅
- **有机性** - 运动轨迹如自然生长般有机
- **节奏感** - 动画节奏如行走步伐般有规律
- **呼吸感** - 动画有张有弛，留有呼吸空间

### 1.3 动画分类

| 类别 | 说明 | 优先级 | 使用场景 |
|------|------|--------|----------|
| **页面转场** | 页面间的过渡动画 | P0 | 页面切换 |
| **交互动画** | 用户操作的反馈动画 | P0 | 点击、滑动 |
| **加载动画** | 等待状态的动画 | P0 | 加载中 |
| **微交互** | 细微的状态变化动画 | P1 | 开关、收藏 |
| **装饰动画** | 氛围营造动画 | P2 | 背景、装饰 |

---

## 2. 动画原则

### 2.1 物理原则

#### 缓动函数 (Easing)

| 缓动名称 | 曲线 | 用途 | 示例 |
|----------|------|------|------|
| **ease-out** | 快开始慢结束 | 元素进入 | 页面进入、弹窗出现 |
| **ease-in** | 慢开始快结束 | 元素退出 | 页面退出、弹窗关闭 |
| **ease-in-out** | 慢快慢 | 状态切换 | 开关切换、tab切换 |
| **spring** | 弹性 | 活泼交互 | 收藏按钮、成功提示 |
| **linear** | 匀速 | 持续动画 | 加载旋转、进度条 |

#### 缓动曲线值

```dart
// Flutter 缓动曲线定义
class AnimationCurves {
  // 标准缓动
  static const standard = Curves.easeInOut;
  static const enter = Curves.easeOut;
  static const exit = Curves.easeIn;
  
  // 弹性缓动
  static const spring = Curves.elasticOut;
  static const bouncy = Curves.bounceOut;
  
  // 自定义品牌缓动 - "山径曲线"
  static const mountain = Cubic(0.4, 0.0, 0.2, 1);
  static const path = Cubic(0.25, 0.46, 0.45, 0.94);
}
```

### 2.2 时间原则

#### 动画时长

| 动画类型 | 时长 | 说明 |
|----------|------|------|
| **微交互** | 100-200ms | 开关、按钮反馈 |
| **标准交互** | 200-300ms | 弹窗、浮层 |
| **页面转场** | 300-400ms | 页面切换 |
| **复杂动画** | 400-600ms | 引导、展示 |
| **持续动画** | 1000-3000ms | 加载、循环 |

#### 时长规范

```dart
class AnimationDurations {
  // 微交互
  static const Duration micro = Duration(milliseconds: 100);
  static const Duration quick = Duration(milliseconds: 150);
  
  // 标准交互
  static const Duration normal = Duration(milliseconds: 200);
  static const Duration standard = Duration(milliseconds: 300);
  
  // 页面转场
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration modalTransition = Duration(milliseconds: 250);
  
  // 复杂动画
  static const Duration complex = Duration(milliseconds: 400);
  static const Duration elaborate = Duration(milliseconds: 600);
  
  // 持续动画
  static const Duration loading = Duration(milliseconds: 1500);
  static const Duration loop = Duration(milliseconds: 2000);
}
```

### 2.3 空间原则

#### 运动方向

| 方向 | 含义 | 使用场景 |
|------|------|----------|
| **从左到右** | 前进、进入 | 页面进入、下一步 |
| **从右到左** | 后退、退出 | 页面退出、返回 |
| **从下到上** | 展开、出现 | 弹窗、底部面板 |
| **从上到下** | 收起、消失 | 关闭、收起 |
| **中心扩散** | 强调、聚焦 | 点击效果、提示 |
| **边缘进入** | 通知、提示 | Snackbar、Toast |

#### 运动幅度

| 元素 | 建议幅度 | 说明 |
|------|----------|------|
| **页面** | 屏幕宽度的 100% | 完整切换 |
| **弹窗** | 从目标位置 ±20-40px | 微妙提醒 |
| **按钮** | 缩放 0.95-1.05 | 轻微反馈 |
| **图标** | 旋转 0-360° | 加载、状态 |

---

## 3. 页面转场动画

### 3.1 标准页面转场

#### iOS 风格转场

```dart
// Flutter 页面转场 - iOS风格
class CupertinoPageTransition extends PageRouteBuilder {
  final Widget child;
  
  CupertinoPageTransition({required this.child})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);  // 从右进入
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          
          var tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: curve));
          
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: Duration(milliseconds: 300),
      );
}
```

#### 转场参数

| 参数 | 值 | 说明 |
|------|-----|------|
| **方向** | 水平滑动 | 新页面从右进入 |
| **时长** | 300ms | 标准时长 |
| **缓动** | ease-in-out | 自然流畅 |
| **阴影** | 进入页面左侧阴影 | 增加层次感 |

### 3.2 特殊页面转场

#### 底部弹窗转场

```
底部弹窗进入动画:

初始状态:                    结束状态:
┌─────────────────┐         ┌─────────────────┐
│                 │         │  遮罩(50%黑)    │
│   当前页面      │   →     ├─────────────────┤
│                 │         │                 │
│                 │         │   弹窗内容      │
│                 │         │   圆角顶部      │
└─────────────────┘         │                 │
                            └─────────────────┘

动画参数:
- 遮罩: opacity 0 → 0.5, 时长 200ms
- 弹窗: translateY(100%) → translateY(0), 时长 300ms, ease-out
```

#### 全屏图片转场 (Hero 动画)

```dart
// Flutter Hero 动画
Hero(
  tag: 'trail_image_${trail.id}',
  child: Image.network(trail.imageUrl),
  flightShuttleBuilder: (context, animation, direction, 
                         fromContext, toContext) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRRect(
          borderRadius: BorderRadius.lerp(
            BorderRadius.circular(12),  // 列表圆角
            BorderRadius.zero,          // 全屏无圆角
            animation.value,
          ),
          child: child,
        );
      },
      child: Image.network(trail.imageUrl),
    );
  },
)
```

### 3.3 页面转场对照表

| 场景 | 转场类型 | 方向 | 时长 | 说明 |
|------|----------|------|------|------|
| **列表→详情** | Hero + 滑动 | 右进 | 400ms | 图片共享元素动画 |
| **首页→二级** | 滑动 | 右进 | 300ms | 标准转场 |
| **返回上一级** | 滑动 | 左出 | 300ms | 标准返回 |
| **弹出设置** | 底部滑入 | 上滑 | 300ms | 底部面板 |
| **弹出模态** | 淡入 + 缩放 | 中心 | 250ms | 居中弹窗 |
| **启动页→首页** | 淡入 | 无 | 500ms | 品牌过渡 |

---

## 4. 交互动画规范

### 4.1 按钮交互动画

#### 主按钮动画

```dart
// 按钮按下动画
class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onPressed;
  
  @override
  _AnimatedButtonState createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95)
      .animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: widget.child,
      ),
    );
  }
}
```

#### 按钮动画参数

| 状态 | 缩放 | 时长 | 缓动 |
|------|------|------|------|
| **按下 (Tap Down)** | 0.95 | 100ms | ease-out |
| **释放 (Tap Up)** | 1.0 | 150ms | spring |
| **禁用** | 1.0 | 即时 | - |

### 4.2 列表项动画

#### 列表进入动画

```dart
// 列表项 stagger 动画
class AnimatedListItem extends StatelessWidget {
  final Widget child;
  final int index;
  
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

// 使用 stagger
ListView.builder(
  itemBuilder: (context, index) {
    return FutureBuilder(
      future: Future.delayed(Duration(milliseconds: index * 50)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AnimatedListItem(
            index: index,
            child: ListTile(...),
          );
        }
        return SizedBox.shrink();
      },
    );
  },
)
```

#### 列表动画参数

| 参数 | 值 | 说明 |
|------|-----|------|
| **进入延迟** | index × 50ms | 逐项延迟 |
| **位移距离** | 20px | 从下方滑入 |
| **透明度** | 0 → 1 | 淡入效果 |
| **最大同时动画** | 5项 | 性能考虑 |

### 4.3 收藏/点赞动画

#### 心形收藏动画

```dart
class FavoriteButton extends StatefulWidget {
  final bool isFavorite;
  final VoidCallback onTap;
  
  @override
  _FavoriteButtonState createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> 
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.3), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 1.3, end: 0.9), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.9, end: 1.0), weight: 50),
    ]).animate(_controller);
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!widget.isFavorite) {
          _controller.forward(from: 0);
        }
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: Icon(
            widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: widget.isFavorite ? Colors.red : Colors.grey,
            size: 24,
          ),
        ),
      ),
    );
  }
}
```

#### 收藏动画参数

| 阶段 | 缩放 | 时长占比 | 效果 |
|------|------|----------|------|
| **放大** | 1.0 → 1.3 | 30% | 强调 |
| **回弹** | 1.3 → 0.9 | 20% | 弹性 |
| **恢复** | 0.9 → 1.0 | 50% | 稳定 |

---

## 5. 加载动画规范

### 5.1 页面加载动画

#### 骨架屏动画

```dart
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      period: Duration(milliseconds: 1500),
      child: child,
    );
  }
}

// 骨架屏卡片
class SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 图片占位
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          SizedBox(height: 12),
          // 标题占位
          Container(
            width: 150,
            height: 16,
            color: Colors.white,
          ),
          SizedBox(height: 8),
          // 描述占位
          Container(
            width: double.infinity,
            height: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
```

#### 骨架屏参数

| 参数 | 值 | 说明 |
|------|-----|------|
| **基础色** | Gray-200 | `#E5E7EB` |
| **高亮色** | Gray-100 | `#F3F4F6` |
| **动画周期** | 1500ms | 一次扫描时长 |
| **方向** | 从左到右 | 水平扫描 |

### 5.2 加载指示器

#### 品牌加载动画

```dart
class TrailLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  
  @override
  _TrailLoadingIndicatorState createState() => 
      _TrailLoadingIndicatorState();
}

class _TrailLoadingIndicatorState extends State<TrailLoadingIndicator> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size, widget.size),
          painter: TrailPainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

// 自定义绘制 - 山径路径加载
class TrailPainter extends CustomPainter {
  final double progress;
  final Color color;
  
  TrailPainter({required this.progress, required this.color});
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    // 绘制蜿蜒的路径
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.3, size.height * 0.5,
        size.width * 0.5, size.height * 0.6,
      )
      ..quadraticBezierTo(
        size.width * 0.7, size.height * 0.7,
        size.width * 0.8, size.height * 0.3,
      );
    
    // 绘制动画路径
    final pathMetric = path.computeMetrics().first;
    final drawPath = pathMetric.extractPath(
      0,
      pathMetric.length * progress,
    );
    
    canvas.drawPath(drawPath, paint);
  }
  
  @override
  bool shouldRepaint(covariant TrailPainter oldDelegate) => 
      oldDelegate.progress != progress;
}
```

#### 加载指示器参数

| 类型 | 尺寸 | 颜色 | 用途 |
|------|------|------|------|
| **页面加载** | 48px | Primary-500 | 全页加载 |
| **按钮加载** | 20px | White | 按钮内加载 |
| **下拉刷新** | 36px | Primary-500 | 刷新指示器 |
| **内联加载** | 16px | Gray-500 | 小区域加载 |

### 5.3 进度动画

#### 圆形进度条

```dart
class CircularProgress extends StatelessWidget {
  final double progress;  // 0.0 - 1.0
  final double size;
  final Color color;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: progress),
        duration: Duration(milliseconds: 500),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return CircularProgressIndicator(
            value: value,
            strokeWidth: 4,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            backgroundColor: Colors.grey[200],
          );
        },
      ),
    );
  }
}
```

---

## 6. 微交互动画

### 6.1 开关 (Switch)

```dart
// 自定义开关动画
class AnimatedSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        width: 50,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: value ? Color(0xFF2D968A) : Colors.grey[300],
        ),
        child: AnimatedAlign(
          duration: Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: EdgeInsets.all(2),
            child: Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

#### 开关动画参数

| 属性 | 关闭→开启 | 开启→关闭 | 时长 |
|------|-----------|-----------|------|
| **背景色** | Gray-300 → Primary-500 | Primary-500 → Gray-300 | 200ms |
| **滑块位置** | 左 → 右 | 右 → 左 | 200ms |
| **缓动** | ease-in-out | ease-in-out | - |

### 6.2 输入框焦点动画

```dart
class AnimatedInputBorder extends StatelessWidget {
  final bool isFocused;
  final Widget child;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? Color(0xFF2D968A) : Colors.grey[300]!,
          width: isFocused ? 2 : 1,
        ),
        boxShadow: isFocused ? [
          BoxShadow(
            color: Color(0xFF2D968A).withOpacity(0.15),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ] : [],
      ),
      child: child,
    );
  }
}
```

### 6.3 Toast/Snackbar 动画

```dart
// Toast 进入退出动画
class AnimatedToast extends StatelessWidget {
  final String message;
  final bool isVisible;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
      bottom: isVisible ? 100 : -100,
      left: 16,
      right: 16,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 200),
        opacity: isVisible ? 1.0 : 0.0,
        child: Material(
          elevation: 4,
          borderRadius: BorderRadius.circular(8),
          color: Colors.black87,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            child: Text(
              message,
              style: TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 7. 技术实现

### 7.1 Flutter 动画库

#### 推荐库

| 库名 | 用途 | 版本 |
|------|------|------|
| **flutter_animate** | 声明式动画 | ^4.0.0 |
| **lottie** | Lottie动画 | ^2.0.0 |
| **shimmer** | 骨架屏 | ^3.0.0 |
| **rive** | Rive动画 | ^0.12.0 |

#### 使用示例

```dart
// flutter_animate 使用
Container()
  .animate()
  .fadeIn(duration: 300.ms)
  .slideY(begin: 0.2, end: 0)
  .scale(begin: Offset(0.9, 0.9), end: Offset(1, 1))
  .then()
  .shake(duration: 200.ms);

// Lottie 使用
Lottie.asset(
  'assets/animations/loading.json',
  width: 100,
  height: 100,
  repeat: true,
);
```

### 7.2 动画工具类

```dart
// lib/utils/animations.dart

class AppAnimations {
  // 页面转场
  static Route<T> fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: Duration(milliseconds: 300),
    );
  }
  
  // 缩放弹窗
  static Route<T> scaleRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var curve = Curves.easeOut;
        var curveTween = CurveTween(curve: curve);
        var scaleAnimation = Tween<double>(
          begin: 0.9,
          end: 1.0,
        ).chain(curveTween).animate(animation);
        var fadeAnimation = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).chain(curveTween).animate(animation);
        
        return FadeTransition(
          opacity: fadeAnimation,
          child: ScaleTransition(
            scale: scaleAnimation,
            child: child,
          ),
        );
      },
      transitionDuration: Duration(milliseconds: 250),
    );
  }
  
  // Stagger 动画
  static List<Widget> staggeredList(
    List<Widget> children, {
    Duration delay = const Duration(milliseconds: 50),
  }) {
    return children.asMap().entries.map((entry) {
      return entry.value
        .animate(delay: delay * entry.key)
        .fadeIn()
        .slideY(begin: 0.2, end: 0);
    }).toList();
  }
}
```

---

## 8. 性能规范

### 8.1 性能原则

| 原则 | 说明 | 实现方式 |
|------|------|----------|
| **60fps** | 保持流畅帧率 | 使用 GPU 加速属性 |
| **避免布局** | 动画不触发布局 | 仅使用 transform/opacity |
| **控制数量** | 同时动画元素有限 | 最多 5-7 个同时动画 |
| **按需加载** | 动画资源懒加载 | 延迟加载 Lottie/图片 |
| **及时清理** | 动画结束后释放资源 | dispose() 控制器 |

### 8.2 低端设备适配 (风险缓解方案)

#### 问题识别
部分低端设备（Android 8.0 以下、2GB 内存以下）在复杂动画下会出现卡顿。

#### 解决方案

1. **自动降级策略**
```dart
// lib/utils/animation_helper.dart

import 'package:device_info_plus/device_info_plus.dart';

class AnimationHelper {
  static bool? _shouldReduceMotion;
  
  /// 检测是否需要减少动画
  static Future<bool> shouldReduceMotion() async {
    if (_shouldReduceMotion != null) return _shouldReduceMotion!;
    
    // 1. 检查系统设置 (用户偏好减少动画)
    final prefs = await SharedPreferences.getInstance();
    final userPref = prefs.getBool('reduce_motion');
    if (userPref == true) {
      _shouldReduceMotion = true;
      return true;
    }
    
    // 2. 检测低端设备
    final deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      // API < 26 或 内存 < 2GB
      if (androidInfo.version.sdkInt < 26) {
        _shouldReduceMotion = true;
        return true;
      }
    }
    
    // 3. 检查屏幕刷新率 (Flutter 3.0+)
    // 如果设备不支持高刷，减少动画复杂度
    
    _shouldReduceMotion = false;
    return false;
  }
  
  /// 获取动画时长 (根据设备性能调整)
  static Duration getDuration(Duration normal) {
    if (_shouldReduceMotion == true) {
      return Duration(milliseconds: (normal.inMilliseconds * 0.5).round());
    }
    return normal;
  }
  
  /// 是否禁用复杂动画
  static bool get disableComplexAnimations => _shouldReduceMotion == true;
}
```

2. **prefers-reduced-motion 适配**
```dart
// 监听系统无障碍设置
class ReducedMotionObserver extends StatefulWidget {
  final Widget child;
  
  @override
  _ReducedMotionObserverState createState() => _ReducedMotionObserverState();
}

class _ReducedMotionObserverState extends State<ReducedMotionObserver> 
    with WidgetsBindingObserver {
  bool _reduceMotion = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkReduceMotion();
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAccessibilityFeatures() {
    _checkReduceMotion();
  }
  
  void _checkReduceMotion() {
    final window = WidgetsBinding.instance.window;
    setState(() {
      _reduceMotion = window.accessibilityFeatures.disableAnimations;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimationLimiter(
      reduceMotion: _reduceMotion,
      child: widget.child,
    );
  }
}

/// 动画限制器
class AnimationLimiter extends InheritedWidget {
  final bool reduceMotion;
  
  const AnimationLimiter({
    Key? key,
    required this.reduceMotion,
    required Widget child,
  }) : super(key: key, child: child);
  
  static AnimationLimiter? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AnimationLimiter>();
  }
  
  @override
  bool updateShouldNotify(AnimationLimiter old) => 
      reduceMotion != old.reduceMotion;
}
```

3. **动画降级策略表**

| 动画类型 | 正常效果 | 降级效果 |
|----------|----------|----------|
| 页面转场 | 300ms 滑动 | 150ms 淡入 |
| 按钮反馈 | 缩放 0.95 | 透明度变化 |
| 列表进入 | stagger 动画 | 直接显示 |
| 骨架屏 | 流光动画 | 静态占位 |
| 加载动画 | 品牌动画 | 标准转圈 |
| 收藏动画 | 弹性缩放 | 颜色变化 |

4. **UI 开关**
```dart
// 设置页面提供手动开关
SwitchListTile(
  title: Text('减少动画'),
  subtitle: Text('提升低端设备性能'),
  value: reduceMotion,
  onChanged: (value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduce_motion', value);
    setState(() => reduceMotion = value);
  },
)
```

### 8.3 GPU 加速属性

优先使用以下属性（GPU 加速）：

| 属性 | 用途 | 性能 |
|------|------|------|
| **transform** | 位移、缩放、旋转 | ✅ GPU 加速 |
| **opacity** | 淡入淡出 | ✅ GPU 加速 |
| **filter** | 模糊效果 | ⚠️ 谨慎使用 |

避免以下属性（触发布局/重绘）：

| 属性 | 问题 | 替代方案 |
|------|------|----------|
| **width/height** | 触发布局 | scale transform |
| **top/left** | 触发布局 | translate transform |
| **padding/margin** | 触发布局 | 预先设置好 |
| **border-radius** | 触发重绘 | 使用 clipPath |

### 8.3 性能检查清单

- [ ] 使用 `RepaintBoundary` 隔离复杂动画
- [ ] 及时 `dispose()` 动画控制器
- [ ] 使用 `const` 构造函数减少重建
- [ ] 限制同时动画元素数量
- [ ] 在低端设备上测试性能
- [ ] 使用 DevTools 分析性能

---

## 9. 设计Token

### 9.1 动画Token

```json
{
  "animation": {
    "duration": {
      "micro": "100ms",
      "quick": "150ms",
      "normal": "200ms",
      "standard": "300ms",
      "complex": "400ms",
      "elaborate": "600ms"
    },
    "easing": {
      "standard": "cubic-bezier(0.4, 0.0, 0.2, 1)",
      "enter": "cubic-bezier(0.0, 0.0, 0.2, 1)",
      "exit": "cubic-bezier(0.4, 0.0, 1, 1)",
      "spring": "cubic-bezier(0.68, -0.55, 0.265, 1.55)",
      "mountain": "cubic-bezier(0.25, 0.46, 0.45, 0.94)"
    },
    "scale": {
      "pressed": "0.95",
      "hover": "1.02",
      "emphasis": "1.1",
      "pop": "1.3"
    },
    "translate": {
      "small": "4px",
      "medium": "8px",
      "large": "16px",
      "enter": "20px",
      "page": "100%"
    },
    "opacity": {
      "hidden": "0",
      "subtle": "0.5",
      "visible": "1"
    }
  }
}
```

### 9.2 使用示例

```dart
// 使用 Token 构建动画
AnimatedContainer(
  duration: AppTokens.animation.duration.standard,  // 300ms
  curve: AppTokens.animation.easing.standard,       // ease-in-out
  transform: Matrix4.identity()
    ..scale(isPressed ? AppTokens.animation.scale.pressed : 1.0),
  child: child,
);
```

---

## 10. 验收标准

### 10.1 功能验收

| 检查项 | 标准 | 检查方法 |
|--------|------|----------|
| **动画触发** | 按设计触发，无遗漏 | 逐页测试 |
| **动画流畅** | 60fps，无卡顿 | 性能测试 |
| **动画时长** | 符合规范 | 计时测试 |
| **缓动曲线** | 自然流畅 | 视觉检查 |

### 10.2 体验验收

| 检查项 | 标准 | 检查方法 |
|--------|------|----------|
| **反馈及时** | 操作后 100ms 内有反馈 | 手动测试 |
| **意图清晰** | 动画能传达操作意图 | 用户测试 |
| **不干扰** | 动画不干扰主要内容 | 视觉检查 |
| **一致性** | 同类动画表现一致 | 对比检查 |

### 10.3 性能验收

| 检查项 | 标准 | 检查方法 |
|--------|------|----------|
| **帧率** | ≥ 55fps | DevTools |
| **内存** | 无泄漏 | 内存监控 |
| **电量** | 不异常耗电 | 电量测试 |
| **低端设备** | 可接受性能 | 真机测试 |

---

## 附录

### A. 参考资源

- [Material Motion Guidelines](https://material.io/design/motion/understanding-motion.html)
- [Flutter Animations Documentation](https://flutter.dev/docs/development/ui/animations)
- [Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/ios/visual-design/animation/)

### B. 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | M4 阶段初版，完整动画规范 |

### C. 设计团队

- 动效设计: [待填写]
- 开发对接: [待填写]
- 性能优化: [待填写]

---

> **"如流水般自然，如呼吸般流畅"** - 山径APP动画设计哲学
