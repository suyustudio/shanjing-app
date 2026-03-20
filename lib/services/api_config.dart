/**
 * API 配置
 * 
 * 后端 API 基础配置和 URL 定义
 */

/// API 基础配置
class ApiConfig {
  /// 开发环境基础 URL
  static const String devBaseUrl = 'http://localhost:3000';
  
  /// 生产环境基础 URL（待配置）
  static const String prodBaseUrl = 'https://api.shanjing.app';
  
  /// 当前环境使用的 Base URL
  static const String baseUrl = devBaseUrl;
  
  /// API 版本前缀 (与后端 M6 统一)
  static const String apiVersion = '/v1';
  
  /// 完整 API 基础 URL
  static String get apiBaseUrl => baseUrl + apiVersion;
  
  /// 请求超时时间（秒）
  static const int timeoutSeconds = 30;
}

/// API 端点定义
class ApiEndpoints {
  // ========== 路线相关 ==========
  /// 路线列表
  static const String trails = '/trails';
  
  /// 路线详情（需要拼接路线ID）
  static String trailDetail(String trailId) => '/trails/$trailId';
  
  /// 推荐路线
  static const String recommendedTrails = '/trails/recommended';
  
  /// 附近路线
  static const String nearbyTrails = '/trails/nearby';
  
  // ========== 收藏相关 ==========
  /// 收藏列表
  static const String favorites = '/favorites';
  
  /// 切换收藏状态
  static const String toggleFavorite = '/favorites/toggle';
  
  /// 检查收藏状态（需要拼接路线ID）
  static String favoriteStatus(String trailId) => '/favorites/status/$trailId';
  
  /// 取消收藏（需要拼接路线ID）
  static String removeFavorite(String trailId) => '/favorites/$trailId';
  
  // ========== 收藏夹相关 (M6新增) ==========
  /// 收藏夹列表
  static const String collections = '/collections';
  
  /// 收藏夹详情
  static String collectionDetail(String collectionId) => '/collections/$collectionId';
  
  /// 收藏夹路线管理
  static String collectionTrails(String collectionId) => '/collections/$collectionId/trails';
  
  /// 移除收藏夹中的路线
  static String collectionTrailDetail(String collectionId, String trailId) => 
      '/collections/$collectionId/trails/$trailId';
  
  /// 排序收藏夹内路线
  static String collectionSort(String collectionId) => '/collections/$collectionId/sort';
  
  /// 快速收藏路线
  static String quickCollect(String trailId) => '/trails/$trailId/collect';
  
  // ========== 评论相关 (M6新增) ==========
  /// 获取路线评论列表 / 发表评论
  static String trailReviews(String trailId) => '/trails/$trailId/reviews';
  
  /// 评论详情 / 编辑 / 删除
  static String reviewDetail(String reviewId) => '/reviews/$reviewId';
  
  /// 点赞评论
  static String reviewLike(String reviewId) => '/reviews/$reviewId/like';
  
  /// 评论回复列表 / 发表回复
  static String reviewReplies(String reviewId) => '/reviews/$reviewId/replies';
  
  /// 举报评论
  static String reviewReport(String reviewId) => '/reviews/$reviewId/report';
  
  // ========== 用户相关 ==========
  /// 当前用户信息
  static const String currentUser = '/users/me';
  
  // ========== 地图相关 ==========
  /// 地理编码
  static const String geocode = '/map/geocode';
  
  /// 逆地理编码
  static const String regeocode = '/map/regeocode';
  
  /// 步行路线规划
  static const String walkingRoute = '/map/route/walking';
  
  /// 驾车路线规划
  static const String drivingRoute = '/map/route/driving';
  
  /// 骑行路线规划
  static const String bicyclingRoute = '/map/route/bicycling';
}
