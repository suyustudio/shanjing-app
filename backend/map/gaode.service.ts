import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

export interface RegeocodeRequest {
  lng: number;
  lat: number;
}

export interface RegeocodeResponse {
  success: boolean;
  error?: string;
  address?: string;
  province?: string;
  city?: string;
  district?: string;
  street?: string;
  adcode?: string;
}

@Injectable()
export class GaodeService {
  private readonly logger = new Logger(GaodeService.name);
  private readonly baseUrl = 'https://restapi.amap.com/v3';

  constructor(private readonly httpService: HttpService) {}

  async regeocode(request: RegeocodeRequest): Promise<RegeocodeResponse> {
    try {
      const location = `${request.lng},${request.lat}`;

      const { data } = await firstValueFrom(
        this.httpService.get(`${this.baseUrl}/geocode/regeo`, {
          params: {
            key: process.env.AMAP_KEY,
            location,
            output: 'JSON',
          },
        }),
      );

      if (data.status !== '1') {
        return {
          success: false,
          error: data.info || '逆地理编码失败',
        };
      }

      const component = data.regeocode.addressComponent;

      return {
        success: true,
        address: data.regeocode.formatted_address,
        province: component.province,
        city: component.city,
        district: component.district,
        street: component.street || component.township,
        adcode: component.adcode,
      };
    } catch (error) {
      this.logger.error('逆地理编码请求失败:', error.message);
      return {
        success: false,
        error: error instanceof Error ? error.message : '请求异常',
      };
    }
  }
}
