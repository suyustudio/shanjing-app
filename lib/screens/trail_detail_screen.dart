import 'package:flutter/material.dart';
import '../widgets/app_loading.dart';
import 'navigation_screen.dart';

/// 路线详情页
/// 显示路线封面、基本信息、简介和导航入口
class TrailDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? trailData;

  const TrailDetailScreen({Key? key, this.trailData}) : super(key: key);

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen> {
  bool _isFavorite = false;
  bool _isLoading = false;

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
    // TODO: 下载路线
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('开始下载路线...')),
    );
  }

  /// 获取难度颜色
  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case '简单':
        return const Color(0xFF2D968A);
      case '中等':
        return const Color(0xFFFFC107);
      case '困难':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF757575);
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

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 主内容区域
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 封面图区域
                      _buildCoverImage(),
                      
                      // 内容区域
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 路线名称 + 难度标签
                            _buildTitleSection(),
                            
                            const SizedBox(height: 16),
                            
                            // 距离/时长/海拔信息行
                            _buildInfoRow(),
                            
                            const SizedBox(height: 24),
                            
                            // 路线简介
                            _buildDescription(),
                            
                            const SizedBox(height: 24),
                            
                            // TabBar
                            _buildTabBar(),
                          ],
                        ),
                      ),
                      
                      // TabBarView 内容
                      SizedBox(
                        height: 300,
                        child: _buildTabBarView(),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 底部开始导航按钮
              _buildBottomButton(),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建封面图区域
  Widget _buildCoverImage() {
    return Stack(
      children: [
        // 封面图
        Container(
          height: 240,
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey[200],
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
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.grey[700],
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 构建标题区域（路线名称 + 难度标签）
  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 路线名称
        Text(
          _trailData['name'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF212121),
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
                  color: const Color(0xFFFFC107),
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
  Widget _buildInfoRow() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 距离
          _buildInfoItem(
            icon: Icons.location_on_outlined,
            value: '${_trailData['distance']} km',
            label: '距离',
          ),
          
          // 分隔线
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          
          // 时长
          _buildInfoItem(
            icon: Icons.timer_outlined,
            value: _formatDuration(_trailData['duration']),
            label: '时长',
          ),
          
          // 分隔线
          Container(
            height: 40,
            width: 1,
            color: Colors.grey[300],
          ),
          
          // 海拔
          _buildInfoItem(
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
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: const Color(0xFF2D968A),
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 构建 TabBar
  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: const TabBar(
        labelColor: Color(0xFF2D968A),
        unselectedLabelColor: Colors.grey,
        indicatorColor: Color(0xFF2D968A),
        tabs: [
          Tab(text: '轨迹'),
          Tab(text: '评价'),
          Tab(text: '攻略'),
        ],
      ),
    );
  }

  /// 构建 TabBarView
  Widget _buildTabBarView() {
    return const TabBarView(
      children: [
        // 轨迹 Tab
        Center(
          child: Text(
            '轨迹内容',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        // 评价 Tab
        Center(
          child: Text(
            '评价内容',
            style: TextStyle(color: Colors.grey),
          ),
        ),
        // 攻略 Tab
        Center(
          child: Text(
            '攻略内容',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }

  /// 构建路线简介
  Widget _buildDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '路线简介',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212121),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _trailData['description'],
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            height: 1.6,
          ),
          maxLines: 4,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// 构建底部操作栏
  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
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
            // 左侧：收藏按钮
            IconButton(
              onPressed: _toggleFavorite,
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.grey[700],
              ),
            ),
            const SizedBox(width: 8),
            // 中间：开始导航按钮
            Expanded(
              child: SizedBox(
                height: 44,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _startNavigation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2D968A),
                    foregroundColor: Colors.white,
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
            const SizedBox(width: 8),
            // 右侧：下载按钮
            IconButton(
              onPressed: _downloadTrail,
              icon: Icon(
                Icons.download_outlined,
                color: Colors.grey[700],
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
      backgroundColor: Colors.white,
      body: AppError(
        message: '路线不存在或已下架',
        icon: Icons.map_outlined,
        onRetry: () => Navigator.pop(context),
        retryText: '返回',
      ),
    );
  }
}
