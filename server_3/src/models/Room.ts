import { Player } from "./Player";
import { GameController } from "../controllers/GameController";
import { Server } from "socket.io";

export enum RoomStatus {
    WAITING = 'waiting',
    PLAYING = 'playing'
}

export class Room {
    id: string;
    players: Player[] = [];
    roomStatus: RoomStatus = RoomStatus.WAITING;
    gameController: GameController;

    constructor(io: Server) {
        this.id = require('uuid').v4();
        this.gameController = new GameController(io, this);
    }

    getAvailableSeat(): number {
        for (let i = 0; i < 3; i++) {
            if (!this.players.some(p => p.seat === i)) return i;
        }
        return -1;
    }
}