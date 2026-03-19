# 路线起始点标记设计需求

## 需求确认（来自用户）

### 1. 起点标记
- **设计**: 绿色圆点 + "起" 字
- **输出**: Design Agent 提供 PNG 资源

### 2. 终点标记
- **设计**: 建议用旗帜图标 (🚩) 或 "终" 字
- **输出**: Design Agent 提供 PNG 资源

### 3. 环形路线
- **设计**: 起点和终点合并为一个标记
- **图标**: 建议用 🔄 环形箭头或 "起/终" 合并标识

## 技术规格

### 尺寸要求
| 分辨率 | 尺寸 | 用途 |
|--------|------|------|
| mdpi | 24x24px | 基础 |
| hdpi | 36x36px | 1.5x |
| xhdpi | 48x48px | 2x |
| xxhdpi | 72x72px | 3x |
| xxxhdpi | 96x96px | 4x |

### 格式
- PNG (透明背景)
- 命名规范:
  - `marker_start.png` - 起点标记
  - `marker_end.png` - 终点标记
  - `marker_circular.png` - 环形路线标记

### 颜色参考
- 起点绿色: `#4CAF50` (Material green)
- 终点红色: `#F44336` (Material red)
- 文字: 白色 `#FFFFFF`

## 待办
- [ ] Design Agent 提供设计稿
- [ ] 导出 5 种分辨率 PNG
- [ ] 放入 `assets/markers/` 目录
- [ ] Dev 实现代码集成
