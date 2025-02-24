import 'package:landlords_3/data/models/player.dart';

class Room {
  final String id;
  final List<Player> players;
  final DateTime createdAt;

  const Room({
    required this.id,
    required this.players,
    required this.createdAt,
  });

  // 简化版房间信息用于列表展示
  String get displayStatus {
    if (players.length == 3) return '游戏中';
    return '等待中 (${players.length}/3)';
  }

  Room copyWith({
    String? id,
    List<Player>? players,
    DateTime? createdAt,
    bool? hasPassword,
  }) {
    return Room(
      id: id ?? this.id,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
