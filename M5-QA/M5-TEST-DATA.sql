-- M5 阶段测试数据 SQL
-- 山径 App M5 功能测试数据准备
-- 版本: v1.0
-- 日期: 2026-03-20

-- ============================================================
-- 一、测试用户数据
-- ============================================================

-- 1.1 不同画像测试用户
INSERT INTO users (id, nickname, avatar, created_at, updated_at) VALUES
-- 新用户 (冷启动测试)
('user_newbie_001', '测试新用户1', 'https://cdn.shanjing.app/default-avatar.png', NOW(), NOW()),
('user_newbie_002', '测试新用户2', 'https://cdn.shanjing.app/default-avatar.png', NOW(), NOW()),

-- 轻度用户 (少量记录)
('user_light_001', '轻度用户1', 'https://cdn.shanjing.app/avatar1.png', DATE_SUB(NOW(), INTERVAL 30 DAY), NOW()),
('user_light_002', '轻度用户2', 'https://cdn.shanjing.app/avatar2.png', DATE_SUB(NOW(), INTERVAL 45 DAY), NOW()),

-- 中度用户 (常规使用)
('user_medium_001', '中度用户1', 'https://cdn.shanjing.app/avatar3.png', DATE_SUB(NOW(), INTERVAL 60 DAY), NOW()),
('user_medium_002', '中度用户2', 'https://cdn.shanjing.app/avatar4.png', DATE_SUB(NOW(), INTERVAL 90 DAY), NOW()),

-- 重度用户 (高频使用)
('user_heavy_001', '重度用户1', 'https://cdn.shanjing.app/avatar5.png', DATE_SUB(NOW(), INTERVAL 120 DAY), NOW()),
('user_heavy_002', '重度用户2', 'https://cdn.shanjing.app/avatar6.png', DATE_SUB(NOW(), INTERVAL 150 DAY), NOW()),

-- 成就测试专用用户
('user_ach_test_001', '成就测试用户1', 'https://cdn.shanjing.app/test-avatar.png', NOW(), NOW()),
('user_ach_test_002', '成就测试用户2', 'https://cdn.shanjing.app/test-avatar.png', NOW(), NOW()),
('user_ach_test_003', '成就测试用户3', 'https://cdn.shanjing.app/test-avatar.png', NOW(), NOW()),

-- 推荐算法测试用户
('user_rec_test_001', '推荐测试用户1', 'https://cdn.shanjing.app/rec-avatar.png', NOW(), NOW()),
('user_rec_test_002', '推荐测试用户2', 'https://cdn.shanjing.app/rec-avatar.png', NOW(), NOW()),
('user_rec_test_003', '推荐测试用户3', 'https://cdn.shanjing.app/rec-avatar.png', NOW(), NOW());

-- 1.2 用户配置数据 (用于推荐算法测试)
INSERT INTO user_preferences (user_id, preferred_difficulty, preferred_distance_min, preferred_distance_max, created_at, updated_at) VALUES
('user_rec_test_001', 2, 3000, 15000, NOW(), NOW()),  -- 偏好适中难度，3-15km
('user_rec_test_002', 1, 1000, 8000, NOW(), NOW()),   -- 偏好简单难度，1-8km
('user_rec_test_003', 3, 10000, 30000, NOW(), NOW()); -- 偏好困难难度，10-30km

-- ============================================================
-- 二、测试路线数据
-- ============================================================

-- 2.1 基础测试路线数据
INSERT INTO trails (id, name, description, distance, duration, difficulty, rating, rating_count, coordinates, region, created_at, updated_at) VALUES
-- 简单路线 (难度 1)
('trail_001', '九溪十八涧', '杭州经典入门徒步路线，沿途溪水潺潺', 3200, 5400, 1, 4.8, 156, 
 ST_GeomFromText('LINESTRING(120.12 30.22, 120.13 30.23, 120.14 30.24)'), '杭州西湖区', NOW(), NOW()),
('trail_002', '断桥残雪漫步', '西湖边轻松漫步路线', 2500, 3600, 1, 4.6, 89,
 ST_GeomFromText('LINESTRING(120.15 30.26, 120.16 30.27)'), '杭州西湖区', NOW(), NOW()),
('trail_003', '苏堤春晓', '西湖十景之一，平坦易行', 2800, 4200, 1, 4.7, 112,
 ST_GeomFromText('LINESTRING(120.13 30.24, 120.14 30.25)'), '杭州西湖区', NOW(), NOW()),

