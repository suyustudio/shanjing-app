import { IsString, IsOptional, Length, Matches, IsArray, ValidateNested, IsObject } from 'class-validator';
import { Type } from 'class-transformer';
import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';

class EmergencyContactDto {
  @ApiProperty({ description: '联系人姓名', example: '张三' })
  @IsString()
  @Length(2, 20, { message: '姓名长度必须在2-20个字符之间' })
  name: string;

  @ApiProperty({ description: '联系人电话', example: '13900139000' })
  @IsString()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式错误' })
  phone: string;

  @ApiProperty({ description: '关系', example: '配偶' })
  @IsString()
  @Length(1, 20, { message: '关系描述长度必须在1-20个字符之间' })
  relation: string;
}

export class UpdateUserDto {
  @ApiPropertyOptional({ description: '用户昵称', example: '新的昵称' })
  @IsOptional()
  @IsString()
  @Length(2, 20, { message: '昵称长度必须在2-20个字符之间' })
  nickname?: string;

  @ApiPropertyOptional({ description: '用户设置', example: { notificationEnabled: true, autoUpload: false } })
  @IsOptional()
  @IsObject()
  settings?: Record<string, any>;
}

export class UpdateEmergencyContactsDto {
  @ApiProperty({ description: '紧急联系人列表', type: [EmergencyContactDto] })
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => EmergencyContactDto)
  contacts: EmergencyContactDto[];
}

export class BindPhoneDto {
  @ApiProperty({ description: '手机号', example: '13800138000' })
  @IsString()
  @Matches(/^1[3-9]\d{9}$/, { message: '手机号格式错误' })
  phone: string;

  @ApiProperty({ description: '短信验证码', example: '123456' })
  @IsString()
  @Length(6, 6, { message: '验证码必须是6位数字' })
  code: string;
}
