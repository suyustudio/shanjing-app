export interface EmergencyContact {
    name: string;
    phone: string;
    relation: string;
}
export interface UserInfo {
    id: string;
    nickname?: string;
    avatarUrl?: string;
    phone?: string;
    emergencyContacts?: EmergencyContact[];
    settings?: Record<string, any>;
    createdAt: Date;
    updatedAt: Date;
}
export interface UserResponse {
    success: boolean;
    data: UserInfo;
}
export interface EmergencyContactsResponse {
    success: boolean;
    data: {
        emergencyContacts: EmergencyContact[];
        updatedAt: Date;
    };
}
export interface PhoneResponse {
    success: boolean;
    data: {
        phone: string;
        updatedAt: Date;
    };
}
