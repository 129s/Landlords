const { v4: uuidv4 } = require('uuid');

class MessageModel {
    constructor(roomId, senderId, senderName, content, type = 'text') {
        this.id = uuidv4();
        this.roomId = roomId;
        this.senderId = senderId;
        this.senderName = senderName;
        this.content = content;
        this.type = type;
        this.timestamp = new Date();
    }

    toJSON() {
        return {
            id: this.id,
            roomId: this.roomId,
            senderId: this.senderId,
            senderName: this.senderName,
            content: this.content,
            type: this.type,
            timestamp: this.timestamp.toISOString()
        };
    }
}

module.exports = MessageModel;