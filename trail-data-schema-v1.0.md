# 山径APP 路线数据标准格式 v1.0

## 概述

本文档定义了山径APP路线数据的标准JSON Schema格式，用于统一路线数据的存储、交换和验证。

---

## JSON Schema

```json
{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "$id": "https://shanji.app/schemas/trail-data-v1.0.json",
  "title": "Trail Data Schema",
  "description": "山径APP路线数据标准格式",
  "type": "object",
  "required": ["id", "name", "distance", "duration", "difficulty", "coordinates", "source"],
  "properties": {
    "id": {
      "type": "string",
      "description": "路线唯一标识符",
      "examples": ["trail_001", "hiking-uuid-1234"]
    },
    "name": {
      "type": "string",
      "description": "路线名称",
      "minLength": 1,
      "maxLength": 100,
      "examples": ["西湖环湖徒步", "黄山天都峰路线"]
    },
    "distance": {
      "type": "number",
      "description": "路线总距离（单位：公里）",
      "minimum": 0,
      "examples": [5.2, 12.8]
    },
    "duration": {
      "type": "number",
      "description": "预计完成时间（单位：分钟）",
      "minimum": 0,
      "examples": [120, 360]
    },
    "difficulty": {
      "type": "string",
      "description": "路线难度等级",
      "enum": ["easy", "moderate", "hard"],
      "enumDescriptions": {
        "easy": "简单 - 平坦路面，适合初学者和家庭",
        "moderate": "中等 - 有一定坡度，需要基本体能",
        "hard": "困难 - 陡峭或技术要求高，需要良好体能和经验"
      }
    },
    "description": {
      "type": "string",
      "description": "路线详细描述",
      "minLength": 1,
      "examples": ["这是一条风景优美的环湖路线，途经多个著名景点..."]
    },
    "coordinates": {
      "type": "array",
      "description": "路线坐标点数组，WGS84坐标系 [经度, 纬度]",
      "minItems": 2,
      "items": {
        "type": "array",
        "minItems": 2,
        "maxItems": 2,
        "items": {
          "type": "number"
        },
        "description": "坐标点 [longitude, latitude]"
      },
      "examples": [
        [[120.1551, 30.2741], [120.1602, 30.2755], [120.1650, 30.2760]]
      ]
    },
    "source": {
      "type": "string",
      "description": "数据来源标识",
      "examples": ["user_upload", "official", "partner_gaode", "partner_baidu"]
    },
    "elevation_gain": {
      "type": "number",
      "description": "累计爬升高度（单位：米）",
      "minimum": 0,
      "examples": [150, 850]
    },
    "max_elevation": {
      "type": "number",
      "description": "最高海拔（单位：米）",
      "examples": [450, 1864]
    },
    "tags": {
      "type": "array",
      "description": "路线标签",
      "items": {
        "type": "string"
      },
      "examples": [["风景优美", "适合拍照", "亲子友好"], ["挑战性", " technical", "需装备"]]
    },
    "images": {
      "type": "array",
      "description": "路线相关图片URL列表",
      "items": {
        "type": "string",
        "format": "uri"
      },
      "examples": [
        ["https://cdn.shanji.app/images/trail001_01.jpg"]
      ]
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "description": "记录创建时间（ISO 8601格式）",
      "examples": ["2024-01-15T08:30:00Z"]
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "description": "记录最后更新时间（ISO 8601格式）",
      "examples": ["2024-02-20T14:22:00Z"]
    },
    "location": {
      "type": "string",
      "description": "路线所在地理位置",
      "examples": ["杭州西湖", "黄山风景区"]
    },
    "collectionDate": {
      "type": "string",
      "format": "date",
      "description": "数据采集日期",
      "examples": ["2024-01-15"]
    },
    "notes": {
      "type": "string",
      "description": "采集备注信息",
      "examples": ["雨天路滑，注意安全"]
    },
    "features": {
      "type": "array",
      "description": "路线特色功能点",
      "items": {
        "type": "string"
      },
      "examples": [["观景台", "休息亭", "水源点"]]
    }
  },
  "additionalProperties": true
}
```

