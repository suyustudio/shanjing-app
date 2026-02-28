# 高德地图服务配置文档

## 概述

本文档描述了山径APP后端服务中高德地图API的集成配置和使用方法。

## 功能模块

### 1. 配置模块 (AmapConfigService)

负责加载和管理高德地图API的配置信息。

### 2. 地理编码服务 (AmapGeocodeService)

提供地址与坐标之间的相互转换功能：
- **地理编码**：地址转经纬度坐标
- **逆地理编码**：经纬度坐标转地址

## 环境变量配置

在项目的 `.env` 文件中添加以下配置项：

```env
# 高德地图 API 配置（必填）
AMAP_API_KEY=your_amap_api_key_here

# 高德地图安全密钥（可选，用于数字签名）
# AMAP_SECURITY_CONFIG=your_security_config

# API 基础 URL（可选，默认使用高德官方地址）
# AMAP_BASE_URL=https://restapi.amap.com/v3

# 请求超时时间，单位毫秒（可选，默认10000）
# AMAP_TIMEOUT=10000

# 是否启用请求日志（可选，默认false）
# AMAP_ENABLE_LOG=true
```

## 获取高德地图 API Key

1. 访问 [高德开放平台](https://lbs.amap.com/)
2. 注册并登录账号
3. 进入「控制台」→「应用管理」→「我的应用」
4. 点击「创建新应用」，填写应用名称（如：山径APP）
5. 在应用下点击「添加Key」
6. 选择「Web服务」类型，提交后即可获得 API Key

## 模块集成

### 1. 导入模块

在需要使用地图服务的模块中导入 `MapModule`：

```typescript
import { Module } from '@nestjs/common';
import { MapModule } from './map/map.module';
import { TrailsService } from './trails.service';
import { TrailsController } from './trails.controller';

@Module({
  imports: [MapModule],
  controllers: [TrailsController],
  providers: [TrailsService],
})
export class TrailsModule {}
```

或者在全局模块中导入：

```typescript
// app.module.ts
import { Module } from '@nestjs/common';
import { MapModule } from './modules/map/map.module';

@Module({
  imports: [
    MapModule,  // 地图服务模块
    // ... 其他模块
  ],
})
export class AppModule {}
```

### 2. 使用地理编码服务

```typescript
import { Injectable } from '@nestjs/common';
import { AmapGeocodeService } from '../map/amap-geocode.service';

@Injectable()
export class TrailsService {
  constructor(
    private readonly amapGeocodeService: AmapGeocodeService,
  ) {}

  /**
   * 示例：根据地址获取坐标
   */
  async getCoordinatesByAddress(address: string, city?: string) {
    const result = await this.amapGeocodeService.geocode({
      address,
      city,
    });

    if (!result.success) {
      throw new Error(`地理编码失败: ${result.errorMessage}`);
    }

    return result.locations;
  }

  /**
   * 示例：根据坐标获取地址
   */
  async getAddressByCoordinates(lat: number, lng: number) {
    const location = this.amapGeocodeService.formatLocation(lat, lng);
    
    const result = await this.amapGeocodeService.regeocode({
      location,
      extensions: 'all',  // 返回详细地址信息和附近POI
      radius: 1000,       // 搜索半径1000米
    });

    if (!result.success) {
      throw new Error(`逆地理编码失败: ${result.errorMessage}`);
    }

    return {
      address: result.formattedAddress,
      component: result.addressComponent,
      nearbyPois: result.pois,
    };
  }
}
```

## API 接口说明

### 地理编码 (Geocode)

将结构化地址转换为经纬度坐标。

**接口：** `POST /api/v1/map/geocode`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| address | string | 是 | 结构化地址，如：北京市朝阳区阜通东大街6号 |
| city | string | 否 | 指定地址所在城市，如：北京/北京市/BEIJING |

**响应示例：**

```json
{
  "success": true,
  "data": {
    "locations": [
      {
        "location": {
          "lat": 39.990464,
          "lng": 116.481488
        },
        "formattedAddress": "北京市朝阳区望京街道阜通东大街6号",
        "country": "中国",
        "province": "北京市",
        "city": "北京市",
        "district": "朝阳区",
        "street": "阜通东大街",
        "streetNumber": "6号",
        "adcode": "110105",
        "level": "门址"
      }
    ]
  }
}
```

### 逆地理编码 (Regeocode)

将经纬度坐标转换为结构化地址。

**接口：** `POST /api/v1/map/regeocode`

**请求参数：**

| 参数名 | 类型 | 必填 | 说明 |
|--------|------|------|------|
| lat | number | 是 | 纬度，如：39.990464 |
| lng | number | 是 | 经度，如：116.481488 |
| extensions | string | 否 | 返回结果控制：base(默认)/all |
| radius | number | 否 | 搜索半径，单位：米，范围：0-3000，默认1000 |

**响应示例：**

```json
{
  "success": true,
  "data": {
    "formattedAddress": "北京市朝阳区望京街道阜通东大街6号方恒国际中心",
    "addressComponent": {
      "country": "中国",
      "province": "北京市",
      "city": "北京市",
      "district": "朝阳区",
      "township": "望京街道",
      "neighborhood": "",
      "building": "方恒国际中心",
      "street": "阜通东大街",
      "number": "6号",
      "adcode": "110105"
    },
    "pois": [
      {
        "id": "B000A7BGD1",
        "name": "方恒国际中心",
        "type": "商务住宅;楼宇;商务写字楼",
        "distance": 0,
        "address": "阜通东大街6号",
        "location": {
          "lat": 39.990464,
          "lng": 116.481488
        }
      }
    ]
  }
}
```

## 错误处理

服务会自动处理以下错误情况：

1. **API Key 未配置**：启动时抛出错误，提示配置 AMAP_API_KEY
2. **请求超时**：默认10秒超时，可通过环境变量调整
3. **API 返回错误**：返回包含错误信息的标准化结果
4. **网络异常**：捕获并包装为友好错误信息

## 日志记录

设置 `AMAP_ENABLE_LOG=true` 可启用请求日志记录，包括：
- 请求 URL
- 请求参数
- 响应结果数量
- 错误信息

**注意：** 生产环境建议关闭日志或配置适当的日志级别，避免敏感信息泄露。

## 限制说明

1. **调用频次限制**：请参考高德开放平台的相关配额说明
2. **坐标系**：高德地图使用 GCJ-02 坐标系（国测局坐标）
3. **覆盖范围**：主要覆盖中国大陆地区

## 扩展计划

后续可扩展的地图服务功能：

1. **路径规划**：步行、骑行、驾车路径规划
2. **静态地图**：生成地图图片
3. **天气查询**：获取指定位置天气信息
4. **POI搜索**：周边兴趣点搜索
5. **行政区域查询**：省市区边界查询

## 参考文档

- [高德地图 Web服务 API 文档](https://lbs.amap.com/api/webservice/summary)
- [地理编码 API](https://lbs.amap.com/api/webservice/guide/api/georegeo#geo)
- [逆地理编码 API](https://lbs.amap.com/api/webservice/guide/api/georegeo#regeo)
