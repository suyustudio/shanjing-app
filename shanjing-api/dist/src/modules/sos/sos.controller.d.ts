import { SosTriggerDto } from './dto/sos-trigger.dto';
export declare class SosController {
    private readonly logger;
    triggerSos(dto: SosTriggerDto): Promise<{
        success: boolean;
        message: string;
    }>;
}
