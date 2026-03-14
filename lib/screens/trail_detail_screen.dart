import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../constants/design_system.dart';
import 'navigation_screen.dart';

/// 路线详情页
/// 显示路线封面、基本信息、简介和导航入口
class TrailDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? trailData;

  const TrailDetailScreen({Key? key, this.trailData}) : super(key: key);

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _isFavorite = false;
  bool _isLoading = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  late TabController _tabController;

  /// 获取路线数据（优先使用传递的数据）
  Map<String, dynamic> get _trailData {
    if (widget.trailData != null) {
      return widget.trailData!;
    }
    // 默认数据
    return {
      'id': 'trail_001',
      'name': '西湖环湖步道',
      'coverUrl': 'https://picsum.photos/400/240',
      'difficulty': '中等',
      'difficultyLevel': 3,
      'distance': 12.5,
      'duration': 240,
      'elevation': 150,
      'description': '这是一条风景优美的徒步路线，沿途可欣赏西湖美景，经过断桥、苏堤、白堤等著名景点。适合周末休闲，全程平坦，路面状况良好，是杭州最受欢迎的徒步路线之一。',
      'isFavorite': false,
    };
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = _trailData['isFavorite'] ?? false;
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// 切换收藏状态
  void _toggleFavorite() {
    setState(() {
      _isFavorite = !_isFavorite;
    });
    // TODO: 调用收藏 API
  }

  /// 开始导航
  void _startNavigation() {
    final trailName = _trailData['name']?.toString() ?? '未知路线';
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(routeName: trailName),
      ),
    );
  }

  /// 下载路线
  void _downloadTrail() {
    if (_isDownloading) return;
    
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });
    
    // 显示带进度的 SnackBar
    _showDownloadSnackBar();
    
    // 模拟下载进度（实际项目中替换为真实下载逻辑）
    _simulateDownload();
  }
  
  /// 显示下载进度 SnackBar
  void _showDownloadSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: StatefulBuilder(
          builder: (context, setSnackBarState) {
            return Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: _downloadProgress > 0 ? _downloadProgress : null,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _downloadProgress >= 1.0 
                            ? '下载完成'
                            : _downloadProgress > 0 
                                ? '正在下载 ${(_downloadProgress * 100).toInt()}%'
                                : '准备下载...',
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (_downloadProgress > 0 && _downloadProgress < 1.0)
                        const SizedBox(height: 4),
                      if (_downloadProgress > 0 && _downloadProgress < 1.0)
                        LinearProgressIndicator(
                          value: _downloadProgress,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          minHeight: 2,
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        backgroundColor: DesignSystem.getPrimary(context),
        duration: const Duration(seconds: 10),
        action: _downloadProgress >= 1.0
            ? SnackBarAction(
                label: '查看',
                textColor: Colors.white,
                onPressed: () {
                  // TODO: 跳转到离线地图管理页面
                },
              )
            : null,
      ),
    );
  }
  
  /// 模拟下载进度
  void _simulateDownload() {
    const totalSteps = 20;
    var currentStep = 0;
    
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      currentStep++;
      setState(() {
        _downloadProgress = currentStep / totalSteps;
      });
      
      // 更新 SnackBar 显示
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showDownloadSnackBar();
      
      if (currentStep >= totalSteps) {
        timer.cancel();
        setState(() {
          _isDownloading = false;
        });
        
        // 下载完成，显示完成提示
        Future.delayed(const Duration(milliseconds: 500), () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text('路线下载成功', style: TextStyle(color: Colors.white)),
                ],
              ),
              backgroundColor: DesignSystem.getSuccess(context),
              duration: const Duration(seconds: 2),
            ),
          );
        });
      }
    });
  }

  /// 获取难度颜色
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '简单':
        return DesignSystem.getSuccess(context);
      case '中等':
        return DesignSystem.getWarning(context);
      case '困难':
        return DesignSystem.getError(context);
      default:
        return DesignSystem.getTextTertiary(context);
    }
  }

  /// 格式化时长
  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours > 0 && mins > 0) {
      return '约 ${hours}小时${mins}分';
    } else if (hours > 0) {
      return '约 ${hours}小时';
    } else {
      return '约 ${mins}分钟';
    }
  }

  @override
  Widget build(BuildContext context) {
    // 检查路线数据是否为空
    if (widget.trailData == null) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // 封面图
              SliverToBoxAdapter(
                child: _buildCoverImage(context),
              ),
              // 标题区域
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(context),
                      const SizedBox(height: 16),
                      _buildInfoRow(context),
                      const SizedBox(height: 24),
                      _buildDescription(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              // TabBar - 吸顶
              SliverPersistentHeader(
                pinned: true,
                delegate: _TabBarDelegate(
                  child: Container(
                    color: DesignSystem.getBackground(context),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: DesignSystem.getPrimary(context),
                      unselectedLabelColor: DesignSystem.getTextSecondary(context),
                      indicatorColor: DesignSystem.getPrimary(context),
                      tabs: const [
                        Tab(text: '简介'),
                        Tab(text: '轨迹'),
                        Tab(text: '评价'),
                        Tab(text: '攻略'),
                      ],
                    ),
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              // 简介 Tab
              _buildIntroductionTab(),
              // 轨迹 Tab
              _buildTrackTab(),
              // 评价 Tab
              _buildReviewTab(),
              // 攻略 Tab
              _buildGuideTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  /// 构建封面图区域
  Widget _buildCoverImage(BuildContext context) {
    return Stack(
      children: [
        // 封面图
        Container(
          height: 240,
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: DesignSystem.getBackgroundTertiary(context),
            image: DecorationImage(
              image: NetworkImage(_trailData['coverUrl']),
              fit: BoxFit.cover,
            ),
          ),
        ),
        // 收藏按钮 - 右上角
        Positioned(
          top: 24,
          right: 24,
          child: Container(
            decoration: BoxDecoration(
              color: DesignSystem.getBackgroundElevated(context).withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: DesignSystem.getShadowLight(context),
            ),
            child: IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : DesignSystem.getTextSecondary(context),
              ),
            ),
          ),
        ),
        // 返回按钮 - 左上角
        Positioned(
          top: 24,
          left: 24,
          child: Container(
            decoration: BoxDecoration(
              color: DesignSystem.getBackgroundElevated(context).withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: DesignSystem.getShadowLight(context),
            ),
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Icon(
                Icons.arrow_back,
                color: DesignSystem.getTextPrimary(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建标题区域（路线名称 + 难度标签）
  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 路线名称 - 22px Semibold
        Text(
          _trailData['name'],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: DesignSystem.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        // 星级 + 难度标签
        Row(
          children: [
            // 星级评分
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < _trailData['difficultyLevel']
                      ? Icons.star
                      : Icons.star_border,
                  color: DesignSystem.getWarning(context),
                  size: 18,
                );
              }),
            ),
            const SizedBox(width: 8),
            // 难度标签
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getDifficultyColor(_trailData['difficulty']).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '难度: ${_trailData['difficulty']}',
                style: TextStyle(
                  fontSize: 12,
                  color: _getDifficultyColor(_trailData['difficulty']),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 构建信息行（距离/时长/海拔）
  Widget _buildInfoRow(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildInfoItem(
            context: context,
            icon: Icons.location_on_outlined,
            value: '${_trailData['distance']} km',
            label: '距离',
          ),
          Container(
            height: 40,
            width: 1,
            color: DesignSystem.getDivider(context),
          ),
          _buildInfoItem(
            context: context,
            icon: Icons.timer_outlined,
            value: _formatDuration(_trailData['duration']),
            label: '时长',
          ),
          Container(
            height: 40,
            width: 1,
            color: DesignSystem.getDivider(context),
          ),
          _buildInfoItem(
            context: context,
            icon: Icons.trending_up_outlined,
            value: '${_trailData['elevation']} m',
            label: '海拔爬升',
          ),
        ],
      ),
    );
  }

  /// 构建单个信息项
  Widget _buildInfoItem({
    required BuildContext context,
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: DesignSystem.getPrimary(context),
          size: 24,
        ),
        const SizedBox(height: 8),
        // 核心数据 - 24px 大号字体
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: DesignSystem.getTextPrimary(context),
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: DesignSystem.getTextSecondary(context),
          ),
        ),
      ],
    );
  }

  /// 构建路线简介
  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '路线简介',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: DesignSystem.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _trailData['description'],
          style: TextStyle(
            fontSize: 14,
            color: DesignSystem.getTextSecondary(context),
            height: 1.6,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建简介 Tab
  Widget _buildIntroductionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 路线描述
          _buildSectionTitle('路线描述'),
          const SizedBox(height: 12),
          Text(
            _trailData['description'],
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 24),
          // 难度说明
          _buildSectionTitle('难度说明'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getDifficultyColor(_trailData['difficulty']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _trailData['difficulty'],
                  style: TextStyle(
                    fontSize: 14,
                    color: _getDifficultyColor(_trailData['difficulty']),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // 适合人群
          _buildSectionTitle('适合人群'),
          const SizedBox(height: 12),
          Text(
            '适合喜欢自然风光、希望轻松徒步的户外爱好者。全程路况良好，无技术难点。',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 100), // 底部留白
        ],
      ),
    );
  }

  /// 构建轨迹 Tab
  Widget _buildTrackTab() {
    return const Center(
      child: Text('轨迹内容'),
    );
  }

  /// 构建评价 Tab
  Widget _buildReviewTab() {
    return const Center(
      child: Text('评价内容'),
    );
  }

  /// 构建攻略 Tab
  Widget _buildGuideTab() {
    return const Center(
      child: Text('攻略内容'),
    );
  }

  /// 构建章节标题
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: DesignSystem.getTextPrimary(context),
      ),
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // 收藏按钮 - 固定56px宽度
            SizedBox(
              width: 56,
              height: 48,
              child: IconButton(
                onPressed: _toggleFavorite,
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : DesignSystem.getTextSecondary(context),
                  size: 24,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            const SizedBox(width: 12),
            // 下载按钮 - 固定120px宽度
            SizedBox(
              width: 120,
              height: 48,
              child: OutlinedButton(
                onPressed: _isDownloading ? null : _downloadTrail,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _isDownloading 
                      ? DesignSystem.getPrimary(context)
                      : DesignSystem.getTextPrimary(context),
                  side: BorderSide(
                    color: _isDownloading 
                        ? DesignSystem.getPrimary(context)
                        : DesignSystem.getDivider(context),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isDownloading)
                      SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: _downloadProgress > 0 ? _downloadProgress : null,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            DesignSystem.getPrimary(context),
                          ),
                        ),
                      )
                    else
                      Icon(
                        Icons.download_outlined,
                        size: 20,
                        color: DesignSystem.getTextSecondary(context),
                      ),
                    const SizedBox(width: 4),
                    Text(
                      _isDownloading 
                          ? '${(_downloadProgress * 100).toInt()}%'
                          : '下载路线',
                      style: TextStyle(
                        fontSize: 14,
                        color: _isDownloading
                            ? DesignSystem.getPrimary(context)
                            : DesignSystem.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 开始导航按钮 - flex填充剩余空间
            Expanded(
              child: SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startNavigation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: DesignSystem.getPrimary(context),
                    foregroundColor: DesignSystem.getTextInverse(context),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const AppLoadingSmall()
                      : const Text(
                          '开始导航',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建空状态
  Widget _buildEmptyState() {
    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      body: AppError(
        message: '路线不存在或已下架',
        icon: Icons.map_outlined,
        onRetry: () => Navigator.pop(context),
        retryText: '返回',
      ),
    );
  }
}

/// TabBar 吸顶委托
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _TabBarDelegate({required this.child});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  double get maxExtent => 48;

  @override
  double get minExtent => 48;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}