# 山径APP Build #25 设计验收报告

> **报告日期**: 2026-03-12  
> **构建版本**: Build #25  
> **APK下载**: https://github.com/suyustudio/shanjing-app/actions/runs/22991545878  
> **报告类型**: UI/UX Design Review  
> **参考对象**: 从Figma设计系统规范 (Material Design 3 + 山径品牌调性) 的眼睛审视

---

## 1. 构建信息摘要

| 项目 | 详情 |
|------|------|
| **构建编号** | #25 |
| **GitHub Run ID** | 22991545878 |
| **构建状态** | ✅ 成功 |
| **Commit** | 99ada3741c2d20c0eff2843265189270d5f6fece |
| **提交信息** | Fix: 启用手势支持，修复路线卡片点击 |
| **构建时长** | 6m 48s |
| **APK大小** | 52.4 MB |
| **构建时间** | 2026-03-12 15:41 CST |

### 版本变更要点
- 启用手势支持
- 修复路线卡片点击问题

---

## 2. 与设计稿对比结果

### 2.1 视觉一致性检查

#### ✅ 符合规范的项目

| 检查项 | 设计规范 | 实际实现 | 状态 |
|--------|----------|----------|------|
| 品牌主色 | #2D968A | Color(0xFF2D968A) | ✅ 一致 |
| 暗黑模式主色 | #4DB6AC | Color(0xFF4DB6AC) | ✅ 一致 |
| 8点间距系统 | 4/8/12/16/24px | 8/16/24/32px | ✅ 基本符合 |
| 卡片圆角 | 12px (radius-lg) | 12px (radiusLarge) | ✅ 一致 |
| 按钮圆角 | 8px (radius-md) | 8px (radius) | ✅ 一致 |
| 难度颜色-休闲 | #4CAF50 | Color(0xFF4CAF50) | ✅ 一致 |
| 难度颜色-挑战 | #F44336 | Color(0xFFF44336) | ✅ 一致 |

#### ⚠️ 与设计规范有偏差的项

| 检查项 | 设计规范 | 实际实现 | 偏差等级 |
|--------|----------|----------|----------|
| **路线名称字号** | 22px Semibold | 24px Bold | 🔴 P1 - 过大 |
| **核心数据数值字体** | DIN Alternate, 24px Bold | 系统字体, 14px Semibold | 🔴 P1 - 未使用品牌字体 |
| **Tab选中字重** | 16px Semibold | 继承Material默认 | 🟡 P2 - 可能偏细 |
| **底部按钮布局** | 收藏(固定56px) + 下载(固定120px) + 导航(flex:1) | 三个按钮均分+下载按钮 | 🔴 P1 - 布局不符 |
| **简介Tab** | 应有[简介][轨迹][评价][攻略] | 实际[轨迹][评价][攻略] | 🔴 P1 - 缺少简介Tab |
| **Tab下划线样式** | 2px solid, 宽度20px, 圆角1px | Material默认 | 🟡 P2 - 需定制 |
| **收藏按钮样式** | 56×48px, 圆角12px, 背景#F3F4F6 | IconButton默认 | 🟡 P2 - 尺寸不符 |

#### 🔴 视觉问题列表（详细）

**P1 优先级 - 必须修复**

1. **路线标题字号过大**
   - 当前: 24px Bold
   - 规范: 22px Semibold (font-weight: 600)
   - 影响: 视觉层级过重，与设计稿不一致
   - 建议: 调整为 `fontSize: 22, fontWeight: FontWeight.w600`

2. **核心数据展示未使用品牌字体**
   - 当前: 系统默认字体，14px
   - 规范: DIN Alternate, 24px Bold + 14px单位 + 12px标签
   - 影响: 数据展示缺乏品牌辨识度
   - 建议: 集成DIN字体或Google Fonts的等效字体

3. **底部按钮布局与设计稿不符**
   - 当前: 收藏IconButton + 导航Expanded + 下载IconButton
   - 规范: 收藏(56px固定) | 下载(120px固定) | 导航(剩余空间)
   - 影响: 下载按钮过小，不易点击
   - 建议: 按设计稿重新布局，下载按钮应有文字标签

4. **缺少"简介" Tab**
   - 当前: 3个Tab (轨迹/评价/攻略)
   - 规范: 4个Tab (简介/轨迹/评价/攻略)
   - 影响: 信息架构不完整
   - 建议: 添加简介Tab，作为默认选中项

5. **路线难度标签颜色映射错误**
   - 当前: 简单=success, 中等=warning, 困难=error
   - 规范: 休闲=#4CAF50, 轻度=#8BC34A, 进阶=#FF9800, 挑战=#F44336
   - 影响: 难度等级表达不完整
   - 建议: 使用设计规范的四级难度颜色

**P2 优先级 - 建议优化**

6. **Tab下划线未定制**
   - 当前: Material默认下划线
   - 规范: 2px宽, 20px长度, 圆角1px
   - 建议: 自定义TabBar indicator

