# M6 问题修复方案验证报告

> **验证日期**: 2026-03-20  
> **验证人**: Product Agent (SubAgent)  
> **状态**: 已完成验证  

---

## 一、执行摘要

### 1.1 验证结论

| 验证项 | 状态 | 说明 |
|--------|------|------|
| 点赞功能方案 | ✅ 已确认 | 补充接口定义和数据模型 |
| 接口统一方案 | ✅ 已确认 | 统一为 M5 风格规范 |
| 缺失模块方案 | ⚠️ 部分确认 | 照片/关注/收藏夹需后续实现 |
| PRD 文档更新 | ✅ 已完成 | 补充遗漏功能点 |
| 测试用例更新 | ✅ 已完成 | 修正错误并补充场景 |

### 1.2 关键决策

1. **评分数据类型**: 统一使用 `integer 1-5`，不支持半星
2. **响应格式**: 统一使用 M5 风格 `{success, data, meta}`
3. **接口路径**: 统一使用 `/v1/` 前缀，资源嵌套风格
4. **点赞功能**: 补充 `review_likes` 表和独立点赞接口

---

## 二、点赞功能方案验证

### 2.1 点赞交互流程确认

```
用户点击点赞按钮
      ↓
前端调用 POST /v1/reviews/{reviewId}/like
      ↓
后端检查用户是否已点赞
      ↓
├─ 已点赞 → 返回 409 错误
└─ 未点赞 → 创建 like 记录
              ↓
        更新 review.likeCount (+1)
              ↓
        返回更新后的 likeCount 和 isLiked=true
              ↓
        前端更新 UI（按钮高亮 + 数量+1）
```

**取消点赞流程类似，使用 DELETE 方法**

### 2.2 点赞数展示方式确认

| 场景 | 展示方式 | 说明 |
|------|----------|------|
| 评论列表 | 👍 23 | 图标+数字，右对齐 |
| 评论详情 | 👍 256 | 同上，更大字号 |
| 我的评论 | 👍 12 · 💬 3 | 与回复数一起展示 |
| 点赞动画 | Scale(1.2) → 1 | 200ms spring 动画 |

### 2.3 点赞状态同步确认

- **本地状态**: 前端维护 isLiked 状态，即时反馈
- **服务端状态**: 数据库记录真实状态
- **冲突处理**: 重复点赞返回 409，前端同步状态
- **离线支持**: 暂不支持离线点赞，后续迭代考虑

### 2.4 点赞功能接口定义（已确认）

```yaml
# 点赞评论
POST /v1/reviews/{reviewId}/like
Authorization: Bearer {token}

Response 200:
  success: true
  data:
    reviewId: string
    likeCount: number      # 更新后的点赞数
    isLiked: true

# 取消点赞
DELETE /v1/reviews/{reviewId}/like
Authorization: Bearer {token}

Response 200:
  success: true
  data:
    reviewId: string
    likeCount: number      # 更新后的点赞数
    isLiked: false

# 批量检查点赞状态（用于列表）
POST /v1/reviews/batch-check-like
Authorization: Bearer {token}
Request Body:
  reviewIds: string[]     # 最多 100 个

Response 200:
  success: true
  data:
    reviewId1: true
    reviewId2: false
    ...
```

### 2.5 数据模型（已确认）

```prisma
// 评论点赞表
model ReviewLike {
  id        String   @id @default(cuid())
  reviewId  String
  userId    String
  createdAt DateTime @default(now())

  @@unique([reviewId, userId])  // 每个用户对每条评论只能点赞一次
  @@index([reviewId])           // 查询评论的所有点赞
  @@index([userId])             // 查询用户的所有点赞
  @@map("review_likes")
}

// 更新后的 Review 模型
model Review {
  id          String   @id @default(cuid())
  userId      String
  trailId     String
  rating      Int      // 1-5，integer 类型
  content     String
  difficulty  String?  // easy/moderate/hard
  isVerified  Boolean  @default(false)  // 是否体验过
  likeCount   Int      @default(0)
  replyCount  Int      @default(0)
  isEdited    Boolean  @default(false)
  isReported  Boolean  @default(false)
  status      String   @default("active") // active/hidden/deleted
  createdAt   DateTime @default(now())
  updatedAt   DateTime @updatedAt

  // 关联
  user    User           @relation(fields: [userId], references: [id])
  trail   Trail          @relation(fields: [trailId], references: [id])
  tags    ReviewTag[]
  photos  ReviewPhoto[]
  replies ReviewReply[]
  likes   ReviewLike[]

  @@unique([userId, trailId])
  @@index([trailId, createdAt])
  @@index([trailId, likeCount])  // 热门评论排序
  @@map("reviews")
}
```

---

## 三、接口统一方案验证

### 3.1 M6 与 M5 接口一致性确认

