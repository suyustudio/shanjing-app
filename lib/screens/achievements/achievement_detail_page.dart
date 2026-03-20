// ================================================================
// Achievement Detail Page
// 成就详情页面
// ================================================================

import 'package:flutter/material.dart';
import '../../models/achievement_model.dart';
import '../../services/achievement_service.dart';

class AchievementDetailPage extends StatelessWidget {
  final UserAchievementModel achievement;

  const AchievementDetailPage({
    Key? key,
    required this.achievement,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final category = AchievementCategory.values.firstWhere(
      (c) => c.name == achievement.category,
      orElse: () => AchievementCategory.explorer,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(achievement.name),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 徽章大图展示
            _buildBadgeCard(category, isUnlocked),
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

  Widget _buildBadgeCard(AchievementCategory category, bool isUnlocked) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isUnlocked
              ? [
                  _getCategoryColor(category).withOpacity(0.3),
                  _getCategoryColor(category).withOpacity(0.1),
                ]
              : [Colors.grey.shade200, Colors.grey.shade100],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // 徽章图标
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isUnlocked ? Colors.white : Colors.grey.shade300,
              boxShadow: isUnlocked
                  ? [
                      BoxShadow(
                        color: _getCategoryColor(category).withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 5,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Icon(
                isUnlocked ? _getCategoryIcon(category) : Icons.lock,
                size: 60,
                color: isUnlocked
                    ? _getCategoryColor(category)
                    : Colors.grey.shade500,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // 成就名称
          Text(
            achievement.name,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: isUnlocked ? Colors.black87 : Colors.grey.shade600,
            ),
          ),
          if (achievement.currentLevel != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: _getLevelColor(achievement.currentLevel!).withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                achievement.currentLevel!,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: _getLevelColor(achievement.currentLevel!),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final category = AchievementCategory.values.firstWhere(
      (c) => c.name == achievement.category,
      orElse: () => AchievementCategory.explorer,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '成就信息',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('类别', AchievementService.getCategoryDisplayName(category)),
            const Divider(height: 24),
            _buildInfoRow(
              '状态',
              achievement.isUnlocked ? '已解锁' : '未解锁',
              valueColor: achievement.isUnlocked ? Colors.green : Colors.grey,
            ),
            if (achievement.isUnlocked && achievement.unlockedAt != null) ...[
              const Divider(height: 24),
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
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '当前进度',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${achievement.currentProgress}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '/ ${achievement.nextRequirement}',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: achievement.percentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '已完成 ${achievement.percentage}%',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              Icons.check_circle,
              size: 48,
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 12),
            const Text(
              '恭喜解锁此成就！',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '继续保持，解锁更多成就！',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
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
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.explorer:
        return Colors.blue;
      case AchievementCategory.distance:
        return Colors.orange;
      case AchievementCategory.frequency:
        return Colors.purple;
      case AchievementCategory.challenge:
        return Colors.red;
      case AchievementCategory.social:
        return Colors.green;
    }
  }

  IconData _getCategoryIcon(AchievementCategory category) {
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

  Color _getLevelColor(String level) {
    if (level.contains('铜')) return const Color(0xFFCD7F32);
    if (level.contains('银')) return const Color(0xFFC0C0C0);
    if (level.contains('金')) return const Color(0xFFFFD700);
    if (level.contains('钻石')) return const Color(0xFF00CED1);
    return Colors.green;
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
