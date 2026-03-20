// ================================================================
// M6: 用户主页（带关注功能）
// ================================================================

import 'package:flutter/material.dart';
import '../services/follow_service.dart';
import '../widgets/social/follow_button.dart';
import '../screens/social/follow_list_screen.dart';

/// 用户主页屏幕
class UserProfileScreen extends StatefulWidget {
  final String userId;
  final String? nickname;
  final String? avatarUrl;

  const UserProfileScreen({
    Key? key,
    required this.userId,
    this.nickname,
    this.avatarUrl,
  }) : super(key: key);

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  FollowStats? _stats;
  FollowStatus? _status;
  bool _isLoading = true;
  String? _error;

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        FollowService.instance.getFollowStats(widget.userId),
        FollowService.instance.getFollowStatus(widget.userId),
      ]);

      setState(() {
        _stats = results[0] as FollowStats;
        _status = results[1] as FollowStatus;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _onFollowChanged() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            // 顶部导航栏
            SliverAppBar(
              title: Text(widget.nickname ?? '用户主页'),
              centerTitle: true,
              pinned: true,
              expandedHeight: 300,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeader(),
              ),
              bottom: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: '动态'),
                  Tab(text: '照片'),
                  Tab(text: '路线'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // 动态
            _buildActivityTab(),
            // 照片
            _buildPhotosTab(),
            // 路线
            _buildTrailsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
            SizedBox(height: 8),
            Text('加载失败', style: TextStyle(color: Colors.grey[600])),
            TextButton(
              onPressed: _loadData,
              child: Text('重试'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: EdgeInsets.only(top: kToolbarHeight + MediaQuery.of(context).padding.top),
      child: Column(
        children: [
          // 用户信息卡片
          _buildUserInfoCard(),
          // 关注数据
          _buildFollowStats(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      margin: EdgeInsets.all(16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // 头像
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[200],
                  border: Border.all(
                    color: Colors.white,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: widget.avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          widget.avatarUrl!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Icon(
                        Icons.person,
                        size: 40,
                        color: Colors.grey[400],
                      ),
              ),
              SizedBox(width: 16),
              // 用户信息
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.nickname ?? '用户${widget.userId.substring(0, 6)}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '@user${widget.userId.substring(0, 8)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                    SizedBox(height: 8),
                    // 关注按钮
                    if (_status != null)
                      FollowButton(
                        userId: widget.userId,
                        isFollowing: _status!.isFollowing,
                        size: FollowButtonSize.medium,
                        onFollowChanged: _onFollowChanged,
                        showMutual: true,
                        isMutual: _status?.isMutual ?? false,
                      ),
                  ],
                ),
              ),
            ],
          ),
          // 简介
          SizedBox(height: 16),
          Text(
            '热爱山野，记录每一步风景。\n已徒步 128 公里，累计爬升 3200 米',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowStats() {
    if (_stats == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildStatItem(
            '关注',
            _stats!.followingCount.toString(),
            () => _navigateToFollowList(FollowListType.following),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            '粉丝',
            _stats!.followersCount.toString(),
            () => _navigateToFollowList(FollowListType.followers),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey[300],
          ),
          _buildStatItem(
            '获赞',
            '2.3k',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, VoidCallback? onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[900],
                ),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToFollowList(FollowListType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FollowListScreen(
          userId: widget.userId,
          nickname: widget.nickname,
          type: type,
        ),
      ),
    );
  }

  Widget _buildActivityTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildActivityCard(index);
      },
    );
  }

  Widget _buildActivityCard(int index) {
    final activities = [
      {
        'icon': Icons.map,
        'title': '徒步了 九溪十八涧',
        'subtitle': '⭐⭐⭐⭐⭐ 2024-03-15',
        'content': '风景太美了，强烈推荐！',
      },
      {
        'icon': Icons.photo_camera,
        'title': '上传了 3 张照片到 十里琅珰',
        'subtitle': '2024-03-10',
        'content': '',
      },
      {
        'icon': Icons.star,
        'title': '评价了 龙井问茶',
        'subtitle': '⭐⭐⭐⭐⭐ 2024-03-08',
        'content': '茶园风景很棒，适合拍照。',
      },
    ];

    if (index >= activities.length) {
      return SizedBox.shrink();
    }

    final activity = activities[index];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              activity['icon'] as IconData,
              color: Theme.of(context).primaryColor,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['title'] as String,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  activity['subtitle'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                  ),
                ),
                if ((activity['content'] as String).isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text(
                    activity['content'] as String,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
                SizedBox(height: 12),
                // 互动按钮
                Row(
                  children: [
                    _buildActionButton(Icons.favorite_border, '23'),
                    SizedBox(width: 16),
                    _buildActionButton(Icons.chat_bubble_outline, '5'),
                    SizedBox(width: 16),
                    _buildActionButton(Icons.share, ''),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String count) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: Colors.grey[500],
        ),
        if (count.isNotEmpty) ...[
          SizedBox(width: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[500],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPhotosTab() {
    return GridView.builder(
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: 9,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.image,
              color: Colors.grey[400],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrailsTab() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 12),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.terrain,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '路线 ${index + 1}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '⭐ 4.8  |  8.5km',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
