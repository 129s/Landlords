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
            console.log("RoomController");
            this.sendRoomList();
            // 监听房间相关事件
            socket.on('createRoom', (data, callback) => this.handleCreateRoom(socket, callback));
            socket.on('joinRoom', (roomId, callback) => this.handleJoinRoom(socket, roomId, callback));
            socket.on('leaveRoom', (data, callback) => this.handleLeaveRoom(socket, callback));
            socket.on('getRoomList', () => this.sendRoomList(socket));
            socket.on('toggleReady', (data, callback) => this.handleToggleReady(socket, callback));
            // 监听玩家操作事件
            socket.on('playerAction', (action, callback) => {
                const room = this.getPlayerRoom(socket.id);
                room?.gameController.handlePlayerAction(socket, action, callback);
            });
            socket.on("setPlayerName", (name, callback) => this.handleSetPlayerName(socket, name, callback))
            socket.on('disconnect', () => this.handleDisconnect(socket));
        });
    }

    private handleSetPlayerName(socket: Socket, name: string, callback: Function) {
        const room = this.getPlayerRoom(socket.id);
        if (!room) {
            callback({ 'status': 'fail' });
            return;
        }

        const player = room.players.find(p => p.id === socket.id);
        if (!player) {
            callback({ 'status': 'fail' });
            return;
        }
        player.name = name;

        this.updateRoomState(room);
        console.log(room.toJSON());

        room.gameController.updatePlayers(room.players);

        callback({ 'status': 'success' });
    }

    // 断开连接处理（TODO:重连机制）
    private handleDisconnect(socket: Socket) {
        const room = this.getPlayerRoom(socket.id);
        if (!room) return;

        // 执行离开房间逻辑
        this.handleLeaveRoom(socket, () => {
            console.log(`Player ${socket.id} disconnected`);
        });

        // 删除玩家关联（防止内存泄漏）
        this.playerRoomMap.delete(socket.id);
    }

    private handleToggleReady(socket: Socket, callback: Function) {
        const room = this.getPlayerRoom(socket.id);
        if (!room) {
            callback({ 'status': 'fail' });
            return;
        }

        const player = room.players.find(p => p.id === socket.id);
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

        room.gameController.updatePlayers(room.players);

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
            // console.log("handleJoinRoom fail")
            callback({ 'status': 'fail' })
            return;
        }

        const seatIndex = room.getAvailableSeat();
        if (seatIndex === -1) {
            callback({ 'status': 'room_full' });
            return;
        }

        // 加入相关逻辑
        const player = new Player(socket.id, `未命名`, seatIndex);
        room.players.push(player);
        socket.join(room.id); // 将客户端加入房间
        this.playerRoomMap.set(socket.id, room.id);

        // 更新房间状态
        this.updateRoomState(room);

        // 增加延迟确保socket已加入房间
        setTimeout(() => {
            // 更新游戏状态中的玩家列表
            room.gameController.updatePlayers(room.players);
        }, 200); // 等待WebSocket连接完全建立

        callback({ 'status': 'success' })
    }

    private handleLeaveRoom(socket: Socket, callback: Function) {
        const roomId = this.playerRoomMap.get(socket.id);
        if (!roomId) return;

        const room = this.rooms.get(roomId);
        if (!room) return;

        const leavingSeatIndex = room.players[this.getPlayerIndexFromSocket(socket.id)].seat;

        // 离开相关逻辑
        room.players = room.players.filter(p => p.id !== socket.id);
        socket.leave(room.id);
        this.playerRoomMap.delete(socket.id);

        // 重新整理玩家索引
        room.players.forEach(p => {
            if (p.seat > leavingSeatIndex) p.seat--;
        });

        // TODO:停止游戏

        // 删除空房间
        if (room.players.length === 0) {
            this.rooms.delete(roomId);
        } else {
            // 更新游戏状态中的玩家列表
            room.gameController.updatePlayers(room.players)
            // 停止游戏
            if (room.roomStatus === RoomStatus.PLAYING) {
                room.gameController.stopGame(`玩家${socket.id.slice(-4)}离开房间`);
                room.roomStatus = RoomStatus.WAITING;
            }
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

        const player = room.players.find(p => p.id === socketId);
        if (!player) return -1;

        return room.players.indexOf(player);
    }
}