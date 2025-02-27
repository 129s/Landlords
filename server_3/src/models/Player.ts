import { Poker } from "./Poker";


export class Player {
    id: string;
    name: string;
    cards: Poker[] = [];
    isLandlord = false;

    constructor(public socketId: string, name: string) {
        this.id = require('uuid').v4();
        this.name = name || `玩家_${Math.random().toString(36).substr(2, 4)}`;
    }
}