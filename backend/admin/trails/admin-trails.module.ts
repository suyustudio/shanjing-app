// admin-trails.module.ts - 后台管理路线模块
// 山径APP - 后台管理 API

import { Module } from '@nestjs/common';
import { AdminTrailsController } from './admin-trails.controller';
import { AdminTrailsService } from './admin-trails.service';

/**
 * 后台管理路线模块
 * 
 * 提供管理员路线管理功能：
 * - 创建路线
 * - 更新路线
 * - 删除路线
 */
@Module({
  controllers: [AdminTrailsController],
  providers: [AdminTrailsService],
  exports: [AdminTrailsService],
})
export class AdminTrailsModule {}
