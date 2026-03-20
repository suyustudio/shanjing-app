// ================================================================
// Achievement Module
// 成就系统模块
// ================================================================

import { Module } from '@nestjs/common';
import { AchievementsController, UserStatsController, AchievementCacheController } from './achievements.controller';
import { AchievementsService } from './achievements.service';
import { AchievementsCheckerService } from './achievements-checker.service';
import { PrismaModule } from '../../database/prisma.module';
import { RedisModule } from '../../shared/redis/redis.module';

@Module({
  imports: [PrismaModule, RedisModule],
  controllers: [AchievementsController, UserStatsController, AchievementCacheController],
  providers: [AchievementsService, AchievementsCheckerService],
  exports: [AchievementsService, AchievementsCheckerService],
})
export class AchievementsModule {}
