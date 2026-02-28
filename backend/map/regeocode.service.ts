import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

@Injectable()
export class RegeocodeService {
  private readonly logger = new Logger(RegeocodeService.name);
  private readonly baseUrl = 'https://restapi.amap.com/v3/geocode/regeo';

  constructor(private readonly httpService: HttpService) {}

  async regeocode(longitude: number, latitude: number): Promise<string> {
    const location = `${longitude},${latitude}`;

    try {
      const { data } = await firstValueFrom(
        this.httpService.get(this.baseUrl, {
          params: {
            key: process.env.AMAP_KEY,
            location,
          },
        }),
      );

      if (data.status !== '1') {
        throw new Error(`逆地理编码失败: ${data.info}`);
      }

      return data.regeocode?.formatted_address || '';
    } catch (error) {
      this.logger.error('逆地理编码请求失败:', error.message);
      throw error;
    }
  }
}
