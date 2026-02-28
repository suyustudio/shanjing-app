import { AmapConfigService } from './amap-config.service';
import { GeocodeRequest, RegeocodeRequest, StandardGeocodeResult, StandardRegeocodeResult, LatLng } from './amap.types';
export declare class AmapGeocodeService {
    private readonly configService;
    private readonly logger;
    private readonly httpClient;
    constructor(configService: AmapConfigService);
    geocode(request: GeocodeRequest): Promise<StandardGeocodeResult>;
    regeocode(request: RegeocodeRequest): Promise<StandardRegeocodeResult>;
    batchGeocode(addresses: string[], city?: string): Promise<Map<string, StandardGeocodeResult>>;
    formatLocation(lat: number, lng: number): string;
    parseLocation(location: string): LatLng;
    private convertToLocationInfo;
    private convertToRegeocodeResult;
}
