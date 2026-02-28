export declare class LatLngDto {
    lat: number;
    lng: number;
}
export declare class AddressComponentDto {
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
export declare class LocationInfoDto {
    location: LatLngDto;
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
export declare class PoiInfoDto {
    id: string;
    name: string;
    type: string;
    tel?: string;
    distance?: number;
    address: string;
    location: LatLngDto;
}
export declare class GeocodeDataDto {
    locations: LocationInfoDto[];
}
export declare class RegeocodeDataDto {
    formattedAddress: string;
    addressComponent: AddressComponentDto;
    pois?: PoiInfoDto[];
}
export declare class GeocodeResponseDto {
    success: boolean;
    errorMessage?: string;
    data: GeocodeDataDto;
}
export declare class RegeocodeResponseDto {
    success: boolean;
    errorMessage?: string;
    data: RegeocodeDataDto;
}
