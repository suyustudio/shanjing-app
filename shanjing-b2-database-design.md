# 山径APP - 数据库设计文档 (B2)

> **文档版本**: v1.0  
> **制定日期**: 2026-02-27  
> **文档状态**: 已确认  
> **对应阶段**: Week 2 - B2 数据库设计  
> **数据库**: PostgreSQL 15.4+ with PostGIS 3.3+

---

## 1. 设计概述

### 1.1 设计目标

- 支持山径APP核心业务：用户管理、路线数据、POI管理、收藏、轨迹记录
- 满足离线地图功能的数据存储需求
- 支持地理空间数据的高效查询（PostGIS）
- 保证数据一致性和查询性能

### 1.2 设计原则

1. **规范化设计**: 遵循第三范式，减少数据冗余
2. **空间数据优化**: 充分利用PostGIS扩展处理地理数据
3. **索引优化**: 针对查询场景设计合理的索引策略
4. **扩展性**: 预留字段和表结构，支持未来功能扩展
5. **安全性**: 敏感数据加密存储，用户隐私保护

---

## 2. 实体关系图 (ER Diagram)

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              山径APP 数据库 ER 图                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│   ┌─────────────┐         ┌─────────────┐         ┌─────────────┐              │
│   │    users    │         │   trails    │         │    pois     │              │
│   ├─────────────┤         ├─────────────┤         ├─────────────┤              │
│   │ PK id       │◄────────┤ PK id       │◄────────┤ PK id       │              │
│   │    wx_openid│    1:N  │    name     │    1:N  │    trail_id │              │
│   │    nickname │         │    distance │         │    name     │              │
│   │    phone    │         │    difficulty│        │    type     │              │
│   │    emergency│         │    gpx_url  │         │    location │◄── PostGIS   │
│   └─────────────┘         │    safety   │         │    sequence │              │
│          │                │    bounds   │         └─────────────┘              │
│          │                └─────────────┘                │                      │
│          │                       │                       │                      │
│          │              ┌────────┴────────┐              │                      │
│          │              │                 │              │                      │
│          ▼              ▼                 ▼              │                      │
│   ┌─────────────┐  ┌─────────────┐  ┌─────────────┐     │                      │
│   │  favorites  │  │offline_pkg  │  │track_records│     │                      │
│   ├─────────────┤  ├─────────────┤  ├─────────────┤     │                      │
│   │ PK id       │  │ PK id       │  │ PK id       │     │                      │
│   │ FK user_id  │  │ FK trail_id │  │ FK user_id  │     │                      │
│   │ FK trail_id │  │    file_url │  │ FK trail_id │     │                      │
│   │    created_at│  │    bounds   │  │    track    │─────┘                      │
│   └─────────────┘  │    expires  │  │    stats    │                            │
│                    └─────────────┘  └─────────────┘                            │
│                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 2.1 关系说明

| 关系 | 类型 | 说明 |
|------|------|------|
| users → favorites | 1:N | 一个用户可以收藏多条路线 |
| users → track_records | 1:N | 一个用户可以有多条轨迹记录 |
| trails → pois | 1:N | 一条路线包含多个POI点 |
| trails → favorites | 1:N | 一条路线可以被多个用户收藏 |
| trails → offline_packages | 1:N | 一条路线可以有多个版本的离线包 |
| trails → track_records | 1:N | 一条路线可以有多个用户的轨迹记录 |

---

## 3. 完整 Prisma Schema

