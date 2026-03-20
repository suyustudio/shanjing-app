import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/achievement.dart';

/// 成就解锁弹窗
class AchievementUnlockDialog extends StatefulWidget {
  final NewlyUnlockedAchievement achievement;
  final VoidCallback onDismiss;
  final VoidCallback onShare;

  const AchievementUnlockDialog({
    Key? key,
    required this.achievement,
    required this.onDismiss,
    required this.onShare,
  }) : super(key: key);

  @override
  State<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with TickerProviderStateMixin {
  late AnimationController _badgeController;
  late AnimationController _glowController;
  late AnimationController _textController;
  late AnimationController _buttonController;

  late Animation<double> _badgeScale;
  late Animation<double> _badgeRotation;
  late Animation<double> _glowOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _buttonSlide;

  @override
  void initState() {
    super.initState();

    // 徽章动画控制器
    _badgeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // 光效动画控制器
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // 文字动画控制器
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 按钮动画控制器
    _buttonController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // 徽章缩放动画（弹性效果）
    _badgeScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.2),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0),
        weight: 40,
      ),
    ]).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOutBack,
    ));

    // 徽章旋转动画
    _badgeRotation = Tween<double>(
      begin: -0.2,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _badgeController,
      curve: Curves.easeOut,
    ));

    // 光效透明度动画
    _glowOpacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 70,
      ),
    ]).animate(_glowController);

    // 文字淡入动画
    _textOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // 按钮上滑动画
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _buttonController,
      curve: Curves.easeOut,
    ));

    // 启动动画序列
    _startAnimationSequence();
  }

  void _startAnimationSequence() async {
    // 同时启动徽章和光效动画
    _badgeController.forward();
    _glowController.forward();

    // 延迟 200ms 后显示文字
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _textController.forward();

    // 延迟 400ms 后显示按钮
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _buttonController.forward();
  }

  @override
  void dispose() {
    _badgeController.dispose();
    _glowController.dispose();
    _textController.dispose();
    _buttonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 320,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 光效背景
            AnimatedBuilder(
              animation: _glowOpacity,
              builder: (context, child) {
                return Opacity(
                  opacity: _glowOpacity.value,
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          _getGlowColor().withOpacity(0.6),
                          _getGlowColor().withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            // 徽章动画
            AnimatedBuilder(
              animation: _badgeController,
              builder: (context, child) {
                return Transform.scale(
                  scale: _badgeScale.value,
                  child: Transform.rotate(
                    angle: _badgeRotation.value,
                    child: _buildBadge(),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // 标题文字
            FadeTransition(
              opacity: _textOpacity,
              child: Column(
                children: [
                  const Text(
                    '🎉 恭喜解锁！',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.achievement.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.achievement.message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 按钮
            SlideTransition(
              position: _buttonSlide,
              child: FadeTransition(
                opacity: _buttonController,
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: widget.onShare,
                        icon: const Icon(Icons.share),
                        label: const Text('分享成就'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: widget.onDismiss,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('稍后再说'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge() {
    final level = widget.achievement.level;
    final color = Color(
      int.parse(level.colorHex.substring(1), radix: 16) | 0xFF000000,
    );

    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.8),
            color,
            color.withOpacity(0.9),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 4,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getBadgeIcon(),
              size: 48,
              color: Colors.white,
            ),
            const SizedBox(height: 4),
            Text(
              level.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getGlowColor() {
    final colorHex = widget.achievement.level.colorHex;
    return Color(
      int.parse(colorHex.substring(1), radix: 16) | 0xFF000000,
    );
  }

  IconData _getBadgeIcon() {
    switch (widget.achievement.level) {
      case AchievementLevelType.bronze:
        return Icons.emoji_events;
      case AchievementLevelType.silver:
        return Icons.star;
      case AchievementLevelType.gold:
        return Icons.workspace_premium;
      case AchievementLevelType.diamond:
        return Icons.diamond;
      default:
        return Icons.emoji_events;
    }
  }
}
