// collection_detail_screen.dart
// 山径APP - 收藏夹详情页

import 'package:flutter/material.dart';
import '../../models/collection_model.dart';
import '../../services/collection_service.dart';
import '../../widgets/collections/collection_trail_card.dart';
import '../../widgets/collections/collection_form_dialog.dart';
import '../trail_detail_screen.dart';

/// 收藏夹详情页
class CollectionDetailScreen extends StatefulWidget {
  final Collection collection;

  const CollectionDetailScreen({
    Key? key,
    required this.collection,
  }) : super(key: key);

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  final CollectionService _collectionService = CollectionService();
  
  late Collection _collection;
  CollectionDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _collection = widget.collection;
    _loadDetail();
  }

  /// 加载收藏夹详情
  Future<void> _loadDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final detail = await _collectionService.getCollectionDetail(_collection.id);
      if (mounted) {
        setState(() {
          _detail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '加载失败: $e';
          _isLoading = false;
        });
      }
    }
  }

  /// 显示编辑弹窗
  void _showEditDialog() {
    showDialog(
      context: context,
      builder: (context) => CollectionFormDialog(
        initialName: _collection.name,
        initialDescription: _collection.description,
        initialIsPublic: _collection.isPublic,
        isEditing: true,
        onSubmit: (name, description, isPublic) async {
          final result = await _collectionService.updateCollection(
            collectionId: _collection.id,
            name: name,
            description: description,
            isPublic: isPublic,
          );
          
          if (result.success && result.collection != null) {
            setState(() {
              _collection = result.collection!;
            });
            _loadDetail();
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('更新成功')),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(result.message)),
              );
            }
          }
          
          return result.success;
        },
      ),
    );
  }

  /// 移除路线
  Future<void> _removeTrail(String trailId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认移除'),
        content: const Text('确定要从收藏夹中移除这条路线吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('移除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _collectionService.removeTrailFromCollection(
        collectionId: _collection.id,
        trailId: trailId,
      );
      
      if (result.success) {
        _loadDetail();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('移除成功')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message)),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(_collection.name),
        background: _collection.coverUrl != null
            ? Image.network(
                _collection.coverUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildDefaultCover(),
              )
            : _buildDefaultCover(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: _showEditDialog,
          tooltip: '编辑',
        ),
        PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'share':
                // TODO: 分享
                break;
              case 'sort':
                // TODO: 排序模式
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'share',
              child: Row(
                children: [
                  Icon(Icons.share, size: 20),
                  SizedBox(width: 8),
                  Text('分享'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'sort',
              child: Row(
                children: [
                  Icon(Icons.sort, size: 20),
                  SizedBox(width: 8),
                  Text('排序管理'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDefaultCover() {
    return Container(
      color: Colors.green.shade100,
      child: Center(
        child: Icon(
          Icons.folder,
          size: 80,
          color: Colors.green.shade300,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadDetail,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_detail == null || _detail!.trails.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.route_outlined, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('收藏夹是空的', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              const Text(
                '去添加一些喜欢的路线吧',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // TODO: 跳转到发现页
                },
                child: const Text('去发现路线'),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 收藏夹信息
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_detail?.description != null) ...[
                  Text(
                    _detail!.description!,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                ],
                Row(
                  children: [
                    Icon(
                      _detail?.isPublic == true ? Icons.public : Icons.lock,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_detail?.trailCount ?? 0} 条路线',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '更新于 ${_formatDate(_collection.updatedAt)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 路线列表
          ..._detail!.trails.map((trail) => CollectionTrailCard(
            trail: trail,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TrailDetailScreen(
                    trailId: trail.trailId,
                  ),
                ),
              ).then((_) => _loadDetail());
            },
            onRemove: () => _removeTrail(trail.trailId),
          )),
        ],
      ),
    );
  }

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
    } else {
      return '刚刚';
    }
  }
}
