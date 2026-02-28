/**
 * 高德地图路线规划服务
 * 
 * 提供步行、骑行、驾车等多种出行方式的路线规划功能
 * 文档参考：https://lbs.amap.com/api/webservice/guide/api/direction
 */

import { Injectable, Logger } from '@nestjs/common';
import axios, { AxiosInstance } from 'axios';
import { AmapConfigService } from './amap-config.service';
import {
  WalkingRouteRequest,
  WalkingRouteResult,
  DrivingRouteRequest,
  DrivingRouteResult,
  BicyclingRouteRequest,
  BicyclingRouteResult,
  StandardRouteResult,
  RoutePath,
  RouteStep,
  LatLng,
} from './amap-route.types';

@Injectable()
export class AmapRouteService {
  private readonly logger = new Logger(AmapRouteService.name);
  private readonly httpClient: AxiosInstance;

  constructor(private readonly configService: AmapConfigService) {
    this.httpClient = axios.create({
      timeout: this.configService.getTimeout(),
      headers: {
        'Content-Type': 'application/json',
      },
    });

    // 请求拦截器：添加日志
    this.httpClient.interceptors.request.use((config) => {
      if (this.configService.isLogEnabled()) {
        this.logger.debug(`高德地图路线规划请求: ${config.url}`);
      }
      return config;
    });

    // 响应拦截器：处理错误
    this.httpClient.interceptors.response.use(
      (response) => response,
      (error) => {
        this.logger.error(`高德地图路线规划请求失败: ${error.message}`);
        throw error;
      },
    );
  }

  /**
   * 步行路线规划
   * 
   * @param request 步行路线规划请求参数
   * @returns 标准化的路线规划结果
   * 
   * @example
   * ```typescript
   * const result = await routeService.walkingRoute({
   *   origin: '116.481028,39.989643',
   *   destination: '116.434446,39.90816'
   * });
   * ```
   */
  async walkingRoute(request: WalkingRouteRequest): Promise<StandardRouteResult> {
    try {
      const params = {
        key: this.configService.getApiKey(),
        origin: request.origin,
        destination: request.destination,
        output: 'JSON',
      };

      const response = await this.httpClient.get<WalkingRouteResult>(
        `${this.configService.getBaseUrl()}/direction/walking`,
        { params },
      );

      const data = response.data;

      // 检查API返回状态
      if (data.status !== '1') {
        this.logger.warn(`步行路线规划失败: ${data.info}`);
        return {
          success: false,
          errorMessage: data.info || '步行路线规划失败',
          paths: [],
        };
      }

      // 转换结果格式
      const paths = data.route.paths.map((path) => this.convertWalkingPath(path));

      if (this.configService.isLogEnabled()) {
        this.logger.debug(`步行路线规划成功: 找到 ${paths.length} 条路线`);
      }

      return {
        success: true,
        origin: data.route.origin,
        destination: data.route.destination,
        paths,
      };
    } catch (error) {
      this.logger.error(`步行路线规划请求异常: ${error.message}`);
      return {
        success: false,
        errorMessage: `请求异常: ${error.message}`,
        paths: [],
      };
    }
  }

  /**
   * 驾车路线规划
   * 
   * @param request 驾车路线规划请求参数
   * @returns 标准化的路线规划结果
   * 
   * @example
   * ```typescript
   * const result = await routeService.drivingRoute({
   *   origin: '116.481028,39.989643',
   *   destination: '116.434446,39.90816',
   *   strategy: 10 // 最快路线
   * });
   * ```
   */
  async drivingRoute(request: DrivingRouteRequest): Promise<StandardRouteResult> {
    try {
      const params = {
        key: this.configService.getApiKey(),
        origin: request.origin,
        destination: request.destination,
        strategy: request.strategy || 10,
        waypoints: request.waypoints || '',
        avoidpolygons: request.avoidpolygons || '',
        avoidroad: request.avoidroad || '',
        output: 'JSON',
      };

      const response = await this.httpClient.get<DrivingRouteResult>(
        `${this.configService.getBaseUrl()}/direction/driving`,
        { params },
      );

      const data = response.data;

      // 检查API返回状态
      if (data.status !== '1') {
        this.logger.warn(`驾车路线规划失败: ${data.info}`);
        return {
          success: false,
          errorMessage: data.info || '驾车路线规划失败',
          paths: [],
        };
      }

      // 转换结果格式
      const paths = data.route.paths.map((path) => this.convertDrivingPath(path));

      if (this.configService.isLogEnabled()) {
        this.logger.debug(`驾车路线规划成功: 找到 ${paths.length} 条路线`);
      }

      return {
        success: true,
        origin: data.route.origin,
        destination: data.route.destination,
        paths,
      };
    } catch (error) {
      this.logger.error(`驾车路线规划请求异常: ${error.message}`);
      return {
        success: false,
        errorMessage: `请求异常: ${error.message}`,
        paths: [],
      };
    }
  }

