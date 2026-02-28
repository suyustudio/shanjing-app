# QA Week 4 Day 2 Review Report

**Reviewer:** Dev Agent  
**Date:** 2026-02-28  
**Review 文档:**
1. `test-cases-trails.md` - 路线收藏测试用例
2. `integration-test-plan.md` - 集成测试方案

---

## 1. 路线收藏测试用例 Review (test-cases-trails.md)

### 1.1 可执行性 ✅ 良好

| 维度 | 评价 | 说明 |
|------|------|------|
| 用例描述 | 清晰 | 测试步骤和预期结果描述明确 |
| 前置条件 | 完整 | 用户登录状态、页面可访问性已说明 |
| 测试数据 | 缺失 | 未指定具体测试路线 ID |

**建议改进:**
- 补充测试数据：指定具体的 `trail_id` 或使用动态获取方式
- 添加边界情况：如收藏不存在的路线、重复收藏等异常场景

### 1.2 与代码一致性 ⚠️ 部分不符

**问题发现:**

1. **API 端点不匹配**
   - 测试用例描述的是前端按钮交互
   - 实际后端代码分析：
     - `Favorite` 模型存在于 Prisma schema
     - 但**未发现用户端的收藏/取消收藏 API 控制器**
     - 仅在 `admin-trails.service.ts` 中有 `favoriteCount` 统计

2. **缺失的 API 实现**
   ```
   期望的 API (根据测试用例推断):
   - POST   /api/trails/:id/favorite     (收藏)
   - DELETE /api/trails/:id/favorite     (取消收藏)
   - GET    /api/users/me/favorites      (获取收藏列表)
   
   实际代码中:
   - 无 trails 模块控制器（仅 admin/trails 有管理接口）
   - 无用户端收藏相关 API
   - 仅有 Favorite 数据模型定义
   ```

3. **Schema 验证**
   ```prisma
   model Favorite {
     id        String   @id @default(uuid())
     userId    String
     trailId   String
     createdAt DateTime @default(now())
     trail     Trail    @relation(fields: [trailId], references: [id])
   }
   ```
   - 模型定义正确，但缺少唯一约束（同一用户不应重复收藏同一路线）

**结论:** 测试用例基于假设的 API 设计，实际后端尚未实现用户端收藏接口。

### 1.3 技术可行性 ✅ 可自动化

- 用例结构适合使用 Jest + Supertest 进行 E2E 测试
- 需要补充 API 实现后才能执行

---

## 2. 集成测试方案 Review (integration-test-plan.md)

### 2.1 可执行性 ⚠️ 部分问题

| 步骤 | 操作 | 问题 |
|------|------|------|
| 1 | 用户注册 | 实际 API 为 `POST /auth/register/phone`，非 `/api/register` |
| 2 | 用户登录 | 实际 API 为 `POST /auth/login/phone`，非 `/api/login` |
| 3 | 浏览路线列表 | **API 不存在** - 无用户端路线列表接口 |
| 4 | 收藏路线 | **API 不存在** - 无收藏接口实现 |

**接口路径错误:**
- 方案中的 `/api/*` 路径与实际代码不符
- 实际代码使用 `/auth/*` 和 `/users/*` 等路径

### 2.2 与代码一致性 ❌ 不符

**实际 API 结构 (基于代码分析):**

```
Auth Module:
- POST /auth/register/phone    ✓ 存在
- POST /auth/register/wechat   ✓ 存在
- POST /auth/login/phone       ✓ 存在
- POST /auth/login/wechat      ✓ 存在
- POST /auth/refresh           ✓ 存在
- POST /auth/logout            ✓ 存在

Users Module:
- GET    /users/me             ✓ 存在
- PUT    /users/me             ✓ 存在
- PUT    /users/me/avatar      ✓ 存在
- PUT    /users/me/emergency   ✓ 存在
- PUT    /users/me/phone       ✓ 存在

Map Module:
- POST /map/geocode            ✓ 存在
- POST /map/regeocode          ✓ 存在
- POST /map/route/walking      ✓ 存在
- POST /map/route/driving      ✓ 存在
- POST /map/route/bicycling    ✓ 存在
- POST /map/route              ✓ 存在

Admin Trails Module:
- POST   /admin/trails         ✓ 存在 (管理端)
- GET    /admin/trails         ✓ 存在 (管理端)
- GET    /admin/trails/:id     ✓ 存在 (管理端)
- PUT    /admin/trails/:id     ✓ 存在 (管理端)
- DELETE /admin/trails/:id     ✓ 存在 (管理端)

缺失的 API (用户端):
- GET    /trails               ❌ 不存在
- GET    /trails/:id           ❌ 不存在
- POST   /trails/:id/favorite  ❌ 不存在
- GET    /users/me/favorites   ❌ 不存在
```

