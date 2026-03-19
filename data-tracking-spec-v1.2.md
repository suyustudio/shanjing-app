# 山径APP - 数据埋点规范 v1.2（最终版）

> **文档版本**: v1.2  
> **制定日期**: 2026-03-19  
> **文档状态**: 最终版  
> **基于版本**: v1.0, v1.1  
> **适用范围**: M4 阶段埋点实施  
> **产品定位**: 城市年轻人的轻度徒步向导

---

## 1. 更新概述

### 1.1 版本变更

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| v1.0 | 2026-02-28 | 初版完成，核心事件定义 |
| v1.1 | 2026-03-14 | 补充安全功能、POI、登录、存储等埋点 |
| **v1.2** | **2026-03-19** | **确认 4 个待实施事件的具体触发时机和参数格式** |
| **v1.2.1** | **2026-03-19** | **新增失败场景埋点处理规范（网络失败、取消操作、API失败）** |

### 1.2 v1.2 重点更新

- ✅ **明确 4 个待实施事件的触发时机**
- ✅ **定义事件参数的详细格式**
- ✅ **提供代码实现示例**
- ✅ **完善实施检查清单**

---

## 2. 待实施埋点事件（M4 重点）

### 2.1 路线分享事件 (share_trail)

#### 事件定义

| 属性 | 值 |
|------|-----|
| **事件名** | `share_trail` |
| **事件类型** | 功能埋点 |
| **触发时机** | 用户成功分享路线后（选择分享渠道并确认） |
| **事件级别** | P0 - 必须实施 |

#### 触发时机详解

```
触发流程:
1. 用户点击路线详情页分享按钮
2. 弹出分享面板，选择分享模板（3种风格可选）
3. 选择分享渠道（微信好友/朋友圈/保存本地）
4. 用户确认分享
5. ✅ 事件触发（分享成功回调中）

不触发场景:
- 用户仅打开分享面板但未选择渠道
- 分享过程中取消
- 分享失败（错误事件单独上报）
```

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `route_id` | String | 是 | 路线唯一标识 | `"R001"` |
| `route_name` | String | 是 | 路线名称 | `"九溪十八涧"` |
| `share_channel` | String | 是 | 分享渠道 | 见下方枚举 |
| `template_type` | String | 是 | 海报模板类型 | 见下方枚举 |
| `share_time_ms` | Number | 是 | 分享耗时(毫秒) | `1250` |
| `poster_size_kb` | Number | 否 | 海报大小(KB) | `245` |
| `generation_duration_ms` | Number | 否 | 海报生成耗时 | `800` |

#### 枚举值定义

**share_channel (分享渠道)**
| 值 | 说明 |
|----|------|
| `wechat_session` | 微信好友 |
| `wechat_timeline` | 微信朋友圈 |
| `save_local` | 保存到本地相册 |
| `copy_link` | 复制链接 |
| `more_options` | 更多选项（系统分享） |

**template_type (模板类型)**
| 值 | 说明 |
|----|------|
| `nature` | 山野自然风（默认） |
| `minimal` | 极简数据风 |
| `film` | 文艺胶片风 |

#### 代码实现示例

```dart
// lib/widgets/share_poster.dart

void _onShareConfirmed(String channel, String templateType) {
  final startTime = DateTime.now();
  
  // 生成海报
  generatePoster(templateType).then((posterData) {
    final generationDuration = DateTime.now().difference(startTime).inMilliseconds;
    final posterSize = posterData.lengthInBytes ~/ 1024;
    
    // 执行分享
    Share.share(posterData, channel: channel).then((result) {
      final shareTime = DateTime.now().difference(startTime).inMilliseconds;
      
      // ✅ 埋点上报
      Analytics.track('share_trail', {
        'route_id': widget.routeId,
        'route_name': widget.routeName,
        'share_channel': channel,
        'template_type': templateType,
        'share_time_ms': shareTime,
        'poster_size_kb': posterSize,
        'generation_duration_ms': generationDuration,
      });
      
      // 显示成功提示
      showToast('分享成功');
    }).catchError((error) {
      // 分享失败单独上报
      Analytics.track('share_trail_failed', {
        'route_id': widget.routeId,
        'fail_reason': error.toString(),
      });
    });
  });
}
```

---

### 2.2 SOS 紧急求助事件 (sos_trigger)

#### 事件定义

