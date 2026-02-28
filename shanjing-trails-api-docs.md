# 山径APP - 路线数据 API 接口文档

> **文档版本**: v1.0  
> **制定日期**: 2026-02-27  
> **文档状态**: 已完成  
> **对应阶段**: Week 2 - B4 路线数据 API 开发

---

## 目录

1. [接口概览](#1-接口概览)
2. [路线列表模块](#2-路线列表模块)
3. [路线详情模块](#3-路线详情模块)
4. [轨迹数据模块](#4-轨迹数据模块)
5. [错误码定义](#5-错误码定义)
6. [数据模型](#6-数据模型)

---

## 1. 接口概览

### 1.1 基础信息

| 项目 | 说明 |
|------|------|
| 基础URL | `https://api.shanjing.app/v1` |
| 协议 | HTTPS |
| 数据格式 | JSON |
| 认证方式 | Bearer Token（部分接口公开访问） |
| 字符编码 | UTF-8 |

### 1.2 请求头规范

```http
Content-Type: application/json
Authorization: Bearer <jwt_token>  // 需要认证的接口
X-Request-ID: <uuid>  // 可选，用于请求追踪
```

### 1.3 响应格式

**成功响应:**
```json
{
  "success": true,
  "data": { ... },
  "meta": { ... }  // 分页信息（可选）
}
```

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": { ... }  // 详细错误信息（可选）
  }
}
```

### 1.4 接口清单

| 模块 | 方法 | 路径 | 认证 | 说明 |
|------|------|------|------|------|
| 路线列表 | GET | `/trails` | 否 | 获取路线列表（支持分页、筛选、排序） |
| 路线搜索 | GET | `/trails/search` | 否 | 搜索路线（关键字搜索） |
| 路线详情 | GET | `/trails/:id` | 否 | 获取路线详情（基本信息、POI、离线包） |
| 轨迹数据 | GET | `/trails/:id/track` | 否 | 获取路线轨迹点数据（GPX格式） |

---

## 2. 路线列表模块

### 2.1 获取路线列表

**接口:** `GET /trails`

**认证:** 公开访问

**查询参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| page | number | 否 | 页码，默认1 |
| limit | number | 否 | 每页数量，默认20，最大100 |
| difficulty | string | 否 | 难度筛选：easy(简单), moderate(中等), hard(困难) |
| minDuration | number | 否 | 最短时长（分钟） |
| maxDuration | number | 否 | 最长时长（分钟） |
| minDistance | number | 否 | 最短距离（公里） |
| maxDistance | number | 否 | 最长距离（公里） |
| tags | string | 否 | 标签筛选，多个标签用逗号分隔 |
| city | string | 否 | 城市筛选 |
| sortBy | string | 否 | 排序方式：recommended(推荐), distance(距离), popularity(热度) |
| sortOrder | string | 否 | 排序顺序：asc(升序), desc(降序)，默认desc |
| lat | number | 否 | 当前纬度（用于距离排序） |
| lng | number | 否 | 当前经度（用于距离排序） |

**成功响应:**
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

---

### 2.2 搜索路线

**接口:** `GET /trails/search`

**认证:** 公开访问

**查询参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| keyword | string | 是 | 搜索关键字（路线名称、城市、地点） |
| page | number | 否 | 页码，默认1 |
| limit | number | 否 | 每页数量，默认20，最大100 |
| sortBy | string | 否 | 排序方式：recommended, distance, popularity |
| sortOrder | string | 否 | 排序顺序：asc, desc，默认desc |

**成功响应:** 同获取路线列表

---

## 3. 路线详情模块

### 3.1 获取路线详情

**接口:** `GET /trails/:id`

**认证:** 公开访问

**路径参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | string | 是 | 路线ID |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "id": "clq1234567890abcdef",
    "name": "九溪十八涧徒步路线",
    "description": "经典杭州徒步路线，沿途溪流潺潺，茶园环绕...",
    "distanceKm": 8.5,
    "durationMin": 180,
    "elevationGainM": 350.5,
    "elevationLossM": 350.5,
    "difficulty": "moderate",
    "tags": ["森林", "溪流", "亲子友好", "茶园"],
    "coverImages": [
      "https://example.com/images/trail1_1.jpg",
      "https://example.com/images/trail1_2.jpg"
    ],
    "gpxUrl": "https://example.com/trails/clq1234567890abcdef.gpx",
    "safetyInfo": {
      "femaleFriendly": true,
      "signalCoverage": "全程有信号",
      "evacuationPoints": 3,
      "emergencyPhone": "110"
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
        "id": "clqpoi0987654321",
        "name": "九溪烟树",
        "type": "navigation",
        "subtype": "观景台",
        "coordinates": {
          "lat": 30.2750,
          "lng": 120.1560,
          "altitude": 155.0
        },
        "sequence": 1,
        "description": "著名观景点，可俯瞰整个九溪",
        "photos": ["https://example.com/poi1.jpg"],
        "priority": 8,
        "metadata": {
          "hasRestroom": true,
          "bestViewTime": "早晨"
        }
      },
      {
        "id": "clqpoi1234567890",
        "name": "龙井茶园补给点",
        "type": "service",
        "subtype": "补给点",
        "coordinates": {
          "lat": 30.2760,
          "lng": 120.1570,
          "altitude": 160.0
        },
        "sequence": 2,
        "description": "提供饮用水、简单食物",
        "photos": [],
        "priority": 6,
        "metadata": {
          "businessHours": "08:00-18:00",
          "hasWater": true
        }
      }
    ],
    "offlinePackages": [
      {
        "id": "clqpkg111122223333",
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

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "TRAIL_NOT_FOUND",
    "message": "路线不存在"
  }
}
```

---

## 4. 轨迹数据模块

### 4.1 获取路线轨迹数据

**接口:** `GET /trails/:id/track`

**认证:** 公开访问

**路径参数:**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| id | string | 是 | 路线ID |

**成功响应:**
```json
{
  "success": true,
  "data": {
    "trailId": "clq1234567890abcdef",
    "trailName": "九溪十八涧徒步路线",
    "totalPoints": 156,
    "totalDistanceKm": 8.5,
    "points": [
      {
        "lat": 30.2741,
        "lng": 120.1551,
        "altitude": 100.0,
        "timestamp": "2024-01-15T08:30:00.000Z"
      },
      {
        "lat": 30.2745,
        "lng": 120.1555,
        "altitude": 105.0,
        "timestamp": "2024-01-15T08:31:00.000Z"
      },
      {
        "lat": 30.2750,
        "lng": 120.1560,
        "altitude": 110.0,
        "timestamp": "2024-01-15T08:32:00.000Z"
      }
    ],
    "gpxUrl": "https://example.com/trails/clq1234567890abcdef.gpx"
  }
}
```

**字段说明:**

| 字段 | 类型 | 说明 |
|------|------|------|
| trailId | string | 路线ID |
| trailName | string | 路线名称 |
| totalPoints | number | 轨迹点总数 |
| totalDistanceKm | number | 轨迹总距离（公里） |
| points | array | 轨迹点数组 |
| points[].lat | number | 纬度（WGS84坐标系） |
| points[].lng | number | 经度（WGS84坐标系） |
| points[].altitude | number | 海拔（米） |
| points[].timestamp | string | 时间戳（ISO 8601格式） |
| gpxUrl | string | GPX文件下载URL |

**错误响应:**
```json
{
  "success": false,
  "error": {
    "code": "TRAIL_NOT_FOUND",
    "message": "路线不存在"
  }
}
```

---

## 5. 错误码定义

### 5.1 通用错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `INTERNAL_ERROR` | 500 | 服务器内部错误 |
| `BAD_REQUEST` | 400 | 请求参数错误 |
| `UNAUTHORIZED` | 401 | 未授权，Token无效或过期 |
| `FORBIDDEN` | 403 | 禁止访问 |
| `NOT_FOUND` | 404 | 资源不存在 |
| `RATE_LIMITED` | 429 | 请求过于频繁 |

### 5.2 路线数据错误码

| 错误码 | HTTP状态码 | 说明 |
|--------|------------|------|
| `TRAIL_NOT_FOUND` | 404 | 路线不存在 |
| `TRAIL_NOT_PUBLISHED` | 404 | 路线未发布 |
| `INVALID_TRAIL_ID` | 400 | 路线ID格式错误 |
| `TRACK_DATA_NOT_AVAILABLE` | 404 | 轨迹数据不可用 |

---

## 6. 数据模型

### 6.1 Trail 模型（路线）

```typescript
interface Trail {
  id: string;                    // 路线唯一ID
  name: string;                  // 路线名称
  description?: string;          // 路线描述
  distanceKm: number;            // 距离（公里）
  durationMin: number;           // 预计用时（分钟）
  elevationGainM: number;        // 累计爬升（米）
  elevationLossM?: number;       // 累计下降（米）
  difficulty: 'easy' | 'moderate' | 'hard';  // 难度等级
  tags: string[];                // 标签数组
  coverImages: string[];         // 封面图片URL数组
  gpxUrl: string;                // GPX文件URL
  safetyInfo: Record<string, any>;  // 安全信息
  location: {
    city: string;                // 城市
    district: string;            // 区县
    address: string;             // 详细地址
  };
  coordinates: {
    lat: number;                 // 起点纬度
    lng: number;                 // 起点经度
  };
  bounds: {
    north: number;               // 北边界
    south: number;               // 南边界
    east: number;                // 东边界
    west: number;                // 西边界
  };
  elevationProfile?: Array<{     // 海拔剖面数据
    distance: number;            // 距离（公里）
    elevation: number;           // 海拔（米）
  }>;
  stats: {
    favoriteCount: number;       // 收藏数
    viewCount: number;           // 浏览数
  };
  pois: Poi[];                   // POI列表
  offlinePackages: OfflinePackage[];  // 离线包列表
  createdAt: string;             // 创建时间 (ISO 8601)
  updatedAt: string;             // 更新时间 (ISO 8601)
}
```

### 6.2 POI 模型（兴趣点）

```typescript
interface Poi {
  id: string;                    // POI唯一ID
  name: string;                  // POI名称
  type: 'safety' | 'navigation' | 'service' | 'info' | 'social';  // POI类型
  subtype: string;               // 子类型
  coordinates: {
    lat: number;                 // 纬度
    lng: number;                 // 经度
    altitude?: number;           // 海拔
  };
  sequence: number;              // 序号（用于排序）
  description?: string;          // 描述
  photos: string[];              // 照片URL数组
  priority: number;              // 优先级（1-10）
  metadata?: Record<string, any>;  // 扩展信息
}
```

### 6.3 TrackPoint 模型（轨迹点）

```typescript
interface TrackPoint {
  lat: number;                   // 纬度（WGS84）
  lng: number;                   // 经度（WGS84）
  altitude?: number;             // 海拔（米）
  timestamp?: string;            // 时间戳（ISO 8601）
}

interface TrackData {
  trailId: string;               // 路线ID
  trailName: string;             // 路线名称
  totalPoints: number;           // 轨迹点总数
  totalDistanceKm: number;       // 总距离（公里）
  points: TrackPoint[];          // 轨迹点数组
  gpxUrl: string;                // GPX文件URL
}
```

### 6.4 OfflinePackage 模型（离线包）

```typescript
interface OfflinePackage {
  id: string;                    // 离线包ID
  version: string;               // 版本号
  fileUrl: string;               // 文件URL
  fileSizeMb: number;            // 文件大小（MB）
  checksum: string;              // 文件校验值（SHA-256）
  minZoom: number;               // 最小缩放级别
  maxZoom: number;               // 最大缩放级别
  bounds: {
    north: number;
    south: number;
    east: number;
    west: number;
  };
  expiresAt: string;             // 过期时间 (ISO 8601)
}
```

---

## 附录

### A. 难度等级说明

| 难度 | 说明 | 适合人群 |
|------|------|----------|
| easy | 简单 | 新手，路况良好，坡度平缓 |
| moderate | 中等 | 有一定挑战，需要一定体力 |
| hard | 困难 | 高难度路线，需要专业装备 |

### B. POI类型说明

| 类型 | 说明 | 示例 |
|------|------|------|
| safety | 安全类 | 急救点、避难所、紧急电话 |
| navigation | 导航类 | 岔路口、里程碑、指示牌 |
| service | 服务类 | 补给点、洗手间、休息站 |
| info | 信息类 | 观景台、介绍牌、文物点 |
| social | 社交类 | 拍照点、网红打卡点 |

### C. 坐标系说明

所有坐标数据均采用 **WGS84** 坐标系（GPS坐标系）。

- 纬度范围：-90 ~ 90
- 经度范围：-180 ~ 180

---

> **文档说明**: 本文档作为 Week 2 B4-2 任务的交付物，包含完整的路线数据 API 接口定义。所有接口实现以此文档为准。
