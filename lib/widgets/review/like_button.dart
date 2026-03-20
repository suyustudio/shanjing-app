/**
 * 点赞按钮组件
 * 
 * M6 评论点赞功能 - 带动画效果
 * 参考: design/M6-DESIGN-FIX-v1.0.md
 */

import 'package:flutter/material.dart';

/// 点赞按钮
class LikeButton extends StatefulWidget {
  final int count;
  final bool isLiked;
  final VoidCallback? onTap;
  final Duration animationDuration;
  final double size;
  
  const LikeButton({
    Key? key,
    required this.count,
    required this.isLiked,
    this.onTap,
    this.animationDuration = const Duration(milliseconds: 300),
    this.size = 44.0,
  }) : super(key: key);

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  
  bool _isPressed = false;
  bool _showParticles = false;

  // 品牌色
  static const Color _primaryColor = Color(0xFF2D968A);
  static const Color _grayColor = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    // 弹性动画曲线
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.85),
        weight: 16.7, // 0-50ms
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.3)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 33.3, // 50-150ms
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.3, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 50, // 150-300ms
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    if (widget.onTap == null) return;
    
    // 触发动画
    _controller.forward(from: 0).then((_) {
      setState(() {
        _showParticles = false;
      });
    });
    
    // 如果是点赞操作，显示粒子效果
    if (!widget.isLiked) {
      setState(() {
        _showParticles = true;
      });
    }
    
    widget.onTap!();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  /// 格式化点赞数
  String _formatCount(int count) {
    if (count == 0) return '';
    if (count < 1000) return count.toString();
    if (count < 10000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return '${(count / 10000).toStringAsFixed(1)}w';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.85 : _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.transparent,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 粒子效果层
                  if (_showParticles && !widget.isLiked)
                    _ParticlesWidget(
                      color: _primaryColor,
                      onComplete: () {
                        setState(() {
                          _showParticles = false;
                        });
                      },
                    ),
                  // 点赞图标和数字
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.isLiked
                            ? Icons.thumb_up
                            : Icons.thumb_up_outlined,
                        size: 20,
                        color: widget.isLiked ? _primaryColor : _grayColor,
                      ),
                      if (widget.count > 0) ...[
                        SizedBox(width: 4),
                        AnimatedSwitcher(
                          duration: Duration(milliseconds: 200),
                          transitionBuilder: (child, animation) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: Offset(0, -0.5),
                                  end: Offset(0, 0),
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
                              color: widget.isLiked ? _primaryColor : _grayColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// 粒子效果组件
class _ParticlesWidget extends StatefulWidget {
  final Color color;
  final VoidCallback onComplete;

  const _ParticlesWidget({
    Key? key,
    required this.color,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<_ParticlesWidget> createState() => _ParticlesWidgetState();
}

class _ParticlesWidgetState extends State<_ParticlesWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );
    
    _controller.forward().then((_) {
      widget.onComplete();
    });
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
        return CustomPaint(
          size: Size(60, 60),
          painter: _ParticlesPainter(
            progress: _controller.value,
            color: widget.color,
          ),
        );
      },
    );
  }
}

/// 粒子绘制
class _ParticlesPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ParticlesPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final particleCount = 8;
    final radius = 15.0 + (progress * 20); // 扩散半径
    
    for (int i = 0; i < particleCount; i++) {
      final angle = (i * 2 * 3.14159) / particleCount;
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      
      final paint = Paint()
        ..color = color.withOpacity(1 - progress)
        ..style = PaintingStyle.fill;
      
      final particleSize = 4 * (1 - progress);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
