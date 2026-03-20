// ================================================================
// Achievement Detail Page
// 成就详情页面
// ================================================================

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../constants/design_system.dart';
import '../../models/achievement_model.dart';
import '../../services/achievement_service.dart';
import '../../widgets/achievement_badge.dart';

class AchievementDetailPage extends StatelessWidget {
  final UserAchievementModel achievement;

  const AchievementDetailPage({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      appBar: AppBar(
        title: Text(achievement.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: DesignSystem.getTextPrimary(context),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 徽章大图展示
            _buildBadgeCard(isUnlocked),
            const SizedBox(height: 24),
            // 成就信息
            _buildInfoCard(),
            const SizedBox(height: 24),
            // 进度信息
            if (!isUnlocked || achievement.percentage < 100)
              _buildProgressCard(),
            if (isUnlocked) ...[
              const SizedBox(height: 24),
              _buildUnlockInfoCard(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBadgeCard(bool isUnlocked) {
    final levelColor = AchievementBadgeUtils.getLevelColor(
      achievement.currentLevel ?? 'bronze',
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnlocked
              ? [
                  levelColor.withOpacity(0.3),
                  levelColor.withOpacity(0.1),
                ]
              : [
                  DesignSystem.getBackgroundSecondary(context),
                  DesignSystem.getBackgroundTertiary(context),
                ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: DesignSystem.getShadow(context),
      ),
      child: Column(
        children: [
          // 徽章 - 使用新的 AchievementBadge 组件
          AchievementBadge(
            category: achievement.category,
            level: achievement.currentLevel ?? 'bronze',
            state: isUnlocked ? BadgeState.unlocked : BadgeState.locked,
            size: BadgeSize.large,
            enableAnimation: isUnlocked,
          ),
          const SizedBox(height: 20),
          // 成就名称
          Text(
            achievement.name,
            style: DesignSystem.getHeadlineSmall(context).copyWith(
              color: isUnlocked 
                  ? DesignSystem.getTextPrimary(context) 
                  : DesignSystem.getTextTertiary(context),
            ),
          ),
          if (achievement.currentLevel != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: levelColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                achievement.currentLevel!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: levelColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '成就信息',
              style: DesignSystem.getTitleMedium(context),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              '类别', 
              _getCategoryDisplayName(achievement.category),
            ),
            Divider(
              height: 24, 
              color: DesignSystem.getDivider(context),
            ),
            _buildInfoRow(
              '状态',
              achievement.isUnlocked ? '已解锁' : '未解锁',
              valueColor: achievement.isUnlocked 
                  ? DesignSystem.success 
                  : DesignSystem.getTextTertiary(context),
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              Divider(
                height: 24, 
                color: DesignSystem.getDivider(context),
              ),
              _buildInfoRow(
                '解锁时间',
                _formatDate(achievement.unlockedAt!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final primaryColor = DesignSystem.getPrimary(context);

    return Container(
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(16),
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '当前进度',
              style: DesignSystem.getTitleMedium(context),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${achievement.currentProgress}',
                  style: DesignSystem.getHeadlineSmall(context).copyWith(
                    color: primaryColor,
                  ),
                ),
                Text(
                  '/ ${achievement.nextRequirement}',
                  style: DesignSystem.getBodyLarge(context).copyWith(
                    color: DesignSystem.getTextSecondary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: achievement.percentage / 100,
                backgroundColor: DesignSystem.getBackgroundTertiary(context),
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '已完成 ${achievement.percentage}%',
              style: DesignSystem.getBodySmall(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockInfoCard() {
    final successColor = DesignSystem.getSuccess(context);

    return Container(
      decoration: BoxDecoration(
        color: successColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: successColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: successColor,
            ),
            const SizedBox(height: 12),
            Text(
              '恭喜解锁此成就！',
              style: DesignSystem.getTitleMedium(context),
            ),
            const SizedBox(height: 8),
            Text(
              '继续保持，解锁更多成就！',
              style: DesignSystem.getBodyMedium(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: DesignSystem.getBodyMedium(context).copyWith(
            color: DesignSystem.getTextSecondary(context),
          ),
        ),
        Text(
          value,
          style: DesignSystem.getBodyMedium(context).copyWith(
            fontWeight: FontWeight.bold,
            color: valueColor ?? DesignSystem.getTextPrimary(context),
          ),
        ),
      ],
    );
  }

  String _getCategoryDisplayName(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('first') || cat.contains('explorer')) return '首次徒步';
    if (cat.contains('distance')) return '里程累计';
    if (cat.contains('trail')) return '路线收集';
    if (cat.contains('streak') || cat.contains('frequency')) return '连续打卡';
    if (cat.contains('share') || cat.contains('social')) return '分享达人';
    return '其他';
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
