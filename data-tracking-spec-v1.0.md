# 山径APP - 数据埋点规范 v1.0

> **文档版本**: v1.0  
> **制定日期**: 2026-02-28  
> **文档状态**: Week 3 Day 1 - P6  
> **适用范围**: 山径APP全功能埋点  
> **产品定位**: 城市年轻人的轻度徒步向导

---

## 1. 埋点体系概述

### 1.1 埋点目标

| 目标维度 | 具体说明 |
|---------|---------|
| **产品优化** | 了解用户行为路径，优化功能设计和交互流程 |
| **运营决策** | 支持运营活动效果评估，指导内容推荐策略 |
| **商业分析** | 分析用户价值，支持商业模式优化 |
| **问题定位** | 快速发现功能异常和用户体验问题 |

### 1.2 埋点原则

1. **完整性** - 覆盖核心业务流程和关键用户行为
2. **准确性** - 确保数据真实可靠，避免重复或遗漏
3. **及时性** - 事件触发后实时上报，延迟不超过5秒
4. **隐私合规** - 遵循隐私政策，敏感信息脱敏处理
5. **性能友好** - 埋点逻辑不阻塞主线程，不影响用户体验

### 1.3 埋点类型

| 类型 | 说明 | 示例 |
|------|------|------|
| **页面埋点** | 页面浏览/离开事件 | 首页浏览、路线详情页浏览 |
| **点击埋点** | 用户点击/触摸事件 | 按钮点击、列表项点击 |
| **曝光埋点** | 元素可见性事件 | 卡片曝光、广告曝光 |
| **功能埋点** | 业务流程事件 | 开始导航、完成路线规划 |
| **性能埋点** | 技术指标事件 | 页面加载时长、接口响应时间 |
| **错误埋点** | 异常事件 | 网络错误、定位失败 |

---

## 2. 核心埋点事件定义

### 2.1 页面浏览事件 (PageView)

#### 事件说明
记录用户进入和离开页面的行为，用于分析页面流量和用户停留时长。

#### 事件标识
| 属性 | 值 |
|------|-----|
| 事件名 | `page_view` / `page_exit` |
| 事件类型 | 页面埋点 |
| 触发时机 | 页面可见时/页面隐藏时 |

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `page_id` | String | 是 | 页面唯一标识 | `home`, `route_detail`, `navigation` |
| `page_name` | String | 是 | 页面名称 | `首页`, `路线详情`, `导航页` |
| `page_url` | String | 是 | 页面路径 | `/pages/home/index` |
| `referrer_page` | String | 否 | 来源页面ID | `route_list` |
| `enter_time` | Number | 是 | 进入时间戳(ms) | `1709059200000` |
| `exit_time` | Number | 否 | 离开时间戳(ms) | `1709059260000` |
| `duration` | Number | 否 | 停留时长(ms) | `60000` |
| `page_params` | Object | 否 | 页面参数 | `{"route_id": "R001"}` |

#### 页面ID规范

| 页面 | page_id | page_name |
|------|---------|-----------|
| 启动页 | `splash` | 启动页 |
| 首页 | `home` | 首页 |
| 路线列表 | `route_list` | 路线列表 |
| 路线详情 | `route_detail` | 路线详情 |
| 路线规划 | `route_planning` | 路线规划 |
| 导航页 | `navigation` | 导航 |
| 记录页 | `record` | 路线记录 |
| 收藏页 | `favorite` | 我的收藏 |
| 离线包管理 | `offline_package` | 离线包管理 |
| 设置页 | `settings` | 设置 |
| 个人中心 | `profile` | 个人中心 |
| 搜索页 | `search` | 搜索 |
| 搜索结果 | `search_result` | 搜索结果 |

---

### 2.2 按钮点击事件 (ButtonClick)

#### 事件说明
记录用户点击按钮的行为，用于分析功能使用频率和转化漏斗。

#### 事件标识
| 属性 | 值 |
|------|-----|
| 事件名 | `button_click` |
| 事件类型 | 点击埋点 |
| 触发时机 | 按钮点击时 |

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `page_id` | String | 是 | 所在页面ID | `route_detail` |
| `button_id` | String | 是 | 按钮唯一标识 | `btn_start_nav` |
| `button_name` | String | 是 | 按钮名称 | `开始导航` |
| `button_type` | String | 否 | 按钮类型 | `primary`, `secondary`, `icon` |
| `click_time` | Number | 是 | 点击时间戳(ms) | `1709059200000` |
| `extra_params` | Object | 否 | 附加参数 | `{"route_id": "R001"}` |

#### 核心按钮ID规范

