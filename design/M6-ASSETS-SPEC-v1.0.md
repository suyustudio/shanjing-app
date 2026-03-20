# M6 设计修复 - 切图资源规范

> **文档版本**: v1.0  
> **制定日期**: 2026-03-20  
> **关联文档**: M6-DESIGN-FIX-v1.0.md, M6-COMPONENT-SPEC-v1.0.md

---

## 1. 图标资源

### 1.1 点赞图标

| 文件名 | 尺寸 | 用途 | 格式 | 颜色 |
|--------|------|------|------|------|
| ic_like_normal.svg | 24x24 | 未点赞状态 | SVG | #9CA3AF |
| ic_like_selected.svg | 24x24 | 已点赞状态 | SVG | #2D968A |
| ic_like_normal_20.svg | 20x20 | 小尺寸使用 | SVG | #9CA3AF |
| ic_like_selected_20.svg | 20x20 | 小尺寸使用 | SVG | #2D968A |

**设计要求:**
- 使用 Material Design 风格拇指向上图标
- 线稿版本 (outlined) 用于未选中
- 填充版本 (filled) 用于已选中
- 描边宽度: 2px

### 1.2 回复图标

| 文件名 | 尺寸 | 用途 | 格式 | 颜色 |
|--------|------|------|------|------|
| ic_reply.svg | 24x24 | 回复按钮 | SVG | #6B7280 |
| ic_reply_filled.svg | 24x24 | 回复状态 | SVG | #2D968A |

**设计要求:**
- 使用弯曲箭头图标
- 表示回复/返回的含义
- 描边宽度: 1.5px

### 1.3 展开/收起图标

| 文件名 | 尺寸 | 用途 | 格式 | 颜色 |
|--------|------|------|------|------|
| ic_expand_more.svg | 16x16 | 展开更多 | SVG | #2D968A |
| ic_expand_less.svg | 16x16 | 收起内容 | SVG | #2D968A |
| ic_chevron_down.svg | 12x12 | 下拉箭头 | SVG | #6B7280 |
| ic_chevron_up.svg | 12x12 | 上拉箭头 | SVG | #6B7280 |

### 1.4 图片相关图标

| 文件名 | 尺寸 | 用途 | 格式 | 颜色 |
|--------|------|------|------|------|
| ic_image_placeholder.svg | 48x48 | 图片占位 | SVG | #D1D5DB |
| ic_fullscreen.svg | 24x24 | 全屏查看 | SVG | #FFFFFF |
| ic_fullscreen_exit.svg | 24x24 | 退出全屏 | SVG | #FFFFFF |
| ic_zoom_in.svg | 24x24 | 放大 | SVG | #FFFFFF |
| ic_zoom_out.svg | 24x24 | 缩小 | SVG | #FFFFFF |

### 1.5 空状态插画

| 文件名 | 尺寸 | 用途 | 格式 | 备注 |
|--------|------|------|------|------|
| empty_comments.svg | 200x200 | 评论空状态 | SVG | 对话气泡样式 |
| empty_photos.svg | 200x200 | 照片空状态 | SVG | 相机/图片样式 |
| empty_favorites.svg | 200x200 | 收藏空状态 | SVG | 书签/星星样式 |
| empty_network.svg | 200x200 | 网络错误 | SVG | WiFi断开样式 |
| empty_search.svg | 200x200 | 搜索无结果 | SVG | 放大镜样式 |

**插画风格要求:**
- 线稿风格，描边宽度: 2px
- 主色调: #E5E7EB (浅灰)
- 无填充或极浅填充
- 简洁几何形状

---

## 2. 空状态插画设计稿

### 2.1 评论空状态 (empty_comments)

```
        ┌─────────────────┐
       /                   \
      /    ╭───────────╮    \
     │     │   ◕   ◕   │     │
     │     │     ▽     │     │
     │     ╰───────────╯     │
      \      ╱         ╱     /
       \   ╱           ╱   /
        └─────────────────┘
        
        对话气泡样式
        内含简化表情
```

**规格:**
- 画布: 200x200px
- 气泡: 140x100px, 圆角 20px
- 表情: 60x40px, 居中
- 描边: #E5E7EB, 2px
- 无填充

### 2.2 照片空状态 (empty_photos)

```
        ┌─────────────┐
        │  ┌───────┐  │
        │  │ ○   ○ │  │
        │  │   ◇   │  │
        │  │       │  │
        │  └───────┘  │
        └─────────────┘
              ╱╲
            ╱    ╲
          ╱   🏔️   ╲
        ╱_____________╲
        
        相机 + 风景简笔画
```

**规格:**
- 画布: 200x200px
- 相机: 120x90px, 圆角 8px
- 镜头: 40px 圆形
- 描边: #E5E7EB, 2px
- 底部三角形: 山峰简笔画

### 2.3 网络错误 (empty_network)

```
             📡
            /│\
           / │ \
          ╱  │  ╲
        ─────┴─────
        
        WiFi 信号断开
        中间带 X 或断线
```

**规格:**
- 画布: 200x200px
- WiFi 图标: 100x80px
- 三道弧线 + 底部横线
- 断线标记: 红色斜杠或 X
- 描边: #E5E7EB, 2px

---

## 3. 动画资源

### 3.1 点赞动画 JSON (Lottie)

| 文件名 | 用途 | 尺寸 | 说明 |
|--------|------|------|------|
| anim_like.json | 点赞成功动画 | 100x100 | 粒子扩散效果 |
| anim_like_bounce.json | 按钮弹跳 | 44x44 | scale 动画 |

**动画参数:**
```json
{
  "animation": {
    "duration": 400,
    "particles": {
      "count": 12,
      "colors": ["#2D968A", "#FFB800"],
      "size": { "min": 4, "max": 8 },
      "spread": 30
    }
  }
}
```

