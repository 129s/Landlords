// server/models/RoomModel.js
class RoomModel {
    constructor(id, players, roomName) {
        this.id = id
        this.players = players
        this.createdAt = new Date()
        this.status = 'waiting' // waiting/playing
        this.roomName = roomName; // Add roomName
    }
}

module.exports = RoomModel;
