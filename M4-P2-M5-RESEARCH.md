# M4 P2 - M5 功能预研报告

> **报告版本**: v1.0  
> **生成日期**: 2026-03-19  > **报告状态**: 预研完成  
> **目标阶段**: M5 规划参考

---

## 1. 执行摘要

本报告对 M5 阶段建议实施的 3 个 P2 功能进行预研，提供竞品分析、技术方案、工时估算和实施建议。

| 功能 | 优先级 | 预估工时 | 技术复杂度 | 实施建议 |
|------|--------|----------|------------|----------|
| 新手引导 | P2 | 10h | 低 | M5 早期实施 |
| 成就系统 | P2 | 16h | 中 | M5 中期实施 |
| 路线推荐 | P2 | 12h | 中 | M5 后期实施，依赖数据积累 |

---

## 2. 新手引导功能调研

### 2.1 功能概述

新手引导帮助首次使用用户快速了解核心功能，提升留存率。

### 2.2 竞品分析

#### Keep
- **引导形式**: 全屏遮罩 + 高亮提示
- **引导内容**: 首页功能入口、运动记录、社区
- **交互方式**: 点击"下一步"，可跳过
- **时长**: 约 30 秒

#### 两步路
- **引导形式**: 底部弹窗 + 页面内提示
- **引导内容**: 记录轨迹、发现路线、离线地图
- **交互方式**: 自动播放 + 手动控制
- **特色**: 首次记录时动态引导

#### AllTrails
- **引导形式**: 沉浸式全屏
- **引导内容**: 搜索、筛选、导航、记录
- **交互方式**: 滑动翻页，最后进入APP
- **特色**: 精美插画，品牌感强

### 2.3 推荐方案

#### 引导流程设计

```
Step 1: 欢迎页（品牌介绍）
  - 山径 Logo + Slogan
  - 核心价值：发现城市中的自然
  - 按钮：[开始探索]

Step 2: 权限说明
  - 位置权限：用于导航和记录
  - 存储权限：用于保存离线地图
  - 通知权限：安全提醒
  - 按钮：[允许] [稍后]

Step 3: 核心功能介绍（3页轮播）
  页1: 发现路线
    - 插图：地图上的路线
    - 文案：发现身边的徒步路线
  页2: 离线导航
    - 插图：无信号导航
    - 文案：没信号也能安心走
  页3: 安全求助
    - 插图：SOS按钮
    - 文案：一键求助，守护安全

Step 4: 场景化引导
  - 进入首页后，高亮"附近路线"
  - 提示：点击这里发现附近路线
```

#### 技术实现

```dart
// 新手引导状态管理
class OnboardingService {
  static const String KEY_COMPLETED = 'onboarding_completed';
  
  static Future<bool> isCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(KEY_COMPLETED) ?? false;
  }
  
  static Future<void> markCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_COMPLETED, true);
  }
  
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(KEY_COMPLETED, false);
  }
}

// 引导页面
class OnboardingScreen extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    return PageView(
      children: [
        WelcomePage(),
        PermissionPage(),
        FeaturePage(index: 0),
        FeaturePage(index: 1),
        FeaturePage(index: 2),
      ],
    );
  }
}

// 场景化引导（首页高亮）
class SpotlightOverlay extends StatelessWidget {
  final Widget child;
  final String targetKey;
  final String description;
  
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 遮罩层
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black54,
            BlendMode.srcOut,
          ),
          child: child,
        ),
        // 高亮区域
        Positioned(
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
        // 说明文字
        Positioned(
          child: Text(description, style: highlightTextStyle),
        ),
      ],
    );
  }
}
```

### 2.4 工时估算

| 模块 | 工时 | 说明 |
|------|------|------|
| 引导页面UI | 4h | 4个页面，含动画 |
| 权限申请集成 | 2h | 位置/存储/通知 |
| 状态管理 | 2h | 本地存储，跳过逻辑 |
| 场景化高亮 | 2h | 首页路线入口高亮 |
| **总计** | **10h** | - |

### 2.5 验收标准

- [ ] 首次安装显示引导流程
- [ ] 可随时跳过引导
- [ ] 权限申请不阻塞流程
- [ ] 完成引导后不再显示
- [ ] 引导完成率 > 80%

---

## 3. 成就系统功能调研

### 2.1 功能概述

成就系统通过徽章和进度激励用户持续使用，增强产品粘性。

### 2.2 竞品分析

#### Keep
- **成就类型**: 运动数据类、社交类、挑战类
- **展示位置**: 个人中心 - 我的徽章
- **等级体系**: 铜/银/金/钻石四级
- **特色**: 与运动数据深度绑定

