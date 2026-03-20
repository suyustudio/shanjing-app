import 'package:flutter/material.dart';
import '../../models/achievement.dart';

/// 徽章组件
class AchievementBadge extends StatelessWidget {
  final UserAchievement achievement;
  final double size;
  final VoidCallback? onTap;
  final bool showAnimation;

  const AchievementBadge({
    Key? key,
    required this.achievement,
    this.size = 80,
    this.onTap,
    this.showAnimation = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.currentLevel != null;
    final level = achievement.currentLevel;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: size,
        height: size * 1.2,
        child: Column(
          children: [
            // 徽章图标
            _buildBadgeIcon(isUnlocked, level),
            const SizedBox(height: 8),
            // 成就名称
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: size * 0.15,
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                color: isUnlocked ? Colors.black87 : Colors.grey.shade500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            // 等级标识
            if (isUnlocked) ...[
              const SizedBox(height: 2),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: size * 0.1,
                  vertical: size * 0.03,
                ),
                decoration: BoxDecoration(
                  color: _getLevelColor(level!).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(size * 0.1),
                ),
                child: Text(
                  level.displayName,
                  style: TextStyle(
                    fontSize: size * 0.12,
                    color: _getLevelColor(level),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Icon(
                Icons.lock,
                size: size * 0.15,
                color: Colors.grey.shade400,
              ),
            ],
            // 新解锁标记
            if (achievement.isNew) ...[
              const SizedBox(height: 4),
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeIcon(bool isUnlocked, AchievementLevelType? level) {
    if (!isUnlocked) {
      // 未解锁状态
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
          border: Border.all(
            color: Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            Icons.help_outline,
            size: size * 0.4,
            color: Colors.grey.shade400,
          ),
        ),
      );
    }

    final color = _getLevelColor(level!);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color,
            color.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: showAnimation ? 15 : 8,
            spreadRadius: showAnimation ? 3 : 1,
          ),
        ],
        border: Border.all(
          color: Colors.white,
          width: 3,
        ),
      ),
      child: Center(
        child: Icon(
          _getBadgeIcon(level),
          size: size * 0.45,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getLevelColor(AchievementLevelType level) {
    return Color(
      int.parse(level.colorHex.substring(1), radix: 16) | 0xFF000000,
    );
  }

  IconData _getBadgeIcon(AchievementLevelType level) {
    switch (achievement.category) {
      case AchievementCategory.explorer:
        return Icons.map;
      case AchievementCategory.distance:
        return Icons.straighten;
      case AchievementCategory.frequency:
        return Icons.local_fire_department;
      case AchievementCategory.challenge:
        return Icons.emoji_flags;
      case AchievementCategory.social:
        return Icons.share;
      default:
        return Icons.emoji_events;
    }
  }
}

/// 成就徽章展示组件（大尺寸）
class LargeAchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final AchievementLevelType? unlockedLevel;
  final VoidCallback? onTap;

  const LargeAchievementBadge({
    Key? key,
    required this.achievement,
    this.unlockedLevel,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = unlockedLevel != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUnlocked ? Colors.green.shade200 : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.green.shade100,
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isUnlocked)
              _buildUnlockedBadge()
            else
              _buildLockedBadge(),
            const SizedBox(height: 12),
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                color: isUnlocked ? Colors.black87 : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
            if (isUnlocked && unlockedLevel != null) ...[
              const SizedBox(height: 4),
              Text(
                unlockedLevel!.displayName,
                style: TextStyle(
                  fontSize: 14,
                  color: _getLevelColor(unlockedLevel!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ] else ...[
              const SizedBox(height: 4),
              Text(
                '未解锁',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockedBadge() {
    final level = unlockedLevel!;
    final color = _getLevelColor(level);

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.7),
            color,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 12,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          _getCategoryIcon(),
          size: 40,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLockedBadge() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(
          color: Colors.grey.shade300,
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.lock,
          size: 32,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }

  Color _getLevelColor(AchievementLevelType level) {
    return Color(
      int.parse(level.colorHex.substring(1), radix: 16) | 0xFF000000,
    );
  }

  IconData _getCategoryIcon() {
    switch (achievement.category) {
      case AchievementCategory.explorer:
        return Icons.map;
      case AchievementCategory.distance:
        return Icons.straighten;
      case AchievementCategory.frequency:
        return Icons.local_fire_department;
      case AchievementCategory.challenge:
        return Icons.emoji_flags;
      case AchievementCategory.social:
        return Icons.share;
      default:
        return Icons.emoji_events;
    }
  }
}
