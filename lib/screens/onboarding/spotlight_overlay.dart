import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

/// 高亮位置枚举
enum SpotlightPosition {
  top,
  center,
  bottom,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

/// 场景化高亮引导组件
/// 用于在首页等页面高亮特定功能区域
class SpotlightOverlay extends StatefulWidget {
  /// 目标 Widget 的 GlobalKey，用于定位高亮区域
  final GlobalKey? targetKey;

  /// 高亮区域的位置和大小（如果 targetKey 为 null）
  final Rect? targetRect;

  /// 引导说明文字
  final String description;

  /// 引导提示位置
  final SpotlightPosition position;

  /// 点击遮罩是否关闭
  final bool dismissOnTap;

  /// 点击"我知道了"回调
  final VoidCallback? onDismiss;

  /// 下一步回调（多步引导时使用）
  final VoidCallback? onNext;

  /// 是否显示"下一步"按钮
  final bool showNextButton;

  /// 下一步按钮文字
  final String nextButtonText;

  /// 遮罩颜色
  final Color maskColor;

  /// 高亮区域圆角
  final double highlightRadius;

  /// 高亮区域边距
  final EdgeInsets highlightPadding;

  /// 动画时长
  final Duration animationDuration;

  const SpotlightOverlay({
    super.key,
    this.targetKey,
    this.targetRect,
    required this.description,
    this.position = SpotlightPosition.bottom,
    this.dismissOnTap = false,
    this.onDismiss,
    this.onNext,
    this.showNextButton = true,
    this.nextButtonText = '我知道了',
    this.maskColor = Colors.black54,
    this.highlightRadius = 12,
    this.highlightPadding = const EdgeInsets.all(8),
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  State<SpotlightOverlay> createState() => _SpotlightOverlayState();
}

class _SpotlightOverlayState extends State<SpotlightOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  Rect? _targetRect;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _updateTargetRect();
    _controller.forward();
  }

  @override
  void didUpdateWidget(SpotlightOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetKey != widget.targetKey ||
        oldWidget.targetRect != widget.targetRect) {
      _updateTargetRect();
    }
  }

  void _updateTargetRect() {
    if (widget.targetRect != null) {
      _targetRect = widget.targetRect;
    } else if (widget.targetKey != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _calculateTargetRect();
      });
    }
  }

  void _calculateTargetRect() {
    final key = widget.targetKey;
    if (key == null) return;

    final context = key.currentContext;
    if (context == null) return;

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() {
      _targetRect = Rect.fromLTWH(
        position.dx - widget.highlightPadding.left,
        position.dy - widget.highlightPadding.top,
        size.width + widget.highlightPadding.horizontal,
        size.height + widget.highlightPadding.vertical,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    _controller.reverse().then((_) {
      widget.onDismiss?.call();
    });
  }

  void _handleNext() {
    if (widget.onNext != null) {
      _controller.reverse().then((_) {
        widget.onNext?.call();
      });
    } else {
      _handleDismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rect = _targetRect;

    return GestureDetector(
      onTap: widget.dismissOnTap ? _handleDismiss : null,
      behavior: HitTestBehavior.translucent,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: [
              // 遮罩层（带挖空）
              CustomPaint(
                size: size,
                painter: _SpotlightPainter(
                  targetRect: rect,
                  maskColor: widget.maskColor.withOpacity(
                    widget.maskColor.opacity * _fadeAnimation.value,
                  ),
                  highlightRadius: widget.highlightRadius,
                ),
              ),

              // 高亮区域的脉冲动画
              if (rect != null)
                Positioned.fromRect(
                  rect: rect,
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(widget.highlightRadius),
                        border: Border.all(
                          color: Theme.of(context).primaryColor.withOpacity(
                            0.5 * _fadeAnimation.value,
                          ),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ),

              // 引导提示卡片
              if (rect != null)
                Positioned(
                  left: _getCardLeft(rect, size.width),
                  top: _getCardTop(rect, size.height),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildGuideCard(context),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  double _getCardLeft(Rect rect, double screenWidth) {
    const cardWidth = 280.0;
    switch (widget.position) {
      case SpotlightPosition.topLeft:
      case SpotlightPosition.bottomLeft:
        return rect.left.clamp(16, screenWidth - cardWidth - 16);
      case SpotlightPosition.topRight:
      case SpotlightPosition.bottomRight:
        return (rect.right - cardWidth).clamp(16, screenWidth - cardWidth - 16);
      case SpotlightPosition.top:
      case SpotlightPosition.center:
      case SpotlightPosition.bottom:
      default:
        return ((rect.left + rect.right) / 2 - cardWidth / 2)
            .clamp(16, screenWidth - cardWidth - 16);
    }
  }

  double _getCardTop(Rect rect, double screenHeight) {
    const cardHeight = 150.0;
    switch (widget.position) {
      case SpotlightPosition.top:
      case SpotlightPosition.topLeft:
      case SpotlightPosition.topRight:
        return (rect.top - cardHeight - 16).clamp(16, screenHeight - cardHeight - 16);
      case SpotlightPosition.center:
        return ((rect.top + rect.bottom) / 2 - cardHeight / 2)
            .clamp(16, screenHeight - cardHeight - 16);
      case SpotlightPosition.bottom:
      case SpotlightPosition.bottomLeft:
      case SpotlightPosition.bottomRight:
      default:
        return (rect.bottom + 16).clamp(16, screenHeight - cardHeight - 16);
    }
  }

  Widget _buildGuideCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1F24) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.touch_app_outlined,
            size: 36,
            color: DesignSystem.primary,
          ),
          const SizedBox(height: 12),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF1A1A1A),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 120,
            height: 40,
            child: FilledButton(
              onPressed: _handleNext,
              style: FilledButton.styleFrom(
                backgroundColor: DesignSystem.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: Text(widget.nextButtonText),
            ),
          ),
        ],
      ),
    );
  }
}