-- 适中路线 (难度 2)
('trail_004', '龙井村茶园', '茶园风光，略有起伏', 5500, 7200, 2, 4.5, 78,
 ST_GeomFromText('LINESTRING(120.10 30.20, 120.11 30.21, 120.12 30.22)'), '杭州西湖区', NOW(), NOW()),
('trail_005', '满觉陇桂花道', '秋季赏桂经典路线', 4800, 6300, 2, 4.4, 65,
 ST_GeomFromText('LINESTRING(120.11 30.21, 120.12 30.22)'), '杭州西湖区', NOW(), NOW()),
('trail_006', '云栖竹径', '竹林深处，幽静清凉', 6200, 7800, 2, 4.6, 92,
 ST_GeomFromText('LINESTRING(120.09 30.19, 120.10 30.20)'), '杭州西湖区', NOW(), NOW()),

-- 困难路线 (难度 3)
('trail_007', '宝石山攀登', '需要一定体力，风景绝佳', 8200, 10800, 3, 4.7, 134,
 ST_GeomFromText('LINESTRING(120.14 30.25, 120.15 30.26, 120.16 30.27)'), '杭州西湖区', NOW(), NOW()),
('trail_008', '玉皇山环线', '全程有挑战，适合进阶', 9500, 12600, 3, 4.5, 87,
 ST_GeomFromText('LINESTRING(120.15 30.25, 120.16 30.26)'), '杭州西湖区', NOW(), NOW()),
('trail_009', '十里琅珰', '山脊行走，视野开阔', 8800, 11400, 3, 4.8, 156,
 ST_GeomFromText('LINESTRING(120.11 30.22, 120.12 30.23, 120.13 30.24)'), '杭州西湖区', NOW(), NOW()),

-- 专家路线 (难度 4)
('trail_010', '灵峰探梅大环线', '长距离高难度路线', 15200, 18000, 4, 4.6, 45,
 ST_GeomFromText('LINESTRING(120.10 30.20, 120.11 30.21, 120.12 30.22, 120.13 30.23)'), '杭州西湖区', NOW(), NOW()),
('trail_011', '天目山穿越', '专业级徒步路线', 28500, 28800, 4, 4.8, 34,
 ST_GeomFromText('LINESTRING(119.50 30.40, 119.52 30.42)'), '杭州临安区', NOW(), NOW()),

-- 不同评分测试数据
('trail_low_rating', '测试低评分路线', '用于测试评分因子', 5000, 6000, 2, 2.5, 20,
 ST_GeomFromText('LINESTRING(120.20 30.30, 120.21 30.31)'), '测试区域', NOW(), NOW()),
('trail_high_rating', '测试高评分路线', '用于测试评分因子', 5000, 6000, 2, 5.0, 200,
 ST_GeomFromText('LINESTRING(120.22 30.32, 120.23 30.33)'), '测试区域', NOW(), NOW()),

-- 不同新鲜度测试数据 (不同创建时间)
('trail_fresh_new', '全新上线路线', '用于测试新鲜度因子', 6000, 7500, 2, 4.5, 5,
 ST_GeomFromText('LINESTRING(120.24 30.34, 120.25 30.35)'), '测试区域', NOW(), NOW()),
('trail_fresh_old', '旧路线测试', '用于测试新鲜度因子', 6000, 7500, 2, 4.5, 150,
 ST_GeomFromText('LINESTRING(120.26 30.36, 120.27 30.37)'), '测试区域', DATE_SUB(NOW(), INTERVAL 100 DAY), DATE_SUB(NOW(), INTERVAL 100 DAY));

-- 2.2 路线热度数据 (用于推荐算法测试)
INSERT INTO trail_stats (trail_id, monthly_completions, total_favorites, total_shares, updated_at) VALUES
('trail_001', 120, 340, 89, NOW()),      -- 热门路线
('trail_002', 85, 210, 56, NOW()),
('trail_003', 95, 280, 72, NOW()),
('trail_004', 65, 180, 45, NOW()),
('trail_005', 45, 120, 32, NOW()),
('trail_006', 55, 150, 38, NOW()),
('trail_007', 78, 220, 67, NOW()),
('trail_008', 52, 140, 41, NOW()),
('trail_009', 88, 260, 78, NOW()),
('trail_010', 25, 80, 18, NOW()),
('trail_011', 15, 45, 12, NOW()),
('trail_low_rating', 10, 25, 5, NOW()),
('trail_high_rating', 150, 420, 120, NOW()),
('trail_fresh_new', 5, 15, 3, NOW()),
('trail_fresh_old', 60, 180, 50, NOW());

