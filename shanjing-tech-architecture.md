# 山径APP - 技术架构设计文档

> **文档版本**: v1.0  
> **最后更新**: 2026-02-27  
> **文档状态**: 评审中  
> **对应PRD**: shanjing-prd-v1.2.md

---

## 目录

1. [系统架构设计](#1-系统架构设计)
2. [客户端架构（Flutter）](#2-客户端架构flutter)
3. [后端架构（Node.js）](#3-后端架构nodejs)
4. [关键模块设计](#4-关键模块设计)
5. [非功能需求](#5-非功能需求)
6. [附录](#6-附录)

---

## 1. 系统架构设计

### 1.1 整体架构图

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    客户端层                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                           山径APP (Flutter)                              │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │   │
│  │  │ 发现模块  │  │ 导航模块  │  │ 记录模块  │  │ 社区模块  │  │ 我的模块  │  │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │   │
│  │  ┌─────────────────────────────────────────────────────────────────┐   │   │
│  │  │                      基础服务层                                    │   │   │
│  │  │  ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐        │   │   │
│  │  │  │地图服务 │ │定位服务 │ │存储服务 │ │网络服务 │ │分享服务 │        │   │   │
│  │  │  └────────┘ └────────┘ └────────┘ └────────┘ └────────┘        │   │   │
│  │  └─────────────────────────────────────────────────────────────────┘   │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      │ HTTPS/WSS
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    网关层                                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                         Nginx / API Gateway                              │   │
│  │  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐ │   │
│  │  │   负载均衡    │  │   限流熔断    │  │   SSL终止    │  │   日志记录    │ │   │
│  │  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘ │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    服务层                                         │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │                        Node.js 微服务集群                                │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  │   │
│  │  │ 用户服务  │  │ 路线服务  │  │ 导航服务  │  │ 文件服务  │  │ 通知服务  │  │   │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘  │   │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐                              │   │
│  │  │ 收藏服务  │  │ 搜索服务  │  │ 后台服务  │                              │   │
│  │  └──────────┘  └──────────┘  └──────────┘                              │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                    数据层                                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐    │
│  │  PostgreSQL │  │    Redis    │  │    MinIO    │  │   Elasticsearch     │    │
│  │  (主数据库)  │  │  (缓存/会话) │  │  (对象存储)  │  │     (搜索引擎)       │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
                                      │
                                      ▼
┌─────────────────────────────────────────────────────────────────────────────────┐
│                                  第三方服务层                                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐    │
│  │   高德SDK    │  │   微信SDK    │  │   极光推送   │  │       OSS           │    │
│  │  (地图/定位) │  │  (登录/分享) │  │  (消息推送)  │  │   (阿里云存储)       │    │
│  └─────────────┘  └─────────────┘  └─────────────┘  └─────────────────────┘    │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### 1.2 技术选型说明

#### 1.2.1 客户端：Flutter

| 维度 | 选择理由 |
|------|----------|
| **跨平台** | 一套代码同时支持iOS/Android，MVP阶段节省50%+开发成本 |
| **性能** | 自绘引擎，性能接近原生，地图渲染流畅度满足导航需求 |
| **生态** | 高德SDK提供Flutter插件，社区组件丰富 |
| **团队** | 单移动端工程师可独立完成双端开发 |
| **热更新** | 支持Code Push，紧急修复无需发版 |

**备选方案对比**:
| 方案 | 优点 | 缺点 | 决策 |
|------|------|------|------|
| Flutter | 跨平台、性能高、生态好 | 包体积略大 | ✅ 首选 |
| React Native | 生态成熟、Web团队易上手 | 地图性能一般 | ❌ 次选 |
| 原生双端 | 性能最佳 | 开发成本高 | ❌ MVP不适用 |

#### 1.2.2 后端：Node.js + TypeScript

| 维度 | 选择理由 |
|------|----------|
| **开发效率** | JavaScript全栈，前后端可复用部分逻辑 |
| **生态丰富** | npm包管理，Express/NestJS框架成熟 |
| **实时能力** | WebSocket支持好，适合导航实时数据 |
| **团队匹配** | 团队熟悉JavaScript技术栈 |
| **部署简单** | Docker化部署，CI/CD流程成熟 |

**技术栈组合**:
```
运行时: Node.js 18+ LTS
框架: NestJS (企业级架构)
语言: TypeScript (类型安全)
ORM: Prisma (现代化数据库工具)
文档: Swagger/OpenAPI
测试: Jest + Supertest
```

#### 1.2.3 地图服务：高德SDK

| 维度 | 选择理由 |
|------|----------|
| **数据准确** | 国内地图数据最准确，山路、步道覆盖全 |
| **北斗支持** | 原生支持北斗+GPS双模定位，符合产品卖点 |
| **离线能力** | 支持离线地图下载，满足核心需求 |
| **阿里资源** | 便于商务沟通，可能获得技术支持 |
| **合规性** | 国内地图资质齐全，避免政策风险 |

**高德SDK功能使用**:
| 功能模块 | 高德SDK能力 | 使用方式 |
|----------|-------------|----------|
| 地图显示 | 2D/3D地图 | 官方Flutter插件 |
| 离线地图 | 按城市/区域下载 | 原生SDK封装 |
| 定位服务 | GPS+北斗双模 | 定位SDK |
| 轨迹绘制 | 折线/多边形 | 地图覆盖物 |
| 导航功能 | 路径规划 | 导航SDK |

### 1.3 部署架构

#### 1.3.1 环境划分

```
┌─────────────────────────────────────────────────────────────────┐
│                        生产环境 (Production)                      │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   Web服务器  │  │   应用服务器 │  │   数据库服务器│             │
│  │  (Nginx ×2) │  │  (Node ×4)  │  │(PostgreSQL主从)│            │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   缓存服务器 │  │   对象存储   │  │   CDN节点    │             │
│  │  (Redis集群) │  │   (OSS)     │  │  (阿里云CDN) │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ 镜像部署
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        预发布环境 (Staging)                       │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  与生产环境一致配置，用于上线前最终验证                      │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ 自动化部署
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        测试环境 (Testing)                         │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  简化配置，用于集成测试和QA验收                            │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ 开发分支自动部署
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        开发环境 (Development)                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │  Docker Compose 本地开发环境                              │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

#### 1.3.2 容器化部署

```yaml
# docker-compose.yml 示例
version: '3.8'
services:
  app:
    image: shanjing/app:${VERSION}
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://...
      - REDIS_URL=redis://...
    depends_on:
      - postgres
      - redis
    deploy:
      replicas: 4
      resources:
        limits:
          cpus: '1'
          memory: 1G
  
  postgres:
    image: postgis/postgis:15-3.3
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_DB=shanjing
      - POSTGRES_USER=app
      - POSTGRES_PASSWORD=${DB_PASSWORD}
  
  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    command: redis-server --appendonly yes

volumes:
  postgres_data:
  redis_data:
```

---

## 2. 客户端架构（Flutter）

### 2.1 项目结构

```
shanjing_app/
├── android/                    # Android原生配置
├── ios/                        # iOS原生配置
├── lib/
│   ├── main.dart              # 应用入口
│   ├── app.dart               # 应用配置
│   ├── config/                # 配置层
│   │   ├── constants.dart     # 常量定义
│   │   ├── routes.dart        # 路由配置
│   │   ├── theme.dart         # 主题配置
│   │   └── env.dart           # 环境变量
│   ├── core/                  # 核心层
│   │   ├── base/              # 基类定义
│   │   ├── exceptions/        # 异常处理
│   │   ├── extensions/        # 扩展方法
│   │   └── utils/             # 工具类
│   ├── data/                  # 数据层
│   │   ├── models/            # 数据模型
│   │   ├── repositories/      # 数据仓库
│   │   ├── datasources/       # 数据源
│   │   │   ├── local/         # 本地数据源
│   │   │   └── remote/        # 远程数据源
│   │   └── mappers/           # 数据映射
│   ├── domain/                # 领域层
│   │   ├── entities/          # 领域实体
│   │   ├── usecases/          # 用例
│   │   └── repositories/      # 仓库接口
│   ├── presentation/          # 表现层
│   │   ├── providers/         # 状态管理
│   │   ├── screens/           # 页面
│   │   │   ├── splash/
│   │   │   ├── login/
│   │   │   ├── discovery/
│   │   │   ├── trail_detail/
│   │   │   ├── navigation/
│   │   │   ├── recording/
│   │   │   ├── community/
│   │   │   └── profile/
│   │   ├── widgets/           # 公共组件
│   │   │   ├── common/        # 通用组件
│   │   │   ├── map/           # 地图组件
│   │   │   ├── navigation/    # 导航组件
│   │   │   └── poi/           # POI组件
│   │   └── viewmodels/        # 视图模型
│   └── services/              # 服务层
│       ├── amap_service.dart  # 高德SDK封装
│       ├── location_service.dart # 定位服务
│       ├── storage_service.dart  # 存储服务
│       ├── http_service.dart     # 网络服务
│       ├── auth_service.dart     # 认证服务
│       ├── share_service.dart    # 分享服务
│       └── tts_service.dart      # 语音服务
├── assets/                    # 静态资源
│   ├── images/
│   ├── icons/
│   ├── fonts/
│   └── l10n/                  # 国际化
├── test/                      # 测试
├── pubspec.yaml
└── README.md
```

### 2.2 状态管理方案

#### 2.2.1 选型：Riverpod

**选择理由**:
| 维度 | Riverpod | Provider | Bloc |
|------|----------|----------|------|
| 编译安全 | ✅ 编译时检查 | ❌ 运行时检查 | ✅ 类型安全 |
| 代码生成 | ✅ 支持 | ❌ 不支持 | ❌ 部分支持 |
| 性能 | ✅ 优秀 | ✅ 良好 | ✅ 良好 |
| 学习成本 | 🟡 中等 | ✅ 低 | 🟡 中等 |
| 社区活跃 | ✅ 活跃 | ✅ 成熟 | ✅ 成熟 |

**核心设计**:
```dart
// lib/presentation/providers/auth_provider.dart
import 'package:riverpod/riverpod.dart';

// 认证状态
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AuthState build() {
    return const AuthState.initial();
  }

  Future<void> loginWithWechat(String code) async {
    state = const AuthState.loading();
    try {
      final user = await ref.read(authRepositoryProvider).wechatLogin(code);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AuthState.unauthenticated();
  }
}

// 路线数据状态
@riverpod
class TrailNotifier extends _$TrailNotifier {
  @override
  Future<List<Trail>> build() async {
    return ref.read(trailRepositoryProvider).getNearbyTrails();
  }

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return ref.read(trailRepositoryProvider).getNearbyTrails();
    });
  }
}

// 导航状态
@riverpod
class NavigationNotifier extends _$NavigationNotifier {
  @override
  NavigationState build() {
    return const NavigationState.idle();
  }

  void startNavigation(Trail trail) {
    state = NavigationState.active(
      trail: trail,
      currentPosition: null,
      remainingDistance: trail.distanceKm,
      eta: DateTime.now().add(Duration(minutes: trail.durationMin)),
    );
  }

  void updatePosition(LatLng position) {
    state = state.map(
      idle: (_) => _,
      active: (active) {
        // 计算偏航、更新进度
        final deviation = _calculateDeviation(position, active.trail);
        final remainingDistance = _calculateRemainingDistance(position, active.trail);
        return active.copyWith(
          currentPosition: position,
          deviation: deviation,
          remainingDistance: remainingDistance,
        );
      },
    );
  }
}
```

### 2.3 本地存储

#### 2.3.1 存储方案选型

| 数据类型 | 存储方案 | 理由 |
|----------|----------|------|
| 用户配置 | SharedPreferences | 轻量键值对 |
| 离线地图 | 文件系统 | 高德SDK原生支持 |
| 路线数据 | SQLite (drift) | 结构化查询 |
| 轨迹记录 | SQLite + 文件 | 大数据量分存 |
| 图片缓存 | 文件系统 | 快速读取 |
| 临时数据 | Memory | 运行时缓存 |

#### 2.3.2 离线数据管理

```dart
// lib/data/datasources/local/offline_database.dart
import 'package:drift/drift.dart';

part 'offline_database.g.dart';

// 路线表
@DataClassName('OfflineTrail')
class OfflineTrails extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  RealColumn get distanceKm => real()();
  IntColumn get durationMin => integer()();
  RealColumn get elevationGainM => real()();
  TextColumn get difficulty => text()();
  TextColumn get tags => text().map(const JsonListConverter())();
  TextColumn get coverImages => text().map(const JsonListConverter())();
  TextColumn get gpxData => text()();
  TextColumn get poiData => text().map(const JsonListConverter())();
  DateTimeColumn get downloadedAt => dateTime()();
  DateTimeColumn get expiresAt => dateTime()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// POI表
@DataClassName('OfflinePoi')
class OfflinePois extends Table {
  TextColumn get id => text()();
  TextColumn get trailId => text()();
  TextColumn get name => text()();
  TextColumn get type => text()();
  TextColumn get subtype => text()();
  RealColumn get latitude => real()();
  RealColumn get longitude => real()();
  RealColumn get altitude => real().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get photos => text().map(const JsonListConverter()).nullable()();
  IntColumn get priority => integer()();
  
  @override
  Set<Column> get primaryKey => {id};
}

// 轨迹记录表
@DataClassName('TrackRecord')
class TrackRecords extends Table {
  TextColumn get id => text()();
  TextColumn get trailId => text().nullable()();
  TextColumn get userId => text()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  RealColumn get totalDistanceKm => real().nullable()();
  IntColumn get durationSec => integer().nullable()();
  RealColumn get elevationGainM => real().nullable()();
  RealColumn get elevationLossM => real().nullable()();
  TextColumn get trackPoints => text()(); // JSON数组
  TextColumn get photos => text().map(const JsonListConverter()).nullable()();
  BoolColumn get isUploaded => boolean().withDefault(const Constant(false))();
  
  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [OfflineTrails, OfflinePois, TrackRecords])
class OfflineDatabase extends _$OfflineDatabase {
  OfflineDatabase() : super(_openConnection());
  
  @override
  int get schemaVersion => 1;
  
  // 路线CRUD
  Future<List<OfflineTrail>> getAllTrails() => select(offlineTrails).get();
  Future<OfflineTrail?> getTrail(String id) =>
      (select(offlineTrails)..where((t) => t.id.equals(id))).getSingleOrNull();
  Future<int> insertTrail(OfflineTrailsCompanion trail) =>
      into(offlineTrails).insert(trail, mode: InsertMode.replace);
  Future<int> deleteTrail(String id) =>
      (delete(offlineTrails)..where((t) => t.id.equals(id))).go();
  
  // 获取即将过期的离线包
  Future<List<OfflineTrail>> getExpiringTrails() =>
      (select(offlineTrails)..where((t) => t.expiresAt.isSmallerThanValue(DateTime.now()))).get();
}
```

#### 2.3.3 离线包管理器

```dart
// lib/services/offline_package_manager.dart
class OfflinePackageManager {
  final OfflineDatabase _database;
  final AMapService _mapService;
  final StorageService _storage;
  
  // 下载路线离线包
  Future<DownloadResult> downloadTrailPackage(String trailId) async {
    try {
      // 1. 获取路线元数据
      final trail = await _fetchTrailMetadata(trailId);
      
      // 2. 计算离线地图区域
      final bounds = _calculateMapBounds(trail.gpxData);
      
      // 3. 下载离线地图
      final mapDownload = await _mapService.downloadOfflineMap(
        bounds: bounds,
        minZoom: 14,
        maxZoom: 16,
        onProgress: (progress) => _emitProgress(trailId, progress),
      );
      
      // 4. 保存路线数据到数据库
      await _database.insertTrail(OfflineTrailsCompanion(
        id: Value(trailId),
        name: Value(trail.name),
        // ... 其他字段
        downloadedAt: Value(DateTime.now()),
        expiresAt: Value(DateTime.now().add(const Duration(days: 30))),
      ));
      
      // 5. 保存POI数据
      for (final poi in trail.pois) {
        await _database.insertPoi(OfflinePoisCompanion(
          id: Value('${trailId}_${poi.sequence}'),
          trailId: Value(trailId),
          // ... 其他字段
        ));
      }
      
      return DownloadResult.success(
        trailId: trailId,
        sizeBytes: mapDownload.sizeBytes,
      );
    } catch (e) {
      return DownloadResult.failure(trailId: trailId, error: e.toString());
    }
  }
  
  // 清理过期离线包
  Future<void> cleanExpiredPackages() async {
    final expiredTrails = await _database.getExpiringTrails();
    for (final trail in expiredTrails) {
      await deleteTrailPackage(trail.id);
    }
  }
  
  // 获取存储使用情况
  Future<StorageUsage> getStorageUsage() async {
    final trails = await _database.getAllTrails();
    final mapSize = await _mapService.getOfflineMapSize();
    final dbSize = await _storage.getDatabaseSize();
    
    return StorageUsage(
      offlineMapsBytes: mapSize,
      databaseBytes: dbSize,
      totalBytes: mapSize + dbSize,
      trailCount: trails.length,
    );
  }
}
```

### 2.4 地图模块架构

#### 2.4.1 高德SDK封装

```dart
// lib/services/amap_service.dart
class AMapService {
  late AMapController _mapController;
  final _locationController = StreamController<LatLng>.broadcast();
  
  Stream<LatLng> get locationStream => _locationController.stream;
  
  // 初始化
  Future<void> initialize() async {
    await AMapInitializer.init(
      apiKey: Env.amapApiKey,
      privacyStatement: true,
    );
  }
  
  // 创建地图控制器
  Future<AMapController> createMapController(AMapWidget mapWidget) async {
    _mapController = await mapWidget.controller.future;
    return _mapController;
  }
  
  // 显示离线地图
  Future<void> showOfflineMap(String trailId) async {
    final offlineData = await _getOfflineMapData(trailId);
    await _mapController.setOfflineMap(offlineData);
  }
  
  // 绘制轨迹
  Future<void> drawTrail(List<LatLng> points, {Color? color}) async {
    final polyline = Polyline(
      points: points,
      color: color ?? Colors.blue,
      width: 8,
      joinType: JoinType.round,
    );
    await _mapController.addPolyline(polyline);
  }
  
  // 添加POI标记
  Future<void> addPoiMarkers(List<Poi> pois) async {
    final markers = pois.map((poi) => Marker(
      position: LatLng(poi.latitude, poi.longitude),
      icon: _getPoiIcon(poi.type),
      infoWindow: InfoWindow(
        title: poi.name,
        snippet: poi.description,
      ),
    )).toList();
    await _mapController.addMarkers(markers);
  }
  
  // 开始定位
  Future<void> startLocation() async {
    await _mapController.startLocation(
      locationOption: LocationOption(
        desiredAccuracy: DesiredAccuracy.hight,
        distanceFilter: 5, // 5米更新一次
        locateWithReGeocode: false,
      ),
    );
    _mapController.onLocationChanged.listen((location) {
      _locationController.add(LatLng(location.latitude, location.longitude));
    });
  }
  
  // 下载离线地图
  Future<DownloadResult> downloadOfflineMap({
    required LatLngBounds bounds,
    required int minZoom,
    required int maxZoom,
    required Function(double) onProgress,
  }) async {
    final offlineController = await AMapOfflineMapController.create();
    return await offlineController.download(
      bounds: bounds,
      minZoom: minZoom,
      maxZoom: maxZoom,
      onProgress: onProgress,
    );
  }
}
```

#### 2.4.2 离线地图管理

```dart
// lib/services/offline_map_manager.dart
class OfflineMapManager {
  final AMapService _amapService;
  final LocalStorage _storage;
  
  // 离线地图配置
  static const int kMinZoom = 14;  // 最小缩放级别
  static const int kMaxZoom = 16;  // 最大缩放级别
  static const double kBufferDistance = 500; // 路线周边500米
  static const int kExpiryDays = 30; // 30天过期
  
  // 计算下载区域
  LatLngBounds _calculateDownloadBounds(List<LatLng> trailPoints) {
    final bounds = _calculateBounds(trailPoints);
    return LatLngBounds(
      southwest: LatLng(
        bounds.southwest.latitude - _metersToLat(kBufferDistance),
        bounds.southwest.longitude - _metersToLng(kBufferDistance, bounds.southwest.latitude),
      ),
      northeast: LatLng(
        bounds.northeast.latitude + _metersToLat(kBufferDistance),
        bounds.northeast.longitude + _metersToLng(kBufferDistance, bounds.northeast.latitude),
      ),
    );
  }
  
  // 预估下载大小
  Future<int> estimateDownloadSize(List<LatLng> trailPoints) async {
    final bounds = _calculateDownloadBounds(trailPoints);
    final area = _calculateArea(bounds);
    // 经验公式：每平方公里约 0.5-2MB (14-16级)
    final estimatedBytes = (area * 1.5 * 1024 * 1024).toInt();
    return estimatedBytes;
  }
  
  // 删除离线地图
  Future<void> deleteOfflineMap(String trailId) async {
    await _amapService.deleteOfflineMap(trailId);
    await _storage.delete('offline_map_$trailId');
  }
}
```

### 2.5 导航模块架构

#### 2.5.1 导航服务

```dart
// lib/services/navigation_service.dart
class NavigationService {
  final AMapService _mapService;
  final LocationService _locationService;
  final TTSService _ttsService;
  final OfflineDatabase _database;
  
  final _navigationStateController = StreamController<NavigationState>.broadcast();
  final _voiceInstructionController = StreamController<VoiceInstruction>.broadcast();
  
  Stream<NavigationState> get navigationState => _navigationStateController.stream;
  Stream<VoiceInstruction> get voiceInstructions => _voiceInstructionController.stream;
  
  Timer? _navigationTimer;
  Trail? _currentTrail;
  List<LatLng> _trailPoints = [];
  int _currentSegmentIndex = 0;
  
  // 开始导航
  Future<void> startNavigation(Trail trail) async {
    _currentTrail = trail;
    _trailPoints = _parseGpx(trail.gpxData);
    _currentSegmentIndex = 0;
    
    // 加载离线地图
    await _mapService.showOfflineMap(trail.id);
    
    // 绘制路线
    await _mapService.drawTrail(_trailPoints);
    
    // 开始定位
    await _locationService.startTracking(
      accuracy: LocationAccuracy.bestForNavigation,
      interval: const Duration(seconds: 1),
    );
    
    // 监听位置更新
    _locationService.positionStream.listen(_onPositionUpdate);
    
    // 启动导航循环
    _navigationTimer = Timer.periodic(const Duration(seconds: 1), (_) => _navigationLoop());
    
    // 播报开始导航
    _ttsService.speak('开始导航，全程${trail.distanceKm}公里，预计${trail.durationMin}分钟');
    
    _navigationStateController.add(NavigationState(
      status: NavigationStatus.navigating,
      trail: trail,
      progress: 0,
    ));
  }
  
  // 位置更新处理
  void _onPositionUpdate(Position position) {
    if (_currentTrail == null) return;
    
    final currentLatLng = LatLng(position.latitude, position.longitude);
    
    // 1. 轨迹匹配
    final matchResult = _matchToTrail(currentLatLng);
    
    // 2. 偏航检测
    if (matchResult.distance > 30) {
      _handleDeviation(matchResult);
    }
    
    // 3. 更新进度
    final progress = _calculateProgress(matchResult);
    
    // 4. 检查POI接近
    _checkNearbyPois(currentLatLng);
    
    // 5. 更新导航状态
    _navigationStateController.add(NavigationState(
      status: NavigationStatus.navigating,
      trail: _currentTrail!,
      currentPosition: currentLatLng,
      matchedPosition: matchResult.matchedPoint,
      progress: progress,
      remainingDistance: _calculateRemainingDistance(matchResult),
      eta: _calculateEta(matchResult),
      deviation: matchResult.distance > 30 ? matchResult.distance : null,
    ));
  }
  
  // 轨迹匹配算法
  TrailMatchResult _matchToTrail(LatLng position) {
    // 找到最近的轨迹点
    double minDistance = double.infinity;
    LatLng? matchedPoint;
    int matchedIndex = 0;
    
    for (int i = 0; i < _trailPoints.length; i++) {
      final distance = _calculateDistance(position, _trailPoints[i]);
      if (distance < minDistance) {
        minDistance = distance;
        matchedPoint = _trailPoints[i];
        matchedIndex = i;
      }
    }
    
    // 投影到轨迹线段上（更精确的匹配）
    if (matchedIndex > 0 && matchedIndex < _trailPoints.length - 1) {
      final projection = _projectToSegment(
        position,
        _trailPoints[matchedIndex - 1],
        _trailPoints[matchedIndex + 1],
      );
      if (projection.distance < minDistance) {
        minDistance = projection.distance;
        matchedPoint = projection.point;
      }
    }
    
    return TrailMatchResult(
      matchedPoint: matchedPoint!,
      distance: minDistance,
      segmentIndex: matchedIndex,
    );
  }
  
  // 偏航处理
  void _handleDeviation(TrailMatchResult matchResult) {
    if (matchResult.distance > 50) {
      // 严重偏航，提示重新规划
      _ttsService.speak('您已偏离路线，请返回或重新规划');
      _voiceInstructionController.add(VoiceInstruction(
        type: VoiceInstructionType.deviation,
        message: '您已偏离路线${matchResult.distance.toInt()}米',
        priority: VoicePriority.high,
      ));
    } else if (matchResult.distance > 30) {
      // 轻度偏航，提醒
      _ttsService.speak('您已偏离路线，请返回正确方向');
    }
  }
  
  // 检查附近POI
  void _checkNearbyPois(LatLng position) async {
    if (_currentTrail == null) return;
    
    final pois = await _database.getPoisByTrailId(_currentTrail!.id);
    for (final poi in pois) {
      final poiPosition = LatLng(poi.latitude, poi.longitude);
      final distance = _calculateDistance(position, poiPosition);
      
      if (distance < 100 && !_isPoiAnnounced(poi.id)) {
        // 接近POI，语音播报
        _announcePoi(poi, distance);
      }
    }
  }
  
  // 停止导航
  Future<void> stopNavigation() async {
    _navigationTimer?.cancel();
    await _locationService.stopTracking();
    _navigationStateController.add(const NavigationState(
      status: NavigationStatus.idle,
    ));
  }
}
```

#### 2.5.2 轨迹记录服务

```dart
// lib/services/track_recording_service.dart
class TrackRecordingService {
  final LocationService _locationService;
  final OfflineDatabase _database;
  
  bool _isRecording = false;
  String? _currentRecordId;
  List<TrackPoint> _trackPoints = [];
  DateTime? _startTime;
  double _totalDistance = 0;
  double _elevationGain = 0;
  double _elevationLoss = 0;
  double? _lastAltitude;
  
  // 开始记录
  Future<void> startRecording({String? trailId}) async {
    _isRecording = true;
    _currentRecordId = _generateRecordId();
    _trackPoints = [];
    _startTime = DateTime.now();
    _totalDistance = 0;
    _elevationGain = 0;
    _elevationLoss = 0;
    _lastAltitude = null;
    
    // 开始定位
    await _locationService.startTracking(
      accuracy: LocationAccuracy.bestForNavigation,
      interval: const Duration(seconds: 1),
    );
    
    // 监听位置
    _locationService.positionStream.listen(_onPositionUpdate);
    
    // 创建记录
    await _database.insertTrackRecord(TrackRecordsCompanion(
      id: Value(_currentRecordId!),
      trailId: Value(trailId),
      userId: Value(await _getCurrentUserId()),
      startedAt: Value(_startTime!),
    ));
  }
  
  // 位置更新
  void _onPositionUpdate(Position position) {
    if (!_isRecording) return;
    
    final trackPoint = TrackPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      altitude: position.altitude,
      timestamp: DateTime.now(),
      accuracy: position.accuracy,
    );
    
    // 计算距离和海拔变化
    if (_trackPoints.isNotEmpty) {
      final lastPoint = _trackPoints.last;
      final distance = _calculateDistance(
        LatLng(lastPoint.latitude, lastPoint.longitude),
        LatLng(trackPoint.latitude, trackPoint.longitude),
      );
      _totalDistance += distance;
      
      if (_lastAltitude != null) {
        final elevationDiff = position.altitude - _lastAltitude!;
        if (elevationDiff > 0) {
          _elevationGain += elevationDiff;
        } else {
          _elevationLoss += elevationDiff.abs();
        }
      }
    }
    
    _lastAltitude = position.altitude;
    _trackPoints.add(trackPoint);
    
    // 每30秒保存一次
    if (_trackPoints.length % 30 == 0) {
      _saveTrackPoints();
    }
  }
  
  // 暂停记录
  Future<void> pauseRecording() async {
    _isRecording = false;
    await _locationService.stopTracking();
  }
  
  // 恢复记录
  Future<void> resumeRecording() async {
    _isRecording = true;
    await _locationService.startTracking(
      accuracy: LocationAccuracy.bestForNavigation,
      interval: const Duration(seconds: 1),
    );
  }
  
  // 结束记录
  Future<TrackRecord> stopRecording() async {
    _isRecording = false;
    await _locationService.stopTracking();
    
    final endTime = DateTime.now();
    final duration = endTime.difference(_startTime!).inSeconds;
    
    // 保存最终数据
    await _saveTrackPoints();
    
    // 更新记录
    await _database.updateTrackRecord(
      _currentRecordId!,
      TrackRecordsCompanion(
        endedAt: Value(endTime),
        totalDistanceKm: Value(_totalDistance / 1000),
        durationSec: Value(duration),
        elevationGainM: Value(_elevationGain),
        elevationLossM: Value(_elevationLoss),
      ),
    );
    
    return await _database.getTrackRecord(_currentRecordId!) as TrackRecord;
  }
  
  // 保存轨迹点
  Future<void> _saveTrackPoints() async {
    if (_currentRecordId == null || _trackPoints.isEmpty) return;
    
    await _database.updateTrackRecord(
      _currentRecordId!,
      TrackRecordsCompanion(
        trackPoints: Value(jsonEncode(_trackPoints.map((p) => p.toJson()).toList())),
      ),
    );
  }
}
```

---

## 3. 后端架构（Node.js）

### 3.1 项目结构

```
shanjing-api/
├── src/
│   ├── main.ts                    # 应用入口
│   ├── app.module.ts              # 根模块
│   ├── config/                    # 配置
│   │   ├── database.config.ts
│   │   ├── redis.config.ts
│   │   ├── oss.config.ts
│   │   └── amap.config.ts
│   ├── common/                    # 公共模块
│   │   ├── decorators/            # 装饰器
│   │   ├── filters/               # 异常过滤器
│   │   ├── guards/                # 守卫
│   │   ├── interceptors/          # 拦截器
│   │   ├── pipes/                 # 管道
│   │   └── utils/                 # 工具函数
│   ├── modules/                   # 业务模块
│   │   ├── auth/                  # 认证模块
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.module.ts
│   │   │   ├── dto/
│   │   │   └── strategies/
│   │   ├── users/                 # 用户模块
│   │   ├── trails/                # 路线模块
│   │   ├── pois/                  # POI模块
│   │   ├── navigation/            # 导航模块
│   │   ├── favorites/             # 收藏模块
│   │   ├── tracks/                # 轨迹模块
│   │   ├── files/                 # 文件模块
│   │   ├── admin/                 # 后台模块
│   │   └── health/                # 健康检查
│   ├── database/                  # 数据库
│   │   ├── prisma/
│   │   │   ├── schema.prisma      # 数据库模型
│   │   │   └── migrations/
│   │   └── seeds/                 # 种子数据
│   └── shared/                    # 共享资源
│       ├── services/              # 共享服务
│       └── interfaces/            # 接口定义
├── test/                          # 测试
├── prisma/
├── docker-compose.yml
├── Dockerfile
├── nest-cli.json
├── package.json
└── tsconfig.json
```

### 3.2 API 设计规范

#### 3.2.1 RESTful API 规范

```yaml
# API 设计规范

# 基础URL
base_url: https://api.shanjing.app/v1

# 认证方式
authentication:
  type: Bearer Token
  header: Authorization: Bearer <token>

# 响应格式
response_format:
  success:
    code: 200
    structure:
      success: true
      data: <payload>
      meta: <pagination_info>
  error:
    structure:
      success: false
      error:
        code: <error_code>
        message: <error_message>
        details: <error_details>

# 分页规范
pagination:
  request:
    page: 页码 (默认1)
    limit: 每页数量 (默认20, 最大100)
  response:
    meta:
      page: 当前页
      limit: 每页数量
      total: 总数量
      total_pages: 总页数

# 排序规范
sorting:
  format: sort=<field>:<order>
  example: sort=created_at:desc

# 过滤规范
filtering:
  format: <field>=<value>
  operators:
    eq: 等于 (默认)
    gt: 大于
    lt: 小于
    gte: 大于等于
    lte: 小于等于
    like: 模糊匹配
```

#### 3.2.2 API 接口清单

```yaml
# 认证模块 /auth
POST   /auth/wechat          # 微信登录
POST   /auth/refresh         # 刷新Token
POST   /auth/logout          # 退出登录

# 用户模块 /users
GET    /users/me             # 获取当前用户信息
PUT    /users/me             # 更新用户信息
PUT    /users/me/emergency   # 更新紧急联系人
PUT    /users/me/phone       # 绑定手机号
GET    /users/me/favorites   # 获取收藏列表
GET    /users/me/records     # 获取徒步记录
GET    /users/me/offline     # 获取离线包列表

# 路线模块 /trails
GET    /trails               # 获取路线列表
GET    /trails/nearby        # 获取附近路线
GET    /trails/:id           # 获取路线详情
GET    /trails/:id/offline   # 获取离线包下载信息
POST   /trails/:id/favorite  # 收藏/取消收藏
GET    /trails/:id/pois      # 获取路线POI列表

# POI模块 /pois
GET    /pois/:id             # 获取POI详情
GET    /pois/:id/nearby      # 获取附近POI

# 轨迹模块 /tracks
POST   /tracks               # 创建轨迹记录
PUT    /tracks/:id           # 更新轨迹记录
POST   /tracks/:id/upload    # 上传轨迹数据
GET    /tracks/:id           # 获取轨迹详情
GET    /tracks/:id/export    # 导出GPX文件

# 文件模块 /files
POST   /files/upload         # 上传文件
GET    /files/:id            # 获取文件
POST   /files/presign        # 获取预签名URL

# 后台管理 /admin
GET    /admin/trails         # 路线管理列表
POST   /admin/trails         # 创建路线
PUT    /admin/trails/:id     # 更新路线
DELETE /admin/trails/:id     # 删除路线
GET    /admin/users          # 用户管理列表
GET    /admin/stats          # 统计数据
```

#### 3.2.3 接口详细定义示例

```typescript
// 路线列表接口
// GET /api/v1/trails?lat=30.25&lng=120.15&distance=50&difficulty=easy,moderate&page=1&limit=20

// Request
interface GetTrailsRequest {
  lat?: number;           // 纬度，用于附近搜索
  lng?: number;           // 经度，用于附近搜索
  distance?: number;      // 搜索半径（公里）
  difficulty?: string;    // 难度筛选，逗号分隔
  tags?: string;          // 标签筛选
  min_distance?: number;  // 最小距离
  max_distance?: number;  // 最大距离
  sort?: string;          // 排序方式
  page?: number;          // 页码
  limit?: number;         // 每页数量
}

// Response
interface GetTrailsResponse {
  success: true;
  data: TrailSummary[];
  meta: {
    page: number;
    limit: number;
    total: number;
    total_pages: number;
  };
}

interface TrailSummary {
  id: string;
  name: string;
  cover_image: string;
  distance_km: number;
  duration_min: number;
  difficulty: 'easy' | 'moderate' | 'hard';
  tags: string[];
  location: {
    city: string;
    district: string;
  };
  is_favorite: boolean;
  offline_status: 'none' | 'downloaded' | 'expired';
}

// 路线详情接口
// GET /api/v1/trails/:id

interface TrailDetail {
  id: string;
  name: string;
  description: string;
  distance_km: number;
  duration_min: number;
  elevation_gain_m: number;
  difficulty: 'easy' | 'moderate' | 'hard';
  tags: string[];
  cover_images: string[];
  safety_info: {
    female_friendly: boolean;
    signal_coverage: string;
    evacuation_points: number;
  };
  location: {
    city: string;
    district: string;
    start_point: {
      lat: number;
      lng: number;
      address: string;
    };
  };
  pois: PoiSummary[];
  track_preview: {
    elevation_profile: ElevationPoint[];
    bounds: {
      north: number;
      south: number;
      east: number;
      west: number;
    };
  };
  offline_package: {
    size_mb: number;
    min_zoom: number;
    max_zoom: number;
    expires_at: string;
  };
}
```

### 3.3 数据库设计

#### 3.3.1 Prisma Schema

```prisma
// prisma/schema.prisma

generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

// 用户表
model User {
  id                String   @id @default(cuid())
  wxOpenid          String   @unique @map("wx_openid")
  wxUnionid         String?  @unique @map("wx_unionid")
  nickname          String?
  avatarUrl         String?  @map("avatar_url")
  phone             String?  @unique
  
  // 紧急联系人（JSON存储）
  emergencyContacts Json?    @map("emergency_contacts")
  
  // 关联
  favorites         Favorite[]
  trackRecords      TrackRecord[]
  
  // 时间戳
  createdAt         DateTime @default(now()) @map("created_at")
  updatedAt         DateTime @updatedAt @map("updated_at")
  
  @@map("users")
}

// 路线表
model Trail {
  id               String   @id @default(cuid())
  name             String
  description      String?
  distanceKm       Float    @map("distance_km")
  durationMin      Int      @map("duration_min")
  elevationGainM   Float    @map("elevation_gain_m")
  difficulty       Difficulty
  tags             String[] // PostgreSQL数组类型
  
  // 封面图片
  coverImages      String[] @map("cover_images")
  
  // 轨迹数据（GPX文件URL）
  gpxUrl           String   @map("gpx_url")
  
  // 安全信息
  safetyInfo       Json     @map("safety_info")
  
  // 位置信息
  city             String
  district         String
  startPointLat    Float    @map("start_point_lat")
  startPointLng    Float    @map("start_point_lng")
  startPointAddress String  @map("start_point_address")
  
  // 边界框（用于地图显示）
  boundsNorth      Float    @map("bounds_north")
  boundsSouth      Float    @map("bounds_south")
  boundsEast       Float    @map("bounds_east")
  boundsWest       Float    @map("bounds_west")
  
  // 海拔剖面数据
  elevationProfile Json?    @map("elevation_profile")
  
  // 关联
  pois             Poi[]
  favorites        Favorite[]
  offlinePackages  OfflinePackage[]
  
  // 状态
  isPublished      Boolean  @default(false) @map("is_published")
  publishedAt      DateTime? @map("published_at")
  
  // 时间戳
  createdAt        DateTime @default(now()) @map("created_at")
  updatedAt        DateTime @updatedAt @map("updated_at")
  
  // 空间索引
  @@index([startPointLat, startPointLng])
  @@index([city, district])
  @@index([difficulty])
  @@index([isPublished, publishedAt])
  @@map("trails")
}

// POI表
model Poi {
  id          String   @id @default(cuid())
  trailId     String   @map("trail_id")
  name        String
  type        PoiType
  subtype     String
  
  // 位置（使用PostGIS Point类型）
  location    Unsupported("geometry(Point, 4326)")
  latitude    Float
  longitude   Float
  altitude    Float?
  
  // 序列号（用于排序）
  sequence    Int
  
  // 描述和图片
  description String?
  photos      String[]
  
  // 优先级
  priority    Int      @default(0)
  
  // 扩展信息（根据类型不同）
  metadata    Json?
  
  // 关联
  trail       Trail    @relation(fields: [trailId], references: [id], onDelete: Cascade)
  
  // 时间戳
  createdAt   DateTime @default(now()) @map("created_at")
  
  // 索引
  @@index([trailId, sequence])
  @@index([type])
  @@index([latitude, longitude])
  // PostGIS空间索引
  @@index([location], type: Gist)
  @@map("pois")
}

// 离线包表
model OfflinePackage {
  id          String   @id @default(cuid())
  trailId     String   @map("trail_id")
  
  // 文件信息
  fileUrl     String   @map("file_url")
  fileSizeMb  Float    @map("file_size_mb")
  checksum    String
  
  // 地图配置
  minZoom     Int      @map("min_zoom")
  maxZoom     Int      @map("max_zoom")
  boundsNorth Float    @map("bounds_north")
  boundsSouth Float    @map("bounds_south")
  boundsEast  Float    @map("bounds_east")
  boundsWest  Float    @map("bounds_west")
  
  // 关联
  trail       Trail    @relation(fields: [trailId], references: [id], onDelete: Cascade)
  
  // 时间戳
  createdAt   DateTime @default(now()) @map("created_at")
  expiresAt   DateTime @map("expires_at")
  
  @@index([trailId])
  @@index([expiresAt])
  @@map("offline_packages")
}

// 收藏表
model Favorite {
  id        String   @id @default(cuid())
  userId    String   @map("user_id")
  trailId   String   @map("trail_id")
  
  user      User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  trail     Trail    @relation(fields: [trailId], references: [id], onDelete: Cascade)
  
  createdAt DateTime @default(now()) @map("created_at")
  
  @@unique([userId, trailId])
  @@index([userId])
  @@index([trailId])
  @@map("favorites")
}

// 轨迹记录表
model TrackRecord {
  id              String   @id @default(cuid())
  userId          String   @map("user_id")
  trailId         String?  @map("trail_id")
  
  // 时间
  startedAt       DateTime @map("started_at")
  endedAt         DateTime? @map("ended_at")
  
  // 统计数据
  totalDistanceKm Float?   @map("total_distance_km")
  durationSec     Int?     @map("duration_sec")
  elevationGainM  Float?   @map("elevation_gain_m")
  elevationLossM  Float?   @map("elevation_loss_m")
  
  // 轨迹数据（JSON或文件URL）
  trackDataUrl    String?  @map("track_data_url")
  
  // 照片
  photos          String[]
  
  // 关联
  user            User     @relation(fields: [userId], references: [id], onDelete: Cascade)
  
  // 状态
  isUploaded      Boolean  @default(false) @map("is_uploaded")
  
  // 时间戳
  createdAt       DateTime @default(now()) @map("created_at")
  updatedAt       DateTime @updatedAt @map("updated_at")
  
  @@index([userId])
  @@index([trailId])
  @@index([startedAt])
  @@map("track_records")
}

// 枚举定义
enum Difficulty {
  easy
  moderate
  hard
}

enum PoiType {
  safety      // 安全类
  navigation  // 导航类
  service     // 服务类
  info        // 信息类
  social      // 社交类
}
```

#### 3.3.2 索引优化策略

```sql
-- 空间查询优化（PostGIS）
CREATE INDEX idx_pois_location ON pois USING GIST (location);

-- 附近路线搜索
CREATE INDEX idx_trails_location ON trails (start_point_lat, start_point_lng);

-- 路线筛选
CREATE INDEX idx_trails_filter ON trails (city, difficulty, is_published);

-- POI查询
CREATE INDEX idx_pois_trail_sequence ON pois (trail_id, sequence);
CREATE INDEX idx_pois_type ON pois (type) WHERE type = 'safety';

-- 时间序列查询
CREATE INDEX idx_track_records_user_time ON track_records (user_id, started_at DESC);

-- 全文搜索（路线名称和描述）
CREATE INDEX idx_trails_search ON trails USING GIN (to_tsvector('chinese', name || ' ' || COALESCE(description, '')));
```

### 3.4 缓存策略

#### 3.4.1 Redis 使用场景

| 场景 | 数据类型 | TTL | 说明 |
|------|----------|-----|------|
| 用户会话 | String | 7天 | JWT Token黑名单 |
| 路线列表 | Hash | 1小时 | 热门路线缓存 |
| 路线详情 | String | 30分钟 | 单个路线数据 |
| 附近搜索 | Geo | 15分钟 | 地理位置缓存 |
| 限流计数 | String | 1分钟 | API限流 |
| 热点数据 | String | 5分钟 | 首页推荐数据 |

#### 3.4.2 缓存实现

```typescript
// src/shared/services/cache.service.ts
import { Injectable, Inject } from '@nestjs/common';
import { Redis } from 'ioredis';

@Injectable()
export class CacheService {
  constructor(
    @Inject('REDIS_CLIENT') private readonly redis: Redis,
  ) {}

  // 获取缓存
  async get<T>(key: string): Promise<T | null> {
    const data = await this.redis.get(key);
    return data ? JSON.parse(data) : null;
  }

  // 设置缓存
  async set(key: string, value: any, ttlSeconds?: number): Promise<void> {
    const data = JSON.stringify(value);
    if (ttlSeconds) {
      await this.redis.setex(key, ttlSeconds, data);
    } else {
      await this.redis.set(key, data);
    }
  }

  // 删除缓存
  async del(key: string): Promise<void> {
    await this.redis.del(key);
  }

  // 批量删除（模式匹配）
  async delPattern(pattern: string): Promise<void> {
    const keys = await this.redis.keys(pattern);
    if (keys.length > 0) {
      await this.redis.del(...keys);
    }
  }

  // 地理位置添加
  async geoAdd(key: string, longitude: number, latitude: number, member: string): Promise<void> {
    await this.redis.geoadd(key, longitude, latitude, member);
  }

  // 附近搜索
  async geoRadius(
    key: string,
    longitude: number,
    latitude: number,
    radiusKm: number,
  ): Promise<string[]> {
    return await this.redis.georadius(
      key,
      longitude,
      latitude,
      radiusKm,
      'km',
      'WITHDIST',
      'ASC',
    );
  }
}
```

### 3.5 文件存储

#### 3.5.1 OSS 配置

```typescript
// src/config/oss.config.ts
export const ossConfig = {
  region: process.env.OSS_REGION || 'oss-cn-hangzhou',
  accessKeyId: process.env.OSS_ACCESS_KEY_ID,
  accessKeySecret: process.env.OSS_ACCESS_KEY_SECRET,
  bucket: process.env.OSS_BUCKET || 'shanjing-prod',
  
  // 存储路径规则
  paths: {
    trailImages: 'trails/images/',
    trailGpx: 'trails/gpx/',
    poiImages: 'pois/images/',
    userAvatars: 'users/avatars/',
    trackRecords: 'tracks/',
    tempUploads: 'temp/',
  },
  
  // 图片处理规则
  imageProcessing: {
    thumbnail: '?x-oss-process=image/resize,w_400',
    cover: '?x-oss-process=image/resize,w_800',
    original: '',
  },
};
```

#### 3.5.2 文件服务

```typescript
// src/modules/files/files.service.ts
@Injectable()
export class FilesService {
  private readonly ossClient: OSS;
  
  constructor() {
    this.ossClient = new OSS(ossConfig);
  }
  
  // 获取预签名上传URL
  async getPresignedUploadUrl(
    fileType: string,
    fileExt: string,
    folder: string,
  ): Promise<PresignedUrlResponse> {
    const filename = `${uuidv4()}.${fileExt}`;
    const key = `${folder}${filename}`;
    
    // 生成预签名URL（15分钟有效）
    const url = this.ossClient.signatureUrl(key, {
      method: 'PUT',
      expires: 900,
      'Content-Type': fileType,
    });
    
    return {
      uploadUrl: url,
      accessUrl: `https://${ossConfig.bucket}.${ossConfig.region}.aliyuncs.com/${key}`,
      key,
    };
  }
  
  // 获取预签名下载URL
  async getPresignedDownloadUrl(key: string, expires = 3600): Promise<string> {
    return this.ossClient.signatureUrl(key, {
      method: 'GET',
      expires,
    });
  }
  
  // 删除文件
  async deleteFile(key: string): Promise<void> {
    await this.ossClient.delete(key);
  }
  
  // 获取图片处理URL
  getImageUrl(key: string, style: 'thumbnail' | 'cover' | 'original' = 'original'): string {
    const baseUrl = `https://${ossConfig.bucket}.${ossConfig.region}.aliyuncs.com/${key}`;
    return baseUrl + ossConfig.imageProcessing[style];
  }
}
```

### 3.6 后台管理系统

#### 3.6.1 后台功能模块

```
后台管理系统 (React + Ant Design)
├── 仪表盘
│   ├── 数据概览
│   ├── 用户统计
│   └── 路线统计
├── 路线管理
│   ├── 路线列表
│   ├── 路线创建/编辑
│   ├── POI管理
│   ├── 离线包管理
│   └── 路线审核
├── 用户管理
│   ├── 用户列表
│   ├── 用户详情
│   └── 用户反馈
├── 内容管理
│   ├── 轨迹记录
│   ├── 收藏数据
│   └── 举报处理
├── 系统设置
│   ├── 基础配置
│   ├── 敏感词管理
│   └── 操作日志
└── 数据分析
    ├── 使用统计
    ├── 导航统计
    └── 性能监控
```

#### 3.6.2 后台API

```typescript
// 路线创建
POST /admin/trails
{
  "name": "九溪十八涧环线",
  "description": "...",
  "distanceKm": 8.5,
  "durationMin": 180,
  "elevationGainM": 320,
  "difficulty": "moderate",
  "tags": ["亲子", "摄影", "茶园"],
  "city": "杭州市",
  "district": "西湖区",
  "startPoint": {
    "lat": 30.2345,
    "lng": 120.1234,
    "address": "九溪公交站"
  },
  "safetyInfo": {
    "femaleFriendly": true,
    "signalCoverage": "全程有信号",
    "evacuationPoints": 3
  },
  "coverImages": ["url1", "url2"],
  "gpxUrl": "trails/gpx/xxx.gpx"
}

// POI批量导入
POST /admin/trails/:id/pois/batch
{
  "pois": [
    {
      "name": "龙井村补给点",
      "type": "service",
      "subtype": "补给点",
      "latitude": 30.2345,
      "longitude": 120.1234,
      "sequence": 5,
      "description": "...",
      "priority": 8
    }
  ]
}
```

---

## 4. 关键模块设计

### 4.1 用户系统

#### 4.1.1 微信登录流程

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  客户端  │────▶│ 微信SDK │────▶│ 微信服务器│────▶│  后端API │────▶│  数据库  │
└─────────┘     └─────────┘     └─────────┘     └─────────┘     └─────────┘
     │               │               │               │               │
     │ 1.调起微信登录  │               │               │               │
     │──────────────▶│               │               │               │
     │               │ 2.用户授权     │               │               │
     │               │──────────────▶│               │               │
     │               │ 3.返回auth_code│               │               │
     │               │◀──────────────│               │               │
     │ 4.发送auth_code│               │               │               │
     │──────────────────────────────────────────────▶│               │
     │               │               │ 5.用code换access_token+openid
     │               │               │               │──────────────▶│
     │               │               │ 6.返回用户信息  │               │
     │               │               │◀──────────────│               │
     │               │               │               │ 7.查询/创建用户 │
     │               │               │               │──────────────▶│
     │               │               │               │ 8.返回JWT Token│
     │◀──────────────────────────────────────────────│               │
```

#### 4.1.2 认证实现

```typescript
// src/modules/auth/auth.service.ts
@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
    private readonly wechatService: WechatService,
  ) {}

  async wechatLogin(code: string): Promise<LoginResponse> {
    // 1. 用code换取微信access_token和openid
    const wxData = await this.wechatService.code2Session(code);
    
    // 2. 查询用户是否存在
    let user = await this.prisma.user.findUnique({
      where: { wxOpenid: wxData.openid },
    });
    
    // 3. 不存在则创建新用户
    if (!user) {
      // 获取微信用户信息
      const wxUserInfo = await this.wechatService.getUserInfo(
        wxData.access_token,
        wxData.openid,
      );
      
      user = await this.prisma.user.create({
        data: {
          wxOpenid: wxData.openid,
          wxUnionid: wxData.unionid,
          nickname: wxUserInfo.nickname,
          avatarUrl: wxUserInfo.headimgurl,
        },
      });
    }
    
    // 4. 生成JWT Token
    const tokens = await this.generateTokens(user);
    
    return {
      user: this.sanitizeUser(user),
      tokens,
      isNewUser: !user.phone, // 是否需要绑定手机号
    };
  }
  
  // 手机号绑定
  async bindPhone(userId: string, phoneData: BindPhoneDto): Promise<User> {
    // 验证短信验证码
    await this.smsService.verifyCode(phoneData.phone, phoneData.code);
    
    // 更新用户手机号
    return await this.prisma.user.update({
      where: { id: userId },
      data: { phone: phoneData.phone },
    });
  }
  
  // 生成Token
  private async generateTokens(user: User): Promise<Tokens> {
    const payload = { sub: user.id, openid: user.wxOpenid };
    
    const accessToken = this.jwtService.sign(payload, {
      expiresIn: '2h',
    });
    
    const refreshToken = this.jwtService.sign(payload, {
      expiresIn: '7d',
    });
    
    return { accessToken, refreshToken };
  }
}
```

### 4.2 路线数据模型

#### 4.2.1 数据关系图

```
┌─────────────┐       ┌─────────────┐       ┌─────────────┐
│    User     │       │    Trail    │       │     Poi     │
├─────────────┤       ├─────────────┤       ├─────────────┤
│ id          │       │ id          │◀──────│ trail_id    │
│ wx_openid   │       │ name        │       │ name        │
│ nickname    │       │ distance_km │       │ type        │
│ phone       │       │ difficulty  │       │ latitude    │
│ emergency   │       │ gpx_url     │       │ longitude   │
└─────────────┘       │ safety_info │       │ sequence    │
       │              └─────────────┘       └─────────────┘
       │                     │
       │              ┌──────┴──────┐
       │              │             │
       ▼              ▼             ▼
┌─────────────┐  ┌─────────────┐ ┌─────────────┐
│   Favorite  │  │OfflinePackage│ │ TrackRecord │
├─────────────┤  ├─────────────┤ ├─────────────┤
│ user_id     │  │ trail_id    │ │ user_id     │
│ trail_id    │  │ file_url    │ │ trail_id    │
└─────────────┘  │ file_size   │ │ track_data  │
                 └─────────────┘ │ started_at  │
                                 └─────────────┘
```

#### 4.2.2 GPX数据处理

```typescript
// src/modules/trails/gpx.service.ts
@Injectable()
export class GpxService {
  // 解析GPX文件
  parseGpx(gpxContent: string): GpxData {
    const parser = new xml2js.Parser();
    const result = parser.parseStringSync(gpxContent);
    
    const trackPoints: TrackPoint[] = [];
    const track = result.gpx.trk[0].trkseg[0].trkpt;
    
    for (const point of track) {
      trackPoints.push({
        lat: parseFloat(point.$.lat),
        lng: parseFloat(point.$.lon),
        elevation: parseFloat(point.ele[0]),
        timestamp: new Date(point.time[0]),
      });
    }
    
    // 计算统计数据
    const stats = this.calculateStats(trackPoints);
    
    // 生成海拔剖面
    const elevationProfile = this.generateElevationProfile(trackPoints);
    
    return {
      points: trackPoints,
      bounds: this.calculateBounds(trackPoints),
      ...stats,
      elevationProfile,
    };
  }
  
  // 计算统计数据
  private calculateStats(points: TrackPoint[]): TrailStats {
    let totalDistance = 0;
    let elevationGain = 0;
    let elevationLoss = 0;
    let maxElevation = -Infinity;
    let minElevation = Infinity;
    
    for (let i = 1; i < points.length; i++) {
      const prev = points[i - 1];
      const curr = points[i];
      
      // 距离
      totalDistance += this.haversineDistance(prev, curr);
      
      // 海拔变化
      const elevDiff = curr.elevation - prev.elevation;
      if (elevDiff > 0) {
        elevationGain += elevDiff;
      } else {
        elevationLoss += Math.abs(elevDiff);
      }
      
      // 最高/最低海拔
      maxElevation = Math.max(maxElevation, curr.elevation);
      minElevation = Math.min(minElevation, curr.elevation);
    }
    
    return {
      totalDistanceKm: totalDistance / 1000,
      elevationGainM: elevationGain,
      elevationLossM: elevationLoss,
      maxElevationM: maxElevation,
      minElevationM: minElevation,
    };
  }
  
  // 生成海拔剖面（简化点）
  private generateElevationProfile(points: TrackPoint[]): ElevationPoint[] {
    const simplified = simplify(points, 0.00001, true); // Douglas-Peucker算法
    return simplified.map((p, index) => ({
      distance: this.calculateDistanceFromStart(points, index),
      elevation: p.elevation,
    }));
  }
}
```

### 4.3 离线地图下载与更新机制

#### 4.3.1 下载流程

```
┌─────────┐     ┌─────────┐     ┌─────────┐     ┌─────────┐
│  用户   │────▶│  客户端  │────▶│  后端API │────▶│  高德SDK │
└─────────┘     └─────────┘     └─────────┘     └─────────┘
     │               │               │               │
     │ 点击下载       │               │               │
     │──────────────▶│               │               │
     │               │ 1.请求下载信息  │               │
     │               │──────────────▶│               │
     │               │ 2.返回离线包配置 │               │
     │               │◀──────────────│               │
     │               │ 3.计算下载区域  │               │
     │               │ 4.调用SDK下载   │               │
     │               │──────────────▶│──────────────▶│
     │               │ 5.进度回调     │               │
     │               │◀──────────────│◀──────────────│
     │ 显示进度       │               │               │
     │◀──────────────│               │               │
     │               │ 6.下载完成     │               │
     │               │ 7.保存元数据   │               │
     │               │ 8.通知后端     │               │
     │               │──────────────▶│               │
     │ 下载完成提示   │               │               │
     │◀──────────────│               │               │
```

#### 4.3.2 更新机制

```typescript
// 离线包更新检查
async function checkOfflinePackageUpdates(): Promise<UpdateInfo[]> {
  const localPackages = await database.getAllOfflineTrails();
  const updates: UpdateInfo[] = [];
  
  for (const local of localPackages) {
    // 检查是否过期
    if (local.expiresAt < DateTime.now()) {
      updates.push({
        trailId: local.id,
        type: 'expired',
        message: '离线包已过期，建议重新下载',
      });
      continue;
    }
    
    // 检查服务端是否有更新
    const serverVersion = await api.getOfflinePackageVersion(local.id);
    if (serverVersion.updatedAt > local.downloadedAt) {
      updates.push({
        trailId: local.id,
        type: 'update_available',
        message: '路线数据有更新',
        newSize: serverVersion.sizeMb,
      });
    }
  }
  
  return updates;
}

// 自动清理策略
async function autoCleanupOfflinePackages(): Promise<void> {
  // 1. 删除过期包
  const expired = await database.getExpiringTrails();
  for (const trail of expired) {
    await offlineManager.deleteTrailPackage(trail.id);
  }
  
  // 2. 检查存储空间
  const usage = await offlineManager.getStorageUsage();
  const maxStorage = 500 * 1024 * 1024; // 500MB上限
  
  if (usage.totalBytes > maxStorage) {
    // 按最后使用时间排序，删除最久未使用的
    const trails = await database.getAllTrailsOrderedByLastUsed();
    let freed = 0;
    
    for (const trail of trails) {
      if (usage.totalBytes - freed <= maxStorage * 0.8) break;
      
      const trailSize = await offlineManager.getTrailPackageSize(trail.id);
      await offlineManager.deleteTrailPackage(trail.id);
      freed += trailSize;
    }
  }
}
```

### 4.4 实时导航数据流

#### 4.4.1 数据流架构

```
┌─────────────────────────────────────────────────────────────────┐
│                         GPS硬件层                                │
│                    Android LocationManager                       │
│                         / iOS CoreLocation                       │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ Position (lat, lng, altitude, accuracy)
┌─────────────────────────────────────────────────────────────────┐
│                      高德定位SDK封装层                            │
│              GPS + 北斗双模融合定位                               │
│              网络定位辅助（有网络时）                              │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ Location (优化后的位置)
┌─────────────────────────────────────────────────────────────────┐
│                        位置处理层                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  轨迹匹配    │  │  偏航检测    │  │  平滑滤波    │             │
│  │  MapMatching│  │  Deviation  │  │  Kalman     │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ NavigationState
┌─────────────────────────────────────────────────────────────────┐
│                        业务逻辑层                                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  进度计算    │  │  POI检测    │  │  语音播报    │             │
│  │  ETA计算    │  │  接近提醒    │  │  TTS播报    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼ UI State
┌─────────────────────────────────────────────────────────────────┐
│                          UI层                                   │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │   地图视图   │  │   导航面板   │  │   语音控制   │             │
│  │  MapWidget  │  │  NavPanel   │  │  VoiceUI    │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
└─────────────────────────────────────────────────────────────────┘
```

#### 4.4.2 定位优化策略

```dart
// 定位配置
class LocationConfig {
  // 导航模式（高精度）
  static const navigation = LocationOption(
    desiredAccuracy: DesiredAccuracy.hight,
    distanceFilter: 5,           // 5米更新一次
    pausesLocationUpdatesAutomatically: false,
    allowsBackgroundLocationUpdates: true,
    activityType: ActivityType.fitness,
  );
  
  // 省电模式
  static const powerSave = LocationOption(
    desiredAccuracy: DesiredAccuracy.medium,
    distanceFilter: 20,          // 20米更新一次
    pausesLocationUpdatesAutomatically: true,
  );
}

// 卡尔曼滤波平滑
class KalmanFilter {
  double q = 0.0001;  // 过程噪声
  double r = 0.01;    // 测量噪声
  double x = 0;       // 估计值
  double p = 1;       // 估计误差
  double k = 0;       // 卡尔曼增益
  
  double update(double measurement) {
    // 预测
    p = p + q;
    
    // 更新
    k = p / (p + r);
    x = x + k * (measurement - x);
    p = (1 - k) * p;
    
    return x;
  }
}
```

### 4.5 分享功能

#### 4.5.1 分享图片生成

```dart
// lib/services/share_image_generator.dart
class ShareImageGenerator {
  // 生成路线分享卡片
  static Future<Uint8List> generateTrailCard(Trail trail) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(1080, 1920); // 9:16 适合社交媒体
    
    // 绘制背景
    final bgPaint = Paint()..color = const Color(0xFFF5F5F5);
    canvas.drawRect(Offset.zero & size, bgPaint);
    
    // 绘制封面图
    final coverImage = await _loadImage(trail.coverImages.first);
    _drawImageCover(canvas, coverImage, const Rect.fromLTWH(0, 0, 1080, 1080));
    
    // 绘制信息卡片
    final cardRect = const Rect.fromLTWH(40, 920, 1000, 960);
    _drawCard(canvas, cardRect);
    
    // 绘制路线名称
    _drawText(
      canvas,
      trail.name,
      const Offset(80, 980),
      style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold),
    );
    
    // 绘制数据
    _drawDataRow(canvas, '距离', '${trail.distanceKm}km', const Offset(80, 1100));
    _drawDataRow(canvas, '用时', '${trail.durationMin}分钟', const Offset(400, 1100));
    _drawDataRow(canvas, '爬升', '${trail.elevationGainM}m', const Offset(720, 1100));
    
    // 绘制难度标签
    _drawDifficultyBadge(canvas, trail.difficulty, const Offset(80, 1250));
    
    // 绘制二维码
    final qrCode = await _generateQRCode('https://shanjing.app/t/${trail.id}');
    _drawQRCode(canvas, qrCode, const Offset(780, 1550));
    
    // 绘制品牌标识
    _drawLogo(canvas, const Offset(80, 1750));
    
    // 生成图片
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.width.toInt(), size.height.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    
    return byteData!.buffer.asUint8List();
  }
  
  // 生成徒步记录分享卡片
  static Future<Uint8List> generateRecordCard(TrackRecord record) async {
    // 类似实现，展示轨迹数据
    // ...
  }
}
```

#### 4.5.2 多平台分享适配

```dart
// lib/services/share_service.dart
class ShareService {
  // 分享到微信
  static Future<void> shareToWechat({
    required ShareType type,
    String? title,
    String? description,
    String? imageUrl,
    Uint8List? imageData,
    String? url,
  }) async {
    switch (type) {
      case ShareType.session:
        await Fluwx.shareToWeChat(
          WeChatShareImageModel(
            image: imageData != null 
                ? WeChatImage.binary(imageData) 
                : WeChatImage.network(imageUrl!),
            scene: WeChatScene.SESSION,
          ),
        );
        break;
      case ShareType.timeline:
        await Fluwx.shareToWeChat(
          WeChatShareWebPageModel(
            webPage: url!,
            title: title!,
            description: description,
            thumbnail: WeChatImage.binary(imageData!),
            scene: WeChatScene.TIMELINE,
          ),
        );
        break;
    }
  }
  
  // 系统分享（保存图片）
  static Future<void> shareToSystem(Uint8List imageData) async {
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/share_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(imageData);
    
    await Share.shareXFiles(
      [XFile(file.path)],
      text: '分享我的徒步路线',
    );
  }
}
```

---

## 5. 非功能需求

### 5.1 性能优化

#### 5.1.1 启动优化

| 优化项 | 目标 | 方案 |
|--------|------|------|
| 冷启动时间 | < 3秒 | 延迟加载非核心模块、资源预加载 |
| 首屏渲染 | < 1秒 | 骨架屏、数据预加载 |
| 地图初始化 | < 500ms | 离线地图优先、延迟加载在线资源 |

```dart
// 启动优化配置
void main() {
  // 1. 绑定初始化
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. 并行初始化
  Future.wait([
    // 初始化高德SDK
    AMapService.initialize(),
    // 初始化本地数据库
    OfflineDatabase.initialize(),
    // 预加载必要资源
    AssetLoader.preloadCriticalAssets(),
  ]);
  
  // 3. 延迟初始化非核心服务
  scheduleMicrotask(() {
    AnalyticsService.initialize();
    CrashReporter.initialize();
  });
  
  runApp(const ShanjingApp());
}
```

#### 5.1.2 地图渲染优化

```dart
// 地图性能优化
class MapOptimization {
  // 1. 视口外POI不渲染
  static void optimizePoiDisplay(AMapController controller, List<Poi> pois, LatLngBounds visibleRegion) {
    final visiblePois = pois.where((poi) => 
      visibleRegion.contains(LatLng(poi.latitude, poi.longitude))
    ).toList();
    
    controller.clearMarkers();
    controller.addMarkers(visiblePois.map((p) => _createMarker(p)).toList());
  }
  
  // 2. 轨迹点简化
  static List<LatLng> simplifyTrackPoints(List<LatLng> points, double tolerance) {
    return DouglasPeucker.simplify(points, tolerance);
  }
  
  // 3. 分级加载
  static void loadTilesByZoom(int zoom) {
    if (zoom < 12) {
      // 只显示路线概览
      showTrailOutlineOnly();
    } else if (zoom < 15) {
      // 显示主要POI
      showMajorPois();
    } else {
      // 显示所有POI
      showAllPois();
    }
  }
}
```

#### 5.1.3 内存管理

```dart
// 内存管理策略
class MemoryManager {
  // 图片缓存限制
  static const int maxImageCacheSize = 100 * 1024 * 1024; // 100MB
  
  // 轨迹点限制
  static const int maxTrackPointsInMemory = 10000;
  
  // 定期清理
  static void scheduleCleanup() {
    Timer.periodic(const Duration(minutes: 5), (_) {
      // 清理过期图片缓存
      imageCache.clearLiveImages();
      
      // 清理非活动页面资源
      PaintingBinding.instance.imageCache.clear();
    });
  }
  
  // 低内存处理
  static void handleLowMemory() {
    // 清理地图缓存
    AMapService.clearCache();
    
    // 释放非必要资源
    imageCache.clear();
    
    // 提示用户
    showLowMemoryWarning();
  }
}
```

### 5.2 离线优先策略

#### 5.2.1 数据同步策略

```
┌─────────────────────────────────────────────────────────────────┐
│                      离线优先架构                                │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   ┌─────────────┐         ┌─────────────┐         ┌───────────┐│
│   │   本地数据库 │◀───────▶│  同步引擎    │◀───────▶│  云端API  ││
│   │  (SQLite)   │         │             │         │           ││
│   └─────────────┘         └─────────────┘         └───────────┘│
│          │                       │                       │     │
│          ▼                       ▼                       ▼     │
│   ┌─────────────┐         ┌─────────────┐         ┌───────────┐│
│   │  离线缓存层  │         │  冲突解决器  │         │  版本控制  ││
│   │             │         │             │         │           ││
│   └─────────────┘         └─────────────┘         └───────────┘│
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

#### 5.2.2 冲突处理

```typescript
// 冲突解决策略
enum ConflictResolution {
  CLIENT_WINS = 'client_wins',    // 客户端优先
  SERVER_WINS = 'server_wins',    // 服务端优先
  LAST_WRITE_WINS = 'last_write', // 最后写入优先
  MERGE = 'merge',                // 合并
}

// 冲突检测与解决
async function resolveConflict(
  localData: any,
  serverData: any,
  strategy: ConflictResolution,
): Promise<ResolvedData> {
  // 1. 检测冲突
  if (localData.version === serverData.version) {
    return { data: localData, conflict: false };
  }
  
  // 2. 根据策略解决
  switch (strategy) {
    case ConflictResolution.CLIENT_WINS:
      return { 
        data: { ...localData, version: serverData.version + 1 },
        conflict: true,
        resolution: 'client_wins',
      };
      
    case ConflictResolution.SERVER_WINS:
      return {
        data: serverData,
        conflict: true,
        resolution: 'server_wins',
      };
      
    case ConflictResolution.MERGE:
      return {
        data: mergeData(localData, serverData),
        conflict: true,
        resolution: 'merged',
      };
  }
}
```

### 5.3 安全设计

#### 5.3.1 API鉴权

```typescript
// JWT Guard
@Injectable()
export class JwtAuthGuard implements CanActivate {
  constructor(
    private readonly jwtService: JwtService,
    private readonly prisma: PrismaService,
  ) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const token = this.extractTokenFromHeader(request);
    
    if (!token) {
      throw new UnauthorizedException('缺少认证令牌');
    }
    
    try {
      const payload = this.jwtService.verify(token);
      
      // 检查Token是否在黑名单中
      const isBlacklisted = await this.prisma.tokenBlacklist.findUnique({
        where: { token },
      });
      
      if (isBlacklisted) {
        throw new UnauthorizedException('令牌已失效');
      }
      
      request.user = payload;
      return true;
    } catch (error) {
      throw new UnauthorizedException('无效的认证令牌');
    }
  }
  
  private extractTokenFromHeader(request: Request): string | undefined {
    const [type, token] = request.headers.authorization?.split(' ') ?? [];
    return type === 'Bearer' ? token : undefined;
  }
}
```

#### 5.3.2 数据加密

```typescript
// 敏感数据加密
import { createCipheriv, createDecipheriv, randomBytes, scryptSync } from 'crypto';

export class EncryptionService {
  private readonly algorithm = 'aes-256-gcm';
  private readonly key: Buffer;
  
  constructor() {
    // 从环境变量派生密钥
    this.key = scryptSync(process.env.ENCRYPTION_KEY!, 'salt', 32);
  }
  
  // 加密
  encrypt(text: string): EncryptedData {
    const iv = randomBytes(16);
    const cipher = createCipheriv(this.algorithm, this.key, iv);
    
    let encrypted = cipher.update(text, 'utf8', 'hex');
    encrypted += cipher.final('hex');
    
    const authTag = cipher.getAuthTag();
    
    return {
      encrypted,
      iv: iv.toString('hex'),
      authTag: authTag.toString('hex'),
    };
  }
  
  // 解密
  decrypt(data: EncryptedData): string {
    const decipher = createDecipheriv(
      this.algorithm,
      this.key,
      Buffer.from(data.iv, 'hex'),
    );
    
    decipher.setAuthTag(Buffer.from(data.authTag, 'hex'));
    
    let decrypted = decipher.update(data.encrypted, 'hex', 'utf8');
    decrypted += decipher.final('utf8');
    
    return decrypted;
  }
}

// 使用：加密紧急联系人
const encryptedContacts = encryptionService.encrypt(JSON.stringify(emergencyContacts));
```

#### 5.3.3 隐私保护

```dart
// 位置隐私保护
class PrivacyProtection {
  // 位置模糊化（用于社交分享）
  static LatLng obfuscateLocation(LatLng location, double radiusMeters) {
    final random = Random();
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * radiusMeters;
    
    // 计算偏移后的坐标
    final latOffset = distance * cos(angle) / 111320;
    final lngOffset = distance * sin(angle) / (111320 * cos(location.latitude * pi / 180));
    
    return LatLng(
      location.latitude + latOffset,
      location.longitude + lngOffset,
    );
  }
  
  // 轨迹简化（去除敏感位置）
  static List<LatLng> sanitizeTrack(List<LatLng> points) {
    // 移除起点和终点附近的精确位置（保护住址）
    const privacyRadius = 200; // 200米
    
    return points.where((point, index) {
      if (index < 10 || index > points.length - 10) {
        // 起点和终点区域模糊处理
        return false;
      }
      return true;
    }).toList();
  }
}
```

### 5.4 监控与日志

#### 5.4.1 崩溃上报

```dart
// lib/services/crash_reporter.dart
class CrashReporter {
  static void initialize() {
    // 捕获Flutter异常
    FlutterError.onError = (FlutterErrorDetails details) {
      _reportCrash(
        error: details.exception,
        stackTrace: details.stack,
        context: 'flutter_error',
      );
    };
    
    // 捕获Zone异常
    runZonedGuarded(
      () => runApp(const ShanjingApp()),
      (error, stackTrace) {
        _reportCrash(
          error: error,
          stackTrace: stackTrace,
          context: 'zone_error',
        );
      },
    );
    
    // 捕获原生异常
    if (Platform.isAndroid || Platform.isIOS) {
      Crashlytics.instance.setCrashlyticsCollectionEnabled(true);
    }
  }
  
  static void _reportCrash({
    required dynamic error,
    required StackTrace stackTrace,
    required String context,
  }) {
    // 上报到服务端
    ApiService.post('/analytics/crash', {
      'error': error.toString(),
      'stackTrace': stackTrace.toString(),
      'context': context,
      'appVersion': AppInfo.version,
      'deviceInfo': AppInfo.deviceInfo,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}
```

#### 5.4.2 性能监控

```typescript
// 后端性能监控中间件
@Injectable()
export class PerformanceMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    const start = Date.now();
    
    res.on('finish', () => {
      const duration = Date.now() - start;
      
      // 记录慢请求
      if (duration > 1000) {
        logger.warn(`Slow request: ${req.method} ${req.path} took ${duration}ms`);
      }
      
      // 上报指标
      metrics.timing('http.request.duration', duration, {
        method: req.method,
        path: req.route?.path || req.path,
        status: res.statusCode.toString(),
      });
      
      metrics.increment('http.request.count', {
        method: req.method,
        status: res.statusCode.toString(),
      });
    });
    
    next();
  }
}
```

#### 5.4.3 关键指标监控

| 指标类型 | 指标名称 | 告警阈值 |
|----------|----------|----------|
| 性能 | API响应时间 | > 500ms |
| 性能 | 地图加载时间 | > 2s |
| 稳定性 | 崩溃率 | > 1% |
| 稳定性 | 导航成功率 | < 95% |
| 业务 | 日活跃用户 | 监控趋势 |
| 业务 | 路线下载成功率 | < 98% |

---

## 6. 附录

### 6.1 技术栈版本

| 组件 | 版本 | 说明 |
|------|------|------|
| Flutter | 3.16+ | 稳定版 |
| Dart | 3.2+ | 跟随Flutter |
| Node.js | 18 LTS | 长期支持版 |
| NestJS | 10+ | 最新稳定版 |
| PostgreSQL | 15+ | 主数据库 |
| PostGIS | 3.3+ | 空间扩展 |
| Redis | 7+ | 缓存 |
| Prisma | 5+ | ORM |

### 6.2 环境变量配置

```bash
# 服务端 .env
NODE_ENV=production
PORT=3000
DATABASE_URL=postgresql://user:pass@localhost:5432/shanjing
REDIS_URL=redis://localhost:6379
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=2h

# 微信
WECHAT_APP_ID=wx...
WECHAT_APP_SECRET=...

# 高德
AMAP_API_KEY=...
AMAP_API_SECRET=...

# OSS
OSS_REGION=oss-cn-hangzhou
OSS_ACCESS_KEY_ID=...
OSS_ACCESS_KEY_SECRET=...
OSS_BUCKET=shanjing-prod

# 加密
ENCRYPTION_KEY=your-32-byte-encryption-key

# 客户端 .env
API_BASE_URL=https://api.shanjing.app/v1
AMAP_API_KEY=...
AMAP_API_SECRET=...
```

### 6.3 部署检查清单

- [ ] 环境变量配置正确
- [ ] 数据库迁移已执行
- [ ] 索引已创建
- [ ] Redis连接正常
- [ ] OSS bucket已配置
- [ ] SSL证书有效
- [ ] 日志收集已配置
- [ ] 监控告警已配置
- [ ] 备份策略已配置

### 6.4 参考文档

- [Flutter官方文档](https://docs.flutter.dev)
- [NestJS官方文档](https://docs.nestjs.com)
- [高德地图SDK文档](https://lbs.amap.com)
- [Prisma文档](https://www.prisma.io/docs)
- [PostGIS文档](https://postgis.net/documentation)

---

> **文档维护**: 本文档随项目迭代持续更新，最新版本请查看版本控制系统。
