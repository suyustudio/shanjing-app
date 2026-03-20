// collection_selector_dialog.dart
// 山径APP - 收藏夹选择弹窗

import 'package:flutter/material.dart';
import '../../models/collection_model.dart';
import '../../services/collection_service.dart';
import 'collection_form_dialog.dart';

/// 收藏夹选择弹窗
class CollectionSelectorDialog extends StatefulWidget {
  final String trailId;
  final String trailName;

  const CollectionSelectorDialog({
    Key? key,
    required this.trailId,
    required this.trailName,
  }) : super(key: key);

  /// 显示选择弹窗
  static Future<bool> show(BuildContext context, {
    required String trailId,
    required String trailName,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CollectionSelectorDialog(
        trailId: trailId,
        trailName: trailName,
      ),
    );
    return result ?? false;
  }

  @override
  State<CollectionSelectorDialog> createState() => _CollectionSelectorDialogState();
}

class _CollectionSelectorDialogState extends State<CollectionSelectorDialog> {
  final CollectionService _collectionService = CollectionService();
  
  List<Collection> _collections = [];
  Set<String> _selectedCollectionIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  /// 加载收藏夹列表
  Future<void> _loadCollections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final collections = await _collectionService.getCollections();
      
      // 检查路线在哪些收藏夹中
      final List<Future> checks = [];
      for (final collection in collections) {
        checks.add(
          _collectionService.getCollectionDetail(collection.id, limit: 100)
            .then((detail) {
              if (detail.trails.any((t) => t.trailId == widget.trailId)) {
                _selectedCollectionIds.add(collection.id);
              }
            })
            .catchError((_) {}),
        );
      }
      
      await Future.wait(checks);
      
      if (mounted) {
        setState(() {
          _collections = collections;
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

  /// 切换收藏夹选择
  Future<void> _toggleCollection(Collection collection) async {
    final isSelected = _selectedCollectionIds.contains(collection.id);
    
    setState(() {
      if (isSelected) {
        _selectedCollectionIds.remove(collection.id);
      } else {
        _selectedCollectionIds.add(collection.id);
      }
    });

    try {
      if (isSelected) {
        // 从收藏夹移除
        await _collectionService.removeTrailFromCollection(
          collectionId: collection.id,
          trailId: widget.trailId,
        );
      } else {
        // 添加到收藏夹
        await _collectionService.addTrailToCollection(
          collectionId: collection.id,
          trailId: widget.trailId,
        );
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isSelected ? '已从收藏夹移除' : '已添加到收藏夹'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      // 失败时恢复状态
      setState(() {
        if (isSelected) {
          _selectedCollectionIds.add(collection.id);
        } else {
          _selectedCollectionIds.remove(collection.id);
        }
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('操作失败: $e')),
        );
      }
    }
  }

  /// 显示创建收藏夹弹窗
  void _showCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => CollectionFormDialog(
        onSubmit: (name, description, isPublic) async {
          final result = await _collectionService.createCollection(
            name: name,
            description: description,
            isPublic: isPublic,
          );
          
          if (result.success) {
            _loadCollections();
          }
          
          return result.success;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 标题栏
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.folder, color: Colors.green),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '收藏"${widget.trailName}"',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('完成'),
                  ),
                ],
              ),
            ),
            
            // 收藏夹列表
            Flexible(
              child: _buildContent(),
            ),
            
            // 底部按钮
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _showCreateDialog,
                      icon: const Icon(Icons.add),
                      label: const Text('新建收藏夹'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadCollections,
                child: const Text('重试'),
              ),
            ],
          ),
        ),
      );
    }

    if (_collections.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('还没有收藏夹，创建一个吧'),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      itemCount: _collections.length,
      itemBuilder: (context, index) {
        final collection = _collections[index];
        final isSelected = _selectedCollectionIds.contains(collection.id);
        
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              image: collection.coverUrl != null
                  ? DecorationImage(
                      image: NetworkImage(collection.coverUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: collection.coverUrl == null
                ? Icon(Icons.folder, color: Colors.green.shade300)
                : null,
          ),
          title: Text(collection.name),
          subtitle: Text('${collection.trailCount} 条路线'),
          trailing: isSelected
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.radio_button_unchecked, color: Colors.grey),
          onTap: () => _toggleCollection(collection),
        );
      },
    );
  }
}
