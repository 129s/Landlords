const { v4: uuidv4 } = require('uuid');

class PlayerModel {
    constructor(name) {
        this.id = uuidv4();
        this.name = name;
        this.seat = 0;
        this.cardCount = 17;
        this.isLandlord = false;
    }
}

module.exports = PlayerModel;
