# 路线数据 API 接口文档

## 概述

本文档描述了山径APP路线数据相关的 API 接口，包括路线列表查询、搜索和详情获取功能。

## 基础信息

- **基础路径**: `/api/v1`
- **认证方式**: JWT Token (Bearer Token)
- **公开接口**: 路线列表、搜索、详情接口为公开接口，无需登录即可访问

## 接口列表

### 1. 获取路线列表

获取路线列表，支持分页、筛选和排序。

#### 请求

```
GET /trails
```

#### 查询参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| page | integer | 否 | 页码，默认1 | 1 |
| limit | integer | 否 | 每页数量，默认20，最大100 | 20 |
| difficulty | string | 否 | 难度筛选：easy(简单), moderate(中等), hard(困难) | moderate |
| minDuration | integer | 否 | 最短时长（分钟） | 60 |
| maxDuration | integer | 否 | 最长时长（分钟） | 300 |
| minDistance | number | 否 | 最短距离（公里） | 5 |
| maxDistance | number | 否 | 最长距离（公里） | 20 |
| tags | string | 否 | 标签筛选，多个标签用逗号分隔 | 森林,瀑布,观景 |
| city | string | 否 | 城市筛选 | 杭州 |
| sortBy | string | 否 | 排序方式：recommended(推荐), distance(距离), popularity(热度) | recommended |
| sortOrder | string | 否 | 排序顺序：asc(升序), desc(降序) | desc |
| lat | number | 否 | 当前纬度（用于距离排序） | 30.2741 |
| lng | number | 否 | 当前经度（用于距离排序） | 120.1551 |

#### 响应

**成功响应 (200 OK)**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "clq1234567890abcdef",
        "name": "九溪十八涧徒步路线",
        "description": "经典杭州徒步路线，沿途溪流潺潺...",
        "distanceKm": 8.5,
        "durationMin": 180,
        "elevationGainM": 350.5,
        "difficulty": "moderate",
        "tags": ["森林", "溪流", "亲子友好"],
        "coverImage": "https://example.com/images/trail1.jpg",
        "location": {
          "city": "杭州",
          "district": "西湖区",
          "address": "龙井村入口"
        },
        "coordinates": {
          "lat": 30.2741,
          "lng": 120.1551
        },
        "stats": {
          "favoriteCount": 128,
          "viewCount": 1024
        },
        "distanceFromUser": 5.2,
        "createdAt": "2024-01-15T08:30:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 156,
      "totalPages": 8,
      "hasMore": true
    }
  }
}
```

#### 示例请求

```bash
# 基础列表
curl -X GET "https://api.example.com/api/v1/trails?page=1&limit=10"

# 带筛选条件
curl -X GET "https://api.example.com/api/v1/trails?difficulty=moderate&minDistance=5&maxDistance=15&tags=森林,瀑布"

# 按距离排序（需要提供坐标）
curl -X GET "https://api.example.com/api/v1/trails?sortBy=distance&lat=30.2741&lng=120.1551"

# 按热度排序
curl -X GET "https://api.example.com/api/v1/trails?sortBy=popularity&sortOrder=desc"
```

---

### 2. 搜索路线

根据关键字搜索路线，支持搜索路线名称、城市、区县、地址和描述。

#### 请求

```
GET /trails/search
```

#### 查询参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| keyword | string | 是 | 搜索关键字 | 西湖 |
| page | integer | 否 | 页码，默认1 | 1 |
| limit | integer | 否 | 每页数量，默认20，最大100 | 20 |
| sortBy | string | 否 | 排序方式：recommended(推荐), distance(距离), popularity(热度) | recommended |
| sortOrder | string | 否 | 排序顺序：asc(升序), desc(降序) | desc |

#### 响应

**成功响应 (200 OK)**

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "clq1234567890abcdef",
        "name": "西湖环湖徒步",
        "description": "环绕西湖的经典路线...",
        "distanceKm": 10.5,
        "durationMin": 240,
        "elevationGainM": 50.0,
        "difficulty": "easy",
        "tags": ["湖景", "城市", "平坦"],
        "coverImage": "https://example.com/images/westlake.jpg",
        "location": {
          "city": "杭州",
          "district": "西湖区",
          "address": "断桥残雪"
        },
        "coordinates": {
          "lat": 30.2596,
          "lng": 120.1447
        },
        "stats": {
          "favoriteCount": 256,
          "viewCount": 2048
        },
        "createdAt": "2024-01-10T10:00:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 12,
      "totalPages": 1,
      "hasMore": false
    }
  }
}
```

#### 示例请求

```bash
# 搜索关键字
curl -X GET "https://api.example.com/api/v1/trails/search?keyword=西湖"

# 搜索并分页
curl -X GET "https://api.example.com/api/v1/trails/search?keyword=九溪&page=1&limit=10"

# 搜索并按热度排序
curl -X GET "https://api.example.com/api/v1/trails/search?keyword=森林&sortBy=popularity"
```

---

### 3. 获取路线详情

根据路线ID获取详细信息，包括POI列表和离线包信息。

#### 请求

```
GET /trails/:id
```

#### 路径参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| id | string | 是 | 路线ID | clq1234567890abcdef |

#### 响应

**成功响应 (200 OK)**

