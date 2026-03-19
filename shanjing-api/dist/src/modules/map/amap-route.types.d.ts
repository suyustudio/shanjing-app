import { LatLng } from './amap.types';
export interface WalkingRouteRequest {
    origin: string;
    destination: string;
}
export interface DrivingRouteRequest {
    origin: string;
    destination: string;
    strategy?: number;
    waypoints?: string;
    avoidpolygons?: string;
    avoidroad?: string;
}
export interface BicyclingRouteRequest {
    origin: string;
    destination: string;
}
export interface WalkingRouteResult {
    status: string;
    info: string;
    route: {
        origin: string;
        destination: string;
        paths: WalkingPathInfo[];
    };
}
export interface DrivingRouteResult {
    status: string;
    info: string;
    route: {
        origin: string;
        destination: string;
        paths: DrivingPathInfo[];
    };
}
export interface BicyclingRouteResult {
    status: string;
    info: string;
    route: {
        origin: string;
        destination: string;
        paths: BicyclingPathInfo[];
    };
}
export interface WalkingPathInfo {
    origin: string;
    destination: string;
    distance: string;
    duration: string;
    steps: WalkingStepInfo[];
}
export interface DrivingPathInfo {
    origin: string;
    destination: string;
    distance: string;
    duration: string;
    strategy: string;
    tolls: string;
    toll_distance: string;
    restriction: string;
    traffic_lights: string;
    steps: DrivingStepInfo[];
}
export interface BicyclingPathInfo {
    origin: string;
    destination: string;
    distance: string;
    duration: string;
    steps: BicyclingStepInfo[];
}
export interface WalkingStepInfo {
    instruction: string;
    orientation: string;
    road: string;
    distance: string;
    duration: string;
    polyline: string;
    action: string;
    assistant_action: string;
    walk_type: string;
}
export interface DrivingStepInfo {
    instruction: string;
    orientation: string;
    road: string;
    distance: string;
    duration: string;
    polyline: string;
    action: string;
    assistant_action: string;
    toll_road: string;
    tolls: string;
    toll_distance: string;
}
export interface BicyclingStepInfo {
    instruction: string;
    orientation: string;
    road: string;
    distance: string;
    duration: string;
    polyline: string;
    action: string;
    assistant_action: string;
}
export interface StandardRouteResult {
    success: boolean;
    errorMessage?: string;
    origin?: string;
    destination?: string;
    paths: RoutePath[];
}
export interface RoutePath {
    distance: number;
    duration: number;
    tolls?: number;
    tollDistance?: number;
    restriction?: boolean;
    trafficLights?: number;
    steps: RouteStep[];
}
export interface RouteStep {
    instruction: string;
    road: string;
    distance: number;
    duration: number;
    polyline: LatLng[];
    tolls?: number;
    tollRoad?: string;
    action: string;
    assistantAction: string;
}
