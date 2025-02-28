import { Socket, Server } from "socket.io";
import { Room, RoomStatus } from "../models/Room";
import { Player } from "../models/Player";
import { GamePhase } from "../constants/constants";
import { GameController } from "./GameController";

export class RoomController {
    private rooms = new Map<string, Room>();
    private playerRoomMap = new Map<string, string>();

    constructor(private io: Server) {
        this.setupSocketHandlers();
    }

    private setupSocketHandlers() {
        this.io.on('connection', (socket: Socket) => {
            this.sendRoomList();
            socket.on('createRoom', (data, callback) => this.handleCreateRoom(socket, callback));
            socket.on('joinRoom', (roomId, callback) => this.handleJoinRoom(socket, roomId, callback));
            socket.on('leaveRoom', (data, callback) => this.handleLeaveRoom(socket, callback));
            socket.on('getRoomList', () => this.sendRoomList(socket));
            socket.on('toggleReady', (data, callback) => this.handleToggleReady(socket, callback))
        });
    }

    private handleToggleReady(socket: Socket, callback: Function) {
        const room = this.getPlayerRoom(socket.id);
        if (!room) {
            callback({ 'status': 'fail' });
            return;
        }

        const player = room.players.find(p => p.socketId === socket.id);
        if (!player) {
            callback({ 'status': 'fail' });
            return;
        }

        player.ready = !player.ready;

        // 检测是否开始游戏
        if (room.players.every(p => p.ready) &&
            room.players.length === 3) {
            room.roomStatus = RoomStatus.PLAYING;
            room.gameController.initializeGame();
        }

        this.updateRoomState(room);
        callback({ 'status': 'success' });
    }

    private handleCreateRoom(socket: Socket, callback: Function) {
        const room = new Room(this.io);
        this.rooms.set(room.id, room);
        this.updateRoomState(room);

        callback({ 'roomId': room.id, 'status': 'success' })
    }

    private handleJoinRoom(socket: Socket, roomId: string, callback: Function) {
        const room = this.rooms.get(roomId);
        if (!room) {
            callback({ 'status': 'fail' })
            return;
        }

        const seatIndex = room.getAvailableSeat();
        if (seatIndex === -1) return callback({ 'status': 'room_full' });

        // 加入相关逻辑
        const player = new Player(socket.id, `Player${socket.id.slice(-4)}`, seatIndex);
        room.players.push(player);
        socket.join(room.id); // 将客户端加入房间
        this.playerRoomMap.set(socket.id, room.id);

        // 更新房间状态
        this.updateRoomState(room);

        // 更新游戏状态中的玩家列表
        room.gameController.updatePlayers(room.players)

        callback({ 'status': 'success' })
    }

    private handleLeaveRoom(socket: Socket, callback: Function) {
        const roomId = this.playerRoomMap.get(socket.id);
        if (!roomId) return;

        const room = this.rooms.get(roomId);
        if (!room) return;

        const leavingSeatIndex = room.players[this.getPlayerIndexFromSocket(socket.id)].seat;

        // 离开相关逻辑
        room.players = room.players.filter(p => p.socketId !== socket.id);
        socket.leave(room.id);
        this.playerRoomMap.delete(socket.id);

        // 重新整理玩家索引
        room.players.forEach(p => {
            if (p.seat > leavingSeatIndex) p.seat--;
        });

        // 删除空房间
        if (room.players.length === 0) {
            this.rooms.delete(roomId);
        } else {
            // 更新游戏状态中的玩家列表
            room.gameController.updatePlayers(room.players)
        }

        // 更新房间状态
        this.updateRoomState(room);

        callback({ 'status': 'success' });
    }

    public updateRoomState(room: Room) {
        const playersInfo = room.players.map(p => ({
            id: p.id,
            name: p.name,
            seat: p.seat,
            ready: p.ready,
            cardCount: p.cardCount || 0
        }));

        const response = {
            id: room.id,
            roomStatus: room.roomStatus,
            players: playersInfo
        };

        this.io.to(room.id).emit('roomUpdate', response);
        this.sendRoomList();
    }

    private sendRoomList(socket?: Socket) {
        const rooms = Array.from(this.rooms.values());

        if (socket) {//socket为空时为全体消息
            socket.emit('roomListUpdate', rooms);
        } else {
            this.io.emit('roomListUpdate', rooms);
        }
    }

    public getRoom(roomId: string): Room | undefined {
        return roomId ? this.rooms.get(roomId) : undefined;
    }

    public getPlayerRoom(socketId: string): Room | undefined {
        const roomId = this.playerRoomMap.get(socketId);
        return roomId ? this.rooms.get(roomId) : undefined;
    }

    public getPlayerIndexFromSocket(socketId: string): number {
        const room = this.getPlayerRoom(socketId);
        if (!room) return -1;

        const player = room.players.find(p => p.socketId === socketId);
        if (!player) return -1;

        return room.players.indexOf(player);
    }
}