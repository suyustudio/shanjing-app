import { AmapConfigService } from './amap-config.service';
import { WalkingRouteRequest, DrivingRouteRequest, BicyclingRouteRequest, StandardRouteResult, LatLng } from './amap-route.types';
export declare class AmapRouteService {
    private readonly configService;
    private readonly logger;
    private readonly httpClient;
    constructor(configService: AmapConfigService);
    walkingRoute(request: WalkingRouteRequest): Promise<StandardRouteResult>;
    drivingRoute(request: DrivingRouteRequest): Promise<StandardRouteResult>;
    bicyclingRoute(request: BicyclingRouteRequest): Promise<StandardRouteResult>;
    batchWalkingRoute(requests: WalkingRouteRequest[]): Promise<Map<string, StandardRouteResult>>;
    formatLocation(lat: number, lng: number): string;
    parseLocation(location: string): LatLng;
    private convertWalkingPath;
    private convertDrivingPath;
    private convertBicyclingPath;
    private parsePolyline;
}
