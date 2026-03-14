# iOS 离线地图测试计划

## iOS 现状

| 项目 | 状态 | 说明 |
|------|------|------|
| ios/ 目录 | ✅ 存在 | 基础目录结构已创建 |
| OfflineMapPlugin.swift | ✅ 已实现 | 完整的高德 SDK 桥接代码 |
| iOS 项目配置 | ⚠️ 不完整 | 缺少 AppDelegate.swift、Info.plist 等 |
| Podfile | ⚠️ 待配置 | 需添加高德 iOS SDK 依赖 |

## iOS 项目创建步骤

```bash
# 1. 创建完整 iOS 项目
flutter create --platforms ios .

# 2. 编辑 Podfile，添加高德 SDK
pod 'AMap3DMap'          # 3D 地图 SDK
pod 'AMapOfflineMap'     # 离线地图 SDK

# 3. 安装依赖
cd ios && pod install
```

## 高德 iOS SDK 集成步骤

| 步骤 | 操作 | 完成标准 |
|------|------|----------|
| 1 | 配置 API Key | Info.plist 添加 `AMapApiKey` |
| 2 | 配置权限 | 添加定位、存储权限描述 |
| 3 | 验证 SDK 初始化 | AppDelegate 中注册 API Key |
| 4 | 链接插件 | MainPluginRegistry 注册 OfflineMapPlugin |

## 测试检查项

| # | 检查项 | 完成标准 |
|---|--------|----------|
| 1 | 编译通过 | `flutter build ios --debug` 无错误 |
| 2 | 初始化成功 | `initialize()` 返回 true |
| 3 | 获取城市列表 | `getOfflineCityList()` 返回城市数据 |
| 4 | 下载离线包 | 北京市地图下载进度 0→100% |
| 5 | 进度事件 | EventChannel 收到实时进度更新 |
| 6 | 断网可用 | 关闭网络后地图正常显示 |
| 7 | 删除地图 | 调用删除后本地文件清理 |
| 8 | 存储统计 | 正确显示已用/剩余空间 |

## 风险评估

| 风险项 | 影响 | 说明 |
|--------|------|------|
| iOS SDK 差异 | 中 | 高德 iOS/Android API 略有不同 |
| 签名配置 | 低 | 需配置开发者证书才能真机测试 |
| 审核限制 | 低 | 离线地图功能无特殊审核风险 |

## 预计工作量

- iOS 项目配置：2h
- SDK 集成调试：4h
- 真机测试验证：4h
- **总计：10h**

## 建议优先级

**P2 - 次要优先级**

理由：
1. Android 端已完成并验证
2. 当前用户以 Android 为主
3. 功能风险低，可延后上线
