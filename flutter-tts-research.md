# Flutter 语音播报调研 - flutter_tts

## 插件简介

**flutter_tts** 是 Flutter 官方推荐的文本转语音(TTS)插件，支持多平台：
- ✅ Android / iOS
- ✅ Web
- ✅ Windows / macOS

---

## 集成步骤

### 1. 添加依赖

```yaml
# pubspec.yaml
dependencies:
  flutter_tts: ^4.2.0
```

### 2. Android 配置

```gradle
// android/app/build.gradle
minSdkVersion 21
```

```xml
<!-- android/app/src/main/AndroidManifest.xml -->
<queries>
  <intent>
    <action android:name="android.intent.action.TTS_SERVICE" />
  </intent>
</queries>
```

### 3. iOS 配置

无需额外配置（可选：设置音频会话类别）。

---

## 基础使用

```dart
import 'package:flutter_tts/flutter_tts.dart';

// 初始化
final FlutterTts flutterTts = FlutterTts();

// 基础播报
await flutterTts.speak("你好，世界");

// 停止播报
await flutterTts.stop();

// 暂停（Android SDK 26+）
await flutterTts.pause();
```

---

## 常用设置

```dart
// 设置语言
await flutterTts.setLanguage("zh-CN");  // 中文
await flutterTts.setLanguage("en-US");  // 英文

// 设置语速 (0.0 - 1.0)
await flutterTts.setSpeechRate(0.5);

// 设置音量 (0.0 - 1.0)
await flutterTts.setVolume(1.0);

// 设置音调 (0.5 - 2.0)
await flutterTts.setPitch(1.0);
```

---

## 事件监听

```dart
flutterTts.setStartHandler(() {
  print("开始播报");
});

flutterTts.setCompletionHandler(() {
  print("播报完成");
});

flutterTts.setErrorHandler((msg) {
  print("错误: $msg");
});
```

---

## 获取可用语音

```dart
// 获取语言列表
List<dynamic> languages = await flutterTts.getLanguages;

// 获取语音列表
List<Map> voices = await flutterTts.getVoices;

// 设置指定语音
await flutterTts.setVoice({"name": "zh-CN", "locale": "zh-CN"});
```

---

## 总结

| 功能 | 支持情况 |
|------|----------|
| 基础播报 | ✅ 全平台 |
| 停止/暂停 | ✅ 全平台 |
| 语速/音量/音调 | ✅ 全平台 |
| 多语言 | ✅ 全平台 |
| 保存为文件 | ✅ iOS/macOS/Android |
| 进度回调 | ✅ iOS/Android/Web |

**推荐场景**：语音播报、阅读辅助、无障碍功能。
