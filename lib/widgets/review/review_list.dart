/**
 * 评论列表组件
 * 
 * M6 评论系统 - 评论列表展示
 */

import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import '../../services/review_service.dart';
import 'review_item.dart';
import 'review_skeleton.dart';
import 'review_empty.dart';

/// 评论列表
class ReviewList extends StatefulWidget {
  final String trailId;
  final String? sort;
  final int? rating;
  final VoidCallback? onWriteReview;
  final Function(Review)? onReviewTap;

  const ReviewList({
    Key? key,
    required this.trailId,
    this.sort = 'newest',
    this.rating,
    this.onWriteReview,
    this.onReviewTap,
  }) : super(key: key);

  @override
  State<ReviewList> createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewList> {
  final ReviewService _reviewService = ReviewService();
  
  List<Review> _reviews = [];
  ReviewStats? _stats;
  bool _isLoading = true;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  String? _error;
  int _page = 1;
  static const int _limit = 10;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  @override
  void didUpdateWidget(ReviewList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sort != widget.sort ||
        oldWidget.rating != widget.rating) {
      _refresh();
    }
  }

  /// 刷新评论列表
  Future<void> _refresh() async {
    setState(() {
      _page = 1;
      _reviews = [];
      _hasMore = true;
      _error = null;
    });
    await _loadReviews();
  }

  /// 加载评论
  Future<void> _loadReviews() async {
    if (_isLoading && _page == 1) return;

    setState(() {
      if (_page == 1) {
        _isLoading = true;
      } else {
        _isLoadingMore = true;
      }
      _error = null;
    });

    try {
      final response = await _reviewService.getReviews(
        widget.trailId,
        sort: widget.sort ?? 'newest',
        rating: widget.rating,
        page: _page,
        limit: _limit,
      );

      setState(() {
        if (_page == 1) {
          _reviews = response.list;
        } else {
          _reviews.addAll(response.list);
        }
        _stats = response.stats;
        _hasMore = _reviews.length < response.total;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  /// 加载更多
  Future<void> _loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    
    setState(() {
      _page++;
    });
    await _loadReviews();
  }

  /// 处理点赞
  Future<void> _handleLike(Review review, int index) async {
    try {
      final result = await _reviewService.likeReview(review.id);
      
      setState(() {
        _reviews[index] = review.copyWith(
          isLiked: result.isLiked,
          likeCount: result.likeCount,
        );
      });
    } catch (e) {
      // 显示错误提示
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('操作失败，请重试')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ReviewSkeleton();
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_reviews.isEmpty) {
      return ReviewEmpty(onWriteReview: widget.onWriteReview);
    }

    return RefreshIndicator(
      onRefresh: _refresh,
      color: Color(0xFF2D968A),
      child: CustomScrollView(
        slivers: [
          // 统计头部
          if (_stats != null)
            SliverToBoxAdapter(
              child: _buildStatsHeader(),
            ),
          
          // 评论列表
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= _reviews.length) {
                  if (_hasMore) {
                    _loadMore();
                    return _buildLoadMoreIndicator();
                  }
                  return SizedBox.shrink();
                }

                final review = _reviews[index];
                return ReviewItem(
                  review: review,
                  onLike: () => _handleLike(review, index),
                  onReply: () {
                    // 打开回复输入
                  },
                  onExpand: () {
                    widget.onReviewTap?.call(review);
                  },
                  onImageTap: (url) {
                    // 打开图片查看器
                    _showPhotoViewer(review.photos, url);
                  },
                );
              },
              childCount: _reviews.length + (_hasMore ? 1 : 0),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建统计头部
  Widget _buildStatsHeader() {
    if (_stats == null) return SizedBox.shrink();

    final distribution = _stats!.getRatingDistribution();

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // 平均评分
          Column(
            children: [
              Text(
                _stats!.avgRating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < _stats!.avgRating.round()
                        ? Icons.star
                        : Icons.star_border,
                    size: 16,
                    color: Color(0xFFFFB800),
                  );
                }),
              ),
              SizedBox(height: 4),
              Text(
                '${_stats!.totalCount}条评价',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9CA3AF),
                ),
              ),
            ],
          ),
          
          SizedBox(width: 24),
          
          // 评分分布
          Expanded(
            child: Column(
              children: [5, 4, 3, 2, 1].map((star) {
                final percentage = (distribution[star] ?? 0) * 100;
                return _buildRatingBar(star, percentage);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建评分条
  Widget _buildRatingBar(int star, double percentage) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star星',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFFFB800),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建加载更多指示器
  Widget _buildLoadMoreIndicator() {
    return Container(
      padding: EdgeInsets.all(16),
      alignment: Alignment.center,
      child: SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2D968A)),
        ),
      ),
    );
  }

  /// 构建错误 widget
  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48,
            color: Color(0xFF9CA3AF),
          ),
          SizedBox(height: 16),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF6B7280),
            ),
          ),
          SizedBox(height: 8),
          TextButton(
            onPressed: _refresh,
            child: Text('重新加载'),
          ),
        ],
      ),
    );
  }

  /// 显示图片查看器
  void _showPhotoViewer(List<String> photos, String initialUrl) {
    final initialIndex = photos.indexOf(initialUrl);
    
    showDialog(
      context: context,
      builder: (context) => PhotoViewer(
        photos: photos,
        initialIndex: initialIndex >= 0 ? initialIndex : 0,
        onClose: () => Navigator.pop(context),
      ),
    );
  }
}

/// 图片查看器
class PhotoViewer extends StatelessWidget {
  final List<String> photos;
  final int initialIndex;
  final VoidCallback onClose;

  const PhotoViewer({
    Key? key,
    required this.photos,
    required this.initialIndex,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black,
        child: PageView.builder(
          controller: PageController(initialPage: initialIndex),
          itemCount: photos.length,
          itemBuilder: (context, index) {
            return Center(
              child: InteractiveViewer(
                minScale: 0.5,
                maxScale: 3.0,
                child: Image.network(
                  photos[index],
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
