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
exports.FilesController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const oss_service_1 = require("./oss.service");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
class GenerateUploadUrlDto {
}
class BatchUploadUrlDto {
}
let FilesController = class FilesController {
    constructor(ossService) {
        this.ossService = ossService;
    }
    async getUploadUrl(req, dto) {
        const result = await this.ossService.generatePhotoUploadUrl(req.user.userId, dto.filename, dto.contentType);
        return {
            success: true,
            data: result,
        };
    }
    async getBatchUploadUrls(req, dto) {
        const results = await this.ossService.generateBatchUploadUrls(req.user.userId, dto.files);
        return {
            success: true,
            data: results,
        };
    }
    getStatus() {
        return {
            success: true,
            data: {
                configured: this.ossService.isConfigured(),
            },
        };
    }
};
exports.FilesController = FilesController;
__decorate([
    (0, common_1.Post)('upload-url'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '获取照片上传凭证' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, GenerateUploadUrlDto]),
    __metadata("design:returntype", Promise)
], FilesController.prototype, "getUploadUrl", null);
__decorate([
    (0, common_1.Post)('upload-urls'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '批量获取照片上传凭证' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, BatchUploadUrlDto]),
    __metadata("design:returntype", Promise)
], FilesController.prototype, "getBatchUploadUrls", null);
__decorate([
    (0, common_1.Get)('status'),
    (0, swagger_1.ApiOperation)({ summary: '检查 OSS 配置状态' }),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", []),
    __metadata("design:returntype", void 0)
], FilesController.prototype, "getStatus", null);
exports.FilesController = FilesController = __decorate([
    (0, swagger_1.ApiTags)('文件上传'),
    (0, common_1.Controller)('v1/files'),
    __metadata("design:paramtypes", [oss_service_1.OssService])
], FilesController);
//# sourceMappingURL=files.controller.js.map