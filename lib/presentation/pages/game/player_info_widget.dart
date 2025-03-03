import 'package:flutter/material.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/data/models/player.dart';

class PlayerInfoWidget extends StatelessWidget {
  final Player player;
  final bool isLandlord;
  final bool isCurrentTurn;
  final Alignment alignment;
  final GamePhase gamePhase;

  const PlayerInfoWidget({
    super.key,
    required this.player,
    required this.isLandlord,
    required this.isCurrentTurn,
    required this.alignment,
    required this.gamePhase,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 头像区域
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _getAvatarColor(player.name), // 根据名称生成背景色
            border: Border.all(
              color: isCurrentTurn ? Colors.amber : Colors.white,
              width: 1,
            ),
          ),
          child: Stack(
            children: [
              // 显示名称首字符
              Center(
                child: Text(
                  _getAvatarText(player.name),
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (isLandlord)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Text(
                      '地主',
                      style: TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // 玩家名称和状态
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                player.name,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
              gamePhase == GamePhase.playing
                  ? Text(
                    '${player.cardCount}',
                    style: TextStyle(
                      color: _getCountColor(player.cardCount),
                      fontSize: 12,
                    ),
                  )
                  : Text(""),
            ],
          ),
        ),
      ],
    );
  }

  Color _getAvatarColor(String name) {
    // 通过名称哈希生成稳定颜色
    final hash = name.hashCode;
    return HSLColor.fromAHSL(1, (hash % 360).toDouble(), 0.2, 0.5).toColor();
  }

  String _getAvatarText(String name) {
    if (name.isEmpty) return "?";
    final trimmed = name.trim();

    // 获取有效字符（过滤表情符号等）
    final validChars = trimmed.characters
        .where((c) => c.codeUnitAt(0) > 127)
        .take(1);

    if (validChars.isEmpty) return trimmed.substring(0, 1).toUpperCase();

    // 取前两个有效字符
    return validChars.take(2).join().toUpperCase();
  }

  Color _getCountColor(int count) {
    if (count > 12) return Colors.green;
    if (count > 5) return Colors.orange;
    return Colors.red;
  }
}
