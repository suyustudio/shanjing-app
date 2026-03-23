// collection_detail_screen.dart
// 山径APP - 收藏夹详情页（集成多选、搜索、标签管理、批量操作）

import 'package:flutter/material.dart';
import '../../models/collection_model.dart';
import '../../models/collection_enhanced_model.dart';
import '../../models/collection_tag.dart';
import '../../services/collection_service.dart';
import '../../services/collection_enhanced_service.dart';
import '../../services/tag_service.dart';
import '../../components/collection/collection_multiselect.dart';
import '../../components/collection/batch_action_bar.dart';
import '../../components/collection/batch_action_menu.dart';
import '../../components/collection/collection_search.dart';
import '../../components/collection/tag_management.dart';
import '../../widgets/collections/collection_trail_card.dart';
import '../../widgets/collections/collection_form_dialog.dart';
import '../trail_detail_screen.dart';
import '../../services/share_service_enhanced.dart';

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
  final CollectionEnhancedService _collectionEnhancedService = CollectionEnhancedService();
  final TagService _tagService = TagService();
  
  late Collection _collection;
  CollectionDetail? _detail;
  bool _isLoading = true;
  String? _errorMessage;
  
  // 多选模式状态
  bool _isMultiSelectMode = false;
  final Set<String> _selectedTrailIds = {};
  
  // 搜索状态
  String _searchQuery = '';
  List<Trail> _filteredTrails = [];
  
  // 标签状态
  List<CollectionTag> _tags = [];
  bool _isLoadingTags = false;
  
  // 搜索控制器
  late final CollectionSearchController _searchController;

  @override
  void initState() {
    super.initState();
    _collection = widget.collection;
    _searchController = CollectionSearchController();
    _searchController.init(collectionId: _collection.id);
    
    // 监听搜索查询变化
    _searchController.textController.addListener(() {
      final query = _searchController.textController.text;
      if (query != _searchQuery) {
        _onSearchQueryChanged(query);
      }
    });
    
    _loadDetail();
    _loadTags();
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
          _updateFilteredTrails();
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

  /// 加载收藏夹标签
  Future<void> _loadTags() async {
    if (_collection.id.isEmpty) return;
    
    setState(() {
      _isLoadingTags = true;
    });
    
    try {
      final tags = await _tagService.getCollectionTags(_collection.id);
      if (mounted) {
        setState(() {
          _tags = tags;
          _isLoadingTags = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingTags = false;
        });
      }
    }
  }

  /// 进入多选模式
  void _enterMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = true;
      _selectedTrailIds.clear();
    });
  }

  /// 退出多选模式
  void _exitMultiSelectMode() {
    setState(() {
      _isMultiSelectMode = false;
      _selectedTrailIds.clear();
    });
  }

  /// 切换路线选择状态
  void _toggleTrailSelection(String trailId) {
    setState(() {
      if (_selectedTrailIds.contains(trailId)) {
        _selectedTrailIds.remove(trailId);
      } else {
        _selectedTrailIds.add(trailId);
      }
    });
  }

  /// 全选
  void _selectAllTrails() {
    if (_detail == null || _detail!.trails.isEmpty) return;
    
    setState(() {
      // 如果有搜索过滤，只选中过滤后的路线；否则选中所有路线
      final trailsToSelect = _searchQuery.isNotEmpty 
          ? _filteredTrails 
          : _detail!.trails;
      _selectedTrailIds.addAll(trailsToSelect.map((trail) => trail.trailId));
    });
  }

  /// 检查是否所有过滤后的路线都已选中
  bool _isAllFilteredTrailsSelected() {
    if (_detail == null || _detail!.trails.isEmpty) return false;
    
    final trailsToCheck = _searchQuery.isNotEmpty 
        ? _filteredTrails 
        : _detail!.trails;
    
    if (trailsToCheck.isEmpty) return false;
    
    return trailsToCheck.every((trail) => _selectedTrailIds.contains(trail.trailId));
  }

  /// 取消全选
  void _deselectAllTrails() {
    setState(() {
      _selectedTrailIds.clear();
    });
  }

  /// 取消选中所有过滤后的路线
  void _deselectAllFilteredTrails() {
    if (_detail == null || _detail!.trails.isEmpty) return;
    
    setState(() {
      final trailsToDeselect = _searchQuery.isNotEmpty 
          ? _filteredTrails 
          : _detail!.trails;
      for (final trail in trailsToDeselect) {
        _selectedTrailIds.remove(trail.trailId);
      }
    });
  }

  /// 处理搜索查询变化
  void _onSearchQueryChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    
    if (_detail != null) {
      _updateFilteredTrails();
    }
  }

  /// 更新过滤后的路线列表
  void _updateFilteredTrails() {
    if (_searchQuery.isEmpty) {
      _filteredTrails = _detail?.trails ?? [];
      return;
    }
    
    final query = _searchQuery.toLowerCase();
    _filteredTrails = _detail!.trails.where((trail) {
      return trail.name.toLowerCase().contains(query) ||
          (trail.description?.toLowerCase().contains(query) ?? false) ||
          (trail.note?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  /// 批量删除选中路线
  Future<void> _batchDeleteTrails() async {
    if (_selectedTrailIds.isEmpty) return;
    
    final confirmed = await CollectionBatchActionMenu.showDeleteConfirmationDialog(
      context: context,
      selectedCount: _selectedTrailIds.length,
    );
    
    if (!confirmed) return;
    
    // 显示进度指示器
    OverlayEntry? overlay;
    try {
      overlay = OverlayEntry(
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      Overlay.of(context).insert(overlay);
      
      // 调用批量删除API
      final result = await _collectionEnhancedService.batchRemoveTrailsFromCollection(
        collectionId: _collection.id,
        trailIds: _selectedTrailIds.toList(),
      );
      
      overlay.remove();
      overlay = null;
      
      // 处理结果
      if (result.success) {
        // 全部成功或部分成功
        if (result.failedIds != null && result.failedIds!.isNotEmpty) {
          // 部分成功场景
          final successCount = result.successCount;
          final failedCount = result.totalCount - result.successCount;
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已删除 $successCount 条路线，$failedCount 条删除失败'),
                duration: const Duration(seconds: 3),
              ),
            );
          }
          
          // 从选中列表中移除成功删除的ID（保留失败的ID）
          setState(() {
            _selectedTrailIds.removeWhere((id) => !result.failedIds!.contains(id));
          });
          
          // 如果还有失败的项，保持在多选模式，让用户重试
          if (_selectedTrailIds.isNotEmpty) {
            return;
          }
        } else {
          // 全部成功
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('已删除 ${_selectedTrailIds.length} 条路线'),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        }
        
        // 退出多选模式并刷新数据
        _exitMultiSelectMode();
        _loadDetail();
      } else {
        // 批量操作失败
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message.isEmpty ? '删除失败' : result.message),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
    } catch (e) {
      // 清理覆盖层
      if (overlay != null) {
        overlay.remove();
      }
      
      // 异常处理
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('删除失败: ${e.toString()}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  /// 批量移动选中路线
  Future<void> _batchMoveTrails() async {
    if (_selectedTrailIds.isEmpty) return;
    
    List<CollectionItem> collections;
    String targetCollectionId;
    CollectionItem targetCollection;
    
    try {
      // 获取用户的所有收藏夹列表
      final userCollections = await _collectionService.getCollections();
      
      // 过滤掉当前收藏夹，并转换为CollectionItem格式
      collections = userCollections
          .where((collection) => collection.id != _collection.id)
          .map((collection) => CollectionItem(
                id: collection.id,
                name: collection.name,
                trailCount: collection.trailCount,
                isDefault: collection.isDefault,
              ))
          .toList();
      
      // 如果没有其他收藏夹，提示用户
      if (collections.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('您还没有其他收藏夹，请先创建收藏夹')),
          );
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('获取收藏夹列表失败: $e')),
        );
      }
      return;
    }
    
    final selectedTargetCollectionId = await CollectionBatchActionMenu.showMoveToCollectionSelector(
      context: context,
      collections: collections,
      currentCollectionId: _collection.id,
    );
    
    if (selectedTargetCollectionId == null) return;
    
    targetCollectionId = selectedTargetCollectionId;
    targetCollection = collections.firstWhere(
      (c) => c.id == targetCollectionId,
      orElse: () => collections.first,
    );
    
    final confirmed = await CollectionBatchActionMenu.showMoveConfirmationDialog(
      context: context,
      selectedCount: _selectedTrailIds.length,
      targetCollectionName: targetCollection.name,
    );
    
    if (!confirmed) return;
    
    // 调用批量移动API
    // 显示进度指示器
    OverlayEntry? overlay;
    try {
      overlay = OverlayEntry(
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      Overlay.of(context).insert(overlay);
      
      final result = await _collectionEnhancedService.batchMoveTrails(
        sourceCollectionId: _collection.id,
        targetCollectionId: targetCollectionId,
        trailIds: _selectedTrailIds.toList(),
      );
      
      overlay.remove();
      overlay = null;
      
      if (!result.success) {
        throw Exception(result.message);
      }
      
      _exitMultiSelectMode();
      _loadDetail();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('已移动 ${result.successCount} 条路线到 "${targetCollection.name}"')),
        );
      }
    } catch (e) {
      // 清理覆盖层
      if (overlay != null) {
        overlay.remove();
      }
      
      _exitMultiSelectMode();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('移动失败: ${e.toString()}')),
        );
      }
    }
  }

  /// 批量添加标签到选中路线
  Future<void> _batchAddTags() async {
    if (_selectedTrailIds.isEmpty) return;
    
    // 显示批量添加标签对话框
    final selectedTagIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => _BatchAddTagsDialog(
        collectionId: _collection.id,
        trailIds: _selectedTrailIds.toList(),
        tagService: _tagService,
        collectionEnhancedService: _collectionEnhancedService,
      ),
    );
    
    if (selectedTagIds != null && selectedTagIds.isNotEmpty) {
      // 调用批量添加标签API
      await _performBatchAddTags(selectedTagIds);
    }
  }
  
  Future<void> _performBatchAddTags(List<String> tagIds) async {
    if (_selectedTrailIds.isEmpty || tagIds.isEmpty) return;
    
    // 显示进度指示器
    final overlay = OverlayEntry(
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    Overlay.of(context).insert(overlay);
    
    try {
      final result = await _collectionEnhancedService.batchAddTagsToTrails(
        collectionId: _collection.id,
        trailIds: _selectedTrailIds.toList(),
        tagIds: tagIds,
      );
      
      overlay.remove();
      
      if (result.success) {
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功为 ${result.successCount} 条路线添加标签'),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // 如果部分失败，显示详细信息
        if (result.failedIds != null && result.failedIds!.isNotEmpty) {
          final failedCount = result.totalCount - result.successCount;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${failedCount} 条路线标签添加失败，请重试'),
              duration: const Duration(seconds: 3),
            ),
          );
          
          // 保留失败的ID，让用户重试
          setState(() {
            _selectedTrailIds.retainAll(result.failedIds!);
          });
          
          if (_selectedTrailIds.isNotEmpty) {
            // 保持在多选模式
            return;
          }
        } else {
          // 全部成功，退出多选模式并刷新
          _exitMultiSelectMode();
          _loadDetail();
        }
      } else {
        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message.isEmpty ? '添加标签失败' : result.message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      overlay.remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('添加标签失败: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 批量分享选中路线
  Future<void> _batchShareTrails() async {
    if (_selectedTrailIds.isEmpty) return;
    
    // 1. 显示分享渠道选择器
    final shareChannel = await _showShareChannelSelector();
    if (shareChannel == null) return;
    
    // 2. 显示确认对话框
    final confirmed = await CollectionBatchActionMenu.showShareConfirmationDialog(
      context: context,
      selectedCount: _selectedTrailIds.length,
      shareChannel: shareChannel,
    );
    if (!confirmed) return;
    
    // 3. 执行批量分享（显示进度指示器）
    OverlayEntry? overlay;
    try {
      overlay = OverlayEntry(
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );
      Overlay.of(context).insert(overlay);
      
      final result = await _collectionEnhancedService.batchShareTrails(
        collectionId: _collection.id,
        trailIds: _selectedTrailIds.toList(),
        shareChannel: shareChannel,
        templateType: 'nature', // 默认使用自然模板
      );
      
      overlay.remove();
      overlay = null;
      
      if (!result.success) {
        throw Exception(result.message);
      }
      
      // 4. 显示结果
      if (result.successCount == result.totalCount) {
        // 全部成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功分享 ${result.successCount} 条路线'),
            duration: const Duration(seconds: 2),
          ),
        );
        _exitMultiSelectMode();
      } else if (result.successCount > 0) {
        // 部分成功
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功分享 ${result.successCount} 条路线，失败 ${result.totalCount - result.successCount} 条'),
            duration: const Duration(seconds: 3),
          ),
        );
        // 保留失败的ID，让用户重试
        if (result.failedIds != null && result.failedIds!.isNotEmpty) {
          setState(() {
            _selectedTrailIds.retainAll(result.failedIds!);
          });
          // 保持在多选模式
          return;
        }
      } else {
        // 全部失败
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('分享失败: ${result.message}'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      // 清理覆盖层
      if (overlay != null) {
        overlay.remove();
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('分享失败: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 显示分享渠道选择器
  Future<String?> _showShareChannelSelector() async {
    final selectedChannel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('选择分享渠道'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.wechat),
              title: const Text('微信好友'),
              onTap: () => Navigator.pop(context, 'wechat_session'),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('朋友圈'),
              onTap: () => Navigator.pop(context, 'wechat_timeline'),
            ),
            ListTile(
              leading: const Icon(Icons.download),
              title: const Text('保存图片'),
              onTap: () => Navigator.pop(context, 'save_local'),
            ),
            ListTile(
              leading: const Icon(Icons.copy),
              title: const Text('复制链接'),
              onTap: () => Navigator.pop(context, 'copy_link'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
        ],
      ),
    );
    return selectedChannel;
  }

  /// 批量移除标签从选中路线
  Future<void> _batchRemoveTags() async {
    if (_selectedTrailIds.isEmpty) return;
    
    // 显示批量移除标签对话框
    final selectedTagIds = await showDialog<List<String>>(
      context: context,
      builder: (context) => _BatchRemoveTagsDialog(
        collectionId: _collection.id,
        trailIds: _selectedTrailIds.toList(),
        tagService: _tagService,
        collectionEnhancedService: _collectionEnhancedService,
      ),
    );
    
    if (selectedTagIds != null && selectedTagIds.isNotEmpty) {
      // 调用批量移除标签API
      await _performBatchRemoveTags(selectedTagIds);
    }
  }
  
  Future<void> _performBatchRemoveTags(List<String> tagIds) async {
    if (_selectedTrailIds.isEmpty || tagIds.isEmpty) return;
    
    // 显示进度指示器
    final overlay = OverlayEntry(
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
    Overlay.of(context).insert(overlay);
    
    try {
      final result = await _collectionEnhancedService.batchRemoveTagsFromTrails(
        collectionId: _collection.id,
        trailIds: _selectedTrailIds.toList(),
        tagIds: tagIds,
      );
      
      overlay.remove();
      
      if (result.success) {
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('成功从 ${result.successCount} 条路线移除标签'),
            duration: const Duration(seconds: 2),
          ),
        );
        
        // 如果部分失败，显示详细信息
        if (result.failedIds != null && result.failedIds!.isNotEmpty) {
          final failedCount = result.totalCount - result.successCount;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${failedCount} 条路线标签移除失败，请重试'),
              duration: const Duration(seconds: 3),
            ),
          );
          
          // 保留失败的ID，让用户重试
          setState(() {
            _selectedTrailIds.retainAll(result.failedIds!);
          });
          
          if (_selectedTrailIds.isNotEmpty) {
            // 保持在多选模式
            return;
          }
        } else {
          // 全部成功，退出多选模式并刷新
          _exitMultiSelectMode();
          _loadDetail();
        }
      } else {
        // 显示错误消息
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message.isEmpty ? '移除标签失败' : result.message),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      overlay.remove();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('移除标签失败: $e'),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// 将CollectionBatchAction转换为CollectionBatchActionType
  CollectionBatchActionType _mapBatchAction(CollectionBatchAction action) {
    switch (action) {
      case CollectionBatchAction.delete:
        return CollectionBatchActionType.delete;
      case CollectionBatchAction.move:
        return CollectionBatchActionType.move;
      case CollectionBatchAction.tag:
        return CollectionBatchActionType.tag;
      case CollectionBatchAction.share:
        return CollectionBatchActionType.share;
      case CollectionBatchAction.cancel:
        return CollectionBatchActionType.cancel;
      case CollectionBatchAction.selectAll:
      case CollectionBatchAction.deselectAll:
        // 这些操作在批量操作栏中不直接支持
        return CollectionBatchActionType.cancel;
    }
  }

  /// 处理批量操作
  void _handleBatchAction(CollectionBatchActionType action) {
    switch (action) {
      case CollectionBatchActionType.delete:
        _batchDeleteTrails();
        break;
      case CollectionBatchActionType.move:
        _batchMoveTrails();
        break;
      case CollectionBatchActionType.tag:
        _batchAddTags();
        break;
      case CollectionBatchActionType.share:
        _batchShareTrails();
        break;
      case CollectionBatchActionType.cancel:
        _exitMultiSelectMode();
        break;
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
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverAppBar(),
              _buildBody(),
            ],
          ),
          
          // 批量操作栏（多选模式时显示）
          if (_isMultiSelectMode)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: CollectionBatchActionBar(
                selectedCount: _selectedTrailIds.length,
                availableActions: [
                  CollectionBatchActionType.delete,
                  CollectionBatchActionType.move,
                  CollectionBatchActionType.tag,
                  CollectionBatchActionType.share,
                ],
                onActionSelected: _handleBatchAction,
                onActionLongPressed: (action) {
                  if (action == CollectionBatchActionType.tag) {
                    _batchRemoveTags();
                  }
                },
                onCancel: _exitMultiSelectMode,
                showAtTop: false,
                showAnimation: true,
              ),
            ),
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
      actions: _isMultiSelectMode
          ? [
              IconButton(
                icon: const Icon(Icons.check_box),
                onPressed: _isAllFilteredTrailsSelected()
                    ? _deselectAllFilteredTrails
                    : _selectAllTrails,
                tooltip: _isAllFilteredTrailsSelected()
                    ? '取消全选'
                    : '全选',
              ),
            ]
          : [
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
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          child: Column(
            children: [
              // 搜索框
              if (!_isMultiSelectMode)
                SearchInput(
                  controller: _searchController,
                  hintText: '搜索收藏夹内的路线...',
                  showCancelButton: true,
                  autofocus: false,
                ),
              
              // 多选模式下的状态栏
              if (_isMultiSelectMode)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: _exitMultiSelectMode,
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        '已选 ${_selectedTrailIds.length} 项',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedTrailIds.isNotEmpty)
                        TextButton.icon(
                          onPressed: () {
                            // 显示批量操作菜单
                            CollectionBatchActionMenu.showBottomMenu(
                              context: context,
                              selectedCount: _selectedTrailIds.length,
                              availableActions: [
                                CollectionBatchAction.delete,
                                CollectionBatchAction.move,
                                CollectionBatchAction.tag,
                                CollectionBatchAction.share,
                              ],
                            ).then((action) {
                              if (action != null && action != CollectionBatchAction.cancel) {
                                _handleBatchAction(
                                  _mapBatchAction(action),
                                );
                              }
                            });
                          },
                          icon: const Icon(Icons.more_vert),
                          label: const Text('操作'),
                        ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
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

    // 计算要显示的路线列表
    final trailsToShow = _searchQuery.isEmpty
        ? _detail!.trails
        : _filteredTrails;
    
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
          
          // 标签管理区域
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '标签',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(width: 8),
                    if (!_isLoadingTags)
                      IconButton(
                        icon: const Icon(Icons.add, size: 16),
                        onPressed: () {
                          // 添加新标签
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('新建标签'),
                              content: TagEditor(
                                initialTags: _tags.map((tag) => tag.name).toList(),
                                onTagsChanged: (newTags) {
                                  // TODO: 更新收藏夹标签
                                },
                                collectionId: _collection.id,
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('取消'),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('保存'),
                                ),
                              ],
                            ),
                          );
                        },
                        tooltip: '添加标签',
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                _isLoadingTags
                    ? const CircularProgressIndicator()
                    : _tags.isEmpty
                        ? Text(
                            '暂无标签',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          )
                        : TagDisplay(
                            tags: _tags.map((tag) => tag.name).toList(),
                            mode: TagDisplayMode.chips,
                            onTagTap: (tag) {
                              // 按标签筛选路线
                              setState(() {
                                _searchQuery = tag;
                              });
                              _onSearchQueryChanged(tag);
                            },
                            onTagDelete: (tag) {
                              // TODO: 删除标签
                              setState(() {
                                _tags.removeWhere((t) => t.name == tag);
                              });
                            },
                            maxVisibleTags: 10,
                          ),
              ],
            ),
          ),
          
          const Divider(height: 1),
          
          // 搜索状态提示
          if (_searchQuery.isNotEmpty && trailsToShow.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '没有找到相关路线',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                    child: const Text('清空搜索'),
                  ),
                ],
              ),
            ),
          
          // 路线列表
          ...trailsToShow.map((trail) {
            final isSelected = _selectedTrailIds.contains(trail.trailId);
            
            // 使用多选卡片包装
            return CollectionMultiSelectCard(
              id: trail.trailId,
              isSelected: isSelected,
              isSelectionMode: _isMultiSelectMode,
              onTap: _isMultiSelectMode
                  ? () => _toggleTrailSelection(trail.trailId)
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrailDetailScreen(
                            trailId: trail.trailId,
                          ),
                        ),
                      ).then((_) => _loadDetail());
                    },
              onSelectTap: () {
                if (!_isMultiSelectMode) {
                  setState(() {
                    _isMultiSelectMode = true;
                  });
                }
                _toggleTrailSelection(trail.trailId);
              },
              child: CollectionTrailCard(
                trail: trail,
                onTap: null, // 由外层卡片处理
                onRemove: _isMultiSelectMode
                    ? null
                    : () => _removeTrail(trail.trailId),
                searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
              ),
            );
          }),
          
          // 批量操作栏（底部固定栏由Scaffold的bottomSheet处理）
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

