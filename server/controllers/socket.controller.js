const roomService = require('../services/room.service');
const logger = require('../utils/logger'); // 引入 logger

function handleSocketEvents(io) {
  io.on('connection', (socket) => {
    logger.info('A user connected: %s', socket.id);

    socket.on('createRoom', (playerName) => {
      try {
        const room = global.roomService.createRoom(playerName, socket.id);

        socket.join(room.id);
        io.emit('roomUpdate', global.roomService.getRooms());
        logger.info('Room created by %s with ID: %s', playerName, room.id);
      } catch (error) {
        logger.error("Error creating room:", error);
        socket.emit("roomError", error.message);
      }
    });

    socket.on('joinRoom', ({ roomId, playerName }) => {
      try {
        const room = global.roomService.joinRoom(roomId, playerName, socket.id);
        socket.join(roomId);
        io.to(roomId).emit('playerJoined', room);
        io.emit('roomUpdate', global.roomService.getRooms());
        logger.info('%s joined room %s', playerName, roomId);
      } catch (error) {
        logger.error("Error joining room:", error);
        socket.emit("roomError", error.message);
      }
    });

    socket.on('requestRooms', () => {
      logger.info('Rooms requested');
      socket.emit('roomUpdate', global.roomService.getRooms());
    });
    socket.on('disconnect', () => {
      try {
        const connection = global.roomService.playerConnections.get(socket.id);
        if (connection) {
          const room = global.roomService.rooms.get(connection.roomId);

          // 正确移除玩家（使用filter保持不可变性）
          const updatedPlayers = room.players.filter(p => p.socketId !== socket.id);
          room.players = updatedPlayers;

          // 当房间变空时立即删除
          if (updatedPlayers.length === 0) {
            global.roomService.rooms.delete(connection.roomId);
            logger.info('Room %s deleted due to emptiness', connection.roomId);
          }

          // 更新所有客户端前检查房间是否仍然存在
          const roomsToEmit = updatedPlayers.length > 0
            ? global.roomService.getRooms()
            : global.roomService.getRooms().filter(r => r.id !== connection.roomId);

          io.emit('roomUpdate', roomsToEmit);
        }
      } finally {
        // 确保移除玩家连接记录
        global.roomService.playerConnections.delete(socket.id);
        logger.info('User disconnected: %s', socket.id);
      }
    });

    socket.on('sendMessage', (message) => {
      try {
        const room = global.roomService.addMessage(message.roomId, message);
        io.to(message.roomId).emit('messageReceived', {
          ...message,
          id: uuidv4(),
          senderId: socket.id,
          senderName: getPlayerName(socket.id) // 需要实现获取玩家名称的方法
        });
      } catch (error) {
        logger.error('发送消息失败:', error);
      }
    });
  });
}

module.exports = { handleSocketEvents };
