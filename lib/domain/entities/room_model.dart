import 'package:landlords_3/domain/entities/player_model.dart';

class RoomModel {
  final String id;
  final List<PlayerModel> players;
  final DateTime createdAt;
  final bool hasPassword;

  const RoomModel({
    required this.id,
    required this.players,
    required this.createdAt,
    this.hasPassword = false,
  });

  // 简化版房间信息用于列表展示
  String get displayStatus {
    if (players.length == 3) return '游戏中';
    return '等待中 (${players.length}/3)';
  }

  RoomModel copyWith({
    String? id,
    List<PlayerModel>? players,
    DateTime? createdAt,
    bool? hasPassword,
  }) {
    return RoomModel(
      id: id ?? this.id,
      players: players ?? this.players,
      createdAt: createdAt ?? this.createdAt,
      hasPassword: hasPassword ?? this.hasPassword,
    );
  }
}
