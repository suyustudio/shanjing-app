/**
 * 评论项组件
 * 
 * M6 评论系统 - 单条评论展示
 */

import 'package:flutter/material.dart';
import '../../models/review_model.dart';
import 'like_button.dart';
import 'review_photo_grid.dart';
import 'review_reply_list.dart';
import 'review_tags.dart';

/// 评论项组件
class ReviewItem extends StatelessWidget {
  final Review review;
  final VoidCallback? onLike;
  final VoidCallback? onReply;
  final VoidCallback? onExpand;
  final Function(String)? onImageTap;
  final Function(String)? onUserTap;
  final bool showReplies;
  final int maxReplies;

  const ReviewItem({
    Key? key,
    required this.review,
    this.onLike,
    this.onReply,
    this.onExpand,
    this.onImageTap,
    this.onUserTap,
    this.showReplies = true,
    this.maxReplies = 2,
  }) : super(key: key);

  // 品牌色
  static const Color _primaryColor = Color(0xFF2D968A);
  static const Color _grayColor = Color(0xFF9CA3AF);
  static const Color _textColor = Color(0xFF4B5563);

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头部：头像、昵称、评分、点赞
          _buildHeader(),
          SizedBox(height: 12),
          
          // 标签
          if (review.tags.isNotEmpty) ...[
            ReviewTags(tags: review.tags),
            SizedBox(height: 8),
          ],
          
          // 评论内容
          if (review.content != null && review.content!.isNotEmpty) ...[
            _buildContent(),
            SizedBox(height: 12),
          ],
          
          // 图片
          if (review.photos.isNotEmpty) ...[
            ReviewPhotoGrid(
              photos: review.photos,
              onTap: onImageTap,
            ),
            SizedBox(height: 12),
          ],
          
          // 底部：时间、回复按钮
          _buildFooter(),
          
          // 回复列表
          if (showReplies && 
              review.replies != null && 
              review.replies!.isNotEmpty) ...[
            SizedBox(height: 12),
            ReviewReplyList(
              replies: review.replies!,
              maxDisplayCount: maxReplies,
              totalCount: review.replyCount,
              onViewAll: onExpand,
              onReplyTap: onReply,
            ),
          ],
        ],
      ),
    );
  }

  /// 构建头部
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像
        GestureDetector(
          onTap: onUserTap != null ? () => onUserTap!(review.user.id) : null,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3F4F6),
              image: review.user.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(review.user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: review.user.avatarUrl == null
                ? Icon(Icons.person, color: _grayColor, size: 24)
                : null,
          ),
        ),
        SizedBox(width: 12),
        
        // 用户信息
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 昵称
              Row(
                children: [
                  Text(
                    review.user.nickname ?? '匿名用户',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF374151),
                    ),
                  ),
                  // 体验过标识
                  if (review.isVerified) ...[
                    SizedBox(width: 6),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Color(0xFFE8F5F3),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        '体验过',
                        style: TextStyle(
                          fontSize: 10,
                          color: _primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              SizedBox(height: 4),
              
              // 评分
              Row(
                children: [
                  _buildStarRating(review.rating),
                  SizedBox(width: 8),
                  Text(
                    review.rating.toString(),
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFB800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        // 点赞按钮
        LikeButton(
          count: review.likeCount,
          isLiked: review.isLiked,
          onTap: onLike,
        ),
      ],
    );
  }

  /// 构建星级评分
  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: Color(0xFFFFB800),
        );
      }),
    );
  }

  /// 构建评论内容
  Widget _buildContent() {
    return Text(
      review.content!,
      style: TextStyle(
        fontSize: 14,
        color: _textColor,
        height: 1.5,
      ),
    );
  }

  /// 构建底部
  Widget _buildFooter() {
    return Row(
      children: [
        // 时间
        Text(
          _formatDate(review.createdAt),
          style: TextStyle(
            fontSize: 12,
            color: _grayColor,
          ),
        ),
        
        // 已编辑标识
        if (review.isEdited) ...[
          SizedBox(width: 8),
          Text(
            '已编辑',
            style: TextStyle(
              fontSize: 12,
              color: _grayColor,
            ),
          ),
        ],
        
        SizedBox(width: 16),
        
        // 回复按钮
        GestureDetector(
          onTap: onReply,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              '回复',
              style: TextStyle(
                fontSize: 12,
                color: _grayColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 格式化日期
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 365) {
      return '${(diff.inDays / 365).floor()}年前';
    } else if (diff.inDays > 30) {
      return '${(diff.inDays / 30).floor()}个月前';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}天前';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}小时前';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}分钟前';
    } else {
      return '刚刚';
    }
  }
}
