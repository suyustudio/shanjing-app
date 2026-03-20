-- ================================================================
-- M6 Database Migration Script
-- 山径APP M6阶段数据库迁移 - 社交互动功能
-- ================================================================

BEGIN;

-- ==================== 评论系统 ====================

-- 创建评论表
CREATE TABLE reviews (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trail_id UUID NOT NULL REFERENCES trails(id) ON DELETE CASCADE,
    rating DECIMAL(2,1) NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
    content VARCHAR(500),
    is_edited BOOLEAN DEFAULT FALSE,
    is_reported BOOLEAN DEFAULT FALSE,
    report_reason VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    reply_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, trail_id)
);

-- 创建评论回复表
CREATE TABLE review_replies (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES review_replies(id) ON DELETE CASCADE,
    content VARCHAR(500) NOT NULL,
    is_reported BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建评论标签表
CREATE TABLE review_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    tag VARCHAR(32) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建评论图片表
CREATE TABLE review_photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    review_id UUID NOT NULL REFERENCES reviews(id) ON DELETE CASCADE,
    url VARCHAR(512) NOT NULL,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 照片系统 ====================

-- 创建照片表
CREATE TABLE photos (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trail_id UUID REFERENCES trails(id) ON DELETE SET NULL,
    poi_id UUID,
    url VARCHAR(512) NOT NULL,
    thumbnail_url VARCHAR(512),
    width INTEGER,
    height INTEGER,
    size_kb INTEGER,
    description VARCHAR(100),
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    taken_at TIMESTAMP,
    device VARCHAR(100),
    like_count INTEGER DEFAULT 0,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建照片点赞表
CREATE TABLE photo_likes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    photo_id UUID NOT NULL REFERENCES photos(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(photo_id, user_id)
);

-- ==================== 用户关注系统 ====================

-- 创建关注表
CREATE TABLE follows (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    follower_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(follower_id, following_id),
    CHECK (follower_id != following_id)
);

-- ==================== 用户动态系统 ====================

-- 创建动态类型枚举
CREATE TYPE activity_type AS ENUM (
    'COMPLETE_TRAIL',
    'POST_REVIEW',
    'UPLOAD_PHOTO',
    'UNLOCK_ACHIEVEMENT',
    'CREATE_COLLECTION'
);

-- 创建用户动态表
CREATE TABLE user_activities (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    type activity_type NOT NULL,
    content JSONB NOT NULL,
    is_public BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ==================== 收藏夹系统 ====================

-- 创建收藏夹表
CREATE TABLE collections (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    description VARCHAR(200),
    cover_url VARCHAR(512),
    is_public BOOLEAN DEFAULT TRUE,
    sort_order INTEGER DEFAULT 0,
    trail_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 创建收藏夹-路线关联表
CREATE TABLE collection_trails (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    collection_id UUID NOT NULL REFERENCES collections(id) ON DELETE CASCADE,
    trail_id UUID NOT NULL REFERENCES trails(id) ON DELETE CASCADE,
    sort_order INTEGER DEFAULT 0,
    note VARCHAR(100),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(collection_id, trail_id)
);

-- ==================== 扩展现有表 ====================

-- 扩展 users 表
ALTER TABLE users ADD COLUMN IF NOT EXISTS followers_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS following_count INTEGER DEFAULT 0;
ALTER TABLE users ADD COLUMN IF NOT EXISTS photos_count INTEGER DEFAULT 0;

-- 扩展 trails 表
ALTER TABLE trails ADD COLUMN IF NOT EXISTS reviews_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS avg_rating DECIMAL(2,1);
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_5_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_4_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_3_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_2_count INTEGER DEFAULT 0;
ALTER TABLE trails ADD COLUMN IF NOT EXISTS rating_1_count INTEGER DEFAULT 0;

-- ==================== 创建索引 ====================

-- 评论表索引
CREATE INDEX idx_reviews_trail_time ON reviews(trail_id, created_at DESC);
CREATE INDEX idx_reviews_user_time ON reviews(user_id, created_at DESC);
CREATE INDEX idx_reviews_rating ON reviews(rating);

-- 评论回复表索引
CREATE INDEX idx_review_replies_review ON review_replies(review_id, created_at);
CREATE INDEX idx_review_replies_user ON review_replies(user_id);

-- 评论标签表索引
CREATE INDEX idx_review_tags_review ON review_tags(review_id);
CREATE INDEX idx_review_tags_tag ON review_tags(tag);

-- 照片表索引
CREATE INDEX idx_photos_trail ON photos(trail_id, created_at DESC);
CREATE INDEX idx_photos_user ON photos(user_id, created_at DESC);
CREATE INDEX idx_photos_location ON photos(latitude, longitude);

-- 照片点赞表索引
CREATE INDEX idx_photo_likes_photo ON photo_likes(photo_id);
CREATE INDEX idx_photo_likes_user ON photo_likes(user_id);

-- 关注表索引
CREATE INDEX idx_follows_follower ON follows(follower_id, created_at DESC);
CREATE INDEX idx_follows_following ON follows(following_id, created_at DESC);

-- 用户动态表索引
CREATE INDEX idx_activities_user ON user_activities(user_id, created_at DESC);
CREATE INDEX idx_activities_type ON user_activities(type, created_at DESC);

-- 收藏夹表索引
CREATE INDEX idx_collections_user ON collections(user_id, sort_order);
CREATE INDEX idx_collections_public ON collections(is_public, created_at DESC);

-- 收藏夹-路线关联表索引
CREATE INDEX idx_collection_trails ON collection_trails(collection_id, sort_order);

COMMIT;
