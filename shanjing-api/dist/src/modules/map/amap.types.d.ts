export interface LatLng {
    lat: number;
    lng: number;
}
export interface GeocodeRequest {
    address: string;
    city?: string;
}
export interface RegeocodeRequest {
    location: string;
    poitype?: string;
    radius?: number;
    extensions?: 'base' | 'all';
    homeorcorp?: 'home' | 'corp';
}
export interface GeocodeResult {
    status: string;
    info: string;
    count: string;
    geocodes: GeocodeInfo[];
}
export interface GeocodeInfo {
    country: string;
    province: string;
    city: string;
    district: string;
    township: string;
    neighborhood?: {
        name: string;
        type: string;
    };
    building?: {
        name: string;
        type: string;
    };
    street?: string;
    number?: string;
    adcode: string;
    formatted_address: string;
    addressComponent?: AddressComponent;
    location: string;
    level: string;
}
export interface AddressComponent {
    country: string;
    province: string;
    city: string;
    district: string;
    township: string;
    neighborhood?: {
        name: string;
        type: string;
    };
    building?: {
        name: string;
        type: string;
    };
    street?: string;
    number?: string;
    adcode: string;
}
export interface RegeocodeResult {
    status: string;
    info: string;
    regeocode: RegeocodeInfo;
}
export interface RegeocodeInfo {
    formatted_address: string;
    addressComponent: AddressComponent;
    pois?: PoiInfo[];
    roads?: RoadInfo[];
    roadinters?: RoadIntersection[];
}
export interface PoiInfo {
    id: string;
    name: string;
    type: string;
    tel?: string;
    direction?: string;
    distance?: string;
    location: string;
    address: string;
    poiweight?: string;
    businessarea?: string;
}
export interface RoadInfo {
    id: string;
    name: string;
    direction: string;
    distance: string;
    location: string;
}
export interface RoadIntersection {
    direction: string;
    distance: string;
    location: string;
    first_id: string;
    first_name: string;
    second_id: string;
    second_name: string;
}
export interface StandardGeocodeResult {
    success: boolean;
    errorMessage?: string;
    locations: LocationInfo[];
}
export interface StandardRegeocodeResult {
    success: boolean;
    errorMessage?: string;
    formattedAddress: string;
    addressComponent: AddressComponentDetail;
    pois?: PoiDetail[];
}
export interface LocationInfo {
    location: LatLng;
    formattedAddress: string;
    country: string;
    province: string;
    city: string;
    district: string;
    street?: string;
    streetNumber?: string;
    adcode: string;
    level: string;
}
export interface AddressComponentDetail {
    country: string;
    province: string;
    city: string;
    district: string;
    township: string;
    neighborhood?: string;
    building?: string;
    street?: string;
    number?: string;
    adcode: string;
}
export interface PoiDetail {
    id: string;
    name: string;
    type: string;
    tel?: string;
    distance?: number;
    address: string;
    location: LatLng;
}
