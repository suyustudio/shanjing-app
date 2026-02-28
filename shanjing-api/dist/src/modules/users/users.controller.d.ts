import { UsersService } from './users.service';
import { UpdateUserDto, UpdateEmergencyContactsDto, BindPhoneDto } from './dto';
import { UserResponse, EmergencyContactsResponse, PhoneResponse } from './interfaces/user.interface';
export declare class UsersController {
    private readonly usersService;
    constructor(usersService: UsersService);
    getCurrentUser(userId: string): Promise<UserResponse>;
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
}
