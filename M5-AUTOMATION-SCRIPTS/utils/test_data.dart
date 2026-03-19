// M5 测试数据定义
// 包含测试用例所需的模拟数据

/// 成就测试数据
class AchievementTestData {
  
  /// 测试用户数据
  static final Map<String, UserProfile> testUsers = {
    'user_a': UserProfile(
      id: 'user_a',
      name: '测试用户A-新手',
      completedTrails: 3,
      totalDistanceKm: 8,
      weeklyStreak: 0,
      shareCount: 2,
    ),
    'user_b': UserProfile(
      id: 'user_b',
      name: '测试用户B-活跃',
      completedTrails: 12,
      totalDistanceKm: 60,
      weeklyStreak: 3,
      shareCount: 8,
    ),
    'user_c': UserProfile(
      id: 'user_c',
      name: '测试用户C-资深',
      completedTrails: 35,
      totalDistanceKm: 250,
      weeklyStreak: 10,
      shareCount: 25,
    ),
  };
  
  /// 探索类成就测试数据
  static final List<AchievementTestCase> explorerCases = [
    AchievementTestCase(
      name: '铜级触发',
      completedTrails: 5,
      expectedLevel: 'bronze',
      expectedUnlock: true,
    ),
    AchievementTestCase(
      name: '银级触发',
      completedTrails: 15,
      expectedLevel: 'silver',
      expectedUnlock: true,
    ),
    AchievementTestCase(
      name: '金级触发',
      completedTrails: 30,
      expectedLevel: 'gold',
      expectedUnlock: true,
    ),
    AchievementTestCase(
      name: '钻石级触发',
      completedTrails: 50,
      expectedLevel: 'diamond',
      expectedUnlock: true,
    ),
    AchievementTestCase(
      name: '临界值-未触发',
      completedTrails: 4,
      expectedLevel: null,
      expectedUnlock: false,
    ),
    AchievementTestCase(
      name: '临界值-刚好触发',
      completedTrails: 5,
      expectedLevel: 'bronze',
      expectedUnlock: true,
    ),
  ];
  
  /// 里程类成就测试数据
  static final List<AchievementTestCase> distanceCases = [
    AchievementTestCase(
      name: '铜级-10km',
      totalDistanceMeters: 10000,
      expectedLevel: 'bronze',
    ),
    AchievementTestCase(
      name: '银级-50km',
      totalDistanceMeters: 50000,
      expectedLevel: 'silver',
    ),
    AchievementTestCase(
      name: '金级-100km',
      totalDistanceMeters: 100000,
      expectedLevel: 'gold',
    ),
    AchievementTestCase(
      name: '钻石级-500km',
      totalDistanceMeters: 500000,
      expectedLevel: 'diamond',
    ),
  ];
  
  /// 频率类成就测试数据
  static final List<AchievementTestCase> weeklyCases = [
    AchievementTestCase(
      name: '铜级-2周',
      weeklyStreak: 2,
      expectedLevel: 'bronze',
    ),
    AchievementTestCase(
      name: '银级-4周',
      weeklyStreak: 4,
      expectedLevel: 'silver',
    ),
    AchievementTestCase(
      name: '金级-8周',
      weeklyStreak: 8,
      expectedLevel: 'gold',
    ),
    AchievementTestCase(
      name: '钻石级-16周',
      weeklyStreak: 16,
      expectedLevel: 'diamond',
    ),
  ];
  