```prisma
// schema.prisma
// 山径APP 数据库模型定义
// PostgreSQL 15.4+ with PostGIS 3.3+

// ==================== 生成器配置 ====================

generator client {
  provider = "prisma-client-js"
  previewFeatures = ["postgresqlExtensions"]
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
  extensions = [postgis]
}

// ==================== 枚举定义 ====================

// 路线难度枚举
enum Difficulty {
  easy       // 简单
  moderate   // 中等
  hard       // 困难
}

// POI类型枚举
enum PoiType {
  safety      // 安全类：急救点、避难所
  navigation  // 导航类：岔路口、里程碑
  service     // 服务类：补给点、洗手间
  info        // 信息类：观景台、介绍牌
  social      // 社交类：拍照点、休息区
}

// 轨迹记录状态枚举
enum TrackStatus {
  recording   // 记录中
  paused      // 已暂停
  completed   // 已完成
  uploaded    // 已上传
}

// ==================== 用户模块 ====================

// 用户表
model User {
  id                String   @id @default(cuid())
  
  // 微信认证信息
  wxOpenid          String   @unique @map("wx_openid")
  wxUnionid         String?  @unique @map("wx_unionid")
  
  // 基本信息
  nickname          String?
  avatarUrl         String?  @map("avatar_url")
  phone             String?  @unique
  
  // 紧急联系人（JSON格式存储）
  // 格式: [{"name": "张三", "phone": "13800138000", "relation": "配偶"}]
  emergencyContacts Json?    @map("emergency_contacts")
  
  // 用户设置
  settings          Json?    @default("{}")
  
  // 关联关系
  favorites         Favorite[]
  trackRecords      TrackRecord[]
  
  // 时间戳
  createdAt         DateTime @default(now()) @map("created_at")
  updatedAt         DateTime @updatedAt @map("updated_at")
  
  // 索引
  @@index([wxOpenid])
  @@index([phone])
  @@index([createdAt])
  @@map("users")
}

// ==================== 路线模块 ====================

// 路线表
model Trail {
  id               String   @id @default(cuid())
  
  // 基本信息
  name             String   @db.VarChar(100)
  description      String?  @db.Text
  distanceKm       Float    @map("distance_km")
  durationMin      Int      @map("duration_min")
  elevationGainM   Float    @map("elevation_gain_m")
  elevationLossM   Float?   @map("elevation_loss_m")
  difficulty       Difficulty
  
  // 标签（PostgreSQL数组类型）
  tags             String[] @default([])
  
  // 封面图片（JSON数组存储URL）
  coverImages      String[] @map("cover_images")
  
  // 轨迹数据（GPX文件URL）
  gpxUrl           String   @map("gpx_url")
  
  // 安全信息（JSON格式）
  // 格式: {"femaleFriendly": true, "signalCoverage": "全程有信号", "evacuationPoints": 3}
  safetyInfo       Json     @map("safety_info")
  
  // 位置信息
  city             String   @db.VarChar(50)
  district         String   @db.VarChar(50)
  startPointLat    Float    @map("start_point_lat")
  startPointLng    Float    @map("start_point_lng")
  startPointAddress String  @map("start_point_address") @db.VarChar(200)
  
  // 边界框（用于地图显示范围）
  boundsNorth      Float    @map("bounds_north")
  boundsSouth      Float    @map("bounds_south")
  boundsEast       Float    @map("bounds_east")
  boundsWest       Float    @map("bounds_west")
  
  // 海拔剖面数据（JSON格式，简化后的海拔数据）
  // 格式: [{"distance": 0, "elevation": 100}, {"distance": 0.5, "elevation": 150}]
  elevationProfile Json?    @map("elevation_profile")
  
  // 统计信息
  favoriteCount    Int      @default(0) @map("favorite_count")
  viewCount        Int      @default(0) @map("view_count")
  
  // 关联关系
  pois             Poi[]
  favorites        Favorite[]
  offlinePackages  OfflinePackage[]
  trackRecords     TrackRecord[]
  
  // 发布状态
  isPublished      Boolean  @default(false) @map("is_published")
  publishedAt      DateTime? @map("published_at")
  
  // 时间戳
  createdAt        DateTime @default(now()) @map("created_at")
  updatedAt        DateTime @updatedAt @map("updated_at")
  
  // 索引定义
  @@index([startPointLat, startPointLng])
  @@index([city, district])
  @@index([difficulty])
  @@index([isPublished, publishedAt])
  @@index([tags])
  @@map("trails")
}

// POI表（兴趣点）
model Poi {
  id          String   @id @default(cuid())
  
  // 关联路线
  trailId     String   @map("trail_id")
  
  // 基本信息
  name        String   @db.VarChar(100)
  type        PoiType
  subtype     String   @db.VarChar(50)  // 子类型：如"补给点"、"洗手间"
  
  // 位置信息（PostGIS几何类型）
  // 使用 geometry(Point, 4326) 存储WGS84坐标系的点
  location    Unsupported("geometry(Point, 4326)")?
  latitude    Float
  longitude   Float
  altitude    Float?
  
  // 序列号（用于POI排序，从小到大）
  sequence    Int
  
  // 描述和图片
  description String?  @db.Text
  photos      String[] @default([])
  
  // 优先级（用于显示优先级，1-10）
  priority    Int      @default(5)
  
  // 扩展信息（根据POI类型存储不同信息）
  // 服务类: {"openingHours": "08:00-18:00", "phone": "xxx"}
  // 安全类: {"equipment": ["急救箱", "AED"]}
  metadata    Json?
  
  // 关联关系
  trail       Trail    @relation(fields: [trailId], references: [id], onDelete: Cascade)
  
  // 时间戳
  createdAt   DateTime @default(now()) @map("created_at")
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  // 索引定义
  @@index([trailId, sequence])
  @@index([type])
  @@index([latitude, longitude])
  @@index([priority])
  // PostGIS空间索引（使用GIST索引加速地理查询）
  @@index([location], type: Gist)
  @@map("pois")
}

// ==================== 离线包模块 ====================

// 离线包表
model OfflinePackage {
  id          String   @id @default(cuid())
  
  // 关联路线
  trailId     String   @map("trail_id")
  
  // 版本信息
  version     String   @default("1.0.0")
  
  // 文件信息
  fileUrl     String   @map("file_url")
  fileSizeMb  Float    @map("file_size_mb")
  checksum    String   @db.VarChar(64)  // SHA-256校验值
  
  // 地图配置
  minZoom     Int      @map("min_zoom")
  maxZoom     Int      @map("max_zoom")
  boundsNorth Float    @map("bounds_north")
  boundsSouth Float    @map("bounds_south")
  boundsEast  Float    @map("bounds_east")
  boundsWest  Float    @map("bounds_west")
  
  // 关联关系
  trail       Trail    @relation(fields: [trailId], references: [id], onDelete: Cascade)
  
  // 时间戳
  createdAt   DateTime @default(now()) @map("created_at")
  expiresAt   DateTime @map("expires_at")
  
  // 索引定义
  @@index([trailId])
  @@index([expiresAt])
  @@index([createdAt])
  @@map("offline_packages")
}

// ==================== 用户行为模块 ====================

// 收藏表
model Favorite {
  id        String   @id @default(cuid())
  
  // 关联用户和路线
  userId    String   @map("user_id")
  trailId   String   @map("trail_id")
  
  // 关联关系
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  trail     Trail    @relation(fields: [trailId], references: [id], onDelete: Cascade)
  
  // 时间戳
  createdAt DateTime @default(now()) @map("created_at")
  
  // 唯一约束：一个用户不能重复收藏同一条路线
  @@unique([userId, trailId])
  // 索引定义
  @@index([userId, createdAt])
  @@index([trailId])
  @@map("favorites")
}

// 轨迹记录表
model TrackRecord {
  id              String   @id @default(cuid())
  
  // 关联用户
  userId          String   @map("user_id")
  
  // 关联路线（可选，自由徒步时为空）
  trailId         String?  @map("trail_id")
  
  // 时间信息
  startedAt       DateTime @map("started_at")
  endedAt         DateTime? @map("ended_at")
  
  // 统计数据
  totalDistanceKm Float?   @map("total_distance_km")
  durationSec     Int?     @map("duration_sec")
  elevationGainM  Float?   @map("elevation_gain_m")
  elevationLossM  Float?   @map("elevation_loss_m")
  maxAltitudeM    Float?   @map("max_altitude_m")
  minAltitudeM    Float?   @map("min_altitude_m")
  
  // 轨迹数据（GPX文件URL或JSON数据）
  // 小数据量存储为JSON，大数据量存储为文件URL
  trackDataUrl    String?  @map("track_data_url")
  trackDataJson   Json?    @map("track_data_json")
  
  // 照片（JSON数组存储URL）
  photos          String[] @default([])
  
  // 状态
  status          TrackStatus @default(recording)
  isUploaded      Boolean  @default(false) @map("is_uploaded")
  
  // 关联关系
  user            User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  trail           Trail?   @relation(fields: [trailId], references: [id], onDelete: SetNull)
  
  // 时间戳
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")
  
  // 索引定义
  @@index([userId, startedAt])
  @@index([trailId])
  @@index([status, isUploaded])
  @@index([createdAt])
  @@map("track_records")
}

// ==================== 系统模块 ====================

// Token黑名单表（用于用户登出）
model TokenBlacklist {
  id        String   @id @default(cuid())
  token     String   @unique @db.Text
  expiresAt DateTime @map("expires_at")
  createdAt DateTime @default(now()) @map("created_at")
  
  @@index([token])
  @@index([expiresAt])
  @@map("token_blacklist")
}

// 系统配置表
model SystemConfig {
  id          String   @id @default(cuid())
  key         String   @unique @db.VarChar(100)
  value       Json
  description String?
  updatedAt   DateTime @updatedAt @map("updated_at")
  
  @@map("system_config")
}

// 操作日志表（可选，用于后台审计）
model OperationLog {
  id          String   @id @default(cuid())
  userId      String?  @map("user_id")
  action      String   @db.VarChar(50)  // 操作类型
  resource    String   @db.VarChar(50)  // 操作对象类型
  resourceId  String?  @map("resource_id")
  details     Json?    // 操作详情
  ipAddress   String?  @map("ip_address") @db.VarChar(45)
  userAgent   String?  @map("user_agent") @db.Text
  createdAt   DateTime @default(now()) @map("created_at")
  
  @@index([userId, createdAt])
  @@index([action, createdAt])
  @@index([resource, resourceId])
  @@map("operation_logs")
}
```

