# 山径APP 数据格式标准化 Review 报告

**Review 日期**: 2026-02-28  
**Review 人**: Dev Agent  
**Review 对象**: Product Agent 完成的数据格式标准化工作

---

## 1. 执行摘要

Product Agent 完成了 10 条杭州徒步路线数据的收集和初步标准化工作。本 Review 从 Schema 完整性、数据质量、技术可用性和一致性四个维度进行评估。

**总体评分**: ⚠️ **需要改进** (6/10)

**主要问题**:
1. 数据格式与 Schema 定义存在显著偏差
2. `duration` 字段单位不统一（小时 vs 分钟）
3. `difficulty` 字段枚举值不统一
4. 缺少必需的 `coordinates` 字段
5. 各条数据字段结构不一致

---

## 2. Schema 完整性 Review

### 2.1 Schema 设计评估

| 评估项 | 状态 | 说明 |
|--------|------|------|
| 字段定义清晰度 | ✅ 良好 | Schema 中字段类型、约束、示例完整 |
| 必填字段合理性 | ✅ 合理 | 8个必填字段覆盖核心信息 |
| 可选字段覆盖度 | ⚠️ 可优化 | 缺少 `location` 字段定义（实际数据中有） |
| 扩展性 | ✅ 良好 | `additionalProperties: false` 控制严格 |

### 2.2 Schema 改进建议

```json
// 建议增加以下字段定义
{
  "location": {
    "type": "string",
    "description": "路线所在地理位置"
  },
  "features": {
    "type": "array",
    "items": { "type": "string" },
    "description": "路线特色亮点"
  },
  "highlights": {
    "type": "array", 
    "items": { "type": "string" },
    "description": "途经景点/亮点"
  },
  "bestSeason": {
    "type": "array",
    "items": { "type": "string" },
    "description": "最佳游览季节"
  }
}
```

---

## 3. 数据质量 Review

### 3.1 与 Schema 符合度检查

| 检查项 | 符合度 | 问题描述 |
|--------|--------|----------|
| `id` 字段 | ✅ 100% | 所有数据都有有效 ID |
| `name` 字段 | ✅ 100% | 名称完整 |
| `distance` 字段 | ✅ 100% | 数值正确 |
| `duration` 字段 | ❌ 0% | **单位错误**: Schema 要求分钟，数据使用小时 |
| `difficulty` 字段 | ❌ 30% | **枚举值不统一**: 使用中文描述而非 `easy/moderate/hard` |
| `description` 字段 | ✅ 100% | 描述完整 |
| `coordinates` 字段 | ❌ 0% | **全部缺失** - 这是核心字段！ |
| `source` 字段 | ✅ 100% | 来源标识正确 |

### 3.2 各条数据详细检查

| 文件 | ID | duration 问题 | difficulty 问题 | coordinates | 其他问题 |
|------|-----|---------------|-----------------|-------------|----------|
| trail-data-001.json | trail-001 | 2(小时)→应120 | "入门级"→应"easy" | ❌ 缺失 | - |
| trail-data-002.json | trail-002 | 1.5(小时)→应90 | "入门级"→应"easy" | ❌ 缺失 | - |
| trail-data-003.json | trail-003 | 2(小时)→应120 | "入门级"→应"easy" | ❌ 缺失 | - |
| trail-data-004.json | trail-004 | 2.5(小时)→应150 | "中等偏上"→应"moderate" | ❌ 缺失 | - |
| trail-data-005.json | trail-005 | 1.5(小时)→应90 | "轻量级"→应"easy" | ❌ 缺失 | - |
| trail-data-006.json | trail-006 | 2(小时)→应120 | "入门级"→应"easy" | ❌ 缺失 | - |
| trail-data-007.json | trail-007 | 2(小时)→应120 | "入门级"→应"easy" | ❌ 缺失 | - |
| trail-data-008.json | trail-008 | 1.5(小时)→应90 | "入门级"→应"easy" | ❌ 缺失 | - |
| trail-data-009.json | trail-009 | 1(小时)→应60 | "简单"→应"easy" | ❌ 缺失 | - |
| trail-data-010.json | trail-010 | 1.5(小时)→应90 | ✅ "easy" 正确 | ❌ 缺失 | - |

### 3.3 数据质量评分

