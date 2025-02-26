import 'dart:async';

import 'package:landlords_3/data/models/game_state.dart';
import 'package:landlords_3/core/services/socket_service.dart';
import 'package:landlords_3/data/models/poker.dart';

class GameService {
  final _socket = SocketService().socket;

  /// 游戏状态流
  Stream<GameState> gameStateStream() {
    final controller = StreamController<GameState>();

    _socket.on('game_state_updated', (data) {
      final state = GameState.fromJson(data);
      controller.add(state);
    });

    return controller.stream;
  }

  /// 出牌操作
  void playCards(List<Poker> cards) {
    _socket.emit('play_cards', {
      'cards': cards.map((card) => card.toJson()).toList(),
    });
  }

  /// 叫地主操作
  void placeBid(int bidValue) {
    _socket.emit('place_bid', {'bidValue': bidValue});
  }

  /// 跳过回合
  void passTurn() {
    _socket.emit('pass_turn');
  }
}