  /**
   * 骑行路线规划
   * 
   * @param request 骑行路线规划请求参数
   * @returns 标准化的路线规划结果
   * 
   * @example
   * ```typescript
   * const result = await routeService.bicyclingRoute({
   *   origin: '116.481028,39.989643',
   *   destination: '116.434446,39.90816'
   * });
   * ```
   */
  async bicyclingRoute(request: BicyclingRouteRequest): Promise<StandardRouteResult> {
    try {
      const params = {
        key: this.configService.getApiKey(),
        origin: request.origin,
        destination: request.destination,
        output: 'JSON',
      };

      const response = await this.httpClient.get<BicyclingRouteResult>(
        `${this.configService.getBaseUrl()}/direction/bicycling`,
        { params },
      );

      const data = response.data;

      // 检查API返回状态
      if (data.status !== '1') {
        this.logger.warn(`骑行路线规划失败: ${data.info}`);
        return {
          success: false,
          errorMessage: data.info || '骑行路线规划失败',
          paths: [],
        };
      }

      // 转换结果格式
      const paths = data.route.paths.map((path) => this.convertBicyclingPath(path));

      if (this.configService.isLogEnabled()) {
        this.logger.debug(`骑行路线规划成功: 找到 ${paths.length} 条路线`);
      }

      return {
        success: true,
        origin: data.route.origin,
        destination: data.route.destination,
        paths,
      };
    } catch (error) {
      this.logger.error(`骑行路线规划请求异常: ${error.message}`);
      return {
        success: false,
        errorMessage: `请求异常: ${error.message}`,
        paths: [],
      };
    }
  }

  /**
   * 批量路线规划
   * 一次性规划多条路线
   * 
   * @param requests 路线规划请求列表
   * @returns 路线规划结果列表
   */
  async batchWalkingRoute(
    requests: WalkingRouteRequest[],
  ): Promise<Map<string, StandardRouteResult>> {
    const results = new Map<string, StandardRouteResult>();

    // 使用 Promise.all 并行处理
    const promises = requests.map(async (request, index) => {
      const result = await this.walkingRoute(request);
      results.set(`route_${index}`, result);
    });

    await Promise.all(promises);

    return results;
  }

  /**
   * 坐标格式化工具
   * 将经纬度数字格式化为 API 需要的字符串格式
   * 
   * @param lat 纬度
   * @param lng 经度
   * @returns 格式化的坐标字符串，如："116.481488,39.990464"
   */
  formatLocation(lat: number, lng: number): string {
    return `${lng},${lat}`;
  }

  /**
   * 解析坐标字符串
   * 
   * @param location 坐标字符串，如："116.481488,39.990464"
   * @returns 经纬度对象
   */
  parseLocation(location: string): LatLng {
    const [lng, lat] = location.split(',').map(Number);
    return { lat, lng };
  }

  /**
   * 将高德返回的步行路线信息转换为标准格式
   */
  private convertWalkingPath(path: any): RoutePath {
    return {
      distance: parseInt(path.distance, 10),
      duration: parseInt(path.duration, 10),
      steps: path.steps.map((step: any) => ({
        instruction: step.instruction,
        road: step.road,
        distance: parseInt(step.distance, 10),
        duration: parseInt(step.duration, 10),
        polyline: this.parsePolyline(step.polyline),
        action: step.action,
        assistantAction: step.assistant_action,
      })),
    };
  }

  /**
   * 将高德返回的驾车路线信息转换为标准格式
   */
  private convertDrivingPath(path: any): RoutePath {
    return {
      distance: parseInt(path.distance, 10),
      duration: parseInt(path.duration, 10),
      tolls: parseFloat(path.tolls || '0'),
      tollDistance: parseInt(path.toll_distance || '0', 10),
      restriction: parseInt(path.restriction || '0', 10) === 1,
      trafficLights: parseInt(path.traffic_lights || '0', 10),
      steps: path.steps.map((step: any) => ({
        instruction: step.instruction,
        road: step.road,
        distance: parseInt(step.distance, 10),
        duration: parseInt(step.duration, 10),
        polyline: this.parsePolyline(step.polyline),
        tolls: parseFloat(step.tolls || '0'),
        tollRoad: step.toll_road,
        action: step.action,
        assistantAction: step.assistant_action,
      })),
    };
  }

  /**
   * 将高德返回的骑行路线信息转换为标准格式
   */
  private convertBicyclingPath(path: any): RoutePath {
    return {
      distance: parseInt(path.distance, 10),
      duration: parseInt(path.duration, 10),
      steps: path.steps.map((step: any) => ({
        instruction: step.instruction,
        road: step.road,
        distance: parseInt(step.distance, 10),
        duration: parseInt(step.duration, 10),
        polyline: this.parsePolyline(step.polyline),
        action: step.action,
        assistantAction: step.assistant_action,
      })),
    };
  }

  /**
   * 解析 polyline 字符串为坐标数组
   * 
   * @param polyline 格式如："116.481488,39.990464;116.481489,39.990465"
   * @returns 坐标数组
   */
  private parsePolyline(polyline: string): LatLng[] {
    if (!polyline) return [];
    
    return polyline.split(';').map((point) => {
      const [lng, lat] = point.split(',').map(Number);
      return { lat, lng };
    });
  }
}
