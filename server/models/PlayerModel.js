class PlayerModel {
    constructor(socketId) {
        this.id = socketId; // 唯一标识
        this.name = `玩家${socketId.slice(-5)}`; // 生成可读的默认名称
        this.seat = -1;
        this.cardCount = 0;
        this.isLandlord = false;
    }
}
module.exports = PlayerModel;