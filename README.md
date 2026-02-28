# 山径

一款为城市年轻人设计的轻度徒步向导应用。

## 简介

山径帮助用户发现周边徒步路线，提供离线导航和安全保障，让每一次出走都轻松安心。

**核心功能：**
- 发现 - 浏览和搜索精选徒步路线
- 导航 - 离线地图、实时轨迹跟随、偏航检测
- 记录 - 轨迹记录、照片标记、数据回顾（M2开放）
- 我的 - 个人资料、收藏路线、历史记录

## 安装

### 环境要求
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Android SDK / Xcode（iOS开发）

### 快速开始

```bash
# 克隆仓库
git clone <repo-url>
cd hangzhou_guide

# 安装依赖
flutter pub get

# 配置高德地图 Key
# 在 .env 文件中添加：
# AMAP_ANDROID_KEY=your_android_key
# AMAP_IOS_KEY=your_ios_key

# 运行
flutter run
```

## 使用

1. **浏览路线** - 打开应用查看推荐路线，可按距离、难度、标签筛选
2. **下载路线** - 在路线详情页点击下载，获取离线地图数据
3. **开始导航** - 到达起点附近后点击导航，跟随轨迹前行
4. **分享行程** - 使用安全分享功能，让亲友了解你的位置

## 技术栈

- Flutter - 跨平台 UI 框架
- 高德地图 SDK - 地图与定位服务
- 本地存储 - 离线数据缓存

## 项目结构

```
lib/
├── main.dart          # 应用入口
├── screens/           # 页面
│   ├── discovery_screen.dart
│   ├── navigation_screen.dart
│   ├── profile_screen.dart
│   └── trail_detail_screen.dart
├── widgets/           # 组件
└── constants/         # 常量
```

## 许可证

MIT
