/**
 * 评论输入组件
 * 
 * M6 评论系统 - 评论输入框
 */

import 'package:flutter/material.dart';

/// 评论输入框
class ReviewInput extends StatefulWidget {
  final String? hintText;
  final int maxLength;
  final VoidCallback? onCancel;
  final Function(String)? onSubmit;
  final bool autofocus;

  const ReviewInput({
    Key? key,
    this.hintText,
    this.maxLength = 500,
    this.onCancel,
    this.onSubmit,
    this.autofocus = false,
  }) : super(key: key);

  @override
  State<ReviewInput> createState() => _ReviewInputState();
}

class _ReviewInputState extends State<ReviewInput> {
  late TextEditingController _controller;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _controller.addListener(() {
      setState(() {
        _isComposing = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSubmit?.call(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color(0xFFE5E7EB),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 输入框
            Container(
              constraints: BoxConstraints(
                minHeight: 80,
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: Color(0xFFF9FAFB),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Color(0xFFE5E7EB),
                ),
              ),
              child: TextField(
                controller: _controller,
                autofocus: widget.autofocus,
                maxLength: widget.maxLength,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? '说点什么...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: Color(0xFF9CA3AF),
                  ),
                  contentPadding: EdgeInsets.all(12),
                  border: InputBorder.none,
                  counterText: '',
                ),
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
            SizedBox(height: 8),
            
            // 底部工具栏
            Row(
              children: [
                // 字数统计
                Text(
                  '${_controller.text.length}/${widget.maxLength}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
                Spacer(),
                
                // 取消按钮
                if (widget.onCancel != null)
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ),
                SizedBox(width: 8),
                
                // 发送按钮
                ElevatedButton(
                  onPressed: _isComposing ? _handleSubmit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2D968A),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Color(0xFFE5E7EB),
                    disabledForegroundColor: Color(0xFF9CA3AF),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    '发送',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// 回复输入框（带回复对象提示）
class ReplyInput extends StatelessWidget {
  final String replyToUser;
  final VoidCallback? onCancel;
  final Function(String)? onSubmit;

  const ReplyInput({
    Key? key,
    required this.replyToUser,
    this.onCancel,
    this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 回复对象提示
        Container(
          margin: EdgeInsets.only(bottom: 8),
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5F3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '回复 @$replyToUser:',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1D756B),
                ),
              ),
              SizedBox(width: 8),
              GestureDetector(
                onTap: onCancel,
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: Color(0xFF1D756B),
                ),
              ),
            ],
          ),
        ),
        
        // 输入框
        ReviewInput(
          hintText: '回复 @$replyToUser...',
          onCancel: onCancel,
          onSubmit: onSubmit,
          autofocus: true,
        ),
      ],
    );
  }
}
