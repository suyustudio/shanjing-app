import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/filter_tags.dart';
import '../widgets/route_card.dart';
import '../widgets/app_app_bar.dart';
import '../widgets/app_loading.dart';
import '../widgets/app_error.dart';
import 'trail_detail_screen.dart';

/// 页面切换动画 - FadeTransition
class FadePageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;

  FadePageRoute({required this.child})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => child,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
}

/// 发现页 - 路线探索主页面
class DiscoveryScreen extends StatefulWidget {
  const DiscoveryScreen({super.key});

  @override
  State<DiscoveryScreen> createState() => _DiscoveryScreenState();
}

class _DiscoveryScreenState extends State<DiscoveryScreen> with TickerProviderStateMixin {
  String _selectedTag = '全部';
  String _searchQuery = '';
  List<Map<String, dynamic>> _trails = [];
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timeoutTimer;
  Timer? _debounceTimer;
  
  // 列表动画控制器
  late AnimationController _listAnimController;
  late List<Animation<double>> _fadeAnimations;

  /// 初始化列表渐显动画
  void _initListAnimations() {
    final count = _filteredTrails.length;
    _fadeAnimations = List.generate(count, (index) {
      final start = index * 0.1;
      final end = start + 0.5;
      return Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _listAnimController,
          curve: Interval(
            start.clamp(0, 1),
            end.clamp(0, 1),
            curve: Curves.easeOut,
          ),
        ),
      );
    });
  }

  /// 难度映射
  String _getDifficultyText(String difficulty) {
    switch (difficulty) {
      case 'easy':
        return '简单';
      case 'moderate':
        return '中等';
      case 'hard':
        return '困难';
      default:
        return '简单';
    }
  }

  /// 从JSON加载真实数据
  Future<void> _loadTrails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // 10秒超时
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
          _errorMessage = '加载超时，请重试';
        });
      }
    });

    try {
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('data/json/trails-all.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      final List<dynamic> trailsList = jsonData['trails'] ?? [];
      
      _timeoutTimer?.cancel();
      
      if (mounted) {
        setState(() {
          _trails = trailsList.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoading = false;
        });
        // 初始化并启动列表动画
        _initListAnimations();
        _listAnimController.forward();
      }
    } on SocketException catch (_) {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() {
          _errorMessage = '网络连接失败，请检查网络';
          _isLoading = false;
        });
      }
    } catch (e) {
      _timeoutTimer?.cancel();
      if (mounted) {
        setState(() {
          _errorMessage = '数据加载失败';
          _isLoading = false;
        });
      }
    }
  }

  /// 获取筛选后的路线列表
  List<Map<String, dynamic>> get _filteredTrails {
    return _trails.where((trail) {
      // 搜索过滤
      final name = trail['name']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      final matchesSearch = _searchQuery.isEmpty || name.contains(query);
      
      // 难度筛选
      final difficulty = trail['difficulty']?.toString() ?? 'easy';
      String difficultyText = _getDifficultyText(difficulty);
      final matchesTag = _selectedTag == '全部' || difficultyText == _selectedTag;
      
      return matchesSearch && matchesTag;
    }).toList();
  }

  /// 处理搜索（带防抖）
  void _onSearch(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
      });
      // 重新触发动画
      _listAnimController.reset();
      _initListAnimations();
      _listAnimController.forward();
    });
  }

  /// 处理标签选择
  void _onTagSelect(String tag) {
    setState(() {
      _selectedTag = tag;
    });
    // 重新触发动画
    _listAnimController.reset();
    _initListAnimations();
    _listAnimController.forward();
  }

  @override
  void initState() {
    super.initState();
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTrails();
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _debounceTimer?.cancel();
    _listAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredTrails = _filteredTrails;
    
    return Scaffold(
      appBar: const AppAppBar(
        title: '发现',
      ),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.all(16),
            child: SearchBar(
              hintText: '搜索路线',
              onSearch: _onSearch,
            ),
          ),

          // 筛选标签
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: FilterTags(
              selectedTag: _selectedTag,
              onSelect: _onTagSelect,
            ),
          ),

          const SizedBox(height: 16),

          // 路线卡片列表
          Expanded(
            child: _isLoading
                ? const AppLoading()
                : _errorMessage != null
                    ? AppError(
                        message: _errorMessage!,
                        onRetry: _loadTrails,
                      )
                    : filteredTrails.isEmpty
                        ? const AppEmpty(message: '暂无符合条件的路线')
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredTrails.length,
                            itemBuilder: (context, index) {
                              final trail = filteredTrails[index];
                              final distance = trail['distance'] ?? 0;
                              final duration = trail['duration'] ?? 0;
                              final difficulty = trail['difficulty'] ?? 'easy';
                              
                              return AnimatedBuilder(
                                animation: _fadeAnimations[index],
                                builder: (context, child) {
                                  return FadeTransition(
                                    opacity: _fadeAnimations[index],
                                    child: child,
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _AnimatedRouteCard(
                                    imageUrl: 'https://picsum.photos/seed/${trail['id']}/200/150',
                                    name: trail['name'] ?? '未知路线',
                                    distance: '$distance km',
                                    duration: '${(duration / 60).toStringAsFixed(1)} 小时',
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        FadePageRoute(
                                          child: TrailDetailScreen(
                                            trailData: trail,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

/// 带动画的路线卡片 - 点击缩放效果
class _AnimatedRouteCard extends StatefulWidget {
  final String imageUrl;
  final String name;
  final String distance;
  final String duration;
  final VoidCallback onTap;

  const _AnimatedRouteCard({
    required this.imageUrl,
    required this.name,
    required this.distance,
    required this.duration,
    required this.onTap,
  });

  @override
  State<_AnimatedRouteCard> createState() => _AnimatedRouteCardState();
}

class _AnimatedRouteCardState extends State<_AnimatedRouteCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _scaleController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _scaleController.reverse().then((_) => widget.onTap());
  }

  void _onTapCancel() {
    _scaleController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: RouteCard(
          imageUrl: widget.imageUrl,
          name: widget.name,
          distance: widget.distance,
          duration: widget.duration,
          onTap: () {}, // 由 GestureDetector 处理
        ),
      ),
    );
  }
}
