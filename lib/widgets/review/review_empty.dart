/**
 * 评论空状态组件
 * 
 * M6 评论系统 - 无评论时展示
 */

import 'package:flutter/material.dart';

/// 评论空状态
class ReviewEmpty extends StatelessWidget {
  final VoidCallback? onWriteReview;

  const ReviewEmpty({
    Key? key,
    this.onWriteReview,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 插画
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Color(0xFFE5E7EB),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(height: 24),
            
            // 标题
            Text(
              '还没有评论',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            SizedBox(height: 8),
            
            // 副标题
            Text(
              '成为第一个评论的人吧',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(height: 24),
            
            // 发表评论按钮
            if (onWriteReview != null)
              ElevatedButton(
                onPressed: onWriteReview,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2D968A),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(
                  '发表评论',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
