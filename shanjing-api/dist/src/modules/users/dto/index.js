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
exports.BindPhoneDto = exports.UpdateEmergencyContactsDto = exports.UpdateUserDto = void 0;
const class_validator_1 = require("class-validator");
const class_transformer_1 = require("class-transformer");
const swagger_1 = require("@nestjs/swagger");
class EmergencyContactDto {
}
__decorate([
    (0, swagger_1.ApiProperty)({ description: '联系人姓名', example: '张三' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(2, 20, { message: '姓名长度必须在2-20个字符之间' }),
    __metadata("design:type", String)
], EmergencyContactDto.prototype, "name", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '联系人电话', example: '13900139000' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^1[3-9]\d{9}$/, { message: '手机号格式错误' }),
    __metadata("design:type", String)
], EmergencyContactDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '关系', example: '配偶' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(1, 20, { message: '关系描述长度必须在1-20个字符之间' }),
    __metadata("design:type", String)
], EmergencyContactDto.prototype, "relation", void 0);
class UpdateUserDto {
}
exports.UpdateUserDto = UpdateUserDto;
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户昵称', example: '新的昵称' }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(2, 20, { message: '昵称长度必须在2-20个字符之间' }),
    __metadata("design:type", String)
], UpdateUserDto.prototype, "nickname", void 0);
__decorate([
    (0, swagger_1.ApiPropertyOptional)({ description: '用户设置', example: { notificationEnabled: true, autoUpload: false } }),
    (0, class_validator_1.IsOptional)(),
    (0, class_validator_1.IsObject)(),
    __metadata("design:type", Object)
], UpdateUserDto.prototype, "settings", void 0);
class UpdateEmergencyContactsDto {
}
exports.UpdateEmergencyContactsDto = UpdateEmergencyContactsDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '紧急联系人列表', type: [EmergencyContactDto] }),
    (0, class_validator_1.IsArray)(),
    (0, class_validator_1.ValidateNested)({ each: true }),
    (0, class_transformer_1.Type)(() => EmergencyContactDto),
    __metadata("design:type", Array)
], UpdateEmergencyContactsDto.prototype, "contacts", void 0);
class BindPhoneDto {
}
exports.BindPhoneDto = BindPhoneDto;
__decorate([
    (0, swagger_1.ApiProperty)({ description: '手机号', example: '13800138000' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Matches)(/^1[3-9]\d{9}$/, { message: '手机号格式错误' }),
    __metadata("design:type", String)
], BindPhoneDto.prototype, "phone", void 0);
__decorate([
    (0, swagger_1.ApiProperty)({ description: '短信验证码', example: '123456' }),
    (0, class_validator_1.IsString)(),
    (0, class_validator_1.Length)(6, 6, { message: '验证码必须是6位数字' }),
    __metadata("design:type", String)
], BindPhoneDto.prototype, "code", void 0);
//# sourceMappingURL=index.js.map