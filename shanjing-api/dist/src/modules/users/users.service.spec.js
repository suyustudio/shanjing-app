"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const users_service_1 = require("./users.service");
const prisma_service_1 = require("../../database/prisma.service");
const files_service_1 = require("../files/files.service");
const common_1 = require("@nestjs/common");
describe('UsersService', () => {
    let service;
    let prisma;
    let filesService;
    const mockPrismaService = {
        user: {
            findUnique: jest.fn(),
            update: jest.fn(),
        },
    };
    const mockFilesService = {
        uploadAvatar: jest.fn(),
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            providers: [
                users_service_1.UsersService,
                {
                    provide: prisma_service_1.PrismaService,
                    useValue: mockPrismaService,
                },
                {
                    provide: files_service_1.FilesService,
                    useValue: mockFilesService,
                },
            ],
        }).compile();
        service = module.get(users_service_1.UsersService);
        prisma = module.get(prisma_service_1.PrismaService);
        filesService = module.get(files_service_1.FilesService);
        jest.clearAllMocks();
    });
    it('should be defined', () => {
        expect(service).toBeDefined();
    });
    describe('getUserById', () => {
        it('should return user info successfully', async () => {
            const mockUser = {
                id: 'user-1',
                nickname: '测试用户',
                phone: '13800138000',
                avatarUrl: null,
                emergencyContacts: [],
                settings: {},
                createdAt: new Date(),
                updatedAt: new Date(),
            };
            mockPrismaService.user.findUnique.mockResolvedValue(mockUser);
            const result = await service.getUserById('user-1');
            expect(result.success).toBe(true);
            expect(result.data.id).toBe('user-1');
        });
        it('should throw NotFoundException if user not found', async () => {
            mockPrismaService.user.findUnique.mockResolvedValue(null);
            await expect(service.getUserById('non-existent')).rejects.toThrow(common_1.NotFoundException);
        });
    });
    describe('updateUser', () => {
        it('should update user info successfully', async () => {
            const mockUser = {
                id: 'user-1',
                nickname: '新昵称',
                phone: '13800138000',
                avatarUrl: null,
                emergencyContacts: [],
                settings: { notificationEnabled: true },
                createdAt: new Date(),
                updatedAt: new Date(),
            };
            mockPrismaService.user.findUnique.mockResolvedValue({ id: 'user-1' });
            mockPrismaService.user.update.mockResolvedValue(mockUser);
            const result = await service.updateUser('user-1', { nickname: '新昵称', settings: { notificationEnabled: true } });
            expect(result.success).toBe(true);
            expect(result.data.nickname).toBe('新昵称');
        });
        it('should throw NotFoundException if user not found', async () => {
            mockPrismaService.user.findUnique.mockResolvedValue(null);
            await expect(service.updateUser('non-existent', { nickname: '新昵称' })).rejects.toThrow(common_1.NotFoundException);
        });
    });
    describe('uploadAvatar', () => {
        it('should upload avatar successfully', async () => {
            const mockFile = { originalname: 'avatar.jpg', mimetype: 'image/jpeg', size: 1024, buffer: Buffer.from('') };
            const avatarUrl = 'http://localhost:3000/uploads/avatars/avatar_user-1_123456.jpg';
            mockPrismaService.user.findUnique.mockResolvedValue({ id: 'user-1' });
            mockFilesService.uploadAvatar.mockResolvedValue(avatarUrl);
            mockPrismaService.user.update.mockResolvedValue({ id: 'user-1', avatarUrl, updatedAt: new Date() });
            const result = await service.uploadAvatar('user-1', mockFile);
            expect(result.success).toBe(true);
            expect(result.data.avatarUrl).toBe(avatarUrl);
        });
    });
    describe('updateEmergencyContacts', () => {
        it('should update emergency contacts successfully', async () => {
            const contacts = [
                { name: '张三', phone: '13900139000', relation: '配偶' },
            ];
            mockPrismaService.user.findUnique.mockResolvedValue({ id: 'user-1' });
            mockPrismaService.user.update.mockResolvedValue({
                id: 'user-1',
                emergencyContacts: contacts,
                updatedAt: new Date(),
            });
            const result = await service.updateEmergencyContacts('user-1', { contacts });
            expect(result.success).toBe(true);
            expect(result.data.emergencyContacts).toEqual(contacts);
        });
        it('should throw BadRequestException if contacts exceed limit', async () => {
            const contacts = [
                { name: '张三', phone: '13900139000', relation: '配偶' },
                { name: '李四', phone: '13900139001', relation: '朋友' },
                { name: '王五', phone: '13900139002', relation: '同事' },
                { name: '赵六', phone: '13900139003', relation: '亲戚' },
            ];
            mockPrismaService.user.findUnique.mockResolvedValue({ id: 'user-1' });
            await expect(service.updateEmergencyContacts('user-1', { contacts })).rejects.toThrow(common_1.BadRequestException);
        });
        it('should throw BadRequestException if phone format is invalid', async () => {
            const contacts = [
                { name: '张三', phone: 'invalid-phone', relation: '配偶' },
            ];
            mockPrismaService.user.findUnique.mockResolvedValue({ id: 'user-1' });
            await expect(service.updateEmergencyContacts('user-1', { contacts })).rejects.toThrow(common_1.BadRequestException);
        });
    });
    describe('bindPhone', () => {
        it('should bind phone successfully', async () => {
            const phone = '13800138000';
            mockPrismaService.user.findUnique.mockResolvedValue(null);
            mockPrismaService.user.update.mockResolvedValue({
                id: 'user-1',
                phone,
                updatedAt: new Date(),
            });
            const result = await service.bindPhone('user-1', { phone, code: '123456' });
            expect(result.success).toBe(true);
            expect(result.data.phone).toBe(phone);
        });
        it('should throw ConflictException if phone already bound to another user', async () => {
            const phone = '13800138000';
            mockPrismaService.user.findUnique.mockResolvedValue({ id: 'other-user' });
            await expect(service.bindPhone('user-1', { phone, code: '123456' })).rejects.toThrow(common_1.ConflictException);
        });
        it('should throw BadRequestException if verification code is invalid', async () => {
            const phone = '13800138000';
            mockPrismaService.user.findUnique.mockResolvedValue(null);
            await expect(service.bindPhone('user-1', { phone, code: '999999' })).rejects.toThrow(common_1.BadRequestException);
        });
    });
});
//# sourceMappingURL=users.service.spec.js.map