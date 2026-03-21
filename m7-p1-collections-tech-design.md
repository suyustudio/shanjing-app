# M7 P1 收藏夹增强功能 - 技术设计文档

## 1. 概述

### 1.1 项目背景
- **M6阶段**：已完成基础收藏功能（收藏/取消收藏、查看收藏列表）
- **M7 P1目标**：增强收藏夹功能，支持分类和批量管理
- **需求状态**：product agent 正在细化需求文档（预计1-2小时完成）
- **技术准备**：2-4小时完成前期技术分析和架构设计

### 1.2 设计原则
1. **向后兼容**：现有收藏数据不能丢失，API保持向下兼容
2. **性能优先**：收藏数据可能较多，需考虑批量操作的性能
3. **遵循规范**：遵循现有设计系统规范和技术栈
4. **模块化**：功能模块清晰，便于后续扩展

## 2. 现有架构分析

### 2.1 前端架构
```
lib/
├── screens/collections/
│   ├── collections_list_screen.dart      # 收藏夹列表页
│   └── collection_detail_screen.dart     # 收藏夹详情页
├── widgets/collections/
│   ├── collection_card.dart              # 收藏夹卡片
│   ├── collection_trail_card.dart        # 收藏路线卡片
│   ├── collection_form_dialog.dart       # 收藏夹表单弹窗
│   ├── collection_selector_dialog.dart   # 收藏夹选择器
│   └── quick_collect_button.dart         # 快速收藏按钮
├── models/
│   └── collection_model.dart             # 数据模型
└── services/
    └── collection_service.dart           # 收藏夹服务
```

### 2.2 后端架构
```
backend/collections/
├── collections.module.ts                 # 模块定义
├── collections.controller.ts             # 控制器
├── collections.service.ts                # 业务逻辑
└── dto/
    ├── collection.dto.ts                 # 请求DTO
    └── collection-response.dto.ts        # 响应DTO
```

### 2.3 数据库模型（当前）
```prisma
// 收藏夹表
model Collection {
  id           String   @id @default(cuid())
  userId       String   @map("user_id")
  name         String   @db.VarChar(20)
  description  String?  @db.VarChar(200)
  coverUrl     String?  @map("cover_url")
  trailCount   Int      @default(0) @map("trail_count")
  isPublic     Boolean  @default(true) @map("is_public")
  isDefault    Boolean  @default(false) @map("is_default")
  sortOrder    Int      @default(0) @map("sort_order")
  createdAt    DateTime @default(now()) @map("created_at")
  updatedAt    DateTime @updatedAt @map("updated_at")
  
  user         User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  trails       CollectionTrail[]
  
  @@unique([userId, name])
  @@index([userId, sortOrder])
  @@index([userId, isDefault])
  @@index([isPublic, createdAt])
}

// 收藏夹-路线关联表
model CollectionTrail {
  id            String   @id @default(cuid())
  collectionId  String   @map("collection_id")
  trailId       String   @map("trail_id")
  note          String?  @db.VarChar(200)
  addedAt       DateTime @default(now()) @map("added_at")
  sortOrder     Int      @default(0) @map("sort_order")
  
  collection    Collection @relation(fields: [collectionId], references: [id], onDelete: Cascade)
  trail         Trail      @relation(fields: [trailId], references: [id], onDelete: Cascade)
  
  @@unique([collectionId, trailId])
  @@index([collectionId, sortOrder])
  @@index([trailId])
}
```

