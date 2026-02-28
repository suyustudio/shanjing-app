import { Test, TestingModule } from '@nestjs/testing';
import { TrailsController } from './trails.controller';
import { TrailsService } from './trails.service';
import { Difficulty } from '@prisma/client';

describe('TrailsController', () => {
  let controller: TrailsController;
  let service: TrailsService;

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [TrailsController],
      providers: [
        {
          provide: TrailsService,
          useValue: {
            findAllPublic: jest.fn(),
          },
        },
      ],
    }).compile();

    controller = module.get<TrailsController>(TrailsController);
    service = module.get<TrailsService>(TrailsService);
  });

  describe('GET /trails', () => {
    it('should return trail list with items and pagination', async () => {
      const mockResponse = {
        success: true,
        data: {
          items: [
            {
              id: 'trail_001',
              name: '九溪十八涧',
              description: '杭州经典徒步路线',
              distanceKm: 8.5,
              durationMin: 180,
              elevationGainM: 350,
              difficulty: Difficulty.moderate,
              tags: ['山水', '古道'],
              coverImage: 'https://example.com/cover.jpg',
              location: {
                city: '杭州',
                district: '西湖区',
                address: '九溪路',
              },
              stats: {
                favoriteCount: 128,
                viewCount: 1024,
              },
              createdAt: '2024-01-01T00:00:00.000Z',
            },
          ],
          pagination: {
            page: 1,
            limit: 20,
            total: 1,
            totalPages: 1,
            hasMore: false,
          },
        },
      };

      jest.spyOn(service, 'findAllPublic').mockResolvedValue(mockResponse);

      const result = await controller.findAll(1, 20);

      expect(service.findAllPublic).toHaveBeenCalledWith({
        page: 1,
        limit: 20,
        city: undefined,
        difficulty: undefined,
      });
      expect(result.data.items).toBeDefined();
      expect(result.data.items.length).toBe(1);
      expect(result.data.pagination).toBeDefined();
      expect(result.data.pagination.page).toBe(1);
      expect(result.data.pagination.total).toBe(1);
    });

    it('should pass city parameter to service when provided', async () => {
      const mockResponse = {
        success: true,
        data: {
          items: [],
          pagination: {
            page: 1,
            limit: 20,
            total: 0,
            totalPages: 0,
            hasMore: false,
          },
        },
      };

      jest.spyOn(service, 'findAllPublic').mockResolvedValue(mockResponse);

      await controller.findAll(1, 20, '杭州');

      expect(service.findAllPublic).toHaveBeenCalledWith({
        page: 1,
        limit: 20,
        city: '杭州',
        difficulty: undefined,
      });
    });

    it('should pass difficulty parameter to service.findAllPublic', async () => {
      const mockResponse = {
        success: true,
        data: {
          items: [],
          pagination: {
            page: 1,
            limit: 20,
            total: 0,
            totalPages: 0,
            hasMore: false,
          },
        },
      };

      jest.spyOn(service, 'findAllPublic').mockResolvedValue(mockResponse);

      await controller.findAll(1, 20, undefined, Difficulty.easy);

      expect(service.findAllPublic).toHaveBeenCalledWith({
        page: 1,
        limit: 20,
        city: undefined,
        difficulty: Difficulty.easy,
      });
    });
  });
});
