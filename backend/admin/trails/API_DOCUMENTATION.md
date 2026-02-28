# 后台管理 - 路线管理 API 文档

## 概述

本文档描述后台管理系统的路线管理接口，提供路线的创建、更新、删除功能。

**基础路径**: `/admin/trails`

**认证要求**: 所有接口需要 JWT Token，且用户角色必须为 `admin` 或 `super_admin`

---

## 接口列表

### 1. 创建路线

创建新路线，可选择立即发布或保存为草稿。

**请求**

```http
POST /admin/trails
Content-Type: application/json
Authorization: Bearer {jwt_token}
```

**请求体 (Request Body)**

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| name | string | ✅ | 路线名称 (2-100字符) |
| description | string | ❌ | 路线描述 (最多5000字符) |
| distanceKm | number | ✅ | 距离（公里） |
| durationMin | number | ✅ | 预计用时（分钟） |
| elevationGainM | number | ✅ | 累计爬升（米） |
| elevationLossM | number | ❌ | 累计下降（米） |
| difficulty | string | ✅ | 难度等级: `easy`, `moderate`, `hard` |
| tags | string[] | ❌ | 标签数组 |
| coverImages | string[] | ❌ | 封面图片URL数组 |
| gpxUrl | string | ❌ | GPX文件URL |
| city | string | ❌ | 城市 |
| district | string | ❌ | 区县 |
| startPointAddress | string | ✅ | 起点地址 |
| startPoint | object | ✅ | 起点坐标 `{ lat, lng, altitude? }` |
| bounds | object | ❌ | 边界框 `{ north, south, east, west }` |
| elevationProfile | array | ❌ | 海拔剖面 `[{ distance, elevation }]` |
| safetyInfo | object | ❌ | 安全信息 |
| isPublished | boolean | ❌ | 是否立即发布，默认 `false` |

**请求示例**

```json
{
  "name": "九溪十八涧徒步路线",
  "description": "经典杭州徒步路线，沿途溪流潺潺，风景优美...",
  "distanceKm": 8.5,
  "durationMin": 180,
  "elevationGainM": 350.5,
  "elevationLossM": 350.5,
  "difficulty": "moderate",
  "tags": ["森林", "溪流", "亲子友好"],
  "coverImages": ["https://example.com/images/trail1.jpg"],
  "city": "杭州",
  "district": "西湖区",
  "startPointAddress": "龙井村入口",
  "startPoint": {
    "lat": 30.2741,
    "lng": 120.1551,
    "altitude": 150.5
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
  "safetyInfo": {
    "femaleFriendly": true,
    "hasRestroom": true
  },
  "isPublished": true
}
```

**响应示例 (201 Created)**

```json
{
  "success": true,
  "message": "路线创建成功",
  "data": {
    "id": "clq1234567890abcdef",
    "name": "九溪十八涧徒步路线",
    "createdAt": "2024-01-15T08:30:00.000Z"
  }
}
```

**错误响应**

- `400` - 请求参数错误（字段验证失败）
- `401` - 未登录或Token无效
- `403` - 权限不足（需要管理员权限）
- `409` - 路线名称已存在

---

### 2. 更新路线

更新现有路线信息，支持部分更新。

**请求**

```http
PATCH /admin/trails/{id}
Content-Type: application/json
Authorization: Bearer {jwt_token}
```

**路径参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | string | 路线ID |

**请求体 (Request Body)**

与创建路线相同，但所有字段都是可选的。只提供需要更新的字段。

**请求示例**

```json
{
  "name": "九溪十八涧经典徒步路线",
  "description": "更新后的描述...",
  "isPublished": true
}
```

**响应示例 (200 OK)**

```json
{
  "success": true,
  "message": "路线更新成功",
  "data": {
    "id": "clq1234567890abcdef",
    "name": "九溪十八涧经典徒步路线",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

**错误响应**

- `400` - 请求参数错误
- `401` - 未登录或Token无效
- `403` - 权限不足
- `404` - 路线不存在
- `409` - 路线名称已存在

---

### 3. 删除路线

删除路线，删除后不可恢复。

**请求**

```http
DELETE /admin/trails/{id}
Authorization: Bearer {jwt_token}
```

**路径参数**

| 参数 | 类型 | 说明 |
|------|------|------|
| id | string | 路线ID |

**响应示例 (200 OK)**

```json
{
  "success": true,
  "message": "路线删除成功",
  "data": {
    "id": "clq1234567890abcdef",
    "name": "九溪十八涧徒步路线",
    "deletedAt": "2024-01-15T12:00:00.000Z"
  }
}
```

**错误响应**

- `401` - 未登录或Token无效
- `403` - 权限不足
- `404` - 路线不存在

---

## 数据类型定义

### Difficulty 枚举

| 值 | 说明 |
|----|------|
| `easy` | 简单 |
| `moderate` | 中等 |
| `hard` | 困难 |

### CoordinateDto

```typescript
{
  lat: number;      // 纬度 (-90 ~ 90)
  lng: number;      // 经度 (-180 ~ 180)
  altitude?: number; // 海拔（米）
}
```

### BoundsInputDto

```typescript
{
  north: number;  // 北边界
  south: number;  // 南边界
  east: number;   // 东边界
  west: number;   // 西边界
}
```

### ElevationPointDto

```typescript
{
  distance: number;   // 距离起点的距离（公里）
  elevation: number;  // 海拔高度（米）
}
```

---

## 权限控制

所有后台管理接口都需要：

1. **JWT 认证** - 请求头必须包含有效的 `Authorization: Bearer {token}`
2. **角色权限** - 用户角色必须为 `admin` 或 `super_admin`

**权限检查流程：**

```
请求 → JwtAuthGuard → RolesGuard → 业务处理
            ↓              ↓
        验证Token      验证角色
```

---

## 代码集成

### 1. 注册模块

在 `app.module.ts` 中注册 `AdminTrailsModule`：

```typescript
import { AdminTrailsModule } from './admin/trails';

@Module({
  imports: [
    // ... 其他模块
    AdminTrailsModule,
  ],
})
export class AppModule {}
```

### 2. 使用装饰器控制权限

```typescript
import { Roles, UserRole } from '../common/guards/roles.guard';

// 在控制器级别设置角色要求
@Controller('admin/trails')
@Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
export class AdminTrailsController {
  // ...
}
```

---

## 注意事项

1. **名称唯一性** - 路线名称在创建和更新时会检查唯一性（不区分大小写）
2. **发布状态** - 创建时设置 `isPublished: true` 会同时设置发布时间
3. **部分更新** - PATCH 接口支持部分更新，只提供需要修改的字段
4. **级联删除** - 删除路线时会同时删除关联的 POI 和离线包（如果数据库设置了级联）
5. **关联数据检查** - 删除前会检查是否有用户收藏或完成记录，并记录警告日志
