# M5 成就系统实现代码

## 已完成交付物清单

### 1. 数据库 (Prisma)
- [x] `prisma/migrations/achievement_migration/migration.sql` - 数据库迁移脚本
- [x] `prisma/schema.prisma` - Prisma 模型定义

### 2. 后端 API (NestJS)
- [x] `src/achievements/achievements.module.ts` - 成就模块
- [x] `src/achievements/achievements.controller.ts` - REST API 控制器
- [x] `src/achievements/achievements.service.ts` - 业务逻辑服务
- [x] `src/achievements/achievements.gateway.ts` - WebSocket 实时通知网关
- [x] `src/achievements/achievements-checker.service.ts` - 成就检查规则引擎
- [x] `src/achievements/dto/*.ts` - DTO 定义

### 3. Flutter 客户端
- [x] `lib/models/achievement.dart` - 数据模型（含 Freezed 代码生成支持）
- [x] `lib/services/achievement_service.dart` - 成就服务
- [x] `lib/screens/achievements/achievement_screen.dart` - 徽章墙页面
- [x] `lib/screens/achievements/achievement_unlock_dialog.dart` - 解锁弹窗
- [x] `lib/widgets/achievement_badge.dart` - 徽章组件
- [x] `lib/utils/achievement_integration.dart` - 集成混入
- [x] `lib/utils/achievement_manager.dart` - 集成管理器

---

## 快速集成指南

### 后端部署步骤

1. **执行数据库迁移**
```bash
# 复制迁移文件到项目
mkdir -p prisma/migrations/achievement_migration
cp M5-ACHIEVEMENT-IMPLEMENTATION/prisma/migrations/achievement_migration/migration.sql prisma/migrations/achievement_migration/

# 应用迁移
npx prisma migrate dev --name add_achievements
```

2. **合并 Prisma Schema**
将 `schema.prisma` 中的模型定义合并到主 schema 文件中。

3. **生成 Prisma Client**
```bash
npx prisma generate
```

4. **注册模块**
在 `app.module.ts` 中导入 `AchievementsModule`：
```typescript
import { AchievementsModule } from './achievements/achievements.module';

@Module({
  imports: [
    // ...其他模块
    AchievementsModule,
  ],
})
export class AppModule {}
```

5. **初始化成就数据**
```bash
npx prisma db seed
```

### 前端集成步骤

1. **复制文件到项目**
```bash
# 模型
mkdir -p lib/models
cp M5-ACHIEVEMENT-IMPLEMENTATION/lib/models/achievement.dart lib/models/

# 服务
mkdir -p lib/services
cp M5-ACHIEVEMENT-IMPLEMENTATION/lib/services/achievement_service.dart lib/services/

# 页面
mkdir -p lib/screens/achievements
cp M5-ACHIEVEMENT-IMPLEMENTATION/lib/screens/achievements/*.dart lib/screens/achievements/

# 组件
mkdir -p lib/widgets
cp M5-ACHIEVEMENT-IMPLEMENTATION/lib/widgets/achievement_badge.dart lib/widgets/

# 工具
mkdir -p lib/utils
cp M5-ACHIEVEMENT-IMPLEMENTATION/lib/utils/*.dart lib/utils/
```

2. **安装依赖**
```bash
flutter pub add freezed_annotation json_annotation socket_io_client flutter_riverpod http
flutter pub add --dev freezed json_serializable build_runner
```

3. **生成代码**
```bash
cd lib/models
dart run build_runner build --delete-conflicting-outputs
```

4. **配置 API**
在 `lib/config/api_config.dart` 中添加：
```dart
class ApiConfig {
  static const String baseUrl = 'https://api.shanjing.app/v1';
  static const String wsUrl = 'wss://api.shanjing.app';
}
```

---

## 功能集成示例

### 导航完成后调用成就检查

```dart
import 'package:flutter/material.dart';
import '../utils/achievement_manager.dart';

class NavigationPage extends StatefulWidget {
  @override
  _NavigationPageState createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  final AchievementIntegrationManager _achievementManager = 
      AchievementIntegrationManager();
  DateTime? _navigationStartTime;

  @override
  void initState() {
    super.initState();
    _achievementManager.initialize(context);
    _navigationStartTime = DateTime.now();
  }

  void _finishNavigation() async {
    // 导航结束
    final endTime = DateTime.now();
    
    // 调用成就检查
    final result = await _achievementManager.onTrailCompleted(
      trailId: 'trail_001',
      distance: 8500,  // 8.5km = 8500m
      duration: 7200,  // 2小时 = 7200秒
      startTime: _navigationStartTime,
      endTime: endTime,
      isRain: false,
      isSolo: true,
    );

    if (result?.newlyUnlocked.isNotEmpty ?? false) {
      // 有新成就解锁，弹窗会自动显示
      print('解锁了 ${result!.newlyUnlocked.length} 个新成就！');
    }
  }

  @override
  Widget build(BuildContext context) {
    // ...页面构建
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _finishNavigation,
          child: Text('完成导航'),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _achievementManager.dispose();
    super.dispose();
  }
}
```