### 2.3 集成测试完整性 ⚠️ 场景覆盖不足

**当前覆盖:**
- ✅ 用户注册 → 登录流程
- ⚠️ 路线浏览 (API 缺失)
- ⚠️ 路线收藏 (API 缺失)

**建议补充场景:**
1. **异常流程:**
   - 收藏已删除的路线
   - 未登录状态下尝试收藏
   - 重复收藏同一路线

2. **数据验证:**
   - 收藏后查询用户收藏列表验证
   - 取消收藏后验证数据库记录删除

3. **关联验证:**
   - 路线被收藏后，admin 端 `favoriteCount` 统计正确性

### 2.4 技术可行性 ✅ 可自动化

- 测试框架：Jest + Supertest 已在项目中配置
- 参考：`test/user-system.e2e-spec.ts` 已实现类似模式
- 数据清理：已通过 `prisma` 服务实现

---

## 3. 关键发现与建议

### 3.1 阻塞问题 🔴

| 问题 | 优先级 | 说明 |
|------|--------|------|
| 用户端路线 API 缺失 | P0 | 无 `/trails` 接口，用户无法浏览路线 |
| 收藏功能 API 缺失 | P0 | 无收藏/取消收藏接口 |
| 用户收藏列表 API 缺失 | P1 | 无法获取用户收藏列表 |

### 3.2 建议实现 (供 Dev 参考)

```typescript
// 建议新增模块: src/modules/trails/trails.controller.ts

@Controller('trails')
export class TrailsController {
  // 获取路线列表
  @Get()
  async getTrails(@Query() query: TrailQueryDto) { }

  // 获取路线详情
  @Get(':id')
  async getTrailById(@Param('id') id: string) { }

  // 收藏路线
  @Post(':id/favorite')
  @UseGuards(JwtAuthGuard)
  async favoriteTrail(@CurrentUser('userId') userId: string, @Param('id') trailId: string) { }

  // 取消收藏
  @Delete(':id/favorite')
  @UseGuards(JwtAuthGuard)
  async unfavoriteTrail(@CurrentUser('userId') userId: string, @Param('id') trailId: string) { }
}

// 建议新增: src/modules/users/users.controller.ts

@Get('me/favorites')
@UseGuards(JwtAuthGuard)
async getMyFavorites(@CurrentUser('userId') userId: string) { }
```

### 3.3 测试用例修正建议

**修正后的集成测试步骤:**

```
1. POST /auth/register/phone
   Body: { phone, code, nickname }
   → 返回: { user, tokens }

2. POST /auth/login/phone
   Body: { phone, code }
   → 返回: { user, tokens }

3. GET /trails (需实现)
   Header: Authorization: Bearer {token}
   → 返回: [ { id, name, ... } ]

4. POST /trails/{id}/favorite (需实现)
   Header: Authorization: Bearer {token}
   → 返回: { success: true }

5. GET /users/me/favorites (需实现)
   Header: Authorization: Bearer {token}
   → 验证: 包含已收藏的路线
```

---

## 4. 总体评价

| 维度 | 评分 | 说明 |
|------|------|------|
| 可执行性 | ⭐⭐⭐☆☆ | 用例清晰但依赖未实现的 API |
| 代码一致性 | ⭐⭐☆☆☆ | 与当前代码实现有较大差距 |
| 完整性 | ⭐⭐⭐☆☆ | 覆盖核心流程但缺少异常场景 |
| 技术可行性 | ⭐⭐⭐⭐☆ | 测试框架已就绪，可自动化 |

**结论:**
QA 团队编写的测试用例和集成测试方案**逻辑正确**，但基于假设的完整 API 设计。当前后端代码仅实现了 Auth、Users、Map 和 Admin Trails 模块，**用户端路线浏览和收藏功能尚未实现**。建议 Dev 团队优先实现缺失的 API，然后 QA 可根据实际接口调整测试用例。

---

## 5. Action Items

| 序号 | 任务 | 负责人 | 优先级 |
|------|------|--------|--------|
| 1 | 实现 `GET /trails` 用户端路线列表 | Dev | P0 |
| 2 | 实现 `GET /trails/:id` 路线详情 | Dev | P0 |
| 3 | 实现 `POST /trails/:id/favorite` 收藏 | Dev | P0 |
| 4 | 实现 `DELETE /trails/:id/favorite` 取消收藏 | Dev | P0 |
| 5 | 实现 `GET /users/me/favorites` 收藏列表 | Dev | P1 |
| 6 | 更新集成测试方案中的 API 路径 | QA | P1 |
| 7 | 补充异常场景测试用例 | QA | P2 |