#### Nike Run Club
- **成就类型**: 距离里程碑、频率挑战、特殊活动
- **视觉风格**: 极简，黑白+品牌色
- **分享功能**: 一键生成成就海报
- **特色**: 与真实赛事联动

#### Strava
- **成就类型**: 路段纪录、挑战完成、年度统计
- **社交属性**: 成就可分享，好友可见
- **数据维度**: 距离、海拔、速度、频率
- **特色**: 专业运动数据分析

### 2.3 推荐方案

#### 成就体系设计

**成就分类:**

| 类别 | 说明 | 示例 |
|------|------|------|
| 探索类 | 完成路线 | 首次徒步、路线收集家 |
| 里程类 | 累计距离 | 百公里行者、千里达人 |
| 频率类 | 坚持徒步 | 周行者、月行者、年行者 |
| 挑战类 | 特殊成就 | 夜行者、雨中行、独行者 |
| 社交类 | 分享互动 | 分享达人、点赞狂人 |

**成就等级:**

```
探索类 - 路线收集家
├── 铜：完成 5 条不同路线
├── 银：完成 15 条不同路线
├── 金：完成 30 条不同路线
└── 钻石：完成 50 条不同路线

里程类 - 行者无疆
├── 铜：累计 10 公里
├── 银：累计 50 公里
├── 金：累计 100 公里
└── 钻石：累计 500 公里

频率类 - 周行者
├── 铜：连续 2 周每周徒步
├── 银：连续 4 周每周徒步
├── 金：连续 8 周每周徒步
└── 钻石：连续 16 周每周徒步
```

#### 技术实现

```dart
// 成就定义
class Achievement {
  final String id;
  final String name;
  final String description;
  final String icon;
  final AchievementType type;
  final List<AchievementLevel> levels;
  final bool isHidden;  // 隐藏成就
}

class AchievementLevel {
  final String level;  // bronze/silver/gold/diamond
  final int requirement;
  final String reward;
}

// 成就服务
class AchievementService {
  // 检查并解锁成就
  static Future<List<Achievement>> checkAchievements(UserStats stats) async {
    final unlocked = <Achievement>[];
    
    // 检查探索类成就
    final uniqueTrails = await getUniqueCompletedTrails();
    if (uniqueTrails.length >= 5) {
      unlocked.add(await unlock('explorer_bronze'));
    }
    
    // 检查里程类成就
    final totalDistance = await getTotalDistance();
    if (totalDistance >= 10000) {  // 10km
      unlocked.add(await unlock('distance_bronze'));
    }
    
    // 检查频率类成就
    final weeklyStreak = await getWeeklyStreak();
    if (weeklyStreak >= 2) {
      unlocked.add(await unlock('weekly_bronze'));
    }
    
    return unlocked;
  }
  
  // 解锁成就
  static Future<Achievement> unlock(String achievementId) async {
    final achievement = await _fetchAchievement(achievementId);
    await _saveToUser(achievement);
    await _showUnlockAnimation(achievement);
    return achievement;
  }
  
  // 获取用户成就列表
  static Future<List<UserAchievement>> getUserAchievements() async {
    // 查询用户已解锁成就
  }
}

// 成就解锁动画
class AchievementUnlockAnimation extends StatelessWidget {
  final Achievement achievement;
  
  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(seconds: 1),
      child: Column(
        children: [
          // 徽章图标放大动画
          ScaleTransition(
            scale: _animation,
            child: Image.asset(achievement.icon),
          ),
          Text('解锁成就', style: titleStyle),
          Text(achievement.name, style: nameStyle),
          Text(achievement.description, style: descStyle),
        ],
      ),
    );
  }
}
```

#### 数据库设计

```sql
-- 成就定义表
CREATE TABLE achievements (
    id VARCHAR(32) PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    description TEXT,
    category VARCHAR(32) NOT NULL,  -- explore/distance/frequency/challenge/social
    icon_url VARCHAR(256),
    is_hidden BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT NOW()
);

-- 成就等级表
CREATE TABLE achievement_levels (
    id SERIAL PRIMARY KEY,
    achievement_id VARCHAR(32) REFERENCES achievements(id),
    level VARCHAR(16) NOT NULL,  -- bronze/silver/gold/diamond
    requirement INTEGER NOT NULL,
    reward VARCHAR(128),
    UNIQUE(achievement_id, level)
);

-- 用户成就表
CREATE TABLE user_achievements (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(64) NOT NULL,
    achievement_id VARCHAR(32) REFERENCES achievements(id),
    level VARCHAR(16) NOT NULL,
    unlocked_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, achievement_id)
);

-- 用户统计表（用于成就计算）
CREATE TABLE user_stats (
    user_id VARCHAR(64) PRIMARY KEY,
    total_distance_m INTEGER DEFAULT 0,
    total_duration_sec INTEGER DEFAULT 0,
    unique_trails_count INTEGER DEFAULT 0,
    current_weekly_streak INTEGER DEFAULT 0,
    longest_weekly_streak INTEGER DEFAULT 0,
    last_trail_date DATE,
    updated_at TIMESTAMP DEFAULT NOW()
);
```

