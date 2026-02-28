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
exports.FilesService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const path = require("path");
const fs = require("fs/promises");
let FilesService = class FilesService {
    constructor(configService) {
        this.configService = configService;
        this.uploadDir = this.configService.get('UPLOAD_DIR', './uploads');
        this.baseUrl = this.configService.get('BASE_URL', 'http://localhost:3000');
    }
    async uploadAvatar(file, userId) {
        if (!file) {
            throw new common_1.BadRequestException({
                success: false,
                error: {
                    code: 'FILE_REQUIRED',
                    message: '请上传文件',
                },
            });
        }
        const allowedMimes = ['image/jpeg', 'image/jpg', 'image/png'];
        if (!allowedMimes.includes(file.mimetype)) {
            throw new common_1.BadRequestException({
                success: false,
                error: {
                    code: 'INVALID_FILE_TYPE',
                    message: '仅支持jpg、jpeg、png格式的图片',
                },
            });
        }
        const maxSize = 2 * 1024 * 1024;
        if (file.size > maxSize) {
            throw new common_1.BadRequestException({
                success: false,
                error: {
                    code: 'FILE_TOO_LARGE',
                    message: '文件大小不能超过2MB',
                },
            });
        }
        const ext = path.extname(file.originalname) || '.jpg';
        const filename = `avatar_${userId}_${Date.now()}${ext}`;
        const relativePath = path.join('avatars', filename);
        const fullPath = path.join(this.uploadDir, relativePath);
        const dir = path.dirname(fullPath);
        await fs.mkdir(dir, { recursive: true });
        await fs.writeFile(fullPath, file.buffer);
        return `${this.baseUrl}/uploads/${relativePath}`;
    }
    async deleteFile(fileUrl) {
        try {
            const relativePath = fileUrl.replace(`${this.baseUrl}/uploads/`, '');
            const fullPath = path.join(this.uploadDir, relativePath);
            await fs.unlink(fullPath);
        }
        catch (error) {
        }
    }
};
exports.FilesService = FilesService;
exports.FilesService = FilesService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], FilesService);
//# sourceMappingURL=files.service.js.map