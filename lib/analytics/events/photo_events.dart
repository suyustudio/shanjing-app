// ================================================================
// M6: 照片系统埋点事件
// ================================================================

import '../../analytics_service.dart';

/// 照片系统埋点事件
class PhotoEvents {
  final AnalyticsService _analytics;

  PhotoEvents(this._analytics);

  /// 点击上传按钮
  void trackUploadClick({String? source}) {
    _analytics.track('photo_upload_click', {
      'source': source ?? 'unknown',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 上传成功
  void trackUploadSuccess({
    required int photoCount,
    bool hasLocation = false,
    bool hasDescription = false,
    String? trailId,
  }) {
    _analytics.track('photo_upload_success', {
      'photo_count': photoCount,
      'has_location': hasLocation,
      'has_description': hasDescription,
      'trail_id': trailId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 上传失败
  void trackUploadFailed({
    required String error,
    int? photoCount,
  }) {
    _analytics.track('photo_upload_failed', {
      'error': error,
      'photo_count': photoCount,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 查看瀑布流
  void trackWaterfallView({
    String? trailId,
    String sort = 'newest',
  }) {
    _analytics.track('photo_waterfall_view', {
      'trail_id': trailId,
      'sort': sort,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 查看照片详情
  void trackDetailView({
    required String photoId,
    String? source,
  }) {
    _analytics.track('photo_detail_view', {
      'photo_id': photoId,
      'source': source ?? 'waterfall',
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 点赞照片
  void trackLike({
    required String photoId,
    required bool isLiked,
  }) {
    _analytics.track('photo_like', {
      'photo_id': photoId,
      'is_liked': isLiked,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 收藏照片
  void trackSave({
    required String photoId,
    required bool isSaved,
  }) {
    _analytics.track('photo_save', {
      'photo_id': photoId,
      'is_saved': isSaved,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 删除照片
  void trackDelete({
    required String photoId,
  }) {
    _analytics.track('photo_delete', {
      'photo_id': photoId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 编辑照片信息
  void trackEdit({
    required String photoId,
    bool? descriptionChanged,
    bool? privacyChanged,
  }) {
    _analytics.track('photo_edit', {
      'photo_id': photoId,
      'description_changed': descriptionChanged,
      'privacy_changed': privacyChanged,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 下载照片
  void trackDownload({
    required String photoId,
  }) {
    _analytics.track('photo_download', {
      'photo_id': photoId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// 分享照片
  void trackShare({
    required String photoId,
    required String channel,
  }) {
    _analytics.track('photo_share', {
      'photo_id': photoId,
      'channel': channel,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
}
