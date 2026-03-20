// ================================================================
// M6: 关注按钮组件
// ================================================================

import 'package:flutter/material.dart';
import '../services/follow_service.dart';
import '../constants/app_theme.dart';

/// 关注按钮状态
enum FollowButtonSize {
  small,    // 小尺寸：用于列表卡片
  medium,   // 中尺寸：默认
  large,    // 大尺寸：用于个人主页
}

/// 关注按钮组件
class FollowButton extends StatefulWidget {
  final String userId;
  final bool isFollowing;
  final FollowButtonSize size;
  final VoidCallback? onFollowChanged;
  final bool showMutual;
  final bool isMutual;

  const FollowButton({
    Key? key,
    required this.userId,
    required this.isFollowing,
    this.size = FollowButtonSize.medium,
    this.onFollowChanged,
    this.showMutual = false,
    this.isMutual = false,
  }) : super(key: key);

  @override
  State<FollowButton> createState() => _FollowButtonState();
}

class _FollowButtonState extends State<FollowButton> {
  late bool _isFollowing;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isFollowing;
  }

  @override
  void didUpdateWidget(FollowButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFollowing != widget.isFollowing) {
      setState(() {
        _isFollowing = widget.isFollowing;
      });
    }
  }

  Future<void> _toggleFollow() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FollowService.instance.toggleFollow(
        widget.userId,
        _isFollowing,
      );

      setState(() {
        _isFollowing = result.isFollowing;
      });

      widget.onFollowChanged?.call();

      // 显示提示
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFollowing ? '关注成功' : '已取消关注'),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('操作失败: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 互相关注状态
    if (widget.showMutual && widget.isMutual) {
      return _buildMutualButton();
    }

    // 根据关注状态显示不同按钮
    if (_isFollowing) {
      return _buildFollowingButton();
    } else {
      return _buildFollowButton();
    }
  }

  /// 互相关注按钮
  Widget _buildMutualButton() {
    final size = _getSize();

    return Container(
      width: size.width,
      height: size.height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(size.height / 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.sync_alt,
            size: size.iconSize,
            color: AppTheme.primaryColor,
          ),
          SizedBox(width: 4),
          Text(
            '互相关注',
            style: TextStyle(
              fontSize: size.fontSize,
              fontWeight: FontWeight.w500,
              color: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  /// 已关注按钮（可点击取消）
  Widget _buildFollowingButton() {
    final size = _getSize();

    return GestureDetector(
      onTap: _toggleFollow,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(size.height / 2),
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? SizedBox(
                width: size.iconSize,
                height: size.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[600]!),
                ),
              )
            : Text(
                '已关注',
                style: TextStyle(
                  fontSize: size.fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[600],
                ),
              ),
      ),
    );
  }

  /// 关注按钮
  Widget _buildFollowButton() {
    final size = _getSize();

    return GestureDetector(
      onTap: _toggleFollow,
      child: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(size.height / 2),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? SizedBox(
                width: size.iconSize,
                height: size.iconSize,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '关注',
                style: TextStyle(
                  fontSize: size.fontSize,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  /// 获取尺寸配置
  _ButtonSize _getSize() {
    switch (widget.size) {
      case FollowButtonSize.small:
        return _ButtonSize(
          width: 60,
          height: 28,
          fontSize: 12,
          iconSize: 12,
        );
      case FollowButtonSize.large:
        return _ButtonSize(
          width: 100,
          height: 40,
          fontSize: 16,
          iconSize: 18,
        );
      case FollowButtonSize.medium:
      default:
        return _ButtonSize(
          width: 80,
          height: 36,
          fontSize: 14,
          iconSize: 14,
        );
    }
  }
}

/// 按钮尺寸配置
class _ButtonSize {
  final double width;
  final double height;
  final double fontSize;
  final double iconSize;

  _ButtonSize({
    required this.width,
    required this.height,
    required this.fontSize,
    required this.iconSize,
  });
}
