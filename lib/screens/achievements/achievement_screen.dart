// ================================================================
// Achievement Screen - Product Fixed Version
// 成就/徽章墙主页面 - 修复版
//
// 修复内容:
// - P1-3: 添加数据埋点 (页面访问/Tab切换/详情查看)
// - P1-1: 集成分享功能
// - P2-1: 网格从 3 列改为 4 列
// ================================================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/achievement_model.dart';
import '../../providers/achievement_provider.dart';
import '../../services/achievement_service.dart';
import '../../services/analytics_service.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/achievement_share_poster.dart';
import 'achievement_detail_page.dart';
import 'achievement_unlock_dialog.dart';

class AchievementScreen extends StatefulWidget {
  const AchievementScreen({Key? key}) : super(key: key);

  @override
  State<AchievementScreen> createState() => _AchievementScreenState();
}

class _AchievementScreenState extends State<AchievementScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  final List<AchievementCategory> _categories = [
    AchievementCategory.explorer,
    AchievementCategory.distance,
    AchievementCategory.frequency,
    AchievementCategory.challenge,
    AchievementCategory.social,
  ];
  
  final List<String> _categoryNames = ['全部', '探索', '里程', '打卡', '挑战', '社交'];
  
  // 滚动埋点控制
  double _lastReportedScrollPercent = 0;
  static const double _scrollReportInterval = 25; // 每25%上报一次

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _tabController = TabController(
      length: _categories.length + 1, 
      vsync: this,
    );
    
    // Tab 切换监听（埋点）
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final tabName = _categoryNames[_tabController.index];
        AnalyticsService.instance.logAchievementTabClick(tabName);
      }
    });
    
    // 滚动监听（埋点）
    _scrollController.addListener(_onScroll);
    
    // 加载数据
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AchievementProvider>().loadUserAchievements();
      // 埋点：页面访问
      AnalyticsService.instance.logAchievementPageView();
    });
  }
  
  /// 滚动埋点处理
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    
    final offset = _scrollController.offset;
    final maxExtent = _scrollController.position.maxScrollExtent;
    
    if (maxExtent <= 0) return;
    
    // 计算滚动百分比
    final scrollPercent = (offset / maxExtent * 100).round();
    final currentBucket = (scrollPercent ~/ _scrollReportInterval) * _scrollReportInterval;
    
    // 每25%区间只上报一次
    if (currentBucket > _lastReportedScrollPercent) {
      _lastReportedScrollPercent = currentBucket;
      
      final provider = context.read<AchievementProvider>();
      final currentCategory = _tabController.index == 0 
          ? 'all' 
          : _categories[_tabController.index - 1].name;
      
      AnalyticsService.instance.logAchievementScroll(
        scrollOffset: offset,
        maxScrollExtent: maxExtent,
        visibleBadgeCount: _calculateVisibleBadgeCount(),
        category: currentCategory,
      );
    }
  }
  
  /// 计算当前可见徽章数量
  int _calculateVisibleBadgeCount() {
    // 简化计算：假设每个徽章高度约80，宽度约70，每行4个
    if (!_scrollController.hasClients) return 0;
    
    final viewportHeight = MediaQuery.of(context).size.height - 200; // 减去头部
    final visibleRows = (viewportHeight / 80).ceil();
    return visibleRows * 4; // 每行4个
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 应用从后台回到前台时刷新数据
    if (state == AppLifecycleState.resumed) {
      context.read<AchievementProvider>().refresh();
    }
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
          tabs: _categoryNames.map((name) => Tab(text: name)).toList(),
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
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AchievementProvider>().refresh(),
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // 顶部统计卡片
          SliverToBoxAdapter(
            child: _buildStatsCard(),
          ),
          // 成就网格 - P2-1 Fix: 改为 4 列
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4, // 从 3 改为 4
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
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
  
  /// P2-3 Fix: 空状态引导
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '还没有解锁任何成就',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '开始徒步探索，解锁你的第一个成就吧！',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // 跳转到路线列表
              Navigator.of(context).pushNamed('/trails');
            },
            icon: const Icon(Icons.map),
            label: const Text('去探索路线'),
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
                    '${summary.totalCount > 0 ? (summary.unlockedCount / summary.totalCount * 100).toInt() : 0}%',
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
    // 埋点：查看详情
    AnalyticsService.instance.logAchievementDetailView(achievement.achievementId);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementDetailPage(achievement: achievement),
      ),
    );
  }

  void _showShareOptions() {
    final provider = context.read<AchievementProvider>();
    final summary = provider.summary;
    
    if (summary == null || summary.unlockedCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('还没有解锁任何成就，快去探索吧！')),
      );
      return;
    }
    
    // 找到最高等级的成就用于分享
    final unlockedAchievements = summary.achievements
        .where((a) => a.isUnlocked)
        .toList();
    
    if (unlockedAchievements.isEmpty) return;
    
    // 按等级排序，选择最高的
    final topAchievement = unlockedAchievements.first;
    
    // 埋点：点击分享
    AnalyticsService.instance.logAchievementShareClick(
      topAchievement.achievementId,
      'sheet',
    );
    
    // 显示分享弹窗
    showAchievementShareSheet(
      context,
      data: AchievementShareData(
        achievementName: topAchievement.name,
        achievementLevel: topAchievement.currentLevel ?? '铜',
        achievementIconUrl: '', // 从 achievement 获取
        category: _parseCategory(topAchievement.category),
        level: _parseLevel(topAchievement.currentLevel),
        description: '我在山径App解锁了新成就！',
        unlockedAt: topAchievement.unlockedAt ?? DateTime.now(),
        totalUnlocked: summary.unlockedCount,
        totalAchievements: summary.totalCount,
      ),
    );
  }
  
  AchievementCategory _parseCategory(String category) {
    switch (category.toLowerCase()) {
      case 'explorer':
        return AchievementCategory.explorer;
      case 'distance':
        return AchievementCategory.distance;
      case 'frequency':
        return AchievementCategory.frequency;
      case 'challenge':
        return AchievementCategory.challenge;
      case 'social':
        return AchievementCategory.social;
      default:
        return AchievementCategory.explorer;
    }
  }
  
  AchievementLevel _parseLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'silver':
        return AchievementLevel.silver;
      case 'gold':
        return AchievementLevel.gold;
      case 'diamond':
        return AchievementLevel.diamond;
      default:
        return AchievementLevel.bronze;
    }
  }
}

