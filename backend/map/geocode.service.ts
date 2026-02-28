import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

export interface GeocodeResult {
  longitude: number;
  latitude: number;
}

@Injectable()
export class GeocodeService {
  private readonly logger = new Logger(GeocodeService.name);
  private readonly baseUrl = 'https://restapi.amap.com/v3/geocode/geo';

  constructor(private readonly httpService: HttpService) {}

  async geocode(address: string): Promise<GeocodeResult | null> {
    if (!address || address.trim() === '') {
      return null;
    }

    try {
      const { data } = await firstValueFrom(
        this.httpService.get(this.baseUrl, {
          params: {
            key: process.env.AMAP_KEY,
            address: address.trim(),
          },
        }),
      );

      if (data.status !== '1' || !data.geocodes?.[0]) {
        return null;
      }

      const [longitude, latitude] = data.geocodes[0].location.split(',').map(Number);

      return { longitude, latitude };
    } catch (error) {
      this.logger.error('地理编码请求失败:', error.message);
      return null;
    }
  }
}
