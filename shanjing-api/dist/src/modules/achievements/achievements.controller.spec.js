"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const achievements_controller_1 = require("./achievements.controller");
const achievements_service_1 = require("./achievements.service");
const client_1 = require("@prisma/client");
describe('AchievementsController', () => {
    let controller;
    let statsController;
    let service;
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
        const module = await testing_1.Test.createTestingModule({
            controllers: [achievements_controller_1.AchievementsController, achievements_controller_1.UserStatsController],
            providers: [
                {
                    provide: achievements_service_1.AchievementsService,
                    useValue: mockService,
                },
            ],
        }).compile();
        controller = module.get(achievements_controller_1.AchievementsController);
        statsController = module.get(achievements_controller_1.UserStatsController);
        service = module.get(achievements_service_1.AchievementsService);
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
                    category: client_1.AchievementCategory.EXPLORER,
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
                triggerType: 'trail_completed',
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
                        level: client_1.AchievementLevelEnum.BRONZE,
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
//# sourceMappingURL=achievements.controller.spec.js.map