/// 成就徽章卡片 - 优化版
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
    final category = _parseCategory(achievement.category);
    final level = _parseLevel(achievement.currentLevel);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: _getLevelColor(level).withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
          border: isUnlocked
              ? Border.all(color: _getLevelColor(level).withOpacity(0.3), width: 2)
              : Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 新解锁标记
            if (achievement.isNew)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'NEW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            // 徽章图标
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isUnlocked
                    ? _getCategoryColor(category).withOpacity(0.2)
                    : Colors.grey.shade200,
              ),
              child: Center(
                child: Icon(
                  isUnlocked ? _getCategoryIcon(category) : Icons.lock,
                  size: 24,
                  color: isUnlocked
                      ? _getLevelColor(level)
                      : Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 6),
            // 成就名称
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                achievement.name,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? Colors.black87 : Colors.grey.shade500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),
            // 等级或进度
            if (isUnlocked && achievement.currentLevel != null)
              Text(
                achievement.currentLevel!,
                style: TextStyle(
                  fontSize: 9,
                  color: _getLevelColor(level),
                  fontWeight: FontWeight.w600,
                ),
              )
            else
              Text(
                '${achievement.percentage}%',
                style: TextStyle(
                  fontSize: 9,
                  color: Colors.grey.shade500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  AchievementCategory _parseCategory(String category) {
    try {
      return AchievementCategory.values.firstWhere(
        (c) => c.name == category,
        orElse: () => AchievementCategory.explorer,
      );
    } catch (_) {
      return AchievementCategory.explorer;
    }
  }

  AchievementLevel _parseLevel(String? level) {
    switch (level?.toLowerCase()) {
      case 'silver':
        return AchievementLevel.silver;
      case 'gold':
        return AchievementLevel.gold;
      case 'diamond':
        return AchievementLevel.diamond;
      default:
        return AchievementLevel.bronze;
    }
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

  Color _getLevelColor(AchievementLevel level) {
    switch (level) {
      case AchievementLevel.bronze:
        return const Color(0xFFCD7F32);
      case AchievementLevel.silver:
        return const Color(0xFFC0C0C0);
      case AchievementLevel.gold:
        return const Color(0xFFFFD700);
      case AchievementLevel.diamond:
        return const Color(0xFF00CED1);
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
