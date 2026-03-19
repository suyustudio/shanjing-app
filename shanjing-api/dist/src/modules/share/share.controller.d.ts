import { TrailShareDto, TrailShareResponseDto } from './dto/share-trail.dto';
export declare class ShareController {
    shareTrail(dto: TrailShareDto): Promise<TrailShareResponseDto>;
    private generateShareCode;
}