---

## 4. 索引设计详解

### 4.1 索引总览表

| 表名 | 索引名 | 字段 | 类型 | 用途 |
|------|--------|------|------|------|
| users | idx_users_wx_openid | wx_openid | B-tree | 微信登录查询 |
| users | idx_users_phone | phone | B-tree | 手机号查询 |
| users | idx_users_created_at | created_at | B-tree | 用户列表排序 |
| trails | idx_trails_location | start_point_lat, start_point_lng | B-tree | 附近路线搜索 |
| trails | idx_trails_city_district | city, district | B-tree | 城市筛选 |
| trails | idx_trails_difficulty | difficulty | B-tree | 难度筛选 |
| trails | idx_trails_published | is_published, published_at | B-tree | 已发布路线查询 |
| trails | idx_trails_tags | tags | GIN | 标签搜索 |
| pois | idx_pois_trail_sequence | trail_id, sequence | B-tree | POI列表查询 |
| pois | idx_pois_type | type | B-tree | POI类型筛选 |
| pois | idx_pois_location | latitude, longitude | B-tree | 坐标查询 |
| pois | idx_pois_geo | location | GiST | 空间查询（PostGIS） |
| favorites | idx_favorites_user_created | user_id, created_at | B-tree | 用户收藏列表 |
| favorites | idx_favorites_trail | trail_id | B-tree | 路线收藏统计 |
| track_records | idx_tracks_user_time | user_id, started_at | B-tree | 用户轨迹列表 |
| track_records | idx_tracks_trail | trail_id | B-tree | 路线轨迹统计 |
| track_records | idx_tracks_status | status, is_uploaded | B-tree | 轨迹状态查询 |
| offline_packages | idx_offline_trail | trail_id | B-tree | 路线离线包查询 |
| offline_packages | idx_offline_expires | expires_at | B-tree | 过期包清理 |

