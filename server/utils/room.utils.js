const logger = require('./logger');

// 房间状态验证工具
const validateRoomState = (room) => {
    const validations = [
        { check: !room.id, message: '缺少房间ID' },
        { check: room.players.length > 3, message: '玩家数量超过限制' },
        { check: !room.players.every(p => p.name), message: '存在无效玩家名称' }
    ];

    const error = validations.find(v => v.check);
    if (error) {
        logger.error(`房间状态异常: %s`, error.message);
        throw new Error(`房间状态异常: ${error.message}`);
    }
};

// 玩家匹配算法
const matchPlayers = (players) => {
    const sortedPlayers = players.sort((a, b) => a.joinTime - b.joinTime); // 按加入时间排序
    logger.debug(`玩家匹配，排序后的玩家数量: %s`, sortedPlayers.length);
    return sortedPlayers.slice(0, 3); // 只保留前三位玩家
};

module.exports = { validateRoomState, matchPlayers };
