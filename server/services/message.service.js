// services/message.service.js
const BaseService = require('./base.service');
const MessageModel = require('../models/MessageModel');

class MessageService extends BaseService {
    constructor(stateStore) {
        super(stateStore);
    }

    addMessage(roomId, senderId, content) {
        this.validatePlayerInRoom(senderId, roomId);

        const message = new MessageModel(roomId, senderId, content);
        const messages = this.stateStore.messages.get(roomId) || [];
        messages.push(message);

        this.stateStore.messages.set(roomId, messages);
        return message;
    }

    getMessages(roomId, limit = 50) {
        return this.stateStore.messages.get(roomId)?.slice(-limit) || [];
    }
}

module.exports = MessageService;