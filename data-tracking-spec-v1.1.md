# 山径APP - 埋点补充规范 v1.1

> **文档版本**: v1.1  
> **制定日期**: 2026-03-14  
> **基于版本**: v1.0  
> **文档状态**: 补充完善  

---

## 1. 补充埋点事件

### 1.1 安全功能埋点

#### SOS紧急求救

| 属性 | 值 |
|------|-----|
| 事件名 | `sos_triggered` |
| 事件类型 | 功能埋点 |
| 触发时机 | 用户点击SOS按钮并确认后 |

**事件参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `trigger_location` | Object | 是 | 触发位置坐标 | `{"lat": 30.2741, "lng": 120.1551}` |
| `contact_count` | Number | 是 | 紧急联系人数 | `2` |
| `send_method` | String | 是 | 发送方式 | `sms`, `push`, `both` |
| `send_success` | Boolean | 是 | 发送是否成功 | `true` |
| `trigger_time` | Number | 是 | 触发时间戳 | `1709059200000` |
| `route_id` | String | 否 | 当前导航路线ID | `R001` |

#### 行程分享

| 属性 | 值 |
|------|-----|
| 事件名 | `trip_shared` |
| 事件类型 | 功能埋点 |
| 触发时机 | 用户分享行程后 |

**事件参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `share_type` | String | 是 | 分享类型 | `wechat`, `moments`, `copy_link` |
| `route_id` | String | 是 | 路线ID | `R001` |
| `include_location` | Boolean | 否 | 是否包含实时位置 | `true` |
| `recipient_count` | Number | 否 | 接收人数 | `3` |

#### 紧急联系人设置

| 属性 | 值 |
|------|-----|
| 事件名 | `emergency_contact_updated` |
| 事件类型 | 功能埋点 |
| 触发时机 | 用户添加/修改紧急联系人后 |

**事件参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `action` | String | 是 | 操作类型 | `add`, `update`, `delete` |
| `contact_count` | Number | 是 | 设置后的联系人数量 | `2` |

---

### 1.2 路线详情埋点

#### 海拔图查看

| 属性 | 值 |
|------|-----|
| 事件名 | `elevation_viewed` |
| 事件类型 | 点击埋点 |
| 触发时机 | 用户点击查看海拔剖面图 |

**事件参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `route_id` | String | 是 | 路线ID | `R001` |
| `view_duration` | Number | 否 | 查看时长(ms) | `5000` |

#### POI点击

| 属性 | 值 |
|------|-----|
| 事件名 | `poi_clicked` |
| 事件类型 | 点击埋点 |
| 触发时机 | 用户点击POI标记或列表项 |

**事件参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `route_id` | String | 是 | 路线ID | `R001` |
| `poi_id` | String | 是 | POI标识 | `POI_001` |
| `poi_type` | String | 是 | POI类型 | `viewpoint`, `restroom`, `supply` |
| `poi_name` | String | 否 | POI名称 | `观景台` |

---

### 1.3 用户系统埋点

#### 登录相关

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `login_success` | 登录成功时 | `login_type` (wechat/phone), `is_new_user` |
| `login_fail` | 登录失败时 | `login_type`, `fail_reason`, `fail_code` |
| `logout` | 用户退出登录 | `user_id`, `session_duration` |

#### 用户资料

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `profile_updated` | 更新个人资料 | `field_name`, `update_type` |
| `avatar_changed` | 更换头像 | `source` (camera/gallery) |

---

### 1.4 离线包埋点

#### 存储空间检查

| 属性 | 值 |
|------|-----|
| 事件名 | `storage_check` |
| 事件类型 | 功能埋点 |
| 触发时机 | 下载离线包前检查存储空间 |

**事件参数**

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `available_space` | Number | 是 | 可用空间(MB) | `5120` |
| `required_space` | Number | 是 | 所需空间(MB) | `15` |
| `sufficient` | Boolean | 是 | 空间是否充足 | `true` |

#### 离线包更新

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `offline_package_expired` | 检测到离线包过期 | `package_id`, `expired_days` |
| `offline_package_updated` | 用户更新离线包 | `package_id`, `update_type` |

---

### 1.5 导航过程埋点

#### 导航异常

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `navigation_interrupted` | 导航意外中断 | `reason` (call/app_kill/gps_lost), `duration` |
| `navigation_resumed` | 恢复导航 | `route_id`, `interrupted_duration` |
| `voice_broadcast` | 语音播报触发 | `broadcast_type`, `distance_to_next` |

