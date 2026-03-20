-- ================================================================
-- M6 数据库迁移脚本
-- 执行 Review 修复相关的数据库变更
-- ================================================================

-- 1. 创建评论点赞表
CREATE TABLE IF NOT EXISTS "review_likes" (
    "id" UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    "review_id" UUID NOT NULL REFERENCES "reviews"("id") ON DELETE CASCADE,
    "user_id" UUID NOT NULL REFERENCES "users"("id") ON DELETE CASCADE,
    "created_at" TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE("review_id", "user_id")
);

-- 为 review_likes 添加索引
CREATE INDEX IF NOT EXISTS "idx_review_likes_review" ON "review_likes"("review_id");
CREATE INDEX IF NOT EXISTS "idx_review_likes_user" ON "review_likes"("user_id");

-- 2. 修改 Review 表
-- 2.1 添加 isVerified 字段 ("体验过"标识)
ALTER TABLE "reviews" ADD COLUMN IF NOT EXISTS "is_verified" BOOLEAN NOT NULL DEFAULT false;

-- 2.2 添加热门评论排序索引
CREATE INDEX IF NOT EXISTS "idx_reviews_popular" ON "reviews"("trail_id", "like_count" DESC, "created_at" DESC);

-- 3. 将评分从 DECIMAL 转换为 INTEGER
-- 注意：这会丢失小数部分，将半星评分四舍五入
-- 例如：4.5 -> 5, 3.5 -> 4

-- 3.1 添加临时整数列
ALTER TABLE "reviews" ADD COLUMN "rating_int" SMALLINT;

-- 3.2 转换数据 (四舍五入)
UPDATE "reviews" SET "rating_int" = ROUND("rating")::SMALLINT;

-- 3.3 删除旧列
ALTER TABLE "reviews" DROP COLUMN "rating";

-- 3.4 重命名新列
ALTER TABLE "reviews" RENAME COLUMN "rating_int" TO "rating";

-- 3.5 添加约束
ALTER TABLE "reviews" ALTER COLUMN "rating" SET NOT NULL;

-- 4. 更新现有数据的评分统计
-- 重新计算所有路线的评分统计
UPDATE "trails" t SET
    "avg_rating" = (
        SELECT AVG("rating")::FLOAT 
        FROM "reviews" r 
        WHERE r."trail_id" = t."id"
    ),
    "review_count" = (
        SELECT COUNT(*) 
        FROM "reviews" r 
        WHERE r."trail_id" = t."id"
    ),
    "rating_5_count" = (
        SELECT COUNT(*) 
        FROM "reviews" r 
        WHERE r."trail_id" = t."id" AND r."rating" = 5
    ),
    "rating_4_count" = (
        SELECT COUNT(*) 
        FROM "reviews" r 
        WHERE r."trail_id" = t."id" AND r."rating" = 4
    ),
    "rating_3_count" = (
        SELECT COUNT(*) 
        FROM "reviews" r 
        WHERE r."trail_id" = t."id" AND r."rating" = 3
    ),
    "rating_2_count" = (
        SELECT COUNT(*) 
        FROM "reviews" r 
        WHERE r."trail_id" = t."id" AND r."rating" = 2
    ),
    "rating_1_count" = (
        SELECT COUNT(*) 
        FROM "reviews" r 
        WHERE r."trail_id" = t."id" AND r."rating" = 1
    );

-- 5. 验证迁移结果
SELECT 
    'Review likes table' as check_item,
    COUNT(*) as count
FROM "review_likes"
UNION ALL
SELECT 
    'Reviews with is_verified' as check_item,
    COUNT(*) 
FROM "reviews" 
WHERE "is_verified" = true
UNION ALL
SELECT 
    'Reviews with integer rating' as check_item,
    COUNT(*) 
FROM "reviews" 
WHERE "rating" BETWEEN 1 AND 5;
