/**
 * 路线模块
 * 
 * 前端用户使用的路线查询模块
 */

import { Module } from '@nestjs/common';
import { TrailsController } from './trails.controller';
import { TrailsService } from './trails.service';
import { RecordingController } from './recording.controller';
import { RecordingService } from './recording.service';
import { PrismaModule } from '../../database/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [TrailsController, RecordingController],
  providers: [TrailsService, RecordingService],
  exports: [TrailsService, RecordingService],
})
export class TrailsModule {}