### 4.2 空间索引详解

```sql
-- PostGIS空间索引创建语句（Prisma自动生成，此处供参考）

-- POI空间索引（GiST索引适合地理数据）
CREATE INDEX idx_pois_location ON pois USING GIST (location);

-- 附近POI查询示例
SELECT * FROM pois 
WHERE ST_DWithin(
  location::geography,
  ST_SetSRID(ST_MakePoint(120.15, 30.25), 4326)::geography,
  1000  -- 1000米范围内
);

-- 路线边界框查询
SELECT * FROM trails 
WHERE ST_Intersects(
  ST_MakeEnvelope(bounds_west, bounds_south, bounds_east, bounds_north, 4326),
  ST_MakeEnvelope(120.1, 30.2, 120.2, 30.3, 4326)
);
```

### 4.3 全文搜索索引

```sql
-- 路线名称和描述的全文搜索（中文）
CREATE INDEX idx_trails_fulltext ON trails 
USING GIN (to_tsvector('chinese', name || ' ' || COALESCE(description, '')));

-- 全文搜索查询示例
SELECT * FROM trails 
WHERE to_tsvector('chinese', name || ' ' || COALESCE(description, '')) 
    @@ plainto_tsquery('chinese', '西湖 徒步');
```

---

## 5. 关联关系说明

