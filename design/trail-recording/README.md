# 山径APP - 轨迹采集功能设计稿

> 设计稿目录结构说明

## 目录结构

```
design/trail-recording/
├── README.md                    # 本文件
├── exports/                     # 导出资源
│   ├── png/                     # PNG格式
│   ├── svg/                     # SVG矢量格式
│   └── pdf/                     # PDF文档
├── 01-entrance/                 # 1. 入口界面
├── 02-prepare/                  # 2. 录制前准备页
├── 03-recording/                # 3. 录制中主界面
├── 04-poi-icons/                # 4. POI类型图标
├── 05-post-recording/           # 5. 录制后编辑页
├── 06-my-records/               # 6. 我的采集列表
└── 07-empty-states/             # 7. 空状态/异常状态
```

## 设计规范

### 画布设置

- **基础尺寸**: 390 × 844px (iPhone 14)
- **色彩空间**: sRGB
- **分辨率**: 1x / 2x / 3x 导出

### 色彩系统

参考 `design-system-v1.0.md`，轨迹采集功能主要使用：

| 用途 | 色值 | 说明 |
|------|------|------|
| 录制中 | #2D968A | 品牌主色 |
| 已暂停 | #FFC107 | 警告黄色 |
| 已结束 | #EF5350 | 错误红色 |
| 深色背景 | #0F1419 | 页面背景 |
| 卡片背景 | #1A1F24 | 组件背景 |

### 字体规范

- **中文**: PingFang SC
- **数字**: DIN Alternate
- **层级**: Display / H1 / H2 / Body / Caption

## 界面清单

### 01 入口界面

| 文件 | 说明 | 优先级 |
|------|------|--------|
| `entrance-fab.png` | 首页悬浮按钮入口 | P1 |
| `permission-location.png` | 位置权限申请 | P1 |
| `permission-camera.png` | 相机权限申请 | P1 |
| `onboarding-1.png` | 新手引导-欢迎 | P1 |
| `onboarding-2.png` | 新手引导-标记POI | P1 |
| `onboarding-3.png` | 新手引导-拍照 | P1 |
| `onboarding-4.png` | 新手引导-完成 | P1 |

### 02 录制前准备页

| 文件 | 说明 | 优先级 |
|------|------|--------|
| `prepare-form.png` | 路线信息填写表单 | P1 |

### 03 录制中主界面

| 文件 | 说明 | 优先级 |
|------|------|--------|
| `recording-main.png` | 录制中主界面（深色模式） | P0 |
| `recording-paused.png` | 暂停状态界面 | P1 |
| `poi-selector.png` | POI类型选择弹窗 | P0 |
| `photo-preview.png` | 拍照预览界面 | P1 |
| `status-gps-weak.png` | GPS信号弱警告 | P1 |
| `status-battery-low.png` | 电量低警告 | P1 |
| `confirm-end.png` | 结束录制确认 | P1 |

### 04 POI类型图标

| 文件 | 说明 | 颜色 |
|------|------|------|
| `poi-start.svg` | 起点 | #4CAF50 |
| `poi-end.svg` | 终点 | #2D968A |
| `poi-junction.svg` | 路口 | #FF9800 |
| `poi-viewpoint.svg` | 观景点 | #3B9EFF |
| `poi-restroom.svg` | 卫生间 | #8B7355 |
| `poi-supply.svg` | 补给点 | #FFB800 |
| `poi-danger.svg` | 危险点 | #EF5350 |
| `poi-rest.svg` | 休息点 | #9C27B0 |

### 05 录制后编辑页

| 文件 | 说明 | 优先级 |
|------|------|--------|
| `edit-page.png` | 路线编辑主页面 | P1 |
| `poi-list-edit.png` | POI列表编辑弹窗 | P1 |
| `cover-selector.png` | 封面图选择 | P1 |
| `submit-success.png` | 提交成功页面 | P2 |

### 06 我的采集列表

| 文件 | 说明 | 优先级 |
|------|------|--------|
| `list-all.png` | 全部记录列表 | P1 |
| `list-draft.png` | 草稿箱 | P1 |
| `list-pending.png` | 审核中 | P1 |
| `list-approved.png` | 已通过 | P1 |
| `card-actions.png` | 卡片操作菜单 | P1 |

### 07 空状态/异常状态

| 文件 | 说明 | 优先级 |
|------|------|--------|
| `empty-list.png` | 无采集记录 | P1 |
| `empty-draft.png` | 无草稿 | P2 |
| `error-gps.png` | GPS信号丢失 | P1 |
| `warning-battery.png` | 电量低警告 | P1 |
| `warning-storage.png` | 存储空间不足 | P1 |
| `error-network.png` | 网络错误 | P2 |

## 交付要求

### 文件格式

- **设计源文件**: Figma / Sketch
- **标注文件**: 像素标注 + 间距标注
- **切图资源**: PNG (1x/2x/3x) + SVG
- **文档**: 本README + 设计说明文档

### 导出规范

```
exports/
├── png/
│   ├── 1x/          # 375pt 基准
│   ├── 2x/          # @2x 缩放
│   └── 3x/          # @3x 缩放
├── svg/             # 矢量图标
└── pdf/             # 完整设计稿
```

### 命名规范

- 使用小写字母 + 连字符
- 结构: `模块-界面-状态.png`
- 示例: `recording-main-paused.png`

## 设计原则

1. **单手操作**: 关键按钮位于底部 1/3 区域
2. **户外可见**: 深色模式优先，高对比度
3. **省电设计**: 减少动画，降低亮度
4. **防误触**: 关键操作二次确认
5. **快速标记**: POI标记不超过3秒

## 参考文档

- `../TRAIL-RECORDING-DESIGN.md` - 设计说明
- `../TRAIL-RECORDING-UI.md` - 界面规格
- `../design-system-v1.0.md` - 设计系统
- `../record-vs-follow.md` - 录制模式设计

---

> 设计师: 山径设计团队  
> 更新日期: 2026-03-20  
> 版本: v1.0
