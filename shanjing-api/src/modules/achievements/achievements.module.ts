// ================================================================
// Achievement Module
// 成就系统模块
// ================================================================

import { Module } from '@nestjs/common';
import { AchievementsController, UserStatsController } from './achievements.controller';
import { AchievementsService } from './achievements.service';
import { PrismaModule } from '../../database/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [AchievementsController, UserStatsController],
  providers: [AchievementsService],
  exports: [AchievementsService],
})
export class AchievementsModule {}
