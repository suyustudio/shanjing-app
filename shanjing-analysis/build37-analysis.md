# Build #37 APK 深度分析报告

**分析时间**: 2026-03-04 14:30  
**APK 版本**: v1.0.0+1 (Build #37)  
**APK 大小**: 20.2 MB  
**分析工具**: aapt, apktool, strings, keytool

---

## 执行摘要

Build #37 APK 构建成功但运行时白屏/黑屏，进程在后台存在但界面无法显示。经过深度分析，发现 **2个 P0 阻塞性问题** 和 **2个 P1 问题**。

---

## 发现的问题

### P0 阻塞性问题（必须修复）

#### 1. 缺少高德地图 SO 库
**严重程度**: 🔴 阻塞性  
**影响**: 高德地图 SDK 无法加载，导致 Flutter 插件初始化失败

**证据**:
```
# APK 中的 SO 库只有 Flutter 的
lib/arm64-v8a/libapp.so
lib/arm64-v8a/libflutter.so

# 缺少高德地图 SO 库
# 应有: libAMapSDK_MAP_v*.so, libAMapSDK_NAVI_v*.so 等
```

**根本原因**: 
- `flutter create` 生成的项目没有自动包含高德地图 SDK 的原生库
- 需要通过 Gradle 依赖显式添加

**修复方案**:
在 `android/app/build.gradle` 中添加:
```gradle
dependencies {
    compile "com.amap.api:navi-3dmap:latest.integration"
    compile "com.amap.api:search:latest.integration"
    compile "com.amap.api:location:latest.integration"
}
```

---

#### 2. `.env` 文件中的高德 Key 是占位符
**严重程度**: 🔴 阻塞性  
**影响**: 高德地图 SDK 初始化时使用错误的 Key，导致认证失败

**证据**:
```
# assets/flutter_assets/.env
AMAP_KEY=your_amap_key_here
```

**注意**: 
- AndroidManifest.xml 中硬编码了正确的 Key
- 但代码中可能从 `.env` 文件读取 Key
- 两者不一致可能导致 SDK 初始化失败

**修复方案**:
在 GitHub Actions 工作流中添加:
```yaml
- name: Setup .env
  run: |
    echo "AMAP_KEY=${{ secrets.AMAP_KEY }}" > .env
```

---

### P1 重要问题

#### 3. Debug 签名（SHA1 已标记为 weak）
**严重程度**: 🟡 重要  
**影响**: 安全警告，可能影响某些设备的安装

**证据**:
```
Owner: C=US, O=Android, CN=Android Debug
Signature algorithm name: SHA1withRSA (weak)
```

**修复方案**:
- 使用 Release 签名配置
- 或配置 GitHub Actions 使用正确的签名密钥

---

#### 4. 启动背景极简
**严重程度**: 🟡 重要  
**影响**: 用户体验（启动时白屏感）

**证据**:
```xml
<!-- res/drawable/launch_background.xml -->
<?xml version="1.0" encoding="utf-8"?>
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="?android:colorBackground" />
</layer-list>
```

**修复方案**:
添加自定义启动 Logo:
```xml
<layer-list xmlns:android="http://schemas.android.com/apk/res/android">
    <item android:drawable="@android:color/white" />
    <item>
        <bitmap android:src="@drawable/splash_logo" android:gravity="center" />
    </item>
</layer-list>
```

---

## 正常工作的部分

| 组件 | 状态 | 说明 |
|------|------|------|
| AndroidManifest.xml | ✅ | 权限、主题、flutterEmbedding V2 配置正确 |
| MainActivity | ✅ | 继承 FlutterActivity，代码正确 |
| 主题配置 | ✅ | LaunchTheme/NormalTheme 配置正确 |
| Flutter 引擎 | ✅ | libflutter.so + libapp.so 完整 |
| 插件注册 | ✅ | GeneratedPluginRegistrant 正常，有异常处理 |
| 路线数据 | ✅ | 10条路线数据完整（trails-all.json） |
| 高德 smali 类 | ✅ | com/amap/flutter/map/ 下的类都存在 |
| APK 签名 | ✅ | 已签名（虽然是 Debug） |

---

## 问题影响分析

### 为什么白屏？

**场景 1: 高德 SO 库缺失**
1. Flutter 引擎正常启动
2. 高德地图插件初始化
3. 尝试加载 `libAMapSDK_MAP_v*.so`
4. SO 库不存在 → `UnsatisfiedLinkError`
5. 异常被捕获，但 Flutter 界面可能无法正常渲染

**场景 2: Key 错误**
1. 高德地图 SDK 初始化
2. 使用 `.env` 中的错误 Key `your_amap_key_here`
3. 高德服务器认证失败
4. SDK 初始化失败，Flutter 界面卡住

**两种场景都可能导致：**
- 进程在后台存在
- 界面无法显示（白屏/黑屏）
- 应用无响应

---

## 修复优先级

### 立即修复（Build #40 或 #41）
1. [ ] 添加高德地图 SDK Gradle 依赖
2. [ ] 修复 `.env` 文件中的 Key

### 尽快修复（Build #42）
3. [ ] 使用 Release 签名
4. [ ] 添加自定义启动画面

---

## 测试验证清单

修复后需要验证：

| 验证项 | 方法 |
|--------|------|
| SO 库存在 | `unzip -l app.apk \| grep "libAMapSDK"` |
| Key 正确 | 检查 `.env` 文件内容 |
| 启动正常 | 真机测试，3秒内显示首页 |
| 地图加载 | 检查地图是否显示，标记点是否正确 |
| 定位功能 | 检查 GPS 定位是否可用 |

---

## 相关文件

| 文件 | 路径 |
|------|------|
| 分析报告 | `shanjing-analysis/build37-analysis.md` |
| 反编译代码 | `shanjing-analysis/build37-decompiled/` |
| APK 文件 | `shanjing-analysis/build37.apk` |

---

## 附录：分析命令

```bash
# APK 基本信息
aapt dump badging build37.apk

# AndroidManifest.xml
aapt dump xmltree build37.apk AndroidManifest.xml

# 反编译 APK
apktool d -f build37.apk -o build37-decompiled

# 检查 SO 库
unzip -l build37.apk | grep "\.so$"

# 检查签名
unzip -p build37.apk META-INF/CERT.RSA | keytool -printcert -v
```

---

**分析完成时间**: 2026-03-04 14:35  
**分析师**: Dev Agent (APK 深度分析)