/// 批量添加标签对话框
class _BatchAddTagsDialog extends StatefulWidget {
  final String collectionId;
  final List<String> trailIds;
  final TagService tagService;
  final CollectionEnhancedService collectionEnhancedService;

  const _BatchAddTagsDialog({
    required this.collectionId,
    required this.trailIds,
    required this.tagService,
    required this.collectionEnhancedService,
  });

  @override
  State<_BatchAddTagsDialog> createState() => __BatchAddTagsDialogState();
}

class __BatchAddTagsDialogState extends State<_BatchAddTagsDialog> {
  final List<CollectionTag> _availableTags = [];
  final Set<String> _selectedTagIds = {};
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final TextEditingController _newTagController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      final tags = await widget.tagService.getAllTags();
      setState(() {
        _availableTags.clear();
        _availableTags.addAll(tags);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载标签失败: $e';
        _isLoading = false;
      });
    }
  }

  List<CollectionTag> get _filteredTags {
    if (_searchQuery.isEmpty) return _availableTags;
    return _availableTags.where((tag) => 
      tag.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _toggleTagSelection(CollectionTag tag) {
    setState(() {
      if (_selectedTagIds.contains(tag.id)) {
        _selectedTagIds.remove(tag.id);
      } else {
        _selectedTagIds.add(tag.id);
      }
    });
  }

  Future<void> _createNewTag() async {
    final tagName = _newTagController.text.trim();
    if (tagName.isEmpty) return;
    
    try {
      final newTag = await widget.tagService.createTag(name: tagName);
      setState(() {
        _availableTags.add(newTag);
        _selectedTagIds.add(newTag.id);
      });
      _newTagController.clear();
      // 清除搜索
      _searchQuery = '';
      _searchController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('创建标签失败: $e'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('为 ${widget.trailIds.length} 条路线添加标签'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索标签...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            
            const SizedBox(height: 16),
            
            // 新标签创建
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _newTagController,
                    decoration: const InputDecoration(
                      hintText: '新建标签...',
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onSubmitted: (_) => _createNewTag(),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _createNewTag,
                  child: const Text('创建'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // 标签选择区域
            Text(
              '选择标签',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red))
            else if (_filteredTags.isEmpty)
              const Text('暂无标签', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filteredTags.map((tag) {
                  final isSelected = _selectedTagIds.contains(tag.id);
                  return FilterChip(
                    label: Text(tag.name),
                    selected: isSelected,
                    onSelected: (_) => _toggleTagSelection(tag),
                    backgroundColor: tag.color.withOpacity(0.1),
                    selectedColor: tag.color.withOpacity(0.3),
                    checkmarkColor: tag.color,
                    labelStyle: TextStyle(
                      color: isSelected ? tag.color : theme.colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 8),
            
            if (_selectedTagIds.isNotEmpty)
              Text(
                '已选择 ${_selectedTagIds.length} 个标签',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _selectedTagIds.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedTagIds.toList()),
          child: const Text('添加'),
        ),
      ],
    );
  }
}

/// 批量移除标签对话框
class _BatchRemoveTagsDialog extends StatefulWidget {
  final String collectionId;
  final List<String> trailIds;
  final TagService tagService;
  final CollectionEnhancedService collectionEnhancedService;

  const _BatchRemoveTagsDialog({
    required this.collectionId,
    required this.trailIds,
    required this.tagService,
    required this.collectionEnhancedService,
  });

  @override
  State<_BatchRemoveTagsDialog> createState() => __BatchRemoveTagsDialogState();
}

class __BatchRemoveTagsDialogState extends State<_BatchRemoveTagsDialog> {
  final List<CollectionTag> _availableTags = [];
  final Set<String> _selectedTagIds = {};
  bool _isLoading = true;
  String? _errorMessage;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      // TODO: 实际应该获取选中路线共有的标签，这里先获取所有标签
      final tags = await widget.tagService.getAllTags();
      setState(() {
        _availableTags.clear();
        _availableTags.addAll(tags);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = '加载标签失败: $e';
        _isLoading = false;
      });
    }
  }

  List<CollectionTag> get _filteredTags {
    if (_searchQuery.isEmpty) return _availableTags;
    return _availableTags.where((tag) => 
      tag.name.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

  void _toggleTagSelection(CollectionTag tag) {
    setState(() {
      if (_selectedTagIds.contains(tag.id)) {
        _selectedTagIds.remove(tag.id);
      } else {
        _selectedTagIds.add(tag.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Text('从 ${widget.trailIds.length} 条路线移除标签'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 搜索框
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索标签...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            
            const SizedBox(height: 16),
            
            // 标签选择区域
            Text(
              '选择要移除的标签',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red))
            else if (_filteredTags.isEmpty)
              const Text('暂无标签', style: TextStyle(color: Colors.grey))
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _filteredTags.map((tag) {
                  final isSelected = _selectedTagIds.contains(tag.id);
                  return FilterChip(
                    label: Text(tag.name),
                    selected: isSelected,
                    onSelected: (_) => _toggleTagSelection(tag),
                    backgroundColor: tag.color.withOpacity(0.1),
                    selectedColor: tag.color.withOpacity(0.3),
                    checkmarkColor: tag.color,
                    labelStyle: TextStyle(
                      color: isSelected ? tag.color : theme.colorScheme.onSurface,
                    ),
                  );
                }).toList(),
              ),
            
            const SizedBox(height: 8),
            
            if (_selectedTagIds.isNotEmpty)
              Text(
                '已选择 ${_selectedTagIds.length} 个标签',
                style: theme.textTheme.bodySmall,
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: _selectedTagIds.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selectedTagIds.toList()),
          child: const Text('移除'),
        ),
      ],
    );
  }
}
