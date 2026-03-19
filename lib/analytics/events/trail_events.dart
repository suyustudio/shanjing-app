/// 路线交互相关事件定义
class TrailEvents {
  TrailEvents._();

  // ===== 事件名称 =====
  static const String trailView = 'trail_view';
  static const String trailFavorite = 'trail_favorite';
  static const String trailShare = 'trail_share';
  static const String trailDownload = 'trail_download';
  static const String trailNavigateStart = 'trail_navigate_start';
  // ✅ 修正：使用 trail_navigate_complete 而不是 trail_complete（根据埋点规范 v1.2）
  static const String trailNavigateComplete = 'trail_navigate_complete';

  // ===== 参数键名 =====
  static const String paramRouteId = 'route_id';
  static const String paramRouteName = 'route_name';
  static const String paramDifficulty = 'difficulty';
  static const String paramDuration = 'duration';
  static const String paramDistance = 'distance';
  static const String paramSource = 'source';
  static const String paramFavoriteAction = 'action'; // add/remove
  static const String paramShareChannel = 'channel';
  static const String paramCompletionTime = 'completion_time';
  
  // ===== 新增参数键名（符合 data-tracking-spec-v1.2） =====
  static const String paramCompletionType = 'completion_type'; // auto/manual/checkpoint
  static const String paramActualDistanceM = 'actual_distance_m';
  static const String paramActualDurationSec = 'actual_duration_sec';
  static const String paramPlannedDistanceM = 'planned_distance_m';
  static const String paramPlannedDurationMin = 'planned_duration_min';
  static const String paramDeviationCount = 'deviation_count';
  static const String paramAvgSpeedMs = 'avg_speed_ms';
  static const String paramPauseCount = 'pause_count';
  static const String paramPauseDurationSec = 'pause_duration_sec';
  static const String paramPhotoCount = 'photo_count';
  static const String paramCompletionTimestamp = 'completion_timestamp';
  static const String paramRating = 'rating';
}
