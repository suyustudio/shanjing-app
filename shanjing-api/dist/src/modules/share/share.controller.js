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
exports.ShareController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const share_trail_dto_1 = require("./dto/share-trail.dto");
let ShareController = class ShareController {
    async shareTrail(dto) {
        const shareCode = this.generateShareCode();
        const baseUrl = 'https://shanjing.app';
        return {
            shareUrl: `${baseUrl}/s/${shareCode}`,
            qrCodeUrl: `${baseUrl}/api/qrcode/${shareCode}.png`,
        };
    }
    generateShareCode() {
        const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
        let code = '';
        for (let i = 0; i < 8; i++) {
            code += chars.charAt(Math.floor(Math.random() * chars.length));
        }
        return code;
    }
};
exports.ShareController = ShareController;
__decorate([
    (0, common_1.Post)('trail'),
    (0, common_1.HttpCode)(common_1.HttpStatus.OK),
    (0, swagger_1.ApiOperation)({
        summary: '生成路线分享链接',
        description: '根据路线ID生成分享链接和二维码',
    }),
    (0, swagger_1.ApiResponse)({
        status: 200,
        description: '生成成功',
        type: share_trail_dto_1.TrailShareResponseDto,
    }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [share_trail_dto_1.TrailShareDto]),
    __metadata("design:returntype", Promise)
], ShareController.prototype, "shareTrail", null);
exports.ShareController = ShareController = __decorate([
    (0, swagger_1.ApiTags)('分享'),
    (0, common_1.Controller)('share')
], ShareController);
//# sourceMappingURL=share.controller.js.map