  /// 成就定义数据
  static final List<AchievementDefinition> achievementDefinitions = [
    AchievementDefinition(
      id: 'explorer',
      name: '路线收集家',
      category: 'explore',
      levels: [
        LevelDefinition(level: 'bronze', requirement: 5, label: '铜'),
        LevelDefinition(level: 'silver', requirement: 15, label: '银'),
        LevelDefinition(level: 'gold', requirement: 30, label: '金'),
        LevelDefinition(level: 'diamond', requirement: 50, label: '钻石'),
      ],
    ),
    AchievementDefinition(
      id: 'distance',
      name: '行者无疆',
      category: 'distance',
      levels: [
        LevelDefinition(level: 'bronze', requirement: 10000, label: '铜'),
        LevelDefinition(level: 'silver', requirement: 50000, label: '银'),
        LevelDefinition(level: 'gold', requirement: 100000, label: '金'),
        LevelDefinition(level: 'diamond', requirement: 500000, label: '钻石'),
      ],
    ),
    AchievementDefinition(
      id: 'weekly',
      name: '周行者',
      category: 'frequency',
      levels: [
        LevelDefinition(level: 'bronze', requirement: 2, label: '铜'),
        LevelDefinition(level: 'silver', requirement: 4, label: '银'),
        LevelDefinition(level: 'gold', requirement: 8, label: '金'),
        LevelDefinition(level: 'diamond', requirement: 16, label: '钻石'),
      ],
    ),
    AchievementDefinition(
      id: 'night_walker',
      name: '夜行者',
      category: 'challenge',
      isHidden: true,
      levels: [
        LevelDefinition(level: 'bronze', requirement: 1, label: '铜'),
      ],
    ),
    AchievementDefinition(
      id: 'rain_walker',
      name: '雨中行',
      category: 'challenge',
      isHidden: true,
      levels: [
        LevelDefinition(level: 'bronze', requirement: 1, label: '铜'),
      ],
    ),
    AchievementDefinition(
      id: 'sharer',
      name: '分享达人',
      category: 'social',
      levels: [
        LevelDefinition(level: 'bronze', requirement: 10, label: '铜'),
        LevelDefinition(level: 'silver', requirement: 30, label: '银'),
        LevelDefinition(level: 'gold', requirement: 100, label: '金'),
        LevelDefinition(level: 'diamond', requirement: 500, label: '钻石'),
      ],
    ),
  ];
}

/// 推荐算法测试数据
class RecommendationTestData {
  
  /// 测试路线数据
  static final List<TrailData> trails = [
    // 杭州路线
    TrailData(
      id: 'hz_001',
      name: '九溪烟树',
      city: '杭州',
      lat: 30.2001,
      lng: 120.1201,
      difficulty: 'easy',
      distanceKm: 3.5,
      durationMin: 90,
      sceneryType: 'forest',
      elevationGain: 150,
      rating: 4.8,
      popularity: 1500,
      createdAt: DateTime(2024, 1, 15),
    ),
    TrailData(
      id: 'hz_002',
      name: '龙井村环线',
      city: '杭州',
      lat: 30.2101,
      lng: 120.1301,
      difficulty: 'medium',
      distanceKm: 8.0,
      durationMin: 180,
      sceneryType: 'tea',
      elevationGain: 350,
      rating: 4.6,
      popularity: 1200,
      createdAt: DateTime(2024, 2, 10),
    ),
    TrailData(
      id: 'hz_003',
      name: '宝石山',
      city: '杭州',
      lat: 30.2601,
      lng: 120.1401,
      difficulty: 'easy',
      distanceKm: 2.5,
      durationMin: 60,
      sceneryType: 'mountain',
      elevationGain: 100,
      rating: 4.5,
      popularity: 2000,
      createdAt: DateTime(2024, 1, 5),
    ),
    TrailData(
      id: 'hz_004',
      name: '云栖竹径',
      city: '杭州',
      lat: 30.1801,
      lng: 120.1101,
      difficulty: 'hard',
      distanceKm: 12.0,
      durationMin: 300,
      sceneryType: 'bamboo',
      elevationGain: 600,
      rating: 4.7,
      popularity: 800,
      createdAt: DateTime(2024, 3, 1),
    ),
    
    // 上海路线
    TrailData(
      id: 'sh_001',
      name: '佘山徒步',
      city: '上海',
      lat: 31.1001,
      lng: 121.2001,
      difficulty: 'easy',
      distanceKm: 2.8,
      durationMin: 70,
      sceneryType: 'mountain',
      elevationGain: 80,
      rating: 4.2,
      popularity: 800,
      createdAt: DateTime(2024, 1, 20),
    ),
    TrailData(
      id: 'sh_002',
      name: '世纪公园环线',
      city: '上海',
      lat: 31.2201,
      lng: 121.5501,
      difficulty: 'easy',
      distanceKm: 5.0,
      durationMin: 120,
      sceneryType: 'park',
      elevationGain: 20,
      rating: 4.4,
      popularity: 1000,
      createdAt: DateTime(2024, 2, 5),
    ),
    
    // 北京路线
    TrailData(
      id: 'bj_001',
      name: '香山红叶',
      city: '北京',
      lat: 39.9901,
      lng: 116.1801,
      difficulty: 'medium',
      distanceKm: 8.5,
      durationMin: 200,
      sceneryType: 'mountain',
      elevationGain: 500,
      rating: 4.5,
      popularity: 3000,
      createdAt: DateTime(2024, 1, 1),
    ),
  ];
  
