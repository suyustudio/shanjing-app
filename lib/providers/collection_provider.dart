// collection_provider.dart
// 山径APP - 收藏夹状态管理

import 'package:flutter/foundation.dart';
import '../models/collection_model.dart';
import '../services/collection_service.dart';

/// 收藏夹状态管理
class CollectionProvider extends ChangeNotifier {
  final CollectionService _service = CollectionService();
  
  List<Collection> _collections = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Collection> get collections => _collections;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// 默认收藏夹
  Collection? get defaultCollection => 
      _collections.firstWhere((c) => c.isDefault, orElse: () => null as Collection);

  /// 加载收藏夹列表
  Future<void> loadCollections({bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _collections = await _service.getCollections(forceRefresh: forceRefresh);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 创建收藏夹
  Future<bool> createCollection({
    required String name,
    String? description,
    bool isPublic = true,
  }) async {
    final result = await _service.createCollection(
      name: name,
      description: description,
      isPublic: isPublic,
    );

    if (result.success) {
      await loadCollections(forceRefresh: true);
      return true;
    }
    
    _error = result.message;
    notifyListeners();
    return false;
  }

  /// 删除收藏夹
  Future<bool> deleteCollection(String collectionId) async {
    final result = await _service.deleteCollection(collectionId);

    if (result.success) {
      _collections.removeWhere((c) => c.id == collectionId);
      notifyListeners();
      return true;
    }
    
    _error = result.message;
    notifyListeners();
    return false;
  }

  /// 添加路线到收藏夹
  Future<bool> addTrailToCollection({
    required String collectionId,
    required String trailId,
    String? note,
  }) async {
    final result = await _service.addTrailToCollection(
      collectionId: collectionId,
      trailId: trailId,
      note: note,
    );

    if (result.success) {
      // 更新本地计数
      final index = _collections.indexWhere((c) => c.id == collectionId);
      if (index != -1) {
        _collections[index] = _collections[index].copyWith(
          trailCount: _collections[index].trailCount + 1,
        );
        notifyListeners();
      }
      return true;
    }
    
    return false;
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
