declare class EmergencyContactDto {
    name: string;
    phone: string;
    relation: string;
}
export declare class UpdateUserDto {
    nickname?: string;
    settings?: Record<string, any>;
}
export declare class UpdateEmergencyContactsDto {
    contacts: EmergencyContactDto[];
}
export declare class BindPhoneDto {
    phone: string;
    code: string;
}
export {};
