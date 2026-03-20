// ================================================================
// Achievement Badge Widget
// 成就徽章组件 - 使用 SVG 资源
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';
import '../../constants/design_system.dart';
import '../../models/achievement_model.dart';

/// 徽章状态
enum BadgeState {
  locked,    // 未解锁
  unlocked,  // 已解锁
  newUnlock, // 新解锁
}

/// 徽章尺寸
enum BadgeSize {
  small(60),   // 列表展示
  medium(80),  // 网格展示 (默认)
  large(120),  // 详情展示
  xlarge(160); // 解锁弹窗

  final double value;
  const BadgeSize(this.value);
}

/// 成就徽章组件
class AchievementBadge extends StatelessWidget {
  final String category;
  final String level;
  final BadgeState state;
  final BadgeSize size;
  final bool enableAnimation;
  final VoidCallback? onTap;

  const AchievementBadge({
    Key? key,
    required this.category,
    required this.level,
    this.state = BadgeState.unlocked,
    this.size = BadgeSize.medium,
    this.enableAnimation = false,
    this.onTap,
  }) : super(key: key);

  /// 获取徽章 SVG 路径
  String get _badgeSvgPath {
    final categoryKey = _getCategoryKey(category);
    final levelKey = _getLevelKey(level);
    final sizeValue = size.value >= 120 ? '120' : '80';
    return 'assets/badges/$categoryKey/badge_${categoryKey}_$levelKey ${sizeValue}.svg';
  }

