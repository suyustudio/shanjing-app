# Week 2 交付物清单

## 任务完成状态

| 任务 | 状态 | 交付物 |
|------|------|--------|
| B1 技术选型确认 | ✅ 完成 | `shanjing-b1-tech-selection.md` |
| B2 数据库设计 | ✅ 完成 | `shanjing-b2-database-design.md` |
| B2 ER图 | ✅ 完成 | `shanjing-b2-er-diagram.mmd` |
| B2 Prisma Schema | ✅ 完成 | `prisma/schema.prisma` |

---

## 交付物说明

### 1. B1 技术选型确认文档
**文件**: `shanjing-b1-tech-selection.md`

包含内容：
- Flutter 3.16.0+ 版本确认
- Node.js 18.19.0 LTS + NestJS 10.3.0+ 确认
- PostgreSQL 15.4+ with PostGIS 3.3+ 确认
- 高德 SDK 版本确认（Android/iOS SDK 9.7.0+, Flutter插件 3.0.0+）
- 第三方服务选型（微信SDK、阿里云OSS、Redis等）
- 技术栈全景图和版本锁定表
- 风险评估与备选方案

### 2. B2 数据库设计文档
**文件**: `shanjing-b2-database-design.md`

包含内容：
- 完整 ER 图说明
- 完整 Prisma Schema 定义（含详细注释）
- 索引设计详解（含空间索引）
- 关联关系说明
- JSON字段结构定义
- 数据库迁移脚本
- 性能优化策略
- 数据安全设计
- 备份与恢复策略

### 3. ER 图 (Mermaid)
**文件**: `shanjing-b2-er-diagram.mmd`

包含内容：
- 可视化 ER 图（Mermaid语法）
- 所有表字段定义
- 表关系说明
- 索引设计要点

### 4. Prisma Schema 文件
**文件**: `prisma/schema.prisma`

可直接使用的 Prisma 模型定义文件，包含：
- 7 个业务表：users, trails, pois, offline_packages, favorites, track_records
- 3 个系统表：token_blacklist, system_config, operation_logs
- 4 个枚举类型：Difficulty, PoiType, TrackStatus
- 完整的索引定义
- 外键关联和级联策略

---

## 快速开始

### 初始化数据库

```bash
# 1. 进入后端项目目录
cd shanjing-api

# 2. 安装依赖
npm install

# 3. 配置环境变量
cp .env.example .env
# 编辑 .env 设置 DATABASE_URL

# 4. 执行数据库迁移
npx prisma migrate dev --name init

# 5. 生成 Prisma Client
npx prisma generate

# 6. 导入种子数据（可选）
npx prisma db seed
```

### 环境变量示例

```bash
# .env
DATABASE_URL="postgresql://user:password@localhost:5432/shanjing?schema=public"
```

---

## 数据库表概览

| 表名 | 说明 | 核心字段 |
|------|------|----------|
| users | 用户表 | wx_openid, nickname, phone, emergency_contacts |
| trails | 路线表 | name, distance_km, difficulty, bounds, gpx_url |
| pois | POI点表 | name, type, location(geometry), sequence |
| offline_packages | 离线包表 | trail_id, file_url, bounds, expires_at |
| favorites | 收藏表 | user_id, trail_id |
| track_records | 轨迹记录表 | user_id, trail_id, track_data, stats |
| token_blacklist | Token黑名单 | token, expires_at |
| system_config | 系统配置 | key, value |
| operation_logs | 操作日志 | user_id, action, resource |

---

## 技术选型总览

```
┌─────────────────────────────────────────────────────────────┐
│                        山径APP 技术栈                        │
├─────────────────────────────────────────────────────────────┤
│  客户端: Flutter 3.16.0+ (Dart 3.2+)                        │
│  后端: Node.js 18.19.0 LTS + NestJS 10.3.0+                 │
│  数据库: PostgreSQL 15.4+ with PostGIS 3.3+                 │
│  ORM: Prisma 5.7.0+                                         │
│  缓存: Redis 7.2+                                           │
│  地图: 高德 SDK 9.7.0+ (Flutter插件 3.0.0+)                 │
│  存储: 阿里云OSS                                            │
└─────────────────────────────────────────────────────────────┘
```

---

## 下一步

Week 2 完成后，进入 Week 3 开发阶段：

1. **后端**: B3 用户系统API开发
2. **移动端**: M1 项目搭建完成，启动 M2 公共组件库

详见 `shanjing-m1-schedule.md` 排期文档。
