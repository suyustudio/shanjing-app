# 山径 APP 埋点实施检查清单

> **文档版本**: v1.0  
> **生成日期**: 2026-03-14  
> **SDK 选型**: 友盟+ U-App  

---

## 1. SDK 集成状态

| 检查项 | 状态 | 说明 |
|--------|------|------|
| pubspec.yaml 依赖添加 | ✅ 完成 | `umeng_analytics_plugin: ^1.0.0` |
| SDK 初始化 | ✅ 完成 | `main.dart` 中初始化，DEBUG 关闭/发布开启 |
| 用户身份关联 | ✅ 完成 | `setUserId()` 方法已实现 |
| 调试日志 | ✅ 完成 | 仅在 debugMode=true 输出 |

---

## 2. 页面浏览事件 (page_view / page_exit)

| 页面 | 页面 ID | 页面名称 | 状态 | 额外参数 |
|------|---------|----------|------|----------|
| 发现页 | `discovery` | 发现页 | ✅ | - |
| 路线详情页 | `trail_detail` | 路线详情页 | ✅ | `route_id`, `route_name` |
| 地图页 | `map` | 地图页 | ✅ | - |
| 导航页 | `navigation` | 导航页 | ✅ | `route_name` |
| 我的页 | `profile` | 我的页 | ✅ | - |
| 离线地图页 | `offline_map` | 离线地图页 | ✅ | - |

**实现方式**: `AnalyticsMixin` 自动处理页面生命周期

---

## 3. 路线交互事件

| 事件名 | 触发位置 | 状态 | 参数 |
|--------|----------|------|------|
| `trail_view` | 发现页列表点击 | ✅ | `route_id`, `route_name`, `difficulty`, `duration`, `distance`, `source` |
| `trail_favorite` | 路线详情页收藏按钮 | ✅ | `route_id`, `route_name`, `action` (add/remove) |
| `trail_download` | 路线详情页下载按钮 | ✅ | `route_id`, `route_name`, `start_time` |
| `trail_navigate_start` | 路线详情页导航按钮 | ✅ | `route_id`, `route_name`, `source` |
| `trail_navigate_complete` | 导航完成时 | ✅ | `route_name`, `completion_time` |
| `trail_share` | (暂未实现) | ⬜ | - |

---

## 4. 地图交互事件

| 事件名 | 触发位置 | 状态 | 参数 |
|--------|----------|------|------|
| `map_marker_click` | (需补充) | ⬜ | `marker_id`, `marker_type` |
| `map_route_click` | (需补充) | ⬜ | `route_id` |
| `map_zoom` | 地图缩放按钮 | ✅ | `zoom_level`, `direction` (in/out) |
| `offline_map_download` | 离线地图下载完成 | ✅ | `city_code`, `city_name`, `result` (success/failed) |
| `offline_map_delete` | 离线地图删除 | ✅ | `city_code`, `city_name` |

---

## 5. 导航事件

| 事件名 | 触发位置 | 状态 | 参数 |
|--------|----------|------|------|
| `navigation_start` | 路线详情页开始导航 | ✅ | `route_id`, `route_name` |
| `navigation_pause` | 导航页关闭时 | ✅ | `route_name`, `duration`, `reason` |
| `navigation_resume` | 从偏航恢复时 | ✅ | `route_name` |
| `navigation_off_track` | 偏航检测触发 | ✅ | `route_name`, `off_track_distance` |
| `navigation_complete` | 到达目的地 | ✅ | `route_name`, `duration` |
| `navigation_sos_trigger` | (暂未实现 SOS 功能) | ⬜ | - |

---

## 6. 用户行为事件

| 事件名 | 触发位置 | 状态 | 参数 |
|--------|----------|------|------|
| `app_launch` | 应用启动时 | ✅ | `source`, `launch_time` |
| `app_background` | 应用进入后台 | ✅ | `source_page`, `timestamp` |
| `app_foreground` | 应用回到前台 | ✅ | `source_page`, `timestamp` |
| `search` | 发现页搜索 | ✅ | `keyword`, `result_count` |
| `filter_use` | 发现页标签筛选 | ✅ | `filter_type`, `filter_value` |
| `login` | (需接入登录功能) | ⬜ | `login_type`, `success`, `is_new_user` |
| `register` | (需接入登录功能) | ⬜ | `login_type` |

---

## 7. 属性完整性检查

### 7.1 通用属性（所有事件自动附加）

| 属性名 | 说明 | 状态 |
|--------|------|------|
| `timestamp` | 事件发生时间戳 | ✅ |
| `user_id` | 用户 ID（登录后） | ✅ |
| `page_id` | 当前页面 ID | ✅ |

### 7.2 用户属性（需登录后设置）

| 属性名 | 说明 | 状态 |
|--------|------|------|
| `user_id` | 用户唯一标识 | ✅ |

---

## 8. 待完善项

### 8.1 功能依赖（需产品/开发配合）

| 功能 | 关联事件 | 优先级 |
|------|----------|--------|
| 分享功能 | `trail_share` | P1 |
| 登录/注册 | `login`, `register` | P1 |
| SOS 紧急求救 | `navigation_sos_trigger` | P2 |
| POI 点击 | `map_marker_click` | P2 |
| 路线点击 | `map_route_click` | P2 |

### 8.2 配置项

| 配置项 | 说明 | 状态 |
|--------|------|------|
| 友盟 Android AppKey | 需在 `main.dart` 中替换 | ⚠️ 待配置 |
| 友盟 iOS AppKey | 需在 `main.dart` 中替换 | ⚠️ 待配置 |

---

## 9. 验证方法

### 9.1 开发环境验证

```bash
# 1. 运行应用，观察控制台日志
flutter run

# 2. 查看 Analytics 调试输出（应显示 ✅ [Analytics] 前缀日志）
```

### 9.2 友盟后台验证

1. 登录友盟+ U-App 后台：https://www.umeng.com
2. 进入「应用统计」-「实时」查看实时事件
3. 触发事件后 1-5 分钟内应能看到数据

### 9.3 事件验证清单

- [ ] 启动应用 → 查看 `app_launch` 事件
- [ ] 切换底部导航 → 查看各页面 `page_view` 事件
- [ ] 搜索路线 → 查看 `search` 事件
- [ ] 点击筛选标签 → 查看 `filter_use` 事件
- [ ] 进入路线详情 → 查看 `trail_view` + `page_view`
- [ ] 点击收藏 → 查看 `trail_favorite` 事件
- [ ] 点击下载 → 查看 `trail_download` 事件
- [ ] 开始导航 → 查看 `navigation_start` 事件
- [ ] 地图缩放 → 查看 `map_zoom` 事件
- [ ] 下载离线地图 → 查看 `offline_map_download` 事件

---

## 10. 下一步行动

1. **配置友盟 AppKey**: 替换 `main.dart` 中的 `YOUR_UMENG_ANDROID_KEY` 和 `YOUR_UMENG_IOS_KEY`
2. **接入登录功能**: 完成后补充 `login` 和 `register` 事件
3. **实现分享功能**: 完成后补充 `trail_share` 事件
4. **添加 SOS 功能**: 完成后补充 `navigation_sos_trigger` 事件
5. **完善地图交互**: 添加 `map_marker_click` 和 `map_route_click` 事件

---

**总结**: 当前已完成 25+ 个核心埋点事件，覆盖页面浏览、路线交互、地图交互、导航事件、用户行为等主要场景。基础埋点框架已搭建完成，可与友盟后台联调验证。
