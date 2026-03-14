import { IsNumber, IsNotEmpty, IsOptional } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class SosTriggerDto {
  @ApiProperty({ description: '位置信息' })
  @IsNotEmpty()
  location: {
    lat: number;
    lng: number;
  };

  @ApiProperty({ description: '时间戳', required: false })
  @IsOptional()
  @IsNumber()
  timestamp?: number;
}
