-- ================================================================
-- M5 Database Migration Script - Achievement System
-- 山径APP M5阶段数据库迁移 - 成就系统
-- ================================================================

BEGIN;

-- 1. 创建枚举类型
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'achievement_category') THEN
    CREATE TYPE achievement_category AS ENUM ('EXPLORER', 'DISTANCE', 'FREQUENCY', 'CHALLENGE', 'SOCIAL');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'achievement_level_enum') THEN
    CREATE TYPE achievement_level_enum AS ENUM ('BRONZE', 'SILVER', 'GOLD', 'DIAMOND');
  END IF;
END $$;

-- 2. 创建成就定义表
CREATE TABLE IF NOT EXISTS achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
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
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  level achievement_level_enum NOT NULL,
  requirement INTEGER NOT NULL,
  name VARCHAR(64) NOT NULL,
  description TEXT,
  reward VARCHAR(128),
  icon_url VARCHAR(256),
  UNIQUE(achievement_id, level)
);

-- 4. 创建用户成就表
CREATE TABLE IF NOT EXISTS user_achievements (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  achievement_id UUID NOT NULL REFERENCES achievements(id) ON DELETE CASCADE,
  level_id UUID NOT NULL REFERENCES achievement_levels(id) ON DELETE CASCADE,
  progress INTEGER DEFAULT 0,
  unlocked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  is_new BOOLEAN DEFAULT TRUE,
  is_notified BOOLEAN DEFAULT FALSE,
  UNIQUE(user_id, achievement_id)
);

-- 5. 创建用户统计表
CREATE TABLE IF NOT EXISTS user_stats (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
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

-- 6. 创建索引
CREATE INDEX IF NOT EXISTS idx_achievements_category ON achievements(category);
CREATE INDEX IF NOT EXISTS idx_achievements_sort ON achievements(sort_order);
CREATE INDEX IF NOT EXISTS idx_levels_achievement ON achievement_levels(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_time ON user_achievements(user_id, unlocked_at);
CREATE INDEX IF NOT EXISTS idx_user_achievements_user_new ON user_achievements(user_id, is_new);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement ON user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_stats_distance ON user_stats(total_distance_m);
CREATE INDEX IF NOT EXISTS idx_user_stats_trails ON user_stats(unique_trails_count);
CREATE INDEX IF NOT EXISTS idx_user_stats_streak ON user_stats(current_weekly_streak);

COMMIT;
