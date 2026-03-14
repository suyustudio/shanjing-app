import { Controller, Post, Body, Logger } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse } from '@nestjs/swagger';
import { SosTriggerDto } from './dto/sos-trigger.dto';

@ApiTags('SOS紧急求助')
@Controller('sos')
export class SosController {
  private readonly logger = new Logger(SosController.name);

  @Post('trigger')
  @ApiOperation({ summary: '触发SOS紧急求助' })
  @ApiResponse({ status: 200, description: 'SOS已触发' })
  async triggerSos(@Body() dto: SosTriggerDto) {
    const timestamp = dto.timestamp || Date.now();
    
    this.logger.warn(`🆘 SOS触发 - 位置: [${dto.location.lat}, ${dto.location.lng}], 时间: ${new Date(timestamp).toISOString()}`);
    
    // TODO: 后续接入真实短信服务
    this.logger.log('📱 模拟发送紧急短信通知...');

    return {
      success: true,
      message: 'SOS紧急求助已触发，救援人员将尽快联系您',
    };
  }
}
