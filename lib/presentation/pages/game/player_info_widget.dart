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
            border: Border.all(
              color: isCurrentTurn ? Colors.amber : Colors.grey,
              width: 2,
            ),
          ),
          child: Stack(
            children: [
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

  Color _getCountColor(int count) {
    if (count > 12) return Colors.green;
    if (count > 5) return Colors.orange;
    return Colors.red;
  }
}
