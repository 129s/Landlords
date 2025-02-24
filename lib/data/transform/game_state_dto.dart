import 'package:landlords_3/data/transform/player_dto.dart';
import 'package:landlords_3/data/transform/poker_dto.dart';
import 'package:landlords_3/data/transform/room_dto.dart';

class GameStateDTO {
  final String roomId;
  final String phase;
  final List<PlayerDTO> players;
  final int currentPlayer;
  final List<PokerDTO> lastPlayedCards;
  final int currentBid;
  final List<dynamic>
  history; // You might want to create a DTO for history items

  GameStateDTO({
    required this.roomId,
    required this.phase,
    required this.players,
    required this.currentPlayer,
    required this.lastPlayedCards,
    required this.currentBid,
    required this.history,
  });

  factory GameStateDTO.fromJson(Map<String, dynamic> json) {
    return GameStateDTO(
      roomId: json['roomId'],
      phase: json['phase'],
      players:
          (json['players'] as List)
              .map((playerJson) => PlayerDTO.fromJson(playerJson))
              .toList(),
      currentPlayer: json['currentPlayer'],
      lastPlayedCards:
          (json['lastPlayedCards'] as List)
              .map((cardJson) => PokerDTO.fromJson(cardJson))
              .toList(),
      currentBid: json['currentBid'],
      history:
          json['history']
              as List<dynamic>, // Adjust if you create a HistoryItemDTO
    );
  }
}