-- ============================================================
-- 三、成就定义数据
-- ============================================================

-- 3.1 成就基础定义
INSERT INTO achievements (id, name, description, category, level, icon, condition_type, condition_value, points, sort_order, created_at) VALUES
-- 首次徒步 (1个)
('first_001', '迈出第一步', '完成第一次路线记录', 'first', 'bronze', 'assets/achievements/first_step.png', 'first_completion', 1, 10, 1, NOW()),

-- 里程累计 (5个)
('dist_001', '初出茅庐', '累计徒步 10km', 'distance', 'bronze', 'assets/achievements/distance_bronze.png', 'distance_total', 10000, 20, 10, NOW()),
('dist_002', '行路人', '累计徒步 50km', 'distance', 'silver', 'assets/achievements/distance_silver.png', 'distance_total', 50000, 50, 11, NOW()),
('dist_003', '远行者', '累计徒步 100km', 'distance', 'gold', 'assets/achievements/distance_gold.png', 'distance_total', 100000, 100, 12, NOW()),
('dist_004', '千里行者', '累计徒步 500km', 'distance', 'diamond', 'assets/achievements/distance_diamond.png', 'distance_total', 500000, 300, 13, NOW()),
('dist_005', '万里长征', '累计徒步 1000km', 'distance', 'diamond', 'assets/achievements/distance_diamond2.png', 'distance_total', 1000000, 500, 14, NOW()),

-- 路线收集 (5个)
('trail_001_ach', '路线探索者', '完成 5 条不同路线', 'trail', 'bronze', 'assets/achievements/trail_bronze.png', 'unique_trails', 5, 30, 20, NOW()),
('trail_002_ach', '路线达人', '完成 15 条不同路线', 'trail', 'silver', 'assets/achievements/trail_silver.png', 'unique_trails', 15, 60, 21, NOW()),
('trail_003_ach', '路线专家', '完成 30 条不同路线', 'trail', 'gold', 'assets/achievements/trail_gold.png', 'unique_trails', 30, 120, 22, NOW()),
('trail_004_ach', '路线大师', '完成 50 条不同路线', 'trail', 'diamond', 'assets/achievements/trail_diamond.png', 'unique_trails', 50, 250, 23, NOW()),
('trail_005_ach', '路线传奇', '完成 100 条不同路线', 'trail', 'diamond', 'assets/achievements/trail_diamond2.png', 'unique_trails', 100, 500, 24, NOW()),

-- 连续打卡 (5个)
('streak_001', '坚持不懈', '连续 3 天徒步', 'streak', 'bronze', 'assets/achievements/streak_bronze.png', 'consecutive_days', 3, 25, 30, NOW()),
('streak_002', '习惯养成', '连续 7 天徒步', 'streak', 'silver', 'assets/achievements/streak_silver.png', 'consecutive_days', 7, 60, 31, NOW()),
('streak_003', '持之以恒', '连续 30 天徒步', 'streak', 'gold', 'assets/achievements/streak_gold.png', 'consecutive_days', 30, 200, 32, NOW()),
('streak_004', '户外狂热', '连续 60 天徒步', 'streak', 'diamond', 'assets/achievements/streak_diamond.png', 'consecutive_days', 60, 400, 33, NOW()),
('streak_005', '年度挑战', '连续 100 天徒步', 'streak', 'diamond', 'assets/achievements/streak_diamond2.png', 'consecutive_days', 100, 1000, 34, NOW()),

-- 分享达人 (4个)
('share_001', '乐于分享', '累计分享 5 次', 'share', 'bronze', 'assets/achievements/share_bronze.png', 'total_shares', 5, 15, 40, NOW()),
('share_002', '内容创作者', '累计分享 20 次', 'share', 'silver', 'assets/achievements/share_silver.png', 'total_shares', 20, 40, 41, NOW()),
('share_003', '户外博主', '累计获得 100 赞', 'share', 'gold', 'assets/achievements/share_gold.png', 'total_likes', 100, 80, 42, NOW()),
('share_004', '意见领袖', '累计获得 500 赞', 'share', 'diamond', 'assets/achievements/share_diamond.png', 'total_likes', 500, 200, 43, NOW());

-- ============================================================
-- 四、用户进度测试数据
-- ============================================================

