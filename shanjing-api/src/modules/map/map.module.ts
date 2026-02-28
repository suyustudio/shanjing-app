import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AmapConfigService } from './amap-config.service';
import { AmapGeocodeService } from './amap-geocode.service';
import { AmapRouteService } from './amap-route.service';
import { MapController } from './map.controller';

/**
 * 高德地图服务模块
 * 
 * 提供高德地图 Web API 的封装服务，包括：
 * - 地理编码服务（地址转坐标）
 * - 逆地理编码服务（坐标转地址）
 * - 路线规划服务（步行、驾车、骑行）
 * 
 * 使用方式：
 * ```typescript
 * import { MapModule } from './map/map.module';
 * 
 * @Module({
 *   imports: [MapModule],
 * })
 * export class YourModule {}
 * ```
 * 
 * 然后在服务中注入使用：
 * ```typescript
 * constructor(
 *   private readonly amapGeocodeService: AmapGeocodeService,
 *   private readonly amapRouteService: AmapRouteService,
 * ) {}
 * ```
 */
@Module({
  imports: [ConfigModule],
  controllers: [MapController],
  providers: [AmapConfigService, AmapGeocodeService, AmapRouteService],
  exports: [AmapConfigService, AmapGeocodeService, AmapRouteService],
})
export class MapModule {}
