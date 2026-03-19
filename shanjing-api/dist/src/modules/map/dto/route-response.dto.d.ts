export declare class LatLngDto {
    lat: number;
    lng: number;
}
export declare class RouteStepDto {
    instruction: string;
    road: string;
    distance: number;
    duration: number;
    polyline: LatLngDto[];
    tolls?: number;
    tollRoad?: string;
    action: string;
    assistantAction: string;
}
export declare class RoutePathDto {
    distance: number;
    duration: number;
    tolls?: number;
    tollDistance?: number;
    restriction?: boolean;
    trafficLights?: number;
    steps: RouteStepDto[];
}
export declare class RouteDataDto {
    origin: string;
    destination: string;
    paths: RoutePathDto[];
}
export declare class RouteResponseDto {
    success: boolean;
    errorMessage?: string;
    data: RouteDataDto;
}