| 属性 | 值 |
|------|-----|
| **事件名** | `sos_trigger` |
| **事件类型** | 功能埋点 |
| **触发时机** | SOS 倒计时结束或用户主动确认后，真实发起求助 |
| **事件级别** | P0 - 必须实施 |

#### 触发时机详解

```
触发流程:
1. 用户点击 SOS 按钮
2. 显示倒计时确认页面（5秒倒计时）
3. 场景 A: 倒计时结束自动触发
   场景 B: 用户在倒计时期间点击"立即发送"
4. 调用后端 SOS API
5. 后端返回成功
6. ✅ 事件触发（API 成功回调中）

不触发场景:
- 用户点击 SOS 后取消
- 倒计时期间退出页面
- API 调用失败（错误事件单独上报）
```

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `trigger_type` | String | 是 | 触发方式 | `"auto"` / `"manual"` |
| `countdown_remaining_sec` | Number | 是 | 倒计时剩余秒数 | `0` / `3` |
| `location_lat` | Number | 是 | 触发位置纬度 | `30.2741` |
| `location_lng` | Number | 是 | 触发位置经度 | `120.1551` |
| `location_accuracy` | Number | 是 | 定位精度(米) | `8.5` |
| `route_id` | String | 否 | 当前导航路线ID | `"R001"` |
| `contact_count` | Number | 是 | 紧急联系人数 | `2` |
| `send_method` | String | 是 | 发送方式 | 见下方枚举 |
| `api_response_ms` | Number | 是 | API 响应时间 | `350` |
| `trigger_timestamp` | Number | 是 | 触发时间戳 | `1709059200000` |

#### 枚举值定义

**trigger_type (触发方式)**
| 值 | 说明 |
|----|------|
| `auto` | 倒计时结束自动触发 |
| `manual` | 用户主动点击"立即发送" |

**send_method (发送方式)**
| 值 | 说明 |
|----|------|
| `sms` | 仅短信 |
| `push` | 仅推送通知 |
| `both` | 短信+推送 |
| `wechat` | 微信通知（如已绑定） |

#### 代码实现示例

```dart
// lib/services/sos_service.dart

class SOSService {
  static Future<bool> triggerSOS({
    required String triggerType,
    required int countdownRemaining,
    String? routeId,
  }) async {
    final triggerTime = DateTime.now().millisecondsSinceEpoch;
    
    // 获取当前位置
    final position = await LocationService.getCurrentPosition();
    
    // 获取紧急联系人
    final contacts = await getEmergencyContacts();
    
    // 调用后端 API
    final apiStartTime = DateTime.now();
    try {
      final response = await http.post(
        Uri.parse('${Config.apiBaseUrl}/sos/trigger'),
        body: {
          'lat': position.latitude,
          'lng': position.longitude,
          'contacts': contacts.map((c) => c.phone).toList(),
          'route_id': routeId,
        },
      );
      final apiResponseTime = DateTime.now().difference(apiStartTime).inMilliseconds;
      
      if (response.statusCode == 200) {
        // ✅ 埋点上报
        Analytics.track('sos_trigger', {
          'trigger_type': triggerType,
          'countdown_remaining_sec': countdownRemaining,
          'location_lat': position.latitude,
          'location_lng': position.longitude,
          'location_accuracy': position.accuracy,
          'route_id': routeId,
          'contact_count': contacts.length,
          'send_method': 'both', // 根据后端配置
          'api_response_ms': apiResponseTime,
          'trigger_timestamp': triggerTime,
        });
        
        return true;
      }
    } catch (e) {
      // SOS 失败单独上报
      Analytics.track('sos_trigger_failed', {
        'error': e.toString(),
        'route_id': routeId,
      });
    }
    
    return false;
  }
}
```

---

### 2.3 导航开始事件 (navigation_start)

#### 事件定义

| 属性 | 值 |
|------|-----|
| **事件名** | `navigation_start` |
| **事件类型** | 功能埋点 |
| **触发时机** | 用户点击"开始导航"按钮，导航界面成功加载后 |
| **事件级别** | P0 - 必须实施 |

#### 触发时机详解

