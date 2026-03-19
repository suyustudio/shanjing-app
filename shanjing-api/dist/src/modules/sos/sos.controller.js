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
var SosController_1;
Object.defineProperty(exports, "__esModule", { value: true });
exports.SosController = void 0;
const common_1 = require("@nestjs/common");
const swagger_1 = require("@nestjs/swagger");
const sos_trigger_dto_1 = require("./dto/sos-trigger.dto");
let SosController = SosController_1 = class SosController {
    constructor() {
        this.logger = new common_1.Logger(SosController_1.name);
    }
    async triggerSos(dto) {
        const timestamp = dto.timestamp || Date.now();
        this.logger.warn(`🆘 SOS触发 - 位置: [${dto.location.lat}, ${dto.location.lng}], 时间: ${new Date(timestamp).toISOString()}`);
        this.logger.log('📱 模拟发送紧急短信通知...');
        return {
            success: true,
            message: 'SOS紧急求助已触发，救援人员将尽快联系您',
        };
    }
};
exports.SosController = SosController;
__decorate([
    (0, common_1.Post)('trigger'),
    (0, swagger_1.ApiOperation)({ summary: '触发SOS紧急求助' }),
    (0, swagger_1.ApiResponse)({ status: 200, description: 'SOS已触发' }),
    __param(0, (0, common_1.Body)()),
    __metadata("design:type", Function),
    __metadata("design:paramtypes", [sos_trigger_dto_1.SosTriggerDto]),
    __metadata("design:returntype", Promise)
], SosController.prototype, "triggerSos", null);
exports.SosController = SosController = SosController_1 = __decorate([
    (0, swagger_1.ApiTags)('SOS紧急求助'),
    (0, common_1.Controller)('sos')
], SosController);
//# sourceMappingURL=sos.controller.js.map