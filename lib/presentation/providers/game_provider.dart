import 'dart:async';
import 'dart:io';
import 'package:landlords_3/data/datasources/game_remote_data_source_impl.dart';
import 'package:landlords_3/domain/repositories/game_repository.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/socket/socket_client.dart';
import 'package:landlords_3/domain/repositories/game_repository_impl.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/domain/usecases/create_room.dart';
import 'package:landlords_3/domain/usecases/get_game_state.dart';
import 'package:landlords_3/domain/usecases/join_room.dart';
import 'package:landlords_3/domain/usecases/play_cards.dart';

// 定义 Socket 连接状态
enum SocketStatus { connecting, connected, disconnected, error }

extension SocketStatusExtension on SocketStatus {
  Color get color {
    switch (this) {
      case SocketStatus.connected:
        return Colors.green.shade400;
      case SocketStatus.connecting:
        return Colors.blue.shade400;
      case SocketStatus.disconnected:
        return Colors.orange.shade400;
      case SocketStatus.error:
        return Colors.red.shade400;
      default:
        return Colors.grey.shade400;
    }
  }

  IconData get icon {
    switch (this) {
      case SocketStatus.connected:
        return Icons.check_circle;
      case SocketStatus.connecting:
        return Icons.sync;
      case SocketStatus.disconnected:
        return Icons.link_off;
      case SocketStatus.error:
        return Icons.error;
      default:
        return Icons.question_mark;
    }
  }

  String get displayText {
    switch (this) {
      case SocketStatus.connected:
        return '已连接';
      case SocketStatus.connecting:
        return '连接中...';
      case SocketStatus.disconnected:
        return '已断开连接';
      case SocketStatus.error:
        return '连接错误';
      default:
        return '未知状态';
    }
  }
}

// 定义 GameState
class GameState {
  final String? roomId;
  final String playerName;
  final SocketStatus socketStatus;
  final int playerOrder; // 当前玩家的顺序
  final Map<int, List<PokerData>> displayedCards; // 每个玩家展示的牌
  final bool isMyTurn; // 是否轮到我出牌
  final List<dynamic> players; // 玩家列表
  final dynamic biddingResult; // 叫地主结果
  final dynamic gameEnd; // 游戏结束信息

  GameState({
    this.roomId,
    required this.playerName,
    this.socketStatus = SocketStatus.disconnected,
    this.playerOrder = 0,
    this.displayedCards = const {},
    this.isMyTurn = false,
    this.players = const [],
    this.biddingResult,
    this.gameEnd,
  });

  GameState copyWith({
    String? roomId,
    String? playerName,
    SocketStatus? socketStatus,
    int? playerOrder,
    Map<int, List<PokerData>>? displayedCards,
    bool? isMyTurn,
    List<dynamic>? players,
    dynamic? biddingResult,
    dynamic? gameEnd,
  }) {
    return GameState(
      roomId: roomId ?? this.roomId,
      playerName: playerName ?? this.playerName,
      socketStatus: socketStatus ?? this.socketStatus,
      playerOrder: playerOrder ?? this.playerOrder,
      displayedCards: displayedCards ?? this.displayedCards,
      isMyTurn: isMyTurn ?? this.isMyTurn,
      players: players ?? this.players,
      biddingResult: biddingResult ?? this.biddingResult,
      gameEnd: gameEnd ?? this.gameEnd,
    );
  }
}

// 定义 GameNotifier
class GameNotifier extends StateNotifier<GameState> {
  final CreateRoom _createRoom;
  final JoinRoom _joinRoom;
  final GetGameState _getGameState;
  final PlayCards _playCards;
  final GameRepository _gameRepository;
  late final IO.Socket _socket;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;

  GameNotifier({
    required CreateRoom createRoom,
    required JoinRoom joinRoom,
    required GetGameState getGameState,
    required PlayCards playCards,
    required GameRepository gameRepository,
    required String playerName,
  }) : _createRoom = createRoom,
       _joinRoom = joinRoom,
       _getGameState = getGameState,
       _playCards = playCards,
       _gameRepository = gameRepository,
       super(GameState(playerName: playerName)) {
    _socket = SocketClient.getSocket(state.playerName);
    _setupSocketListeners();
  }

  @override
  void dispose() {
    _socket.disconnect();
    _reconnectTimer?.cancel();
    super.dispose();
  }

  // 初始化连接
  void initialize() {
    connectSocket();
  }

  // 连接 Socket
  void connectSocket() {
    state = state.copyWith(socketStatus: SocketStatus.connecting);
    SocketClient.connect(state.playerName);
  }