```
触发流程:
1. 用户在路线详情页点击"开始导航"按钮
2. 导航页面打开
3. 地图初始化完成
4. GPS 定位成功（或进入模拟模式）
5. 导航状态变为"进行中"
6. ✅ 事件触发

不触发场景:
- 用户点击后取消
- 地图初始化失败
- GPS 权限被拒绝且未开启模拟模式
```

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `route_id` | String | 是 | 路线唯一标识 | `"R001"` |
| `route_name` | String | 是 | 路线名称 | `"九溪十八涧"` |
| `route_distance_m` | Number | 是 | 路线距离(米) | `5600` |
| `route_duration_min` | Number | 是 | 预计耗时(分钟) | `150` |
| `difficulty` | String | 是 | 难度等级 | `"easy"` / `"medium"` / `"hard"` |
| `start_type` | String | 是 | 启动方式 | 见下方枚举 |
| `location_enabled` | Boolean | 是 | 是否启用真实定位 | `true` |
| `location_accuracy_m` | Number | 否 | 启动时定位精度 | `5.2` |
| `offline_mode` | Boolean | 是 | 是否离线模式 | `false` |
| `voice_enabled` | Boolean | 是 | 是否开启语音播报 | `true` |
| `start_timestamp` | Number | 是 | 启动时间戳 | `1709059200000` |

#### 枚举值定义

**start_type (启动方式)**
| 值 | 说明 |
|----|------|
| `normal` | 正常启动（从路线详情页） |
| `resume` | 恢复未完成的导航 |
| `reroute` | 偏航后重新规划 |
| `quick` | 快捷启动（从收藏/历史） |

**difficulty (难度等级)**
| 值 | 说明 |
|----|------|
| `easy` | 休闲 |
| `medium` | 适中 |
| `hard` | 挑战 |

#### 代码实现示例

```dart
// lib/screens/navigation_screen.dart

class _NavigationScreenState extends State<NavigationScreen> {
  @override
  void initState() {
    super.initState();
    _initializeNavigation();
  }
  
  Future<void> _initializeNavigation() async {
    // 初始化地图
    await _initMap();
    
    // 获取定位
    final position = await _initLocation();
    
    // 设置导航状态
    setState(() {
      _navigationState = NavigationState.active;
    });
    
    // ✅ 埋点上报
    Analytics.track('navigation_start', {
      'route_id': widget.routeId,
      'route_name': widget.routeName,
      'route_distance_m': widget.routeDistance,
      'route_duration_min': widget.routeDuration,
      'difficulty': widget.difficulty,
      'start_type': widget.startType,
      'location_enabled': _useRealLocation,
      'location_accuracy_m': position?.accuracy,
      'offline_mode': _isOfflineMode,
      'voice_enabled': _voiceEnabled,
      'start_timestamp': DateTime.now().millisecondsSinceEpoch,
    });
    
    // 开始语音播报
    if (_voiceEnabled) {
      _speak('导航开始，全程${widget.routeDistance}米，预计${widget.routeDuration}分钟');
    }
  }
}
```

---

### 2.4 路线完成事件 (trail_complete)

#### 事件定义

| 属性 | 值 |
|------|-----|
| **事件名** | `trail_complete` |
| **事件类型** | 功能埋点 |
| **触发时机** | 用户到达路线终点，导航自动结束或手动确认完成 |
| **事件级别** | P0 - 必须实施 |

#### 触发时机详解

```
触发流程:
场景 A - 自动完成:
1. 用户距离终点 < 50 米
2. 显示"即将到达终点"提示
3. 用户进入终点 20 米范围
4. 导航自动结束
5. ✅ 事件触发

场景 B - 手动完成:
1. 用户在导航中点击"结束导航"
2. 弹出确认对话框
3. 用户确认"已完成"
4. ✅ 事件触发

场景 C - 强行结束:
1. 用户点击"结束导航"
2. 选择"放弃导航"
3. ❌ 不触发 complete，触发 cancel 事件
```

#### 事件参数

| 参数名 | 类型 | 必填 | 说明 | 示例 |
|--------|------|------|------|------|
| `route_id` | String | 是 | 路线唯一标识 | `"R001"` |
| `route_name` | String | 是 | 路线名称 | `"九溪十八涧"` |
| `completion_type` | String | 是 | 完成类型 | 见下方枚举 |
| `actual_distance_m` | Number | 是 | 实际行走距离(米) | `5800` |
| `actual_duration_sec` | Number | 是 | 实际耗时(秒) | `7200` |
| `planned_distance_m` | Number | 是 | 计划距离(米) | `5600` |
| `planned_duration_min` | Number | 是 | 计划耗时(分钟) | `150` |
| `deviation_count` | Number | 是 | 偏航次数 | `2` |
| `avg_speed_ms` | Number | 是 | 平均速度(米/秒) | `0.81` |
| `pause_count` | Number | 否 | 暂停次数 | `3` |
| `pause_duration_sec` | Number | 否 | 暂停总时长(秒) | `600` |
| `photo_count` | Number | 否 | 拍照数量 | `15` |
| `completion_timestamp` | Number | 是 | 完成时间戳 | `1709059200000` |
| `rating` | Number | 否 | 用户评分(1-5) | `5` |