### 2.4 工时估算

| 模块 | 工时 | 说明 |
|------|------|------|
| 成就定义数据结构 | 2h | 等级、条件配置 |
| 成就检查逻辑 | 4h | 触发时机、条件计算 |
| 解锁动画UI | 3h | 动画效果、徽章展示 |
| 成就页面 | 3h | 列表、详情、分享 |
| 后端API | 4h | 查询、解锁、统计 |
| **总计** | **16h** | - |

### 2.5 验收标准

- [ ] 成就触发时机准确
- [ ] 解锁动画流畅
- [ ] 成就进度实时更新
- [ ] 支持生成分享海报
- [ ] 成就数据可持久化

---

## 4. 路线推荐算法调研

### 3.1 功能概述

根据用户历史行为、地理位置、偏好等推荐个性化路线。

### 3.2 竞品分析

#### Keep
- **推荐逻辑**: 基于位置 + 热门 + 历史偏好
- **排序因子**: 距离近、参与人数多、评分高
- **冷启动**: 默认推荐城市热门路线

#### 两步路
- **推荐逻辑**: 附近路线 + 难度匹配
- **筛选维度**: 距离、耗时、难度、类型
- **特色**: 用户上传路线占比高

#### AllTrails
- **推荐逻辑**: ML模型，多因子排序
- **输入特征**: 历史完成、收藏、评分、地理位置
- **实时性**: 根据天气、季节动态调整
- **特色**: 支持"像这条一样的"相似推荐

### 3.3 推荐方案

#### V1 简单规则推荐

**适用场景**: 初期数据量小，快速上线

```python
# 推荐算法 V1 - 规则-based
def recommend_trails_v1(user_id, lat, lng, limit=10):
    """
    推荐逻辑（按优先级排序）:
    1. 附近未完成的路线（距离 < 20km，按距离排序）
    2. 相似用户喜欢的路线（协同过滤简化版）
    3. 城市热门路线（按完成人数排序）
    4. 新上线路线（按发布时间排序）
    """
    
    # 1. 获取附近路线
    nearby = get_nearby_trails(lat, lng, radius_km=20)
    nearby_ids = [t.id for t in nearby]
    
    # 2. 获取用户已完成路线
    completed = get_user_completed_trails(user_id)
    completed_ids = set([t.id for t in completed])
    
    # 3. 过滤未完成
    candidates = [t for t in nearby if t.id not in completed_ids]
    
    # 4. 按距离排序
    candidates.sort(key=lambda t: t.distance_from_user)
    
    # 5. 如果不足，补充热门路线
    if len(candidates) < limit:
        popular = get_popular_trails(city=get_city(lat, lng), limit=limit)
        for p in popular:
            if p.id not in completed_ids and p.id not in [c.id for c in candidates]:
                candidates.append(p)
            if len(candidates) >= limit:
                break
    
    return candidates[:limit]
```

#### V2 个性化推荐

**适用场景**: 数据积累后，提升推荐质量

```python
# 用户画像特征
user_features = {
    'avg_distance': 用户平均徒步距离,
    'avg_duration': 用户平均徒步时长,
    'preferred_difficulty': 用户偏好难度,
    'preferred_scenery': 用户偏好景观类型,
    'active_time': 用户活跃时段,
    'weekend_ratio': 周末徒步比例,
}

# 路线特征
trail_features = {
    'distance_km': 路线距离,
    'duration_min': 预计耗时,
    'difficulty': 难度等级,
    'scenery_type': 景观类型,
    'elevation_gain': 累计爬升,
    'popularity': 热门程度,
    'rating': 平均评分,
}

# 推荐算法 V2 - 基于内容
def recommend_trails_v2(user_id, lat, lng, limit=10):
    """
    推荐逻辑:
    1. 构建用户画像
    2. 计算路线与用户的匹配度
    3. 排序返回
    """
    user = get_user_profile(user_id)
    candidates = get_candidate_trails(lat, lng, radius_km=50)
    
    scored_trails = []
    for trail in candidates:
        score = calculate_match_score(user, trail)
        scored_trails.append((trail, score))
    
    # 按匹配度排序
    scored_trails.sort(key=lambda x: x[1], reverse=True)
    
    return [t for t, s in scored_trails[:limit]]

def calculate_match_score(user, trail):
    """计算用户与路线的匹配分数"""
    score = 0
    
    # 距离偏好匹配 (0-25分)
    distance_diff = abs(user.avg_distance - trail.distance_km)
    score += max(0, 25 - distance_diff * 5)
    
    # 难度偏好匹配 (0-25分)
    difficulty_match = {
        ('easy', 'easy'): 25,
        ('medium', 'medium'): 25,
        ('hard', 'hard'): 25,
        ('easy', 'medium'): 15,
        ('medium', 'easy'): 15,
        ('medium', 'hard'): 10,
        ('hard', 'medium'): 10,
    }
    score += difficulty_match.get((user.preferred_difficulty, trail.difficulty), 5)
    
    # 景观类型匹配 (0-20分)
    if user.preferred_scenery == trail.scenery_type:
        score += 20
    
    # 热门程度 (0-15分)
    score += min(15, trail.popularity / 100)
    
    # 评分 (0-15分)
    score += trail.rating * 3
    
    return score
```