### 2.4 现有API接口
| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/collections` | 获取收藏夹列表 |
| POST | `/collections` | 创建收藏夹 |
| GET | `/collections/:id` | 获取收藏夹详情 |
| PUT | `/collections/:id` | 更新收藏夹 |
| DELETE | `/collections/:id` | 删除收藏夹 |
| POST | `/collections/:id/trails` | 添加路线到收藏夹 |
| DELETE | `/collections/:id/trails/:trailId` | 从收藏夹移除路线 |
| PUT | `/collections/:id/sort` | 排序收藏夹内路线 |
| POST | `/trails/:id/collect` | 快速收藏（添加到默认收藏夹） |

## 3. 功能需求分析（预期）

基于产品需求背景，预计需要以下增强功能：

### 3.1 收藏夹分类管理
- **分类标签**：为收藏夹添加标签（如：工作、旅行、周末等）
- **分类筛选**：按标签筛选收藏夹
- **分类统计**：显示各类别的收藏夹数量

### 3.2 批量操作功能
- **批量添加路线**：多选路线添加到收藏夹
- **批量移动路线**：将路线从一个收藏夹移动到另一个
- **批量移除路线**：从收藏夹中批量移除路线
- **批量删除收藏夹**：同时删除多个收藏夹

### 3.3 收藏夹搜索筛选
- **关键词搜索**：在收藏夹内搜索路线
- **高级筛选**：按难度、距离、时长等条件筛选
- **排序选项**：多种排序方式（添加时间、距离、评分等）

### 3.4 界面增强
- **多选模式UI**：支持列表项多选
- **批量操作工具栏**：选中项时显示操作工具栏
- **分类管理界面**：标签创建、编辑、删除界面

## 4. 技术架构设计

### 4.1 数据模型扩展

#### 4.1.1 方案A：添加分类标签字段（简单方案）
```prisma
model Collection {
  // ... 现有字段
  tags        String[] @default([])  // 标签数组，存储字符串标签
  category    String?  @db.VarChar(20)  // 主分类
}
```

**优点**：
- 实现简单，无需新增表
- 查询性能好，可直接筛选
- 向后兼容，现有数据无需迁移

**缺点**：
- 标签管理功能有限
- 不支持标签的元数据（颜色、图标等）

#### 4.1.2 方案B：独立的标签系统（扩展方案）
```prisma
// 标签表
model CollectionTag {
  id          String   @id @default(cuid())
  userId      String   @map("user_id")
  name        String   @db.VarChar(20)
  color       String?  @db.VarChar(7)  // HEX颜色，如 #FF0000
  icon        String?  @db.VarChar(50)
  sortOrder   Int      @default(0) @map("sort_order")
  createdAt   DateTime @default(now()) @map("created_at")
  
  user        User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  collections CollectionTagRelation[]
  
  @@unique([userId, name])
  @@index([userId, sortOrder])
}

// 收藏夹-标签关联表
model CollectionTagRelation {
  id            String   @id @default(cuid())
  collectionId  String   @map("collection_id")
  tagId         String   @map("tag_id")
  createdAt     DateTime @default(now()) @map("created_at")
  
  collection    Collection @relation(fields: [collectionId], references: [id], onDelete: Cascade)
  tag           CollectionTag @relation(fields: [tagId], references: [id], onDelete: Cascade)
  
  @@unique([collectionId, tagId])
  @@index([collectionId])
  @@index([tagId])
}
```

**优点**：
- 功能完整，支持标签管理
- 可扩展性强，支持标签颜色、图标等元数据
- 标签可复用，独立管理

**缺点**：
- 实现复杂，需要新增表和关联
- 查询性能稍差（需要JOIN）
- 需要数据迁移

#### 4.1.3 推荐方案
基于开发时间和复杂度考虑，建议**分阶段实施**：

**阶段1（M7 P1）**：采用方案A（简单标签数组），快速实现基本分类功能
**阶段2（后续迭代）**：如有需要，升级到方案B（完整标签系统）

### 4.2 批量操作API设计

#### 4.2.1 批量添加路线
```typescript
POST /collections/:id/trails/batch
{
  "trailIds": ["trail_001", "trail_002", "trail_003"],
  "note": "批量添加的备注" // 可选，应用到所有路线
}
```

#### 4.2.2 批量移除路线
```typescript
DELETE /collections/:id/trails/batch
{
  "trailIds": ["trail_001", "trail_002", "trail_003"]
}
```

#### 4.2.3 批量移动路线
```typescript
POST /collections/batch-move
{
  "sourceCollectionId": "collection_001",
  "targetCollectionId": "collection_002",
  "trailIds": ["trail_001", "trail_002", "trail_003"]
}
```

#### 4.2.4 批量删除收藏夹
```typescript
DELETE /collections/batch
{
  "collectionIds": ["collection_001", "collection_002", "collection_003"]
}
```

### 4.3 搜索筛选API扩展

#### 4.3.1 收藏夹列表筛选
```typescript
GET /collections?tags=工作,旅行&search=杭州&sort=updated&page=1&limit=20
```

**查询参数**：
- `tags`：标签筛选，逗号分隔
- `search`：关键词搜索（名称、描述）
- `sort`：排序方式（`created`, `updated`, `name`, `trailCount`）
- `page`：页码
- `limit`：每页数量

#### 4.3.2 收藏夹内路线搜索
```typescript
GET /collections/:id/trails?search=西湖&difficulty=easy,moderate&minDistance=0&maxDistance=10&sort=added&page=1&limit=20
```

**查询参数**：
- `search`：路线名称关键词
- `difficulty`：难度筛选，逗号分隔
- `minDistance`：最小距离（km）
- `maxDistance`：最大距离（km）
- `minDuration`：最小时长（min）
- `maxDuration`：最大时长（min）
- `sort`：排序方式（`added`, `name`, `distance`, `duration`, `difficulty`）
- `page`：页码
- `limit`：每页数量

### 4.4 前端架构设计

#### 4.4.1 多选模式组件
```dart
// lib/widgets/collections/collection_selection_manager.dart
class CollectionSelectionManager extends ChangeNotifier {
  final Set<String> selectedIds = {};
  bool get isSelectionMode => selectedIds.isNotEmpty;
  int get selectedCount => selectedIds.length;
  
