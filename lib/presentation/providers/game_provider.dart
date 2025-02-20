import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/socket/socket_client.dart';
import 'package:landlords_3/data/datasources/game_remote_data_source.dart';
import 'package:landlords_3/data/datasources/game_remote_data_source_impl.dart';
import 'package:landlords_3/data/models/poker_model.dart';
import 'package:landlords_3/data/repositories/game_repository.dart';
import 'package:landlords_3/data/repositories/game_repository_impl.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:landlords_3/domain/usecases/create_room.dart';
import 'package:landlords_3/domain/usecases/get_game_state.dart';
import 'package:landlords_3/domain/usecases/get_player_order.dart';
import 'package:landlords_3/domain/usecases/join_room.dart';
import 'package:landlords_3/domain/usecases/play_cards.dart';

import '../../core/utils/card_utils.dart';
import '../../domain/entities/poker_data.dart';
import '../../domain/entities/poker_data.dart';

// 定义 Socket 连接状态
enum SocketStatus { connecting, connected, disconnected, error }

// 增强GameState定义
@immutable
class GameState {
  const GameState({
    this.roomId,
    this.playerOrder,
    this.isMyTurn = false,
    this.playerCards = const [],
    this.displayedCardsOther1 = const [],
    this.displayedCardsOther2 = const [],
    this.lastPlayedCards = const [],
    this.selectedIndices = const [],
    this.phase = GamePhase.idle,
    this.version = 0,
    this.socketStatus = SocketStatus.disconnected, // 添加 Socket 连接状态
    this.displayedCards = const {0: [], 1: [], 2: []}, // 使用Map存储各玩家出牌
  });

  final String? roomId;
  final int? playerOrder;
  final bool isMyTurn;
  final List<PokerData> playerCards;
  final List<PokerData> displayedCardsOther1;
  final List<PokerData> displayedCardsOther2;
  final List<PokerData> lastPlayedCards;
  final List<int> selectedIndices;
  final GamePhase phase;
  final int version;
  final SocketStatus socketStatus; // Socket 连接状态
  final Map<int, List<PokerData>> displayedCards; // 各玩家的出牌

  GameState copyWith({
    String? roomId,
    int? playerOrder,
    bool? isMyTurn,
    List<PokerData>? playerCards,
    List<PokerData>? displayedCardsOther1,
    List<PokerData>? displayedCardsOther2,
    List<PokerData>? lastPlayedCards,
    List<int>? selectedIndices,
    GamePhase? phase,
    int? version,
    SocketStatus? socketStatus,
    Map<int, List<PokerData>>? displayedCards,
  }) {
    return GameState(
      roomId: roomId ?? this.roomId,
      playerOrder: playerOrder ?? this.playerOrder,
      isMyTurn: isMyTurn ?? this.isMyTurn,
      playerCards: playerCards ?? this.playerCards,
      displayedCardsOther1: displayedCardsOther1 ?? this.displayedCardsOther1,
      displayedCardsOther2: displayedCardsOther2 ?? this.displayedCardsOther2,
      lastPlayedCards: lastPlayedCards ?? this.lastPlayedCards,
      selectedIndices: selectedIndices ?? this.selectedIndices,
      phase: phase ?? this.phase,
      version: version ?? this.version,
      socketStatus: socketStatus ?? this.socketStatus,
      displayedCards: displayedCards ?? this.displayedCards,
    );
  }

  @override
  String toString() {
    return 'GameState{roomId: $roomId, playerOrder: $playerOrder, isMyTurn: $isMyTurn, playerCards: $playerCards, displayedCardsOther1: $displayedCardsOther1, displayedCardsOther2: $displayedCardsOther2, lastPlayedCards: $lastPlayedCards, selectedIndices: $selectedIndices, phase: $phase, version: $version, socketStatus: $socketStatus, displayedCards: $displayedCards}';
  }
}

enum GamePhase { idle, bidding, playing, end }

// Providers
final remoteDataSourceProvider = Provider<GameRemoteDataSource>((ref) {
  final playerName = const String.fromEnvironment('PLAYER_NAME');
  return GameRemoteDataSourceImpl(playerName: playerName);
});

final repositoryProvider = Provider<GameRepository>((ref) {
  return GameRepositoryImpl(
    remoteDataSource: ref.read(remoteDataSourceProvider),
  );
});

final createRoomProvider = Provider<CreateRoom>((ref) {
  return CreateRoom(repository: ref.read(repositoryProvider));
});

final joinRoomProvider = Provider<JoinRoom>((ref) {
  return JoinRoom(repository: ref.read(repositoryProvider));
});

final getPlayerOrderProvider = Provider<GetPlayerOrder>((ref) {
  return GetPlayerOrder(repository: ref.read(repositoryProvider));
});

final playCardsProvider = Provider<PlayCards>((ref) {
  return PlayCards(repository: ref.read(repositoryProvider));
});

