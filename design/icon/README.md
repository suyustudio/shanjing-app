# 山径 APP 图标设计交付文档

## 📦 交付清单

### 源文件 (SVG)
| 文件 | 说明 |
|------|------|
| `icon-main.svg` | 主图标源文件，1024×1024 |
| `icon-ios.svg` | iOS 专用版本，带光泽效果 |
| `icon-adaptive-fg.svg` | Android 自适应图标前景 |
| `icon-adaptive-bg.svg` | Android 自适应图标背景 |
| `icon-monochrome-white.svg` | 单色白版本（深色背景）|
| `icon-monochrome-dark.svg` | 单色深版本（浅色背景）|

### PNG 导出文件

#### iOS 图标 (`exports/ios/`)
- App Store: `AppStore-1024x1024.png`
- iPhone: 60pt@2x, 60pt@3x, 40pt@2x, 40pt@3x, 29pt@2x, 29pt@3x
- iPad: 76pt@2x, 83.5pt@2x

#### Android 图标 (`exports/android/`)
- 自适应图标前景/背景: mipmap-mdpi 到 mipmap-xxxhdpi
- 传统图标: 48dp 到 192dp
- 通知图标: 24dp 到 96dp

#### Play Store
- `play-store/play-store-icon.png` (512×512)

#### 预览图 (`exports/`)
- `preview-main-1024.png` - 主图标 1024px
- `preview-main-512.png` - 主图标 512px
- `preview-ios-180.png` - iOS 图标 180px
- `comparison.png` - 与飞书对比图

---

## 🎨 设计说明

### 核心概念
**"路径穿越山峰"** — 一条向上延伸的路径，穿越抽象化的山峰轮廓，象征着户外探索的精神。

### 色彩系统

**主色调**
- 阳光金 `#F39C12` - 主品牌色，象征日出、希望
- 岩石灰 `#2D3436` - 深色背景，稳重可靠
- 暖橙 `#E67E22` - 渐变过渡，温暖活力

**辅助色**
- 森林绿 `#27AE60` - 自然元素
- 天空蓝 `#3498DB` - 天气/天空
- 纯白 `#FFFFFF` - 图标主体

### 与飞书的区别

| 维度 | 飞书 | 山径 |
|------|------|------|
| **主色** | 蓝绿 `#3370FF` | 金橙 `#F39C12` |
| **形状** | 圆润气泡 | 锐利几何山峰 |
| **渐变** | 蓝绿渐变 | 日出金到岩石灰 |
| **符号** | 对话气泡 | 路径穿越山峰 |
| **调性** | 科技/办公 | 户外/探索 |

---

## 📐 技术规格

### 安全区域
- 主图标：核心图形在中心 66% 区域
- 自适应图标：关键元素在中心 66%，外圈 18% 可能被裁切
- 最小尺寸：24×24px 仍需清晰可辨

### 圆角规格
- iOS: 180px 圆角（1024px 画布）
- Android: 自适应图标由系统裁切

### 导出设置
- 格式：PNG（各尺寸）、SVG（源文件）
- 色彩空间：sRGB
- 透明度：支持（除背景层外）

---

## 🚀 使用指南

### iOS 集成
1. 将 `exports/ios/` 中的图标拖入 Xcode Assets
2. 确保所有尺寸都已包含
3. App Store 图标单独上传

### Android 集成
1. 将 `mipmap-*` 文件夹复制到 `res/`
2. 在 `AndroidManifest.xml` 中引用自适应图标
3. 通知图标使用 `ic_notification.png`

### 自适应图标配置
```xml
<application
    android:icon="@mipmap/ic_launcher"
    android:roundIcon="@mipmap/ic_launcher_round"
    ... />
```

---

## 📝 设计原则

1. **区别于飞书**
   - 避免蓝绿色调
   - 避免圆润气泡形状
   - 使用大地色系

2. **户外调性**
   - 锐利几何线条
   - 向上的动势
   - 自然色彩

3. **简洁识别**
   - 小尺寸下依然清晰
   - 单色版本保持核心识别
   - 无需文字即可传达品牌

---

## 🔧 导出脚本

使用 `export-icons.sh` 批量导出所有尺寸：

```bash
cd design/icon
./export-icons.sh
```

需要安装：ImageMagick 或 Inkscape

---

## 📄 文件结构

```
design/icon/
├── DESIGN.md              # 设计文档
├── SPECS.md               # 规格清单
├── README.md              # 本文件
├── export-icons.sh        # 导出脚本
├── icon-main.svg          # 主图标
├── icon-ios.svg           # iOS 版本
├── icon-adaptive-fg.svg   # Android 前景
├── icon-adaptive-bg.svg   # Android 背景
├── icon-monochrome-*.svg  # 单色版本
├── comparison.svg         # 对比图
└── exports/               # 导出文件
    ├── ios/               # iOS 图标
    ├── android/           # Android 图标
    ├── play-store/        # Play Store
    └── preview-*.png      # 预览图
```

---

## ✨ 设计亮点

1. **独特的品牌识别** - 与飞书形成鲜明对比
2. **户外精神传达** - 路径+山峰，一眼即懂
3. **多场景适配** - 从 App Store 到通知栏都清晰
4. **现代简约** - 符合当前设计趋势
5. **可扩展性** - SVG 源文件支持任意尺寸

---

*设计完成日期: 2026-03-04*
*设计工具: SVG / Figma-ready*
