# 山径 APP - Dev Agent 任务检查报告

## 检查时间
2026-03-14 15:35

## 后端 API 问题

### 1. ❌ 缺失前端路线 API 控制器
- **位置**: `shanjing-api/src/modules/`
- **问题**: 只有 `admin/trails` 管理后台接口，没有前端用户访问路线的 API
- **影响**: Flutter APP 无法从服务器获取路线列表
- **优先级**: P0

### 2. ❌ 缺失用户收藏 API 控制器
- **位置**: `shanjing-api/src/modules/`
- **问题**: Prisma schema 有 Favorite 模型，但没有对应的控制器和服务
- **影响**: 用户无法收藏/取消收藏路线
- **优先级**: P0

## Flutter APP 问题

### 3. ❌ 收藏功能未对接 API
- **位置**: `lib/screens/trail_detail_screen.dart:87`
- **问题**: `_toggleFavorite()` 只有 UI 切换，没有 API 调用
- **代码**: `// TODO: 调用收藏 API`
- **优先级**: P0

### 4. ❌ 详情页 Tab 内容缺失
- **位置**: `lib/screens/trail_detail_screen.dart`
- **问题**: 
  - `_buildTrackTab()` - 只有 `Text('轨迹内容')` 占位
  - `_buildReviewTab()` - 只有 `Text('评价内容')` 占位  
  - `_buildGuideTab()` - 只有 `Text('攻略内容')` 占位
- **优先级**: P1

### 5. ❌ 离线地图原生实现缺失
- **位置**: `lib/services/offline_map_manager.dart`
- **问题**: 使用了 `MethodChannel` 调用原生 SDK，但没有 Android/iOS 原生代码实现
- **影响**: 离线地图功能无法正常工作
- **优先级**: P2

## 代码质量问题

### 6. ⚠️ TODO 未实现
- **位置**: `lib/screens/navigation_screen.dart:472`
- **代码**: `// TODO: 重新规划路线`
- **优先级**: P2

### 7. ⚠️ 调试代码
- **位置**: `lib/services/offline_map_manager.dart`
- **问题**: 多处使用 `print()` 进行调试输出
- **优先级**: P3

## 修复计划

### Phase 1: 后端 API 基础 (P0)
1. 创建 `TrailsController` - 前端路线查询 API
2. 创建 `FavoritesController` - 用户收藏 API
3. 更新 `AppModule` 注册新模块

### Phase 2: Flutter 功能完善 (P1)
4. 创建 API 服务层 (`TrailService`, `FavoriteService`)
5. 对接收藏功能 API
6. 完善详情页 Tab 内容

### Phase 3: 代码优化 (P2-P3)
7. 处理 TODO
8. 清理调试代码
