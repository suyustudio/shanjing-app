/**
 * 后台管理 - 路线管理模块
 */

import { Module } from '@nestjs/common';
import { AdminTrailsController } from './admin-trails.controller';
import { AdminTrailsService } from './admin-trails.service';

@Module({
  controllers: [AdminTrailsController],
  providers: [AdminTrailsService],
  exports: [AdminTrailsService],
})
export class AdminTrailsModule {}