**首页 (home)**
| 按钮 | button_id | button_name |
|------|-----------|-------------|
| 搜索按钮 | `btn_search` | 搜索 |
| 定位按钮 | `btn_locate` | 定位当前位置 |
| 路线推荐卡片 | `btn_route_card` | 路线卡片 |
| 开始记录 | `btn_start_record` | 开始记录 |

**路线详情 (route_detail)**
| 按钮 | button_id | button_name |
|------|-----------|-------------|
| 返回按钮 | `btn_back` | 返回 |
| 收藏按钮 | `btn_favorite` | 收藏 |
| 分享按钮 | `btn_share` | 分享 |
| 开始导航 | `btn_start_nav` | 开始导航 |
| 下载离线包 | `btn_download_offline` | 下载离线包 |
| 查看海拔图 | `btn_elevation_chart` | 查看海拔图 |

**导航页 (navigation)**
| 按钮 | button_id | button_name |
|------|-----------|-------------|
| 停止导航 | `btn_stop_nav` | 停止导航 |
| 暂停导航 | `btn_pause_nav` | 暂停导航 |
| 继续导航 | `btn_resume_nav` | 继续导航 |
| 重新规划 | `btn_reroute` | 重新规划 |
| 语音开关 | `btn_voice_toggle` | 语音开关 |
| 地图模式切换 | `btn_map_mode` | 地图模式 |

**路线规划 (route_planning)**
| 按钮 | button_id | button_name |
|------|-----------|-------------|
| 添加途经点 | `btn_add_waypoint` | 添加途经点 |
| 删除途经点 | `btn_remove_waypoint` | 删除途经点 |
| 交换起终点 | `btn_swap_points` | 交换起终点 |
| 开始规划 | `btn_plan_route` | 开始规划 |
| 保存路线 | `btn_save_route` | 保存路线 |

---

### 2.3 功能使用事件 (FeatureUse)

#### 事件说明
记录用户完成特定业务流程的行为，用于分析功能使用情况和业务转化。

#### 事件标识
| 属性 | 值 |
|------|-----|
| 事件名 | `feature_use` |
| 事件类型 | 功能埋点 |
| 触发时机 | 功能完成/关键节点 |

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `feature_id` | String | 是 | 功能标识 | `navigation`, `route_planning`, `record` |
| `feature_name` | String | 是 | 功能名称 | `导航`, `路线规划`, `路线记录` |
| `action_type` | String | 是 | 动作类型 | `start`, `complete`, `cancel` |
| `page_id` | String | 是 | 所在页面 | `navigation` |
| `trigger_time` | Number | 是 | 触发时间戳(ms) | `1709059200000` |
| `duration` | Number | 否 | 功能耗时(ms) | `3600000` |
| `result` | String | 否 | 执行结果 | `success`, `fail`, `cancel` |
| `extra_params` | Object | 否 | 业务参数 | 见下文 |

#### 核心功能事件

**导航功能 (navigation)**

| 事件 | feature_id | action_type | extra_params |
|------|------------|-------------|--------------|
| 开始导航 | `navigation` | `start` | `{"route_id": "R001", "route_name": "西湖环线"}` |
| 导航完成 | `navigation` | `complete` | `{"route_id": "R001", "duration": 3600, "distance": 5600}` |
| 导航取消 | `navigation` | `cancel` | `{"route_id": "R001", "cancel_reason": "user"}` |
| 偏航重规划 | `navigation` | `reroute` | `{"route_id": "R001", "off_route_distance": 50}` |

**路线规划 (route_planning)**

| 事件 | feature_id | action_type | extra_params |
|------|------------|-------------|--------------|
| 开始规划 | `route_planning` | `start` | `{"start_point": "...", "end_point": "..."}` |
| 规划完成 | `route_planning` | `complete` | `{"route_id": "R001", "distance": 5600, "duration": 3600}` |
| 保存路线 | `route_planning` | `save` | `{"route_id": "R001", "save_type": "new"}` |

**路线记录 (record)**

| 事件 | feature_id | action_type | extra_params |
|------|------------|-------------|--------------|
| 开始记录 | `record` | `start` | `{"record_mode": "hiking"}` |
| 暂停记录 | `record` | `pause` | `{"duration": 1800}` |
| 恢复记录 | `record` | `resume` | `{}` |
| 完成记录 | `record` | `complete` | `{"record_id": "REC001", "distance": 5600, "duration": 3600}` |
| 保存记录 | `record` | `save` | `{"record_id": "REC001", "route_name": "自定义路线"}` |

**离线包管理 (offline_package)**

