import { ApiProperty } from '@nestjs/swagger';
import { IsString, IsNotEmpty } from 'class-validator';

export class TrailShareDto {
  @ApiProperty({ description: '路线ID', example: 'trail_123456' })
  @IsString()
  @IsNotEmpty()
  trailId: string;
}

export class TrailShareResponseDto {
  @ApiProperty({ description: '分享链接', example: 'https://shanjing.app/share/trail_123456' })
  shareUrl: string;

  @ApiProperty({ description: '二维码图片链接', example: 'https://shanjing.app/qrcode/trail_123456.png' })
  qrCodeUrl: string;
}