7. **收藏按钮尺寸不符**
   - 当前: IconButton默认尺寸(约48px)
   - 规范: 56×48px固定尺寸
   - 建议: 使用Container包装，设置固定尺寸

8. **卡片阴影过于强烈**
   - 当前: `blurRadius: 8, opacity: 0.08`
   - 规范: `0 2px 8px rgba(0,0,0,0.06)`
   - 建议: 降低阴影透明度至0.06

---

### 2.2 动效检查

基于代码分析和构建描述"启用手势支持"的评估：

| 检查项 | 预期效果 | 当前状态 | 评估 |
|--------|----------|----------|------|
| 页面切换动画 | Material默认滑动 | ✅ 已实现 | 流畅 |
| 手势返回 | iOS/Android手势 | ✅ 本次新增 | 待验证 |
| 列表滚动 | 60fps流畅滚动 | ⚠️ 需测试 | 待验证 |
| 按钮点击反馈 | scale(0.96) + 颜色变化 | ⚠️ 部分实现 | 收藏按钮缺动画 |
| Tab切换动画 | 下划线滑动200ms ease-out | ❌ 未实现 | 使用默认 |
| 导航栏滚动渐变 | 透明→白色渐变 | ❌ 未实现 | 待开发 |
| 卡片悬浮效果 | 轻微阴影变化 | ❌ 未实现 | 待开发 |

**动效问题汇总**

1. **Tab下划线动画缺失**
   - 规范要求: 200ms ease-out滑动过渡
   - 当前: 默认Material切换
   - 优先级: P2

2. **导航栏滚动效果未实现**
   - 规范要求: 滚动时导航栏背景透明→白色渐变
   - 当前: 固定背景
   - 优先级: P2

3. **按钮点击反馈不一致**
   - 开始导航按钮: 有颜色变化
   - 收藏/下载按钮: 缺少scale动画
   - 优先级: P2

---

### 2.3 地图UI检查

地图相关UI主要依赖高德地图SDK，以下为UI层面的检查：

| 检查项 | 设计规范 | 当前状态 | 优先级 |
|--------|----------|----------|--------|
| 标记点样式 | 水滴形，36×44px，难度颜色 | ⚠️ 使用SDK默认 | P1 |
| 路线轨迹线颜色 | #2D968A, 3px宽度 | ⚠️ 需验证 | P1 |
| 底部卡片设计 | 160px宽，12px圆角 | ⚠️ 需验证 | P1 |
| 用户位置标记 | 蓝色脉冲动画 | ⚠️ 使用SDK默认 | P2 |
| 聚合标记样式 | 48px圆形，品牌主色 | ⚠️ 需验证 | P2 |

**注意**: 地图UI需要实际安装APK测试才能完整评估。

---

### 2.4 响应式适配检查

| 检查项 | 规范要求 | 当前实现 | 状态 |
|--------|----------|----------|------|
| 页面边距 | 16px固定 | ✅ EdgeInsets.all(16) | 符合 |
| 安全区适配 | SafeArea处理 | ✅ 已使用SafeArea | 符合 |
| 底部按钮安全区 | bottom: 28px | ⚠️ 需检查 | 待验证 |
| 横屏支持 | 锁定竖屏 | ✅ SystemChrome设置 | 符合设计 |
| 不同屏幕尺寸 | 弹性布局 | ⚠️ 需测试 | 待验证 |

---

## 3. 设计系统一致性总结

### 3.1 色彩系统

| Token | 规范值 | 代码值 | 状态 |
|-------|--------|--------|------|
| Primary-500 | #2D968A | 0xFF2D968A | ✅ |
| Primary-600 | #25877C | 未定义 | ⚠️ |
| Gray-900 | #111827 | 0xFF1A1A1A | ⚠️ 略浅 |
| Gray-600 | #4B5563 | 0xFF666666 | ⚠️ 略浅 |
| Success-500 | #4CAF50 | 0xFF4CAF50 | ✅ |
| Warning-500 | #FFC107 | 0xFFFFC107 | ✅ |
| Error-500 | #EF5350 | 0xFFF44336 | ⚠️ 色值不同 |

**发现**: 
- 错误色使用了Material默认的#F44336，而非设计规范的#EF5350
- Gray色阶整体偏浅，缺少Gray-500等中间色阶

### 3.2 字体系统

| 规范层级 | 规范值 | 代码常量 | 偏差 |
|----------|--------|----------|------|
| H1 | 24px Bold | fontXLarge=24 | ⚠️ 需加Bold |
| H2 | 20px Semibold | fontLarge=20 | ⚠️ 需加Semibold |
| Body Large | 16px Regular | 未定义 | ❌ 缺失 |
| Body | 14px Regular | fontBody=14 | ✅ |
| Caption | 12px Regular | fontSmall=12 | ✅ |

**缺失定义**:
- 路线名称专用样式 (22px Semibold)
- 核心数据样式 (DIN Alternate 24px Bold)
- Tab文字样式 (16px/14px Semibold/Regular)

### 3.3 间距系统

