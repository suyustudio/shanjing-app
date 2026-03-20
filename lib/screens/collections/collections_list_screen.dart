// collections_list_screen.dart
// 山径APP - 收藏夹列表页

import 'package:flutter/material.dart';
import '../../models/collection_model.dart';
import '../../services/collection_service.dart';
import '../../widgets/collections/collection_card.dart';
import '../../widgets/collections/collection_form_dialog.dart';
import 'collection_detail_screen.dart';

/// 收藏夹列表页
class CollectionsListScreen extends StatefulWidget {
  const CollectionsListScreen({Key? key}) : super(key: key);

  @override
  State<CollectionsListScreen> createState() => _CollectionsListScreenState();
}

class _CollectionsListScreenState extends State<CollectionsListScreen> 
    with AutomaticKeepAliveClientMixin {
  
  final CollectionService _collectionService = CollectionService();
  
  List<Collection> _collections = [];
  bool _isLoading = true;
  String? _errorMessage;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadCollections();
  }

  /// 加载收藏夹列表
  Future<void> _loadCollections({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final collections = await _collectionService.getCollections(
        forceRefresh: forceRefresh,
      );
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
            _loadCollections(forceRefresh: true);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('创建成功')),
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

  /// 删除收藏夹
  Future<void> _deleteCollection(Collection collection) async {
    if (collection.isDefault) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('默认收藏夹不能删除')),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除收藏夹"${collection.name}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final result = await _collectionService.deleteCollection(collection.id);
      
      if (result.success) {
        _loadCollections(forceRefresh: true);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('删除成功')),
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
    super.build(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('我的收藏夹'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateDialog,
            tooltip: '新建收藏夹',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadCollections(forceRefresh: true),
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateDialog,
        icon: const Icon(Icons.add),
        label: const Text('新建收藏夹'),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _loadCollections(forceRefresh: true),
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    if (_collections.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('还没有收藏夹', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _showCreateDialog,
              child: const Text('创建收藏夹'),
            ),
          ],
        ),
      );
    }

    return ReorderableListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _collections.length,
      onReorder: (oldIndex, newIndex) async {
        if (oldIndex < newIndex) {
          newIndex -= 1;
        }
        
        final item = _collections.removeAt(oldIndex);
        _collections.insert(newIndex, item);
        
        setState(() {});
        
        // TODO: 调用API保存排序
      },
      itemBuilder: (context, index) {
        final collection = _collections[index];
        return CollectionCard(
          key: ValueKey(collection.id),
          collection: collection,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CollectionDetailScreen(
                  collection: collection,
                ),
              ),
            ).then((_) => _loadCollections(forceRefresh: true));
          },
          onDelete: collection.isDefault ? null : () => _deleteCollection(collection),
        );
      },
    );
  }
}