  /// 测试用户画像
  static final Map<String, UserPreference> userPreferences = {
    'user_x': UserPreference(
      userId: 'user_x',
      avgDistanceKm: 3.0,
      preferredDifficulty: 'easy',
      preferredScenery: 'forest',
      location: Location(lat: 30.2741, lng: 120.1551), // 杭州
    ),
    'user_y': UserPreference(
      userId: 'user_y',
      avgDistanceKm: 8.0,
      preferredDifficulty: 'medium',
      preferredScenery: 'mountain',
      location: Location(lat: 31.2304, lng: 121.4737), // 上海
    ),
    'user_z': UserPreference(
      userId: 'user_z',
      // 冷启动用户，无历史数据
      location: Location(lat: 30.2741, lng: 120.1551),
    ),
  };
  
  /// 推荐因子权重配置
  static const Map<String, double> factorWeights = {
    'location': 0.30,
    'difficulty': 0.25,
    'distance_preference': 0.20,
    'rating': 0.15,
    'freshness': 0.10,
  };
  
  /// 预期推荐结果
  static final Map<String, List<String>> expectedRecommendations = {
    'user_x': ['hz_001', 'hz_003', 'hz_002', 'sh_002'], // 杭州、简单、短距离优先
    'user_y': ['sh_002', 'bj_001', 'hz_002'], // 中长距离、medium难度
    'user_z': ['hz_003', 'hz_001', 'bj_001', 'hz_002'], // 热门高评分
  };
}

/// 新手引导测试数据
class OnboardingTestData {
  
  /// 引导步骤定义
  static final List<OnboardingStep> steps = [
    OnboardingStep(
      index: 0,
      name: 'welcome',
      title: '发现城市中的自然',
      description: '山径 - 您的城市徒步向导',
      hasSkip: false,
    ),
    OnboardingStep(
      index: 1,
      name: 'permission',
      title: '权限说明',
      description: '我们需要以下权限来提供服务',
      hasSkip: true,
    ),
    OnboardingStep(
      index: 2,
      name: 'feature_discovery',
      title: '发现路线',
      description: '探索身边的徒步路线',
      hasSkip: true,
    ),
    OnboardingStep(
      index: 3,
      name: 'feature_offline',
      title: '离线导航',
      description: '没信号也能安心走',
      hasSkip: true,
    ),
    OnboardingStep(
      index: 4,
      name: 'feature_safety',
      title: '安全求助',
      description: '一键求助，守护安全',
      hasSkip: true,
    ),
    OnboardingStep(
      index: 5,
      name: 'complete',
      title: '准备出发',
      description: '开始您的徒步之旅',
      hasSkip: false,
    ),
  ];
  
  /// 权限申请测试数据
  static final List<PermissionTestCase> permissionCases = [
    PermissionTestCase(
      type: 'location',
      title: '位置权限',
      description: '用于导航和记录您的徒步路线',
      required: true,
    ),
    PermissionTestCase(
      type: 'storage',
      title: '存储权限',
      description: '用于保存离线地图数据',
      required: false,
    ),
    PermissionTestCase(
      type: 'notification',
      title: '通知权限',
      description: '用于发送安全提醒',
      required: false,
    ),
  ];
  
  /// 完成率测试数据
  static const Map<String, int> completionRateExpected = {
    'total_users': 100,
    'min_completion': 80, // 80%完成率
    'max_skip_rate': 20,  // 20%跳过率
  };
}

/// 性能测试数据
class PerformanceTestData {
  
