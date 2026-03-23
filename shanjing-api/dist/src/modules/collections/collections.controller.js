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
exports.CollectionsController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const collections_service_1 = require("./collections.service");
const collection_dto_1 = require("./dto/collection.dto");
const jwt_auth_guard_1 = require("../../common/guards/jwt-auth.guard");
function wrapResponse(data, meta) {
    return {
        success: true,
        data,
        meta,
    };
}
let CollectionsController = class CollectionsController {
    constructor(collectionsService) {
        this.collectionsService = collectionsService;
    }
    async createCollection(req, dto) {
        const collection = await this.collectionsService.createCollection(req.user.userId, dto);
        return wrapResponse(collection);
    }
    async getCollections(req, query) {
        const currentUserId = req.user?.userId;
        const result = await this.collectionsService.getCollections(query, currentUserId);
        return wrapResponse(result, {
            total: result.total,
            page: result.page,
            limit: result.limit,
        });
    }
    async getCollectionDetail(req, id) {
        const currentUserId = req.user?.userId;
        const collection = await this.collectionsService.getCollectionDetail(id, currentUserId);
        return wrapResponse(collection);
    }
    async updateCollection(req, id, dto) {
        const collection = await this.collectionsService.updateCollection(req.user.userId, id, dto);
        return wrapResponse(collection);
    }
    async deleteCollection(req, id) {
        await this.collectionsService.deleteCollection(req.user.userId, id);
        return wrapResponse({ message: '删除成功' });
    }
    async addTrailToCollection(req, id, dto) {
        const collection = await this.collectionsService.addTrailToCollection(req.user.userId, id, dto);
        return wrapResponse(collection);
    }
    async batchAddTrails(req, id, dto) {
        const collection = await this.collectionsService.batchAddTrails(req.user.userId, id, dto);
        return wrapResponse(collection);
    }
    async removeTrailFromCollection(req, collectionId, trailId) {
        await this.collectionsService.removeTrailFromCollection(req.user.userId, collectionId, trailId);
        return wrapResponse({ message: '移除成功' });
    }
    async batchRemoveTrails(req, id, dto) {
        await this.collectionsService.batchRemoveTrails(req.user.userId, id, dto);
        return wrapResponse({ message: '移除成功' });
    }
    async batchMoveTrails(req, id, dto) {
        const collection = await this.collectionsService.batchMoveTrails(req.user.userId, id, dto);
        return wrapResponse(collection);
    }
    async searchCollectionTrails(req, id, dto) {
        const collection = await this.collectionsService.searchCollectionTrails(req.user.userId, id, dto);
        return wrapResponse(collection);
    }
};
exports.CollectionsController = CollectionsController;
__decorate([
    (0, common_1.Post)('collections'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '创建收藏夹' }),
    (0, swagger_1.ApiResponse)({ status: 201, description: '创建成功', type: collection_dto_1.CollectionDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, collection_dto_1.CreateCollectionDto]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "createCollection", null);
__decorate([
    (0, common_1.Get)('collections'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '获取收藏夹列表' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功', type: collection_dto_1.CollectionListResponseDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, collection_dto_1.QueryCollectionsDto]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "getCollections", null);
__decorate([
    (0, common_1.Get)('collections/:id'),
    (0, swagger_1.ApiOperation)({ summary: '获取收藏夹详情' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '收藏夹ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '获取成功', type: collection_dto_1.CollectionDetailDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "getCollectionDetail", null);
__decorate([
    (0, common_1.Put)('collections/:id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '更新收藏夹' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '收藏夹ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '更新成功', type: collection_dto_1.CollectionDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, collection_dto_1.UpdateCollectionDto]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "updateCollection", null);
__decorate([
    (0, common_1.Delete)('collections/:id'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '删除收藏夹' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '收藏夹ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '删除成功' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "deleteCollection", null);
__decorate([
    (0, common_1.Post)('collections/:id/trails'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '添加路线到收藏夹' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '收藏夹ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '添加成功', type: collection_dto_1.CollectionDetailDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, collection_dto_1.AddTrailToCollectionDto]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "addTrailToCollection", null);
__decorate([
    (0, common_1.Post)('collections/:id/trails/batch'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '批量添加路线到收藏夹' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '收藏夹ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '添加成功', type: collection_dto_1.CollectionDetailDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, collection_dto_1.BatchAddTrailsDto]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "batchAddTrails", null);
__decorate([
    (0, common_1.Delete)('collections/:collectionId/trails/:trailId'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '从收藏夹移除路线' }),
    (0, swagger_1.ApiParam)({ name: 'collectionId', description: '收藏夹ID' }),
    (0, swagger_1.ApiParam)({ name: 'trailId', description: '路线ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '移除成功' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('collectionId')),
    __param(2, (0, common_1.Param)('trailId')),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, String]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "removeTrailFromCollection", null);
__decorate([
    (0, common_1.Delete)('collections/:id/trails/batch'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({ summary: '批量从收藏夹移除路线' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '收藏夹ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '移除成功' }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, collection_dto_1.BatchRemoveTrailsDto]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "batchRemoveTrails", null);
__decorate([
    (0, common_1.Post)('collections/:id/trails/move'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '批量移动路线到其他收藏夹' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '收藏夹ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '移动成功', type: collection_dto_1.CollectionDetailDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, collection_dto_1.BatchMoveTrailsDto]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "batchMoveTrails", null);
__decorate([
    (0, common_1.Get)('collections/:id/search'),
    (0, common_1.UseGuards)(jwt_auth_guard_1.JwtAuthGuard),
    (0, swagger_1.ApiBearerAuth)(),
    (0, swagger_1.ApiOperation)({ summary: '搜索收藏夹内路线' }),
    (0, swagger_1.ApiParam)({ name: 'id', description: '收藏夹ID' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: '搜索成功', type: collection_dto_1.CollectionDetailDto }),
    __param(0, (0, common_1.Req)()),
    __param(1, (0, common_1.Param)('id')),
    __param(2, (0, common_1.Query)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [Object, String, collection_dto_1.SearchCollectionTrailsDto]),
    __metadata("design:returntype", Promise)
], CollectionsController.prototype, "searchCollectionTrails", null);
exports.CollectionsController = CollectionsController = __decorate([
    (0, swagger_1.ApiTags)('收藏夹系统'),
    (0, common_1.Controller)('v1'),
    __metadata("design:paramtypes", [collections_service_1.CollectionsService])
], CollectionsController);
//# sourceMappingURL=collections.controller.js.map