| 事件 | feature_id | action_type | extra_params |
|------|------------|-------------|--------------|
| 下载开始 | `offline_download` | `start` | `{"package_id": "P001", "package_size": 102400}` |
| 下载完成 | `offline_download` | `complete` | `{"package_id": "P001", "download_time": 120}` |
| 下载失败 | `offline_download` | `fail` | `{"package_id": "P001", "fail_reason": "network"}` |
| 删除离线包 | `offline_delete` | `delete` | `{"package_id": "P001"}` |

---

### 2.4 搜索事件 (Search)

#### 事件说明
记录用户搜索行为，用于优化搜索算法和了解用户需求。

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `search_type` | String | 是 | 搜索类型 | `route`, `location`, `poi` |
| `keyword` | String | 是 | 搜索关键词 | `西湖` |
| `result_count` | Number | 否 | 结果数量 | `15` |
| `has_result` | Boolean | 否 | 是否有结果 | `true` |
| `click_position` | Number | 否 | 点击位置 | `2` |
| `click_result` | String | 否 | 点击结果ID | `R001` |

---

### 2.5 手势事件 (Gesture)

| 属性 | 值 |
|------|-----|
| 事件名 | `gesture` |
| 触发时机 | 手势识别完成时 |

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `gesture_type` | String | 是 | 手势类型：`pinch`/`swipe`/`tap` |
| `gesture_data` | Object | 是 | 手势数据，见下表 |

#### 手势类型定义

| 手势类型 | 事件名称 | 参数 |
|----------|----------|------|
| pinch（缩放） | `gesture_pinch` | `scale`（缩放比例）、`center_x`、`center_y`（中心点坐标） |
| swipe（滑动） | `gesture_swipe` | `direction`（方向：up/down/left/right）、`velocity`（速度）、`distance`（距离） |
| tap（点击） | `gesture_tap` | `x`、`y`（坐标）、`tap_count`（点击次数） |

---

### 2.6 曝光事件 (Exposure)

#### 事件说明
记录元素在可视区域出现的事件，用于分析内容曝光和点击率。

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `page_id` | String | 是 | 所在页面 | `home` |
| `element_id` | String | 是 | 元素标识 | `route_card_001` |
| `element_type` | String | 是 | 元素类型 | `card`, `banner`, `list_item` |
| `content_id` | String | 否 | 内容ID | `R001` |
| `exposure_time` | Number | 是 | 曝光时间戳 | `1709059200000` |
| `visible_duration` | Number | 否 | 可见时长(ms) | `2000` |

---

## 3. 埋点数据结构

### 3.1 通用事件结构

所有埋点事件遵循以下基础数据结构：

```json
{
  "event": {
    "event_id": "evt_1234567890",
    "event_name": "page_view",
    "event_type": "page",
    "timestamp": 1709059200000,
    "timezone": "Asia/Shanghai"
  },
  "user": {
    "user_id": "u_abc123",
    "device_id": "dev_xyz789",
    "anonymous_id": "anon_def456",
    "is_login": true
  },
  "device": {
    "platform": "iOS",
    "os_version": "17.0",
    "device_model": "iPhone15,2",
    "app_version": "1.0.0",
    "app_channel": "AppStore"
  },
  "network": {
    "type": "WiFi",
    "carrier": "中国移动"
  },
  "location": {
    "latitude": 30.2741,
    "longitude": 120.1551,
    "accuracy": 10,
    "city": "杭州市",
    "province": "浙江省"
  },
  "page": {
    "page_id": "home",
    "page_name": "首页",
    "page_url": "/pages/home/index",
    "referrer_page": "splash"
  },
  "properties": {
    // 事件特有参数
  }
}
```

### 3.2 字段详细说明

#### Event 事件信息

| 字段 | 类型 | 说明 |
|------|------|------|
| `event_id` | String | 事件唯一ID，UUID格式 |
| `event_name` | String | 事件名称，小写下划线格式 |
| `event_type` | String | 事件类型：page/click/feature/exposure/error |
| `timestamp` | Number | 事件触发时间戳（毫秒） |
| `timezone` | String | 时区信息 |

#### User 用户信息

| 字段 | 类型 | 说明 |
|------|------|------|
| `user_id` | String | 登录用户ID，未登录为空 |
| `device_id` | String | 设备唯一标识 |
| `anonymous_id` | String | 匿名用户标识，首次启动生成 |
| `is_login` | Boolean | 是否已登录 |

#### Device 设备信息

| 字段 | 类型 | 说明 |
|------|------|------|
| `platform` | String | 平台：iOS/Android |
| `os_version` | String | 操作系统版本 |
| `device_model` | String | 设备型号 |
| `app_version` | String | App版本号 |
| `app_channel` | String | 分发渠道 |
| `screen_width` | Number | 屏幕宽度 |
| `screen_height` | Number | 屏幕高度 |
| `pixel_ratio` | Number | 屏幕像素比 |

