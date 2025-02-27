import { Poker } from "./Poker";


export class Player {
    id: string;
    name: string;
    seat: number = 0;
    cardCount: number = 0;
    ready: boolean = false;
    isLandlord = false;
    bidValue = 0;

    constructor(public socketId: string, name: string) {
        this.id = require('uuid').v4();
        this.name = name || `玩家_${Math.random().toString(36).substr(2, 4)}`;
    }
}