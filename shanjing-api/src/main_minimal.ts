import { NestFactory } from '@nestjs/core';
import { Module, Controller, Post, Body } from '@nestjs/common';
import axios from 'axios';

@Controller('api/v1/map/route')
class MapRouteController {
  @Post('walking')
  async walkingRoute(@Body() body: any) {
    try {
      const origin = `${body.originLng},${body.originLat}`;
      const dest = `${body.destLng},${body.destLat}`;
      const key = process.env.AMAP_KEY || 'f2b9c90a87283d71aa509b1edc43d72a';

      const res = await axios.get('https://restapi.amap.com/v3/direction/walking', {
        params: { key, origin, destination: dest },
        timeout: 10000,
      });

      const data = res.data;
      if (data.status !== '1') {
        return { success: false, errorMessage: data.info || '高德API错误', paths: [] };
      }

      const paths = (data.route?.paths || []).map((p: any) => ({
        distance: parseInt(p.distance || '0'),
        duration: parseInt(p.duration || '0'),
        steps: (p.steps || []).map((s: any) => ({
          instruction: s.instruction || '',
          road: s.road || '',
          distance: parseInt(s.distance || '0'),
          duration: parseInt(s.duration || '0'),
          polyline: (s.polyline || '')
            .split(';')
            .filter((part: string) => part.includes(','))
            .map((part: string) => {
              const [lng, lat] = part.split(',');
              return { lat: parseFloat(lat), lng: parseFloat(lng) };
            }),
          action: s.action,
          assistantAction: s.assistant_action,
        })),
      }));

      return { success: true, paths, origin, destination: dest };
    } catch (e: any) {
      return { success: false, errorMessage: e.message, paths: [] };
    }
  }
}

@Module({
  controllers: [MapRouteController],
})
class AppModule {}

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  app.enableCors();
  await app.listen(3000);
  console.log('✅ 山径后端(最小化)运行在 http://localhost:3000');
  console.log('   POST /api/v1/map/route/walking');
}
bootstrap();
