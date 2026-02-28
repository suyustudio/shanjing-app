# 山径APP API 文档

## 目录

- [管理端 API (admin)](#管理端-api-admin)
- [地图服务 API (map)](#地图服务-api-map)

---

## 管理端 API (admin)

### 基础信息

- **Base URL**: `/admin`
- **认证方式**: Bearer Token (JWT)

### 1. 管理员认证

#### POST /admin/auth/login

管理员登录获取 Token。

**请求参数**:

| 字段     | 类型   | 必填 | 说明       |
|----------|--------|------|------------|
| username | string | 是   | 管理员账号 |
| password | string | 是   | 管理员密码 |

**请求示例**:
```json
{
  "username": "admin",
  "password": "password123"
}
```

**响应**:

| 字段  | 类型   | 说明        |
|-------|--------|-------------|
| token | string | JWT Token   |

**响应示例**:
```json
{
  "token": "eyJhbGciOiJIUzI1NiIs..."
}
```

**错误码**:
- `400` - 用户名和密码不能为空
- `401` - 用户名或密码错误
- `500` - 管理员账号未配置

---

### 2. 路线管理

#### GET /admin/trails

获取路线列表（支持分页、筛选、排序）。

**请求头**:
```
Authorization: Bearer <token>
```

**查询参数**:

| 字段        | 类型    | 必填 | 默认值   | 说明                                     |
|-------------|---------|------|----------|------------------------------------------|
| page        | number  | 否   | 1        | 页码                                     |
| limit       | number  | 否   | 20       | 每页数量                                 |
| difficulty  | string  | 否   | -        | 难度筛选: easy/moderate/hard             |
| city        | string  | 否   | -        | 城市筛选                                 |
| isPublished | boolean | 否   | -        | 发布状态筛选                             |
| sortBy      | string  | 否   | createdAt| 排序字段: createdAt/updatedAt/viewCount/favoriteCount |
| sortOrder   | string  | 否   | desc     | 排序顺序: asc/desc                       |

**响应**:

```json
{
  "success": true,
  "data": {
    "items": [
      {
        "id": "clq123...",
        "name": "九溪十八涧",
        "distanceKm": 8.5,
        "durationMin": 180,
        "elevationGainM": 350.5,
        "difficulty": "moderate",
        "tags": ["森林", "溪流"],
        "city": "杭州",
        "district": "西湖区",
        "coverImages": ["https://..."],
        "isPublished": true,
        "viewCount": 1024,
        "favoriteCount": 128,
        "createdAt": "2024-01-15T08:30:00.000Z",
        "updatedAt": "2024-01-15T10:30:00.000Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "totalPages": 5,
      "hasMore": true
    }
  }
}
```

---

#### POST /admin/trails

创建新路线。

**请求头**:
```
Authorization: Bearer <token>
```

**请求参数**:

| 字段            | 类型     | 必填 | 说明                    |
|-----------------|----------|------|-------------------------|
| name            | string   | 是   | 路线名称 (2-100字符)    |
| description     | string   | 否   | 路线描述 (0-5000字符)   |
| distanceKm      | number   | 是   | 距离（公里）            |
| durationMin     | number   | 是   | 预计用时（分钟）        |
| elevationGainM  | number   | 是   | 累计爬升（米）          |
| elevationLossM  | number   | 否   | 累计下降（米）          |
| difficulty      | string   | 是   | 难度: easy/moderate/hard|
| tags            | string[] | 否   | 标签数组                |
| coverImages     | string[] | 否   | 封面图片URL数组         |
| gpxUrl          | string   | 否   | GPX文件URL              |
| city            | string   | 否   | 城市                    |
| district        | string   | 否   | 区县                    |
| startPointAddress| string  | 是   | 起点地址                |
| startPoint      | object   | 是   | 起点坐标 {lat, lng}     |
| bounds          | object   | 否   | 边界框 {north,south,east,west} |
| elevationProfile| array    | 否   | 海拔剖面数据            |
| safetyInfo      | object   | 否   | 安全信息                |
| isPublished     | boolean  | 否   | 是否立即发布            |

**请求示例**:
```json
{
  "name": "九溪十八涧徒步路线",
  "description": "经典杭州徒步路线...",
  "distanceKm": 8.5,
  "durationMin": 180,
  "elevationGainM": 350.5,
  "difficulty": "moderate",
  "tags": ["森林", "溪流", "亲子友好"],
  "city": "杭州",
  "district": "西湖区",
  "startPointAddress": "龙井村入口",
  "startPoint": {
    "lat": 30.2741,
    "lng": 120.1551
  },
  "isPublished": true
}
```

**响应**:

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

**错误码**:
- `400` - 请求参数错误
- `401` - 未登录或Token无效
- `403` - 权限不足
- `409` - 路线名称已存在

---

#### PATCH /admin/trails/:id

更新路线信息（支持部分更新）。

**请求头**:
```
Authorization: Bearer <token>
```

**路径参数**:

| 字段 | 类型   | 必填 | 说明    |
|------|--------|------|---------|
| id   | string | 是   | 路线ID  |

**请求参数**: 同 POST /admin/trails（所有字段可选）

**响应**:

```json
{
  "success": true,
  "message": "路线更新成功",
  "data": {
    "id": "clq1234567890abcdef",
    "name": "九溪十八涧徒步路线",
    "updatedAt": "2024-01-15T10:30:00.000Z"
  }
}
```

**错误码**:
- `400` - 请求参数错误
- `401` - 未登录或Token无效
- `403` - 权限不足
- `404` - 路线不存在
- `409` - 路线名称已存在

---

#### DELETE /admin/trails/:id

删除路线。

**请求头**:
```
Authorization: Bearer <token>
```

**路径参数**:

| 字段 | 类型   | 必填 | 说明    |
|------|--------|------|---------|
| id   | string | 是   | 路线ID  |

**响应**:

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

**错误码**:
- `401` - 未登录或Token无效
- `403` - 权限不足
- `404` - 路线不存在

---

## 地图服务 API (map)

### 基础信息

- **服务类型**: 内部服务 (Service)
- **数据源**: 高德地图 API

### 1. 地理编码服务 (GeocodeService)

#### geocode(address: string)

将地址转换为经纬度坐标。

**参数**:

| 字段    | 类型   | 必填 | 说明     |
|---------|--------|------|----------|
| address | string | 是   | 地址字符串 |

**返回值**:

| 字段      | 类型   | 说明     |
|-----------|--------|----------|
| longitude | number | 经度     |
| latitude  | number | 纬度     |

**返回示例**:
```typescript
{
  longitude: 120.1551,
  latitude: 30.2741
}
```

---

### 2. 逆地理编码服务 (RegeocodeService)

#### regeocode(longitude: number, latitude: number)

将经纬度坐标转换为地址。

**参数**:

| 字段      | 类型   | 必填 | 说明 |
|-----------|--------|------|------|
| longitude | number | 是   | 经度 |
| latitude  | number | 是   | 纬度 |

**返回值**: string (格式化地址)

**返回示例**:
```
"浙江省杭州市西湖区龙井村"
```

---

### 3. 路线规划服务 (RouteService)

#### planRoute(origin, destination)

规划驾驶路线。

**参数**:

| 字段        | 类型   | 必填 | 说明     |
|-------------|--------|------|----------|
| origin      | object | 是   | 起点坐标 |
| origin.longitude | number | 是 | 起点经度 |
| origin.latitude  | number | 是 | 起点纬度 |
| destination | object | 是   | 终点坐标 |
| destination.longitude | number | 是 | 终点经度 |
| destination.latitude  | number | 是 | 终点纬度 |

**返回值**:

| 字段     | 类型   | 说明             |
|----------|--------|------------------|
| distance | number | 距离（米）       |
| duration | number | 预计时间（秒）   |
| polyline | string | 路线坐标串       |

**返回示例**:
```typescript
{
  distance: 8500,
  duration: 1200,
  polyline: "120.1551,30.2741;120.1600,30.2800;..."
}
```

---

### 4. 高德服务 (GaodeService)

#### regeocode(request)

逆地理编码（增强版）。

**参数**:

| 字段 | 类型   | 必填 | 说明 |
|------|--------|------|------|
| lng  | number | 是   | 经度 |
| lat  | number | 是   | 纬度 |

**返回值**:

| 字段     | 类型    | 说明           |
|----------|---------|----------------|
| success  | boolean | 是否成功       |
| error    | string  | 错误信息       |
| address  | string  | 格式化地址     |
| province | string  | 省份           |
| city     | string  | 城市           |
| district | string  | 区县           |
| street   | string  | 街道/乡镇      |
| adcode   | string  | 行政区划代码   |

**返回示例**:
```typescript
{
  success: true,
  address: "浙江省杭州市西湖区龙井村",
  province: "浙江省",
  city: "杭州市",
  district: "西湖区",
  street: "龙井村",
  adcode: "330106"
}
```

---

## 数据类型定义

### Difficulty (难度枚举)

```typescript
enum Difficulty {
  EASY = 'easy',         // 简单
  MODERATE = 'moderate', // 中等
  HARD = 'hard'          // 困难
}
```

### CoordinateDto (坐标点)

```typescript
{
  lat: number;      // 纬度 (-90 ~ 90)
  lng: number;      // 经度 (-180 ~ 180)
  altitude?: number; // 海拔（米）
}
```

---

## 环境变量

| 变量名        | 说明             | 使用模块     |
|---------------|------------------|--------------|
| JWT_SECRET    | JWT 密钥         | admin        |
| ADMIN_USERNAME| 管理员账号       | admin/auth   |
| ADMIN_PASSWORD| 管理员密码       | admin/auth   |
| AMAP_KEY      | 高德地图 API Key | map          |