  // 设置 Socket 监听器
  void _setupSocketListeners() {
    _socket.onConnect((_) {
      print('Socket connected!');
      state = state.copyWith(socketStatus: SocketStatus.connected);
      _reconnectAttempts = 0; // 重置重连尝试次数
      _reconnectTimer?.cancel(); // 取消重连定时器
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected!');
      state = state.copyWith(socketStatus: SocketStatus.disconnected);
      _scheduleReconnect(); // 安排重连
    });

    _socket.onError((error) {
      print('Socket error: $error');
      state = state.copyWith(socketStatus: SocketStatus.error);
      _scheduleReconnect(); // 安排重连
    });

    _socket.on('roomCreated', (roomId) {
      state = state.copyWith(roomId: roomId as String);
    });

    _socket.on('playerJoined', (players) {
      state = state.copyWith(players: players as List<dynamic>);
    });

    // 增强事件监听
    _enhancedEventHandling();
  }

  // 增强事件处理
  void _enhancedEventHandling() {
    _socket.on('playerJoined', (players) => _updatePlayers(players));
    // _socket.on('biddingResult', (data) => _handleBidding(data)); // 示例
    // _socket.on('gameEnd', (data) => _handleGameEnd(data)); // 示例
  }

  // 更新玩家列表
  void _updatePlayers(dynamic players) {
    state = state.copyWith(players: players as List<dynamic>);
  }

  // 安排重连
  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive ?? false) return; // 如果已经在重连，则不重复安排

    _reconnectTimer = Timer(Duration(seconds: _calculateReconnectDelay()), () {
      if (_reconnectAttempts < 5) {
        print('Attempting to reconnect... (Attempt ${_reconnectAttempts + 1})');
        connectSocket();
        _reconnectAttempts++;
      } else {
        print('Max reconnect attempts reached. Please check your connection.');
        state = state.copyWith(socketStatus: SocketStatus.error);
        _reconnectTimer?.cancel();
      }
    });
  }

  // 计算重连延迟
  int _calculateReconnectDelay() {
    return _reconnectAttempts < 3 ? 3 : 10; // 初始快速重连，之后放缓
  }

  // 创建房间
  Future<void> createRoom() async {
    try {
      final roomId = await _createRoom.execute(state.playerName);
      state = state.copyWith(roomId: roomId);
    } catch (e) {
      print('Error creating room: $e');
      // TODO: 错误处理
    }
  }

  // 加入房间
  Future<void> joinRoom(String roomId) async {
    try {
      await _joinRoom.execute(
        JoinRoomParams(roomId: roomId, playerName: state.playerName),
      );
      state = state.copyWith(roomId: roomId);
    } catch (e) {
      print('Error joining room: $e');
    }
  }

  // 出牌
  void playCards(List<PokerData> cards) {
    _safeNetworkCall(() async {
      await _playCards.execute(
        PlayCardsParams(
          cards: cards,
          roomId: state.roomId!,
          playerOrder: state.playerOrder,
        ),
      );
    });
  }

  // 发送游戏操作
  void sendGameAction(dynamic action) {
    _socket.emit('gameAction', action);
  }

  // 安全网络调用
  void _safeNetworkCall(Future<void> Function() operation) async {
    try {
      await operation();
    } on SocketException catch (e) {
      print('SocketException: $e');
      state = state.copyWith(socketStatus: SocketStatus.error);
      _scheduleReconnect();
    } on TimeoutException {
      print('TimeoutException');
      // TODO: 显示超时警告
    } catch (e) {
      print('Unexpected error: $e');
      // TODO: 统一错误处理
    }
  }

  // 示例：处理叫地主结果
  void _handleBidding(dynamic data) {
    state = state.copyWith(biddingResult: data);
  }

  // 示例：处理游戏结束
  void _handleGameEnd(dynamic data) {
    state = state.copyWith(gameEnd: data);
  }

  // 重新连接
  void reconnect() {
    _reconnectAttempts = 0;
    connectSocket();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  final playerName = 'Player1';
  final repository = ref.read(gameRepositoryProvider);

  return GameNotifier(
    createRoom: CreateRoom(repository), // 直接传入repository实例
    joinRoom: JoinRoom(repository),
    getGameState: GetGameState(repository),
    playCards: PlayCards(repository),
    gameRepository: repository,
    playerName: playerName,
  );
});

final gameRepositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(
    remoteDataSource: GameRemoteDataSourceImpl(
      playerName: 'Player1', // 应与实际玩家名同步
    ),
  );
});

// 状态选择器
final displayedCardsProvider = Provider<List<PokerData>>((ref) {
  final state = ref.watch(gameProvider);
  return state.displayedCards[state.playerOrder] ?? [];
});

final opponentsCardsProvider = Provider.family<List<PokerData>, int>((
  ref,
  order,
) {
  return ref.watch(gameProvider).displayedCards[order] ?? [];
});

// 玩家信息Provider
final playerProvider = Provider.family<dynamic, int>((ref, playerOrder) {
  final gameState = ref.watch(gameProvider);
  if (gameState.players.isNotEmpty && playerOrder < gameState.players.length) {
    return gameState.players[playerOrder];
  }
  return null; // 或者返回一个默认的玩家信息
});
