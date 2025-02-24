const MessageModel = require('../models/MessageModel');
const logger = require('../utils/logger');

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
        logger.info(`房间 %s 收到消息: %s 来自 %s`, roomId, content, senderId);
        return msg;
    }

    getMessages(roomId, limit = 50) {
        const messages = this.messageStore.get(roomId)?.slice(-limit) || [];
        logger.debug(`房间 %s 请求消息列表，数量: %s`, roomId, messages.length);
        return messages;
    }

    purgeRoomMessages(roomId) {
        this.messageStore.delete(roomId);
        logger.info(`房间 %s 消息已清除`, roomId);
    }
}

module.exports = MessageService;