-- 4.1 不同进度状态的用户数据

-- 轻度用户 - 刚起步
INSERT INTO user_progress (user_id, total_distance, total_trails, unique_trails, current_streak, max_streak, total_shares, total_likes, updated_at) VALUES
('user_light_001', 8500, 3, 3, 0, 2, 2, 5, NOW()),
('user_light_002', 12000, 4, 4, 1, 3, 3, 8, NOW());

-- 中度用户 - 有一定积累
INSERT INTO user_progress (user_id, total_distance, total_trails, unique_trails, current_streak, max_streak, total_shares, total_likes, updated_at) VALUES
('user_medium_001', 65000, 18, 16, 5, 12, 15, 45, NOW()),
('user_medium_002', 85000, 25, 22, 0, 8, 22, 78, NOW());

-- 重度用户 - 接近高阶成就
INSERT INTO user_progress (user_id, total_distance, total_trails, unique_trails, current_streak, max_streak, total_shares, total_likes, updated_at) VALUES
('user_heavy_001', 420000, 45, 42, 15, 28, 35, 156, NOW()),
('user_heavy_002', 890000, 78, 65, 45, 67, 58, 342, NOW());

-- 成就阈值边界测试数据
-- 接近 10km 里程成就
INSERT INTO user_progress (user_id, total_distance, total_trails, unique_trails, current_streak, max_streak, total_shares, total_likes, updated_at) VALUES
('user_ach_test_001', 9500, 2, 2, 0, 1, 0, 0, NOW());

-- 接近 50km 里程成就
INSERT INTO user_progress (user_id, total_distance, total_trails, unique_trails, current_streak, max_streak, total_shares, total_likes, updated_at) VALUES
('user_ach_test_002', 48500, 8, 8, 0, 3, 4, 12, NOW());

-- 接近路线收集成就 (已有 4 条，差 1 条到 5 条)
INSERT INTO user_progress (user_id, total_distance, total_trails, unique_trails, current_streak, max_streak, total_shares, total_likes, updated_at) VALUES
('user_ach_test_003', 25000, 4, 4, 0, 2, 2, 5, NOW());

-- 4.2 已解锁成就数据 (用于测试重复解锁等场景)
INSERT INTO user_achievements (user_id, achievement_id, unlocked_at, shared_count, is_new, created_at) VALUES
-- user_light_001 已解锁首次成就
('user_light_001', 'first_001', DATE_SUB(NOW(), INTERVAL 25 DAY), 1, false, DATE_SUB(NOW(), INTERVAL 25 DAY)),

-- user_medium_001 已解锁部分成就
('user_medium_001', 'first_001', DATE_SUB(NOW(), INTERVAL 55 DAY), 2, false, DATE_SUB(NOW(), INTERVAL 55 DAY)),
('user_medium_001', 'dist_001', DATE_SUB(NOW(), INTERVAL 50 DAY), 1, false, DATE_SUB(NOW(), INTERVAL 50 DAY)),
('user_medium_001', 'dist_002', DATE_SUB(NOW(), INTERVAL 30 DAY), 0, false, DATE_SUB(NOW(), INTERVAL 30 DAY)),
('user_medium_001', 'trail_001_ach', DATE_SUB(NOW(), INTERVAL 40 DAY), 1, false, DATE_SUB(NOW(), INTERVAL 40 DAY)),

-- user_heavy_001 已解锁大部分成就
('user_heavy_001', 'first_001', DATE_SUB(NOW(), INTERVAL 110 DAY), 3, false, DATE_SUB(NOW(), INTERVAL 110 DAY)),
('user_heavy_001', 'dist_001', DATE_SUB(NOW(), INTERVAL 100 DAY), 2, false, DATE_SUB(NOW(), INTERVAL 100 DAY)),
('user_heavy_001', 'dist_002', DATE_SUB(NOW(), INTERVAL 90 DAY), 1, false, DATE_SUB(NOW(), INTERVAL 90 DAY)),
('user_heavy_001', 'dist_003', DATE_SUB(NOW(), INTERVAL 60 DAY), 1, false, DATE_SUB(NOW(), INTERVAL 60 DAY)),
('user_heavy_001', 'trail_001_ach', DATE_SUB(NOW(), INTERVAL 95 DAY), 2, false, DATE_SUB(NOW(), INTERVAL 95 DAY)),
('user_heavy_001', 'trail_002_ach', DATE_SUB(NOW(), INTERVAL 70 DAY), 1, false, DATE_SUB(NOW(), INTERVAL 70 DAY)),
('user_heavy_001', 'streak_001', DATE_SUB(NOW(), INTERVAL 80 DAY), 1, false, DATE_SUB(NOW(), INTERVAL 80 DAY)),
('user_heavy_001', 'streak_002', DATE_SUB(NOW(), INTERVAL 75 DAY), 0, false, DATE_SUB(NOW(), INTERVAL 75 DAY)),
('user_heavy_001', 'share_001', DATE_SUB(NOW(), INTERVAL 85 DAY), 2, false, DATE_SUB(NOW(), INTERVAL 85 DAY));