| 维度 | 评分 | 权重 | 加权分 |
|------|------|------|--------|
| 必填字段完整性 | 5/10 | 40% | 2.0 |
| 数据类型正确性 | 4/10 | 30% | 1.2 |
| 枚举值规范性 | 3/10 | 20% | 0.6 |
| 数据一致性 | 4/10 | 10% | 0.4 |
| **总分** | - | 100% | **4.2/10** |

---

## 4. 技术可用性 Review

### 4.1 后端 API 适用性

| 评估项 | 状态 | 说明 |
|--------|------|------|
| JSON 格式有效性 | ✅ 有效 | 所有文件都是合法 JSON |
| 反序列化兼容性 | ⚠️ 部分兼容 | `duration` 单位需要转换逻辑 |
| 数据验证 | ❌ 不通过 | 无法通过 Schema 验证 |
| API 响应格式 | ⚠️ 需调整 | 缺少 `coordinates` 无法绘制轨迹 |

### 4.2 Flutter 前端适用性

| 评估项 | 状态 | 说明 |
|--------|------|------|
| Dart 模型生成 | ⚠️ 可行 | 但需处理字段映射 |
| 地图组件支持 | ❌ 不支持 | 缺少 `coordinates` 无法显示路线 |
| 难度筛选功能 | ⚠️ 需适配 | 需要统一 difficulty 枚举值 |
| 时间显示 | ⚠️ 需转换 | 需要小时→分钟的转换逻辑 |

### 4.3 技术可用性评分

**当前状态**: ⚠️ **不可直接用于生产环境**

必须修复的问题：
1. 补充 `coordinates` 字段（核心功能依赖）
2. 统一 `duration` 单位为分钟
3. 统一 `difficulty` 为英文枚举值

---

## 5. 一致性 Review

### 5.1 字段一致性检查

| 字段 | 一致性 | 问题 |
|------|--------|------|
| `id` | ✅ 一致 | 格式统一为 `trail-XXX` |
| `name` | ✅ 一致 | 均为字符串 |
| `distance` | ✅ 一致 | 均为数值 |
| `duration` | ✅ 一致 | 均为小时单位（但与 Schema 不符） |
| `source` | ✅ 一致 | 均为"两步路公开轨迹" |
| `description` | ✅ 一致 | 均为字符串 |
| `location` | ✅ 一致 | 10条都有 |
| `difficulty` | ❌ 不一致 | 9种不同中文描述 + 1个英文 |
| `features` | ❌ 不一致 | 仅 3/5/7/10 有 |
| `notes` | ❌ 不一致 | 仅 1/3/4/5/6/7/10 有 |
| `highlights` | ❌ 不一致 | 仅 4/9/10 有 |
| `bestSeason` | ❌ 不一致 | 仅 9/10 有 |
| `elevation` | ❌ 不一致 | 仅 4 有 |
| `dataVersion` | ❌ 不一致 | 仅 5/6 有 |
| `collectionBatch` | ❌ 不一致 | 仅 8 有 |

### 5.2 字段存在性矩阵

```
字段              001 002 003 004 005 006 007 008 009 010
---------------------------------------------------------
id                ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
name              ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
distance          ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
duration          ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
source            ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
description       ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
location          ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
difficulty        ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
collectionDate    ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅  ✅
notes             ✅  ❌  ✅  ✅  ✅  ✅  ✅  ❌  ❌  ✅
features          ❌  ❌  ✅  ❌  ✅  ❌  ✅  ❌  ❌  ✅
elevation         ❌  ❌  ❌  ✅  ❌  ❌  ❌  ❌  ❌  ❌
averageSpeed      ❌  ❌  ❌  ✅  ❌  ❌  ❌  ❌  ❌  ❌
route             ❌  ❌  ❌  ✅  ❌  ❌  ❌  ❌  ✅  ❌
highlights        ❌  ❌  ❌  ✅  ❌  ❌  ❌  ❌  ✅  ✅
ticket            ❌  ❌  ❌  ✅  ❌  ❌  ❌  ❌  ❌  ❌
dataVersion       ❌  ❌  ❌  ❌  ✅  ✅  ❌  ❌  ❌  ❌
collectionBatch   ❌  ❌  ❌  ❌  ❌  ❌  ❌  ✅  ❌  ❌
surface           ❌  ❌  ❌  ❌  ❌  ❌  ❌  ❌  ✅  ❌
bestSeason        ❌  ❌  ❌  ❌  ❌  ❌  ❌  ❌  ✅  ✅
coordinates       ❌  ❌  ❌  ❌  ❌  ❌  ❌  ❌  ❌  ❌  ← Schema 必需！
```

