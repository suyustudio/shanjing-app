/**
 * 评论系统使用示例
 * 
 * M6 评论组件使用指南
 */

import 'package:flutter/material.dart';
import '../widgets/review/index.dart';
import '../models/review_model.dart';
import '../services/review_service.dart';

/// 示例：路线详情页中的评论列表
class TrailReviewsExample extends StatelessWidget {
  final String trailId;

  const TrailReviewsExample({
    Key? key,
    required this.trailId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 评论列表
        Expanded(
          child: ReviewList(
            trailId: trailId,
            sort: 'newest',  // newest, highest, lowest, hot
            onWriteReview: () {
              // 打开评论输入页面
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WriteReviewScreen(trailId: trailId),
                ),
              );
            },
            onReviewTap: (review) {
              // 进入评论详情页
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewDetailScreen(review: review),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 示例：写评论页面
class WriteReviewScreen extends StatefulWidget {
  final String trailId;

  const WriteReviewScreen({
    Key? key,
    required this.trailId,
  }) : super(key: key);

  @override
  State<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends State<WriteReviewScreen> {
  final ReviewService _reviewService = ReviewService();
  int _rating = 5;
  String _content = '';
  List<String> _selectedTags = [];
  bool _isSubmitting = false;

  Future<void> _submitReview() async {
    if (_isSubmitting) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final request = CreateReviewRequest(
        rating: _rating,
        content: _content,
        tags: _selectedTags,
        photos: [], // 上传图片后填入 URL
      );

      await _reviewService.createReview(widget.trailId, request);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('评论发表成功')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发表失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('写评论'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submitReview,
            child: _isSubmitting
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text('发表'),
          ),
        ],
      ),
      body: Column(
        children: [
          // 评分选择
          _buildRatingSelector(),
          
          // 标签选择
          _buildTagSelector(),
          
          // 内容输入
          Expanded(
            child: ReviewInput(
              hintText: '分享你的徒步体验...',
              onSubmit: (text) {
                setState(() {
                  _content = text;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(5, (index) {
          return IconButton(
            icon: Icon(
              index < _rating ? Icons.star : Icons.star_border,
              size: 40,
              color: Color(0xFFFFB800),
            ),
            onPressed: () {
              setState(() {
                _rating = index + 1;
              });
            },
          );
        }),
      ),
    );
  }

  Widget _buildTagSelector() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: ReviewTags(
        tags: PREDEFINED_TAGS.where((tag) => _selectedTags.contains(tag)).toList(),
        onTagTap: (tag) {
          setState(() {
            if (_selectedTags.contains(tag)) {
              _selectedTags.remove(tag);
            } else if (_selectedTags.length < 5) {
              _selectedTags.add(tag);
            }
          });
        },
      ),
    );
  }
}

/// 示例：评论详情页面
class ReviewDetailScreen extends StatefulWidget {
  final Review review;

  const ReviewDetailScreen({
    Key? key,
    required this.review,
  }) : super(key: key);

  @override
  State<ReviewDetailScreen> createState() => _ReviewDetailScreenState();
}

class _ReviewDetailScreenState extends State<ReviewDetailScreen> {
  final ReviewService _reviewService = ReviewService();
  late Review _review;
  List<ReviewReply> _replies = [];
  bool _isLoading = true;
  bool _showReplyInput = false;

  @override
  void initState() {
    super.initState();
    _review = widget.review;
    _loadReplies();
  }

  Future<void> _loadReplies() async {
    try {
      final replies = await _reviewService.getReplies(_review.id);
      setState(() {
        _replies = replies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLike() async {
    try {
      final result = await _reviewService.likeReview(_review.id);
      setState(() {
        _review = _review.copyWith(
          isLiked: result.isLiked,
          likeCount: result.likeCount,
        );
      });
    } catch (e) {
      // 显示错误
    }
  }

  Future<void> _submitReply(String content) async {
    try {
      final request = CreateReplyRequest(content: content);
      await _reviewService.createReply(_review.id, request);
      
      // 刷新回复列表
      await _loadReplies();
      
      setState(() {
        _showReplyInput = false;
      });
    } catch (e) {
      // 显示错误
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('评论详情')),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 评论内容
                  ReviewItem(
                    review: _review,
                    onLike: _handleLike,
                    onReply: () {
                      setState(() {
                        _showReplyInput = true;
                      });
                    },
                    showReplies: false,
                  ),
                  
                  // 回复列表
                  if (_isLoading)
                    Center(child: CircularProgressIndicator())
                  else if (_replies.isNotEmpty)
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: 16),
                      child: ReviewReplyList(
                        replies: _replies,
                        totalCount: _replies.length,
                        maxDisplayCount: _replies.length,
                        onReplyTap: (userId) {
                          setState(() {
                            _showReplyInput = true;
                          });
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          // 回复输入框
          if (_showReplyInput)
            ReplyInput(
              replyToUser: _review.user.nickname ?? '用户',
              onCancel: () {
                setState(() {
                  _showReplyInput = false;
                });
              },
              onSubmit: _submitReply,
            ),
        ],
      ),
    );
  }
}

/// 示例：独立使用点赞按钮
class LikeButtonExample extends StatefulWidget {
  @override
  State<LikeButtonExample> createState() => _LikeButtonExampleState();
}

class _LikeButtonExampleState extends State<LikeButtonExample> {
  bool _isLiked = false;
  int _likeCount = 128;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LikeButton(
        count: _likeCount,
        isLiked: _isLiked,
        onTap: () {
          setState(() {
            _isLiked = !_isLiked;
            _likeCount += _isLiked ? 1 : -1;
          });
        },
      ),
    );
  }
}