final getGameStateProvider = Provider<GetGameState>((ref) {
  return GetGameState(repository: ref.read(repositoryProvider));
});

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(this.ref) : super(const GameState());

  final Ref ref;

  // Use Cases (通过 Provider 获取)
  late final CreateRoom _createRoom = ref.read(createRoomProvider);
  late final JoinRoom _joinRoom = ref.read(joinRoomProvider);
  late final GetPlayerOrder _getPlayerOrder = ref.read(getPlayerOrderProvider);
  late final PlayCards _playCards = ref.read(playCardsProvider);
  late final GetGameState _getGameState = ref.read(getGameStateProvider);

  @override
  set state(GameState value) {
    if (kDebugMode) {
      print('GameState changed: $value');
    }
    super.state = value;
  }

  // 初始化游戏
  Future<void> initializeGame() async {
    final playerName = const String.fromEnvironment('PLAYER_NAME');

    // 1. 连接 Socket
    await _connectSocket(playerName);

    // 2. 创建或加入房间
    await _createOrJoinRoom(playerName);

    // 3. 监听游戏事件
    _listenToGameActions();
    _listenToGameUpdates();
  }

  // 连接 Socket
  Future<void> _connectSocket(String playerName) async {
    state = state.copyWith(socketStatus: SocketStatus.connecting);
    try {
      SocketClient.connect(playerName);

      // 监听连接状态
      SocketClient.addConnectionListener(playerName, (isConnected) {
        if (isConnected) {
          state = state.copyWith(socketStatus: SocketStatus.connected);
        } else {
          state = state.copyWith(socketStatus: SocketStatus.disconnected);
        }
      });

      // 监听连接错误
      SocketClient.addErrorListener(playerName, (error) {
        print('Socket connection error: $error');
        state = state.copyWith(socketStatus: SocketStatus.error);
      });
    } catch (e) {
      print('Failed to connect socket: $e');
      state = state.copyWith(socketStatus: SocketStatus.error);
    }
  }

  // 创建或加入房间
  Future<void> _createOrJoinRoom(String playerName) async {
    try {
      if (state.roomId == null) {
        // 创建房间
        final roomId = await _createRoom.execute(playerName);
        print('Room created: $roomId');
        state = state.copyWith(roomId: roomId);
        await _joinRoom.execute(roomId, playerName); // 加入房间
      } else {
        // 加入房间
        await _joinRoom.execute(state.roomId!, playerName); // 直接加入房间
      }
    } catch (e) {
      print('Failed to create or join room: $e');
      // TODO: 处理创建/加入房间失败的情况，例如显示错误信息
    }
  }

  void _listenToGameActions() {
    final playerName = const String.fromEnvironment('PLAYER_NAME');
    final socket = SocketClient.getSocket(playerName);

    socket.on('dealCards', (data) {
      if (data is List) {
        _handleDealCards(data);
      } else {
        print('Unexpected data type for dealCards: ${data.runtimeType}');
      }
    });
  }

  void _listenToGameUpdates() {
    final playerName = const String.fromEnvironment('PLAYER_NAME');
    final socket = SocketClient.getSocket(playerName);

    socket.on('gameUpdate', (data) {
      if (data is Map<String, dynamic>) {
        _handleOpponentPlay(data);
      } else {
        print('Unexpected data type for gameUpdate: ${data.runtimeType}');
      }
    });
  }

  void _handleDealCards(List<dynamic> serverCards) async {
    final playerOrder = await _getPlayerOrder.execute();
    state = state.copyWith(playerOrder: playerOrder);

    final myCards =
        serverCards
            .where((c) => c['owner'] == state.playerOrder)
            .map((c) => _convertToPoker(c as Map<String, dynamic>))
            .toList();

    state = state.copyWith(
      playerCards: CardUtils.sortCards(myCards),
      phase: GamePhase.bidding,
    );
  }

  void _handleOpponentPlay(Map<String, dynamic> action) {
    final cards =
        (action['cards'] as List)
            .map((c) => _convertToPoker(c as Map<String, dynamic>))
            .toList();
    final playerOrder = action['playerOrder'] as int;

    if (playerOrder == 1) {
      state = state.copyWith(displayedCardsOther1: cards);
    } else if (playerOrder == 2) {
      state = state.copyWith(displayedCardsOther2: cards);
    }

    state = state.copyWith(lastPlayedCards: cards);
    _handleTurnUpdate(action['nextPlayer']);
  }

  void _handleTurnUpdate(dynamic nextPlayer) async {
    final playerOrder = await _getPlayerOrder.execute();
    state = state.copyWith(isMyTurn: nextPlayer == playerOrder);
  }

  void playSelectedCards() async {
    final cards =
        state.selectedIndices.map((i) => state.playerCards[i]).toList();
    await _playCards.execute(cards, state.roomId!, state.playerOrder!);
  }

  PokerData _convertToPoker(Map<String, dynamic> data) {
    return PokerModel(
      suit: Suit.values[data['suit']],
      value: CardValue.values[data['value']],
    );
  }

  Map<String, dynamic> _pokerToMap(PokerData card) {
    return {'suit': card.suit.index, 'value': card.value.index};
  }

  void selectCard(int index) {
    List<int> newSelection = List.from(state.selectedIndices);
    if (newSelection.contains(index)) {
      newSelection.remove(index);
    } else {
      newSelection.add(index);
    }
    state = state.copyWith(selectedIndices: newSelection);
  }

  // 添加重连方法
  void reconnect() {
    final playerName = const String.fromEnvironment('PLAYER_NAME');
    SocketClient.disconnect(playerName);
    initializeGame();
  }
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier(ref);
});
