import 'package:landlords_3/core/network/game_service.dart';
import 'package:landlords_3/data/datasources/remote/dto/game_state_dto.dart';
import 'package:landlords_3/data/datasources/remote/dto/poker_dto.dart';
import 'package:landlords_3/domain/entities/poker_model.dart';
import 'package:landlords_3/domain/repositories/game_repo.dart';

class GameRepoImpl implements GameRepository {
  final GameService _gameService;

  GameRepoImpl({required GameService gameService}) : _gameService = gameService;

  @override
  Stream<GameStateDTO> watchGameState(String roomId) {
    return _gameService.gameUpdates.where((state) => state.roomId == roomId);
  }

  @override
  Future<void> startGame() async {
    _gameService.startGame();
  }

  @override
  Future<void> placeBid(int bidValue) async {
    _gameService.placeBid(bidValue);
  }

  @override
  Future<void> playCards(List<PokerModel> cards) async {
    final pokerDTOs =
        cards.map((poker) {
          final suitStr = poker.suit.toString().split('.').last.toLowerCase();
          final valueStr = poker.value.toString().split('.').last.toLowerCase();
          return PokerDTO(suit: suitStr, value: valueStr);
        }).toList();
    _gameService.playCards(pokerDTOs);
  }

  @override
  Future<void> passTurn() async {
    _gameService.passTurn();
  }
}
