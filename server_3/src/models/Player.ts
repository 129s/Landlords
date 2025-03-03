import { Poker } from "./Poker";


export class Player {
    id: string; //同时也是socketid
    name: string;
    seat: number = 0;
    cardCount: number = 0;
    ready: boolean = false;
    isLandlord = false;
    bidValue = -1;

    constructor(socketId: string, name: string, seat: number) {
        this.id = socketId;
        this.name = name || `玩家_${Math.random().toString(36).substr(2, 4)}`;
        this.seat = seat;
    }
}