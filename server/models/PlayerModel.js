const { v4: uuidv4 } = require('uuid');

class PlayerModel {
    constructor(name, socketId) {
        this.id = uuidv4();
        this.name = name;
        this.socketId = socketId;
        this.seat = -1;
        this.cardCount = 0;
        this.isLandlord = false;
    }
}

module.exports = PlayerModel;

//=== 文件路径：models\RoomModel.js ===
class RoomModel {
    constructor(id, players) {
        this.id = id;
        this.players = players;
        this.createdAt = new Date();
    }
}

module.exports = RoomModel;