# Flutter 微信登录模块调研

## 一、插件对比

| 插件 | Stars | 维护状态 | 功能 | 推荐 |
|------|-------|----------|------|------|
| **fluwx** | 3.3k | 活跃 | 登录、分享、支付、小程序 | ⭐ 首选 |
| **wechat_kit** | 774 | 一般 | 登录、分享、支付 | 备选 |

### 选择建议
- **fluwx**：社区活跃、文档完善、功能全面、支持鸿蒙
- **wechat_kit**：轻量、配置简单、适合仅需基础功能

---

## 二、fluwx 集成步骤

### 1. 添加依赖
```yaml
dependencies:
  fluwx: ^4.5.5  # 最新版

fluwx:
  app_id: wx你的AppID
  universal_link: https://your.domain.com/link/
  debug_logging: true
```

### 2. iOS 配置
```xml
<!-- Info.plist -->
<key>LSApplicationQueriesSchemes</key>
<array>
    <string>weixin</string>
    <string>weixinULAPI</string>
    <string>weixinURLParamsAPI</string>
</array>

<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLName</key>
    <string>weixin</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>wx你的AppID</string>
    </array>
  </dict>
</array>
```

### 3. Android 配置
- 无需额外配置
- 需在微信开放平台注册应用签名(MD5)

### 4. 初始化
```dart
import 'package:fluwx/fluwx.dart';

final fluwx = Fluwx();
await fluwx.registerApi(
  appId: "wx你的AppID",
  universalLink: "https://your.domain.com/link/",
);
```

### 5. 登录调用
```dart
// 发起登录
await fluwx.authBy(which: NormalAuth);

// 监听回调
fluwx.addSubscriber((response) {
  if (response is WeChatAuthResponse) {
    // 获取 code，传给后端换取 access_token
    final code = response.code;
  }
});
```

---

## 三、wechat_kit 集成步骤

### 1. 添加依赖
```yaml
dependencies:
  wechat_kit: ^3.2.0

wechat_kit:
  app_id: wx你的AppID
  universal_link: https://your.domain.com/universal_link/app/wechat/
```

### 2. 初始化
```dart
import 'package:wechat_kit/wechat_kit.dart';

final wechat = WechatKit();
await wechat.registerApp(
  appId: "wx你的AppID",
  universalLink: "https://your.domain.com/universal_link/app/wechat/",
);
```

### 3. 登录调用
```dart
// 发起登录
await wechat.auth(scope: <String>[WechatScope.SNSAPI_USERINFO]);

// 监听回调
wechat.authResp().listen((WechatAuthResp resp) {
  // 获取 code
  final code = resp.code;
});
```

---

## 四、注意事项

### 通用
1. **必须先注册微信开放平台账号**，获取 AppID
2. **iOS 必须配置 Universal Links**，且域名需备案
3. **Android 必须配置应用签名**，debug 和 release 签名不同
4. **真机测试**，模拟器无法调起微信

### iOS 特别注意
- 配置 Associated Domains
- 上传 apple-app-site-association 文件到服务器
- 路径格式：`/universal_link/{app}/wechat/*`

### Android 特别注意
- debug 模式使用 debug.keystore，需在微信后台添加 debug 签名
- 4.5.0+ 版本 fluwx 不再自动申请存储权限，分享图片需自行处理

### 常见问题
| 问题 | 解决 |
|------|------|
| errCode = -1 | 检查 AppID、签名、Universal Link |
| 无法调起微信 | 检查 URL Scheme、白名单配置 |
| 回调不执行 | 检查 AppDelegate 是否转发事件 |

---

## 五、推荐方案

**使用 fluwx**：
- 社区更活跃，问题修复快
- 支持鸿蒙系统
- 文档更完善
- 功能更全面（支付、小程序等）

**参考文档**：
- fluwx: https://github.com/OpenFlutter/fluwx
- wechat_kit: https://github.com/rxreader/wechat_kit
- 微信开放平台: https://open.weixin.qq.com/
