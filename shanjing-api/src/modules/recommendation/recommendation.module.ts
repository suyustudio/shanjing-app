// ============================================
// 推荐模块
// ============================================

import { Module } from '@nestjs/common';
import { RecommendationController } from './recommendation.controller';
import { RecommendationService } from './services/recommendation.service';
import { RecommendationAlgorithmService } from './services/recommendation-algorithm.service';
import { UserProfileService } from './services/user-profile.service';

@Module({
  controllers: [RecommendationController],
  providers: [
    RecommendationService,
    RecommendationAlgorithmService,
    UserProfileService,
  ],
  exports: [RecommendationService, UserProfileService],
})
export class RecommendationModule {}