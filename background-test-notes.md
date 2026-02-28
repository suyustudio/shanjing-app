# Week 5 Day 5 - 后台保活测试准备

## 1. background_locator 配置检查

### 当前状态
- 技术调研已完成（见 `tech-verify-gps-background.md`）
- 尚未集成到主项目

### 配置要点

#### Android 权限（已配置在 flutter-amap-config）
```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

#### iOS 权限说明（已配置）
- `NSLocationWhenInUseUsageDescription` - 前台定位
- `NSLocationAlwaysUsageDescription` - 后台持续定位
- `NSLocationAlwaysAndWhenInUseUsageDescription` - 组合权限

---

## 2. 后台定位权限说明

### Android
| 权限 | 用途 | 用户提示 |
|------|------|----------|
| `ACCESS_FINE_LOCATION` | 精确定位 | 需要导航精度 |
| `ACCESS_BACKGROUND_LOCATION` | 后台定位 | 锁屏后仍追踪轨迹 |
| `POST_NOTIFICATIONS` | 前台服务通知 | 显示导航状态 |

### iOS
| 权限 | 用途 |
|------|------|
| When In Use | 前台导航 |
| Always | 后台轨迹记录 |

### 权限申请流程
1. 首次启动 → 申请前台定位
2. 开始导航 → 申请后台定位
3. 用户拒绝后台 → 降级为前台导航

---

## 3. 保活测试要点

### 测试场景
- [ ] 前台导航正常定位
- [ ] 按 Home 键进入后台 → 定位持续
- [ ] 锁屏 → 定位持续
- [ ] 杀掉 App → 定位是否继续（background_locator 特性）
- [ ] 设备重启 → 服务是否自动恢复
- [ ] 低电量模式 → 定位频率变化

### 测试指标
| 指标 | 目标值 |
|------|--------|
| 后台定位频率 | 每 3-5 秒 |
| 轨迹断点率 | < 5% |
| 电量消耗 | 每小时 < 10% |

### 测试设备
- Android 12+（小米/华为/OPPO）
- iOS 16+

### 常见问题
1. 国产 ROM 杀后台 → 需引导用户设置电池白名单
2. iOS 权限被拒 → 提供降级方案（仅前台导航）

---

## 4. 待办

- [ ] 集成 background_locator 到主项目
- [ ] 配置后台服务回调
- [ ] 编写保活测试用例
- [ ] 实际设备测试
