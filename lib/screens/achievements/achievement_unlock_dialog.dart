// ================================================================
// Achievement Unlock Dialog
// 成就解锁弹窗组件 - 集成 Lottie 动画
// ================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import '../../constants/design_system.dart';
import '../../models/achievement_model.dart';
import '../../services/achievement_service.dart';
import '../../widgets/achievement_badge.dart';
import 'achievement_share_card.dart';

/// 成就解锁弹窗
class AchievementUnlockDialog extends StatefulWidget {
  final NewlyUnlockedAchievement achievement;
  final VoidCallback? onDismiss;
  final VoidCallback? onShare;

  const AchievementUnlockDialog({
    Key? key,
    required this.achievement,
    this.onDismiss,
    this.onShare,
  }) : super(key: key);

  @override
  State<AchievementUnlockDialog> createState() => _AchievementUnlockDialogState();

  /// 显示解锁弹窗的便捷方法
  static Future<void> show(
    BuildContext context,
    NewlyUnlockedAchievement achievement, {
    VoidCallback? onDismiss,
    VoidCallback? onShare,
  }) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (context) => AchievementUnlockDialog(
        achievement: achievement,
        onDismiss: onDismiss,
        onShare: onShare,
      ),
    );
  }
}

class _AchievementUnlockDialogState extends State<AchievementUnlockDialog>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _backgroundGlowAnimation;

  @override
  void initState() {
    super.initState();

    // 缩放动画控制器 - 500ms, spring 曲线
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    // 光效动画控制器 - 1000ms
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // Spring 缩放动画
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const _SpringCurve(0.4, 0.5),  // Spring(1, 0.5)
      ),
    );

    // 光效呼吸动画
    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );
    
    // 背景光晕扩散动画
    _backgroundGlowAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _scaleController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // 启动动画
    _scaleController.forward();
    _glowController.repeat(reverse: true);

    // 添加触感反馈
    HapticFeedback.mediumImpact();
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 标题 - 淡入动画
              AnimatedOpacity(
                opacity: _scaleController.value > 0.5 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  '🎉 恭喜解锁！',
                  style: DesignSystem.getHeadlineSmall(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // 徽章动画区域
              SizedBox(
                height: 200,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 背景光晕扩散效果
                    AnimatedBuilder(
                      animation: _backgroundGlowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 200 + (_backgroundGlowAnimation.value * 100),
                          height: 200 + (_backgroundGlowAnimation.value * 100),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _getLevelColor().withOpacity(
                                    0.6 * (1 - _backgroundGlowAnimation.value)),
                                _getLevelColor().withOpacity(
                                    0.3 * (1 - _backgroundGlowAnimation.value)),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    
                    // Lottie Confetti 粒子效果
                    Lottie.asset(
                      'assets/lottie/confetti.json',
                      width: 300,
                      height: 300,
                      fit: BoxFit.cover,
                      repeat: false,
                    ),
                    
                    // Lottie 解锁动画
                    Lottie.asset(
                      'assets/lottie/achievement_unlock.json',
                      width: 180,
                      height: 180,
                      fit: BoxFit.contain,
                      repeat: false,
                    ),
                    
                    // 徽章缩放动画
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: AchievementBadge(
                            category: widget.achievement.achievementId,
                            level: widget.achievement.level,
                            state: BadgeState.unlocked,
                            size: BadgeSize.xlarge,
                            enableAnimation: true,
                          ),
                        );
                      },
                    ),
                    
                    // 徽章光晕呼吸效果
                    AnimatedBuilder(
                      animation: _glowAnimation,
                      builder: (context, child) {
                        return Container(
                          width: 180 + (_glowAnimation.value * 40),
                          height: 180 + (_glowAnimation.value * 40),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                _getLevelColor().withOpacity(_glowAnimation.value * 0.5),
                                _getLevelColor().withOpacity(_glowAnimation.value * 0.2),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // 成就名称 - 淡入动画
              AnimatedOpacity(
                opacity: _scaleController.value > 0.6 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  widget.achievement.name,
                  style: DesignSystem.getHeadlineSmall(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 12),
              
              // 成就等级 - 淡入动画
              AnimatedOpacity(
                opacity: _scaleController.value > 0.7 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getLevelColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getLevelColor(),
                      width: 2,
                    ),
                  ),
                  child: Text(
                    widget.achievement.level,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _getLevelColor(),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // 提示消息 - 淡入动画
              AnimatedOpacity(
                opacity: _scaleController.value > 0.8 ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Text(
                  widget.achievement.message,
                  style: DesignSystem.getBodyMedium(context).copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              
              const SizedBox(height: 40),
              
              // 按钮组 - 上滑动画
              AnimatedBuilder(
                animation: _scaleController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, 20 * (1 - _scaleController.value)),
                    child: Opacity(
                      opacity: _scaleController.value > 0.8 ? 1.0 : 0.0,
                      child: Row(
                        children: [
                          // 分享按钮
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _onShare,
                              icon: const Icon(Icons.share, size: 20),
                              label: const Text('分享成就'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: DesignSystem.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          // 查看详情按钮
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _onDismiss,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: DesignSystem.textPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: const Text('查看详情'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor() {
    final level = widget.achievement.level.toLowerCase();
    if (level.contains('bronze') || level.contains('铜')) {
      return const Color(0xFFCD7F32);
    } else if (level.contains('silver') || level.contains('银')) {
      return const Color(0xFFC0C0C0);
    } else if (level.contains('gold') || level.contains('金')) {
      return const Color(0xFFFFD700);
    } else if (level.contains('diamond') || level.contains('钻石')) {
      return const Color(0xFF00CED1);
    }
    return DesignSystem.primary;
  }

  void _onShare() {
    Navigator.pop(context);
    widget.onShare?.call();
    
    // 显示分享卡片
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AchievementShareCard(
        achievement: widget.achievement,
      ),
    );
  }

  void _onDismiss() {
    Navigator.pop(context);
    widget.onDismiss?.call();
  }
}

/// Spring 曲线 - 模拟弹簧效果
class _SpringCurve extends Curve {
  final double damping;
  final double stiffness;

  const _SpringCurve(this.damping, this.stiffness);

  @override
  double transform(double t) {
    // 简化的弹簧曲线实现
    if (t == 0) return 0;
    if (t == 1) return 1;
    
    final double oscillation = 
        (1 - damping) * (math.sin(t * math.pi * 2 * (1 + stiffness)) / 
        (t * math.pi * 2));
    
    return (1 + oscillation * math.exp(-damping * t * 5)).clamp(0.0, 1.0);
  }
}

/// 简单的成就解锁提示 SnackBar
class AchievementUnlockSnackBar extends StatelessWidget {
  final NewlyUnlockedAchievement achievement;
  final VoidCallback? onTap;

  const AchievementUnlockSnackBar({
    Key? key,
    required this.achievement,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              levelColor.withOpacity(0.8),
              levelColor,
            ],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // 使用 SVG 徽章替代图标
            AchievementBadge(
              category: achievement.achievementId,
              level: achievement.level,
              state: BadgeState.unlocked,
              size: BadgeSize.small,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '解锁新成就！',
                    style: DesignSystem.getLabelMedium(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    achievement.name,
                    style: DesignSystem.getTitleSmall(context).copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Colors.white70,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLevelColor() {
    final level = achievement.level.toLowerCase();
    if (level.contains('bronze') || level.contains('铜')) {
      return const Color(0xFFCD7F32);
    } else if (level.contains('silver') || level.contains('银')) {
      return const Color(0xFFC0C0C0);
    } else if (level.contains('gold') || level.contains('金')) {
      return const Color(0xFFFFD700);
    } else if (level.contains('diamond') || level.contains('钻石')) {
      return const Color(0xFF00CED1);
    }
    return DesignSystem.primary;
  }
}
