import { distributedDataObject } from '@kit.ArkData';

export class MissionInfo {
    MissionName: string;
    MissionDetails: string;
    MissionRequest: number;
    MissionState: boolean;

    constructor(name: string, details: string, request: number, state: boolean) {
        this.MissionName = name;
        this.MissionDetails = details;
        this.MissionRequest = request;
        this.MissionState = state;
    }
}
