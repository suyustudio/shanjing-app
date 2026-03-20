-- ================================================================
-- M5 Achievement System Database Migration
-- 成就系统数据库迁移脚本
-- ================================================================

BEGIN;

-- 1. 创建枚举类型
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'achievement_category') THEN
    CREATE TYPE achievement_category AS ENUM (
      'explorer', 'distance', 'frequency', 'challenge', 'social'
    );
  END IF;
  
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'achievement_level') THEN
    CREATE TYPE achievement_level AS ENUM (
      'bronze', 'silver', 'gold', 'diamond'
    );
  END IF;
END $$;

-- 2. 创建成就定义表
CREATE TABLE IF NOT EXISTS achievements (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  key VARCHAR(32) UNIQUE NOT NULL,
  name VARCHAR(64) NOT NULL,
  description TEXT,
  category achievement_category NOT NULL,
  icon_url VARCHAR(256),
  is_hidden BOOLEAN DEFAULT FALSE,
  sort_order INTEGER DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. 创建成就等级表
CREATE TABLE IF NOT EXISTS achievement_levels (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  achievement_id VARCHAR(32) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  level achievement_level NOT NULL,
  requirement INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  description TEXT,
  reward VARCHAR(128),
  icon_url VARCHAR(256),
  UNIQUE(achievement_id, level)
);

-- 4. 创建用户成就表
CREATE TABLE IF NOT EXISTS user_achievements (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(32) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_id VARCHAR(32) NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  level_id VARCHAR(32) NOT NULL,
  progress INTEGER DEFAULT 0,
  unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_new BOOLEAN DEFAULT TRUE,
  is_notified BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

-- 5. 创建用户统计表
CREATE TABLE IF NOT EXISTS user_stats (
  user_id VARCHAR(32) PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  total_distance_m INTEGER DEFAULT 0,
  total_duration_sec INTEGER DEFAULT 0,
  total_elevation_gain_m FLOAT DEFAULT 0,
  unique_trails_count INTEGER DEFAULT 0,
  completed_trail_ids TEXT[] DEFAULT '{}',
  current_weekly_streak INTEGER DEFAULT 0,
  longest_weekly_streak INTEGER DEFAULT 0,
  current_monthly_streak INTEGER DEFAULT 0,
  last_trail_date DATE,
  trail_count_this_week INTEGER DEFAULT 0,
  trail_count_this_month INTEGER DEFAULT 0,
  night_trail_count INTEGER DEFAULT 0,
  rain_trail_count INTEGER DEFAULT 0,
  solo_trail_count INTEGER DEFAULT 0,
  share_count INTEGER DEFAULT 0,
  avg_distance_km FLOAT,
  avg_duration_min FLOAT,
  preferred_difficulty VARCHAR(16),
  preferred_tags TEXT[] DEFAULT '{}',
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. 创建推荐日志表（可选）
CREATE TABLE IF NOT EXISTS recommendation_logs (
  id VARCHAR(32) PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id VARCHAR(32) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  algorithm VARCHAR(32) NOT NULL,
  context JSONB NOT NULL,
  results JSONB NOT NULL,
  user_action VARCHAR(32),
  action_time TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 7. 扩展 users 表
ALTER TABLE users ADD COLUMN IF NOT EXISTS settings JSONB DEFAULT '{}';

-- 8. 创建索引
CREATE INDEX IF NOT EXISTS idx_achievements_category ON achievements(category);
CREATE INDEX IF NOT EXISTS idx_achievements_sort ON achievements(sort_order);
CREATE INDEX IF NOT EXISTS idx_levels_achievement ON achievement_levels(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_time ON user_achievements(user_id, unlocked_at);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_new ON user_achievements(user_id, is_new);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement ON user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_distance ON user_stats(total_distance_m);
CREATE INDEX IF NOT EXISTS idx_user_stats_trails ON user_stats(unique_trails_count);
CREATE INDEX IF NOT EXISTS idx_user_stats_streak ON user_stats(current_weekly_streak);
CREATE INDEX IF NOT EXISTS idx_rec_logs_user_time ON recommendation_logs(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_rec_logs_algorithm ON recommendation_logs(algorithm);

-- 9. 添加外键约束（如果还没有）
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.table_constraints 
    WHERE constraint_name = 'fk_user_achievements_level'
  ) THEN
    ALTER TABLE user_achievements 
    ADD CONSTRAINT fk_user_achievements_level 
    FOREIGN KEY (level_id) REFERENCES achievement_levels(id) ON DELETE CASCADE;
  END IF;
END $$;

COMMIT;
