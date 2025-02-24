import 'dart:async';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/data/datasources/remote/dto/bid_update_dto.dart';
import 'package:landlords_3/data/datasources/remote/dto/game_state_dto.dart';
import 'package:landlords_3/data/datasources/remote/dto/poker_dto.dart';

class GameService {
  final SocketManager _socket = SocketManager();
  final _gameStateStream = StreamController<GameStateDTO>.broadcast();
  final _bidStream = StreamController<BidUpdateDTO>.broadcast();

  GameService() {
    _socket.on<Map<String, dynamic>>('game_started', (data) {
      _gameStateStream.add(GameStateDTO.fromJson(data));
    });

    _socket.on<Map<String, dynamic>>('bid_updated', (data) {
      _bidStream.add(BidUpdateDTO.fromJson(data));
    });

    _socket.on<Map<String, dynamic>>('game_state_updated', (data) {
      _gameStateStream.add(GameStateDTO.fromJson(data));
    });
  }

  Stream<GameStateDTO> get gameUpdates => _gameStateStream.stream;
  Stream<BidUpdateDTO> get bidUpdates => _bidStream.stream;

  void startGame() {
    _socket.emit('start_game');
  }

  void placeBid(int bidValue) {
    _socket.emit('place_bid', {'bidValue': bidValue});
  }

  void playCards(List<PokerDTO> cards) {
    _socket.emit('play_cards', {
      'cards': cards.map((c) => c.toJson()).toList(),
    });
  }

  void passTurn() {
    _socket.emit('pass_turn');
  }
}
