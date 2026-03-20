// ================================================================
// M6: 用户卡片组件
// ================================================================

import 'package:flutter/material.dart';
import '../services/follow_service.dart';
import '../constants/app_theme.dart';
import 'follow_button.dart';

/// 用户卡片组件
class UserCard extends StatelessWidget {
  final FollowUser user;
  final VoidCallback? onTap;
  final VoidCallback? onFollowChanged;
  final bool showFollowButton;
  final bool showBio;
  final bool showMutualFollows;

  const UserCard({
    Key? key,
    required this.user,
    this.onTap,
    this.onFollowChanged,
    this.showFollowButton = true,
    this.showBio = true,
    this.showMutualFollows = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey[200]!,
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // 头像
            _buildAvatar(),
            SizedBox(width: 12),
            // 用户信息
            Expanded(
              child: _buildUserInfo(),
            ),
            // 关注按钮
            if (showFollowButton)
              FollowButton(
                userId: user.id,
                isFollowing: user.isFollowing,
                size: FollowButtonSize.small,
                onFollowChanged: onFollowChanged,
                showMutual: user.isFollowing && (user.mutualFollows != null && user.mutualFollows! > 0),
                isMutual: user.mutualFollows != null && user.mutualFollows! > 0,
              ),
          ],
        ),
      ),
    );
  }

  /// 构建头像
  Widget _buildAvatar() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey[200],
        border: Border.all(
          color: Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: user.avatarUrl != null
          ? ClipOval(
              child: Image.network(
                user.avatarUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildDefaultAvatar();
                },
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  /// 默认头像
  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 28,
      color: Colors.grey[400],
    );
  }

  /// 构建用户信息
  Widget _buildUserInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // 昵称
        Text(
          user.nickname ?? '用户${user.id.substring(0, 6)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.grey[900],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 2),
        // 粉丝数 + 共同关注
        Row(
          children: [
            Text(
              '${_formatCount(user.followersCount)} 粉丝',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            if (showMutualFollows && user.mutualFollows != null && user.mutualFollows! > 0) ...[
              SizedBox(width: 8),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${user.mutualFollows}个共同关注',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
        // 简介
        if (showBio && user.bio != null && user.bio!.isNotEmpty) ...[
          SizedBox(height: 4),
          Text(
            user.bio!,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  /// 格式化数字
  String _formatCount(int count) {
    if (count >= 10000) {
      return '${(count / 10000).toStringAsFixed(1)}万';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

/// 用户列表项（简化版）
class UserListTile extends StatelessWidget {
  final FollowUser user;
  final VoidCallback? onTap;
  final VoidCallback? onFollowChanged;
  final bool showFollowButton;
  final Widget? trailing;

  const UserListTile({
    Key? key,
    required this.user,
    this.onTap,
    this.onFollowChanged,
    this.showFollowButton = true,
    this.trailing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage: user.avatarUrl != null
            ? NetworkImage(user.avatarUrl!)
            : null,
        child: user.avatarUrl == null
            ? Icon(Icons.person, color: Colors.grey[400])
            : null,
      ),
      title: Text(
        user.nickname ?? '用户${user.id.substring(0, 6)}',
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${user.followersCount} 粉丝',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[500],
        ),
      ),
      trailing: trailing ?? (showFollowButton
          ? FollowButton(
              userId: user.id,
              isFollowing: user.isFollowing,
              size: FollowButtonSize.small,
              onFollowChanged: onFollowChanged,
            )
          : null),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
