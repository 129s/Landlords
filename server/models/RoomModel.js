class RoomModel {
    constructor(id, players) {
        this.id = id;
        this.players = players;
        this.createdAt = new Date();
        this.status = 'waiting';
    }
}

module.exports = RoomModel;