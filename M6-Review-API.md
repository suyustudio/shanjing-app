# M6 评论系统 API 文档

> **版本**: v1.0  
> **日期**: 2026-03-20  
> **状态**: 开发中

---

## 接口概览

| 方法 | 路径 | 说明 | 认证 |
|------|------|------|------|
| POST | `/reviews/trails/:trailId` | 发表评论 | ✓ |
| GET | `/reviews/trails/:trailId` | 获取评论列表 | ✗ |
| GET | `/reviews/:id` | 获取评论详情 | ✗ |
| PUT | `/reviews/:id` | 编辑评论 | ✓ |
| DELETE | `/reviews/:id` | 删除评论 | ✓ |
| POST | `/reviews/:id/replies` | 回复评论 | ✓ |
| GET | `/reviews/:id/replies` | 获取回复列表 | ✗ |
| POST | `/reviews/:id/report` | 举报评论 | ✓ |

---

## 预定义标签

评论支持以下预定义标签（最多选择5个）：

| 类别 | 标签 |
|------|------|
| 风景类 | 风景优美、视野开阔、拍照圣地、秋色迷人、春花烂漫 |
| 难度类 | 难度适中、轻松休闲、挑战性强、适合新手、需要体能 |
| 设施类 | 设施完善、补给方便、厕所干净、指示牌清晰 |
| 人群类 | 适合亲子、宠物友好、人少清静、团队建设 |
| 特色类 | 历史文化、古迹众多、森林氧吧、溪流潺潺 |

---

## 接口详情

### 1. 发表评论

```http
POST /reviews/trails/:trailId
Authorization: Bearer {token}
Content-Type: application/json
```

**请求参数：**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| rating | number | ✓ | 评分 1.0-5.0，支持半星 |
| content | string | ✗ | 评论内容，10-500字 |
| tags | string[] | ✗ | 评论标签，最多5个 |
| photos | string[] | ✗ | 图片URL列表，最多3张 |

**请求示例：**

```json
{
  "rating": 4.5,
  "content": "这条路线风景很美，难度适中，非常适合周末徒步。推荐给大家！",
  "tags": ["风景优美", "难度适中", "适合亲子"],
  "photos": ["https://cdn.example.com/photo1.jpg"]
}
```

**响应示例：**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": "rev_xxx",
    "rating": 4.5,
    "content": "这条路线风景很美...",
    "tags": ["风景优美", "难度适中", "适合亲子"],
    "photos": ["https://cdn.example.com/photo1.jpg"],
    "likeCount": 0,
    "replyCount": 0,
    "isEdited": false,
    "user": {
      "id": "user_xxx",
      "nickname": "山友小明",
      "avatarUrl": "https://cdn.example.com/avatar.jpg"
    },
    "createdAt": "2026-03-20T10:00:00Z",
    "updatedAt": "2026-03-20T10:00:00Z"
  }
}
```

---

### 2. 获取评论列表

```http
GET /reviews/trails/:trailId?sort=newest&page=1&limit=10
```

**查询参数：**

| 参数 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| sort | string | newest | 排序：newest/highest/lowest |
| rating | number | - | 评分筛选 |
| page | number | 1 | 页码 |
| limit | number | 10 | 每页数量 |

**响应示例：**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "list": [
      {
        "id": "rev_xxx",
        "rating": 4.5,
        "content": "...",
        "tags": ["风景优美"],
        "photos": [],
        "likeCount": 12,
        "replyCount": 3,
        "isEdited": false,
        "user": { "id": "...", "nickname": "...", "avatarUrl": "..." },
        "createdAt": "2026-03-20T10:00:00Z",
        "updatedAt": "2026-03-20T10:00:00Z"
      }
    ],
    "total": 100,
    "page": 1,
    "limit": 10,
    "stats": {
      "trailId": "trail_xxx",
      "avgRating": 4.3,
      "totalCount": 100,
      "rating5Count": 45,
      "rating4Count": 35,
      "rating3Count": 15,
      "rating2Count": 3,
      "rating1Count": 2
    }
  }
}
```

---

### 3. 获取评论详情

```http
GET /reviews/:id
```

**响应示例：**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": "rev_xxx",
    "rating": 4.5,
    "content": "...",
    "tags": ["风景优美"],
    "photos": [],
    "likeCount": 12,
    "replyCount": 3,
    "isEdited": false,
    "user": { "id": "...", "nickname": "...", "avatarUrl": "..." },
    "createdAt": "2026-03-20T10:00:00Z",
    "updatedAt": "2026-03-20T10:00:00Z",
    "replies": [
      {
        "id": "reply_xxx",
        "content": "感谢分享！",
        "user": { "id": "...", "nickname": "...", "avatarUrl": "..." },
        "parentId": null,
        "createdAt": "2026-03-20T11:00:00Z"
      }
    ]
  }
}
```

---

### 4. 编辑评论

```http
PUT /reviews/:id
Authorization: Bearer {token}
Content-Type: application/json
```

**说明：**
- 只能编辑自己的评论
- 评论发表后 24 小时内可编辑
- 编辑后 `isEdited` 标记为 `true`

**请求参数：**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| rating | number | ✗ | 评分 1.0-5.0 |
| content | string | ✗ | 评论内容，10-500字 |
| tags | string[] | ✗ | 评论标签，最多5个 |

**响应：** 同发表评论

---

### 5. 删除评论

```http
DELETE /reviews/:id
Authorization: Bearer {token}
```

**说明：**
- 只能删除自己的评论
- 删除后路线评分统计会自动更新

**响应：** HTTP 204 No Content

---

### 6. 回复评论

```http
POST /reviews/:id/replies
Authorization: Bearer {token}
Content-Type: application/json
```

**请求参数：**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| content | string | ✓ | 回复内容，1-500字 |
| parentId | string | ✗ | 父回复ID（支持嵌套回复） |

**响应示例：**

```json
{
  "code": 0,
  "message": "success",
  "data": {
    "id": "reply_xxx",
    "content": "感谢分享！",
    "user": { "id": "...", "nickname": "...", "avatarUrl": "..." },
    "parentId": null,
    "createdAt": "2026-03-20T11:00:00Z"
  }
}
```

---

### 7. 获取回复列表

```http
GET /reviews/:id/replies
```

**响应：** 回复数组

---

### 8. 举报评论

```http
POST /reviews/:id/report
Authorization: Bearer {token}
Content-Type: application/json
```

**请求参数：**

| 参数 | 类型 | 必填 | 说明 |
|------|------|------|------|
| reason | string | ✓ | 举报原因，1-100字 |

**说明：**
- 不能举报自己的评论
- 举报后评论会被标记，等待审核

**响应：** HTTP 204 No Content

---

## 错误码

| 状态码 | 错误码 | 说明 |
|--------|--------|------|
| 400 | REVIEW_ALREADY_EXISTS | 已评论过该路线 |
| 400 | INVALID_TAGS | 无效的标签 |
| 400 | CANNOT_REPORT_SELF | 不能举报自己的评论 |
| 403 | EDIT_TIMEOUT | 超过24小时无法编辑 |
| 403 | NOT_AUTHORIZED | 无权操作 |
| 404 | REVIEW_NOT_FOUND | 评论不存在 |
| 404 | TRAIL_NOT_FOUND | 路线不存在 |

---

## 前端组件建议

### 评分组件
- 支持半星评分（1.0-5.0）
- 悬停预览效果
- 点击确认评分

### 评论列表组件
- 分页加载
- 按时间/评分排序
- 评分分布图表展示

### 评论表单组件
- 富文本输入（限制500字）
- 标签选择器（多选，最多5个）
- 图片上传（最多3张）
