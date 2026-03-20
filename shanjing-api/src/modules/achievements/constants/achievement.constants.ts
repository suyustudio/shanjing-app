// ================================================================
// 成就与推荐系统共享常量
// Achievement & Recommendation System Constants
// ================================================================

/**
 * 时间相关常量 (单位: 毫秒)
 */
export const TIME_CONSTANTS = {
  /** 1分钟 */
  ONE_MINUTE: 60 * 1000,
  /** 5分钟 */
  FIVE_MINUTES: 5 * 60 * 1000,
  /** 10分钟 */
  TEN_MINUTES: 10 * 60 * 1000,
  /** 30分钟 */
  THIRTY_MINUTES: 30 * 60 * 1000,
  /** 1小时 */
  ONE_HOUR: 60 * 60 * 1000,
  /** 24小时 */
  ONE_DAY: 24 * 60 * 60 * 1000,
  /** 30天 */
  THIRTY_DAYS: 30 * 24 * 60 * 60 * 1000,
  /** 90天 */
  NINETY_DAYS: 90 * 24 * 60 * 60 * 1000,
} as const;

/**
 * 距离相关常量 (单位: 米)
 */
export const DISTANCE_CONSTANTS = {
  /** 1公里 */
  ONE_KM: 1000,
  /** 10公里 */
  TEN_KM: 10 * 1000,
  /** 50公里 */
  FIFTY_KM: 50 * 1000,
  /** 100公里 */
  ONE_HUNDRED_KM: 100 * 1000,
  /** 最大参考距离 (用于推荐算法) */
  MAX_REFERENCE_DISTANCE_KM: 100,
  /** 地球半径 (米) - Haversine公式使用 */
  EARTH_RADIUS_METERS: 6371000,
} as const;

/**
 * 缓存TTL常量 (单位: 秒)
 */
export const CACHE_TTL = {
  /** 极短缓存: 2分钟 */
  VERY_SHORT: 120,
  /** 短缓存: 3分钟 */
  SHORT: 180,
  /** 中等缓存: 5分钟 */
  MEDIUM: 300,
  /** 长缓存: 10分钟 */
  LONG: 600,
  /** 持久缓存: 30分钟 */
  PERSISTENT: 1800,
} as const;

/**
 * 成就系统特定常量
 */
export const ACHIEVEMENT_CONSTANTS = {
  /** 成就缓存TTL (秒) */
  ACHIEVEMENT_CACHE_TTL: 300, // 5分钟
  /** 用户成就缓存TTL (秒) */
  USER_ACHIEVEMENT_CACHE_TTL: 180, // 3分钟
  /** 成就列表缓存键 */
  ACHIEVEMENT_LIST_CACHE_KEY: 'achievements:all',
  /** 用户成就缓存键前缀 */
  USER_ACHIEVEMENT_CACHE_PREFIX: 'achievements:user',
  /** 有效触发类型 */
  VALID_TRIGGER_TYPES: ['trail_completed', 'share', 'manual'] as const,
} as const;

/**
 * 推荐系统特定常量
 */