| 项目 | M5 风格 | M6 统一后 | 状态 |
|------|---------|-----------|------|
| 前缀 | `/v1/` | `/v1/` | ✅ 一致 |
| 响应格式 | `{success, data, meta}` | `{success, data, meta}` | ✅ 一致 |
| 错误格式 | `{success, error}` | `{success, error}` | ✅ 一致 |
| 认证方式 | Bearer Token | Bearer Token | ✅ 一致 |
| 资源路径 | 复数名词 | 复数名词 | ✅ 一致 |

### 3.2 响应格式统一

**成功响应**:
```json
{
  "success": true,
  "data": { /* 具体数据 */ },
  "meta": {
    "page": 1,
    "limit": 20,
    "total": 100,
    "hasNext": true
  }
}
```

**错误响应**:
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "错误描述",
    "details": { /* 详细错误信息 */ }
  }
}
```

### 3.3 字段命名统一

| 字段 | 旧命名 | 统一后 | 说明 |
|------|--------|--------|------|
| 用户头像 | avatar / avatarUrl | avatar | 统一为 avatar |
| 用户昵称 | nickname / name | nickname | 统一为 nickname |
| 创建时间 | createdAt / createTime | createdAt | 统一为 createdAt |
| 更新时间 | updatedAt / updateTime | updatedAt | 统一为 updatedAt |
| 评分 | rating (float) | rating (int) | 统一为 integer 1-5 |

### 3.4 接口路径统一

```yaml
# 评论系统 - 统一路径
GET    /v1/trails/{trailId}/reviews      # 获取评论列表
POST   /v1/trails/{trailId}/reviews      # 发表评论
GET    /v1/reviews/{reviewId}            # 获取评论详情
PUT    /v1/reviews/{reviewId}            # 编辑评论
DELETE /v1/reviews/{reviewId}            # 删除评论
POST   /v1/reviews/{reviewId}/like       # 点赞评论
DELETE /v1/reviews/{reviewId}/like       # 取消点赞
GET    /v1/reviews/{reviewId}/replies    # 获取回复列表
POST   /v1/reviews/{reviewId}/replies    # 回复评论

# 照片系统 - 统一路径
GET    /v1/photos                        # 获取照片列表
POST   /v1/photos/upload                 # 获取上传凭证
POST   /v1/photos                        # 创建照片记录
GET    /v1/photos/{photoId}              # 获取照片详情
DELETE /v1/photos/{photoId}              # 删除照片
POST   /v1/photos/{photoId}/like         # 点赞照片

# 关注系统 - 统一路径
POST   /v1/users/{userId}/follow         # 关注用户
DELETE /v1/users/{userId}/follow         # 取消关注
GET    /v1/users/{userId}/following      # 获取关注列表
GET    /v1/users/{userId}/followers      # 获取粉丝列表
GET    /v1/users/me/follow-recommendations # 推荐关注

