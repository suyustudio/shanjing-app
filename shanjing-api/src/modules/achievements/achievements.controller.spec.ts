// ================================================================
// Achievement Controller Unit Tests
// 成就系统控制器单元测试
// ================================================================

import { Test, TestingModule } from '@nestjs/testing';
import { AchievementsController, UserStatsController } from './achievements.controller';
import { AchievementsService } from './achievements.service';
import { AchievementCategory, AchievementLevelEnum } from '@prisma/client';

describe('AchievementsController', () => {
  let controller: AchievementsController;
  let statsController: UserStatsController;
  let service: AchievementsService;

  const mockService = {
    getAllAchievements: jest.fn(),
    getAchievementById: jest.fn(),
    getUserAchievements: jest.fn(),
    markAchievementViewed: jest.fn(),
    markAllAchievementsViewed: jest.fn(),
    checkAchievements: jest.fn(),
    getUserStats: jest.fn(),
  };

  const mockRequest = {
    user: {
      userId: 'user-1',
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [AchievementsController, UserStatsController],
      providers: [
        {
          provide: AchievementsService,
          useValue: mockService,
        },
      ],
    }).compile();

    controller = module.get<AchievementsController>(AchievementsController);
    statsController = module.get<UserStatsController>(UserStatsController);
    service = module.get<AchievementsService>(AchievementsService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getAllAchievements', () => {
    it('should return all achievements', async () => {
      const mockAchievements = [
        {
          id: 'ach-1',
          key: 'explorer',
          name: '路线收集家',
          category: AchievementCategory.EXPLORER,
          isHidden: false,
          sortOrder: 1,
          levels: [],
        },
      ];

      mockService.getAllAchievements.mockResolvedValue(mockAchievements);

      const result = await controller.getAllAchievements();

      expect(result).toEqual(mockAchievements);
      expect(mockService.getAllAchievements).toHaveBeenCalled();
    });
  });

  describe('getMyAchievements', () => {
    it('should return current user achievements', async () => {
      const mockSummary = {
        totalCount: 10,
        unlockedCount: 5,
        newUnlockedCount: 1,
        achievements: [],
      };

      mockService.getUserAchievements.mockResolvedValue(mockSummary);

      const result = await controller.getMyAchievements(mockRequest);

      expect(result).toEqual(mockSummary);
      expect(mockService.getUserAchievements).toHaveBeenCalledWith('user-1');
    });
  });

  describe('checkAchievements', () => {
    it('should check and unlock achievements', async () => {
      const dto = {
        triggerType: 'trail_completed' as const,
        trailId: 'trail-1',
        stats: {
          distance: 5000,
          duration: 3600,
          isNight: false,
          isRain: false,
          isSolo: true,
        },
      };

      const mockResult = {
        newlyUnlocked: [
          {
            achievementId: 'ach-1',
            level: AchievementLevelEnum.BRONZE,
            name: '初级探索者',
            message: '恭喜解锁！',
            badgeUrl: 'badge.png',
          },
        ],
        progressUpdated: [],
      };

      mockService.checkAchievements.mockResolvedValue(mockResult);

      const result = await controller.checkAchievements(mockRequest, dto);

      expect(result).toEqual(mockResult);
      expect(mockService.checkAchievements).toHaveBeenCalledWith('user-1', dto);
    });
  });

  describe('markAchievementViewed', () => {
    it('should mark achievement as viewed', async () => {
      mockService.markAchievementViewed.mockResolvedValue(undefined);

      const result = await controller.markAchievementViewed(mockRequest, 'ach-1');

      expect(result).toEqual({ success: true });
      expect(mockService.markAchievementViewed).toHaveBeenCalledWith('user-1', 'ach-1');
    });
  });

  describe('getUserStats', () => {
    it('should return user stats', async () => {
      const mockStats = {
        totalDistanceM: 10000,
        totalDurationSec: 7200,
        totalElevationGainM: 500,
        uniqueTrailsCount: 5,
        currentWeeklyStreak: 2,
        longestWeeklyStreak: 4,
        nightTrailCount: 1,
        rainTrailCount: 0,
        shareCount: 3,
      };

      mockService.getUserStats.mockResolvedValue(mockStats);

      const result = await statsController.getUserStats(mockRequest);

      expect(result).toEqual(mockStats);
      expect(mockService.getUserStats).toHaveBeenCalledWith('user-1');
    });
  });
});
