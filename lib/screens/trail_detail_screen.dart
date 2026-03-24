import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:amap_flutter_base/amap_flutter_base.dart';
import '../analytics/analytics.dart';
import '../widgets/app_error.dart';
import '../widgets/app_loading.dart';
import '../constants/design_system.dart';
import '../services/favorite_service.dart';
import '../services/api_client.dart';
import '../services/weather_service.dart';
import '../widgets/share_poster.dart';
import '../widgets/safety/safety_tip_card.dart';
import '../widgets/safety/weather_alert_card.dart';
import '../widgets/safety/pre_departure_checklist.dart';
import 'navigation_screen.dart';

/// 路线详情页
/// 显示路线封面、基本信息、简介和导航入口
/// P2安全功能：天气预警、路线难度提示、安全提示卡片
class TrailDetailScreen extends StatefulWidget {
  final Map<String, dynamic>? trailData;

  const TrailDetailScreen({Key? key, this.trailData}) : super(key: key);

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen>
    with SingleTickerProviderStateMixin, AnalyticsMixin {
  bool _isFavorite = false;
  bool _isLoading = false;
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  bool _isTogglingFavorite = false;
  late TabController _tabController;

  // P2安全功能相关
  final WeatherService _weatherService = WeatherService();
  WeatherData? _weatherData;
  List<WeatherAlert> _weatherAlerts = [];
  bool _isLoadingWeather = false;
  List<Map<String, dynamic>> _userHistory = []; // 用户历史记录

  // 埋点相关
  @override
  String get pageId => PageEvents.pageTrailDetail;

  @override
  String get pageName => PageEvents.nameTrailDetail;

  @override
  Map<String, dynamic>? get pageParams => {
        if (_trailData['id'] != null) 'route_id': _trailData['id'],
        if (_trailData['name'] != null) 'route_name': _trailData['name'],
      };

  // 收藏服务
  final FavoriteService _favoriteService = FavoriteService();

  /// 获取路线数据（优先使用传递的数据，添加防御性校验）
  Map<String, dynamic> get _trailData {
    final data = widget.trailData;
    
    if (data == null) {
      return _getDefaultTrailData();
    }
    
    // 防御性复制，确保所有必需字段存在且类型正确
    return {
      'id': data['id']?.toString() ?? 'trail_unknown',
      'name': data['name']?.toString() ?? '未知路线',
      'difficulty': _normalizeDifficulty(data['difficulty']),
      'difficultyLevel': data['difficultyLevel'] ?? _getDifficultyLevelFromString(data['difficulty']),
      'distance': (data['distance'] as num?)?.toDouble() ?? 5.0,
      'duration': data['duration'] as int? ?? 120,
      'elevation': (data['elevation'] as num?)?.toInt() ?? 0,
      'description': data['description']?.toString() ?? '暂无路线描述',
      'coverUrl': data['coverUrl']?.toString() ?? data['coverImage']?.toString() ?? data['previewImage']?.toString() ?? '',
      'isFavorite': data['isFavorite'] as bool? ?? false,
      'coordinates': data['coordinates'] as List<dynamic>? ?? [],
      'parkingLots': data['parkingLots'] as List<dynamic>? ?? [],
    };
  }

  /// 默认路线数据
  Map<String, dynamic> _getDefaultTrailData() => {
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
    'coordinates': [],
    'parkingLots': [],
  };

  /// 标准化难度值（统一为中文）
  String _normalizeDifficulty(dynamic difficulty) {
    final d = difficulty?.toString().toLowerCase() ?? '';
    switch (d) {
      case '简单':
      case 'easy':
        return '简单';
      case '中等':
      case 'medium':
      case '中等难度':
        return '中等';
      case '困难':
      case 'hard':
      case '高难度':
        return '困难';
      default:
        return '简单';
    }
  }

  /// 从难度字符串获取等级数值
  int _getDifficultyLevelFromString(dynamic difficulty) {
    final d = difficulty?.toString().toLowerCase() ?? '';
    switch (d) {
      case '简单':
      case 'easy':
        return 1;
      case '中等':
      case 'medium':
        return 3;
      case '困难':
      case 'hard':
        return 5;
      default:
        return 1;
    }
  }

  @override
  void initState() {
    super.initState();
    _isFavorite = _trailData['isFavorite'] ?? false;
    _tabController = TabController(length: 4, vsync: this);
    
    // P2: 加载天气数据
    _loadWeatherData();
    // P2: 加载用户历史（用于个性化难度提示）
    _loadUserHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// P2: 加载天气数据
  Future<void> _loadWeatherData() async {
    setState(() {
      _isLoadingWeather = true;
    });

    try {
      // 从路线数据中获取坐标（如果有）
      final coordinates = _trailData['coordinates'] as List<dynamic>?;
      double latitude = 30.2741; // 默认杭州
      double longitude = 120.1551;
      
      if (coordinates != null && coordinates.isNotEmpty) {
        final firstCoord = coordinates[0] as List<dynamic>?;
        if (firstCoord != null && firstCoord.length >= 2) {
          // 坐标格式 [longitude, latitude]
          latitude = firstCoord[1].toDouble();
          longitude = firstCoord[0].toDouble();
        }
      }

      final weather = await _weatherService.getCurrentWeather(
        latitude: latitude,
        longitude: longitude,
      );

      final alerts = _weatherService.checkSevereWeather(weather);

      if (mounted) {
        setState(() {
          _weatherData = weather;
          _weatherAlerts = alerts;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  /// P2: 刷新天气数据
  Future<void> _refreshWeather() async {
    _weatherService.clearCache();
    await _loadWeatherData();
  }

  /// P2: 加载用户历史记录（模拟）
  Future<void> _loadUserHistory() async {
    // 实际项目中从本地存储或API获取
    // 这里使用模拟数据
    _userHistory = [];
  }

  /// P2: 检查是否为首次尝试此难度
  bool get _isFirstHighDifficultyAttempt {
    if (_userHistory.isEmpty) return false;
    final currentLevel = _trailData['difficultyLevel'] as int? ?? 1;
    if (currentLevel < 3) return false;
    
    final maxCompletedLevel = _userHistory
        .where((h) => h['completed'] == true)
        .map((h) => h['difficultyLevel'] as int? ?? 1)
        .fold(0, (prev, curr) => curr > prev ? curr : prev);
    
    return currentLevel > maxCompletedLevel;
  }

  /// 切换收藏状态
  Future<void> _toggleFavorite() async {
    if (_isTogglingFavorite) return;

    final trailId = _trailData['id']?.toString();
    if (trailId == null || trailId.isEmpty) {
      _showErrorSnackBar('路线ID无效');
      return;
    }

    setState(() {
      _isTogglingFavorite = true;
    });

    try {
      final result = await _favoriteService.toggleFavorite(trailId);

      if (mounted) {
        setState(() {
          _isFavorite = result.isFavorited;
          _isTogglingFavorite = false;
        });

        _showSuccessSnackBar(result.message);

        // 上报收藏事件
        AnalyticsService().trackEvent(
          TrailEvents.trailFavorite,
          params: {
            TrailEvents.paramRouteId: trailId,
            TrailEvents.paramRouteName: _trailData['name'] ?? '',
            TrailEvents.paramFavoriteAction: result.isFavorited ? 'add' : 'remove',
          },
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
        _showErrorSnackBar(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isTogglingFavorite = false;
        });
        _showErrorSnackBar('操作失败，请稍后重试');
      }
    }
  }

  /// 显示成功提示
  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: DesignSystem.getSuccess(context),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 显示错误提示
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 20),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: DesignSystem.getError(context),
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// P2: 开始导航（带检查清单）
  void _startNavigation() async {
    final trailName = _trailData['name']?.toString() ?? '未知路线';
    final trailId = _trailData['id']?.toString() ?? '';
    
    // P2: 显示出发前检查清单
    final confirmed = await PreDepartureChecklistDialog.show(
      context: context,
      onConfirm: () {
        _proceedToNavigation(trailName, trailId);
      },
    );

    if (confirmed) {
      // 检查清单已确认，继续导航
      _proceedToNavigation(trailName, trailId);
    }
  }

  /// P2: 继续导航流程（新流程：预览 -> 确认 -> 导航）
  void _proceedToNavigation(String trailName, String trailId) {
    debugPrint('🧭 开始导航: $trailName (ID: $trailId)');
    
    // 提取轨迹点
    List<LatLng>? routePoints;
    LatLng? routeStartPoint;
    final coordinates = _trailData['coordinates'];
    
    debugPrint('🗺️ === trail_detail_screen 提取路线坐标 ===');
    debugPrint('🗺️ 路线ID: $trailId, 名称: $trailName');
    debugPrint('🗺️ coordinates 是否为null: ${coordinates == null}');
    debugPrint('🗺️ coordinates 类型: ${coordinates?.runtimeType}');
    
    if (coordinates != null && coordinates is List) {
      debugPrint('🗺️ coordinates 长度: ${coordinates.length}');
      routePoints = coordinates.map((coord) {
        if (coord is List && coord.length >= 2) {
          final lat = coord[1].toDouble(); // 纬度
          final lng = coord[0].toDouble(); // 经度
          debugPrint('🗺️   原始坐标: [$lng, $lat] -> LatLng($lat, $lng)');
          final latLng = LatLng(lat, lng);
          return latLng;
        } else {
          debugPrint('🗺️   ⚠️ 坐标格式无效: $coord');
        }
        return null;
      }).whereType<LatLng>().toList();
      
      debugPrint('🗺️ 提取后的 routePoints 长度: ${routePoints?.length ?? 0}');
      
      // 提取路线起点
      if (routePoints.isNotEmpty) {
        routeStartPoint = routePoints.first;
        debugPrint('🗺️ 路线起点: 纬度=${routeStartPoint.latitude}, 经度=${routeStartPoint.longitude}');
      } else {
        debugPrint('🗺️ ⚠️ 警告: 提取的 routePoints 为空！');
      }
    } else {
      debugPrint('🗺️ ⚠️ 警告: coordinates 数据无效或为空');
    }
    
    debugPrint('🗺️ === 坐标提取完成 ===');
    
    // 上报导航开始事件
    AnalyticsService().trackEvent(
      TrailEvents.trailNavigateStart,
      params: {
        TrailEvents.paramRouteId: trailId,
        TrailEvents.paramRouteName: trailName,
        TrailEvents.paramSource: 'trail_detail',
      },
    );
    
    AnalyticsService().trackEvent(
      NavigationEvents.navigationStart,
      params: {
        NavigationEvents.paramRouteId: trailId,
        NavigationEvents.paramRouteName: trailName,
      },
    );
    
    // 新导航流程：进入预览模式
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NavigationScreen(
          routeName: trailName,
          routePoints: routePoints,
          routeStartPoint: routeStartPoint,
        ),
      ),
    );
  }

  /// 下载路线
  void _downloadTrail() {
    if (_isDownloading) return;
    
    final trailId = _trailData['id']?.toString() ?? '';
    final trailName = _trailData['name']?.toString() ?? '';
    
    AnalyticsService().trackEvent(
      TrailEvents.trailDownload,
      params: {
        TrailEvents.paramRouteId: trailId,
        TrailEvents.paramRouteName: trailName,
        'start_time': DateTime.now().millisecondsSinceEpoch,
      },
    );
    
    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });
    
    _showDownloadSnackBar();
    _simulateDownload();
  }
  
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
                onPressed: () {},
              )
            : null,
      ),
    );
  }
  
  void _simulateDownload() {
    const totalSteps = 20;
    var currentStep = 0;
    
    Timer.periodic(const Duration(milliseconds: 200), (timer) {
      currentStep++;
      setState(() {
        _downloadProgress = currentStep / totalSteps;
      });
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      _showDownloadSnackBar();
      
      if (currentStep >= totalSteps) {
        timer.cancel();
        setState(() {
          _isDownloading = false;
        });
        
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

  /// 显示分享弹窗
  void _showShareDialog() {
    final posterData = PosterData(
      routeName: _trailData['name'] ?? '未知路线',
      routeCoverUrl: _trailData['coverUrl'],
      distance: (_trailData['distance'] ?? 0).toDouble(),
      duration: (_trailData['duration'] ?? 0) / 60,
      elevation: _trailData['elevation'] ?? 0,
      difficulty: _trailData['difficulty'] ?? '未知',
      location: '杭州',
      routeId: _trailData['id']?.toString() ?? '',
    );
    
    AnalyticsService().trackEvent(
      TrailEvents.trailShare,
      params: {
        TrailEvents.paramRouteId: _trailData['id']?.toString() ?? '',
        TrailEvents.paramRouteName: _trailData['name'] ?? '',
      },
    );
    
    showShareDialog(context, posterData);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.trailData == null) {
      return _buildEmptyState();
    }

    return Scaffold(
      backgroundColor: DesignSystem.getBackground(context),
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverToBoxAdapter(
                child: _buildCoverImage(context),
              ),
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
              _buildIntroductionTab(),
              _buildTrackTab(),
              _buildReviewTab(),
              _buildGuideTab(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButton(context),
    );
  }

  Widget _buildCoverImage(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 240,
          width: double.infinity,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: DesignSystem.getBackgroundTertiary(context),
            image: _trailData['coverUrl'] != null || _trailData['previewImage'] != null
              ? DecorationImage(
                  image: NetworkImage(_trailData['coverUrl'] ?? _trailData['previewImage'] as String),
                  fit: BoxFit.cover,
                )
              : null,
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 80,
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
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          right: 24,
          child: Container(
            decoration: BoxDecoration(
              color: DesignSystem.getBackgroundElevated(context).withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: DesignSystem.getShadowLight(context),
            ),
            child: IconButton(
              onPressed: _showShareDialog,
              icon: Icon(
                Icons.share,
                color: DesignSystem.getTextSecondary(context),
              ),
            ),
          ),
        ),
        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
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

  Widget _buildTitleSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _trailData['name'],
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: DesignSystem.getTextPrimary(context),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Row(
              children: List.generate(5, (index) {
                final difficultyLevel = _trailData['difficultyLevel'] ?? 3;
                return Icon(
                  index < difficultyLevel
                      ? Icons.star
                      : Icons.star_border,
                  color: DesignSystem.getWarning(context),
                  size: 18,
                );
              }),
            ),
            const SizedBox(width: 8),
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
            value: '${_trailData['distance'] ?? 0} km',
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
            value: _formatDuration(_trailData['duration'] ?? 0),
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
            value: '${_trailData['elevation'] ?? 0} m',
            label: '海拔爬升',
          ),
        ],
      ),
    );
  }

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

  /// P2: 简介 Tab - 添加天气预警、难度提示、安全提示
  Widget _buildIntroductionTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // P2: 天气预警卡片
          if (_weatherData != null)
            WeatherAlertCard(
              weather: _weatherData!,
              alerts: _weatherAlerts,
              onRefresh: _refreshWeather,
            ),
          
          // P2: 路线难度提示卡片
          TrailDifficultyCard(
            difficulty: _trailData['difficulty'] ?? '未知',
            difficultyLevel: _trailData['difficultyLevel'] ?? 1,
            isFirstAttempt: _isFirstHighDifficultyAttempt,
          ),
          
          // P2: 安全提示卡片
          SafetyTipCard.fromTrailData(trailData: _trailData),
          
          const SizedBox(height: 24),
          
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
          
          // 适合人群
          _buildSectionTitle('适合人群'),
          const SizedBox(height: 12),
          Text(
            _getSuitableAudience(),
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
              height: 1.8,
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  /// P2: 根据难度获取适合人群说明
  String _getSuitableAudience() {
    final difficultyLevel = _trailData['difficultyLevel'] as int? ?? 1;
    
    switch (difficultyLevel) {
      case 1:
      case 2:
        return '适合所有人群，包括家庭出行、儿童和老人。路况良好，坡度平缓，是入门徒步的绝佳选择。';
      case 3:
        return '适合有一定户外经验的徒步者。需要有基本的体力和耐力，建议携带登山杖。';
      case 4:
      case 5:
        return '适合经验丰富的户外爱好者。需要良好的体能和户外技能，建议结伴而行，充分准备装备。';
      default:
        return '请根据自身情况评估是否适合此路线。如有疑问，建议咨询专业户外人士。';
    }
  }

  Widget _buildTrackTab() {
    final coordinates = _trailData['coordinates'] as List<dynamic>? ?? [];
    
    final trackPoints = coordinates.asMap().entries.map((entry) {
      final index = entry.key;
      final coord = entry.value;
      String name;
      if (index == 0) {
        name = '起点';
      } else if (index == coordinates.length - 1) {
        name = '终点';
      } else {
        name = '途经点 ${index}';
      }
      
      return {
        'name': name,
        'lat': coord[1],
        'lng': coord[0],
        'elevation': 15 + (index * 5),
      };
    }).toList();
    
    if (trackPoints.isEmpty) {
      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('路线轨迹'),
            const SizedBox(height: 32),
            Center(
              child: Column(
                children: [
                  Icon(Icons.map_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    '暂无轨迹数据',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('路线轨迹'),
          const SizedBox(height: 16),
          _buildTrackOverviewCard(),
          const SizedBox(height: 24),
          _buildSectionTitle('途径点'),
          const SizedBox(height: 12),
          ...trackPoints.asMap().entries.map((entry) {
            final index = entry.key;
            final point = entry.value;
            final isLast = index == trackPoints.length - 1;
            return _buildTrackPointItem(
              name: point['name'] as String? ?? '途经点',
              elevation: point['elevation'] as int? ?? 0,
              isFirst: index == 0,
              isLast: isLast,
              index: index + 1,
            );
          }).toList(),
          const SizedBox(height: 24),
          _buildSectionTitle('海拔剖面'),
          const SizedBox(height: 12),
          _buildElevationChart(trackPoints),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTrackOverviewCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTrackStatItem('总距离', '${_trailData['distance'] ?? 0} km', Icons.straighten),
          _buildTrackStatItem('总爬升', '${_trailData['elevation'] ?? 0} m', Icons.trending_up),
          _buildTrackStatItem('轨迹点', '7个', Icons.place),
        ],
      ),
    );
  }

  Widget _buildTrackStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: DesignSystem.getPrimary(context), size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: DesignSystem.getTextPrimary(context),
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

  Widget _buildTrackPointItem({
    required String name,
    required int elevation,
    required bool isFirst,
    required bool isLast,
    required int index,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: isFirst
                    ? DesignSystem.getSuccess(context)
                    : isLast
                        ? DesignSystem.getError(context)
                        : DesignSystem.getPrimary(context),
                shape: BoxShape.circle,
                border: Border.all(
                  color: DesignSystem.getBackgroundElevated(context),
                  width: 2,
                ),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 50,
                color: DesignSystem.getDivider(context),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: DesignSystem.getTextPrimary(context),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.trending_up,
                      size: 14,
                      color: DesignSystem.getTextSecondary(context),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '海拔 $elevation m',
                      style: TextStyle(
                        fontSize: 13,
                        color: DesignSystem.getTextSecondary(context),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildElevationChart(List<Map<String, dynamic>> points) {
    final maxElevation = points.map((p) => p['elevation'] as int? ?? 0).reduce((a, b) => a > b ? a : b);
    
    return Container(
      height: 120,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: points.map((point) {
          final elevation = point['elevation'] as int? ?? 0;
          final heightRatio = maxElevation > 0 ? (elevation / maxElevation).toDouble() : 0.0;
          
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${elevation}m',
                style: TextStyle(
                  fontSize: 10,
                  color: DesignSystem.getTextSecondary(context),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 60 * heightRatio,
                decoration: BoxDecoration(
                  color: DesignSystem.getPrimary(context).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReviewTab() {
    final reviews = [
      {
        'userName': '户外探险家',
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=1',
        'rating': 5.0,
        'date': '2026-03-10',
        'content': '风景非常优美，路况也很好，适合周末徒步。龙井村的茶叶很香，十里琅珰的视野特别开阔！',
        'images': ['https://picsum.photos/seed/r1/100/100'],
      },
      {
        'userName': '杭州漫步者',
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=2',
        'rating': 4.5,
        'date': '2026-03-08',
        'content': '整体体验不错，但是周末人比较多。建议大家早点出发，避开人流高峰。',
        'images': [],
      },
      {
        'userName': '摄影爱好者',
        'avatar': 'https://api.dicebear.com/7.x/avataaars/svg?seed=3',
        'rating': 5.0,
        'date': '2026-03-05',
        'content': '拍照圣地！九溪烟树的雾气特别出片，建议雨后去，效果更好。',
        'images': [
          'https://picsum.photos/seed/r3a/100/100',
          'https://picsum.photos/seed/r3b/100/100',
        ],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReviewOverview(),
          const SizedBox(height: 24),
          _buildSectionTitle('用户评价 (${reviews.length})'),
          const SizedBox(height: 12),
          ...reviews.map((review) => _buildReviewItem(review)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReviewOverview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundSecondary(context),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                '4.8',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: DesignSystem.getPrimary(context),
                ),
              ),
              Row(
                children: List.generate(5, (i) {
                  return Icon(
                    i < 4 ? Icons.star : Icons.star_half,
                    color: DesignSystem.getWarning(context),
                    size: 16,
                  );
                }),
              ),
              const SizedBox(height: 4),
              Text(
                '基于 128 条评价',
                style: TextStyle(
                  fontSize: 12,
                  color: DesignSystem.getTextSecondary(context),
                ),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              children: [
                _buildRatingBar(5, 0.7),
                _buildRatingBar(4, 0.2),
                _buildRatingBar(3, 0.08),
                _buildRatingBar(2, 0.02),
                _buildRatingBar(1, 0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int star, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star',
            style: TextStyle(
              fontSize: 12,
              color: DesignSystem.getTextSecondary(context),
            ),
          ),
          const SizedBox(width: 4),
          Icon(Icons.star, size: 12, color: DesignSystem.getTextTertiary(context)),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: DesignSystem.getDivider(context),
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: DesignSystem.getWarning(context),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Map<String, dynamic> review) {
    final images = review['images'] as List<dynamic>;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: DesignSystem.getBackgroundTertiary(context),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: DesignSystem.getTextTertiary(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review['userName'] as String? ?? '匿名用户',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: DesignSystem.getTextPrimary(context),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        ...List.generate(5, (i) {
                          final rating = review['rating'] as double? ?? 5.0;
                          return Icon(
                            i < rating.floor()
                                ? Icons.star
                                : i < rating
                                    ? Icons.star_half
                                    : Icons.star_border,
                            color: DesignSystem.getWarning(context),
                            size: 14,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text(
                          review['date'] as String? ?? '',
                          style: TextStyle(
                            fontSize: 12,
                            color: DesignSystem.getTextTertiary(context),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['content'] as String? ?? '',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
              height: 1.6,
            ),
          ),
          if (images.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: images.map((url) {
                return Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: DesignSystem.getBackgroundTertiary(context),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.image,
                    color: DesignSystem.getTextTertiary(context),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGuideTab() {
    final parkingLots = _trailData['parkingLots'] as List<dynamic>?;
    
    final guides = [
      {
        'title': '最佳徒步时间',
        'icon': Icons.wb_sunny,
        'content': '春季（3-5月）和秋季（9-11月）是最佳徒步季节。春季可欣赏茶园新绿，秋季天气凉爽宜人。建议早上8点前出发，避开正午高温。',
      },
      {
        'title': '装备建议',
        'icon': Icons.backpack,
        'content': '\u2022 舒适的运动鞋或登山鞋\n\u2022 轻便背包（建议15-20L）\n\u2022 防晒用品：帽子、太阳镜、防晒霜\n\u2022 充足的水（建议每人1.5L）\n\u2022 简易干粮和能量棒\n\u2022 雨具（山区天气多变）',
      },
      {
        'title': '交通指南',
        'icon': Icons.directions_bus,
        'content': '公交：乘坐27路、87路至龙井村站下车\n自驾：导航至"龙井村停车场"，停车费10元/小时\n地铁：乘1号线至凤起路站，转乘公交27路',
      },
      {
        'title': '停车场信息',
        'icon': Icons.local_parking,
        'content': parkingLots != null && parkingLots.isNotEmpty
            ? parkingLots.map((p) => '\u2022 ${p['name']}').join('\n')
            : '暂无停车场信息',
      },
      {
        'title': '注意事项',
        'icon': Icons.warning_amber,
        'content': '\u2022 十里琅珰段坡度较陡，请量力而行\n\u2022 龙井村有补给点，可购买水和食物\n\u2022 保护环境，不要乱扔垃圾\n\u2022 雨天路滑，建议改期\n\u2022 带小孩的家庭请注意看护',
      },
      {
        'title': '周边推荐',
        'icon': Icons.place,
        'content': '\u2022 龙井村：品尝正宗龙井茶\n\u2022 灵隐寺：千年古刹，值得一游\n\u2022 云栖竹径：竹林幽深，避暑胜地\n\u2022 梅家坞：茶文化体验',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('徒步攻略'),
          const SizedBox(height: 16),
          ...guides.map((guide) => _buildGuideItem(guide)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGuideItem(Map<String, dynamic> guide) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.getBackgroundElevated(context),
        borderRadius: BorderRadius.circular(12),
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                guide['icon'] as IconData,
                color: DesignSystem.getPrimary(context),
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                guide['title'] as String? ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: DesignSystem.getTextPrimary(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            guide['content'] as String? ?? '',
            style: TextStyle(
              fontSize: 14,
              color: DesignSystem.getTextSecondary(context),
              height: 1.8,
            ),
          ),
        ],
      ),
    );
  }

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

  String _formatDuration(dynamic duration) {
    if (duration == null) return '--';
    
    final minutes = duration is int ? duration : int.tryParse(duration.toString()) ?? 0;
    
    if (minutes < 60) {
      return '$minutes 分钟';
    } else {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours 小时';
      } else {
        return '$hours 小时 $remainingMinutes 分钟';
      }
    }
  }
}

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
