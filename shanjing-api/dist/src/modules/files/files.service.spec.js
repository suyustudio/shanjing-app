"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const files_service_1 = require("./files.service");
const config_1 = require("@nestjs/config");
const common_1 = require("@nestjs/common");
const fs = require("fs/promises");
const path = require("path");
jest.mock('fs/promises');
describe('FilesService', () => {
    let service;
    const mockConfigService = {
        get: jest.fn((key) => {
            const config = {
                UPLOAD_DIR: './test-uploads',
                BASE_URL: 'http://localhost:3000',
            };
            return config[key];
        }),
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            providers: [
                files_service_1.FilesService,
                {
                    provide: config_1.ConfigService,
                    useValue: mockConfigService,
                },
            ],
        }).compile();
        service = module.get(files_service_1.FilesService);
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
            };
            const userId = 'user-1';
            fs.mkdir.mockResolvedValue(undefined);
            fs.writeFile.mockResolvedValue(undefined);
            const result = await service.uploadAvatar(mockFile, userId);
            expect(result).toMatch(/http:\/\/localhost:3000\/uploads\/avatars\/avatar_user-1_\d+\.jpg/);
            expect(fs.mkdir).toHaveBeenCalled();
            expect(fs.writeFile).toHaveBeenCalled();
        });
        it('should throw BadRequestException when file is null', async () => {
            await expect(service.uploadAvatar(null, 'user-1')).rejects.toThrow(common_1.BadRequestException);
        });
        it('should throw BadRequestException for invalid file type', async () => {
            const mockFile = {
                originalname: 'test-file.txt',
                mimetype: 'text/plain',
                size: 1024,
                buffer: Buffer.from('test-data'),
            };
            await expect(service.uploadAvatar(mockFile, 'user-1')).rejects.toThrow(common_1.BadRequestException);
        });
        it('should throw BadRequestException for file too large', async () => {
            const mockFile = {
                originalname: 'large-image.jpg',
                mimetype: 'image/jpeg',
                size: 3 * 1024 * 1024,
                buffer: Buffer.from('large-image-data'),
            };
            await expect(service.uploadAvatar(mockFile, 'user-1')).rejects.toThrow(common_1.BadRequestException);
        });
        it('should accept png file', async () => {
            const mockFile = {
                originalname: 'test-avatar.png',
                mimetype: 'image/png',
                size: 1024,
                buffer: Buffer.from('test-image-data'),
            };
            fs.mkdir.mockResolvedValue(undefined);
            fs.writeFile.mockResolvedValue(undefined);
            const result = await service.uploadAvatar(mockFile, 'user-1');
            expect(result).toMatch(/http:\/\/localhost:3000\/uploads\/avatars\/avatar_user-1_\d+\.png/);
        });
        it('should use default extension when originalname has no extension', async () => {
            const mockFile = {
                originalname: 'avatar',
                mimetype: 'image/jpeg',
                size: 1024,
                buffer: Buffer.from('test-image-data'),
            };
            fs.mkdir.mockResolvedValue(undefined);
            fs.writeFile.mockResolvedValue(undefined);
            const result = await service.uploadAvatar(mockFile, 'user-1');
            expect(result).toMatch(/http:\/\/localhost:3000\/uploads\/avatars\/avatar_user-1_\d+\.jpg/);
        });
    });
    describe('deleteFile', () => {
        it('should delete file successfully', async () => {
            const fileUrl = 'http://localhost:3000/uploads/avatars/avatar_user-1_123456.jpg';
            fs.unlink.mockResolvedValue(undefined);
            await service.deleteFile(fileUrl);
            expect(fs.unlink).toHaveBeenCalled();
        });
        it('should not throw error when file does not exist', async () => {
            const fileUrl = 'http://localhost:3000/uploads/avatars/non-existent.jpg';
            fs.unlink.mockRejectedValue(new Error('File not found'));
            await expect(service.deleteFile(fileUrl)).resolves.not.toThrow();
        });
        it('should handle file url with different base url', async () => {
            const fileUrl = 'http://localhost:3000/uploads/avatars/avatar_user-1_123456.jpg';
            fs.unlink.mockResolvedValue(undefined);
            await service.deleteFile(fileUrl);
            const expectedPath = path.join('./test-uploads', 'avatars/avatar_user-1_123456.jpg');
            expect(fs.unlink).toHaveBeenCalledWith(expectedPath);
        });
    });
});
//# sourceMappingURL=files.service.spec.js.map