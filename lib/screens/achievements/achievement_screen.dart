// ================================================================
// Achievement Screen
// 成就/徽章墙主页面
// ================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/achievement_model.dart';
import '../../providers/achievement_provider.dart';
import '../../services/achievement_service.dart';
import '../../widgets/custom_app_bar.dart';
import 'achievement_detail_page.dart';
import 'achievement_unlock_dialog.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<AchievementCategory> _categories = [
    AchievementCategory.explorer,
    AchievementCategory.distance,
    AchievementCategory.frequency,
    AchievementCategory.challenge,
    AchievementCategory.social,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length + 1, vsync: this);
    
    // 加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementProvider>().loadUserAchievements();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '我的成就',
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _showShareOptions,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: '全部'),
            ..._categories.map((c) => Tab(
              text: AchievementService.getCategoryDisplayName(c),
            )),
          ],
        ),
      ),
      body: Consumer<AchievementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return _buildErrorWidget(provider);
          }

          final summary = provider.summary;
          if (summary == null) return const SizedBox.shrink();

          return TabBarView(
            controller: _tabController,
            children: [
              // 全部成就
              _buildAchievementGrid(summary.achievements),
              // 分类成就
              ..._categories.map((category) {
                final achievements = provider.getAchievementsByCategory(category);
                return _buildAchievementGrid(achievements);
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorWidget(AchievementProvider provider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text('加载失败: ${provider.error}'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => provider.loadUserAchievements(),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementGrid(List<UserAchievementModel> achievements) {
    if (achievements.isEmpty) {
      return const Center(
        child: Text('暂无成就数据'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AchievementProvider>().refresh(),
      child: CustomScrollView(
        slivers: [
          // 顶部统计卡片
          SliverToBoxAdapter(
            child: _buildStatsCard(),
          ),
          // 成就网格
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final achievement = achievements[index];
                  return _AchievementBadgeCard(
                    achievement: achievement,
                    onTap: () => _showAchievementDetail(achievement),
                  );
                },
                childCount: achievements.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Consumer<AchievementProvider>(
      builder: (context, provider, child) {
        final summary = provider.summary;
        if (summary == null) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade400, Colors.green.shade700],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    '已解锁',
                    '${summary.unlockedCount}',
                    Icons.emoji_events,
                  ),
                  _buildStatItem(
                    '总成就',
                    '${summary.totalCount}',
                    Icons.star,
                  ),
                  _buildStatItem(
                    '完成度',
                    '${(summary.unlockedCount / summary.totalCount * 100).toInt()}%',
                    Icons.trending_up,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // 进度条
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary.totalCount > 0
                      ? summary.unlockedCount / summary.totalCount
                      : 0,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  void _showAchievementDetail(UserAchievementModel achievement) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementDetailPage(achievement: achievement),
      ),
    );
  }

  void _showShareOptions() {
    // TODO: 实现分享功能
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('分享我的成就'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 调用分享功能
              },
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('保存成就卡片'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 生成并保存分享卡片
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 成就徽章卡片
class _AchievementBadgeCard extends StatelessWidget {
  final UserAchievementModel achievement;
  final VoidCallback onTap;

  const _AchievementBadgeCard({
    Key? key,
    required this.achievement,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;
    final category = AchievementCategory.values.firstWhere(
      (c) => c.name == achievement.category,
      orElse: () => AchievementCategory.explorer,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          border: isUnlocked
              ? Border.all(color: Colors.green.shade200, width: 2)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 新解锁标记
            if (achievement.isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // 徽章图标
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? _getCategoryColor(category).withOpacity(0.2)
                    : Colors.grey.shade200,
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? _getCategoryIcon(category) : Icons.lock,
                  size: 32,
                  color: isUnlocked
                      ? _getCategoryColor(category)
                      : Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // 成就名称
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black87 : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // 等级或进度
            if (isUnlocked && achievement.currentLevel != null)
              Text(
                achievement.currentLevel!,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
              )
            else
              Text(
                '${achievement.percentage}%',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
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
}
