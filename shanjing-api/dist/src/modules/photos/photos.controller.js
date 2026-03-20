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
exports.PhotosController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const photos_service_1 = require("./photos.service");
const photo_dto_1 = require("./dto/photo.dto");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
function wrapResponse(data, meta) {
    return {
        success: true,
        data,
        meta,
    };
}
let PhotosController = class PhotosController {
    constructor(photosService) {
        this.photosService = photosService;
    }
    async createPhoto(req, dto) {
        const photo = await this.photosService.createPhoto(req.user.userId, dto);
        return wrapResponse(photo);
    }
    async createPhotos(req, dto) {
        const photos = await this.photosService.createPhotos(req.user.userId, dto);
        return wrapResponse(photos);
    }
    async getPhotos(req, query) {
        const currentUserId = req.user?.userId;
        const result = await this.photosService.getPhotos(query, currentUserId);
        return wrapResponse(result, {
            nextCursor: result.nextCursor,
            hasMore: result.hasMore,
        });
    }
    async getPhotoDetail(req, id) {
        const currentUserId = req.user?.userId;
        const photo = await this.photosService.getPhotoDetail(id, currentUserId);
        return wrapResponse(photo);
    }
    async updatePhoto(req, id, dto) {
        const photo = await this.photosService.updatePhoto(req.user.userId, id, dto);
        return wrapResponse(photo);
    }
    async deletePhoto(req, id) {
        await this.photosService.deletePhoto(req.user.userId, id);
        return wrapResponse({ message: '删除成功' });
    }
    async likePhoto(req, id) {
        const result = await this.photosService.likePhoto(req.user.userId, id);
        return wrapResponse(result);
    }
    async getUserPhotos(req, userId, cursor, limit) {
        const currentUserId = req.user?.userId;
        const result = await this.photosService.getUserPhotos(userId, currentUserId, cursor, limit ? parseInt(limit) : 20);
        return wrapResponse(result);
    }
};
exports.PhotosController = PhotosController;
__decorate([
    (0, common_1.Post)(),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '上传单张照片' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: '上传成功', type: photo_dto_1.PhotoDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, photo_dto_1.CreatePhotoDto]),
    __metadata("design:returntype", Promise)
], PhotosController.prototype, "createPhoto", null);
__decorate([
    (0, common_1.Post)('batch'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '批量上传照片' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: '上传成功', type: [photo_dto_1.PhotoDto] }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, photo_dto_1.CreatePhotosDto]),
    __metadata("design:returntype", Promise)
], PhotosController.prototype, "createPhotos", null);
__decorate([
    (0, common_1.Get)(),
    (0, swagger_1.ApiOperation)({ summary: '获取照片列表 (瀑布流)' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功', type: photo_dto_1.PhotoListResponseDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, photo_dto_1.QueryPhotosDto]),
    __metadata("design:returntype", Promise)
], PhotosController.prototype, "getPhotos", null);
__decorate([
    (0, common_1.Get)(':id'),
    (0, swagger_1.ApiOperation)({ summary: '获取照片详情' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '照片ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功', type: photo_dto_1.PhotoDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], PhotosController.prototype, "getPhotoDetail", null);
__decorate([
    (0, common_1.Put)(':id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '更新照片信息' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '照片ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '更新成功', type: photo_dto_1.PhotoDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, photo_dto_1.UpdatePhotoDto]),
    __metadata("design:returntype", Promise)
], PhotosController.prototype, "updatePhoto", null);
__decorate([
    (0, common_1.Delete)(':id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '删除照片' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '照片ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '删除成功' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], PhotosController.prototype, "deletePhoto", null);
__decorate([
    (0, common_1.Post)(':id/like'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '点赞/取消点赞照片' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '照片ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '操作成功', type: photo_dto_1.LikePhotoResponseDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], PhotosController.prototype, "likePhoto", null);
__decorate([
    (0, common_1.Get)('users/:userId/photos'),
    (0, swagger_1.ApiOperation)({ summary: '获取用户的照片列表' }),
    (0, swagger_1.ApiParam)({ name: 'userId', description: '用户ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功', type: photo_dto_1.PhotoListResponseDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('userId')),
    __param(2, (0, common_1.Query)('cursor')),
    __param(3, (0, common_1.Query)('limit')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String, Number]),
    __metadata("design:returntype", Promise)
], PhotosController.prototype, "getUserPhotos", null);
exports.PhotosController = PhotosController = __decorate([
    (0, swagger_1.ApiTags)('照片系统'),
    (0, common_1.Controller)('v1/photos'),
    __metadata("design:paramtypes", [photos_service_1.PhotosService])
], PhotosController);
//# sourceMappingURL=photos.controller.js.map