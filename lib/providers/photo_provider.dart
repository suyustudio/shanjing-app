// ================================================================
// M6: 照片 Provider (状态管理)
// ================================================================

import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/photo_model.dart';
import '../services/photo_service.dart';

class PhotoProvider extends ChangeNotifier {
  final PhotoService _photoService = PhotoService();

  // 照片列表
  List<Photo> _photos = [];
  List<Photo> get photos => _photos;

  // 用户照片
  List<Photo> _userPhotos = [];
  List<Photo> get userPhotos => _userPhotos;

  // 照片详情
  Photo? _currentPhoto;
  Photo? get currentPhoto => _currentPhoto;

  // 加载状态
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // 更多数据
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  // 分页游标
  String? _cursor;

  // 错误信息
  String? _error;
  String? get error => _error;

  /// 加载照片列表
  Future<void> loadPhotos({
    String? trailId,
    String? userId,
    String sort = 'newest',
    bool refresh = false,
  }) async {
    if (_isLoading) return;
    if (!refresh && !_hasMore) return;

    _isLoading = true;
    _error = null;
    if (refresh) {
      _cursor = null;
      _hasMore = true;
    }
    notifyListeners();

    try {
      final response = await _photoService.getPhotos(
        trailId: trailId,
        userId: userId,
        sort: sort,
        cursor: refresh ? null : _cursor,
        limit: 20,
      );

      if (refresh) {
        _photos = response.list;
      } else {
        _photos.addAll(response.list);
      }
      _cursor = response.nextCursor;
      _hasMore = response.hasMore;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载用户照片
  Future<void> loadUserPhotos(String userId, {bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _photoService.getUserPhotos(
        userId,
        cursor: refresh ? null : _cursor,
        limit: 20,
      );

      if (refresh) {
        _userPhotos = response.list;
      } else {
        _userPhotos.addAll(response.list);
      }
      _cursor = response.nextCursor;
      _hasMore = response.hasMore;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 加载照片详情
  Future<void> loadPhotoDetail(String photoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentPhoto = await _photoService.getPhotoDetail(photoId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 上传单张照片
  Future<Photo?> uploadPhoto({
    required File file,
    String? trailId,
    String? description,
    double? latitude,
    double? longitude,
    Function(double)? onProgress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final photo = await _photoService.uploadPhoto(
        file: file,
        trailId: trailId,
        description: description,
        latitude: latitude,
        longitude: longitude,
        onProgress: onProgress,
      );
      _photos.insert(0, photo);
      return photo;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 批量上传照片
  Future<List<Photo>?> uploadPhotos({
    required List<File> files,
    String? trailId,
    String? description,
    Function(int, int)? onProgress,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final photos = await _photoService.uploadPhotos(
        files: files,
        trailId: trailId,
        description: description,
        onProgress: onProgress,
      );
      _photos.insertAll(0, photos);
      return photos;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 更新照片
  Future<bool> updatePhoto(String photoId, UpdatePhotoRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updated = await _photoService.updatePhoto(photoId, request);
      
      // 更新本地数据
      final index = _photos.indexWhere((p) => p.id == photoId);
      if (index != -1) {
        _photos[index] = updated;
      }
      
      if (_currentPhoto?.id == photoId) {
        _currentPhoto = updated;
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 删除照片
  Future<bool> deletePhoto(String photoId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _photoService.deletePhoto(photoId);
      _photos.removeWhere((p) => p.id == photoId);
      _userPhotos.removeWhere((p) => p.id == photoId);
      
      if (_currentPhoto?.id == photoId) {
        _currentPhoto = null;
      }
      
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 点赞/取消点赞
  Future<bool> toggleLike(String photoId) async {
    try {
      final response = await _photoService.likePhoto(photoId);
      
      // 更新本地数据
      final index = _photos.indexWhere((p) => p.id == photoId);
      if (index != -1) {
        _photos[index] = _photos[index].copyWith(
          isLiked: response.isLiked,
          likeCount: response.likeCount,
        );
      }
      
      final userIndex = _userPhotos.indexWhere((p) => p.id == photoId);
      if (userIndex != -1) {
        _userPhotos[userIndex] = _userPhotos[userIndex].copyWith(
          isLiked: response.isLiked,
          likeCount: response.likeCount,
        );
      }
      
      if (_currentPhoto?.id == photoId) {
        _currentPhoto = _currentPhoto!.copyWith(
          isLiked: response.isLiked,
          likeCount: response.likeCount,
        );
      }
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  /// 清除错误
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// 重置状态
  void reset() {
    _photos = [];
    _userPhotos = [];
    _currentPhoto = null;
    _isLoading = false;
    _hasMore = true;
    _cursor = null;
    _error = null;
    notifyListeners();
  }
}
