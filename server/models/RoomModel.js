class RoomModel {
    constructor(id, players) {
        this.id = id;
        this.players = players;
        this.messages = [];
        this.createdAt = new Date();
    }

    addMessage(message) {
        this.messages.push({
            ...message,
            id: require('uuid').v4(),
            timestamp: new Date()
        });
        return this.messages.slice(-50);
    }
}

module.exports = RoomModel;