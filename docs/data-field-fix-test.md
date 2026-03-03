# 数据字段修复测试验证

## 修复内容总结

### 1. 问题修复
- ✅ **字段命名统一**: `difficulty` (中文) + `difficultyLevel` (数字)
- ✅ **数据传递完整**: discovery_screen 构建完整数据后传递
- ✅ **字段映射修复**: trail_detail_screen 安全解析所有字段

### 2. 修改文件

#### lib/screens/discovery_screen.dart
- 新增 `_getDifficultyLevel()` 方法：将 easy/moderate/hard 映射为 2/3/4 星
- 新增 `_buildCompleteTrailData()` 方法：构建包含所有必需字段的完整数据
- 修改 `onTap`：调用 `_buildCompleteTrailData(trail)` 传递完整数据

#### lib/screens/trail_detail_screen.dart
- 重构 `_trailData` getter：安全合并传递数据和默认值
- 新增 `_defaultTrailData`：提供完整默认数据
- 新增 `_parseDouble()` 和 `_parseInt()`：类型安全解析

### 3. 数据流验证

```
JSON 原始数据:
{
  "id": "trail-001",
  "name": "九溪十八涧",
  "difficulty": "easy",
  "distance": 5,
  "duration": 90,
  "elevation": {...} 或数字
}

↓ _buildCompleteTrailData() 转换

应用数据模型:
{
  "id": "trail-001",
  "name": "九溪十八涧",
  "coverUrl": "https://picsum.photos/seed/trail-001/400/240",
  "difficulty": "简单",        // 中文
  "difficultyLevel": 2,        // 数字
  "distance": 5.0,             // double
  "duration": 90,              // int
  "elevation": 313,            // int (从对象提取或直接使用)
  "description": "...",
  "isFavorite": false
}
```

### 4. 字段映射验证

| 输入 | 输出 difficulty | 输出 difficultyLevel |
|------|-----------------|---------------------|
| easy | "简单" | 2 |
| moderate | "中等" | 3 |
| hard | "困难" | 4 |
| 其他 | "简单" | 2 |

### 5. 边界情况处理

- ✅ `elevation` 为对象时：提取 `totalGain` 字段
- ✅ `elevation` 为数字时：直接使用
- ✅ `distance` 为整数时：转换为 double
- ✅ 任何字段缺失时：使用默认值
- ✅ 数据为空时：显示空状态页面

### 6. UI 验证点

详情页应正确显示：
- [ ] 路线封面图
- [ ] 路线名称
- [ ] 星级评分（根据 difficultyLevel）
- [ ] 难度标签（根据 difficulty）
- [ ] 距离、时长、海拔数值
- [ ] 路线简介

## 测试步骤

1. 启动应用，进入发现页
2. 点击任意路线卡片
3. 验证详情页显示的数据与 JSON 源数据一致
4. 验证难度显示为中文（简单/中等/困难）
5. 验证星级显示正确（2/3/4星）
6. 验证距离、时长、海拔数值正确

## 修复完成 ✅

- [x] 统一数据结构
- [x] 统一字段命名规范
- [x] 修复字段映射
- [x] 创建数据字段规范文档