### 5.1 关系类型总览

```
┌─────────────────┬─────────────────┬───────────┬─────────────────────────────┐
│ 父表            │ 子表            │ 关系类型  │ 级联策略                     │
├─────────────────┼─────────────────┼───────────┼─────────────────────────────┤
│ users           │ favorites       │ 1:N       │ 删除用户时级联删除收藏        │
│ users           │ track_records   │ 1:N       │ 删除用户时级联删除轨迹记录    │
│ trails          │ pois            │ 1:N       │ 删除路线时级联删除POI         │
│ trails          │ favorites       │ 1:N       │ 删除路线时级联删除收藏        │
│ trails          │ offline_packages│ 1:N       │ 删除路线时级联删除离线包      │
│ trails          │ track_records   │ 1:N       │ 删除路线时设为NULL            │
└─────────────────┴─────────────────┴───────────┴─────────────────────────────┘
```

### 5.2 外键约束

```sql
-- favorites 表外键
ALTER TABLE favorites 
  ADD CONSTRAINT fk_favorites_user 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE favorites 
  ADD CONSTRAINT fk_favorites_trail 
  FOREIGN KEY (trail_id) REFERENCES trails(id) ON DELETE CASCADE;

-- track_records 表外键
ALTER TABLE track_records 
  ADD CONSTRAINT fk_tracks_user 
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;

ALTER TABLE track_records 
  ADD CONSTRAINT fk_tracks_trail 
  FOREIGN KEY (trail_id) REFERENCES trails(id) ON DELETE SET NULL;
```

---

## 6. 数据类型说明

### 6.1 字段类型映射

| Prisma类型 | PostgreSQL类型 | 用途说明 |
|------------|----------------|----------|
| `String` | `TEXT` / `VARCHAR(n)` | 字符串，带长度限制用VARCHAR |
| `String @db.Uuid` | `UUID` | UUID类型 |
| `Int` | `INTEGER` | 整数 |
| `BigInt` | `BIGINT` | 大整数 |
| `Float` | `DOUBLE PRECISION` | 双精度浮点数 |
| `Decimal` | `DECIMAL` | 精确小数（金额计算） |
| `Boolean` | `BOOLEAN` | 布尔值 |
| `DateTime` | `TIMESTAMP WITH TIME ZONE` | 带时区的时间戳 |
| `Json` | `JSONB` | JSON二进制存储 |
| `String[]` | `TEXT[]` | 字符串数组 |
| `Unsupported("geometry")` | `GEOMETRY` | PostGIS几何类型 |

### 6.2 JSON字段结构定义

