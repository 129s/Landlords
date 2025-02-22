const MessageModel = require('../models/MessageModel');

class MessageService {
    constructor() {
        this.messageStore = new Map(); // roomId -> MessageModel[]
    }

    addMessage(roomId, senderId, senderName, content) {
        if (!this.messageStore.has(roomId)) {
            this.messageStore.set(roomId, []);
        }
        const msg = new MessageModel(roomId, senderId, senderName, content);
        this.messageStore.get(roomId).push(msg);
        return msg;
    }

    getMessages(roomId, limit = 50) {
        return this.messageStore.get(roomId)?.slice(-limit) || [];
    }

    purgeRoomMessages(roomId) {
        this.messageStore.delete(roomId);
    }
}

module.exports = MessageService;