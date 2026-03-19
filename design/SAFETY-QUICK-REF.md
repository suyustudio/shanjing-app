# 安全中心设计 - 快速参考卡

## 🎯 核心设计决策

### 颜色策略
- **主色调**：绿色系（户外、安全、积极）
- **SOS专用**：橙红渐变，仅在触发时使用
- **减少焦虑**：避免大面积红色，用绿色表示"安全保障"

### 信息架构
1. 安全状态卡（顶部 - 一目了然）
2. Lifeline位置分享（中部 - 主要功能）
3. SOS紧急求助（下部 - 最后保障）
4. 安全提示（底部 - 教育信息）

### 防误触设计
- **第一层**：SOS折叠，不直接可见
- **第二层**：长按3秒（非常规点击）
- **第三层**：倒计时确认（可松开取消）
- **第四层**：弹窗确认（最终确认）

---

## 📐 关键尺寸

| 元素 | 尺寸 | 说明 |
|------|------|------|
| SOS按钮 | 120×120px | 圆形，小屏100px |
| 倒计时环 | 140px | 外圈进度 |
| 主按钮高度 | 52px | 全宽按钮 |
| 卡片内边距 | 20px | 标准间距 |
| 卡片圆角 | 12px | 统一风格 |
| 倒计时数字 | 48pt | Bold |

---

## 🎨 颜色代码

### SOS专用
```dart
SOS渐变：#FF5722 → #D32F2F
SOS阴影：#F44336 @ 40%
```

### 状态色
```dart
正常：#4CAF50
活跃：#2D968A
预警：#FF9800
紧急：#D32F2F
```

---

## ⚡ 交互要点

### SOS倒计时
```
长按开始 → 震动反馈 → 每秒滴答 → 松开取消 → 完成确认
   ↓
进度环动画（外圈）
数字倒计时（中心）
脉冲扩散效果（背景）
```

### Lifeline状态流转
```
未设置 → 添加联系人 → 已就绪 → 开始分享 → 分享中 → 结束/超时
            ↓                                              ↓
       从通讯录选择                              超时提醒 → 延长时间/SOS
```

---

## 🌙 暗黑模式要点

| 元素 | 调整 |
|------|------|
| 背景 | `#FFFFFF` → `#121212` |
| 卡片 | `#F5F5F5` → `#1E1E1E` |
| 主色 | 提高亮度 `#2D968A` → `#4DB6AC` |
| SOS | 保持高饱和，确保可见 |
| 阴影 | 加深，使用黑色透明度 |

---

## ♿ 无障碍清单

- [ ] 所有按钮有 `Semantics` 标签
- [ ] 倒计时使用 `liveRegion` 播报
- [ ] 触觉反馈：轻/中/重三级
- [ ] 对比度 ≥ 4.5:1 (紧急状态 ≥ 7:1)
- [ ] 支持系统字体缩放
- [ ] 最小点击区域 44×44pt

---

## 📱 响应式断点

| 设备 | 宽度 | 调整 |
|------|------|------|
| 小屏 | <375pt | 紧凑间距，缩小按钮 |
| 标准 | 375-428pt | 默认布局 |
| 大屏 | >428pt | 增加留白，居中显示 |
| 平板 | >768pt | 双栏布局 |

---

## 🏔️ 户外场景优化

| 场景 | 设计对策 |
|------|----------|
| 阳光直射 | 高对比度模式 |
| 手套操作 | 大点击区域 |
| 湿手/雨滴 | 增加按钮间距 |
| 低电量 | 简化动画 |
| 无信号 | 离线队列，有网重试 |

---

## 🔧 实现优先级

### P0 - 核心功能
1. SafetyStatusCard - 状态卡组件
2. SOSButton - SOS按钮（含长按逻辑）
3. SOSCountdownOverlay - 倒计时覆盖层
4. LifelineCard - Lifeline基础版
5. SafetyCenterScreen - 主页面重构

### P1 - 体验增强
1. 紧急联系人管理
2. 出发前设置流程
3. 超时提醒界面
4. 触觉反馈集成

### P2 - 完善优化
1. 暗黑模式完整适配
2. 平板双栏布局
3. 语音播报支持
4. 离线模式处理

---

## 📝 代码片段

### SOS按钮震动反馈
```dart
// 每秒震动
HapticFeedback.selectionClick();

// 触发成功
HapticFeedback.heavyImpact();
Future.delayed(Duration(milliseconds: 100), () {
  HapticFeedback.heavyImpact();
});
```

### 倒计时语义播报
```dart
Semantics(
  label: 'SOS倒计时',
  value: '剩余$_remaining秒，松开取消',
  liveRegion: true,
  child: CountdownDisplay(),
)
```

### 状态颜色获取
```dart
color switch (status) {
  SafetyStatus.normal => SafetyColors.statusSafe,
  SafetyStatus.sharing => SafetyColors.statusActive,
  SafetyStatus.warning => SafetyColors.statusWarning,
  SafetyStatus.emergency => SafetyColors.statusEmergency,
}
```

---

## 🎭 动画时长

| 动画 | 时长 | 曲线 |
|------|------|------|
| 卡片展开 | 250ms | fastOutSlowIn |
| 按钮按压 | 100ms | easeOut |
| 倒计时脉冲 | 1000ms | easeInOut (循环) |
| 页面切换 | 300ms | easeInOut |
| 成功动画 | 500ms | elasticOut |

---

**打印此卡片，贴在显示器旁边！**

---

## 📚 相关文档

- `SAFETY-CENTER-DESIGN-v1.0.md` - 完整设计文档
- `SAFETY-COMPONENTS-OUTLINE.md` - 组件实现大纲
- `SAFETY-UI-VISUAL-REF.md` - 视觉参考图
