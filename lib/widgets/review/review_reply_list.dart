/**
 * 评论回复列表组件
 * 
 * M6 评论系统 - 嵌套回复展示
 */

import 'package:flutter/material.dart';
import '../../models/review_model.dart';

/// 评论回复列表
class ReviewReplyList extends StatelessWidget {
  final List<ReviewReply> replies;
  final int maxDisplayCount;
  final int totalCount;
  final VoidCallback? onViewAll;
  final Function(String)? onReplyTap;
  final Function(String)? onUserTap;

  const ReviewReplyList({
    Key? key,
    required this.replies,
    this.maxDisplayCount = 2,
    required this.totalCount,
    this.onViewAll,
    this.onReplyTap,
    this.onUserTap,
  }) : super(key: key);

  // 品牌色
  static const Color _primaryColor = Color(0xFF2D968A);
  static const Color _grayColor = Color(0xFF6B7280);
  static const Color _textColor = Color(0xFF4B5563);
  static const Color _bgColor = Color(0xFFF9FAFB);

  @override
  Widget build(BuildContext context) {
    final displayReplies = replies.take(maxDisplayCount).toList();
    final remainingCount = totalCount - displayReplies.length;

    return Container(
      margin: EdgeInsets.only(left: 52), // 与主评论内容对齐
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 回复列表
          ...displayReplies.asMap().entries.map((entry) {
            final index = entry.key;
            final reply = entry.value;
            return Column(
              children: [
                ReviewReplyItem(
                  reply: reply,
                  onReplyTap: onReplyTap,
                  onUserTap: onUserTap,
                ),
                if (index < displayReplies.length - 1)
                  SizedBox(height: 12),
              ],
            );
          }).toList(),
          
          // 查看全部按钮
          if (remainingCount > 0)
            _buildViewAllButton(remainingCount),
        ],
      ),
    );
  }

  /// 构建"查看全部"按钮
  Widget _buildViewAllButton(int count) {
    return GestureDetector(
      onTap: onViewAll,
      child: Container(
        margin: EdgeInsets.only(top: 8),
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '查看全部 $count 条回复',
              style: TextStyle(
                fontSize: 13,
                color: _primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.expand_more,
              size: 16,
              color: _primaryColor,
            ),
          ],
        ),
      ),
    );
  }
}

/// 单条回复项
class ReviewReplyItem extends StatelessWidget {
  final ReviewReply reply;
  final VoidCallback? onReplyTap;
  final Function(String)? onUserTap;

  const ReviewReplyItem({
    Key? key,
    required this.reply,
    this.onReplyTap,
    this.onUserTap,
  }) : super(key: key);

  // 品牌色
  static const Color _grayColor = Color(0xFF6B7280);
  static const Color _textColor = Color(0xFF4B5563);
  static const Color _linkColor = Color(0xFF2D968A);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 头像
        GestureDetector(
          onTap: onUserTap != null ? () => onUserTap!(reply.user.id) : null,
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFF3F4F6),
              image: reply.user.avatarUrl != null
                  ? DecorationImage(
                      image: NetworkImage(reply.user.avatarUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: reply.user.avatarUrl == null
                ? Icon(Icons.person, color: _grayColor, size: 16)
                : null,
          ),
        ),
        SizedBox(width: 8),
        
        // 内容
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 用户名
              Text(
                reply.user.nickname ?? '匿名用户',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: _grayColor,
                ),
              ),
              SizedBox(height: 4),
              
              // 回复内容
              _buildReplyContent(),
              
              SizedBox(height: 4),
              
              // 时间和回复按钮
              Row(
                children: [
                  Text(
                    _formatDate(reply.createdAt),
                    style: TextStyle(
                      fontSize: 11,
                      color: _grayColor,
                    ),
                  ),
                  SizedBox(width: 12),
                  GestureDetector(
                    onTap: onReplyTap,
                    child: Text(
                      '回复',
                      style: TextStyle(
                        fontSize: 11,
                        color: _grayColor,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 构建回复内容
  Widget _buildReplyContent() {
    return RichText(
      text: TextSpan(
        children: [
          // 如果有父回复，显示 "回复 @xxx:"
          if (reply.parentId != null) ...[
            TextSpan(
              text: '回复 ',
              style: TextStyle(
                fontSize: 13,
                color: _textColor,
              ),
            ),
            TextSpan(
              text: '@用户', // 这里可以传入父回复用户信息
              style: TextStyle(
                fontSize: 13,
                color: _linkColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            TextSpan(
              text: ': ',
              style: TextStyle(
                fontSize: 13,
                color: _textColor,
              ),
            ),
          ],
          TextSpan(
            text: reply.content,
            style: TextStyle(
              fontSize: 13,
              color: _textColor,
              height: 1.4,
            ),
          ),
        ],
      ),
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
