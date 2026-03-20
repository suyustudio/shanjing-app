// ================================================================
// M6: 关注/粉丝列表页面
// ================================================================

import 'package:flutter/material.dart';
import '../services/follow_service.dart';
import '../widgets/social/user_card.dart';

/// 列表类型
enum FollowListType {
  following,  // 关注列表
  followers,  // 粉丝列表
}

/// 关注/粉丝列表页面
class FollowListScreen extends StatefulWidget {
  final String userId;
  final String? nickname;
  final FollowListType type;

  const FollowListScreen({
    Key? key,
    required this.userId,
    this.nickname,
    required this.type,
  }) : super(key: key);

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTab = 0;

  @override
  void initState() {
    super.initState();
    _currentTab = widget.type == FollowListType.following ? 0 : 1;
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: _currentTab,
    );
    _tabController.addListener(() {
      setState(() {
        _currentTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.nickname != null
        ? '${widget.nickname}的关注'
        : '关注/粉丝';

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: '关注'),
            Tab(text: '粉丝'),
          ],
          indicatorColor: Theme.of(context).primaryColor,
          labelColor: Theme.of(context).primaryColor,
          unselectedLabelColor: Colors.grey[600],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 关注列表
          _FollowListView(
            userId: widget.userId,
            type: FollowListType.following,
            key: ValueKey('following_${widget.userId}'),
          ),
          // 粉丝列表
          _FollowListView(
            userId: widget.userId,
            type: FollowListType.followers,
            key: ValueKey('followers_${widget.userId}'),
          ),
        ],
      ),
    );
  }
}

/// 用户列表视图
class _FollowListView extends StatefulWidget {
  final String userId;
  final FollowListType type;

  const _FollowListView({
    Key? key,
    required this.userId,
    required this.type,
  }) : super(key: key);

  @override
  State<_FollowListView> createState() => _FollowListViewState();
}

class _FollowListViewState extends State<_FollowListView> {
  final List<FollowUser> _users = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _cursor;
  String? _error;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (!_isLoading && _hasMore) {
        _loadMore();
      }
    }
  }

  Future<void> _loadData() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = widget.type == FollowListType.following
          ? await FollowService.instance.getFollowing(widget.userId)
          : await FollowService.instance.getFollowers(widget.userId);

      setState(() {
        _users.clear();
        _users.addAll(result.list);
        _hasMore = result.hasMore;
        _cursor = result.nextCursor;
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

  Future<void> _loadMore() async {
    if (_isLoading || !_hasMore || _cursor == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = widget.type == FollowListType.following
          ? await FollowService.instance.getFollowing(
              widget.userId,
              cursor: _cursor,
            )
          : await FollowService.instance.getFollowers(
              widget.userId,
              cursor: _cursor,
            );

      setState(() {
        _users.addAll(result.list);
        _hasMore = result.hasMore;
        _cursor = result.nextCursor;
      });
    } catch (e) {
      // 加载更多失败不显示错误，只停止加载
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null && _users.isEmpty) {
      return _buildErrorView();
    }

    if (_users.isEmpty && !_isLoading) {
      return _buildEmptyView();
    }

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        controller: _scrollController,
        itemCount: _users.length + (_hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _users.length) {
            return _buildLoadingIndicator();
          }

          final user = _users[index];
          return UserCard(
            user: user,
            onTap: () {
              // 跳转到用户主页
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => UserProfileScreen(userId: user.id),
              //   ),
              // );
            },
            onFollowChanged: () {
              // 刷新列表
              _loadData();
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.type == FollowListType.following
                ? Icons.person_add_outlined
                : Icons.people_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            widget.type == FollowListType.following
                ? '还没有关注任何人'
                : '还没有粉丝',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
          SizedBox(height: 8),
          Text(
            widget.type == FollowListType.following
                ? '去发现更多有趣的人吧'
                : '分享精彩内容，获得更多关注',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          if (widget.type == FollowListType.following) ...[
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                // 跳转到推荐关注页面
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowSuggestionsScreen(),
                  ),
                );
              },
              child: Text('发现用户'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _error!,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadData,
            child: Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: CircularProgressIndicator(),
    );
  }
}

/// 推荐关注页面
class FollowSuggestionsScreen extends StatefulWidget {
  @override
  _FollowSuggestionsScreenState createState() => _FollowSuggestionsScreenState();
}

class _FollowSuggestionsScreenState extends State<FollowSuggestionsScreen> {
  List<FollowUser> _suggestions = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuggestions();
  }

  Future<void> _loadSuggestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final result = await FollowService.instance.getSuggestions(limit: 20);
      setState(() {
        _suggestions = result.list;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('推荐关注'),
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildErrorView()
              : _suggestions.isEmpty
                  ? _buildEmptyView()
                  : RefreshIndicator(
                      onRefresh: _loadSuggestions,
                      child: ListView.builder(
                        itemCount: _suggestions.length,
                        itemBuilder: (context, index) {
                          final user = _suggestions[index];
                          return UserCard(
                            user: user,
                            onFollowChanged: () {
                              _loadSuggestions();
                            },
                          );
                        },
                      ),
                    ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            '暂无推荐',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red[300],
          ),
          SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadSuggestions,
            child: Text('重试'),
          ),
        ],
      ),
    );
  }
}
