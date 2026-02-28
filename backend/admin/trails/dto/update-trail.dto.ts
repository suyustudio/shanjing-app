// update-trail.dto.ts - 更新路线请求DTO
// 山径APP - 后台管理 API
// 功能：管理员更新路线的数据验证

import { PartialType } from '@nestjs/swagger';
import { CreateTrailDto } from './create-trail.dto';

/**
 * 更新路线请求DTO
 * 
 * 继承自 CreateTrailDto，所有字段变为可选
 * 用于管理员更新路线信息
 */
export class UpdateTrailDto extends PartialType(CreateTrailDto) {}