#### 枚举值定义

**completion_type (完成类型)**
| 值 | 说明 |
|----|------|
| `auto` | 自动到达终点完成 |
| `manual` | 手动确认完成 |
| `checkpoint` | 到达打卡点完成（分段路线） |

#### 代码实现示例

```dart
// lib/screens/navigation_screen.dart

class _NavigationScreenState extends State<NavigationScreen> {
  // 导航统计
  int _deviationCount = 0;
  int _pauseCount = 0;
  int _pauseDurationSec = 0;
  int _photoCount = 0;
  double _totalDistance = 0;
  DateTime? _navigationStartTime;
  DateTime? _lastPauseTime;
  
  void _onNavigationComplete({required bool autoComplete}) {
    final completionTime = DateTime.now();
    final actualDuration = completionTime.difference(_navigationStartTime!).inSeconds;
    final avgSpeed = _totalDistance / actualDuration;
    
    // ✅ 埋点上报
    Analytics.track('trail_complete', {
      'route_id': widget.routeId,
      'route_name': widget.routeName,
      'completion_type': autoComplete ? 'auto' : 'manual',
      'actual_distance_m': _totalDistance.round(),
      'actual_duration_sec': actualDuration,
      'planned_distance_m': widget.routeDistance,
      'planned_duration_min': widget.routeDuration,
      'deviation_count': _deviationCount,
      'avg_speed_ms': double.parse(avgSpeed.toStringAsFixed(2)),
      'pause_count': _pauseCount,
      'pause_duration_sec': _pauseDurationSec,
      'photo_count': _photoCount,
      'completion_timestamp': completionTime.millisecondsSinceEpoch,
    });
    
    // 显示完成页面
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => TrailCompleteScreen(
          routeId: widget.routeId,
          stats: {
            'distance': _totalDistance,
            'duration': actualDuration,
            'deviations': _deviationCount,
          },
        ),
      ),
    );
  }
  
  void _onDeviationDetected() {
    _deviationCount++;
    // 上报偏航事件
    Analytics.track('navigation_deviation', {
      'route_id': widget.routeId,
      'deviation_count': _deviationCount,
      'location': _currentLocation,
    });
  }
  
  void _onPause() {
    _pauseCount++;
    _lastPauseTime = DateTime.now();
  }
  
  void _onResume() {
    if (_lastPauseTime != null) {
      _pauseDurationSec += DateTime.now().difference(_lastPauseTime!).inSeconds;
    }
  }
  
  void _onPhotoTaken() {
    _photoCount++;
  }
}
```

---

## 2.5 失败场景埋点处理规范 ⭐新增 (v1.2.1)

### 2.5.1 网络失败时的埋点行为

#### 场景描述
当设备处于弱网或断网状态时，埋点数据需要可靠保存并在网络恢复后上报。

#### 处理规范