-- ============================================================
-- 五、推荐算法测试数据
-- ============================================================

-- 5.1 用户历史行为数据 (用于推荐算法)
INSERT INTO user_trail_history (user_id, trail_id, completed_at, rating, created_at) VALUES
-- user_rec_test_001 偏好适中难度
('user_rec_test_001', 'trail_004', DATE_SUB(NOW(), INTERVAL 5 DAY), 5, NOW()),
('user_rec_test_001', 'trail_005', DATE_SUB(NOW(), INTERVAL 12 DAY), 4, NOW()),
('user_rec_test_001', 'trail_006', DATE_SUB(NOW(), INTERVAL 20 DAY), 5, NOW()),

-- user_rec_test_002 偏好简单难度
('user_rec_test_002', 'trail_001', DATE_SUB(NOW(), INTERVAL 3 DAY), 5, NOW()),
('user_rec_test_002', 'trail_002', DATE_SUB(NOW(), INTERVAL 8 DAY), 4, NOW()),
('user_rec_test_002', 'trail_003', DATE_SUB(NOW(), INTERVAL 15 DAY), 5, NOW()),

-- user_rec_test_003 偏好困难难度
('user_rec_test_003', 'trail_007', DATE_SUB(NOW(), INTERVAL 4 DAY), 5, NOW()),
('user_rec_test_003', 'trail_008', DATE_SUB(NOW(), INTERVAL 10 DAY), 4, NOW()),
('user_rec_test_003', 'trail_009', DATE_SUB(NOW(), INTERVAL 18 DAY), 5, NOW());

-- 5.2 用户收藏数据
INSERT INTO user_favorites (user_id, trail_id, created_at) VALUES
('user_rec_test_001', 'trail_004', DATE_SUB(NOW(), INTERVAL 5 DAY)),
('user_rec_test_001', 'trail_007', DATE_SUB(NOW(), INTERVAL 15 DAY)),
('user_rec_test_002', 'trail_001', DATE_SUB(NOW(), INTERVAL 3 DAY)),
('user_rec_test_003', 'trail_010', DATE_SUB(NOW(), INTERVAL 7 DAY));

-- ============================================================
-- 六、连续打卡测试数据
-- ============================================================

-- 6.1 模拟连续打卡记录 (用于连续打卡成就测试)
INSERT INTO user_daily_activity (user_id, activity_date, has_activity, created_at) VALUES
-- user_heavy_002 连续 45 天有活动
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 1 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 2 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 3 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 4 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 5 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 6 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 7 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 8 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 9 DAY), true, NOW()),
('user_heavy_002', DATE_SUB(CURDATE(), INTERVAL 10 DAY), true, NOW());

-- 6.2 有中断的打卡记录 (测试连续天数重置)
INSERT INTO user_daily_activity (user_id, activity_date, has_activity, created_at) VALUES
-- user_medium_002 中断后重新开始
('user_medium_002', DATE_SUB(CURDATE(), INTERVAL 1 DAY), true, NOW()),
('user_medium_002', DATE_SUB(CURDATE(), INTERVAL 2 DAY), true, NOW()),
('user_medium_002', DATE_SUB(CURDATE(), INTERVAL 3 DAY), true, NOW()),
-- 中间中断
('user_medium_002', DATE_SUB(CURDATE(), INTERVAL 7 DAY), true, NOW()),
('user_medium_002', DATE_SUB(CURDATE(), INTERVAL 8 DAY), true, NOW()),
('user_medium_002', DATE_SUB(CURDATE(), INTERVAL 9 DAY), true, NOW());

-- ============================================================
-- 七、分享与互动测试数据
-- ============================================================

