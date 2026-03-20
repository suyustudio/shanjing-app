import { AmapGeocodeService } from './amap-geocode.service';
import { AmapRouteService } from './amap-route.service';
import { GeocodeDto, RegeocodeDto, GeocodeResponseDto, RegeocodeResponseDto, WalkingRouteDto, DrivingRouteDto, BicyclingRouteDto, RoutePlanningDto, RouteResponseDto } from './dto';
export declare class MapController {
    private readonly amapGeocodeService;
    private readonly amapRouteService;
    constructor(amapGeocodeService: AmapGeocodeService, amapRouteService: AmapRouteService);
    geocode(dto: GeocodeDto): Promise<GeocodeResponseDto>;
    regeocode(dto: RegeocodeDto): Promise<RegeocodeResponseDto>;
    walkingRoute(dto: WalkingRouteDto): Promise<RouteResponseDto>;
    drivingRoute(dto: DrivingRouteDto): Promise<RouteResponseDto>;
    bicyclingRoute(dto: BicyclingRouteDto): Promise<RouteResponseDto>;
    routePlanning(dto: RoutePlanningDto): Promise<RouteResponseDto>;
}