```dart
// lib/services/analytics_service.dart

class AnalyticsService {
  static final List<Map<String, dynamic>> _pendingEvents = [];
  static const int MAX_RETRY_COUNT = 5;
  static const int MAX_CACHE_SIZE = 50;
  
  /// 网络失败时的埋点处理
  static Future<void> trackWithNetworkRetry(
    String eventName, 
    Map<String, dynamic> params
  ) async {
    final event = {
      'event_name': eventName,
      'params': params,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'retry_count': 0,
    };
    
    try {
      // 尝试立即上报
      await _sendToServer(event);
    } catch (e) {
      // 网络失败，缓存到本地
      if (_pendingEvents.length >= MAX_CACHE_SIZE) {
        // 缓存满时，移除最旧的数据
        _pendingEvents.removeAt(0);
      }
      _pendingEvents.add(event);
      
      // 上报缓存失败事件
      await _sendToServer({
        'event_name': 'analytics_cache_stored',
        'params': {
          'original_event': eventName,
          'cache_size': _pendingEvents.length,
          'fail_reason': e.toString(),
        },
      });
    }
  }
  
  /// 网络恢复后批量上报
  static Future<void> flushPendingEvents() async {
    if (_pendingEvents.isEmpty) return;
    
    final List<Map<String, dynamic>> failedEvents = [];
    
    for (final event in _pendingEvents) {
      try {
        await _sendToServer(event);
      } catch (e) {
        event['retry_count'] = (event['retry_count'] ?? 0) + 1;
        
        if (event['retry_count'] < MAX_RETRY_COUNT) {
          // 未达到最大重试次数，保留
          failedEvents.add(event);
        } else {
          // 超过最大重试次数，上报丢弃事件
          await _sendToServer({
            'event_name': 'analytics_event_dropped',
            'params': {
              'original_event': event['event_name'],
              'retry_count': event['retry_count'],
              'final_error': e.toString(),
            },
          });
        }
      }
    }
    
    _pendingEvents.clear();
    _pendingEvents.addAll(failedEvents);
  }
  
  static Future<void> _sendToServer(Map<String, dynamic> event) async {
    // 实际的上报逻辑
    // 超时设置为10秒
  }
}
```

#### 相关埋点事件

| 事件名 | 触发时机 | 参数 | 说明 |
|--------|---------|------|------|
| `analytics_cache_stored` | 埋点因网络失败缓存时 | `original_event`, `cache_size`, `fail_reason` | 用于监控网络失败率 |
| `analytics_batch_sent` | 批量上报成功时 | `event_count`, `pending_count` | 用于监控恢复上报效率 |
| `analytics_event_dropped` | 超过最大重试次数丢弃时 | `original_event`, `retry_count` | 用于监控数据丢失率 |

---

### 2.5.2 用户取消分享/SOS时的埋点

#### 场景描述
用户在分享面板或SOS倒计时期间取消操作，需要记录取消行为用于漏斗分析。

#### 分享取消埋点

```dart
// lib/widgets/share_poster.dart

void _onShareCancelled(String stage, String reason) {
  // stage: 'template_select', 'channel_select', 'generation', 'confirm'
  // reason: 'user_cancel', 'back_pressed', 'outside_tap'
  
  Analytics.track('share_cancel', {
    'route_id': widget.routeId,
    'route_name': widget.routeName,
    'cancel_stage': stage,      // 用户在哪个阶段取消
    'cancel_reason': reason,    // 取消原因
    'time_spent_ms': DateTime.now().difference(_openTime).inMilliseconds,
    'template_previewed': _previewedTemplates.length,
  });
}
```

**分享取消事件参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `route_id` | String | 是 | 路线ID |
| `route_name` | String | 是 | 路线名称 |
| `cancel_stage` | String | 是 | 取消阶段：`template_select`/`channel_select`/`generation`/`confirm` |
| `cancel_reason` | String | 是 | 取消原因：`user_cancel`/`back_pressed`/`outside_tap` |
| `time_spent_ms` | Number | 是 | 分享面板打开时长 |
| `template_previewed` | Number | 否 | 预览过的模板数量 |

#### SOS取消埋点

```dart
// lib/services/sos_service.dart

void _onSOSCancelled(String stage, String reason) {
  // stage: 'button_click', 'countdown', 'confirm_dialog'
  // reason: 'user_cancel', 'countdown_interrupted', 'back_pressed'
  
  Analytics.track('sos_cancel', {
    'trigger_stage': stage,     // 在哪个阶段取消
    'cancel_reason': reason,    // 取消原因
    'countdown_remaining_sec': _remainingSeconds,
    'location_lat': _currentLocation?.latitude,
    'location_lng': _currentLocation?.longitude,
    'time_since_open_ms': DateTime.now().difference(_sosOpenTime).inMilliseconds,
  });
}
```

**SOS取消事件参数**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `trigger_stage` | String | 是 | 取消阶段：`button_click`/`countdown`/`confirm_dialog` |
| `cancel_reason` | String | 是 | 取消原因：`user_cancel`/`countdown_interrupted`/`back_pressed` |
| `countdown_remaining_sec` | Number | 是 | 倒计时剩余秒数 |
| `location_lat` | Number | 否 | 取消时纬度 |
| `location_lng` | Number | 否 | 取消时经度 |
| `time_since_open_ms` | Number | 是 | SOS页面打开时长 |