-- 7.1 分享记录
INSERT INTO user_shares (user_id, content_type, content_id, share_channel, created_at) VALUES
-- 用于测试分享达人成就
('user_heavy_001', 'achievement', 'dist_003', 'wechat_moments', DATE_SUB(NOW(), INTERVAL 60 DAY)),
('user_heavy_001', 'achievement', 'trail_002_ach', 'wechat_friend', DATE_SUB(NOW(), INTERVAL 55 DAY)),
('user_heavy_001', 'trail', 'trail_004', 'xiaohongshu', DATE_SUB(NOW(), INTERVAL 45 DAY)),
('user_heavy_001', 'trail', 'trail_007', 'weibo', DATE_SUB(NOW(), INTERVAL 40 DAY));

-- 7.2 点赞记录
INSERT INTO user_likes (user_id, content_type, content_id, created_at) VALUES
-- 用于测试分享达人 - 获得点赞成就
('user_light_001', 'share', 'share_001', DATE_SUB(NOW(), INTERVAL 10 DAY)),
('user_light_002', 'share', 'share_001', DATE_SUB(NOW(), INTERVAL 9 DAY)),
('user_medium_001', 'share', 'share_001', DATE_SUB(NOW(), INTERVAL 8 DAY)),
('user_medium_002', 'share', 'share_001', DATE_SUB(NOW(), INTERVAL 7 DAY)),
('user_heavy_001', 'share', 'share_002', DATE_SUB(NOW(), INTERVAL 6 DAY)),
('user_heavy_002', 'share', 'share_002', DATE_SUB(NOW(), INTERVAL 5 DAY));

-- ============================================================
-- 八、清理脚本 (测试后还原)
-- ============================================================

-- 如需清理测试数据，请执行以下语句：
/*
DELETE FROM users WHERE id LIKE 'user_%test_%' OR id LIKE 'user_newbie_%' OR id LIKE 'user_light_%' OR id LIKE 'user_medium_%' OR id LIKE 'user_heavy_%';
DELETE FROM user_preferences WHERE user_id LIKE 'user_%test_%';
DELETE FROM trails WHERE id LIKE 'trail_%test%' OR id LIKE 'trail_fresh_%' OR id LIKE 'trail_low%' OR id LIKE 'trail_high%';
DELETE FROM trail_stats WHERE trail_id LIKE 'trail_%test%' OR trail_id LIKE 'trail_fresh_%' OR trail_id LIKE 'trail_low%' OR trail_id LIKE 'trail_high%';
DELETE FROM user_progress WHERE user_id LIKE 'user_%test_%' OR user_id LIKE 'user_newbie_%' OR user_id LIKE 'user_light_%' OR user_id LIKE 'user_medium_%' OR user_id LIKE 'user_heavy_%';
DELETE FROM user_achievements WHERE user_id LIKE 'user_%test_%' OR user_id LIKE 'user_newbie_%' OR user_id LIKE 'user_light_%' OR user_id LIKE 'user_medium_%' OR user_id LIKE 'user_heavy_%';
DELETE FROM user_trail_history WHERE user_id LIKE 'user_%test_%';
DELETE FROM user_favorites WHERE user_id LIKE 'user_%test_%';
DELETE FROM user_daily_activity WHERE user_id LIKE 'user_%test_%' OR user_id LIKE 'user_medium_%' OR user_id LIKE 'user_heavy_%';
DELETE FROM user_shares WHERE user_id LIKE 'user_%test_%' OR user_id LIKE 'user_heavy_%';
DELETE FROM user_likes WHERE content_id LIKE 'share_%';
*/

-- ============================================================
-- 九、验证查询
-- ============================================================

-- 验证用户数据
-- SELECT * FROM users WHERE id LIKE 'user_test%' OR id LIKE 'user_newbie%' OR id LIKE 'user_light%' OR id LIKE 'user_medium%' OR id LIKE 'user_heavy%';

-- 验证成就定义
-- SELECT * FROM achievements ORDER BY sort_order;

-- 验证用户进度
-- SELECT * FROM user_progress WHERE user_id LIKE 'user_test%' OR user_id LIKE 'user_newbie%' OR user_id LIKE 'user_light%' OR user_id LIKE 'user_medium%' OR user_id LIKE 'user_heavy%';

-- 验证已解锁成就
-- SELECT * FROM user_achievements WHERE user_id LIKE 'user_test%' OR user_id LIKE 'user_newbie%' OR user_id LIKE 'user_light%' OR user_id LIKE 'user_medium%' OR user_id LIKE 'user_heavy%';

-- ============================================================
-- 文档结束
-- ============================================================
