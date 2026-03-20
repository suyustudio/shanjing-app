# 路线轨迹采集功能 - 实现文档

## 概述

本文档描述了山径APP路线轨迹采集功能的完整实现，包括移动端Flutter代码和后端NestJS API。

## 功能范围

### P0 核心功能 (已实现)

1. **轨迹记录**
   - GPS 每秒 1 点高精度记录
   - 实时显示已记录距离、时长
   - 轨迹线实时绘制在地图上

2. **POI 标记**
   - 一键标记当前位置
   - POI 类型选择（起点、终点、路口、观景点、卫生间、补给点、危险点、休息点）
   - 拍照关联到 POI

3. **基础控制**
   - 开始/暂停/继续/结束录制
   - 显示录制状态（距离、时长、POI数量、照片数量）

4. **离线保存**
   - 轨迹数据本地存储（SharedPreferences）
   - 有网络后上传到后台

### P1 功能 (后续迭代)

- 语音备注
- 分段标记（平路/爬升/下降）

## 技术方案

### 移动端 (Flutter)

- **定位**: `amap_flutter_location` + 前台服务
- **地图**: 高德 SDK (`amap_flutter_map`)
- **存储**: 本地 SharedPreferences + 上传后 PostgreSQL
- **拍照**: `image_picker`

### 后端 (NestJS)

- **数据库**: PostgreSQL + Prisma ORM
- **API**: RESTful API with Swagger文档
- **文件存储**: 阿里云OSS (复用现有文件服务)

## 创建的文件

### 1. 移动端文件

```
lib/
├── models/
│   └── recording_model.dart      # 录制数据模型
├── services/
│   └── recording_service.dart    # 录制逻辑服务
├── screens/
│   └── recording_screen.dart     # 录制主界面
└── widgets/
    └── poi_marker_dialog.dart    # POI标记弹窗
```

### 2. 后端文件

```
shanjing-api/src/modules/trails/
├── dto/
│   └── recording.dto.ts          # 数据传输对象
├── recording.controller.ts       # API控制器
└── recording.service.ts          # 业务逻辑服务
```

### 3. 数据库Schema更新

```prisma
// prisma/schema.prisma
model TrailRecording {
  id                String          @id @default(uuid())
  userId            String
  sessionId         String
  trailName         String
  description       String?
  city              String
  district          String
  difficulty        TrailDifficulty
  tags              String[]
  status            RecordingStatus @default(PENDING)
  trailId           String?
  reviewComment     String?
  reviewedAt        DateTime?
  distanceMeters    Float
  durationSeconds   Int
  elevationGain     Float
  elevationLoss     Float
  pointCount        Int
  poiCount          Int
  trackData         Json
  createdAt         DateTime        @default(now())
  updatedAt         DateTime        @updatedAt
  
  user              User            @relation(fields: [userId], references: [id])
  trail             Trail?          @relation(fields: [trailId], references: [id])
}

enum RecordingStatus {
  PENDING
  APPROVED
  REJECTED
}
```

## 使用说明

### 启动录制

```dart
// 获取RecordingService实例
final recordingService = context.read<RecordingService>();

// 初始化服务
await recordingService.initialize();

// 开始录制
await recordingService.startRecording(trailName: '我的路线');
```

### 添加POI标记

```dart
// 显示POI标记弹窗
PoiMarkerDialog.show(
  context: context,
  onConfirm: (type, name, description, photos) {
    recordingService.addPoi(
      type: type,
      name: name,
      description: description,
    );
  },
);
```

### 结束并上传

```dart
// 结束录制
final session = await recordingService.stopRecording();

// 上传轨迹
final response = await recordingService.uploadTrail(
  sessionId: session.id,
  trailName: '路线名称',
  city: '杭州',
  district: '西湖区',
  difficulty: 'EASY',
);
```

## API接口

### 用户端接口

| 方法 | 路径 | 描述 |
|------|------|------|
| POST | `/trails/recording/upload` | 上传轨迹录制数据 |
| GET  | `/trails/recording/my-recordings` | 获取我的录制记录 |
| GET  | `/trails/recording/my-recordings/:id` | 获取录制详情 |

### 管理员接口

| 方法 | 路径 | 描述 |
|------|------|------|
| GET  | `/trails/recording/admin/pending` | 获取待审核列表 |
| POST | `/trails/recording/admin/:id/approve` | 审核通过 |
| POST | `/trails/recording/admin/:id/reject` | 审核拒绝 |

## 录制状态流程

```
[开始录制] → [录制中] → [暂停/继续] → [结束录制] → [上传] → [待审核] → [审核通过/拒绝]
                ↓
            [本地保存]
                ↓
            [放弃录制]
```

## 数据结构

### TrackPoint (轨迹点)

```json
{
  "latitude": 30.259,
  "longitude": 120.148,
  "altitude": 15.5,
  "accuracy": 8.0,
  "speed": 1.2,
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### PoiMarker (POI标记)

```json
{
  "id": "poi_123456",
  "latitude": 30.260,
  "longitude": 120.149,
  "altitude": 18.0,
  "type": "viewpoint",
  "name": "观景台",
  "description": "可以俯瞰西湖",
  "photoUrls": ["url1", "url2"],
  "createdAt": "2024-01-15T10:35:00Z"
}
```

### RecordingSession (录制会话)

```json
{
  "id": "rec_123456",
  "trailName": "西湖环湖",
  "status": "finished",
  "startTime": "2024-01-15T10:00:00Z",
  "endTime": "2024-01-15T12:00:00Z",
  "durationSeconds": 7200,
  "totalDistanceMeters": 10500,
  "elevationGain": 85.5,
  "elevationLoss": 82.0,
  "trackPoints": [...],
  "pois": [...],
  "isUploaded": false
}
```

## 待办事项

### 前端

- [ ] 添加`image_picker`依赖到pubspec.yaml
- [ ] 在导航中添加录制入口
- [ ] 录制列表页面（显示所有本地和已上传的录制）
- [ ] 录制详情页面（查看已完成的录制）
- [ ] 轨迹回放功能
- [ ] 导出GPX文件功能

### 后端

- [ ] 运行`prisma migrate dev`创建新表
- [ ] 在TrailsModule中注册RecordingController和RecordingService
- [ ] 配置照片上传接口（关联POI照片）
- [ ] 实现后台审核界面API

### P1功能 (后续迭代)

- [ ] 语音备注功能
- [ ] 分段标记（平路/爬升/下降）
- [ ] 轨迹编辑（删除错误点）
- [ ] 实时同步（WebSocket）

## 注意事项

1. **GPS精度**: 应用过滤掉精度大于20米的定位点
2. **最小移动距离**: 过滤掉小于3米的移动，减少GPS抖动
3. **电池优化**: 长时间录制时请携带充电宝
4. **存储空间**: 轨迹数据会占用本地存储空间，建议定期清理已上传的记录
5. **网络要求**: 上传需要网络连接，但录制过程完全离线可用

## 测试建议

1. 在实际户外环境测试GPS精度
2. 测试长时间录制（2-3小时）的稳定性
3. 测试弱信号/无信号环境下的离线功能
4. 测试应用被杀后台后恢复录制的能力
5. 测试照片上传和关联功能

## 性能指标

- GPS采样率: 1秒/点
- 轨迹点存储: 本地SQLite/SharedPreferences
- 地图轨迹渲染: 实时更新（每秒）
- 上传压缩: 轨迹数据gzip压缩后上传
