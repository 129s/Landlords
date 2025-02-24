import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/models/game_state_model.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/models/poker.dart';

class GameService {
  final SocketManager _socket = SocketManager();
  final _gameStateStream = StreamController<GameState>.broadcast();
  final _bidStream = StreamController<int>.broadcast();
  final _playCardsStream = StreamController<List<Poker>>.broadcast();
  final _playerStateUpdateStream = StreamController<List<Player>>.broadcast();

  Stream<GameState> get gameUpdates => _gameStateStream.stream;
  Stream<int> get bidUpdates => _bidStream.stream;
  Stream<List<Player>> get onPlayerStateUpdate =>
      _playerStateUpdateStream.stream;
  Stream<List<Poker>> get onPlayCards => _playCardsStream.stream;

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
