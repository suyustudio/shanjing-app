# 数据字段统一文档

## 概述
本文档定义了徒步路线应用中数据字段的统一规范，确保各模块间数据传递的一致性。

## 核心字段规范

### 路线数据模型 (Trail Model)

| 字段名 | 类型 | 必填 | 说明 | 示例值 |
|--------|------|------|------|--------|
| `id` | String | 是 | 路线唯一标识 | "trail-001" |
| `name` | String | 是 | 路线名称 | "九溪十八涧" |
| `coverUrl` | String | 是 | 封面图片URL | "https://picsum.photos/seed/trail-001/400/240" |
| `difficulty` | String | 是 | 难度文本（中文） | "简单"/"中等"/"困难" |
| `difficultyLevel` | int | 是 | 难度等级（1-5星） | 2, 3, 4 |
| `distance` | double | 是 | 路线距离（公里） | 5.0 |
| `duration` | int | 是 | 预计时长（分钟） | 90 |
| `elevation` | int | 是 | 海拔爬升（米） | 150 |
| `description` | String | 是 | 路线简介 | "九溪十八涧位于杭州西湖群山之中..." |
| `location` | String | 否 | 地理位置 | "杭州西湖群山" |
| `isFavorite` | bool | 是 | 是否收藏 | false |

## 字段映射关系

### JSON 数据源 → 应用内模型

| JSON 字段 | 应用字段 | 转换逻辑 |
|-----------|----------|----------|
| `difficulty` ("easy"/"moderate"/"hard") | `difficulty` (中文) | easy→"简单", moderate→"中等", hard→"困难" |
| `difficulty` ("easy"/"moderate"/"hard") | `difficultyLevel` (int) | easy→2, moderate→3, hard→4 |
| `elevation` (对象/数字) | `elevation` (int) | 如果是对象取 `totalGain`，否则直接转 int |
| `distance` (数字) | `distance` (double) | 转换为 double |
| `duration` (数字) | `duration` (int) | 转换为 int |

## 难度映射表

| 原始值 | 中文显示 | 星级等级 | 颜色 |
|--------|----------|----------|------|
| easy | 简单 | 2星 | #2D968A (绿色) |
| moderate | 中等 | 3星 | #FFC107 (黄色) |
| hard | 困难 | 4星 | #F44336 (红色) |

## 文件职责

### discovery_screen.dart
- 从 JSON 加载原始数据
- 调用 `_buildCompleteTrailData()` 构建完整数据
- 确保所有必需字段已填充
- 将完整数据传递给 TrailDetailScreen

### trail_detail_screen.dart
- 接收完整的路线数据
- 使用 `_trailData` getter 安全访问字段
- 提供默认值处理机制
- 支持类型安全的数据解析

## 数据流

```
trails-all.json (原始数据)
    ↓
discovery_screen.dart (数据转换/补全)
    ↓
_buildCompleteTrailData() (统一字段)
    ↓
TrailDetailScreen (完整数据)
    ↓
_trailData getter (安全访问)
    ↓
UI 渲染
```

## 注意事项

1. **字段命名统一**: 统一使用 camelCase 命名
2. **类型安全**: 所有数字字段在解析时进行类型转换
3. **默认值**: 详情页提供完整的默认数据，防止空值崩溃
4. **扩展性**: 保留原始数据中的额外字段（features, highlights 等）

## 更新记录

| 日期 | 版本 | 说明 |
|------|------|------|
| 2026-03-03 | v1.0 | 初始版本，统一 difficulty/difficultyLevel 字段 |
