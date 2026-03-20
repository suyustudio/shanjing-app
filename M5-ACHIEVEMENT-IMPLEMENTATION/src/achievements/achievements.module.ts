import { Module } from '@nestjs/common';
import { AchievementsController } from './achievements.controller';
import { AchievementsService } from './achievements.service';
import { AchievementsGateway } from './achievements.gateway';
import { AchievementsCheckerService } from './achievements-checker.service';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [PrismaModule, AuthModule],
  controllers: [AchievementsController],
  providers: [
    AchievementsService,
    AchievementsGateway,
    AchievementsCheckerService,
  ],
  exports: [
    AchievementsService,
    AchievementsGateway,
    AchievementsCheckerService,
  ],
})
export class AchievementsModule {}
