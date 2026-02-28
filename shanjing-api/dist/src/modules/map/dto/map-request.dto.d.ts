export declare class GeocodeDto {
    address: string;
    city?: string;
}
export declare class RegeocodeDto {
    lat: number;
    lng: number;
    extensions?: 'base' | 'all';
    radius?: number;
}
