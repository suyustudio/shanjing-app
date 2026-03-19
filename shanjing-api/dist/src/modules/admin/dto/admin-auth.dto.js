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
Object.defineProperty(exports, "__esModule", { value: true });
exports.AdminListResponseDto = exports.AdminInfoResponseDto = exports.AdminLoginResponseDto = exports.UpdateAdminDto = exports.CreateAdminDto = exports.AdminLoginDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const class_validator_1 = require("class-validator");
const admin_role_enum_1 = require("../admin-role.enum");
class AdminLoginDto {
}
exports.AdminLoginDto = AdminLoginDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '用户名',
        example: 'admin',
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(3),
    (0, class_validator_1.MaxLength)(50),
    __metadata("design:type", String)
], AdminLoginDto.prototype, "username", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '密码',
        example: 'admin123',
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(6),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], AdminLoginDto.prototype, "password", void 0);
class CreateAdminDto {
}
exports.CreateAdminDto = CreateAdminDto;
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '用户名',
        example: 'newadmin',
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(3),
    (0, class_validator_1.MaxLength)(50),
    __metadata("design:type", String)
], CreateAdminDto.prototype, "username", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '密码',
        example: 'password123',
    }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(6),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], CreateAdminDto.prototype, "password", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '昵称',
        example: '新管理员',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], CreateAdminDto.prototype, "nickname", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({
        description: '角色',
        enum: admin_role_enum_1.AdminRole,
        example: admin_role_enum_1.AdminRole.ADMIN,
    }),
    (0, class_validator_1.IsEnum)(admin_role_enum_1.AdminRole),
    __metadata("design:type", String)
], CreateAdminDto.prototype, "role", void 0);
class UpdateAdminDto {
}
exports.UpdateAdminDto = UpdateAdminDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '昵称',
        example: '更新的昵称',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], UpdateAdminDto.prototype, "nickname", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '密码',
        example: 'newpassword123',
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.MinLength)(6),
    (0, class_validator_1.MaxLength)(100),
    __metadata("design:type", String)
], UpdateAdminDto.prototype, "password", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '角色',
        enum: admin_role_enum_1.AdminRole,
        example: admin_role_enum_1.AdminRole.OPERATOR,
    }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsEnum)(admin_role_enum_1.AdminRole),
    __metadata("design:type", String)
], UpdateAdminDto.prototype, "role", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({
        description: '状态：true-启用，false-禁用',
        example: true,
    }),
    (0, class_validator_1.IsOptional)(),
    __metadata("design:type", Boolean)
], UpdateAdminDto.prototype, "isActive", void 0);
class AdminLoginResponseDto {
}
exports.AdminLoginResponseDto = AdminLoginResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功', example: true }),
    __metadata("design:type", Boolean)
], AdminLoginResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '错误信息' }),
    __metadata("design:type", String)
], AdminLoginResponseDto.prototype, "errorMessage", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '响应数据' }),
    __metadata("design:type", Object)
], AdminLoginResponseDto.prototype, "data", void 0);
class AdminInfoResponseDto {
}
exports.AdminInfoResponseDto = AdminInfoResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功', example: true }),
    __metadata("design:type", Boolean)
], AdminInfoResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '响应数据' }),
    __metadata("design:type", Object)
], AdminInfoResponseDto.prototype, "data", void 0);
class AdminListResponseDto {
}
exports.AdminListResponseDto = AdminListResponseDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '是否成功', example: true }),
    __metadata("design:type", Boolean)
], AdminListResponseDto.prototype, "success", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '管理员列表' }),
    __metadata("design:type", Array)
], AdminListResponseDto.prototype, "data", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '分页信息' }),
    __metadata("design:type", Object)
], AdminListResponseDto.prototype, "meta", void 0);
//# sourceMappingURL=admin-auth.dto.js.map