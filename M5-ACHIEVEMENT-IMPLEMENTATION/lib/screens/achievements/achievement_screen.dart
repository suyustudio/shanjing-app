import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/achievement.dart';
import '../../services/achievement_service.dart';
import '../../widgets/achievement_badge.dart';
import 'achievement_unlock_dialog.dart';

/// 成就筛选类别
final achievementFilterProvider = StateProvider<AchievementCategory?>((ref) => null);

/// 用户成就数据 Provider
final userAchievementsProvider = FutureProvider<UserAchievementSummary>((ref) async {
  final service = AchievementService();
  return service.getUserAchievements();
});

/// 成就列表页面
class AchievementScreen extends ConsumerStatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends ConsumerState<AchievementScreen> {
  final AchievementService _achievementService = AchievementService();

  @override
  void initState() {
    super.initState();
    _setupRealtimeNotifications();
  }

  void _setupRealtimeNotifications() {
    _achievementService.connectRealtime();

    _achievementService.onAchievementUnlocked.listen((unlocked) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AchievementUnlockDialog(
            achievement: unlocked,
            onDismiss: () {
              Navigator.of(context).pop();
              ref.refresh(userAchievementsProvider);
            },
            onShare: () {
              _shareAchievement(unlocked);
            },
          ),
        );
      }
    });
  }

  void _shareAchievement(NewlyUnlockedAchievement achievement) {
    // TODO: 实现分享功能
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('分享功能开发中...')),
    );
  }

  @override
  void dispose() {
    _achievementService.disconnectRealtime();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userAchievementsAsync = ref.watch(userAchievementsProvider);
    final selectedCategory = ref.watch(achievementFilterProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          _buildStatsSection(userAchievementsAsync),
          _buildFilterSection(selectedCategory),
          userAchievementsAsync.when(
            data: (summary) => _buildAchievementGrid(summary, selectedCategory),
            loading: () => const SliverToBoxAdapter(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => SliverToBoxAdapter(
              child: Center(child: Text('加载失败: $error')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          '我的成就',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade700,
                Colors.teal.shade600,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(AsyncValue<UserAchievementSummary> asyncValue) {
    return asyncValue.when(
      data: (summary) => SliverToBoxAdapter(
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.amber.shade400,
                Colors.orange.shade500,
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.unlockedCount} / ${summary.totalCount}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        '已解锁成就',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                  if (summary.newUnlockedCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${summary.newUnlockedCount} 个新成就',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary.totalCount > 0
                      ? summary.unlockedCount / summary.totalCount
                      : 0,
                  backgroundColor: Colors.white24,
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '完成度 ${summary.totalCount > 0 ? (summary.unlockedCount / summary.totalCount * 100).toInt() : 0}%',
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
      loading: () => const SliverToBoxAdapter(child: SizedBox()),
      error: (_, __) => const SliverToBoxAdapter(child: SizedBox()),
    );
  }

  Widget _buildFilterSection(AchievementCategory? selectedCategory) {
    final categories = [
      null, // 全部
      AchievementCategory.explorer,
      AchievementCategory.distance,
      AchievementCategory.frequency,
      AchievementCategory.challenge,
      AchievementCategory.social,
    ];

    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            final isSelected = selectedCategory == category;

            return GestureDetector(
              onTap: () {
                ref.read(achievementFilterProvider.notifier).state = category;
              },
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.green : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? Colors.green : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    category?.displayName ?? '全部',
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAchievementGrid(
    UserAchievementSummary summary,
    AchievementCategory? filter,
  ) {
    var achievements = summary.achievements;

    if (filter != null) {
      achievements = achievements
          .where((a) => a.category == filter)
          .toList();
    }

    return SliverPadding(
      padding: const EdgeInsets.all(16),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.8,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final achievement = achievements[index];
            return AchievementBadge(
              achievement: achievement,
              onTap: () => _showAchievementDetail(achievement),
            );
          },
          childCount: achievements.length,
        ),
      ),
    );
  }

  void _showAchievementDetail(UserAchievement achievement) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            AchievementBadge(
              achievement: achievement,
              size: 100,
              showAnimation: achievement.isNew,
            ),
            const SizedBox(height: 16),
            Text(
              achievement.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (achievement.currentLevel != null) ...[
              const SizedBox(height: 8),
              Text(
                achievement.currentLevel!.displayName,
                style: TextStyle(
                  fontSize: 18,
                  color: Color(
                    int.parse(
                      achievement.currentLevel!.colorHex.substring(1),
                      radix: 16,
                    ) | 0xFF000000,
                  ),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              '进度: ${achievement.currentProgress} / ${achievement.nextRequirement}',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: achievement.percentage / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  achievement.currentLevel != null
                      ? Colors.green
                      : Colors.grey,
                ),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: 24),
            if (achievement.isNew)
              ElevatedButton(
                onPressed: () async {
                  await _achievementService.markAchievementViewed(
                    achievement.achievementId,
                  );
                  ref.refresh(userAchievementsProvider);
                  Navigator.of(context).pop();
                },
                child: const Text('标记为已查看'),
              ),
          ],
        ),
      ),
    );
  }
}
