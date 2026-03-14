/**
 * 路线模块
 * 
 * 前端用户使用的路线查询模块
 */

import { Module } from '@nestjs/common';
import { TrailsController } from './trails.controller';
import { TrailsService } from './trails.service';
import { PrismaModule } from '../../database/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [TrailsController],
  providers: [TrailsService],
  exports: [TrailsService],
})
export class TrailsModule {}
