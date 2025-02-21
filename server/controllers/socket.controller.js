const roomService = require('../services/room.service');
const logger = require('../utils/logger'); // 引入 logger

function handleSocketEvents(io) {
  io.on('connection', (socket) => {
    logger.info('A user connected: %s', socket.id);

    socket.on('createRoom', (playerName) => {
      try {
        const room = global.roomService.createRoom(playerName);
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
        const room = global.roomService.joinRoom(roomId, playerName);
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
      logger.info('User disconnected: %s', socket.id);
    });
  });
}

module.exports = { handleSocketEvents };