### 收藏路线后调用成就检查

```dart
import '../utils/achievement_manager.dart';

class TrailDetailPage extends StatelessWidget {
  final String trailId;
  
  const TrailDetailPage({Key? key, required this.trailId}) : super(key: key);

  void _toggleBookmark(BuildContext context) async {
    final manager = AchievementIntegrationManager();
    
    // 执行收藏操作
    await bookmarkService.toggleBookmark(trailId);
    
    // 检查收藏成就
    await manager.onTrailBookmarked(trailId);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已收藏路线')),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ...页面构建
  }
}
```

### 使用混入简化集成

```dart
import 'package:flutter/material.dart';
import '../utils/achievement_integration.dart';

class TrailCompletionPage extends StatefulWidget {
  @override
  _TrailCompletionPageState createState() => _TrailCompletionPageState();
}

class _TrailCompletionPageState extends State<TrailCompletionPage>
    with AchievementIntegrationMixin {
  
  Future<void> _completeTrail() async {
    // 使用混入提供的方法
    final result = await checkTrailCompleted(
      trailId: 'trail_001',
      distance: 10000,
      duration: 9000,
      isSolo: true,
    );

    if (result?.newlyUnlocked.isNotEmpty ?? false) {
      for (final achievement in result!.newlyUnlocked) {
        showAchievementUnlock(achievement);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: _completeTrail,
          child: Text('完成路线'),
        ),
      ),
    );
  }
}
```

---

## 成就系统特性

### 支持的成就类型

| 类别 | 触发条件 | 等级 |
|------|----------|------|
| explorer | 完成不同路线数量 | 铜/银/金/钻石 |
| distance | 累计徒步距离（米） | 铜/银/金/钻石 |
| frequency | 连续周徒步 | 铜/银/金/钻石 |
| challenge | 夜间/雨天徒步次数 | 铜/银/金/钻石 |
| social | 分享次数 | 铜/银/金/钻石 |

### 实时通知

- WebSocket 连接实现实时成就解锁通知
- 支持离线解锁，联网后自动同步

### 动画效果

- 徽章解锁弹性缩放动画
- 光效扩散动画
- 文字淡入动画
- 按钮上滑动画

---

## 单元测试兼容性

代码设计时已考虑测试需求：

1. 服务层使用依赖注入，便于 mock
2. 提供 `AchievementIntegrationMixin` 便于测试混入功能
3. 所有外部依赖（如 HTTP、WebSocket）通过抽象接口封装

测试示例：
```dart
// 测试成就检查
await tester.pumpWidget(MaterialApp(home: TestNavigationPage()));
await tester.tap(find.text('完成导航'));
await tester.pumpAndSettle();

expect(find.text('解锁成就'), findsOneWidget);
```

---

## 文件清单

```
M5-ACHIEVEMENT-IMPLEMENTATION/
├── prisma/
│   ├── migrations/
│   │   └── achievement_migration/
│   │       └── migration.sql
│   └── schema.prisma
├── src/
│   └── achievements/
│       ├── achievements.module.ts
│       ├── achievements.controller.ts
│       ├── achievements.service.ts
│       ├── achievements.gateway.ts
│       ├── achievements-checker.service.ts
│       └── dto/
│           ├── check-achievements.dto.ts
│           ├── achievement-response.dto.ts
│           ├── user-achievement-response.dto.ts
│           └── check-result-response.dto.ts
├── lib/
│   ├── models/
│   │   └── achievement.dart
│   ├── services/
│   │   └── achievement_service.dart
│   ├── screens/
│   │   └── achievements/
│   │       ├── achievement_screen.dart
│   │       └── achievement_unlock_dialog.dart
│   ├── widgets/
│   │   └── achievement_badge.dart
│   └── utils/
│       ├── achievement_integration.dart
│       └── achievement_manager.dart
└── README.md
```

---

## 注意事项

1. **Freezed 代码生成**: 修改模型后需要运行 `build_runner`
2. **WebSocket 认证**: 确保 `AuthService` 提供正确的 token
3. **图片资源**: 成就徽章图片需要上传到 CDN 并配置正确的 URL
4. **数据库索引**: 迁移脚本已包含必要的索引，确保查询性能