---

### 2.5.3 API失败时的埋点处理

#### 场景描述
SOS、分享等功能的后端API调用失败时，需要记录失败信息用于问题排查。

#### API失败埋点规范

```dart
// lib/services/api_tracker.dart

class APITracker {
  static void trackAPIFailure({
    required String api_name,
    required String error_type,
    required int http_status,
    required String error_message,
    required int response_time_ms,
    Map<String, dynamic>? extra_params,
  }) {
    Analytics.track('api_request_failed', {
      'api_name': api_name,
      'error_type': error_type,           // timeout, network_error, server_error, client_error
      'http_status': http_status,         // 0表示无响应
      'error_message': error_message,
      'response_time_ms': response_time_ms,
      'network_type': _getNetworkType(),  // wifi, 4g, 3g, 2g, none
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      ...?extra_params,
    });
  }
}

// SOS API失败示例
try {
  final response = await http.post(
    Uri.parse('${Config.apiBaseUrl}/sos/trigger'),
    body: {...},
  ).timeout(Duration(seconds: 10));
  
  if (response.statusCode != 200) {
    throw Exception('Server error: ${response.statusCode}');
  }
} on TimeoutException catch (e) {
  APITracker.trackAPIFailure(
    api_name: 'sos_trigger',
    error_type: 'timeout',
    http_status: 0,
    error_message: e.toString(),
    response_time_ms: 10000,
    extra_params: {'route_id': routeId},
  );
} on SocketException catch (e) {
  APITracker.trackAPIFailure(
    api_name: 'sos_trigger',
    error_type: 'network_error',
    http_status: 0,
    error_message: e.toString(),
    response_time_ms: DateTime.now().difference(startTime).inMilliseconds,
  );
} catch (e) {
  APITracker.trackAPIFailure(
    api_name: 'sos_trigger',
    error_type: 'unknown',
    http_status: 0,
    error_message: e.toString(),
    response_time_ms: DateTime.now().difference(startTime).inMilliseconds,
  );
}
```

#### API失败事件参数

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| `api_name` | String | 是 | API名称：sos_trigger/share_generate等 |
| `error_type` | String | 是 | 错误类型：timeout/network_error/server_error/client_error |
| `http_status` | Number | 是 | HTTP状态码，0表示无响应 |
| `error_message` | String | 是 | 错误详情 |
| `response_time_ms` | Number | 是 | 请求耗时 |
| `network_type` | String | 是 | 网络类型：wifi/4g/3g/2g/none |
| `timestamp` | Number | 是 | 失败时间戳 |

#### 指数退避重试策略

```dart
class RetryPolicy {
  static const List<int> RETRY_DELAYS = [1000, 2000, 4000, 8000, 16000]; // 毫秒
  
  static Future<T> retryWithBackoff<T>({
    required Future<T> Function() operation,
    required String apiName,
    int maxRetries = 5,
  }) async {
    int attempt = 0;
    
    while (attempt < maxRetries) {
      try {
        final startTime = DateTime.now();
        final result = await operation();
        
        // 成功埋点
        Analytics.track('api_request_success', {
          'api_name': apiName,
          'attempt_count': attempt + 1,
          'response_time_ms': DateTime.now().difference(startTime).inMilliseconds,
        });
        
        return result;
      } catch (e) {
        attempt++;
        
        if (attempt >= maxRetries) {
          // 最终失败埋点
          Analytics.track('api_request_final_failed', {
            'api_name': apiName,
            'total_attempts': attempt,
            'final_error': e.toString(),
          });
          rethrow;
        }
        
        // 等待后重试
        await Future.delayed(Duration(milliseconds: RETRY_DELAYS[attempt - 1]));
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
```

---

## 3. 实施检查清单

### 3.1 开发前准备

| 检查项 | 状态 | 备注 |
|--------|------|------|
| [ ] 确认 Analytics SDK 已集成 | ⬜ | 基于现有 analytics.dart |
| [ ] 确认事件上报通道正常 | ⬜ | 测试环境验证 |
| [ ] 确认数据格式符合规范 | ⬜ | 对照本文档 |
| [ ] 确认隐私合规 | ⬜ | 位置信息脱敏处理 |

### 3.2 开发检查清单

