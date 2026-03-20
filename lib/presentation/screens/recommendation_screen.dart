// ============================================
// 为你推荐页面
// ============================================

import 'package:flutter/material.dart';
import 'dart:async';
import '../../models/recommendation_model.dart';
import '../../services/recommendation_service.dart';
import '../../services/location_service.dart';
import 'recommendation_card.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  final RecommendationService _recommendationService = RecommendationService();
  final LocationService _locationService = LocationService();
  
  List<RecommendedTrail> _trails = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  String? _errorMessage;
  
  double? _userLat;
  double? _userLng;

  // 曝光追踪相关
  Timer? _impressionDebounceTimer;
  final Set<String> _reportedTrailIds = {};
  static const Duration _impressionDebounceDuration = Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  @override
  void dispose() {
    _impressionDebounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadRecommendations() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 获取用户位置
      final position = await _locationService.getCurrentPosition();
      _userLat = position?.latitude;
      _userLng = position?.longitude;

      // 获取推荐
      final trails = await _recommendationService.getHomeRecommendations(
        limit: 20,
        lat: _userLat,
        lng: _userLng,
      );

      setState(() {
        _trails = trails;
        _isLoading = false;
      });

      // 延迟上报曝光（防抖处理）
      _debouncedReportImpression();
    } catch (e) {
      setState(() {
        _errorMessage = '加载推荐失败，请重试';
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshRecommendations() async {
    setState(() => _isRefreshing = true);

    try {
      final trails = await _recommendationService.refreshRecommendations(
        limit: 20,
        lat: _userLat,
        lng: _userLng,
      );

      setState(() {
        _trails = trails;
        _isRefreshing = false;
      });
    } catch (e) {
      setState(() => _isRefreshing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('刷新失败，请重试')),
      );
    }
  }

  void _onTrailTap(RecommendedTrail trail) {
    // 记录点击
    _recommendationService.trackClick(
      trailId: trail.id,
      logId: _recommendationService.getCachedLogId(),
    );

    // 跳转到路线详情
    Navigator.pushNamed(
      context,
      '/trail-detail',
      arguments: {'trailId': trail.id},
    );
  }

  void _onBookmarkTap(RecommendedTrail trail) {
    // 记录收藏
    _recommendationService.trackBookmark(
      trailId: trail.id,
      logId: _recommendationService.getCachedLogId(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已收藏 ${trail.name}')),
    );
  }

  /// 防抖处理曝光上报
  void _debouncedReportImpression() {
    _impressionDebounceTimer?.cancel();
    _impressionDebounceTimer = Timer(_impressionDebounceDuration, () {
      _reportImpression();
    });
  }

  /// 上报推荐曝光事件
  void _reportImpression() {
    if (_trails.isEmpty) return;

    // 获取可见的路线（前5条）且未上报过的
    final visibleTrails = _trails.take(5).where((trail) {
      return !_reportedTrailIds.contains(trail.id);
    }).toList();

    if (visibleTrails.isEmpty) return;

    final trailIds = visibleTrails.map((t) => t.id).toList();
    final logId = _recommendationService.getCachedLogId();

    // 标记为已上报
    for (final trail in visibleTrails) {
      _reportedTrailIds.add(trail.id);
    }

    // 发送曝光追踪请求
    _recommendationService.trackImpression(
      trailIds: trailIds,
      scene: RecommendationScene.home,
      logId: logId,
    ).then((success) {
      if (success) {
        debugPrint('Impression reported: ${trailIds.length} trails');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('为你推荐'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isRefreshing ? null : _refreshRecommendations,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshRecommendations,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendations,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_trails.isEmpty) {
      return const Center(
        child: Text('暂无推荐路线', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _trails.length,
      itemBuilder: (context, index) {
        final trail = _trails[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildTrailCard(trail),
        );
      },
    );
  }

  Widget _buildTrailCard(RecommendedTrail trail) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onTrailTap(trail),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 图片
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: trail.coverImage.isNotEmpty
                    ? Image.network(
                        trail.coverImage,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Container(color: Colors.grey[300]),
                      )
                    : Container(color: Colors.grey[300]),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 名称和匹配度
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          trail.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getMatchScoreColor(trail.matchScore),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          trail.matchScoreText,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // 推荐理由
                  if (trail.recommendReason != null)
                    Text(
                      trail.recommendReason!,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  
                  const SizedBox(height: 12),
                  
                  // 路线信息
                  Row(
                    children: [
                      _buildInfoChip(Icons.location_on, trail.formattedDistance),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.timer, trail.formattedDuration),
                      const SizedBox(width: 12),
                      _buildInfoChip(Icons.trending_up, trail.difficultyText),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 评分和收藏
                  Row(
                    children: [
                      Icon(Icons.star, size: 16, color: Colors.amber[400]),
                      const SizedBox(width: 4),
                      Text(
                        trail.rating.toStringAsFixed(1),
                        style: const TextStyle(fontSize: 14),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _onBookmarkTap(trail),
                        icon: const Icon(Icons.bookmark_border, size: 18),
                        label: const Text('收藏'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Color _getMatchScoreColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.blue;
  }
}