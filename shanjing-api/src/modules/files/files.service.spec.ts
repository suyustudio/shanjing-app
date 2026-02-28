import { Test, TestingModule } from '@nestjs/testing';
import { FilesService } from './files.service';
import { ConfigService } from '@nestjs/config';
import { BadRequestException } from '@nestjs/common';
import * as fs from 'fs/promises';
import * as path from 'path';

// Mock fs/promises
jest.mock('fs/promises');

describe('FilesService', () => {
  let service: FilesService;

  const mockConfigService = {
    get: jest.fn((key: string) => {
      const config = {
        UPLOAD_DIR: './test-uploads',
        BASE_URL: 'http://localhost:3000',
      };
      return config[key];
    }),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        FilesService,
        {
          provide: ConfigService,
          useValue: mockConfigService,
        },
      ],
    }).compile();

    service = module.get<FilesService>(FilesService);

    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('uploadAvatar', () => {
    it('should upload avatar successfully', async () => {
      const mockFile = {
        originalname: 'test-avatar.jpg',
        mimetype: 'image/jpeg',
        size: 1024,
        buffer: Buffer.from('test-image-data'),
      } as Express.Multer.File;

      const userId = 'user-1';

      (fs.mkdir as jest.Mock).mockResolvedValue(undefined);
      (fs.writeFile as jest.Mock).mockResolvedValue(undefined);

      const result = await service.uploadAvatar(mockFile, userId);

      expect(result).toMatch(/http:\/\/localhost:3000\/uploads\/avatars\/avatar_user-1_\d+\.jpg/);
      expect(fs.mkdir).toHaveBeenCalled();
      expect(fs.writeFile).toHaveBeenCalled();
    });

    it('should throw BadRequestException when file is null', async () => {
      await expect(service.uploadAvatar(null as any, 'user-1')).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException for invalid file type', async () => {
      const mockFile = {
        originalname: 'test-file.txt',
        mimetype: 'text/plain',
        size: 1024,
        buffer: Buffer.from('test-data'),
      } as Express.Multer.File;

      await expect(service.uploadAvatar(mockFile, 'user-1')).rejects.toThrow(BadRequestException);
    });

    it('should throw BadRequestException for file too large', async () => {
      const mockFile = {
        originalname: 'large-image.jpg',
        mimetype: 'image/jpeg',
        size: 3 * 1024 * 1024, // 3MB
        buffer: Buffer.from('large-image-data'),
      } as Express.Multer.File;

      await expect(service.uploadAvatar(mockFile, 'user-1')).rejects.toThrow(BadRequestException);
    });

    it('should accept png file', async () => {
      const mockFile = {
        originalname: 'test-avatar.png',
        mimetype: 'image/png',
        size: 1024,
        buffer: Buffer.from('test-image-data'),
      } as Express.Multer.File;

      (fs.mkdir as jest.Mock).mockResolvedValue(undefined);
      (fs.writeFile as jest.Mock).mockResolvedValue(undefined);

      const result = await service.uploadAvatar(mockFile, 'user-1');

      expect(result).toMatch(/http:\/\/localhost:3000\/uploads\/avatars\/avatar_user-1_\d+\.png/);
    });

    it('should use default extension when originalname has no extension', async () => {
      const mockFile = {
        originalname: 'avatar',
        mimetype: 'image/jpeg',
        size: 1024,
        buffer: Buffer.from('test-image-data'),
      } as Express.Multer.File;

      (fs.mkdir as jest.Mock).mockResolvedValue(undefined);
      (fs.writeFile as jest.Mock).mockResolvedValue(undefined);

      const result = await service.uploadAvatar(mockFile, 'user-1');

      expect(result).toMatch(/http:\/\/localhost:3000\/uploads\/avatars\/avatar_user-1_\d+\.jpg/);
    });
  });

  describe('deleteFile', () => {
    it('should delete file successfully', async () => {
      const fileUrl = 'http://localhost:3000/uploads/avatars/avatar_user-1_123456.jpg';

      (fs.unlink as jest.Mock).mockResolvedValue(undefined);

      await service.deleteFile(fileUrl);

      expect(fs.unlink).toHaveBeenCalled();
    });

    it('should not throw error when file does not exist', async () => {
      const fileUrl = 'http://localhost:3000/uploads/avatars/non-existent.jpg';

      (fs.unlink as jest.Mock).mockRejectedValue(new Error('File not found'));

      await expect(service.deleteFile(fileUrl)).resolves.not.toThrow();
    });

    it('should handle file url with different base url', async () => {
      const fileUrl = 'http://localhost:3000/uploads/avatars/avatar_user-1_123456.jpg';

      (fs.unlink as jest.Mock).mockResolvedValue(undefined);

      await service.deleteFile(fileUrl);

      const expectedPath = path.join('./test-uploads', 'avatars/avatar_user-1_123456.jpg');
      expect(fs.unlink).toHaveBeenCalledWith(expectedPath);
    });
  });
});
