"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.UsersController = void 0;
const common_1 = require("@nestjs/common");
const platform_express_1 = require("@nestjs/platform-express");
const swagger_1 = require("@nestjs/swagger");
const users_service_1 = require("./users.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
const current_user_decorator_1 = require("../../common/decorators/current-user.decorator");
const dto_1 = require("./dto");
let UsersController = class UsersController {
    constructor(usersService) {
        this.usersService = usersService;
    }
    async getCurrentUser(userId) {
        return this.usersService.getUserById(userId);
    }
    async updateUser(userId, dto) {
        return this.usersService.updateUser(userId, dto);
    }
    async uploadAvatar(userId, file) {
        return this.usersService.uploadAvatar(userId, file);
    }
    async updateEmergencyContacts(userId, dto) {
        return this.usersService.updateEmergencyContacts(userId, dto);
    }
    async bindPhone(userId, dto) {
        return this.usersService.bindPhone(userId, dto);
    }
};
exports.UsersController = UsersController;
__decorate([
    (0, common_1.Get)('me'),
    (0, swagger_1.ApiOperation)({ summary: '获取当前用户信息' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "getCurrentUser", null);
__decorate([
    (0, common_1.Put)('me'),
    (0, swagger_1.ApiOperation)({ summary: '更新用户信息' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '更新成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '参数错误' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, dto_1.UpdateUserDto]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "updateUser", null);
__decorate([
    (0, common_1.Put)('me/avatar'),
    (0, swagger_1.ApiOperation)({ summary: '上传头像' }),
    (0, swagger_1.ApiConsumes)('multipart/form-data'),
    (0, swagger_1.ApiResponse)({ status: 200, description: '上传成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '文件格式错误或文件过大' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    (0, common_1.UseInterceptors)((0, platform_express_1.FileInterceptor)('avatar', {
        limits: {
            fileSize: 2 * 1024 * 1024,
        },
        fileFilter: (req, file, callback) => {
            const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png'];
            if (allowedMimes.includes(file.mimetype)) {
                callback(null, true);
            }
            else {
                callback(new Error('仅支持jpg、jpeg、png格式的图片'), false);
            }
        },
    })),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.UploadedFile)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, Object]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "uploadAvatar", null);
__decorate([
    (0, common_1.Put)('me/emergency'),
    (0, swagger_1.ApiOperation)({ summary: '更新紧急联系人' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '更新成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '参数错误' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, dto_1.UpdateEmergencyContactsDto]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "updateEmergencyContacts", null);
__decorate([
    (0, common_1.Put)('me/phone'),
    (0, swagger_1.ApiOperation)({ summary: '绑定手机号' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '绑定成功' }),
    (0, swagger_1.ApiResponse)({ status: 400, description: '验证码错误或手机号格式错误' }),
    (0, swagger_1.ApiResponse)({ status: 409, description: '手机号已被其他账号绑定' }),
    (0, swagger_1.ApiResponse)({ status: 401, description: '未授权' }),
    __param(0, (0, current_user_decorator_1.CurrentUser)('userId')),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [String, dto_1.BindPhoneDto]),
    __metadata("design:returntype", Promise)
], UsersController.prototype, "bindPhone", null);
exports.UsersController = UsersController = __decorate([
    (0, swagger_1.ApiTags)('用户'),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, common_1.Controller)('users'),
    __metadata("design:paramtypes", [users_service_1.UsersService])
], UsersController);
//# sourceMappingURL=users.controller.js.map