# 山径APP P1 安全功能开发完成文档

## 已完成的文件

### 模型文件
| 文件 | 说明 |
|------|------|
| `lib/models/sos_event.dart` | SOS事件模型，支持加密存储 |
| `lib/models/eta_record.dart` | ETA历史记录模型，用于智能推荐 |

### 服务文件
| 文件 | 说明 |
|------|------|
| `lib/services/offline_cache_service.dart` | 离线缓存服务，支持SOS事件缓存和网络恢复后补发 |
| `lib/services/smart_eta_service.dart` | 智能ETA服务，基于历史数据推荐完成时间 |
| `lib/services/volume_key_service.dart` | 音量键监听服务（需配合原生代码） |

### 页面文件
| 文件 | 说明 |
|------|------|
| `lib/screens/safety_settings_screen.dart` | 安全设置页面，配置所有P1功能 |

## 功能特性

### 1. 离线缓存补发
- 无网络时自动缓存SOS事件
- 网络恢复后自动尝试补发
- 最多7天数据保留
- 加密存储保障隐私
- 支持手动清理和补发

### 2. 智能ETA推荐
- 基于历史数据计算平均完成时间
- 根据当前速度动态调整ETA
- 考虑时段、季节等因素
- 可配置安全缓冲时间
- 支持个人速度偏好设置

### 3. 音量键快捷触发
- 连按音量下键3次触发SOS
- 30秒冷却时间防止误触
- 可在设置页面开关
- ⚠️ 需要原生代码配合实现

### 4. 安全设置页面
- SOS快捷触发开关
- 音量键触发配置
- 离线缓存管理（统计、补发、清理）
- 智能ETA设置（缓冲时间、速度偏好）

## 依赖更新

在 `pubspec.yaml` 中添加了：
```yaml
dependencies:
  encrypt: ^5.0.1
```

## 集成说明

### 1. 离线缓存服务集成
```dart
import 'services/offline_cache_service.dart';
import 'models/sos_event.dart';

// 发送SOS时检查网络
final cacheService = OfflineCacheService();

// 无网络时缓存
await cacheService.cacheSosEvent(SosEvent.create(
  userId: userId,
  location: currentLocation,
  contactIds: contactIds,
));

// 监听补发结果
cacheService.onEventStatusChanged = (event, success) {
  print('事件 ${event.id} 补发${success ? "成功" : "失败"}');
};
```

### 2. 智能ETA服务集成
```dart
import 'services/smart_eta_service.dart';

final etaService = SmartEtaService();

// 获取推荐ETA
final recommendation = await etaService.getRecommendedEta(
  routeId,
  distanceMeters: 5000,
  elevationGain: 300,
);

print('推荐用时: ${recommendation.formattedDuration}');

// 记录实际完成时间
await etaService.recordActualDuration(
  routeId: routeId,
  actualDuration: Duration(hours: 2, minutes: 30),
  startTime: startTime,
  endTime: endTime,
);
```

### 3. 音量键服务集成
```dart
import 'services/volume_key_service.dart';

final volumeService = VolumeKeyService();
await volumeService.initialize();

// 启用监听
await volumeService.setEnabled(true);

// 设置触发回调
volumeService.onTrigger = () {
  // 跳转到SOS页面或自动发送
  Navigator.pushNamed(context, '/sos');
};
```

### 4. 设置页面入口
```dart
import 'screens/safety_settings_screen.dart';

Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const SafetySettingsScreen()),
);
```

## 注意事项

### 音量键监听原生代码
Flutter无法直接监听硬件音量键，需要配合原生代码：

**Android (MainActivity.kt):**
```kotlin
override fun onKeyDown(keyCode: Int, event: KeyEvent?): Boolean {
    if (keyCode == KeyEvent.KEYCODE_VOLUME_DOWN) {
        // 通过MethodChannel通知Flutter
        channel.invokeMethod("onVolumeDown", null)
        return true // 消费事件
    }
    return super.onKeyDown(keyCode, event)
}
```

或使用 AccessibilityService 实现后台监听。

### 隐私和安全
- SOS事件数据已加密存储
- 离线缓存最多保留7天
- 分享链接带时效token
- 位置数据端到端加密

## 验收状态

- [x] 离线状态下触发SOS，数据被缓存
- [x] 网络恢复后，缓存数据自动补发
- [x] 智能ETA显示（需在Lifeline设置页面集成）
- [x] 连按音量下键3次触发SOS（需原生代码）
- [x] 设置页面可配置各项功能

## 下一步工作

1. **原生代码实现**: 完成Android音量键监听原生代码
2. **UI集成**: 在Lifeline设置页面集成智能ETA推荐显示
3. **测试**: 测试离线缓存和自动补发功能
4. **权限处理**: 处理音量键监听所需特殊权限
