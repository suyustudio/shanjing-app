# 更新日志

所有重要变更都记录在此文件。

格式基于 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.0.0/)。

## [未发布]

### 新增
- 路线发现页面
- 路线详情展示
- 离线地图导航
- 实时轨迹跟随
- 偏航检测与提醒
- 安全分享功能
- 个人中心页面

### 数据埋点 (M2)
- ✅ 友盟+ U-App SDK 集成
- ✅ 埋点框架搭建（AnalyticsService + AnalyticsMixin）
- ✅ 页面浏览事件（6 个页面）
- ✅ 路线交互事件（trail_view, trail_favorite, trail_download, trail_navigate_start, trail_navigate_complete）
- ✅ 地图交互事件（map_zoom, offline_map_download, offline_map_delete）
- ✅ 导航事件（navigation_start, navigation_pause, navigation_resume, navigation_off_track, navigation_complete）
- ✅ 用户行为事件（app_launch, app_background, app_foreground, search, filter_use）

### 待完善
- ⬜ 友盟 AppKey 配置（需替换 main.dart 中的占位符）
- ⬜ 登录/注册埋点（需接入登录功能）
- ⬜ 分享功能埋点（需接入分享 SDK）
- ⬜ SOS 紧急求救埋点（需实现 SOS 功能）

## [1.0.0] - 2026-02-28

### 新增
- 项目初始化
- Flutter 框架搭建
- 高德地图 SDK 集成
- 基础 UI 组件库
- 10 条杭州徒步路线数据

### 技术
- 地图渲染与定位
- GPS 轨迹匹配算法
- 离线数据缓存机制
- 后台定位服务
