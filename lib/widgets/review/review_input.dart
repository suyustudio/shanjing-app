/**
 * 评论输入组件
 * 
 * M6 评论系统 - 评论输入框
 * 设计规范: 最小高度80px, 最大高度120px, 聚焦边框 #2D968A
 */

import 'package:flutter/material.dart';
import '../../constants/design_system.dart';

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
  late FocusNode _focusNode;
  bool _isComposing = false;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
    _controller.addListener(() {
      setState(() {
        _isComposing = _controller.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: DesignSystem.getBackground(context),
        border: Border(
          top: BorderSide(
            color: DesignSystem.getBorder(context),
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
              constraints: const BoxConstraints(
                minHeight: 80,
                maxHeight: 120,
              ),
              decoration: BoxDecoration(
                color: DesignSystem.getBackgroundSecondary(context),
                borderRadius: BorderRadius.circular(DesignSystem.radius),
                border: Border.all(
                  // P1: 聚焦边框颜色 #2D968A
                  color: _isFocused 
                      ? DesignSystem.primary 
                      : DesignSystem.border,
                  width: _isFocused ? 1.5 : 1.0,
                ),
              ),
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                maxLength: widget.maxLength,
                maxLines: null,
                textInputAction: TextInputAction.newline,
                decoration: InputDecoration(
                  hintText: widget.hintText ?? '说点什么...',
                  hintStyle: TextStyle(
                    fontSize: 14,
                    color: DesignSystem.getTextTertiary(context),
                  ),
                  contentPadding: const EdgeInsets.all(12),
                  border: InputBorder.none,
                  counterText: '',
                ),
                onSubmitted: (_) => _handleSubmit(),
              ),
            ),
            const SizedBox(height: 8),
            
            // 底部工具栏
            Row(
              children: [
                // 字数统计
                Text(
                  '${_controller.text.length}/${widget.maxLength}',
                  style: TextStyle(
                    fontSize: 12,
                    color: DesignSystem.getTextTertiary(context),
                  ),
                ),
                const Spacer(),
                
                // 取消按钮
                if (widget.onCancel != null)
                  TextButton(
                    onPressed: widget.onCancel,
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 14,
                        color: DesignSystem.getTextSecondary(context),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                
                // 发送按钮
                ElevatedButton(
                  onPressed: _isComposing ? _handleSubmit : null,
                  style: DesignSystem.primaryButtonStyle(context, 
                    isDisabled: !_isComposing,
                  ),
                  child: const Text(
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
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5F3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '回复 @$replyToUser:',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF1D756B),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCancel,
                child: const Icon(
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

/// 底部评论输入栏（用于页面底部固定显示）
class ReviewInputBar extends StatelessWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final VoidCallback? onTap;
  final String? replyToUser;
  final VoidCallback? onCancelReply;

  const ReviewInputBar({
    Key? key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onTap,
    this.replyToUser,
    this.onCancelReply,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DesignSystem.getBackground(context),
        boxShadow: DesignSystem.getShadowLight(context),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 回复提示
            if (replyToUser != null)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5F3),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Text(
                      '回复 @$replyToUser',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1D756B),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF1D756B),
                      ),
                    ),
                  ],
                ),
              ),
            
            // 输入框
            GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: DesignSystem.getBackgroundSecondary(context),
                  borderRadius: BorderRadius.circular(DesignSystem.radiusLarge),
                  border: Border.all(
                    color: DesignSystem.getBorder(context),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.edit_note,
                      size: 20,
                      color: DesignSystem.getTextTertiary(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        hintText ?? '写评论...',
                        style: TextStyle(
                          fontSize: 14,
                          color: DesignSystem.getTextTertiary(context),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.send,
                      size: 20,
                      color: DesignSystem.getTextTertiary(context),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
