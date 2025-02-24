class RoomModel {
    constructor(id, players) {
        this.id = id;
        this.players = players;
        this.createdAt = new Date();
        this.status = 'PREPARING'; // 新增状态字段
    }
}

module.exports = RoomModel;