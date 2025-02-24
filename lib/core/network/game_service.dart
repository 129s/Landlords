import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/data/models/player.dart';
import 'package:landlords_3/data/models/poker.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';

class GameService {
  final SocketManager _socket = SocketManager();
  final _gameStateController = StreamController<GameState>.broadcast();

  GameService() {
    _socket.on<List<Map<String, dynamic>>>('game_state_updated', (data) {
      final state = GameState(
        players: _parsePlayers(data[0]['players']),
        lastPlayedCards: _parseCards(data[0]['lastPlayedCards']),
        phase: _parsePhase(data[0]['phase']),
        currentPlayerSeat: data[0]['currentPlayer'],
        isLandlord: data[0]['isLandlord'] ?? false,
      );
      _gameStateController.add(state);
    });
  }

  Stream<GameState> get gameStateUpdates => _gameStateController.stream;

  List<Poker> _parseCards(List<dynamic> data) =>
      data.map((e) => Poker.fromJson(e)).toList();

  List<Player> _parsePlayers(List<dynamic> data) =>
      data.map((e) => Player.fromJson(e)).toList();

  GamePhase _parsePhase(String phase) =>
      GamePhase.values.firstWhere((e) => e.name == phase.toLowerCase());

  Future<void> placeBid(int bidValue) async {
    try {
      _socket.emit('place_bid', {'bidValue': bidValue});
    } catch (e) {
      throw Exception('出价失败: ${e.toString()}');
    }
  }

  Future<void> playCards(List<Poker> cards) async {
    try {
      final cardData = cards.map((c) => c.toJson()).toList();
      _socket.emit('play_cards', {'cards': cardData});
    } catch (e) {
      throw Exception('出牌失败: ${e.toString()}');
    }
  }

  Future<void> passTurn() async {
    try {
      _socket.emit('pass_turn');
    } catch (e) {
      throw Exception('不出牌失败: ${e.toString()}');
    }
  }
}
