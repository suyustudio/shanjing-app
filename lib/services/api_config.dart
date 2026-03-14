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
  
  /// API 版本前缀
  static const String apiVersion = '/api/v1';
  
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