  void toggle(String id) { ... }
  void selectAll(List<String> ids) { ... }
  void clear() { ... }
  // ...
}
```

#### 4.4.2 批量操作工具栏
```dart
// lib/widgets/collections/batch_action_bar.dart
class BatchActionBar extends StatelessWidget {
  final CollectionSelectionManager selectionManager;
  final VoidCallback onDelete;
  final VoidCallback onMove;
  final VoidCallback onAddToCollection;
  
  // ...
}
```

#### 4.4.3 分类标签组件
```dart
// lib/widgets/collections/collection_tag_chip.dart
class CollectionTagChip extends StatelessWidget {
  final String tag;
  final bool isSelected;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  
  // ...
}
```

## 5. 开发计划（按功能模块拆分）

### 5.1 第一阶段：技术准备（2-4小时）
- [x] 代码分析：现有收藏功能架构
- [x] 架构设计：数据模型扩展方案
- [x] API设计：批量操作和搜索接口
- [x] 技术选型：UI组件和存储方案
- [x] 初始代码结构搭建

### 5.2 第二阶段：后端开发（预计4小时）
| 模块 | 功能 | 预估工时 |
|------|------|----------|
| 数据模型 | 添加tags字段到Collection表 | 1h |
| 批量操作API | 批量添加/移除/移动路线 | 2h |
| 搜索筛选API | 收藏夹列表和内容搜索 | 1h |
| **小计** | | **4h** |

### 5.3 第三阶段：前端开发（预计6小时）
| 模块 | 功能 | 预估工时 |
|------|------|----------|
| 多选模式 | 列表项多选支持 | 1.5h |
| 批量操作UI | 工具栏和操作菜单 | 1.5h |
| 分类标签UI | 标签显示和管理组件 | 1.5h |
| 搜索筛选UI | 搜索框和筛选面板 | 1.5h |
| **小计** | | **6h** |

### 5.4 第四阶段：测试与优化（预计2小时）
| 任务 | 内容 | 预估工时 |
|------|------|----------|
| 单元测试 | 核心功能测试 | 1h |
| 集成测试 | API和UI集成测试 | 0.5h |
| 性能优化 | 批量操作性能测试 | 0.5h |
| **小计** | | **2h** |

### 5.5 总计工时
- 技术准备：4h
- 后端开发：4h
- 前端开发：6h
- 测试优化：2h
- **合计**：**16h**（略超预估12h，但包含缓冲）

## 6. 技术选型

### 6.1 分类存储方案
- **方案**：在Collection表中添加`tags`字段（字符串数组）
- **理由**：简单快速，满足基本需求，后续可升级
- **实现**：使用PostgreSQL数组类型，Prisma支持`String[]`

### 6.2 批量操作UI组件
- **多选模式**：使用`CheckboxListTile`或自定义选择状态
- **工具栏**：`BottomAppBar`或`SliverPersistentHeader`
- **操作菜单**：`PopupMenuButton`或`ActionSheet`

### 6.3 搜索筛选实现
- **前端**：`SearchDelegate`或自定义搜索框
- **后端**：Prisma查询构建器，支持多条件筛选
- **性能**：数据库索引优化，分页加载

### 6.4 状态管理
- **选择状态**：使用`ChangeNotifier`或`ValueNotifier`
- **数据缓存**：沿用现有`CollectionService`缓存机制
- **UI状态**：使用`Provider`或`Bloc`（根据现有架构）

## 7. 向后兼容性

### 7.1 数据兼容
- 现有Collection数据无需迁移
- `tags`字段默认为空数组`[]`
- 所有现有API保持不变

### 7.2 API兼容
- 新增API不影响现有功能
- 现有API响应格式不变
- 可选参数不影响必填参数

### 7.3 客户端兼容
- 新增功能对老版本客户端不可见
- 功能开关可通过Feature Flag控制
- 逐步发布，A/B测试

## 8. 性能考虑

### 8.1 批量操作性能
- 使用数据库事务保证数据一致性
- 批量操作限制单次最大数量（建议100条）
- 异步处理，提供进度反馈

### 8.2 搜索性能
- 数据库索引优化：
  - `Collection(tags)`：GIN索引支持数组查询
  - `Collection(name, description)`：全文搜索索引
  - `CollectionTrail`相关字段索引
- 分页加载，避免一次返回大量数据
- 搜索结果缓存，减少重复查询

### 8.3 前端性能
- 虚拟列表，支持大量数据展示
- 图片懒加载，减少初始加载时间
- 状态缓存，避免重复渲染

## 9. 测试策略

### 9.1 单元测试
- 模型层：数据序列化/反序列化
- 服务层：批量操作逻辑
- 工具函数：标签处理、搜索过滤

### 9.2 集成测试
- API端点：请求/响应格式验证
- 数据库操作：事务和约束测试
- 端到端流程：从UI操作到数据持久化

### 9.3 性能测试
- 批量操作：100条数据添加/移除耗时
- 搜索查询：不同条件组合的响应时间
- 内存使用：大量数据加载时的内存占用

## 10. 风险与缓解

### 10.1 技术风险
| 风险 | 概率 | 影响 | 缓解措施 |
|------|------|------|----------|
| 批量操作性能问题 | 中 | 高 | 分批次处理，添加进度指示 |
| 搜索查询复杂度过高 | 低 | 中 | 查询优化，添加索引，结果缓存 |
| 前端多选状态管理复杂 | 中 | 低 | 使用成熟状态管理方案，充分测试 |

### 10.2 时间风险
- 总工时可能超过12小时
- **缓解**：优先实现核心功能，非核心功能后置
- **备选**：如时间紧张，先实现批量操作，分类功能后续迭代

### 10.3 兼容性风险
- 新功能影响现有收藏体验
- **缓解**：充分测试，灰度发布，收集用户反馈

## 11. 下一步行动

1. **等待产品需求文档**：确认具体功能需求和优先级
2. **开始后端开发**：实现数据模型扩展和批量操作API
3. **并行前端开发**：搭建多选模式和批量操作UI
4. **集成测试**：前后端联调，功能验证
5. **性能优化**：根据测试结果进行优化
6. **发布准备**：文档编写，发布计划制定

## 附录

### A. 数据库迁移脚本示例
```sql
-- 添加tags字段到collections表
ALTER TABLE collections ADD COLUMN tags TEXT[] DEFAULT '{}';