### 3.2 加载动画

| 文件名 | 用途 | 尺寸 | 说明 |
|--------|------|------|------|
| anim_loading.json | 下拉刷新 | 40x40 | 旋转指示器 |
| anim_skeleton.json | 骨架屏流光 | - | shimmer 效果 |

---

## 4. 切图导出规范

### 4.1 SVG 导出设置

```
格式: SVG
画布: 根据图标尺寸
保留编辑能力: 否
CSS属性: 演示文稿属性
小数位数: 2
编码: UTF-8

优化选项:
- 清理 ID: 是
- 合并路径: 是
- 移除注释: 是
- 移除元数据: 是
```

### 4.2 PNG 导出设置 (备用)

```
格式: PNG
分辨率: 
  - 1x: 标准尺寸
  - 2x: 2倍尺寸
  - 3x: 3倍尺寸
色彩空间: sRGB
透明背景: 是

文件名示例:
- ic_like_normal.png (1x)
- ic_like_normal@2x.png (2x)
- ic_like_normal@3x.png (3x)
```

### 4.3 文件命名规范

```
[类型]_[名称]_[状态]_[尺寸].[格式]

类型:
- ic: 图标 (icon)
- img: 图片 (image)
- bg: 背景 (background)
- anim: 动画 (animation)
- empty: 空状态 (empty state)

状态:
- normal: 默认
- selected: 选中
- disabled: 禁用
- pressed: 按下

示例:
ic_like_normal.svg
ic_like_selected.svg
empty_comments.svg
anim_like.json
```

---

## 5. 资源目录结构

```
assets/
├── icons/
│   ├── ic_like_normal.svg
│   ├── ic_like_selected.svg
│   ├── ic_reply.svg
│   ├── ic_expand_more.svg
│   ├── ic_expand_less.svg
│   ├── ic_image_placeholder.svg
│   ├── ic_fullscreen.svg
│   └── ic_fullscreen_exit.svg
├── illustrations/
│   ├── empty_comments.svg
│   ├── empty_photos.svg
│   ├── empty_favorites.svg
│   ├── empty_network.svg
│   └── empty_search.svg
└── animations/
    ├── anim_like.json
    └── anim_loading.json
```

---

## 6. Flutter 资源配置

### 6.1 pubspec.yaml

```yaml
flutter:
  assets:
    # 图标
    - assets/icons/ic_like_normal.svg
    - assets/icons/ic_like_selected.svg
    - assets/icons/ic_reply.svg
    - assets/icons/ic_expand_more.svg
    - assets/icons/ic_expand_less.svg
    - assets/icons/ic_image_placeholder.svg
    - assets/icons/ic_fullscreen.svg
    - assets/icons/ic_fullscreen_exit.svg
    
    # 插画
    - assets/illustrations/empty_comments.svg
    - assets/illustrations/empty_photos.svg
    - assets/illustrations/empty_favorites.svg
    - assets/illustrations/empty_network.svg
    - assets/illustrations/empty_search.svg
    
    # 动画
    - assets/animations/anim_like.json
    - assets/animations/anim_loading.json
```

### 6.2 使用示例

```dart
// SVG 图标
import 'package:flutter_svg/flutter_svg.dart';

SvgPicture.asset(
  'assets/icons/ic_like_normal.svg',
  width: 24,
  height: 24,
  color: const Color(0xFF9CA3AF),
);

// Lottie 动画
import 'package:lottie/lottie.dart';

Lottie.asset(
  'assets/animations/anim_like.json',
  width: 100,
  height: 100,
  repeat: false,
);
```

---

## 7. 替代方案 (不使用自定义切图)

如果暂时无法提供切图，可使用 Flutter 自带图标替代:

| 功能 | 建议替代图标 | 代码 |
|------|-------------|------|
| 点赞 | Icons.thumb_up / Icons.thumb_up_outlined | `Icon(Icons.thumb_up)` |
| 回复 | Icons.reply | `Icon(Icons.reply)` |
| 展开 | Icons.expand_more | `Icon(Icons.expand_more)` |
| 图片 | Icons.image | `Icon(Icons.image)` |
| 全屏 | Icons.fullscreen | `Icon(Icons.fullscreen)` |
| 空评论 | Icons.chat_bubble_outline | `Icon(Icons.chat_bubble_outline, size: 64)` |
| 空照片 | Icons.photo_library_outlined | `Icon(Icons.photo_library_outlined, size: 64)` |
| 无网络 | Icons.wifi_off | `Icon(Icons.wifi_off, size: 64)` |

**建议:** 优先使用 Flutter Material Icons，减少资源包体积。

---

## 8. 资源清单汇总

| 序号 | 文件名 | 类型 | 优先级 | 状态 |
|------|--------|------|--------|------|
| 1 | ic_like_normal.svg | 图标 | P0 | 待切 |
| 2 | ic_like_selected.svg | 图标 | P0 | 待切 |
| 3 | ic_reply.svg | 图标 | P0 | 待切 |
| 4 | ic_expand_more.svg | 图标 | P1 | 待切 |
| 5 | ic_expand_less.svg | 图标 | P1 | 待切 |
| 6 | ic_image_placeholder.svg | 图标 | P1 | 待切 |
| 7 | ic_fullscreen.svg | 图标 | P1 | 待切 |
| 8 | empty_comments.svg | 插画 | P1 | 待切 |
| 9 | empty_photos.svg | 插画 | P1 | 待切 |
| 10 | empty_network.svg | 插画 | P1 | 待切 |
| 11 | anim_like.json | 动画 | P2 | 待制作 |

---

**文档完成时间**: 2026-03-20  
**预计切图工时**: 4-6h  
**交付格式**: SVG (优先) + PNG (备用)