/// 遮罩绘制器，实现挖空效果
class _SpotlightPainter extends CustomPainter {
  final Rect? targetRect;
  final Color maskColor;
  final double highlightRadius;

  _SpotlightPainter({
    required this.targetRect,
    required this.maskColor,
    required this.highlightRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = maskColor
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    if (targetRect != null) {
      final highlightPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            targetRect!,
            Radius.circular(highlightRadius),
          ),
        );

      path.fillType = PathFillType.evenOdd;
      path.addPath(highlightPath, Offset.zero);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.maskColor != maskColor ||
        oldDelegate.highlightRadius != highlightRadius;
  }
}

/// 多步骤场景化引导控制器
class SpotlightGuideController extends ChangeNotifier {
  final List<SpotlightGuideStep> steps;
  int _currentStep = 0;
  bool _isShowing = false;

  SpotlightGuideController({required this.steps});

  int get currentStep => _currentStep;
  bool get isShowing => _isShowing;
  bool get hasNextStep => _currentStep < steps.length - 1;
  bool get isLastStep => _currentStep == steps.length - 1;

  SpotlightGuideStep get currentStepData => steps[_currentStep];

  void start() {
    _currentStep = 0;
    _isShowing = true;
    notifyListeners();
  }

  void next() {
    if (hasNextStep) {
      _currentStep++;
      notifyListeners();
    } else {
      finish();
    }
  }

  void skip() {
    _isShowing = false;
    _currentStep = 0;
    notifyListeners();
  }

  void finish() {
    _isShowing = false;
    _currentStep = 0;
    notifyListeners();
  }

  void goToStep(int step) {
    if (step >= 0 && step < steps.length) {
      _currentStep = step;
      notifyListeners();
    }
  }
}

/// 单步引导配置
class SpotlightGuideStep {
  final GlobalKey? targetKey;
  final Rect? targetRect;
  final String description;
  final SpotlightPosition position;
  final String? nextButtonText;

  const SpotlightGuideStep({
    this.targetKey,
    this.targetRect,
    required this.description,
    this.position = SpotlightPosition.bottom,
    this.nextButtonText,
  });
}