| Token | 规范 | 代码 | 状态 |
|-------|------|------|------|
| space-1 (4px) | ✅ | 未定义 | ❌ 缺失 |
| space-2 (8px) | ✅ | spacingSmall | ✅ |
| space-3 (12px) | ✅ | 未定义 | ❌ 缺失 |
| space-4 (16px) | ✅ | spacingMedium | ✅ |
| space-6 (24px) | ✅ | spacingLarge | ✅ |

**缺失**: 4px和12px间距在代码中未定义为常量

---

## 4. 修改建议（按优先级排序）

### 🔴 P1 - 必须修复（阻塞性问题）

| 序号 | 问题 | 修改方案 | 预估工时 |
|------|------|----------|----------|
| 1 | 路线名称字号错误 | `fontSize: 22, fontWeight: FontWeight.w600` | 10min |
| 2 | 添加"简介" Tab | 在TabBar中添加Tab(text: '简介')，设为默认选中 | 30min |
| 3 | 修复底部按钮布局 | 使用Row + SizedBox固定收藏/下载宽度，Expanded包裹导航按钮 | 1h |
| 4 | 难度颜色完整映射 | 添加轻度(#8BC34A)和进阶(#FF9800)颜色定义 | 20min |
| 5 | 核心数据使用品牌字体 | 引入DIN字体或Google Fonts的Oswald/Bebas Neue等替代 | 2h |

### 🟡 P2 - 建议优化（体验提升）

| 序号 | 问题 | 修改方案 | 预估工时 |
|------|------|----------|----------|
| 6 | Tab下划线定制 | 自定义TabBar indicator: BoxDecoration | 1h |
| 7 | 收藏按钮尺寸规范 | Container(width: 56, height: 48, child: IconButton) | 20min |
| 8 | 按钮点击反馈统一 | 添加scale动画：AnimatedScale或GestureDetector | 1h |
| 9 | 导航栏滚动渐变 | 使用NotificationListener监听滚动，动态改变AppBar背景 | 2h |
| 10 | 修正Error色值 | 改为Color(0xFFEF5350) | 5min |
| 11 | 补充间距常量 | 添加spacingXSmall=4, spacingMid=12 | 10min |
| 12 | 卡片阴影调整 | 改为opacity: 0.06 | 5min |

### 🟢 P3 - 长期优化（可选）

| 序号 | 问题 | 修改方案 | 预估工时 |
|------|------|----------|----------|
| 13 | 地图标记点自定义 | 使用AMap的marker自定义样式 | 4h |
| 14 | 深色模式地图样式 | 配置amap://styles/dark | 2h |
| 15 | 添加字体规范注释 | 在design_system.dart添加设计规范参考 | 30min |
| 16 | 卡片悬浮动效 | MouseRegion/手势检测 + 阴影动画 | 2h |

---

## 5. 验收结论

### 5.1 总体评分

| 维度 | 得分 | 说明 |
|------|------|------|
| 视觉一致性 | 70/100 | 色彩基本正确，布局有偏差，字体需优化 |
| 动效表现 | 60/100 | 基础动效具备，定制动效缺失 |
| 地图UI | 待测试 | 需安装APK验证 |
| 响应式适配 | 80/100 | 基础适配完成，细节待验证 |
| **综合得分** | **70/100** | 合格，但有明显优化空间 |

### 5.2 结论

**Build #25 设计验收结果: ⚠️ 有条件通过**

**通过条件**:
1. 修复P1级别问题中的1-4项（布局、Tab、字号）
2. 验证地图UI符合设计规范

**建议**:
- 高优先级修复建议在下次构建(Build #26)完成
- 动效优化可安排在后续迭代
- 建议建立设计走查流程，每次构建前对照设计规范自查

### 5.3 下一步行动

1. **Dev Agent**: 根据修改建议修复P1问题
2. **QA Agent**: 安装APK进行实际UI测试，重点验证地图标记和轨迹线
3. **Design Agent**: 准备设计走查Checklist，供后续构建使用

---

## 附录

### A. 参考文档

- 设计系统: `design-system-v1.0.md`
- 高保真设计: `design-hifi-v1.0.md`
- 代码文件: `lib/constants/design_system.dart`
- 路线详情页: `lib/screens/trail_detail_screen.dart`

### B. 设计Token对照表

```dart
// 建议添加的字体定义
static const TextStyle routeTitleStyle = TextStyle(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  color: textPrimary,
);

static const TextStyle dataValueStyle = TextStyle(
  fontFamily: 'DIN Alternate', // 或替代字体
  fontSize: 24,
  fontWeight: FontWeight.w700,
  color: textPrimary,
);

// 建议添加的间距
static const double spacingXSmall = 4;   // space-1
static const double spacingMid = 12;     // space-3

// 修正Error色
static const Color error = Color(0xFFEF5350);  // 替代0xFFF44336
```

---

*报告生成时间: 2026-03-12 16:15 CST*  
*生成者: Design Agent*  
*参考: Figma设计系统 + Material Design 3规范*
