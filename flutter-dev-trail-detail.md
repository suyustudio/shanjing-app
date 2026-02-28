# Flutter 路线详情页开发文档

## 开发概述

基于 `flutter-screen-trail-detail.md` 设计文档，实现了路线详情页（Trail Detail Screen）。

## 实现内容

### 1. 封面图区域
- 高度：240px
- 全宽显示，带 16px 边距
- 圆角：12px
- 使用网络图片加载（模拟数据）

### 2. 路线名称 + 难度标签
- 路线名称：24px，加粗，主文字色
- 星级评分：5 星显示，根据难度级别填充
- 难度标签：Chip 样式，颜色区分
  - 简单：品牌青 #2D968A
  - 中等：黄色 #FFC107
  - 困难：红色 #F44336

### 3. 信息行（距离/时长/海拔）
- 三列等宽布局
- 图标 + 数值 + 标签
- 背景：浅灰色圆角卡片
- 数据：
  - 距离：12.5 km
  - 时长：约 4 小时
  - 海拔爬升：150 m

### 4. 路线简介
- 标题：16px，加粗
- 正文：14px，灰色，行高 1.6
- 最多显示 4 行，超出省略

### 5. 收藏按钮
- 位置：封面图右上角
- 样式：圆形白色背景 + 阴影
- 交互：点击切换心形填充状态
- 颜色：未收藏灰色，已收藏红色

### 6. 底部开始导航按钮
- 位置：底部固定
- 样式：主色调填充按钮，圆角 8px
- 高度：48px
- 全宽显示
- 带加载状态支持

### 7. 空状态
- 当传入 trailId 为 'not_found' 时显示
- 灰色地图图标（64px）
- 提示文字："路线不存在或已下架"
- 返回按钮：主色调边框样式

## 文件位置

```
lib/screens/trail_detail_screen.dart
```

## 使用方式

```dart
// 正常显示路线详情
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TrailDetailScreen(trailId: 'trail_001'),
  ),
);

// 显示空状态
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const TrailDetailScreen(trailId: 'not_found'),
  ),
);
```

## 模拟数据

```dart
final Map<String, dynamic> _trailData = {
  'id': 'trail_001',
  'name': '西湖环湖步道',
  'coverUrl': 'https://picsum.photos/400/240',
  'difficulty': '中等',
  'difficultyLevel': 3,
  'distance': 12.5,
  'duration': 240,
  'elevation': 150,
  'description': '这是一条风景优美的徒步路线...',
  'isFavorite': false,
};
```

## 配色方案

| 用途 | 颜色值 |
|------|--------|
| 主色调 | #2D968A |
| 背景色 | #FFFFFF |
| 主文字 | #212121 |
| 次要文字 | #757575 |
| 难度-简单 | #2D968A |
| 难度-中等 | #FFC107 |
| 难度-困难 | #F44336 |
| 收藏红色 | #F44336 |

## 后续优化建议

1. 接入真实 API 替换模拟数据
2. 添加图片轮播支持（多张封面图）
3. 实现收藏状态持久化
4. 添加路线地图预览
5. 增加用户评论区域
6. 添加分享功能
