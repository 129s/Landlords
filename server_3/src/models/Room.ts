import { Player } from "./Player";

export enum RoomStatus {
    WAITING = 'waiting',
    PLAYING = 'playing'
}

export class Room {
    id: string;
    players: Player[] = [];
    roomStatus: RoomStatus = RoomStatus.WAITING;

    constructor() {
        this.id = require('uuid').v4();
    }
}