---

## 字段说明

### 必需字段

| 字段名 | 类型 | 说明 |
|--------|------|------|
| `id` | string | 路线唯一标识符 |
| `name` | string | 路线名称（1-100字符） |
| `distance` | number | 路线总距离（公里） |
| `duration` | number | 预计完成时间（分钟） |
| `difficulty` | string | 难度等级：`easy`/`moderate`/`hard` |
| `coordinates` | array | 路线坐标点数组，WGS84格式 |
| `source` | string | 数据来源标识 |

### 可选字段

| 字段名 | 类型 | 说明 |
|--------|------|------|
| `description` | string | 路线详细描述 |
| `elevation_gain` | number | 累计爬升高度（米） |
| `max_elevation` | number | 最高海拔（米） |
| `tags` | array | 路线标签数组 |
| `images` | array | 图片URL数组 |
| `created_at` | string | 创建时间（ISO 8601） |
| `updated_at` | string | 更新时间（ISO 8601） |
| `location` | string | 路线所在地理位置 |
| `collectionDate` | string | 数据采集日期 |
| `notes` | string | 采集备注信息 |
| `features` | array | 路线特色功能点 |

---

## 难度分级说明

| 等级 | 标识 | 说明 |
|------|------|------|
| 简单 | `easy` | 平坦路面，适合初学者和家庭 |
| 中等 | `moderate` | 有一定坡度，需要基本体能 |
| 困难 | `hard` | 陡峭或技术要求高，需要良好体能和经验 |

---

## 坐标格式说明

- **坐标系**: WGS84 (EPSG:4326)
- **格式**: `[经度, 纬度]` 的数组
- **示例**: `[120.1551, 30.2741]` 表示经度120.1551°，纬度30.2741°
- **注意**: 坐标数组至少包含2个点（起点和终点）

---

## 示例数据

```json
{
  "id": "trail_xihu_001",
  "name": "西湖环湖徒步",
  "distance": 10.5,
  "duration": 180,
  "difficulty": "easy",
  "description": "环绕西湖的经典徒步路线，途经断桥、苏堤、白堤等著名景点，风景优美，适合各年龄段游客。",
  "coordinates": [
    [120.1551, 30.2741],
    [120.1602, 30.2755],
    [120.1650, 30.2760],
    [120.1700, 30.2750],
    [120.1551, 30.2741]
  ],
  "source": "official",
  "elevation_gain": 45,
  "max_elevation": 35,
  "tags": ["风景优美", "适合拍照", "亲子友好", "城市徒步"],
  "images": [
    "https://cdn.shanji.app/images/xihu_01.jpg",
    "https://cdn.shanji.app/images/xihu_02.jpg"
  ],
  "created_at": "2024-01-15T08:30:00Z",
  "updated_at": "2024-02-20T14:22:00Z"
}
```

---

## 版本历史

| 版本 | 日期 | 说明 |
|------|------|------|
| v1.0 | 2024-XX-XX | 初始版本，定义基础路线数据格式 |

---

## 附录

### 数据来源标识建议值

- `user_upload` - 用户上传
- `official` - 官方发布
- `partner_gaode` - 高德地图合作数据
- `partner_baidu` - 百度地图合作数据
- `import_gpx` - GPX文件导入
- `community` - 社区贡献

### 常用标签建议

- 难度相关: `适合新手`, `有一定挑战`, `高难度`
- 场景相关: `城市徒步`, `山地徒步`, `森林徒步`, `海岸线`
- 特色相关: `风景优美`, `适合拍照`, `历史文化`, `亲子友好`, `宠物友好`
- 季节相关: `春季推荐`, `夏季避暑`, `秋季赏叶`, `冬季雪景`