# 收藏夹系统 - 统一路径
GET    /v1/collections                   # 获取收藏夹列表
POST   /v1/collections                   # 创建收藏夹
GET    /v1/collections/{collectionId}    # 获取收藏夹详情
PUT    /v1/collections/{collectionId}    # 更新收藏夹
DELETE /v1/collections/{collectionId}    # 删除收藏夹
POST   /v1/collections/{collectionId}/trails      # 添加路线
DELETE /v1/collections/{collectionId}/trails/{trailId}  # 移除路线
POST   /v1/trails/{trailId}/collect      # 快速收藏
```

---

## 四、缺失模块方案验证

### 4.1 照片系统功能完整性确认

| 功能点 | PRD 定义 | 验证结果 | 优先级 |
|--------|----------|----------|--------|
| 照片上传 | 拍照/相册选择 | ✅ 方案可行 | P0 |
| 瀑布流展示 | 发现页瀑布流 | ✅ 方案可行 | P0 |
| 位置标记 | GPS 位置解析 | ✅ 方案可行 | P1 |
| 照片点赞 | 点赞功能 | ✅ 方案可行 | P0 |
| 照片评论 | 评论功能 | ✅ 方案可行 | P1 |
| 隐私设置 | 公开/私密 | ✅ 方案可行 | P1 |

**技术方案确认**:
- 使用阿里云 OSS 直传，减少服务器带宽
- 瀑布流使用 `flutter_staggered_grid_view`
- 图片压缩使用 OSS 图片处理服务
- CDN 使用阿里云 CDN

### 4.2 关注系统功能完整性确认

| 功能点 | PRD 定义 | 验证结果 | 优先级 |
|--------|----------|----------|--------|
| 关注/取消关注 | 按钮操作 | ✅ 方案可行 | P0 |
| 关注列表 | 列表展示 | ✅ 方案可行 | P0 |
| 粉丝列表 | 列表展示 | ✅ 方案可行 | P0 |
| 互相关注标识 | 双向关注标识 | ✅ 方案可行 | P1 |
| 推荐关注 | 算法推荐 | ✅ 方案可行 | P2 |
| 用户搜索 | 昵称搜索 | ✅ 方案可行 | P1 |

**技术方案确认**:
- 使用 `follows` 表记录关注关系
- 互相关注通过联合查询判断
- 推荐关注使用简单规则（热门/兴趣）

### 4.3 收藏夹功能完整性确认

| 功能点 | PRD 定义 | 验证结果 | 优先级 |
|--------|----------|----------|--------|
| 创建收藏夹 | CRUD | ✅ 方案可行 | P0 |
| 添加/移除路线 | 批量操作 | ✅ 方案可行 | P0 |
| 快速收藏 | 一键收藏 | ✅ 方案可行 | P0 |
| 私密收藏夹 | 权限控制 | ✅ 方案可行 | P1 |
| 分享收藏夹 | 公开分享 | ✅ 方案可行 | P1 |
| 收藏备注 | 添加备注 | ✅ 方案可行 | P2 |

**技术方案确认**:
- 使用 `collections` 和 `collection_trails` 表
- 默认收藏夹 `isDefault=true`，不可删除
- 私密收藏夹通过 `isPublic` 字段控制

---

## 五、PRD 文档更新摘要

### 5.1 补充内容

1. **补充点赞功能详细设计**（第2.3节）
   - 点赞交互流程
   - 点赞数展示方式
   - 点赞状态同步机制

2. **补充"体验过"认证标识**（第2.5节）
   - 认证逻辑：用户完成过该路线
   - 标识展示位置

3. **补充评论审核机制**（第2.1节）
   - 敏感词过滤
   - 举报处理流程

4. **补充照片上传规范**（第3.5节）
   - OSS 直传流程
   - 图片压缩策略

### 5.2 修正内容

1. **评分数据类型**: 明确为 `integer 1-5`，不支持半星
2. **照片数量限制**: 统一为最多 9 张（评论）/ 9 张（照片上传）
3. **回复长度限制**: 统一为最多 200 字
4. **编辑时限**: 明确为 24 小时内可编辑

---

## 六、测试用例更新摘要

### 6.1 错误修正

- 修正 `TC-RV-014` 编号错误（原错误写为 `TC-PH-014`）

### 6.2 新增测试用例

| 用例ID | 测试场景 | 优先级 |
|--------|----------|--------|
| TC-RV-041 | 并发发表评价 | P1 |
| TC-RV-042 | 并发点赞一致性 | P1 |
| TC-RV-043 | XSS 攻击防护 | P0 |
| TC-RV-044 | SQL 注入防护 | P0 |
| TC-RV-045 | 评论嵌套层级限制 | P2 |
| TC-PH-036 | 超大图片上传 (10MB+) | P1 |
| TC-FL-026 | 关注列表大数据量性能 | P1 |

### 6.3 更新测试用例

- `TC-RV-002`: 更新评分边界测试，移除半星测试
- `TC-RV-011`: 补充点赞取消流程测试
- `TC-RV-004`: 更新照片数量上限为 9 张

---

## 七、修复任务清单

### 7.1 Dev Agent 修复任务

| 任务 | 优先级 | 预估工时 | 状态 |
|------|--------|----------|------|
| 创建 review_likes 表 | P0 | 1h | ⬜ |
| 实现点赞/取消点赞接口 | P0 | 4h | ⬜ |
| 统一接口路径风格 | P0 | 2h | ⬜ |
| 修改评分数据类型为 int | P0 | 1h | ⬜ |
| 统一响应格式 | P0 | 2h | ⬜ |
| 统一字段命名 | P0 | 1h | ⬜ |
| 添加数据库索引 | P0 | 2h | ⬜ |
| 实现照片系统 API | P0 | 16h | ⬜ |
| 实现关注系统 API | P0 | 8h | ⬜ |
| 实现收藏夹 API | P0 | 8h | ⬜ |

### 7.2 修复验收标准

- [ ] 点赞功能完整（点赞/取消点赞/批量检查）
- [ ] 所有接口使用统一路径风格 `/v1/`
- [ ] 所有响应使用统一格式 `{success, data, meta}`
- [ ] 评分数据类型为 integer 1-5
- [ ] 照片/关注/收藏夹 API 完整实现

---

## 八、结论与建议

### 8.1 验证结论

1. **点赞功能方案**: ✅ 已确认，补充接口定义和数据模型
2. **接口统一方案**: ✅ 已确认，统一为 M5 风格
3. **缺失模块方案**: ✅ 功能完整，待开发实现
4. **PRD 文档**: ✅ 已更新，补充遗漏功能点
5. **测试用例**: ✅ 已更新，修正错误并补充场景

### 8.2 后续建议

1. **优先级排序**:
   - P0: 点赞功能、接口统一、响应格式统一
   - P1: 照片系统 API、关注系统 API、收藏夹 API
   - P2: 高级评分算法、"体验过"标识

2. **风险提示**:
   - 照片上传涉及 OSS 配置，需提前准备
   - 社交功能需要内容审核，建议接入第三方服务
   - 瀑布流性能需重点关注

3. **验收要点**:
   - 确保所有 P0 功能完整实现
   - 确保接口风格与 M5 完全一致
   - 确保测试用例全部通过

---

**验证完成时间**: 2026-03-20 22:00  
**报告版本**: v1.0  
**下次验证**: Dev 修复完成后
