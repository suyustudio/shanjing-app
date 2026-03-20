-- M5 Recommendation System Migration
-- 用户画像表 + 推荐日志表 + 用户路线交互表

-- 扩展路线表
ALTER TABLE trails ADD COLUMN IF NOT EXISTS avg_rating FLOAT;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS review_count INTEGER DEFAULT 0;

-- 创建用户画像表
CREATE TABLE IF NOT EXISTS user_profiles (
    id VARCHAR(36) PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(36) NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    preferred_difficulty VARCHAR(16),
    preferred_min_distance_km FLOAT,
    preferred_max_distance_km FLOAT,
    preferred_tags TEXT[] DEFAULT '{}',
    total_completed_trails INTEGER DEFAULT 0,
    total_distance_km FLOAT DEFAULT 0,
    total_duration_min INTEGER DEFAULT 0,
    avg_rating_given FLOAT,
    difficulty_vector JSONB,
    tag_vector JSONB,
    is_cold_start BOOLEAN DEFAULT TRUE,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建推荐日志表
CREATE TABLE IF NOT EXISTS recommendation_logs (
    id VARCHAR(36) PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    algorithm VARCHAR(32) NOT NULL,
    scene VARCHAR(32) NOT NULL,
    context_lat FLOAT,
    context_lng FLOAT,
    context_time TIMESTAMP NOT NULL,
    results JSONB NOT NULL,
    user_action VARCHAR(32),
    action_time TIMESTAMP,
    clicked_trail_id VARCHAR(36),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建用户路线交互表
CREATE TABLE IF NOT EXISTS user_trail_interactions (
    id VARCHAR(36) PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id VARCHAR(36) NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trail_id VARCHAR(36) NOT NULL,
    interaction_type VARCHAR(32) NOT NULL,
    rating FLOAT,
    duration_sec INTEGER,
    source VARCHAR(32),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, trail_id, interaction_type)
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_profiles_user_id ON user_profiles(user_id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_cold_start ON user_profiles(is_cold_start);

CREATE INDEX IF NOT EXISTS idx_rec_logs_user_time ON recommendation_logs(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_rec_logs_algorithm ON recommendation_logs(algorithm);
CREATE INDEX IF NOT EXISTS idx_rec_logs_scene ON recommendation_logs(scene);

CREATE INDEX IF NOT EXISTS idx_interactions_user_time ON user_trail_interactions(user_id, created_at);
CREATE INDEX IF NOT EXISTS idx_interactions_trail ON user_trail_interactions(trail_id);
CREATE INDEX IF NOT EXISTS idx_interactions_type ON user_trail_interactions(interaction_type);