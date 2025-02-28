// services/state.store.js
class StateStore {
    constructor() {
        this.rooms = new Map();       // roomId -> RoomModel
        this.connections = new Map(); // socketId -> roomId
        this.messages = new Map();    // roomId -> MessageModel[]
        this.games = new Map();       // roomId -> GameState
    }

    // 原子操作示例
    atomicAddPlayer(roomId, player) {
        if (!this.rooms.has(roomId)) return false;

        const room = this.rooms.get(roomId);
        if (room.players.length >= 3) return false;

        this.connections.set(player.id, roomId);
        room.players.push(player);
        return true;
    }
}

module.exports = StateStore;