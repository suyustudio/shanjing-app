# Bug 修复优先级 - Week 5 Day 6

**日期**: 2026-02-28  
**来源**: Week 5 Day 5 Review 报告汇总  
**状态**: 待修复

---

## P0 - 立即修复（阻塞性问题）

| # | 问题 | 来源 | 影响 | 修复方案 |
|---|------|------|------|----------|
| 1 | API Key 硬编码残留检查 | Dev Review | 安全风险 | 确认 AndroidManifest.xml 占位符生效，检查所有代码文件 |
| 2 | Android 存储权限确认 | Product Review | 离线地图无法保存 | 确认 WRITE_EXTERNAL_STORAGE 已添加 |
| 3 | 搜索防抖实现验证 | Dev Review | 频繁请求影响性能 | 确认 300ms 防抖已生效 |

---

## P1 - 今日修复（重要问题）

| # | 问题 | 来源 | 影响 | 修复方案 |
|---|------|------|------|----------|
| 4 | 页面切换动画统一 | Design Review | 体验不一致 | 所有页面使用 FadePageRoute，提取 AppRouter |
| 5 | 颜色系统统一 | Design Review | 视觉不一致 | 替换所有硬编码颜色为 DesignSystem 常量 |
| 6 | iOS 权限文案优化 | Product Review | 审核风险 | 按 Apple 指南优化描述文案 |
| 7 | _AnimatedRouteCard 抽离 | Dev Review | 代码可维护性 | 抽离为独立组件，便于复用 |

---

## P2 - 本周修复（优化项）

| # | 问题 | 来源 | 影响 | 修复方案 |
|---|------|------|------|----------|
| 8 | 骨架屏实现 | Design Review | 加载体验 | 使用 shimmer 包实现 RouteCardSkeleton |
| 9 | 空状态优化 | Design Review | 用户引导 | 添加清除筛选按钮和操作指引 |
| 10 | 错误状态场景化 | Design Review | 错误感知 | 区分网络错误/服务器错误图标和文案 |
| 11 | 图片 CDN 替换 | Dev Review | 生产环境 | 替换 picsum.photos 为正式 CDN |
| 12 | 间距常量优化 | Dev Review | 代码规范 | 添加 spacingMedium = 12 等常量 |

---

## 修复方案详情

### 1. API Key 安全验证
```bash
# 检查命令
grep -r "e17f8ae117d84e2d2d394a2124866603" --include="*.dart" --include="*.xml" --include="*.gradle"
grep -r "AMAP_KEY" --include="*.dart" | grep -v "dotenv"
```

### 2. 页面切换动画统一
```dart
// lib/utils/app_router.dart
class AppRouter {
  static Route<T> fade<T>(Widget child) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => child,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOut,
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 250),
    );
  }
}
```

### 3. 颜色统一检查清单
- [ ] NavigationScreen: Colors.green → DesignSystem.primary
- [ ] MapScreen: Colors.grey[800] → DesignSystem.textSecondary
- [ ] TrailDetailScreen: 难度颜色硬编码 → DesignSystem 常量

### 4. iOS 权限文案模板
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>山径需要获取您的位置，用于在地图上显示您的当前位置和记录路线轨迹</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>山径需要在后台获取位置，用于持续记录您的路线轨迹（仅在开始记录后）</string>
```

---

## 今日修复计划

| 时间段 | 任务 | 负责人 |
|--------|------|--------|
| 上午 | P0 问题验证 + 修复 | Dev |
| 上午 | P1 颜色统一 + 动画统一 | Dev |
| 下午 | P1 iOS 文案 + 组件抽离 | Dev + Product |
| 下午 | P2 骨架屏 + 空状态优化 | Dev + Design |
| 晚上 | 真实设备测试验证 | All |

---

## 验证标准

- [ ] 所有 P0 问题修复完成并通过验证
- [ ] P1 问题修复 80% 以上
- [ ] 真实设备测试无阻塞性 Bug
- [ ] 代码 Review 通过

---

**生成时间**: 2026-02-28  
**下次更新**: Week 5 Day 6 完成后
