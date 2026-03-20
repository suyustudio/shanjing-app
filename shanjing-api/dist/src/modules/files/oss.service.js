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
exports.OssService = void 0;
const common_1 = require("@nestjs/common");
const config_1 = require("@nestjs/config");
const OSS = require("ali-oss");
const sharp = require("sharp");
let OssService = class OssService {
    constructor(configService) {
        this.configService = configService;
        this.bucket = this.configService.get('OSS_BUCKET', '');
        this.region = this.configService.get('OSS_REGION', '');
        const accessKeyId = this.configService.get('OSS_ACCESS_KEY_ID', '');
        const accessKeySecret = this.configService.get('OSS_ACCESS_KEY_SECRET', '');
        this.baseUrl = this.configService.get('OSS_BASE_URL', '');
        if (this.bucket && this.region && accessKeyId && accessKeySecret) {
            this.client = new OSS({
                region: this.region,
                accessKeyId,
                accessKeySecret,
                bucket: this.bucket,
            });
        }
    }
    isConfigured() {
        return !!this.client;
    }
    async generatePhotoUploadUrl(userId, filename, contentType) {
        if (!this.isConfigured()) {
            throw new Error('OSS not configured');
        }
        const ext = filename.split('.').pop() || 'jpg';
        const timestamp = Date.now();
        const random = Math.random().toString(36).substring(2, 8);
        const key = `photos/${userId}/${timestamp}_${random}.${ext}`;
        const uploadUrl = this.client.signatureUrl('PUT', key, {
            expires: 900,
            'Content-Type': contentType,
        });
        const accessUrl = `${this.baseUrl}/${key}`;
        const thumbnailKey = `photos/${userId}/${timestamp}_${random}_thumb.${ext}`;
        const thumbnailUrl = `${this.baseUrl}/${thumbnailKey}`;
        return {
            uploadUrl,
            accessUrl,
            thumbnailUrl,
            key,
            expires: 900,
        };
    }
    async generateBatchUploadUrls(userId, files) {
        const results = await Promise.all(files.map((file) => this.generatePhotoUploadUrl(userId, file.filename, file.contentType)));
        return results;
    }
    async deleteFile(fileUrl) {
        if (!this.isConfigured()) {
            return;
        }
        try {
            const key = fileUrl.replace(`${this.baseUrl}/`, '');
            await this.client.delete(key);
            const thumbKey = key.replace(/\.([^.]+)$/, '_thumb.$1');
            await this.client.delete(thumbKey).catch(() => {
            });
        }
        catch (error) {
            console.error('Failed to delete OSS file:', error);
        }
    }
    async generateThumbnail(imageBuffer, maxWidth = 400) {
        return sharp(imageBuffer)
            .resize(maxWidth, null, {
            withoutEnlargement: true,
            fit: 'inside',
        })
            .jpeg({ quality: 80 })
            .toBuffer();
    }
    async getImageMetadata(imageBuffer) {
        const metadata = await sharp(imageBuffer).metadata();
        return {
            width: metadata.width || 0,
            height: metadata.height || 0,
        };
    }
};
exports.OssService = OssService;
exports.OssService = OssService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [config_1.ConfigService])
], OssService);
//# sourceMappingURL=oss.service.js.map