  /// 获取类别关键字
  String _getCategoryKey(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('first') || cat.contains('explorer')) return 'first-hike';
    if (cat.contains('distance')) return 'distance';
    if (cat.contains('trail')) return 'trail';
    if (cat.contains('streak') || cat.contains('frequency')) return 'streak';
    if (cat.contains('share') || cat.contains('social')) return 'share';
    return 'first-hike';
  }

  /// 获取等级关键字
  String _getLevelKey(String level) {
    final lvl = level.toLowerCase();
    if (lvl.contains('bronze') || lvl.contains('铜')) return 'bronze';
    if (lvl.contains('silver') || lvl.contains('银')) return 'silver';
    if (lvl.contains('gold') || lvl.contains('金')) return 'gold';
    if (lvl.contains('diamond') || lvl.contains('钻石')) return 'diamond';
    return 'bronze';
  }

  /// 判断是否为钻石等级
  bool get _isDiamond => _getLevelKey(level) == 'diamond';

  /// 获取等级颜色
  Color _getLevelColor() {
    final lvl = _getLevelKey(level);
    switch (lvl) {
      case 'bronze':
        return const Color(0xFFCD7F32);
      case 'silver':
        return const Color(0xFFC0C0C0);
      case 'gold':
        return const Color(0xFFFFD700);
      case 'diamond':
        return const Color(0xFF00CED1);
      default:
        return DesignSystem.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    Widget badgeWidget = GestureDetector(
      onTap: onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 光晕效果（仅解锁状态）
          if (state != BadgeState.locked && enableAnimation)
            _buildGlowEffect(),
          
          // 徽章主体
          _isDiamond ? _buildHexagonBadge() : _buildCircularBadge(),
          
          // 未解锁遮罩
          if (state == BadgeState.locked)
            _buildLockedOverlay(),
          
          // 新解锁标签
          if (state == BadgeState.newUnlock)
            _buildNewBadge(),
        ],
      ),
    );

    // 未解锁状态添加灰度滤镜
    if (state == BadgeState.locked) {
      badgeWidget = ColorFiltered(
        colorFilter: const ColorFilter.matrix([
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0.2126, 0.7152, 0.0722, 0, 0,
          0, 0, 0, 0.6, 0,
        ]),
        child: badgeWidget,
      );
    }

    return badgeWidget;
  }

  /// 构建圆形徽章（铜/银/金）
  Widget _buildCircularBadge() {
    return Container(
      width: size.value,
      height: size.value,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: state == BadgeState.locked 
            ? DesignSystem.backgroundTertiary 
            : Colors.white,
        boxShadow: state != BadgeState.locked
            ? [
                BoxShadow(
                  color: _getLevelColor().withOpacity(0.3),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: ClipOval(
        child: Padding(
          padding: EdgeInsets.all(size.value * 0.1),
          child: SvgPicture.asset(
            _badgeSvgPath,
            width: size.value * 0.8,
            height: size.value * 0.8,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  /// 构建六边形徽章（钻石等级）
  Widget _buildHexagonBadge() {
    return ClipPath(
      clipper: _HexagonClipper(),
      child: Container(
        width: size.value,
        height: size.value,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getLevelColor().withOpacity(0.8),
              _getLevelColor(),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: _getLevelColor().withOpacity(0.5),
              blurRadius: 20,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(size.value * 0.15),
          child: SvgPicture.asset(
            _badgeSvgPath,
            width: size.value * 0.7,
            height: size.value * 0.7,
            fit: BoxFit.contain,
            placeholderBuilder: (context) => _buildPlaceholder(),
          ),
        ),
      ),
    );
  }

  /// 构建光晕效果
  Widget _buildGlowEffect() {
    return Container(
      width: size.value * 1.3,
      height: size.value * 1.3,
      decoration: BoxDecoration(
        shape: _isDiamond ? BoxShape.rectangle : BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            _getLevelColor().withOpacity(0.4),
            _getLevelColor().withOpacity(0.1),
            Colors.transparent,
          ],
        ),
      ),
      child: enableAnimation
          ? Lottie.asset(
              'assets/lottie/badge_shine.json',
              width: size.value * 1.3,
              height: size.value * 1.3,
              fit: BoxFit.contain,
              repeat: true,
            )
          : null,
    );
  }

  /// 构建未解锁遮罩
  Widget _buildLockedOverlay() {
    return Container(
      width: size.value,
      height: size.value,
      decoration: BoxDecoration(
        shape: _isDiamond ? BoxShape.rectangle : BoxShape.circle,
        color: Colors.black.withOpacity(0.3),
      ),
      child: Center(
        child: Icon(
          Icons.lock,
          size: size.value * 0.3,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  /// 构建新解锁标签
  Widget _buildNewBadge() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: DesignSystem.error,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: DesignSystem.error.withOpacity(0.4),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Text(
          'NEW',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// 构建占位符
  Widget _buildPlaceholder() {
    return Container(
      width: size.value * 0.6,
      height: size.value * 0.6,
      decoration: BoxDecoration(
        shape: _isDiamond ? BoxShape.rectangle : BoxShape.circle,
        color: _getLevelColor().withOpacity(0.2),
      ),
      child: Icon(
        Icons.emoji_events,
        size: size.value * 0.4,
        color: _getLevelColor(),
      ),
    );
  }
}

/// 六边形裁剪器
class _HexagonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final width = size.width;
    final height = size.height;
    final radius = width / 2;
    
    // 六边形顶点
    path.moveTo(radius, 0);
    path.lineTo(width, height * 0.25);
    path.lineTo(width, height * 0.75);
    path.lineTo(radius, height);
    path.lineTo(0, height * 0.75);
    path.lineTo(0, height * 0.25);
    path.close();
    
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// 徽章工具类
class AchievementBadgeUtils {
  /// 获取等级颜色
  static Color getLevelColor(String level) {
    final lvl = level.toLowerCase();
    if (lvl.contains('bronze') || lvl.contains('铜')) {
      return const Color(0xFFCD7F32);
    } else if (lvl.contains('silver') || lvl.contains('银')) {
      return const Color(0xFFC0C0C0);
    } else if (lvl.contains('gold') || lvl.contains('金')) {
      return const Color(0xFFFFD700);
    } else if (lvl.contains('diamond') || lvl.contains('钻石')) {
      return const Color(0xFF00CED1);
    }
    return DesignSystem.primary;
  }

  /// 获取等级显示名称
  static String getLevelDisplayName(String level) {
    final lvl = level.toLowerCase();
    if (lvl.contains('bronze')) return '铜';
    if (lvl.contains('silver')) return '银';
    if (lvl.contains('gold')) return '金';
    if (lvl.contains('diamond')) return '钻石';
    return level;
  }

  /// 获取类别图标
  static IconData getCategoryIcon(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.explorer:
        return Icons.map;
      case AchievementCategory.distance:
        return Icons.directions_walk;
      case AchievementCategory.frequency:
        return Icons.calendar_today;
      case AchievementCategory.challenge:
        return Icons.whatshot;
      case AchievementCategory.social:
        return Icons.share;
    }
  }

  /// 获取类别显示名称
  static String getCategoryDisplayName(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.explorer:
        return '首次';
      case AchievementCategory.distance:
        return '里程';
      case AchievementCategory.frequency:
        return '打卡';
      case AchievementCategory.challenge:
        return '挑战';
      case AchievementCategory.social:
        return '分享';
    }
  }
}
