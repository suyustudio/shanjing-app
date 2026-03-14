import { Controller, Post, Body, HttpCode, HttpStatus } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { TrailShareDto, TrailShareResponseDto } from './dto/share-trail.dto';

@ApiTags('分享')
@Controller('share')
export class ShareController {
  @Post('trail')
  @HttpCode(HttpStatus.OK)
  @ApiOperation({
    summary: '生成路线分享链接',
    description: '根据路线ID生成分享链接和二维码',
  })
  @ApiResponse({
    status: 200,
    description: '生成成功',
    type: TrailShareResponseDto,
  })
  async shareTrail(@Body() dto: TrailShareDto): Promise<TrailShareResponseDto> {
    // 生成分享链接（mock实现）
    const shareCode = this.generateShareCode();
    const baseUrl = 'https://shanjing.app';
    
    return {
      shareUrl: `${baseUrl}/s/${shareCode}`,
      qrCodeUrl: `${baseUrl}/api/qrcode/${shareCode}.png`,
    };
  }

  private generateShareCode(): string {
    // 生成8位随机分享码
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    let code = '';
    for (let i = 0; i < 8; i++) {
      code += chars.charAt(Math.floor(Math.random() * chars.length));
    }
    return code;
  }
}
