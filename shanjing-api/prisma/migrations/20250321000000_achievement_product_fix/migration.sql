-- ================================================================
-- M5 Achievement System Product Fix Migration
-- 成就系统 Product 修复迁移
--
-- 修复内容:
-- - P0-2: 添加连续天数字段 (current_streak, longest_streak)
-- - P0-3: 添加点赞数字段 (total_likes_received)
-- ================================================================

-- 添加连续天数统计字段
ALTER TABLE user_stats 
ADD COLUMN IF NOT EXISTS current_streak INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS longest_streak INTEGER DEFAULT 0;

-- 添加点赞统计字段
ALTER TABLE user_stats 
ADD COLUMN IF NOT EXISTS total_likes_received INTEGER DEFAULT 0;

-- 为现有数据迁移：将周连续数据复制到天连续（作为初始值）
UPDATE user_stats 
SET current_streak = current_weekly_streak,
    longest_streak = longest_weekly_streak
WHERE current_streak = 0;

-- 创建索引优化查询性能
CREATE INDEX IF NOT EXISTS idx_user_stats_streak ON user_stats(current_streak);
CREATE INDEX IF NOT EXISTS idx_user_stats_likes ON user_stats(total_likes_received);

-- 更新统计信息
ANALYZE user_stats;
