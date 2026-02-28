import { IsString, IsOptional, Length, Matches } from 'class-validator';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

export class PhoneRegisterDto {
  @ApiProperty({ description: '手机号', example: '13800138000' })
  @IsString()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式错误' })
  phone: string;

  @ApiProperty({ description: '短信验证码', example: '123456' })
  @IsString()
  @Length(6, 6, { message: '验证码必须是6位数字' })
  code: string;

  @ApiPropertyOptional({ description: '用户昵称', example: '山径用户' })
  @IsOptional()
  @IsString()
  @Length(2, 20, { message: '昵称长度必须在2-20个字符之间' })
  nickname?: string;
}

export class WechatRegisterDto {
  @ApiProperty({ description: '微信授权code', example: 'wechat_auth_code' })
  @IsString()
  code: string;

  @ApiPropertyOptional({ description: '用户昵称', example: '微信用户' })
  @IsOptional()
  @IsString()
  @Length(2, 20, { message: '昵称长度必须在2-20个字符之间' })
  nickname?: string;
}

export class PhoneLoginDto {
  @ApiProperty({ description: '手机号', example: '13800138000' })
  @IsString()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式错误' })
  phone: string;

  @ApiProperty({ description: '短信验证码', example: '123456' })
  @IsString()
  @Length(6, 6, { message: '验证码必须是6位数字' })
  code: string;
}

export class WechatLoginDto {
  @ApiProperty({ description: '微信授权code', example: 'wechat_auth_code' })
  @IsString()
  code: string;
}

export class RefreshTokenDto {
  @ApiProperty({ description: '刷新令牌', example: 'eyJhbGciOiJIUzI1NiIs...' })
  @IsString()
  refreshToken: string;
}

export class LogoutDto {
  @ApiPropertyOptional({ description: '刷新令牌', example: 'eyJhbGciOiJIUzI1NiIs...' })
  @IsOptional()
  @IsString()
  refreshToken?: string;

  @ApiPropertyOptional({ description: '是否登出所有设备', default: false })
  @IsOptional()
  allDevices?: boolean;
}
