# M2 离线地图SDK接入测试文档

## 实现概览

### 已完成的功能

#### 1. Android 原生实现
- **文件**: `android/app/src/main/kotlin/com/suyustudio/shanjing/OfflineMapPlugin.kt`
- **集成**: 高德地图离线SDK (`com.amap.api:map3d`)
- **MethodChannel 接口**:
  - `initialize` - 初始化离线地图管理器
  - `getOfflineCityList` - 获取城市列表
  - `getHotCityList` - 获取热门城市列表
  - `downloadOfflineMap` - 开始下载
  - `pauseDownload` - 暂停下载
  - `resumeDownload` - 继续下载
  - `deleteOfflineMap` - 删除离线包
  - `getDownloadedOfflineMapList` - 获取已下载列表
  - `isCityDownloaded` - 检查是否已下载
  - `getDownloadProgress` - 获取下载进度
  - `clearAllOfflineMaps` - 清除所有离线地图
  - `updateOfflineMap` - 更新离线地图

- **EventChannel**: 实时下载进度通知

#### 2. Flutter 层完善
- **OfflineMapManager**: 完整对接原生SDK，支持网络状态监听
- **OfflineMapScreen**: 
  - 三栏界面（已下载、热门城市、全部城市）
  - 实时下载进度显示
  - 网络状态指示器
  - 存储空间管理
  - 离线模式提示
- **MapScreen**: 
  - 离线模式指示器
  - 自动检测网络变化

### 依赖配置

```gradle
// android/app/build.gradle
dependencies {
    implementation 'com.amap.api:3dmap-location-search:latest.integration'
    implementation 'com.amap.api:map3d:latest.integration'
}
```

```yaml
# pubspec.yaml
connectivity_plus: ^5.0.0  # 用于网络状态监听
```

## 测试步骤

### 1. 编译测试
```bash
flutter clean
flutter pub get
cd android
./gradlew clean build
```

### 2. 功能测试

#### 2.1 城市列表加载
1. 进入"我的" -> "离线地图"
2. 验证:
   - [ ] 已下载标签页显示正常
   - [ ] 热门城市标签页显示城市列表
   - [ ] 全部城市标签页显示所有可下载城市
   - [ ] 搜索功能正常工作

#### 2.2 离线地图下载
1. 在"热门城市"或"全部城市"选择一个城市
2. 点击"下载"按钮
3. 验证:
   - [ ] 下载进度条显示并更新
   - [ ] 状态显示"下载中"
   - [ ] 下载完成后自动刷新"已下载"列表
   - [ ] 显示下载完成提示

#### 2.3 暂停/继续下载
1. 开始下载一个离线地图
2. 点击"暂停"按钮
3. 验证:
   - [ ] 状态变为"已暂停"
   - [ ] 进度条颜色变化
4. 点击"继续"按钮
5. 验证:
   - [ ] 状态恢复为"下载中"
   - [ ] 继续下载进度

#### 2.4 删除离线地图
1. 在"已下载"列表中选择一个城市
2. 点击删除图标
3. 验证:
   - [ ] 显示确认对话框
   - [ ] 确认后从列表中移除
   - [ ] 存储空间更新

#### 2.5 离线模式测试
1. 下载至少一个城市的离线地图
2. 关闭设备网络（WiFi + 移动数据）
3. 验证:
   - [ ] 地图屏幕显示"离线模式"指示器
   - [ ] 离线地图屏幕显示离线提示
   - [ ] 已下载的离线地图可以正常使用
   - [ ] 未下载的城市显示"离线模式下无法下载"提示

#### 2.6 网络恢复测试
1. 在离线模式下，重新开启网络
2. 验证:
   - [ ] "离线模式"指示器消失
   - [ ] 可以继续下载新的离线地图

### 3. 存储空间管理测试
1. 下载多个城市的离线地图
2. 验证:
   - [ ] 存储空间统计显示正确
   - [ ] 点击"清理"按钮可以删除所有离线地图
   - [ ] 清理后存储空间归零

## 常见问题排查

### 1. MissingPluginException
**现象**: Flutter层报错"原生插件未实现"
**解决**: 
- 确保Android原生代码已编译
- 执行 `flutter clean && flutter pub get`
- 重新编译应用

### 2. 离线地图无法下载
**现象**: 点击下载没有反应
**解决**:
- 检查存储权限是否授予
- 检查网络连接
- 查看日志输出排查问题

### 3. 下载进度不更新
**现象**: 进度条不刷新
**解决**:
- 检查EventChannel是否正确监听
- 确保在主线程更新UI

## 性能指标

- 下载速度: 取决于网络环境，通常1-10MB/s
- 单个城市离线包大小: 5-50MB（取决于城市大小）
- 初始化时间: < 1秒
- 列表加载时间: < 2秒

## 注意事项

1. **WiFi环境下载**: 建议在WiFi环境下下载离线地图，避免消耗移动流量
2. **存储空间**: 确保设备有足够的存储空间
3. **定期更新**: 离线地图数据会定期更新，建议定期检查更新
4. **Android版本**: 需要Android 5.0 (API 21) 及以上版本

## 待实现（iOS）

由于当前项目暂无iOS目录，iOS原生实现需要：
1. 创建iOS项目结构
2. 集成高德iOS离线地图SDK
3. 实现与Android相同的MethodChannel接口
4. 配置离线地图权限

## 交付标准验证

- [ ] 离线地图可真实下载并使用
- [ ] 下载进度实时显示
- [ ] 断网后能正常显示已下载的离线地图
- [ ] Android真机测试通过
