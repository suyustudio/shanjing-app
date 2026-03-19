import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'dart:math' as math;

/// 山径APP - 动画工具库
/// 包含动画降级、性能优化、品牌曲线等

/// 动画性能帮助类
class AnimationHelper {
  static bool? _shouldReduceMotion;
  static double? _deviceRefreshRate;
  
  /// 检测是否需要减少动画
  /// 
  /// 检查项:
  /// 1. 系统无障碍设置 (prefers-reduced-motion)
  /// 2. 设备性能检测 (< 30fps 自动降级)
  /// 3. 用户手动设置
  static Future<bool> shouldReduceMotion(BuildContext context) async {
    if (_shouldReduceMotion != null) return _shouldReduceMotion!;
    
    // 1. 检查系统无障碍设置
    final window = View.of(context);
    final accessibilityFeatures = window.platformDispatcher.accessibilityFeatures;
    if (accessibilityFeatures.disableAnimations) {
      _shouldReduceMotion = true;
      return true;
    }
    
    // 2. 检测屏幕刷新率
    final refreshRate = _getDeviceRefreshRate();
    if (refreshRate != null && refreshRate < 30) {
      _shouldReduceMotion = true;
      return true;
    }
    
    // 3. 检查用户偏好设置
    // TODO: 从 SharedPreferences 读取用户设置
    // final prefs = await SharedPreferences.getInstance();
    // if (prefs.getBool('reduce_motion') == true) {
    //   _shouldReduceMotion = true;
    //   return true;
    // }
    
    _shouldReduceMotion = false;
    return false;
  }
  
  /// 获取设备刷新率
  static double? _getDeviceRefreshRate() {
    try {
      return SchedulerBinding.instance.platformDispatcher.implicitView?.display?.refreshRate;
    } catch (e) {
      return null;
    }
  }
  
  /// 根据设备性能获取动画时长
  static Duration getDuration(Duration normal, {bool reduceMotion = false}) {
    if (reduceMotion) {
      // 减少动画模式：时长减半，更快完成
      return Duration(milliseconds: (normal.inMilliseconds * 0.5).round());
    }
    return normal;
  }
  
  /// 获取适当的缓动曲线
  static Curve getCurve(Curve normal, {bool reduceMotion = false}) {
    if (reduceMotion) {
      // 减少动画模式：使用线性曲线，减少计算
      return Curves.linear;
    }
    return normal;
  }
  
  /// 重置缓存（用于设置变更后）
  static void resetCache() {
    _shouldReduceMotion = null;
  }
}

/// 品牌动画曲线
/// "山径曲线" - 自然流畅的有机运动
class TrailCurves {
  /// 标准山径曲线 - 用于大部分动画
  /// 模拟自然行走的节奏感
  static const Cubic mountain = Cubic(0.25, 0.46, 0.45, 0.94);
  
  /// 路径曲线 - 用于页面转场
  /// 模拟沿山路行走的起承转合
  static const Cubic path = Cubic(0.4, 0.0, 0.2, 1);
  
  /// 弹性曲线 - 用于活泼交互
  /// 模拟弹簧的自然回弹
  static const Cubic spring = Cubic(0.68, -0.55, 0.265, 1.55);
  
  /// 流水曲线 - 用于连续动画
  /// 模拟溪水流动的连续性
  static const Cubic stream = Cubic(0.37, 0, 0.63, 1);
  
  /// 落叶曲线 - 用于退出动画
  /// 模拟叶子飘落的轻柔感
  static const Cubic leaf = Cubic(0.55, 0.085, 0.68, 0.53);
  
  /// 获取降级后的曲线
  static Curve getReducedCurve(Curve original) {
    // 复杂曲线降级为简单曲线以提高性能
    if (original is Cubic) {
      // 检查是否为复杂曲线（有超出0-1范围的值）
      final cubic = original;
      if (cubic.a < 0 || cubic.b < 0 || cubic.c < 0 || cubic.d < 0 ||
          cubic.a > 1 || cubic.b > 1 || cubic.c > 1 || cubic.d > 1) {
        return Curves.easeInOut; // 降级为简单曲线
      }
    }
    return original;
  }
}

/// 动画时长常量
class TrailDurations {
  /// 微交互 - 按钮点击、开关切换
  static const Duration micro = Duration(milliseconds: 100);
  
  /// 快速交互 - 小元素变化
  static const Duration quick = Duration(milliseconds: 150);
  
  /// 标准交互 - 弹窗、浮层
  static const Duration normal = Duration(milliseconds: 200);
  
  /// 标准转场 - 页面切换
  static const Duration standard = Duration(milliseconds: 300);
  
  /// 复杂动画 - 引导、展示
  static const Duration complex = Duration(milliseconds: 400);
  
  /// 精致动画 - 强调、特殊效果
  static const Duration elaborate = Duration(milliseconds: 600);
  
  /// 加载动画循环周期
  static const Duration loading = Duration(milliseconds: 1500);
  
  /// 空状态入场动画
  static const Duration emptyStateEnter = Duration(milliseconds: 600);
}

