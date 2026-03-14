/// 路线交互相关事件定义
class TrailEvents {
  TrailEvents._();

  // ===== 事件名称 =====
  static const String trailView = 'trail_view';
  static const String trailFavorite = 'trail_favorite';
  static const String trailShare = 'trail_share';
  static const String trailDownload = 'trail_download';
  static const String trailNavigateStart = 'trail_navigate_start';
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
}
