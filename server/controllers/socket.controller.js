const logger = require('../utils/logger');

module.exports = {
  handleSocketEvents: (io, roomService, messageService) => {
    io.on('connection', (socket) => {
      logger.info('用户连接: %s', socket.id);

      socket.on('createRoom', (playerName) => {
        try {
          const room = roomService.createRoom(playerName, socket.id);
          socket.join(room.id);
          io.emit('roomUpdate', roomService.getAllRooms());
          socket.emit('roomCreated', room.id);
        } catch (error) {
          logger.error("创建房间失败:", error);
          socket.emit("roomError", error.message);
        }
      });

      socket.on('joinRoom', ({ roomId, playerName }) => {
        try {
          const room = roomService.joinRoom(roomId, playerName, socket.id);
          socket.join(roomId);

          // 加入时推送当前消息
          const messages = messageService.getMessages(roomId);
          socket.emit('messageUpdate', messages.map(m => m.toJSON()));

          io.to(roomId).emit('playerJoined', room);
          io.emit('roomUpdate', roomService.getRooms());
        } catch (error) {
          logger.error("加入房间失败:", error);
          socket.emit("roomError", error.message);
        }
      });

      socket.on('disconnect', () => {
        const conn = roomService.playerConnections.get(socket.id);
        if (conn) {
          const room = roomService.getRoom(conn.roomId);
          if (room) {
            room.players = room.players.filter(p => p.socketId !== socket.id);
            if (roomService.deleteRoomIfEmpty(conn.roomId)) {
              messageService.purgeRoomMessages(conn.roomId);
            }
          }
          roomService.playerConnections.delete(socket.id);
          io.emit('roomUpdate', roomService.getAllRooms());
        }
        logger.info('用户断开连接: %s', socket.id);
      });

      socket.on('leaveRoom', (roomId) => {
        try {
          const room = roomService.getRoom(roomId);
          if (!room) return;

          // 移除当前玩家
          room.players = room.players.filter(p => p.socketId !== socket.id);
          roomService.playerConnections.delete(socket.id);

          // 广播更新
          io.to(roomId).emit('playerLeft', socket.id);
          io.emit('roomUpdate', roomService.getAllRooms());

          // 房间为空时清理
          if (room.players.length === 0) {
            roomService.roomStore.delete(roomId);
            messageService.purgeRoomMessages(roomId);
          }
        } catch (error) {
          logger.error('退出房间失败:', error);
        }
      });

      socket.on('requestRooms', () => {
        socket.emit('roomUpdate', roomService.getAllRooms());
      });
    });
  }
};