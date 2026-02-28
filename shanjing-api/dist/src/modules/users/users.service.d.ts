import { PrismaService } from '../../database/prisma.service';
import { FilesService } from '../files/files.service';
import { UpdateUserDto, UpdateEmergencyContactsDto, BindPhoneDto } from './dto';
import { UserResponse, EmergencyContactsResponse, PhoneResponse } from './interfaces/user.interface';
export declare class UsersService {
    private readonly prisma;
    private readonly filesService;
    constructor(prisma: PrismaService, filesService: FilesService);
    getUserById(userId: string): Promise<UserResponse>;
    updateUser(userId: string, dto: UpdateUserDto): Promise<UserResponse>;
    uploadAvatar(userId: string, file: Express.Multer.File): Promise<{
        success: boolean;
        data: {
            avatarUrl: string;
            updatedAt: Date;
        };
    }>;
    updateEmergencyContacts(userId: string, dto: UpdateEmergencyContactsDto): Promise<EmergencyContactsResponse>;
    bindPhone(userId: string, dto: BindPhoneDto): Promise<PhoneResponse>;
    private verifySmsCode;
    private sanitizeUser;
}
