export declare class WalkingRouteDto {
    originLat: number;
    originLng: number;
    destLat: number;
    destLng: number;
}
export declare class DrivingRouteDto {
    originLat: number;
    originLng: number;
    destLat: number;
    destLng: number;
    strategy?: number;
}
export declare class BicyclingRouteDto {
    originLat: number;
    originLng: number;
    destLat: number;
    destLng: number;
}
export declare enum RouteType {
    WALKING = "walking",
    DRIVING = "driving",
    BICYCLING = "bicycling"
}
export declare class RoutePlanningDto {
    originLat: number;
    originLng: number;
    destLat: number;
    destLng: number;
    type: RouteType;
    strategy?: number;
}