#### 电量相关

| 事件名 | 触发时机 | 参数 |
|--------|----------|------|
| `low_battery_warning` | 电量低于20%触发警告 | `battery_level`, `is_charging` |
| `power_save_activated` | 自动进入省电模式 | `battery_level`, `reduced_features` |

---

## 2. 埋点实施检查清单

### 2.1 必须实施（P0）

| 事件名 | 页面/模块 | 开发状态 | 测试状态 |
|--------|----------|----------|----------|
| `page_view` / `page_exit` | 所有页面 | ⬜ 未开始 | ⬜ 未开始 |
| `button_click` | 核心按钮 | ⬜ 未开始 | ⬜ 未开始 |
| `feature_use` (导航) | 导航模块 | ⬜ 未开始 | ⬜ 未开始 |
| `sos_triggered` | 安全模块 | ⬜ 未开始 | ⬜ 未开始 |
| `login_success` / `login_fail` | 登录模块 | ⬜ 未开始 | ⬜ 未开始 |

### 2.2 建议实施（P1）

| 事件名 | 页面/模块 | 开发状态 | 测试状态 |
|--------|----------|----------|----------|
| `trip_shared` | 分享功能 | ⬜ 未开始 | ⬜ 未开始 |
| `poi_clicked` | 路线详情 | ⬜ 未开始 | ⬜ 未开始 |
| `elevation_viewed` | 路线详情 | ⬜ 未开始 | ⬜ 未开始 |
| `offline_download` | 离线地图 | ⬜ 未开始 | ⬜ 未开始 |
| `search` | 搜索模块 | ⬜ 未开始 | ⬜ 未开始 |

---

## 3. 埋点实施代码示例

### 3.1 Flutter埋点工具类

```dart
// lib/utils/analytics.dart

class Analytics {
  static void trackPageView(String pageId, String pageName, {Map<String, dynamic>? params}) {
    // 页面浏览埋点
    _track('page_view', {
      'page_id': pageId,
      'page_name': pageName,
      'page_params': params,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static void trackPageExit(String pageId, int duration) {
    // 页面离开埋点
    _track('page_exit', {
      'page_id': pageId,
      'duration': duration,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static void trackButtonClick(String pageId, String buttonId, String buttonName, {Map<String, dynamic>? extra}) {
    // 按钮点击埋点
    _track('button_click', {
      'page_id': pageId,
      'button_id': buttonId,
      'button_name': buttonName,
      'extra_params': extra,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static void trackFeatureUse(String featureId, String featureName, String actionType, {Map<String, dynamic>? extra}) {
    // 功能使用埋点
    _track('feature_use', {
      'feature_id': featureId,
      'feature_name': featureName,
      'action_type': actionType,
      'extra_params': extra,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }
  
  static void _track(String eventName, Map<String, dynamic> data) {
    // 实际埋点上报逻辑
    // 1. 添加通用参数（设备信息、用户信息等）
    // 2. 本地缓存或实时上报
    // 3. 网络恢复后补报
    print('[Analytics] $eventName: $data');
  }
}
```

### 3.2 使用示例

```dart
// 页面埋点
class RouteDetailScreen extends StatefulWidget {
  @override
  void initState() {
    super.initState();
    Analytics.trackPageView('route_detail', '路线详情', params: {'route_id': widget.routeId});
  }
  
  @override
  void dispose() {
    Analytics.trackPageExit('route_detail', _pageDuration);
    super.dispose();
  }
}

// 按钮埋点
ElevatedButton(
  onPressed: () {
    Analytics.trackButtonClick('route_detail', 'btn_start_nav', '开始导航', 
      extra: {'route_id': routeId});
    startNavigation();
  },
  child: Text('开始导航'),
)

// 功能埋点
void startNavigation() {
  Analytics.trackFeatureUse('navigation', '导航', 'start', 
    extra: {'route_id': routeId, 'route_name': routeName});
  // ...
}
```

---

## 4. 更新记录

| 版本 | 日期 | 更新内容 |
|------|------|----------|
| v1.0 | 2026-02-28 | 初版完成，包含核心事件定义 |
| v1.1 | 2026-03-14 | 补充安全功能、POI、登录、存储等埋点事件 |

---

> **"数据驱动决策，埋点连接用户"** - 山径APP数据理念
