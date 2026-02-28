-- 为 trail 表的 city、difficulty、deletedAt 字段添加索引
-- 用于优化查询性能

-- city 字段索引（按城市筛选路线）
CREATE INDEX IF NOT EXISTS "trails_city_idx" ON "trails"("city");

-- difficulty 字段索引（按难度筛选路线）
CREATE INDEX IF NOT EXISTS "trails_difficulty_idx" ON "trails"("difficulty");

-- deletedAt 字段索引（软删除查询优化）
CREATE INDEX IF NOT EXISTS "trails_deleted_at_idx" ON "trails"("deleted_at");