export const RECOMMENDATION_CONSTANTS = {
  /** 推荐缓存前缀 */
  CACHE_PREFIX: 'recommendation:',
  /** 热度缓存TTL (秒) */
  POPULARITY_CACHE_TTL: 300, // 5分钟
  /** 推荐结果缓存TTL (秒) */
  RECOMMENDATION_CACHE_TTL: 600, // 10分钟
  /** 新鲜度衰减天数 */
  FRESHNESS_DECAY_DAYS: 90,
  /** 最大难度差 */
  MAX_DIFFICULTY_DIFF: 3,
  /** 冷启动推荐倍数 */
  COLD_START_MULTIPLIER: 3,
  /** 首页推荐顶部路线数 */
  HOME_TOP_TRAILS_COUNT: 3,
  /** 新鲜度高分阈值 */
  FRESHNESS_HIGH_THRESHOLD: 0.7,
  /** 难度匹配高分阈值 */
  DIFFICULTY_MATCH_HIGH_THRESHOLD: 0.8,
  /** 距离高分阈值 */
  DISTANCE_HIGH_THRESHOLD: 0.7,
  /** 热度高分阈值 */
  POPULARITY_HIGH_THRESHOLD: 0.8,
  /** 评分高分阈值 */
  RATING_HIGH_THRESHOLD: 0.85,
  /** 附近推荐最大距离 (米) */
  NEARBY_MAX_DISTANCE_METERS: 50000, // 50km
  /** 距离加分阈值 (10公里内) */
  DISTANCE_BONUS_THRESHOLD_KM: 10,
  /** 距离减分阈值 (100公里外) */
  DISTANCE_PENALTY_THRESHOLD_KM: 100,
  /** 新路线保护期 (天) */
  NEW_TRAIL_PROTECTION_DAYS: 30,
  /** 最小评价数 (用于评分计算) */
  MIN_REVIEW_COUNT: 10,
  /** 默认评分 */
  DEFAULT_RATING: 3.5,
  /** 热度计算: 完成人数分母 */
  POPULARITY_COMPLETION_DENOMINATOR: 100,
  /** 热度计算: 收藏数分母 */
  POPULARITY_BOOKMARK_DENOMINATOR: 50,
  /** 热度分 - 完成权重 */
  POPULARITY_COMPLETION_WEIGHT: 0.6,
  /** 热度分 - 收藏权重 */
  POPULARITY_BOOKMARK_WEIGHT: 0.4,
  /** 新路线热度保底分 */
  NEW_TRAIL_BASE_POPULARITY_SCORE: 0.5,
  /** 冷启动默认匹配分 */
  COLD_START_DEFAULT_MATCH_SCORE: 0.8,
  /** 无位置默认距离分 */
  DEFAULT_DISTANCE_SCORE: 0.5,
  /** 无创建日期默认新鲜度分 */
  DEFAULT_FRESHNESS_SCORE: 0.5,
  /** 评价数过少保底分 */
  LOW_REVIEW_COUNT_SCORE: 0.7,
} as const;

/**
 * 难度映射常量
 * 前后端共享，确保一致性
 */
export const DIFFICULTY_MAP = {
  /** 简单 -> 数值1 */
  EASY: 1,
  /** 适中 -> 数值2 */
  MODERATE: 2,
  /** 困难 -> 数值3 */
  HARD: 3,
  /** 专家 -> 数值4 */
  EXPERT: 4,
} as const;

/**
 * 推荐场景缓存TTL配置 (秒)
 */
export const CACHE_TTL_BY_SCENE = {
  /** 首页推荐: 5分钟 */
  HOME: 300,
  /** 列表推荐: 10分钟 */
  LIST: 600,
  /** 详情推荐(相似路线): 30分钟 */
  SIMILAR: 1800,
  /** 附近推荐: 2分钟（位置敏感） */
  NEARBY: 120,
} as const;

/**
 * 算法权重配置
 */
export const ALGORITHM_WEIGHTS = {
  /** 默认场景权重 */
  DEFAULT: {
    difficultyMatch: 0.25,
    distance: 0.20,
    rating: 0.20,
    popularity: 0.20,
    freshness: 0.15,
  },
  /** 附近场景权重 (提升距离权重) */
  NEARBY: {
    difficultyMatch: 0.20,
    distance: 0.40,
    rating: 0.15,
    popularity: 0.15,
    freshness: 0.10,
  },
} as const;

/**
 * 事务配置常量
 */
export const TRANSACTION_CONFIG = {
  /** 最大等待时间 (毫秒) */
  MAX_WAIT_MS: 5000,
  /** 超时时间 (毫秒) */
  TIMEOUT_MS: 10000,
  /** 隔离级别 */
  ISOLATION_LEVEL: 'Serializable' as const,
} as const;

/**
 * 日志上下文常量
 */
export const LOG_CONTEXT = {
  /** 成就服务 */
  ACHIEVEMENTS_SERVICE: 'AchievementsService',
  /** 推荐服务 */
  RECOMMENDATION_SERVICE: 'RecommendationService',
  /** 推荐算法服务 */
  RECOMMENDATION_ALGORITHM_SERVICE: 'RecommendationAlgorithmService',
  /** 用户画像服务 */
  USER_PROFILE_SERVICE: 'UserProfileService',
} as const;

/**
 * 验证约束常量
 */
export const VALIDATION_CONSTRAINTS = {
  /** 最大距离 (米) */
  MAX_DISTANCE_METERS: 1000000, // 1000km
  /** 最大时长 (秒) */
  MAX_DURATION_SECONDS: 86400, // 24小时
  /** 最大返回数量 */
  MAX_LIMIT: 50,
  /** 最小返回数量 */
  MIN_LIMIT: 1,
  /** 默认返回数量 */
  DEFAULT_LIMIT: 10,
} as const;
