const { v4: uuidv4 } = require('uuid');

class MessageModel {
    constructor(roomId, senderId, senderName, content) {
        this.id = uuidv4();
        this.roomId = roomId;
        this.senderId = senderId;
        this.senderName = senderName;
        this.content = content;
        this.timestamp = new Date();
    }
}

module.exports = MessageModel;