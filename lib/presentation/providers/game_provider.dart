import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/socket/socket_client.dart';
import 'package:landlords_3/core/utils/card_utils.dart';
import 'package:landlords_3/domain/entities/poker_data.dart';
import 'package:flutter/foundation.dart';
import 'package:landlords_3/data/datasources/game_remote_data_source_impl.dart';
import 'package:landlords_3/data/repositories/game_repository_impl.dart';
import 'package:landlords_3/domain/usecases/create_room.dart';
import 'package:landlords_3/domain/usecases/join_room.dart';
import 'package:landlords_3/domain/usecases/get_player_order.dart';
import 'package:landlords_3/domain/usecases/play_cards.dart';
import 'package:landlords_3/domain/usecases/get_game_state.dart';
import 'package:landlords_3/data/models/poker_model.dart';

enum GamePhase { waiting, dealing, bidding, playing, end }

@immutable
class GameState {
  const GameState({
    this.roomId,
    this.playerOrder = 0, // 默认玩家顺序为0
    this.isMyTurn = false,
    this.playerCards = const [],
    this.displayedCardsOther1 = const [],
    this.displayedCardsOther2 = const [],
    this.lastPlayedCards = const [],
    this.selectedIndices = const [],
    this.phase = GamePhase.waiting,
    this.version = 0,
  });

  final String? roomId;
  final int playerOrder; // 玩家座位顺序 0-地主 1/2-农民
  final bool isMyTurn;
  final List<PokerData> playerCards;
  final List<PokerData> displayedCardsOther1;
  final List<PokerData> displayedCardsOther2;
  final List<PokerData> lastPlayedCards;
  final List<int> selectedIndices;
  final GamePhase phase;
  final int version;

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
    );
  }
}

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(const GameState());

  // Use Cases
  late final CreateRoom _createRoom;
  late final JoinRoom _joinRoom;
  late final GetPlayerOrder _getPlayerOrder;
  late final PlayCards _playCards;
  late final GetGameState _getGameState;

  @override
  set state(GameState value) {
    print('GameState changed: $value');
    super.state = value;
  }

  void initializeGame() async {
    final playerName = const String.fromEnvironment('PLAYER_NAME');
    final socket = SocketClient.getSocket(playerName);
    final remoteDataSource = GameRemoteDataSourceImpl(playerName: playerName);
    final gameRepository = GameRepositoryImpl(
      remoteDataSource: remoteDataSource,
    );

    _createRoom = CreateRoom(repository: gameRepository);
    _joinRoom = JoinRoom(repository: gameRepository);
    _getPlayerOrder = GetPlayerOrder(repository: gameRepository);
    _playCards = PlayCards(repository: gameRepository);
    _getGameState = GetGameState(repository: gameRepository);

    // 连接Socket
    SocketClient.connect(playerName);

    // 加入/创建房间
    if (state.roomId == null) {
      final roomId = await _createRoom.execute(playerName);
      print('Room created: $roomId');
      state = state.copyWith(roomId: roomId);
      _joinRoom.execute(roomId, playerName); // 加入房间
    } else {
      _joinRoom.execute(state.roomId!, playerName); // 直接加入房间
    }

    _listenToGameActions();
    _listenToGameUpdates();
  }

  void _listenToGameActions() {
    final playerName = const String.fromEnvironment('PLAYER_NAME');
    final remoteDataSource = GameRemoteDataSourceImpl(playerName: playerName);
    remoteDataSource.getGameActions().listen((action) {
      print('Received gameAction: ${action['type']}');
      switch (action['type']) {
        case 'DEAL_CARDS':
          _handleDealCards(action['cards']);
          break;
        case 'PLAY_CARDS':
          _handleOpponentPlay(action);
          break;
        case 'TURN_UPDATE':
          _handleTurnUpdate(action['nextPlayer']);
          break;
      }
    });
  }

  void _listenToGameUpdates() {
    final playerName = const String.fromEnvironment('PLAYER_NAME');
    final remoteDataSource = GameRemoteDataSourceImpl(playerName: playerName);
    remoteDataSource.getGameUpdates().listen((data) {
      applyServerUpdate(data);
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
    await _playCards.execute(cards, state.roomId!, state.playerOrder);
  }

  void applyServerUpdate(dynamic data) {
    // 根据服务器数据更新本地状态
    print('Applying server update: $data');
    // TODO: 实现根据服务器数据更新本地状态的逻辑
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
}

final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});
