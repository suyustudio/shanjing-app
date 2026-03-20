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
exports.RecordingService = void 0;
const common_1 = require("@nestjs/common");
const prisma_service_1 = require("../../database/prisma.service");
let RecordingService = class RecordingService {
    constructor(prisma) {
        this.prisma = prisma;
    }
    async uploadRecording(dto, userId) {
        if (!dto.trackData || !dto.trackData.trackPoints || dto.trackData.trackPoints.length < 2) {
            throw new common_1.BadRequestException({
                success: false,
                error: { code: 'INVALID_TRACK_DATA', message: '轨迹数据无效，至少需要2个轨迹点' },
            });
        }
        const trackPoints = dto.trackData.trackPoints;
        const pois = dto.trackData.pois || [];
        const stats = this.calculateTrackStats(trackPoints);
        const recording = await this.prisma.trailRecording.create({
            data: {
                userId,
                sessionId: dto.sessionId,
                trailName: dto.trailName,
                description: dto.description,
                city: dto.city,
                district: dto.district,
                difficulty: dto.difficulty,
                tags: dto.tags || [],
                status: 'PENDING',
                distanceMeters: stats.distance,
                durationSeconds: dto.trackData.durationSeconds || 0,
                elevationGain: stats.elevationGain,
                elevationLoss: stats.elevationLoss,
                pointCount: trackPoints.length,
                poiCount: pois.length,
                trackData: dto.trackData,
            },
        });
        return {
            success: true,
            data: {
                recordingId: recording.id,
                trailName: recording.trailName,
                status: recording.status,
                message: '轨迹上传成功，等待审核后发布',
            },
        };
    }
    async getUserRecordings(userId, query) {
        const { status, page = 1, limit = 20 } = query;
        const skip = (page - 1) * limit;
        const where = { userId };
        if (status) {
            where.status = status.toUpperCase();
        }
        const [recordings, total] = await Promise.all([
            this.prisma.trailRecording.findMany({
                where,
                skip,
                take: limit,
                orderBy: { createdAt: 'desc' },
                select: {
                    id: true,
                    trailName: true,
                    status: true,
                    city: true,
                    district: true,
                    difficulty: true,
                    distanceMeters: true,
                    durationSeconds: true,
                    pointCount: true,
                    poiCount: true,
                    createdAt: true,
                    trailId: true,
                },
            }),
            this.prisma.trailRecording.count({ where }),
        ]);
        return {
            success: true,
            data: recordings.map(r => ({
                id: r.id,
                trailName: r.trailName,
                status: r.status,
                city: r.city,
                district: r.district,
                difficulty: r.difficulty,
                distanceKm: (r.distanceMeters / 1000).toFixed(2),
                durationMin: Math.floor(r.durationSeconds / 60),
                pointCount: r.pointCount,
                poiCount: r.poiCount,
                trailId: r.trailId,
                createdAt: r.createdAt,
            })),
            meta: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    async getRecordingDetail(recordingId, userId) {
        const recording = await this.prisma.trailRecording.findFirst({
            where: {
                id: recordingId,
                userId,
            },
        });
        if (!recording) {
            throw new common_1.NotFoundException({
                success: false,
                error: { code: 'RECORDING_NOT_FOUND', message: '录制记录不存在' },
            });
        }
        return {
            success: true,
            data: {
                id: recording.id,
                trailName: recording.trailName,
                description: recording.description,
                status: recording.status,
                city: recording.city,
                district: recording.district,
                difficulty: recording.difficulty,
                tags: recording.tags,
                distanceMeters: recording.distanceMeters,
                durationSeconds: recording.durationSeconds,
                elevationGain: recording.elevationGain,
                elevationLoss: recording.elevationLoss,
                pointCount: recording.pointCount,
                poiCount: recording.poiCount,
                trackData: recording.trackData,
                trailId: recording.trailId,
                reviewComment: recording.reviewComment,
                createdAt: recording.createdAt,
                updatedAt: recording.updatedAt,
            },
        };
    }
    async getPendingRecordings(query) {
        const { page = 1, limit = 20 } = query;
        const skip = (page - 1) * limit;
        const [recordings, total] = await Promise.all([
            this.prisma.trailRecording.findMany({
                where: { status: 'PENDING' },
                skip,
                take: limit,
                orderBy: { createdAt: 'asc' },
                include: {
                    user: {
                        select: {
                            id: true,
                            nickname: true,
                            avatarUrl: true,
                        },
                    },
                },
            }),
            this.prisma.trailRecording.count({ where: { status: 'PENDING' } }),
        ]);
        return {
            success: true,
            data: recordings.map(r => ({
                id: r.id,
                trailName: r.trailName,
                description: r.description,
                city: r.city,
                district: r.district,
                difficulty: r.difficulty,
                distanceMeters: r.distanceMeters,
                durationSeconds: r.durationSeconds,
                pointCount: r.pointCount,
                poiCount: r.poiCount,
                createdAt: r.createdAt,
                user: r.user,
            })),
            meta: {
                page,
                limit,
                total,
                totalPages: Math.ceil(total / limit),
            },
        };
    }
    async approveRecording(recordingId, dto) {
        const recording = await this.prisma.trailRecording.findUnique({
            where: { id: recordingId },
        });
        if (!recording) {
            throw new common_1.NotFoundException({
                success: false,
                error: { code: 'RECORDING_NOT_FOUND', message: '录制记录不存在' },
            });
        }
        if (recording.status !== 'PENDING') {
            throw new common_1.BadRequestException({
                success: false,
                error: { code: 'INVALID_STATUS', message: '该记录已被处理' },
            });
        }
        const trackData = recording.trackData;
        const trackPoints = trackData.trackPoints || [];
        const pois = trackData.pois || [];
        const bounds = this.calculateBounds(trackPoints);
        const startPoint = trackPoints[0];
        const endPoint = trackPoints[trackPoints.length - 1];
        const trail = await this.prisma.trail.create({
            data: {
                name: dto.trailName || recording.trailName,
                description: dto.description || recording.description,
                distanceKm: recording.distanceMeters / 1000,
                durationMin: Math.floor(recording.durationSeconds / 60),
                elevationGainM: Math.floor(recording.elevationGain),
                difficulty: (dto.difficulty || recording.difficulty),
                tags: dto.tags || recording.tags,
                city: recording.city,
                district: recording.district,
                startPointLat: startPoint.latitude,
                startPointLng: startPoint.longitude,
                startPointAddress: dto.startPointAddress,
                coverImages: dto.coverImages || [],
                boundsNorth: bounds.north,
                boundsSouth: bounds.south,
                boundsEast: bounds.east,
                boundsWest: bounds.west,
                isActive: true,
                isPublished: true,
                createdBy: recording.userId,
                pois: {
                    create: pois.map((poi, index) => ({
                        name: poi.name || poi.type,
                        description: poi.description,
                        lat: poi.latitude,
                        lng: poi.longitude,
                        type: poi.type,
                        order: index,
                    })),
                },
            },
        });
        await this.prisma.trailRecording.update({
            where: { id: recordingId },
            data: {
                status: 'APPROVED',
                trailId: trail.id,
                reviewComment: dto.comment,
                reviewedAt: new Date(),
            },
        });
        return {
            success: true,
            data: {
                recordingId: recording.id,
                trailId: trail.id,
                trailName: trail.name,
                message: '审核通过，路线已发布',
            },
        };
    }
    async rejectRecording(recordingId, reason) {
        const recording = await this.prisma.trailRecording.findUnique({
            where: { id: recordingId },
        });
        if (!recording) {
            throw new common_1.NotFoundException({
                success: false,
                error: { code: 'RECORDING_NOT_FOUND', message: '录制记录不存在' },
            });
        }
        if (recording.status !== 'PENDING') {
            throw new common_1.BadRequestException({
                success: false,
                error: { code: 'INVALID_STATUS', message: '该记录已被处理' },
            });
        }
        await this.prisma.trailRecording.update({
            where: { id: recordingId },
            data: {
                status: 'REJECTED',
                reviewComment: reason,
                reviewedAt: new Date(),
            },
        });
        return {
            success: true,
            data: {
                recordingId: recording.id,
                message: '已拒绝该录制',
                reason,
            },
        };
    }
    calculateTrackStats(trackPoints) {
        let distance = 0;
        let elevationGain = 0;
        let elevationLoss = 0;
        for (let i = 1; i < trackPoints.length; i++) {
            const prev = trackPoints[i - 1];
            const curr = trackPoints[i];
            distance += this.calculateDistance(prev.latitude, prev.longitude, curr.latitude, curr.longitude);
            const altDiff = curr.altitude - prev.altitude;
            if (altDiff > 0.5) {
                elevationGain += altDiff;
            }
            else if (altDiff < -0.5) {
                elevationLoss += Math.abs(altDiff);
            }
        }
        return {
            distance,
            elevationGain,
            elevationLoss,
        };
    }
    calculateBounds(trackPoints) {
        let north = trackPoints[0].latitude;
        let south = trackPoints[0].latitude;
        let east = trackPoints[0].longitude;
        let west = trackPoints[0].longitude;
        for (const point of trackPoints) {
            if (point.latitude > north)
                north = point.latitude;
            if (point.latitude < south)
                south = point.latitude;
            if (point.longitude > east)
                east = point.longitude;
            if (point.longitude < west)
                west = point.longitude;
        }
        return { north, south, east, west };
    }
    calculateDistance(lat1, lng1, lat2, lng2) {
        const R = 6371000;
        const dLat = this.toRadians(lat2 - lat1);
        const dLng = this.toRadians(lng2 - lng1);
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.toRadians(lat1)) *
                Math.cos(this.toRadians(lat2)) *
                Math.sin(dLng / 2) *
                Math.sin(dLng / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return R * c;
    }
    toRadians(degrees) {
        return degrees * (Math.PI / 180);
    }
};
exports.RecordingService = RecordingService;
exports.RecordingService = RecordingService = __decorate([
    (0, common_1.Injectable)(),
    __metadata("design:paramtypes", [prisma_service_1.PrismaService])
], RecordingService);
//# sourceMappingURL=recording.service.js.map