| 事件 | 触发时机确认 | 参数完整 | 测试通过 | 备注 |
|------|-------------|---------|---------|------|
| share_trail | ⬜ | ⬜ | ⬜ | 分享成功回调中 |
| sos_trigger | ⬜ | ⬜ | ⬜ | API 成功后 |
| navigation_start | ⬜ | ⬜ | ⬜ | 导航初始化完成后 |
| trail_complete | ⬜ | ⬜ | ⬜ | 到达终点或手动确认 |

### 3.3 测试验证要点

| 验证项 | 验证方法 |
|--------|---------|
| 事件触发时机 | 日志输出确认 |
| 参数值正确性 | 断点检查 |
| 数据上报成功 | 抓包或后端日志 |
| 异常场景处理 | 模拟网络失败/取消操作 |
| 性能影响 | 埋点前后 FPS 对比 |

---

## 4. 数据使用指南

### 4.1 核心指标定义

| 指标 | 计算方式 | 业务意义 |
|------|---------|---------|
| **分享转化率** | share_trail / 路线详情页浏览 | 内容传播能力 |
| **SOS 触发率** | sos_trigger / navigation_start | 安全功能使用情况 |
| **导航完成率** | trail_complete / navigation_start | 核心功能使用质量 |
| **平均完成偏差** | trail_complete.actual_distance / planned_distance | 路线准确性 |
| **用户留存** | 次日再次 navigation_start | 产品粘性 |

### 4.2 分析场景建议

| 分析场景 | 涉及事件 | 分析维度 |
|---------|---------|---------|
| 用户活跃度 | navigation_start, trail_complete | 日/周/月活跃用户数 |
| 功能健康度 | share_trail, sos_trigger | 功能使用频率、成功率 |
| 路线质量 | trail_complete | 完成率、偏差率、评分分布 |
| 用户分群 | 所有事件 | 高频用户、低频用户、流失预警 |

---

## 5. 附录

### 5.1 完整事件索引

| 事件名 | 类型 | 优先级 | 状态 |
|--------|------|--------|------|
| page_view | 页面 | P0 | ✅ 已实施 |
| page_exit | 页面 | P0 | ✅ 已实施 |
| button_click | 点击 | P0 | ✅ 已实施 |
| feature_use | 功能 | P0 | ✅ 已实施 |
| login_success | 功能 | P0 | ✅ 已实施 |
| login_fail | 功能 | P0 | ✅ 已实施 |
| **share_trail** | 功能 | **P0** | **⏳ 待实施** |
| **share_cancel** | 功能 | **P0** | **⏳ 待实施** |
| **sos_trigger** | 功能 | **P0** | **⏳ 待实施** |
| **sos_cancel** | 功能 | **P0** | **⏳ 待实施** |
| **navigation_start** | 功能 | **P0** | **⏳ 待实施** |
| **trail_complete** | 功能 | **P0** | **⏳ 待实施** |
| analytics_cache_stored | 技术 | P1 | ⬜ 未开始 |
| analytics_batch_sent | 技术 | P1 | ⬜ 未开始 |
| analytics_event_dropped | 技术 | P1 | ⬜ 未开始 |
| api_request_failed | 技术 | P1 | ⬜ 未开始 |
| api_request_success | 技术 | P1 | ⬜ 未开始 |
| api_request_final_failed | 技术 | P1 | ⬜ 未开始 |
| trip_shared | 功能 | P1 | ⬜ 未开始 |
| elevation_viewed | 点击 | P1 | ⬜ 未开始 |
| poi_clicked | 点击 | P1 | ⬜ 未开始 |

### 5.2 相关文档

| 文档 | 路径 |
|------|------|
| 埋点规范 v1.0 | data-tracking-spec-v1.0.md |
| 埋点规范 v1.1 | data-tracking-spec-v1.1.md |
| M4 功能规划 | M4-FEATURE-PLAN.md |
| 分析工具接入 | 待补充 |

### 5.3 变更记录

| 版本 | 日期 | 变更内容 |
|------|------|---------|
| v1.2.1 | 2026-03-19 | 新增失败场景埋点处理规范（网络失败、取消操作、API失败、指数退避重试） |
| v1.2 | 2026-03-19 | 确认 4 个待实施事件的触发时机、参数格式、代码示例 |

---

> **文档编写**: Product Agent  
> **评审待办**: Dev Agent（确认技术可行性）、QA Agent（确认测试方案）