### 5.3 一致性评分

| 维度 | 评分 |
|------|------|
| 核心字段一致性 | 8/10 |
| 扩展字段一致性 | 3/10 |
| 数据格式一致性 | 4/10 |
| **总分** | **5/10** |

---

## 6. 问题汇总与修复建议

### 6.1 🔴 严重问题（必须修复）

| 问题 | 影响 | 修复建议 |
|------|------|----------|
| 缺少 `coordinates` 字段 | 无法显示路线轨迹 | 补充 GPS 坐标数据，或标记为待补充 |
| `duration` 单位错误 | API 计算错误 | 统一转换为分钟（×60） |
| `difficulty` 枚举值错误 | 筛选功能失效 | 统一映射到 `easy/moderate/hard` |

### 6.2 🟡 中等问题（建议修复）

| 问题 | 影响 | 修复建议 |
|------|------|----------|
| 扩展字段不统一 | 前端展示不一致 | 统一字段结构，空值用 `null` 或 `[]` |
| 缺少 `elevation_gain`/`max_elevation` | 海拔信息缺失 | 补充或标记为可选 |
| 缺少 `tags` 字段 | 分类/搜索功能受限 | 添加标签数组 |
| 缺少 `images` 字段 | 无图片展示 | 添加图片 URL 数组 |

### 6.3 🟢 建议优化

| 问题 | 修复建议 |
|------|----------|
| `collectionDate` 冗余 | 可移到 metadata |
| `dataVersion` 不一致 | 统一版本号或移除 |
| `notes` 字段内容重复 | 提取公共部分到 metadata |

---

## 7. 修复后数据示例

```json
{
  "id": "trail-001",
  "name": "九溪十八涧",
  "distance": 5,
  "duration": 120,
  "difficulty": "easy",
  "description": "九溪十八涧位于杭州西湖群山之中，是一条经典的入门级徒步路线。沿途溪水潺潺，茶园环绕，风景清幽，适合周末休闲徒步。",
  "coordinates": [
    [120.1234, 30.5678],
    [120.1235, 30.5679]
  ],
  "source": "两步路公开轨迹",
  "elevation_gain": 150,
  "max_elevation": 200,
  "tags": ["入门级", "溪水", "茶园", "周末休闲"],
  "images": [],
  "location": "杭州西湖群山",
  "features": ["溪水潺潺", "茶园环绕", "风景清幽"],
  "created_at": "2026-02-28T00:00:00Z",
  "updated_at": "2026-02-28T00:00:00Z"
}
```

---

## 8. 结论与建议

### 8.1 总体评价

Product Agent 完成了基础数据采集工作，但在数据标准化方面存在以下主要问题：

1. **Schema 遵循度低**: 关键字段（coordinates、duration、difficulty）与 Schema 定义不符
2. **数据完整性不足**: 缺少绘制路线必需的 coordinates 字段
3. **一致性较差**: 扩展字段在各条数据中差异较大

### 8.2 后续行动建议

| 优先级 | 行动项 | 负责人 |
|--------|--------|--------|
| P0 | 统一 `duration` 单位为分钟 | Product Agent |
| P0 | 统一 `difficulty` 为英文枚举值 | Product Agent |
| P0 | 补充或标记 `coordinates` 字段 | Product Agent / Dev |
| P1 | 统一扩展字段结构 | Product Agent |
| P1 | 更新 Schema 增加实际使用的字段 | Dev |
| P2 | 建立数据验证脚本 | Dev |
| P2 | 编写数据转换工具 | Dev |

### 8.3 数据可用性结论

**当前状态**: ❌ **不可直接用于开发**

需要 Product Agent 完成上述 P0 级别修复后，方可进入开发流程。

---

## 9. 附录

### 9.1 Difficulty 映射表

| 当前值 | 应映射为 |
|--------|----------|
| 入门级 | easy |
| 轻量级 | easy |
| 简单 | easy |
| 中等偏上 | moderate |
| easy | easy (正确) |

### 9.2 Duration 转换公式

```javascript
// 小时 → 分钟
duration_minutes = duration_hours * 60
```

### 9.3 Review 检查清单

- [x] Schema 完整性检查
- [x] 数据质量检查
- [x] 技术可用性评估
- [x] 一致性检查
- [x] 问题汇总
- [x] 修复建议
- [x] 修复示例

---

**报告生成时间**: 2026-02-28  
**Review 完成**
