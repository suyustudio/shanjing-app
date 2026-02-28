import { Injectable, Logger } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';

interface RoutePoint {
  longitude: number;
  latitude: number;
}

interface RouteResult {
  distance: number;
  duration: number;
  polyline: string;
}

@Injectable()
export class RouteService {
  private readonly logger = new Logger(RouteService.name);
  private readonly baseUrl = 'https://restapi.amap.com/v3/direction/driving';

  constructor(private readonly httpService: HttpService) {}

  async planRoute(origin: RoutePoint, destination: RoutePoint): Promise<RouteResult> {
    const originStr = `${origin.longitude},${origin.latitude}`;
    const destStr = `${destination.longitude},${destination.latitude}`;

    try {
      const { data } = await firstValueFrom(
        this.httpService.get(this.baseUrl, {
          params: {
            key: process.env.AMAP_KEY,
            origin: originStr,
            destination: destStr,
            extensions: 'base',
          },
        }),
      );

      if (data.status !== '1' || !data.route?.paths?.[0]) {
        throw new Error(data.info || '路线规划失败');
      }

      const path = data.route.paths[0];

      return {
        distance: parseInt(path.distance, 10),
        duration: parseInt(path.duration, 10),
        polyline: path.polyline || '',
      };
    } catch (error) {
      this.logger.error('路线规划请求失败:', error.message);
      throw error;
    }
  }
}
