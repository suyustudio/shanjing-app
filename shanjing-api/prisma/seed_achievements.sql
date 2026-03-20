-- ================================================================
-- M5 Achievement Seed Data
-- 成就系统种子数据
-- ================================================================

BEGIN;

-- 删除现有数据（如果存在）
DELETE FROM user_achievements;
DELETE FROM achievement_levels;
DELETE FROM achievements;

-- 1. 探索类成就：路线收集家
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'explorer', '路线收集家', '探索不同的徒步路线，收集你的足迹', 'EXPLORER', 'https://cdn.shanjing.app/badges/explorer.png', 1);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'BRONZE', 5, '初级探索者', '完成5条不同路线', 'https://cdn.shanjing.app/badges/explorer_bronze.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'SILVER', 15, '资深行者', '完成15条不同路线', 'https://cdn.shanjing.app/badges/explorer_silver.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'GOLD', 30, '山野达人', '完成30条不同路线', 'https://cdn.shanjing.app/badges/explorer_gold.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa1', 'DIAMOND', 50, '路线收藏家', '完成50条不同路线', 'https://cdn.shanjing.app/badges/explorer_diamond.png');

-- 2. 里程类成就：行者无疆
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'distance', '行者无疆', '累计徒步里程，丈量世界', 'DISTANCE', 'https://cdn.shanjing.app/badges/distance.png', 2);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'BRONZE', 10000, '初试身手', '累计10公里', 'https://cdn.shanjing.app/badges/distance_bronze.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb6', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'SILVER', 50000, '步履不停', '累计50公里', 'https://cdn.shanjing.app/badges/distance_silver.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb7', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'GOLD', 100000, '千里之行', '累计100公里', 'https://cdn.shanjing.app/badges/distance_gold.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb8', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa2', 'DIAMOND', 500000, '行者无疆', '累计500公里', 'https://cdn.shanjing.app/badges/distance_diamond.png');

-- 3. 频率类成就：周行者
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'weekly', '周行者', '坚持每周徒步，养成运动习惯', 'FREQUENCY', 'https://cdn.shanjing.app/badges/weekly.png', 3);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb9', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'BRONZE', 2, '起步者', '连续2周每周徒步', 'https://cdn.shanjing.app/badges/weekly_bronze.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbba', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'SILVER', 4, '坚持者', '连续4周每周徒步', 'https://cdn.shanjing.app/badges/weekly_silver.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'GOLD', 8, '习惯养成', '连续8周每周徒步', 'https://cdn.shanjing.app/badges/weekly_gold.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbc', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa3', 'DIAMOND', 16, '行者人生', '连续16周每周徒步', 'https://cdn.shanjing.app/badges/weekly_diamond.png');

-- 4. 挑战类成就：夜行者（隐藏成就）
INSERT INTO achievements (id, key, name, description, category, icon_url, is_hidden, sort_order) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'night', '夜行者', '在夜晚探索山野，体验不一样的风景', 'CHALLENGE', 'https://cdn.shanjing.app/badges/night.png', true, 4);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbd', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'BRONZE', 1, '初探夜色', '完成1次夜间徒步', 'https://cdn.shanjing.app/badges/night_bronze.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbe', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'SILVER', 5, '夜行常客', '完成5次夜间徒步', 'https://cdn.shanjing.app/badges/night_silver.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbf', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'GOLD', 10, '暗夜行者', '完成10次夜间徒步', 'https://cdn.shanjing.app/badges/night_gold.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc0', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa4', 'DIAMOND', 20, '月下独行者', '完成20次夜间徒步', 'https://cdn.shanjing.app/badges/night_diamond.png');

-- 5. 挑战类成就：雨中行（隐藏成就）
INSERT INTO achievements (id, key, name, description, category, icon_url, is_hidden, sort_order) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'rain', '雨中行', '在雨天徒步，感受自然的另一面', 'CHALLENGE', 'https://cdn.shanjing.app/badges/rain.png', true, 5);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'BRONZE', 1, '雨中漫步', '完成1次雨天徒步', 'https://cdn.shanjing.app/badges/rain_bronze.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'SILVER', 3, '风雨无阻', '完成3次雨天徒步', 'https://cdn.shanjing.app/badges/rain_silver.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'GOLD', 5, '雨中山行', '完成5次雨天徒步', 'https://cdn.shanjing.app/badges/rain_gold.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc4', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa5', 'DIAMOND', 10, '雨夜行者', '完成10次雨天徒步', 'https://cdn.shanjing.app/badges/rain_diamond.png');

-- 6. 社交类成就：分享达人
INSERT INTO achievements (id, key, name, description, category, icon_url, sort_order) VALUES
('aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', 'sharer', '分享达人', '分享你的徒步经历，传递户外乐趣', 'SOCIAL', 'https://cdn.shanjing.app/badges/sharer.png', 6);

INSERT INTO achievement_levels (id, achievement_id, level, requirement, name, description, icon_url) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc5', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', 'BRONZE', 1, '初次分享', '分享1次徒步经历', 'https://cdn.shanjing.app/badges/sharer_bronze.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc6', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', 'SILVER', 5, '分享常客', '分享5次徒步经历', 'https://cdn.shanjing.app/badges/sharer_silver.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc7', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', 'GOLD', 10, '山径大使', '分享10次徒步经历', 'https://cdn.shanjing.app/badges/sharer_gold.png'),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbc8', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaa6', 'DIAMOND', 20, '户外博主', '分享20次徒步经历', 'https://cdn.shanjing.app/badges/sharer_diamond.png');

COMMIT;
