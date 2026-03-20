/**
 * 评论骨架屏组件
 * 
 * M6 评论系统 - 加载占位
 */

import 'package:flutter/material.dart';

/// 评论骨架屏
class ReviewSkeleton extends StatelessWidget {
  final int itemCount;

  const ReviewSkeleton({
    Key? key,
    this.itemCount = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return _ReviewSkeletonItem();
      },
    );
  }
}

class _ReviewSkeletonItem extends StatefulWidget {
  @override
  State<_ReviewSkeletonItem> createState() => _ReviewSkeletonItemState();
}

class _ReviewSkeletonItemState extends State<_ReviewSkeletonItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
          // 头部：头像和用户名
          Row(
            children: [
              // 头像
              _buildSkeletonBox(40, 40, radius: 20),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSkeletonBox(120, 16),
                    SizedBox(height: 8),
                    _buildSkeletonBox(100, 14),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          
          // 内容行1
          _buildSkeletonBox(double.infinity, 16),
          SizedBox(height: 8),
          
          // 内容行2
          _buildSkeletonBox(double.infinity, 16),
          SizedBox(height: 8),
          
          // 内容行3
          _buildSkeletonBox(MediaQuery.of(context).size.width * 0.6, 16),
          SizedBox(height: 12),
          
          // 图片
          Row(
            children: [
              _buildSkeletonBox(120, 120, radius: 8),
              SizedBox(width: 8),
              _buildSkeletonBox(120, 120, radius: 8),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonBox(double width, double height, {double radius = 4}) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFE5E7EB),
                Color(0xFFF3F4F6),
                Color(0xFFE5E7EB),
              ],
              stops: [
                0.0,
                0.5 + (_animation.value * 0.25),
                1.0,
              ],
            ),
          ),
        );
      },
    );
  }
}
