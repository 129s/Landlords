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

    getAvailableSeat(): number {
        for (let i = 0; i < 3; i++) {
            if (!this.players.some(p => p.seat === i)) return i;
        }
        return -1;
    }

}
