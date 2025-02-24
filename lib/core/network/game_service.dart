import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/models/game_state.dart';
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
    try {
      _socket.emit('start_game', {'roomId': roomId});
    } catch (e) {
      throw Exception('游戏启动失败: ${e.toString()}');
    }
  }

  Future<void> placeBid(int bidValue) async {
    try {
      _socket.emit('place_bid', {
        'bidValue': bidValue,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('出价失败: ${e.toString()}');
    }
  }

  Future<void> playCards(List<Poker> cards) async {
    try {
      final cardData = cards.map((c) => c.toJson()).toList();
      _socket.emit('play_cards', {
        'cards': cardData,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      throw Exception('出牌失败: ${e.toString()}');
    }
  }
}
