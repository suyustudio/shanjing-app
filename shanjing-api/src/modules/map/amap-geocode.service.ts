import { Injectable, Logger } from '@nestjs/common';
import axios, { AxiosInstance } from 'axios';
import { AmapConfigService } from './amap-config.service';
import {
  GeocodeRequest,
  GeocodeResult,
  RegeocodeRequest,
  RegeocodeResult,
  StandardGeocodeResult,
  StandardRegeocodeResult,
  LocationInfo,
  LatLng,
  AddressComponentDetail,
  PoiDetail,
} from './amap.types';

/**
 * 高德地图地理编码服务
 * 
 * 提供地址与坐标之间的相互转换功能：
 * 1. 地理编码：地址转坐标
 * 2. 逆地理编码：坐标转地址
 * 
 * 文档参考：https://lbs.amap.com/api/webservice/guide/api/georegeo
 */
@Injectable()
export class AmapGeocodeService {
  private readonly logger = new Logger(AmapGeocodeService.name);
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
        this.logger.debug(`高德地图请求: ${config.url}`);
      }
      return config;
    });

    // 响应拦截器：处理错误
    this.httpClient.interceptors.response.use(
      (response) => response,
      (error) => {
        this.logger.error(`高德地图请求失败: ${error.message}`);
        throw error;
      },
    );
  }

  /**
   * 地理编码：将地址转换为经纬度坐标
   * 
   * @param request 地理编码请求参数
   * @returns 标准化的地理编码结果
   * 
   * @example
   * ```typescript
   * const result = await geocodeService.geocode({
   *   address: '北京市朝阳区阜通东大街6号',
   *   city: '北京'
   * });
   * ```
   */
  async geocode(request: GeocodeRequest): Promise<StandardGeocodeResult> {
    try {
      const params = {
        key: this.configService.getApiKey(),
        address: request.address,
        city: request.city || '',
        output: 'JSON',
      };

      const response = await this.httpClient.get<GeocodeResult>(
        `${this.configService.getBaseUrl()}/geocode/geo`,
        { params },
      );

      const data = response.data;

      // 检查API返回状态
      if (data.status !== '1') {
        this.logger.warn(`地理编码失败: ${data.info}`);
        return {
          success: false,
          errorMessage: data.info || '地理编码失败',
          locations: [],
        };
      }

      // 转换结果格式
      const locations = data.geocodes.map((item) => this.convertToLocationInfo(item));

      if (this.configService.isLogEnabled()) {
        this.logger.debug(`地理编码成功: 找到 ${locations.length} 个结果`);
      }

      return {
        success: true,
        locations,
      };
    } catch (error) {
      this.logger.error(`地理编码请求异常: ${error.message}`);
      return {
        success: false,
        errorMessage: `请求异常: ${error.message}`,
        locations: [],
      };
    }
  }

  /**
   * 逆地理编码：将经纬度坐标转换为地址
   * 
   * @param request 逆地理编码请求参数
   * @returns 标准化的逆地理编码结果
   * 
   * @example
   * ```typescript
   * const result = await geocodeService.regeocode({
   *   location: '116.481488,39.990464',
   *   extensions: 'all',
   *   radius: 1000
   * });
   * ```
   */
  async regeocode(request: RegeocodeRequest): Promise<StandardRegeocodeResult> {
    try {
      const params = {
        key: this.configService.getApiKey(),
        location: request.location,
        poitype: request.poitype || '',
        radius: request.radius || 1000,
        extensions: request.extensions || 'base',
        homeorcorp: request.homeorcorp || '',
        output: 'JSON',
      };

      const response = await this.httpClient.get<RegeocodeResult>(
        `${this.configService.getBaseUrl()}/geocode/regeo`,
        { params },
      );

      const data = response.data;

      // 检查API返回状态
      if (data.status !== '1') {
        this.logger.warn(`逆地理编码失败: ${data.info}`);
        return {
          success: false,
          errorMessage: data.info || '逆地理编码失败',
          formattedAddress: '',
          addressComponent: {} as AddressComponentDetail,
        };
      }

      const result = this.convertToRegeocodeResult(data);

      if (this.configService.isLogEnabled()) {
        this.logger.debug(`逆地理编码成功: ${result.formattedAddress}`);
      }

      return result;
    } catch (error) {
      this.logger.error(`逆地理编码请求异常: ${error.message}`);
      return {
        success: false,
        errorMessage: `请求异常: ${error.message}`,
        formattedAddress: '',
        addressComponent: {} as AddressComponentDetail,
      };
    }
  }

  /**
   * 批量地理编码
   * 一次性转换多个地址
   * 
   * @param addresses 地址列表
   * @param city 可选的城市参数（应用于所有地址）
   * @returns 地理编码结果列表
   */
  async batchGeocode(
    addresses: string[],
    city?: string,
  ): Promise<Map<string, StandardGeocodeResult>> {
    const results = new Map<string, StandardGeocodeResult>();

    // 使用 Promise.all 并行处理
    const promises = addresses.map(async (address) => {
      const result = await this.geocode({ address, city });
      results.set(address, result);
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
   * 将高德返回的地理编码信息转换为标准格式
   */
  private convertToLocationInfo(item: any): LocationInfo {
    const location = this.parseLocation(item.location);

    return {
      location,
      formattedAddress: item.formatted_address || '',
      country: item.country || '中国',
      province: item.province || '',
      city: item.city || '',
      district: item.district || '',
      street: item.street || item.addressComponent?.street || '',
      streetNumber: item.number || item.addressComponent?.number || '',
      adcode: item.adcode || '',
      level: item.level || '',
    };
  }

  /**
   * 将高德返回的逆地理编码结果转换为标准格式
   */
  private convertToRegeocodeResult(data: RegeocodeResult): StandardRegeocodeResult {
    const regeocode = data.regeocode;
    const component = regeocode.addressComponent;

    const addressComponent: AddressComponentDetail = {
      country: component.country || '中国',
      province: component.province || '',
      city: component.city || '',
      district: component.district || '',
      township: component.township || '',
      neighborhood: component.neighborhood?.name || '',
      building: component.building?.name || '',
      street: component.street || '',
      number: component.number || '',
      adcode: component.adcode || '',
    };

    const result: StandardRegeocodeResult = {
      success: true,
      formattedAddress: regeocode.formatted_address,
      addressComponent,
    };

    // 如果有POI信息，一并返回
    if (regeocode.pois && regeocode.pois.length > 0) {
      result.pois = regeocode.pois.map((poi) => ({
        id: poi.id,
        name: poi.name,
        type: poi.type,
        tel: poi.tel,
        distance: poi.distance ? parseInt(poi.distance, 10) : undefined,
        address: poi.address,
        location: this.parseLocation(poi.location),
      }));
    }

    return result;
  }
}