-- 创建GIN索引以加速数组查询
CREATE INDEX collections_tags_idx ON collections USING GIN (tags);

-- 添加搜索相关索引
CREATE INDEX collections_name_idx ON collections USING GIN (to_tsvector('chinese', name));
CREATE INDEX collections_description_idx ON collections USING GIN (to_tsvector('chinese', description));
```

### B. API文档更新示例
```yaml
/components/schemas/BatchAddTrailsRequest:
  type: object
  properties:
    trailIds:
      type: array
      items:
        type: string
      description: 路线ID列表
    note:
      type: string
      description: 批量添加的备注（可选）
  required:
    - trailIds

/components/schemas/CollectionListQuery:
  type: object
  properties:
    tags:
      type: string
      description: 标签筛选，逗号分隔
    search:
      type: string
      description: 关键词搜索
    sort:
      type: string
      enum: [created, updated, name, trailCount]
      default: updated
    page:
      type: integer
      default: 1
    limit:
      type: integer
      default: 20
```

### C. 前端组件结构
```
lib/
├── screens/collections/
│   ├── collections_list_screen.dart          # 增强：多选模式
│   ├── collection_detail_screen.dart         # 增强：搜索筛选
│   └── collection_tags_screen.dart           # 新增：标签管理
├── widgets/collections/
│   ├── batch_action_bar.dart                 # 新增：批量操作工具栏
│   ├── collection_selection_manager.dart     # 新增：选择状态管理
│   ├── tag_chip.dart                         # 新增：标签芯片
│   ├── search_filter_panel.dart              # 新增：搜索筛选面板
│   └── multi_select_checkbox.dart            # 新增：多选复选框
└── services/
    ├── collection_service.dart               # 扩展：批量操作API
    └── tag_service.dart                      # 新增：标签管理服务
```