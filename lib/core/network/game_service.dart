import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/models/game_state_model.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';

class GameService {
  final SocketManager _socket = SocketManager();
  final _gameStateStream = StreamController<GameState>.broadcast();
  final _bidStream = StreamController<int>.broadcast();
  final _playCardsStream = StreamController<List<Poker>>.broadcast();
  final _playerStateUpdateStream = StreamController<List<Player>>.broadcast();

  GameService() {
    _socket.on<Map<String, dynamic>>('game_started', (data) {
      _gameStateStream.add(_parseGameState(data));
    });

    _socket.on<Map<String, dynamic>>('bid_updated', (data) {
      _bidStream.add(data['currentBid'] as int);
    });

    _socket.on<Map<String, dynamic>>('game_state_updated', (data) {
      _gameStateStream.add(_parseGameState(data));
    });

    _socket.on<List<dynamic>>('cards_played', (data) {
      final cards = data.map((c) => _parsePoker(c)).toList();
      _playCardsStream.add(cards);
    });

    _socket.on<List<dynamic>>('player_state_update', (data) {
      _playerStateUpdateStream.add(data.map((p) => _parsePlayer(p)).toList());
    });
  }

  GameState _parseGameState(Map<String, dynamic> data) {
    return GameState(
      players:
          (data['players'] as List)
              .map(
                (p) => Player(
                  id: p['id'],
                  name: p['name'],
                  seat: p['seat'],
                  isLandlord: p['isLandlord'],
                ),
              )
              .toList(),
      phase: _mapPhase(data['phase']),
      lastPlayedCards:
          (data['lastPlayedCards'] as List)
              .map(
                (c) => Poker(
                  suit: Suit.values.firstWhere((s) => s.name == c['suit']),
                  value: CardValue.values.firstWhere(
                    (v) => v.name == c['value'],
                  ),
                ),
              )
              .toList(),
      currentPlayerSeat: data['currentPlayer'],
    );
  }

  GamePhase _mapPhase(String phase) {
    switch (phase) {
      case 'BIDDING':
        return GamePhase.bidding;
      case 'PLAYING':
        return GamePhase.playing;
      default:
        return GamePhase.connecting;
    }
  }

  Stream<GameState> get gameUpdates => _gameStateStream.stream;
  Stream<int> get bidUpdates => _bidStream.stream;
  // 新增方法
  Stream<List<Player>> get onPlayerStateUpdate =>
      _playerStateUpdateStream.stream;
  Stream<List<Poker>> get onPlayCards => _playCardsStream.stream;

  Future<Map<String, dynamic>> getRoomDetails(String roomId) async {
    final completer = Completer<Map<String, dynamic>>();

    _socket.emitWithAck('get_room_details', {'roomId': roomId}, (response) {
      if (response['success']) {
        completer.complete(response['room']);
      } else {
        completer.completeError(Exception(response['error']));
      }
    });

    return completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('获取房间详情超时'),
    );
  }

  Future<void> startGame(String roomId) async {
    _socket.emit('start_game', {'roomId': roomId});
  }

  Future<void> placeBid(int bidValue) async {
    _socket.emit('place_bid', {'bidValue': bidValue});
  }

  Future<void> playCards(List<Poker> cards) async {
    _socket.emit('play_cards', {
      'cards': cards.map((c) => _convertPokerToJson(c)).toList(),
    });
  }

  Map<String, dynamic> _convertPokerToJson(Poker poker) {
    return {'suit': poker.suit.name, 'value': poker.value.name};
  }
}