  /// 性能基准指标
  static const Map<String, PerformanceThreshold> thresholds = {
    'app_launch': PerformanceThreshold(
      metric: '冷启动时间',
      target: 2000,      // 2s
      warning: 3000,     // 3s
      critical: 5000,    // 5s
    ),
    'onboarding_animation': PerformanceThreshold(
      metric: '引导动画FPS',
      target: 60,
      warning: 55,
      critical: 45,
    ),
    'achievement_unlock': PerformanceThreshold(
      metric: '成就解锁动画FPS',
      target: 60,
      warning: 55,
      critical: 45,
    ),
    'recommendation_api': PerformanceThreshold(
      metric: '推荐API响应时间(ms)',
      target: 100,
      warning: 200,
      critical: 500,
    ),
    'recommendation_list': PerformanceThreshold(
      metric: '推荐列表加载时间(ms)',
      target: 1000,
      warning: 2000,
      critical: 3000,
    ),
    'memory_usage': PerformanceThreshold(
      metric: '内存占用(MB)',
      target: 100,
      warning: 150,
      critical: 200,
    ),
  };
  
  /// 并发测试参数
  static const Map<String, dynamic> concurrencyTest = {
    'users': 1000,
    'duration_sec': 60,
    'target_qps': 1000,
    'max_error_rate': 0.001, // 0.1%
  };
}

// ==================== 数据类定义 ====================

class UserProfile {
  final String id;
  final String name;
  final int completedTrails;
  final double totalDistanceKm;
  final int weeklyStreak;
  final int shareCount;
  
  UserProfile({
    required this.id,
    required this.name,
    required this.completedTrails,
    required this.totalDistanceKm,
    required this.weeklyStreak,
    required this.shareCount,
  });
}

class AchievementTestCase {
  final String name;
  final int? completedTrails;
  final int? totalDistanceMeters;
  final int? weeklyStreak;
  final String? expectedLevel;
  final bool? expectedUnlock;
  
  AchievementTestCase({
    required this.name,
    this.completedTrails,
    this.totalDistanceMeters,
    this.weeklyStreak,
    this.expectedLevel,
    this.expectedUnlock,
  });
}

class AchievementDefinition {
  final String id;
  final String name;
  final String category;
  final List<LevelDefinition> levels;
  final bool isHidden;
  
  AchievementDefinition({
    required this.id,
    required this.name,
    required this.category,
    required this.levels,
    this.isHidden = false,
  });
}

class LevelDefinition {
  final String level;
  final int requirement;
  final String label;
  
  LevelDefinition({
    required this.level,
    required this.requirement,
    required this.label,
  });
}

class TrailData {
  final String id;
  final String name;
  final String city;
  final double lat;
  final double lng;
  final String difficulty;
  final double distanceKm;
  final int durationMin;
  final String sceneryType;
  final int elevationGain;
  final double rating;
  final int popularity;
  final DateTime createdAt;
  
  TrailData({
    required this.id,
    required this.name,
    required this.city,
    required this.lat,
    required this.lng,
    required this.difficulty,
    required this.distanceKm,
    required this.durationMin,
    required this.sceneryType,
    required this.elevationGain,
    required this.rating,
    required this.popularity,
    required this.createdAt,
  });
}

class UserPreference {
  final String userId;
  final double? avgDistanceKm;
  final String? preferredDifficulty;
  final String? preferredScenery;
  final Location location;
  
  UserPreference({
    required this.userId,
    this.avgDistanceKm,
    this.preferredDifficulty,
    this.preferredScenery,
    required this.location,
  });
}

class Location {
  final double lat;
  final double lng;
  
  Location({required this.lat, required this.lng});
}

class OnboardingStep {
  final int index;
  final String name;
  final String title;
  final String description;
  final bool hasSkip;
  
  OnboardingStep({
    required this.index,
    required this.name,
    required this.title,
    required this.description,
    required this.hasSkip,
  });
}

class PermissionTestCase {
  final String type;
  final String title;
  final String description;
  final bool required;
  
  PermissionTestCase({
    required this.type,
    required this.title,
    required this.description,
    required this.required,
  });
}

class PerformanceThreshold {
  final String metric;
  final num target;
  final num warning;
  final num critical;
  
  PerformanceThreshold({
    required this.metric,
    required this.target,
    required this.warning,
    required this.critical,
  });
}
