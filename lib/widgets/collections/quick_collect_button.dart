// quick_collect_button.dart
// 山径APP - 快速收藏按钮

import 'package:flutter/material.dart';
import '../../services/collection_service.dart';
import '../collections/collection_selector_dialog.dart';

/// 快速收藏按钮
class QuickCollectButton extends StatefulWidget {
  final String trailId;
  final String trailName;
  final bool showLabel;
  final VoidCallback? onCollectChanged;

  const QuickCollectButton({
    Key? key,
    required this.trailId,
    required this.trailName,
    this.showLabel = false,
    this.onCollectChanged,
  }) : super(key: key);

  @override
  State<QuickCollectButton> createState() => _QuickCollectButtonState();
}

class _QuickCollectButtonState extends State<QuickCollectButton> {
  final CollectionService _collectionService = CollectionService();
  
  bool _isCollected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  /// 检查收藏状态
  Future<void> _checkStatus() async {
    try {
      final isCollected = await _collectionService.isQuickCollected(widget.trailId);
      if (mounted) {
        setState(() {
          _isCollected = isCollected;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// 快速收藏
  Future<void> _quickCollect() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _collectionService.quickCollect(widget.trailId);
      
      if (mounted) {
        setState(() {
          _isCollected = result.isCollected;
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.isCollected ? '已添加到收藏夹' : '已取消收藏'),
            duration: const Duration(seconds: 1),
          ),
        );
        
        widget.onCollectChanged?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  /// 显示收藏夹选择弹窗
  Future<void> _showSelector() async {
    final result = await CollectionSelectorDialog.show(
      context,
      trailId: widget.trailId,
      trailName: widget.trailName,
    );
    
    if (result == true) {
      _checkStatus();
      widget.onCollectChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showLabel) {
      return TextButton.icon(
        onPressed: _isLoading ? null : _showSelector,
        icon: _isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(
                _isCollected ? Icons.bookmark : Icons.bookmark_border,
                color: _isCollected ? Colors.green : null,
              ),
        label: Text(_isCollected ? '已收藏' : '收藏'),
        style: TextButton.styleFrom(
          foregroundColor: _isCollected ? Colors.green : null,
        ),
      );
    }

    return IconButton(
      onPressed: _isLoading ? null : _showSelector,
      icon: _isLoading
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : Icon(
              _isCollected ? Icons.bookmark : Icons.bookmark_border,
              color: _isCollected ? Colors.green : null,
            ),
      tooltip: '收藏',
    );
  }
}
