import { AmapGeocodeService } from './amap-geocode.service';
import { GeocodeDto, RegeocodeDto, GeocodeResponseDto, RegeocodeResponseDto } from './dto';
export declare class MapController {
    private readonly amapGeocodeService;
    constructor(amapGeocodeService: AmapGeocodeService);
    geocode(dto: GeocodeDto): Promise<GeocodeResponseDto>;
    regeocode(dto: RegeocodeDto): Promise<RegeocodeResponseDto>;
}
