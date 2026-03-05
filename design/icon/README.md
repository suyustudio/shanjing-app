# 山径 APP 图标设计交付文档

## 📦 交付清单

### 源文件 (SVG)
| 文件 | 说明 |
|------|------|
| `icon-main.svg` | 主图标源文件，1024×1024 |
| `icon-ios.svg` | iOS 专用版本，带光泽效果 |
| `icon-adaptive-fg.svg` | Android 自适应图标前景 |
| `icon-adaptive-bg.svg` | Android 自适应图标背景 |

### PNG 导出文件

#### iOS 图标 (`exports/ios/`)
- App Store: `AppStore-1024x1024.png`
- iPhone: 60pt@2x, 60pt@3x, 40pt@2x, 40pt@3x, 29pt@2x, 29pt@3x
- iPad: 76pt@2x, 83.5pt@2x

#### Android 图标 (`exports/android/`)
- 自适应图标前景/背景: mipmap-mdpi 到 mipmap-xxxhdpi
- 传统图标: 48dp 到 192dp

#### Play Store
- `play-store/play-store-icon.png` (512×512)

#### 预览图 (`exports/`)
- `preview-main-1024.png` - 主图标 1024px
- `preview-main-512.png` - 主图标 512px
- `preview-ios-180.png` - iOS 图标 180px
- `preview-adaptive-fg.png` - Android 前景
- `preview-adaptive-bg.png` - Android 背景

---

## 🎨 设计说明

### 核心概念
**"手绘山径"** — 一条蜿蜒向上的手绘风格路径作为视觉主体，穿越柔和的山峦轮廓，象征着户外徒步探索的旅程。设计灵感来源于户外手绘地图的笔触，传递温暖、自然、有机的感觉。

### 设计演变

| 版本 | 特点 | 问题 |
|------|------|------|
| **旧版** | 三座几何山峰 + 金色路径 | 太复杂，小尺寸不清晰，几何感过强 |
| **新版** | 手绘路径为主体 + 柔和山为背景 | 简洁温暖，层次分明，小尺寸清晰 |

### 视觉层次

```
第一层：手绘金色路径（主体）
  ↓
第二层：山顶小旗帜（终点标记）
  ↓
第三层：柔和远山轮廓（背景衬托）
  ↓
第四层：温暖日出天空（底色）
```

### 色彩系统

**主色调**
- 阳光金 `#F4D03F` / `#F39C12` - 主品牌色，象征日出、希望
- 大地棕 `#D4A84B` - 路径主色，温暖自然
- 暖米色 `#F5E6D3` / `#FFE4B5` - 天空背景

**辅助色**
- 远山灰 `#D4C4B0` / `#A89880` - 柔和的山峦轮廓
- 森林绿 `#27AE60` - 起点标记
- 旗帜红 `#E74C3C` - 山顶终点

**与飞书的区别**

| 维度 | 飞书 | 山径 |
|------|------|------|
| **主色** | 蓝绿 `#3370FF` | 金橙 `#F39C12` |
| **风格** | 圆润气泡/科技感 | 手绘自然/有机感 |
| **形状** | 几何圆润 | 手绘笔触 |
| **渐变** | 蓝绿渐变 | 日出金到暖米 |
| **符号** | 对话气泡 | 蜿蜒路径+山峰 |
| **调性** | 科技/办公 | 户外/探索/温暖 |

---

## 📐 技术规格

### 安全区域
- 主图标：核心图形在中心 66% 区域
- 自适应图标：关键元素在中心 66%，外圈 18% 可能被裁切
- 最小尺寸：24×24px 仍需清晰可辨

### 圆角规格
- iOS: 180px 圆角（1024px 画布）
- Android: 自适应图标由系统裁切

### 手绘效果实现
- 使用 SVG 滤镜 `feTurbulence` + `feDisplacementMap` 模拟笔触纹理
- 路径采用贝塞尔曲线，模拟自然手绘线条
- 多层叠加：底色 + 主体色 + 高光，增加立体感

---

## 🚀 使用指南

### iOS 集成
1. 将 `exports/ios/` 中的图标拖入 Xcode Assets
2. 确保所有尺寸都已包含
3. App Store 图标单独上传

### Android 集成
1. 将 `mipmap-*` 文件夹复制到 `res/`
2. 在 `AndroidManifest.xml` 中引用自适应图标
```xml
<application
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher_round"
    ... />
```

### 导出脚本

使用 `export-icons.sh` 批量导出所有尺寸：

```bash
cd design/icon
./export-icons.sh
```

需要安装：librsvg2-bin (`apt-get install librsvg2-bin`)

---

## 📝 设计原则

1. **区别于飞书**
   - 避免蓝绿色调
   - 避免圆润气泡形状
   - 使用大地色系
   - 手绘有机风格 vs 几何科技风格

2. **户外调性**
   - 手绘地图笔触感
   - 向上的动势
   - 自然温暖色彩

3. **简洁识别**
   - 小尺寸下依然清晰
   - 路径作为主体元素
   - 无需文字即可传达品牌

---

## 📄 文件结构

```
design/icon/
├── README.md              # 本文件
├── export-icons.sh        # 导出脚本
├── icon-main.svg          # 主图标
├── icon-ios.svg           # iOS 版本
├── icon-adaptive-fg.svg   # Android 前景
├── icon-adaptive-bg.svg   # Android 背景
└── exports/               # 导出文件
    ├── ios/               # iOS 图标
    ├── android/           # Android 图标
    ├── play-store/        # Play Store
    └── preview-*.png      # 预览图
```

---

## ✨ 设计亮点

1. **独特的品牌识别** - 与飞书形成鲜明对比，一眼可辨
2. **户外精神传达** - 蜿蜒路径+山顶旗帜，传达探索精神
3. **手绘温度感** - 有机笔触，区别于冰冷的科技图标
4. **多场景适配** - 从 App Store 到通知栏都清晰
5. **层次分明** - 路径、旗帜、山峦、天空四层递进
6. **可扩展性** - SVG 源文件支持任意尺寸

---

*设计完成日期: 2026-03-05*
*设计风格: 手绘自然/有机*
*设计工具: SVG*