#### emergency_contacts (users表)
```json
[
  {
    "name": "张三",
    "phone": "13800138000",
    "relation": "配偶"
  },
  {
    "name": "李四",
    "phone": "13900139000",
    "relation": "朋友"
  }
]
```

#### safety_info (trails表)
```json
{
  "femaleFriendly": true,
  "signalCoverage": "全程有信号",
  "evacuationPoints": 3,
  "warnings": ["部分路段湿滑", "注意野生动物"]
}
```

#### elevation_profile (trails表)
```json
[
  {"distance": 0.0, "elevation": 100.5},
  {"distance": 0.5, "elevation": 150.2},
  {"distance": 1.0, "elevation": 180.0}
]
```

#### metadata (pois表) - 服务类示例
```json
{
  "openingHours": "08:00-18:00",
  "phone": "0571-88888888",
  "services": ["餐饮", "住宿", "充电"]
}
```

---

## 7. 数据库迁移脚本

### 7.1 初始迁移

```bash
# 1. 初始化Prisma
npx prisma init

# 2. 生成迁移文件
npx prisma migrate dev --name init

# 3. 生成Prisma Client
npx prisma generate
```

### 7.2 种子数据

```typescript
// prisma/seed.ts
import { PrismaClient, Difficulty, PoiType } from '@prisma/client';

const prisma = new PrismaClient();

async function main() {
  // 创建示例路线
  const trail = await prisma.trail.create({
    data: {
      name: '九溪十八涧环线',
      description: '杭州经典徒步路线，途经九溪烟树、龙井村等景点',
      distanceKm: 8.5,
      durationMin: 180,
      elevationGainM: 320,
      difficulty: Difficulty.moderate,
      tags: ['亲子', '摄影', '茶园', '溪流'],
      coverImages: ['https://example.com/trail1.jpg'],
      gpxUrl: 'trails/gpx/jiuxi.gpx',
      safetyInfo: {
        femaleFriendly: true,
        signalCoverage: '全程有信号',
        evacuationPoints: 3,
      },
      city: '杭州市',
      district: '西湖区',
      startPointLat: 30.1985,
      startPointLng: 120.1258,
      startPointAddress: '九溪公交站',
      boundsNorth: 30.2150,
      boundsSouth: 30.1850,
      boundsEast: 120.1400,
      boundsWest: 120.1100,
      isPublished: true,
      publishedAt: new Date(),
    },
  });

  // 创建POI
  await prisma.poi.createMany({
    data: [
      {
        trailId: trail.id,
        name: '九溪烟树',
        type: PoiType.info,
        subtype: '观景台',
        latitude: 30.2050,
        longitude: 120.1280,
        sequence: 1,
        description: '九溪十八涧标志性景点',
        priority: 10,
      },
      {
        trailId: trail.id,
        name: '龙井村补给点',
        type: PoiType.service,
        subtype: '补给点',
        latitude: 30.2100,
        longitude: 120.1320,
        sequence: 5,
        description: '提供茶水、简餐',
        priority: 8,
        metadata: {
          openingHours: '08:00-18:00',
          services: ['餐饮', '茶水'],
        },
      },
    ],
  });

  console.log('Seed data created successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
```

### 7.3 运行种子

```bash
# package.json 添加
{
  "prisma": {
    "seed": "ts-node prisma/seed.ts"
  }
}

# 执行种子
npx prisma db seed
```

---

## 8. 性能优化策略

### 8.1 查询优化

```typescript
// 1. 附近路线查询（使用边界框预过滤）
const nearbyTrails = await prisma.trail.findMany({
  where: {
    isPublished: true,
    // 先使用B-tree索引过滤边界框
    boundsSouth: { lte: lat + 0.5 },
    boundsNorth: { gte: lat - 0.5 },
    boundsWest: { lte: lng + 0.5 },
    boundsEast: { gte: lng - 0.5 },
  },
  take: 20,
});

// 2. 用户收藏列表（使用覆盖索引）
const favorites = await prisma.favorite.findMany({
  where: { userId },
  orderBy: { createdAt: 'desc' },
  include: {
    trail: {
      select: {
        id: true,
        name: true,
        coverImages: true,
        distanceKm: true,
        difficulty: true,
      },
    },
  },
});

// 3. 路线POI查询（利用联合索引）
const pois = await prisma.poi.findMany({
  where: { trailId },
  orderBy: { sequence: 'asc' },
});
```

