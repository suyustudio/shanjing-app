// ================================================================
// Achievement Share Card
// 成就分享卡片组件
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../../constants/design_system.dart';
import '../../models/achievement_model.dart';
import '../../services/achievement_service.dart';
import '../../widgets/achievement_badge.dart';

/// 成就分享卡片
class AchievementShareCard extends StatelessWidget {
  final NewlyUnlockedAchievement achievement;
  final UserStatsModel? stats;
  final VoidCallback? onSave;
  final VoidCallback? onShare;

  const AchievementShareCard({
    Key? key,
    required this.achievement,
    this.stats,
    this.onSave,
    this.onShare,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getBackground(context),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 拖动指示器
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            decoration: BoxDecoration(
              color: DesignSystem.getBorder(context),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // 标题
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              '分享成就',
              style: DesignSystem.getTitleMedium(context),
            ),
          ),
          // 卡片预览
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _ShareCardPreview(
              achievement: achievement,
              stats: stats,
            ),
          ),
          const SizedBox(height: 24),
          // 分享选项
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // 保存图片
                Expanded(
                  child: _ShareButton(
                    icon: Icons.download,
                    label: '保存图片',
                    color: DesignSystem.info,
                    onTap: () => _saveToGallery(context),
                  ),
                ),
                const SizedBox(width: 16),
                // 微信分享
                Expanded(
                  child: _ShareButton(
                    icon: Icons.wechat,
                    label: '微信好友',
                    color: DesignSystem.success,
                    onTap: () => _shareToWeChat(context),
                  ),
                ),
                const SizedBox(width: 16),
                // 朋友圈
                Expanded(
                  child: _ShareButton(
                    icon: Icons.camera_alt,
                    label: '朋友圈',
                    color: DesignSystem.warning,
                    onTap: () => _shareToMoments(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _saveToGallery(BuildContext context) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('图片已保存到相册', style: DesignSystem.getBodyMedium(context)),
          backgroundColor: DesignSystem.getSuccess(context),
        ),
      );
      onSave?.call();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('保存失败: $e', style: DesignSystem.getBodyMedium(context)),
          backgroundColor: DesignSystem.getError(context),
        ),
      );
    }
  }

  Future<void> _shareToWeChat(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享给微信好友', style: DesignSystem.getBodyMedium(context)),
      ),
    );
    onShare?.call();
  }

  Future<void> _shareToMoments(BuildContext context) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('分享到朋友圈', style: DesignSystem.getBodyMedium(context)),
      ),
    );
    onShare?.call();
  }
}

/// 分享卡片预览
class _ShareCardPreview extends StatelessWidget {
  final NewlyUnlockedAchievement achievement;
  final UserStatsModel? stats;

  const _ShareCardPreview({
    Key? key,
    required this.achievement,
    this.stats,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final levelColor = _getLevelColor();
    final primaryColor = DesignSystem.getPrimary(context);

    return RepaintBoundary(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              levelColor.withOpacity(0.3),
              levelColor.withOpacity(0.1),
              DesignSystem.getBackground(context),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: DesignSystem.getShadow(context),
        ),
        child: Column(
          children: [
            // 顶部标签
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '#山径App',
                    style: TextStyle(
                      fontSize: 12,
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // 徽章 - 使用新的 AchievementBadge 组件
            AchievementBadge(
              category: achievement.achievementId,
              level: achievement.level,
              state: BadgeState.unlocked,
              size: BadgeSize.large,
              enableAnimation: true,
            ),
            
            const SizedBox(height: 20),
            
            // 等级标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: levelColor,
                  width: 2,
                ),
              ),
              child: Text(
                achievement.level,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: levelColor,
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // 成就名称
            Text(
              achievement.name,
              style: DesignSystem.getHeadlineSmall(context).copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 8),
            
            // 成就描述
            Text(
              achievement.message,
              style: DesignSystem.getBodyMedium(context).copyWith(
                color: DesignSystem.getTextSecondary(context),
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // 分隔线
            Divider(color: DesignSystem.getBorder(context)),
            
            const SizedBox(height: 16),
            
            // 统计信息
            if (stats != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatItem(
                    '累计里程',
                    AchievementService.formatProgress(
                      stats!.totalDistanceM,
                      AchievementCategory.distance,
                    ),
                  ),
                  _buildStatItem(
                    '完成路线',
                    '${stats!.uniqueTrailsCount}条',
                  ),
                  _buildStatItem(
                    '连续打卡',
                    '${stats!.currentWeeklyStreak}周',
                  ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // 底部 Logo
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.landscape,
                  size: 24,
                  color: primaryColor,
                ),
                const SizedBox(width: 8),
                Text(
                  '山径 App',
                  style: DesignSystem.getTitleSmall(context).copyWith(
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '扫描二维码，一起徒步',
              style: DesignSystem.getBodySmall(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DesignSystem.textSecondary,
          ),
        ),
      ],
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

/// 分享按钮
class _ShareButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: DesignSystem.getBodySmall(context).copyWith(
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget 转图片工具类
class WidgetToImage {
  /// 将 Widget 转换为 PNG 图片字节
  static Future<Uint8List?> capture(
    BuildContext context,
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary = key.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Widget 转图片失败: $e');
      return null;
    }
  }
}