```json
{
  "success": true,
  "data": {
    "id": "clq1234567890abcdef",
    "name": "九溪十八涧徒步路线",
    "description": "经典杭州徒步路线，沿途溪流潺潺...",
    "distanceKm": 8.5,
    "durationMin": 180,
    "elevationGainM": 350.5,
    "elevationLossM": 350.5,
    "difficulty": "moderate",
    "tags": ["森林", "溪流", "亲子友好"],
    "coverImages": [
      "https://example.com/images/trail1_1.jpg",
      "https://example.com/images/trail1_2.jpg"
    ],
    "gpxUrl": "https://example.com/tracks/trail1.gpx",
    "safetyInfo": {
      "femaleFriendly": true,
      "signalCoverage": "全程有信号",
      "evacuationPoints": 3
    },
    "location": {
      "city": "杭州",
      "district": "西湖区",
      "address": "龙井村入口"
    },
    "coordinates": {
      "lat": 30.2741,
      "lng": 120.1551
    },
    "bounds": {
      "north": 30.2841,
      "south": 30.2641,
      "east": 120.1651,
      "west": 120.1451
    },
    "elevationProfile": [
      { "distance": 0, "elevation": 100 },
      { "distance": 0.5, "elevation": 150 },
      { "distance": 1.0, "elevation": 200 }
    ],
    "stats": {
      "favoriteCount": 128,
      "viewCount": 1024
    },
    "pois": [
      {
        "id": "clq0987654321fedcba",
        "name": "九溪烟树",
        "type": "navigation",
        "subtype": "观景台",
        "coordinates": {
          "lat": 30.2750,
          "lng": 120.1560,
          "altitude": 150.0
        },
        "sequence": 1,
        "description": "著名观景点，可俯瞰整个九溪",
        "photos": ["https://example.com/poi1.jpg"],
        "priority": 8,
        "metadata": {
          "hasRestroom": true
        }
      }
    ],
    "offlinePackages": [
      {
        "id": "clqaaaa1111bbbb2222",
        "version": "1.0.0",
        "fileUrl": "https://example.com/packages/trail1.zip",
        "fileSizeMb": 15.5,
        "checksum": "a1b2c3d4e5f6...",
        "minZoom": 12,
        "maxZoom": 18,
        "bounds": {
          "north": 30.2841,
          "south": 30.2641,
          "east": 120.1651,
          "west": 120.1451
        },
        "expiresAt": "2025-01-15T08:30:00.000Z"
      }
    ],
    "createdAt": "2024-01-15T08:30:00.000Z",
    "updatedAt": "2024-01-15T08:30:00.000Z"
  }
}
```

**错误响应 (404 Not Found)**

```json
{
  "success": false,
  "error": {
    "code": "TRAIL_NOT_FOUND",
    "message": "路线不存在"
  }
}
```

#### 示例请求

```bash
curl -X GET "https://api.example.com/api/v1/trails/clq1234567890abcdef"
```

---

## 数据类型定义

### Difficulty (难度等级)

| 值 | 说明 |
|----|------|
| easy | 简单 - 适合新手，路况良好 |
| moderate | 中等 - 有一定挑战，需要一定体力 |
| hard | 困难 - 高难度路线，需要专业装备 |

### TrailSortBy (排序方式)

| 值 | 说明 |
|----|------|
| recommended | 推荐排序（默认）- 按发布时间倒序 |
| distance | 距离排序 - 按距离用户远近排序 |
| popularity | 热度排序 - 按收藏数排序 |

---

## 错误码说明

| 错误码 | 说明 | HTTP状态码 |
|--------|------|-----------|
| UNAUTHORIZED | 未授权，请先登录 | 401 |
| TRAIL_NOT_FOUND | 路线不存在 | 404 |
| VALIDATION_ERROR | 参数校验错误 | 400 |
| INTERNAL_ERROR | 服务器内部错误 | 500 |

---

## 模块集成说明

### 1. 注册模块

在 `AppModule` 中导入 `TrailsModule`：

```typescript
import { Module } from '@nestjs/common';
import { TrailsModule } from './trails/trails.module';

@Module({
  imports: [
    TrailsModule,
    // ... 其他模块
  ],
})
export class AppModule {}
```

### 2. 依赖说明

本模块依赖以下模块：

- `PrismaModule` - 数据库访问
- `CommonModule` - JWT Guard 和 Public 装饰器

### 3. 文件结构

```
backend/trails/
├── dto/
│   ├── list-trails.dto.ts      # 列表和搜索请求DTO
│   └── trail-response.dto.ts   # 响应DTO定义
├── trails.controller.ts        # 控制器
├── trails.service.ts           # 服务层
├── trails.module.ts            # 模块定义
└── index.ts                    # 模块导出
```

---

## 性能优化说明

1. **分页查询**: 默认每页20条，最大支持100条
2. **数据库索引**: 已针对常用查询字段建立索引（difficulty, city, tags, isPublished）
3. **浏览数统计**: 采用异步更新，不阻塞主响应
4. **距离计算**: 使用 Haversine 公式在应用层计算，避免复杂SQL

---

## 更新日志

### v1.0.0 (2024-02-27)

- 初始版本发布
- 实现路线列表查询接口
- 实现路线搜索接口
- 实现路线详情接口
- 支持分页、筛选、排序功能