#### 推荐排序因子权重

| 因子 | 权重 | 说明 |
|------|------|------|
| 地理位置 | 30% | 距离越近越好 |
| 难度匹配 | 25% | 符合用户能力 |
| 距离偏好 | 20% | 符合用户习惯 |
| 评分 | 15% | 高质量优先 |
| 新鲜度 | 10% | 新路线适当加权 |

### 3.4 技术实现

```dart
// 推荐服务
class RecommendationService {
  static Future<List<Trail>> getRecommendations({
    required double lat,
    required double lng,
    int limit = 10,
  }) async {
    final response = await http.get(
      Uri.parse('${Config.apiBaseUrl}/recommendations'),
      headers: {'Authorization': 'Bearer $token'},
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return (data['trails'] as List)
          .map((t) => Trail.fromJson(t))
          .toList();
    }
    
    throw Exception('Failed to load recommendations');
  }
}

// 推荐页面
class RecommendationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Trail>>(
      future: RecommendationService.getRecommendations(
        lat: currentLocation.latitude,
        lng: currentLocation.longitude,
      ),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return TrailList(trails: snapshot.data!);
        }
        return LoadingIndicator();
      },
    );
  }
}
```

### 3.5 工时估算

| 模块 | 工时 | 说明 |
|------|------|------|
| 推荐算法 V1 | 4h | 规则-based |
| 推荐算法 V2 | 6h | 个性化匹配 |
| 推荐 API | 2h | 接口封装 |
| 推荐页面 | 2h | 列表展示 |
| **总计** | **12h** | V1优先，V2迭代 |

### 3.6 验收标准

- [ ] 推荐列表加载 < 1s
- [ ] 推荐准确率 > 60%（用户点击率）
- [ ] 冷启动有默认推荐
- [ ] 支持刷新获取新推荐
- [ ] 无网络时有缓存展示

---

## 5. 实施建议

### 5.1 优先级排序

| 排序 | 功能 | 理由 |
|------|------|------|
| 1 | 新手引导 | 提升新用户留存，低投入高回报 |
| 2 | 成就系统 | 提升用户粘性，数据可驱动推荐 |
| 3 | 路线推荐 | 依赖数据积累，M5后期实施 |

### 5.2 依赖关系

```
新手引导 ─────────────────┐
                          ├──> 路线推荐（需要用户画像数据）
成就系统 ──┬──> 用户行为数据 ─┘
           └──> 分享功能（成就分享）
```

### 5.3 M5 排期建议

| 阶段 | 功能 | 工时 | 里程碑 |
|------|------|------|--------|
| M5-Week 1 | 新手引导 | 10h | 新用户留存提升 |
| M5-Week 2-3 | 成就系统 | 16h | 用户粘性提升 |
| M5-Week 4 | 推荐 V1 | 6h | 基础推荐上线 |
| M5-Week 5-6 | 推荐 V2 | 6h | 个性化推荐 |

---

## 6. 附录

### 6.1 相关文档

| 文档 | 路径 | 说明 |
|------|------|------|
| M4 功能规划 | M4-FEATURE-PLAN.md | 当前阶段规划 |
| 用户反馈方案 | M4-USER-FEEDBACK.md | 用户需求来源 |
| 数据埋点规范 | data-tracking-spec-v1.2.md | 行为数据采集 |

### 6.2 变更记录

| 版本 | 日期 | 变更内容 |
|------|------|----------|
| v1.0 | 2026-03-19 | 初版完成，3个功能预研完成 |

---

> **报告编写**: Product Agent  
> **参考对象**: AllTrails（专业）、Keep（大众）、两步路（本土）  
> **建议**: 新手引导优先，成就系统跟进，推荐算法数据驱动迭代
