# 性能优化建议

## 数据库查询优化

### 添加索引

在 `trail` 表的以下字段添加索引，提升查询性能：

| 字段 | 说明 |
|------|------|
| `city` | 城市筛选常用条件 |
| `difficulty` | 难度筛选常用条件 |
| `deletedAt` | 软删除过滤条件 |

### SQL 示例

```sql
CREATE INDEX idx_trail_city ON trail(city);
CREATE INDEX idx_trail_difficulty ON trail(difficulty);
CREATE INDEX idx_trail_deleted_at ON trail(deletedAt);
```