#### Network 网络信息

| 字段 | 类型 | 说明 |
|------|------|------|
| `type` | String | 网络类型：WiFi/4G/5G/3G/2G/Offline |
| `carrier` | String | 运营商名称 |

#### Location 位置信息

| 字段 | 类型 | 说明 |
|------|------|------|
| `latitude` | Number | 纬度 |
| `longitude` | Number | 经度 |
| `accuracy` | Number | 定位精度（米） |
| `altitude` | Number | 海拔高度（米） |
| `city` | String | 城市 |
| `province` | String | 省份 |

---

## 4. 埋点实施规范

### 4.1 代码埋点规范

#### 命名规范

| 类型 | 命名规则 | 示例 |
|------|----------|------|
| 事件名 | 小写下划线 | `page_view`, `button_click` |
| 页面ID | 小写下划线 | `route_detail`, `offline_package` |
| 按钮ID | 前缀_动作 | `btn_start_nav`, `btn_favorite` |
| 功能ID | 小写下划线 | `route_planning`, `offline_download` |
| 参数名 | 小写下划线 | `route_id`, `enter_time` |

#### 代码示例

**iOS (Swift)**
```swift
// 页面浏览
Analytics.track(event: "page_view", parameters: [
    "page_id": "route_detail",
    "page_name": "路线详情",
    "page_params": ["route_id": route.id]
])

// 按钮点击
Analytics.track(event: "button_click", parameters: [
    "page_id": "route_detail",
    "button_id": "btn_start_nav",
    "button_name": "开始导航",
    "extra_params": ["route_id": route.id]
])

// 功能使用
Analytics.track(event: "feature_use", parameters: [
    "feature_id": "navigation",
    "feature_name": "导航",
    "action_type": "start",
    "extra_params": [
        "route_id": route.id,
        "route_name": route.name
    ]
])
```

**Android (Kotlin)**
```kotlin
// 页面浏览
Analytics.track("page_view", mapOf(
    "page_id" to "route_detail",
    "page_name" to "路线详情",
    "page_params" to mapOf("route_id" to route.id)
))

// 按钮点击
Analytics.track("button_click", mapOf(
    "page_id" to "route_detail",
    "button_id" to "btn_start_nav",
    "button_name" to "开始导航",
    "extra_params" to mapOf("route_id" to route.id)
))
```

**Flutter**
```dart
// 页面浏览
Analytics.track('page_view', {
  'page_id': 'route_detail',
  'page_name': '路线详情',
  'page_params': {'route_id': route.id}
});

// 按钮点击
Analytics.track('button_click', {
  'page_id': 'route_detail',
  'button_id': 'btn_start_nav',
  'button_name': '开始导航',
  'extra_params': {'route_id': route.id}
});
```

### 4.2 埋点时机规范

| 事件类型 | 触发时机 | 注意事项 |
|----------|----------|----------|
| 页面浏览 | `viewDidAppear` / `onResume` | 确保页面完全可见后上报 |
| 页面离开 | `viewDidDisappear` / `onPause` | 计算停留时长后上报 |
| 按钮点击 | 点击回调中立即上报 | 避免延迟导致遗漏 |
| 功能开始 | 功能启动时上报 | 记录开始时间戳 |
| 功能完成 | 功能成功结束时上报 | 包含完整业务数据 |
| 曝光事件 | 元素进入可视区域且停留>500ms | 使用IntersectionObserver |

### 4.3 数据上报策略

#### 上报时机

| 策略 | 说明 | 适用场景 |
|------|------|----------|
| **实时上报** | 事件触发后立即上报 | 关键业务事件、错误事件 |
| **批量上报** | 累积一定数量或时间后上报 | 普通点击、曝光事件 |
| **延迟上报** | 网络恢复后上报 | 离线状态下的事件 |

#### 上报条件

```
实时上报条件：
- 事件类型为 error
- 事件类型为 feature_use 且 action_type 为 complete/fail
- 用户主动退出App

批量上报条件（满足任一）：
- 累积事件数 >= 10条
- 距离上次上报 >= 30秒
- App进入后台
- 用户主动退出App
```

### 4.4 数据质量控制

#### 校验规则

| 校验项 | 规则 | 处理方式 |
|--------|------|----------|
| 必填字段 | event_id, event_name, timestamp | 缺失则丢弃，记录错误日志 |
| 时间有效性 | 与服务器时间差 < 24小时 | 异常时间戳标记待校验 |
| 参数类型 | 符合定义的字段类型 | 类型不匹配则转换或丢弃 |
| 参数范围 | 枚举值在定义范围内 | 超出范围标记为"other" |