/// 智能动画构建器
/// 自动根据设备性能调整动画
class SmartAnimatedBuilder extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final Curve curve;
  final AnimatedWidgetBuilder builder;
  final VoidCallback? onEnd;

  const SmartAnimatedBuilder({
    Key? key,
    required this.child,
    required this.duration,
    this.curve = TrailCurves.mountain,
    required this.builder,
    this.onEnd,
  }) : super(key: key);

  @override
  State<SmartAnimatedBuilder> createState() => _SmartAnimatedBuilderState();
}

class _SmartAnimatedBuilderState extends State<SmartAnimatedBuilder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _reduceMotion = false;

  @override
  void initState() {
    super.initState();
    _initAnimation();
  }

  void _initAnimation() {
    _checkReduceMotion();
    
    final adjustedDuration = AnimationHelper.getDuration(
      widget.duration,
      reduceMotion: _reduceMotion,
    );
    
    _controller = AnimationController(
      duration: adjustedDuration,
      vsync: this,
    );
    
    final adjustedCurve = AnimationHelper.getCurve(
      widget.curve,
      reduceMotion: _reduceMotion,
    );
    
    _animation = CurvedAnimation(
      parent: _controller,
      curve: adjustedCurve,
    );
    
    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onEnd != null) {
        widget.onEnd!();
      }
    });
    
    _controller.forward();
  }

  Future<void> _checkReduceMotion() async {
    final shouldReduce = await AnimationHelper.shouldReduceMotion(context);
    if (mounted) {
      setState(() {
        _reduceMotion = shouldReduce;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: widget.builder,
      child: widget.child,
    );
  }
}

/// 性能优化的淡入动画组件
class OptimizedFadeIn extends StatelessWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double beginOpacity;

  const OptimizedFadeIn({
    Key? key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
    this.beginOpacity = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Opacity(opacity: beginOpacity, child: child);
        }
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: beginOpacity, end: 1.0),
          duration: duration,
          curve: TrailCurves.mountain,
          builder: (context, value, child) {
            return Opacity(opacity: value, child: child);
          },
          child: child,
        );
      },
    );
  }
}

/// 性能优化的位移动画组件
class OptimizedSlideIn extends StatelessWidget {
  final Widget child;
  final Offset beginOffset;
  final Duration delay;
  final Duration duration;

  const OptimizedSlideIn({
    Key? key,
    required this.child,
    this.beginOffset = const Offset(0, 20),
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 300),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Transform.translate(
            offset: beginOffset,
            child: Opacity(opacity: 0, child: child),
          );
        }
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: duration,
          curve: TrailCurves.path,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(
                beginOffset.dx * (1 - value),
                beginOffset.dy * (1 - value),
              ),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: child,
        );
      },
    );
  }
}

/// 动画限制器 - 用于控制子树动画
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

/// Stagger动画列表 - 性能优化版本
class OptimizedStaggeredList extends StatelessWidget {
  final List<Widget> children;
  final Duration itemDelay;
  final Duration duration;
  final Axis scrollDirection;
  final bool shrinkWrap;

  const OptimizedStaggeredList({
    Key? key,
    required this.children,
    this.itemDelay = const Duration(milliseconds: 50),
    this.duration = const Duration(milliseconds: 300),
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final limiter = AnimationLimiter.of(context);
    final reduceMotion = limiter?.reduceMotion ?? false;
    
    if (reduceMotion) {
      // 减少动画模式：直接显示，无stagger效果
      return ListView(
        scrollDirection: scrollDirection,
        shrinkWrap: shrinkWrap,
        physics: NeverScrollableScrollPhysics(),
        children: children,
      );
    }
    
    return ListView.builder(
      scrollDirection: scrollDirection,
      shrinkWrap: shrinkWrap,
      physics: NeverScrollableScrollPhysics(),
      itemCount: children.length,
      itemBuilder: (context, index) {
        // 最多同时动画5项，避免性能问题
        if (index > 5) {
          return children[index];
        }
        
        return OptimizedSlideIn(
          delay: itemDelay * index,
          duration: duration,
          child: children[index],
        );
      },
    );
  }
}

/// 脉冲动画 - 用于强调
class PulseAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;

  const PulseAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.minScale = 1.0,
    this.maxScale = 1.05,
  }) : super(key: key);

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _animation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: widget.minScale, end: widget.maxScale),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(begin: widget.maxScale, end: widget.minScale),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: TrailCurves.stream,
    ));
    
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// 呼吸动画 - 用于空状态插画
class BreathingAnimation extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const BreathingAnimation({
    Key? key,
    required this.child,
    this.duration = const Duration(milliseconds: 3000),
  }) : super(key: key);

  @override
  State<BreathingAnimation> createState() => _BreathingAnimationState();
}

class _BreathingAnimationState extends State<BreathingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // 呼吸效果：微妙的缩放 + 透明度变化
        final value = _controller.value;
        final scale = 1.0 + (0.02 * math.sin(value * 2 * math.pi));
        final opacity = 0.95 + (0.05 * math.sin(value * 2 * math.pi));
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
