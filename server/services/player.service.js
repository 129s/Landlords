// services/player.service.js
const BaseService = require('./base.service');
const PlayerModel = require('../models/PlayerModel');

class PlayerService extends BaseService {
    constructor(stateStore) {
        super(stateStore);
    }

    createPlayer(socketId) {
        const player = new PlayerModel(socketId);
        logger.info(`创建玩家: ${socketId}`);
        return player;
    }

    updatePlayerName(socketId, name) {
        const player = this.getPlayer(socketId);
        this._validateNameFormat(name);
        player.name = name;
        logger.info(`玩家更名: ${socketId} -> ${name}`);
    }

    _validateNameFormat(name) {
        if (name.length > 12 || !/^[\w\u4e00-\u9fa5]+$/.test(name)) {
            logger.error(`非法玩家名称: ${name}`);
            throw new Error('INVALID_PLAYER_NAME');
        }
    }
}

module.exports = PlayerService;