#### 测试验证

| 测试类型 | 测试内容 | 验收标准 |
|----------|----------|----------|
| 功能测试 | 验证事件触发和参数正确性 | 事件触发时机正确，参数完整 |
| 性能测试 | 验证埋点对App性能影响 | 埋点耗时 < 50ms，内存增长 < 5MB |
| 网络测试 | 验证弱网和离线场景 | 数据不丢失，恢复后正确上报 |
| 兼容性测试 | 验证不同设备和系统版本 | iOS 12+ / Android 8+ 正常运行 |

---

## 5. 核心指标定义

### 5.1 用户行为指标

| 指标名 | 定义 | 计算方式 |
|--------|------|----------|
| **DAU** | 日活跃用户数 | 当日触发任意事件的独立用户数 |
| **MAU** | 月活跃用户数 | 当月触发任意事件的独立用户数 |
| **启动次数** | App启动次数 | 冷启动 + 热启动次数 |
| **人均使用时长** | 用户平均使用时长 | 总使用时长 / 活跃用户数 |
| **人均启动次数** | 用户平均启动次数 | 总启动次数 / 活跃用户数 |

### 5.2 功能使用指标

| 指标名 | 定义 | 计算方式 |
|--------|------|----------|
| **导航使用率** | 使用导航功能的用户占比 | 导航用户数 / 总用户数 |
| **路线规划转化率** | 规划后保存路线的比例 | 保存路线数 / 规划完成数 |
| **离线包下载率** | 下载离线包的用户占比 | 下载用户数 / 总用户数 |
| **收藏转化率** | 浏览后收藏的比例 | 收藏数 / 路线浏览数 |
| **分享率** | 分享行为的用户占比 | 分享用户数 / 总用户数 |

### 5.3 导航核心指标

| 指标名 | 定义 | 计算方式 |
|--------|------|----------|
| **导航完成率** | 开始导航后完成的比例 | 导航完成数 / 导航开始数 |
| **平均偏航次数** | 单次导航平均偏航次数 | 总偏航次数 / 导航完成数 |
| **平均导航时长** | 单次导航平均耗时 | 总导航时长 / 导航完成数 |
| **离线导航占比** | 离线状态下的导航占比 | 离线导航数 / 总导航数 |

---

## 6. 隐私与合规

### 6.1 数据采集原则

1. **最小必要原则** - 只采集业务必需的数据
2. **用户授权原则** - 敏感数据采集前获得用户同意
3. **匿名化处理** - 用户标识符不可逆关联真实身份
4. **数据安全原则** - 传输和存储过程加密处理

### 6.2 敏感数据处理

| 数据类型 | 处理方式 |
|----------|----------|
| 精确位置 | 上报前脱敏，保留2位小数 |
| 设备标识 | 使用匿名化设备ID，不采集IMEI/Mac |
| 用户ID | 加密传输，日志中脱敏显示 |
| 搜索关键词 | 过滤敏感词，不关联用户身份 |

### 6.3 合规要求

- 遵循《个人信息保护法》相关规定
- 隐私政策中明确告知数据收集范围
- 提供用户数据导出和删除入口
- 不将数据用于约定范围外的用途

---

## 7. 附录

### 7.1 事件字典速查表

| 事件名 | 事件类型 | 触发场景 |
|--------|----------|----------|
| `app_launch` | 功能 | App启动 |
| `app_exit` | 功能 | App退出 |
| `page_view` | 页面 | 页面进入 |
| `page_exit` | 页面 | 页面离开 |
| `button_click` | 点击 | 按钮点击 |
| `feature_use` | 功能 | 功能使用 |
| `search` | 功能 | 搜索行为 |
| `exposure` | 曝光 | 元素曝光 |
| `error` | 错误 | 异常发生 |
| `gesture` | 手势 | 手势交互 |
| `theme_switch` | 功能 | 主题切换 |

**theme_switch 参数**

| 参数名 | 类型 | 说明 | 示例 |
|--------|------|------|------|
| `from_theme` | String | 原主题 | `light`, `dark`, `auto` |
| `to_theme` | String | 目标主题 | `light`, `dark`, `auto` |

### 7.2 参考文档

- 设计系统: design-system-v1.0.md
- 产品术语: shanjing-terminology.md
- PRD: shanjing-prd-v1.2.md

### 7.3 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-02-28 | 初版完成，包含核心事件定义、数据结构和实施规范 |

---

> **"数据驱动决策，埋点连接用户"** - 山径APP数据理念
