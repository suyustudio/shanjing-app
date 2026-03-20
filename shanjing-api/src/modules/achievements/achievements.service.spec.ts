// ================================================================
// Achievement Service Unit Tests
// 成就系统服务单元测试
// ================================================================

import { Test, TestingModule } from '@nestjs/testing';
import { AchievementsService } from './achievements.service';
import { PrismaService } from '../../database/prisma.service';
import { AchievementCategory, AchievementLevelEnum } from '@prisma/client';

describe('AchievementsService', () => {
  let service: AchievementsService;
  let prismaService: PrismaService;

  const mockPrismaService = {
    achievement: {
      findMany: jest.fn(),
      findUnique: jest.fn(),
    },
    userAchievement: {
      findMany: jest.fn(),
      findFirst: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
      updateMany: jest.fn(),
    },
    userStats: {
      findUnique: jest.fn(),
      create: jest.fn(),
      update: jest.fn(),
    },
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        AchievementsService,
        {
          provide: PrismaService,
          useValue: mockPrismaService,
        },
      ],
    }).compile();

    service = module.get<AchievementsService>(AchievementsService);
    prismaService = module.get<PrismaService>(PrismaService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  describe('getAllAchievements', () => {
    it('should return all achievements with levels', async () => {
      const mockAchievements = [
        {
          id: 'ach-1',
          key: 'explorer',
          name: '路线收集家',
          description: '探索不同的徒步路线',
          category: AchievementCategory.EXPLORER,
          iconUrl: 'icon.png',
          isHidden: false,
          sortOrder: 1,
          levels: [
            {
              id: 'level-1',
              level: AchievementLevelEnum.BRONZE,
              requirement: 5,
              name: '初级探索者',
              description: '完成5条不同路线',
              reward: null,
              iconUrl: 'bronze.png',
            },
          ],
        },
      ];

      mockPrismaService.achievement.findMany.mockResolvedValue(mockAchievements);

      const result = await service.getAllAchievements();

      expect(result).toHaveLength(1);
      expect(result[0].key).toBe('explorer');
      expect(result[0].levels).toHaveLength(1);
      expect(mockPrismaService.achievement.findMany).toHaveBeenCalled();
    });
  });

  describe('getUserAchievements', () => {
    it('should return user achievement summary', async () => {
      const userId = 'user-1';

      mockPrismaService.achievement.findMany.mockResolvedValue([
        {
          id: 'ach-1',
          key: 'explorer',
          name: '路线收集家',
          category: AchievementCategory.EXPLORER,
          isHidden: false,
          sortOrder: 1,
          levels: [
            { id: 'level-1', level: AchievementLevelEnum.BRONZE, requirement: 5, name: '初级探索者' },
          ],
        },
      ]);

      mockPrismaService.userAchievement.findMany.mockResolvedValue([]);

      mockPrismaService.userStats.findUnique.mockResolvedValue({
        userId,
        uniqueTrailsCount: 3,
        totalDistanceM: 15000,
      });

      const result = await service.getUserAchievements(userId);

      expect(result.totalCount).toBe(1);
      expect(result.unlockedCount).toBe(0);
      expect(result.achievements).toHaveLength(1);
    });
  });

  describe('checkAchievements', () => {
    it('should unlock new achievement when requirements are met', async () => {
      const userId = 'user-1';
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

      mockPrismaService.userStats.findUnique.mockResolvedValue({
        userId,
        uniqueTrailsCount: 5,
        totalDistanceM: 5000,
        currentWeeklyStreak: 1,
        nightTrailCount: 0,
        shareCount: 0,
        completedTrailIds: [],
        longestWeeklyStreak: 0,
        lastTrailDate: null,
      });

      mockPrismaService.achievement.findMany.mockResolvedValue([
        {
          id: 'ach-1',
          key: 'explorer',
          name: '路线收集家',
          category: AchievementCategory.EXPLORER,
          iconUrl: 'icon.png',
          isHidden: false,
          sortOrder: 1,
          levels: [
            { id: 'level-1', level: AchievementLevelEnum.BRONZE, requirement: 5, name: '初级探索者', iconUrl: 'bronze.png' },
          ],
        },
      ]);

      mockPrismaService.userAchievement.findMany.mockResolvedValue([]);
      mockPrismaService.userAchievement.create.mockResolvedValue({
        id: 'ua-1',
        userId,
        achievementId: 'ach-1',
        levelId: 'level-1',
      });

      const result = await service.checkAchievements(userId, dto);

      expect(result.newlyUnlocked).toHaveLength(1);
      expect(result.newlyUnlocked[0].name).toBe('初级探索者');
    });
  });

  describe('getUserStats', () => {
    it('should return user stats', async () => {
      const userId = 'user-1';

      mockPrismaService.userStats.findUnique.mockResolvedValue({
        userId,
        totalDistanceM: 10000,
        totalDurationSec: 7200,
        totalElevationGainM: 500,
        uniqueTrailsCount: 5,
        currentWeeklyStreak: 2,
        longestWeeklyStreak: 4,
        nightTrailCount: 1,
        rainTrailCount: 0,
        shareCount: 3,
      });

      const result = await service.getUserStats(userId);

      expect(result.totalDistanceM).toBe(10000);
      expect(result.uniqueTrailsCount).toBe(5);
      expect(result.shareCount).toBe(3);
    });
  });
});
