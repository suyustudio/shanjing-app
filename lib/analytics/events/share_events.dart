/// 分享相关事件定义
class ShareEvents {
  ShareEvents._();

  // ===== 事件名称 =====
  static const String shareTrail = 'share_trail';
  static const String shareTrailSuccess = 'share_trail_success';
  static const String shareTrailFailed = 'share_trail_failed';
  static const String shareOpen = 'share_open';

  // ===== 参数键名 =====
  static const String paramTrailId = 'trail_id';
  static const String paramTrailName = 'trail_name';
  static const String paramShareCode = 'share_code';
  static const String paramShareChannel = 'share_channel';
  static const String paramErrorCode = 'error_code';
  
  // 新增的参数（符合 data-tracking-spec-v1.2）
  static const String paramRouteId = 'route_id';
  static const String paramRouteName = 'route_name';
  static const String paramTemplateType = 'template_type';
  static const String paramShareTimeMs = 'share_time_ms';
  static const String paramPosterSizeKb = 'poster_size_kb';
  static const String paramGenerationDurationMs = 'generation_duration_ms';
}