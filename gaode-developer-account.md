# 高德 SDK 开发者账号申请准备清单

## 基本信息

| 项目 | 说明 |
|------|------|
| **应用名称** | 您的应用显示名称（如：我的出行App） |
| **包名** | Android 应用唯一标识（如：com.example.myapp） |
| **SHA1 签名** | 应用签名证书的 SHA1 指纹 |

## 获取 SHA1 签名

### 调试版本
```bash
# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

# Windows
keytool -list -v -keystore %USERPROFILE%\.android\debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 发布版本
```bash
keytool -list -v -keystore <your_release_keystore>.jks -alias <your_alias>
```

## 申请地址

https://lbs.amap.com/dev/key/app

## 注意事项

1. 一个 Key 对应一个包名 + SHA1 组合
2. 调试和发布需要分别申请或使用同一个（推荐分开）
3. 申请后约 5-10 分钟生效