### 8.2 分页策略

```typescript
// 游标分页（推荐用于路线列表）
const trails = await prisma.trail.findMany({
  where: { isPublished: true },
  orderBy: { publishedAt: 'desc' },
  take: 20,
  skip: cursor ? 1 : 0,
  cursor: cursor ? { id: cursor } : undefined,
});

// 偏移分页（用于后台管理）
const trails = await prisma.trail.findMany({
  skip: (page - 1) * limit,
  take: limit,
});
```

### 8.3 连接池配置

```typescript
// prisma/client.ts
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient({
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
  // 连接池配置
  connectionLimit: 10,  // 开发环境
  // connectionLimit: 50,  // 生产环境
});

export default prisma;
```

---

## 9. 数据安全

### 9.1 敏感字段加密

```typescript
// 用户紧急联系人加密存储
import { EncryptionService } from './encryption.service';

// 加密存储
const encryptedContacts = encryptionService.encrypt(
  JSON.stringify(emergencyContacts)
);

await prisma.user.update({
  where: { id: userId },
  data: { emergencyContacts: encryptedContacts },
});

// 解密读取
const user = await prisma.user.findUnique({ where: { id: userId } });
const contacts = JSON.parse(
  encryptionService.decrypt(user.emergencyContacts)
);
```

### 9.2 数据脱敏

```typescript
// 手机号脱敏显示
function maskPhone(phone: string): string {
  return phone.replace(/(\d{3})\d{4}(\d{4})/, '$1****$2');
}

// API返回时脱敏
const userResponse = {
  ...user,
  phone: user.phone ? maskPhone(user.phone) : null,
  wxOpenid: undefined,  // 不返回敏感字段
};
```

---

## 10. 备份与恢复

### 10.1 备份策略

```bash
#!/bin/bash
# backup.sh - 数据库备份脚本

BACKUP_DIR="/backup/postgres"
DATE=$(date +%Y%m%d_%H%M%S)
DB_NAME="shanjing"

# 全量备份
pg_dump -h localhost -U postgres -Fc $DB_NAME > $BACKUP_DIR/full_$DATE.dump

# 保留最近7天的备份
find $BACKUP_DIR -name "full_*.dump" -mtime +7 -delete
```

### 10.2 恢复脚本

```bash
#!/bin/bash
# restore.sh - 数据库恢复脚本

BACKUP_FILE=$1
DB_NAME="shanjing"

# 恢复数据库
pg_restore -h localhost -U postgres -d $DB_NAME --clean $BACKUP_FILE
```

---

## 11. 监控指标

### 11.1 数据库性能指标

| 指标 | 告警阈值 | 说明 |
|------|----------|------|
| 查询响应时间 | > 500ms | 慢查询告警 |
| 连接数使用率 | > 80% | 连接池告警 |
| 磁盘使用率 | > 85% | 存储告警 |
| 死锁次数 | > 0 | 死锁告警 |

### 11.2 慢查询日志

```sql
-- 开启慢查询日志
ALTER SYSTEM SET log_min_duration_statement = '500ms';
ALTER SYSTEM SET log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h ';
SELECT pg_reload_conf();
```

---

## 12. 文档变更记录

| 版本 | 日期 | 变更内容 | 作者 |
|------|------|----------|------|
| v1.0 | 2026-02-27 | 初始版本，完成完整数据库设计 | - |

---

> **文档说明**: 本文档作为Week 2 B2任务的交付物，包含完整的Prisma Schema定义、索引设计和关联关系说明。所有数据库结构以此文档为准。
