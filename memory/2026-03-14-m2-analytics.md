# M2 埋点实施工作总结

**日期**: 2026-03-14  
**任务**: 山径 APP M2 核心目标 - 埋点实施 + 数据追踪完善  
**负责人**: Product Agent

---

## 完成内容

### 1. 埋点 SDK 选型
- **推荐方案**: 友盟+ U-App
- **选型理由**: 
  - 基础功能完全免费，无事件数量限制
  - 数据境内存储，符合国内法规
  - Flutter 官方插件支持
  - 与微信登录等国内生态集成好

### 2. SDK 接入
- ✅ `pubspec.yaml` 添加 `umeng_analytics_plugin` 依赖
- ✅ 创建 `AnalyticsService` 统一封装（支持未来切换其他 SDK）
- ✅ 创建 `AnalyticsMixin` 便捷混入页面
- ✅ `main.dart` 初始化配置（DEBUG 模式关闭、发布模式开启）
- ✅ 用户身份关联接口 `setUserId()` / `clearUserId()`

### 3. 埋点事件实施

#### 页面浏览（6 个页面）
- discovery（发现页）
- trail_detail（路线详情页）
- map（地图页）
- navigation（导航页）
- profile（我的页）
- offline_map（离线地图页）

#### 路线交互（5 个事件）
- trail_view（路线浏览）
- trail_favorite（收藏/取消收藏）
- trail_download（下载路线）
- trail_navigate_start（开始导航）
- trail_navigate_complete（导航完成）

#### 地图交互（3 个事件）
- map_zoom（地图缩放）
- offline_map_download（离线地图下载）
- offline_map_delete（离线地图删除）

#### 导航事件（5 个事件）
- navigation_start（导航开始）
- navigation_pause（导航暂停/退出）
- navigation_resume（恢复导航）
- navigation_off_track（偏航）
- navigation_complete（导航完成）

#### 用户行为（5 个事件）
- app_launch（应用启动）
- app_background（进入后台）
- app_foreground（回到前台）
- search（搜索）
- filter_use（筛选使用）

**总计**: 25+ 个埋点事件

### 4. 文档输出
- `docs/analytics-sdk-selection.md` - SDK 选型报告
- `docs/analytics-implementation-checklist.md` - 实施检查清单
- `CHANGELOG.md` - 更新日志

---

## 待办事项

1. **配置友盟 AppKey**
   - 替换 `main.dart` 中的 `YOUR_UMENG_ANDROID_KEY` 和 `YOUR_UMENG_IOS_KEY`

2. **依赖登录功能**
   - login（登录成功/失败）
   - register（注册）

3. **依赖分享功能**
   - trail_share（路线分享）

4. **依赖 SOS 功能**
   - navigation_sos_trigger（SOS 触发）

5. **可选增强**
   - map_marker_click（POI 标记点击）
   - map_route_click（路线点击）

---

## 文件变更汇总

```
新增:
- lib/analytics/analytics.dart
- lib/analytics/analytics_service.dart
- lib/analytics/analytics_mixin.dart
- lib/analytics/events/page_events.dart
- lib/analytics/events/trail_events.dart
- lib/analytics/events/map_events.dart
- lib/analytics/events/navigation_events.dart
- lib/analytics/events/user_events.dart
- docs/analytics-sdk-selection.md
- docs/analytics-implementation-checklist.md

修改:
- pubspec.yaml (添加 umeng_analytics_plugin 依赖)
- lib/main.dart (初始化 AnalyticsService)
- lib/screens/discovery_screen.dart (添加埋点)
- lib/screens/trail_detail_screen.dart (添加埋点)
- lib/screens/map_screen.dart (添加埋点)
- lib/screens/navigation_screen.dart (添加埋点)
- lib/screens/offline_map_screen.dart (添加埋点)
- lib/screens/profile_screen.dart (添加埋点)
- CHANGELOG.md
```

---

## 验证建议

1. 运行应用，观察控制台是否有 `[Analytics]` 调试输出
2. 登录友盟后台 https://www.umeng.com 查看实时事件
3. 按 `docs/analytics-implementation-checklist.md` 中的验证清单逐项测试
