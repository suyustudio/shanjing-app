# 高德 SDK 开发者账号申请信息

## 应用信息

| 项目 | 内容 |
|------|------|
| 应用名称 | 山径 |
| 包名 | com.shanjing.app |

## 调试版 SHA1 获取命令

```bash
# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Windows
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 申请步骤清单

1. **注册账号** → 访问 [高德开放平台](https://lbs.amap.com/) → 点击右上角「注册」
2. **实名认证** → 登录后进入控制台 → 完成个人/企业实名认证
3. **创建应用** → 应用管理 → 创建新应用 → 填写应用名称「山径」
4. **添加 Key** → 在应用下添加 Key → 选择「Android 平台 SDK」
5. **填写信息** → 输入包名 `com.shanjing.app` 和 SHA1 指纹
6. **获取 Key** → 提交后获得 AppKey，用于项目配置

## 后续配置

在 `android/app/src/main/AndroidManifest.xml` 中添加：

```xml
<meta-data
    android:name="com.amap.api.v2.apikey"
    android:value="你的 AppKey" />
```

---
*生成时间: 2026-02-28*
