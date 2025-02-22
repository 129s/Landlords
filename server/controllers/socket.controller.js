// controllers/socket.controller.js
const roomService = require('../services/room.service');
const authService = require('../services/auth.service'); // 引入 authService
const logger = require('../utils/logger'); // 引入 logger

function handleSocketEvents(io) {
  io.on('connection', (socket) => {
    logger.info('A user connected: %s', socket.id);

    socket.on('createRoom', ({ roomName, userId }) => { // 接收 userId
      try {
        const user = global.authService.getUser(userId); // 通过 userId 获取 user
        if (!user) {
          throw new Error('用户不存在');
        }
        const room = global.roomService.createRoom(roomName, user); // 传递 user 对象
        socket.join(room.id);
        io.emit('roomUpdate', global.roomService.getRooms());
        logger.info('Room created by %s with ID: %s', user.username, room.id);
      } catch (error) {
        logger.error("Error creating room:", error);
        socket.emit("roomError", error.message);
      }
    });

    socket.on('joinRoom', ({ roomId, userId }) => { // 接收 userId
      try {
        const user = global.authService.getUser(userId); // 通过 userId 获取 user
        if (!user) {
          throw new Error('用户不存在');
        }
        const room = global.roomService.joinRoom(roomId, user); // 传递 user 对象
        socket.join(roomId);
        io.to(roomId).emit('playerJoined', room);
        io.emit('roomUpdate', global.roomService.getRooms());
        logger.info('%s joined room %s', user.username, roomId);
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
      logger.info('User disconnected: %s', socket.id);
    });
  });
}

module.exports = { handleSocketEvents };
