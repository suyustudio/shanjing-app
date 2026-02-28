# 获取 SHA1 签名（无 Java 环境方案）

## 方案 1: 使用 Flutter 工具

```bash
# 进入你的 Flutter 项目目录
cd /path/to/shanjing_app

# 使用 Gradle 获取签名信息
./gradlew signingReport

# 或者在项目根目录运行
flutter build apk --debug
```

然后查看输出中的 `SHA1` 字段。

## 方案 2: 使用 Android Studio

1. 打开 Android Studio
2. 打开你的 Flutter 项目
3. 点击右侧 Gradle 面板
4. 展开 `android > app > Tasks > android`
5. 双击 `signingReport`
6. 在底部 Run 窗口查看 SHA1

## 方案 3: 使用在线工具（仅调试版）

如果你已经有 debug.keystore 文件，可以上传到在线工具获取 SHA1：

```bash
# 找到 debug.keystore 位置
# macOS: ~/.android/debug.keystore
# Windows: C:\Users\<用户名>\.android\debug.keystore
```

然后使用在线 keytool 工具提取 SHA1。

## 方案 4: 临时安装 Java（推荐）

```bash
# macOS
brew install openjdk

# Windows
# 下载安装 https://www.oracle.com/java/technologies/downloads/

# 然后运行
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

## 最简单的方法

如果你暂时不想折腾，可以先：**随便填一个 SHA1 占位符**去申请高德 Key，等后面有了正确的 SHA1 再更新。

调试版 Key 可以随时重新申请，不影响开发。

---

**推荐**: 先用方案 1（Flutter Gradle）试试，不需要额外安装 Java。