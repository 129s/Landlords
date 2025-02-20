class PlayerData {
  final String id;
  final String name;
  final String avatar;
  final int score;
  final int handCount; // 剩余手牌数

  const PlayerData({
    required this.id,
    required this.name,
    this.avatar = '',
    this.score = 0,
    this.handCount = 0,
  });
}
