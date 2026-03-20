-- ================================================================
-- M5 Achievement Seed Data - Product Fixed Version
-- 成就系统种子数据 - 按照 PRD 规范修复版
-- 包含: 首次/里程/路线/连续打卡/分享 共 20 个成就
-- ================================================================

BEGIN;

-- 删除现有数据（如果存在）
DELETE FROM user_achievements;
DELETE FROM achievement_levels;
DELETE FROM achievements;

-- ================================================================
-- 1. 首次徒步 (First Hike) - 1个成就
-- ================================================================
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('achv-first-001', 'first_hike', '迈出第一步', '完成你的第一次徒步记录，开启山径之旅', 'EXPLORER', 'https://cdn.shanjing.app/badges/first_step.png', 1);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('lvl-first-001', 'achv-first-001', 'BRONZE', 1, '迈出第一步', '完成第一次路线记录', 'https://cdn.shanjing.app/badges/first_step_bronze.png');

-- ================================================================
-- 2. 里程累计 (Distance Master) - 5级成就
-- ================================================================
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('achv-dist-001', 'distance_master', '行者无疆', '累计徒步里程，丈量世界', 'DISTANCE', 'https://cdn.shanjing.app/badges/distance.png', 2);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('lvl-dist-bronze',  'achv-dist-001', 'BRONZE',  10000,  '初出茅庐', '累计徒步 10km',  'https://cdn.shanjing.app/badges/dist_bronze.png'),
('lvl-dist-silver',  'achv-dist-001', 'SILVER',  50000,  '行路人',   '累计徒步 50km',  'https://cdn.shanjing.app/badges/dist_silver.png'),
('lvl-dist-gold',    'achv-dist-001', 'GOLD',    100000, '远行者',   '累计徒步 100km', 'https://cdn.shanjing.app/badges/dist_gold.png'),
('lvl-dist-dia1',    'achv-dist-001', 'DIAMOND', 500000, '千里行者', '累计徒步 500km', 'https://cdn.shanjing.app/badges/dist_diamond1.png'),
('lvl-dist-dia2',    'achv-dist-001', 'DIAMOND', 1000000,'万里长征', '累计徒步 1000km','https://cdn.shanjing.app/badges/dist_diamond2.png');

-- ================================================================
-- 3. 路线收集 (Trail Collector) - 5级成就
-- ================================================================
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('achv-trail-001', 'trail_collector', '路线收集家', '探索不同的徒步路线，收集你的足迹', 'EXPLORER', 'https://cdn.shanjing.app/badges/trail.png', 3);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('lvl-trail-bronze', 'achv-trail-001', 'BRONZE',  5,   '路线探索者', '完成 5 条不同路线',  'https://cdn.shanjing.app/badges/trail_bronze.png'),
('lvl-trail-silver', 'achv-trail-001', 'SILVER',  15,  '路线达人',   '完成 15 条不同路线', 'https://cdn.shanjing.app/badges/trail_silver.png'),
('lvl-trail-gold',   'achv-trail-001', 'GOLD',    30,  '路线专家',   '完成 30 条不同路线', 'https://cdn.shanjing.app/badges/trail_gold.png'),
('lvl-trail-dia1',   'achv-trail-001', 'DIAMOND', 50,  '路线大师',   '完成 50 条不同路线', 'https://cdn.shanjing.app/badges/trail_diamond1.png'),
('lvl-trail-dia2',   'achv-trail-001', 'DIAMOND', 100, '路线传奇',   '完成 100 条不同路线','https://cdn.shanjing.app/badges/trail_diamond2.png');

-- ================================================================
-- 4. 连续打卡 (Streak Master) - 5级成就 (按天计算)
-- PRD: 3/7/30/60/100 天
-- ================================================================
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('achv-streak-001', 'streak_master', '连续打卡', '坚持每日徒步，养成运动习惯', 'FREQUENCY', 'https://cdn.shanjing.app/badges/streak.png', 4);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('lvl-streak-bronze', 'achv-streak-001', 'BRONZE',  3,   '坚持不懈', '连续 3 天徒步',  'https://cdn.shanjing.app/badges/streak_bronze.png'),
('lvl-streak-silver', 'achv-streak-001', 'SILVER',  7,   '习惯养成', '连续 7 天徒步',  'https://cdn.shanjing.app/badges/streak_silver.png'),
('lvl-streak-gold',   'achv-streak-001', 'GOLD',    30,  '持之以恒', '连续 30 天徒步', 'https://cdn.shanjing.app/badges/streak_gold.png'),
('lvl-streak-dia1',   'achv-streak-001', 'DIAMOND', 60,  '户外狂热', '连续 60 天徒步', 'https://cdn.shanjing.app/badges/streak_diamond1.png'),
('lvl-streak-dia2',   'achv-streak-001', 'DIAMOND', 100, '年度挑战', '连续 100 天徒步','https://cdn.shanjing.app/badges/streak_diamond2.png');

-- ================================================================
-- 5. 分享达人 (Social Star) - 4级成就
-- PRD: 分享5次(铜) / 分享20次(银) / 获赞100(金) / 获赞500(钻)
-- 注意: 金和钻石级基于点赞数而非分享次数
-- ================================================================
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('achv-share-001', 'social_star', '分享达人', '分享你的徒步经历，传递户外乐趣', 'SOCIAL', 'https://cdn.shanjing.app/badges/share.png', 5);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('lvl-share-bronze', 'achv-share-001', 'BRONZE',  5,   '乐于分享',   '累计分享 5 次',    'https://cdn.shanjing.app/badges/share_bronze.png'),
('lvl-share-silver', 'achv-share-001', 'SILVER',  20,  '内容创作者', '累计分享 20 次',   'https://cdn.shanjing.app/badges/share_silver.png'),
('lvl-share-gold',   'achv-share-001', 'GOLD',    100, '户外博主',   '累计获得 100 赞',  'https://cdn.shanjing.app/badges/share_gold.png'),
('lvl-share-dia',    'achv-share-001', 'DIAMOND', 500, '意见领袖',   '累计获得 500 赞',  'https://cdn.shanjing.app/badges/share_diamond.png');

COMMIT;

-- ================================================================
-- 数据验证查询（可选）
-- ================================================================
-- 统计成就总数
-- SELECT category, COUNT(*) as achievement_count, SUM(level_count) as total_levels 
-- FROM achievements a 
-- LEFT JOIN (SELECT achievement_id, COUNT(*) as level_count FROM achievement_levels GROUP BY achievement_id) l 
-- ON a.id = l.achievement_id 
-- GROUP BY category;
