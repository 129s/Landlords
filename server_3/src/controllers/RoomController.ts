import { Socket, Server } from "socket.io";
import { Room } from "../models/Room";
import { Player } from "../models/Player";
import { GamePhase } from "../constants/constants";
import { GameController } from "./GameController";

export class RoomController {
    private rooms = new Map<string, Room>();
    private playerRoomMap = new Map<string, string>();
    private gameController: GameController;

    constructor(private io: Server) {
        this.gameController = new GameController(io, this);
        this.setupSocketHandlers();
    }

    private setupSocketHandlers() {
        this.io.on('connection', (socket: Socket) => {
            this.sendRoomList();
            socket.on('createRoom', (data, callback) => this.handleCreateRoom(socket, callback));
            socket.on('joinRoom', (roomId, callback) => this.handleJoinRoom(socket, roomId, callback));
            socket.on('leaveRoom', (data, callback) => this.handleLeaveRoom(socket, callback));
            socket.on('toggleReady', () => this.handleToggleReady(socket));
            socket.on('getRoomList', () => this.sendRoomList(socket));
        });
    }

    private handleCreateRoom(socket: Socket, callback: Function) {
        const room = new Room();
        this.rooms.set(room.id, room);
        this.updateRoomState(room);

        callback({ 'roomId': room.id, 'status': 'success' })
    }

    private handleJoinRoom(socket: Socket, roomId: string, callback: Function) {
        const room = this.rooms.get(roomId);
        if (!room) return socket.emit('error', 'Room not found');

        const player = new Player(socket.id, `Player${socket.id.slice(-4)}`, room.players.length);// 用房间人数分配座位号
        room.players.push(player);
        this.playerRoomMap.set(socket.id, room.id);

        this.updateRoomState(room);

        callback({ 'status': 'success' })
    }

    private handleLeaveRoom(socket: Socket, callback: Function) {
        const roomId = this.playerRoomMap.get(socket.id);
        if (!roomId) return;

        const room = this.rooms.get(roomId);
        if (!room) return;

        room.players = room.players.filter(p => p.socketId !== socket.id);

        if (room.players.length === 0) {
            this.rooms.delete(roomId);
        }
        this.updateRoomState(room);
        this.playerRoomMap.delete(socket.id);
        callback({ 'status': 'success' });
    }

    private handleToggleReady(socket: Socket) {
        const room = this.getPlayerRoom(socket.id);
        if (!room) return;

        const player = room.players.find(p => p.socketId === socket.id);
        if (player) {
            player.ready = !player.ready;
            this.updateRoomState(room);

            // 自动开始检测
            if (room.players.every(p => p.ready) &&
                room.players.length === 3 &&
                room.roomStatus === 'waiting') {
                this.gameController.initializeGame(room.id);
            }
        }
    }

    private updateRoomState(room: Room) {
        const response = {
            id: room.id,
            roomStatus: room.roomStatus,
            players: room.players.map(p => ({
                id: p.id,
                name: p.name,
                seat: p.seat,
                ready: p.ready,
                cardCount: p.cardCount || 0
            }))
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
}