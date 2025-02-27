import { Player } from "./Player";

export enum RoomStatus {
    WAITING = 'waiting',
    PLAYING = 'playing'
}

export class Room {
    id: string;
    players: Player[] = [];
    status: RoomStatus = RoomStatus.WAITING;
    createdAt: Date = new Date();

    constructor(public maxPlayers: number = 3) {
        this.id = require('uuid').v4();
    }
}
