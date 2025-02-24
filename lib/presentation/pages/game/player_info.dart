import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/domain/entities/player_model.dart';
import 'package:landlords_3/presentation/providers/game_provider.dart';

class PlayerInfo extends ConsumerWidget {
  final int seatNumber;

  const PlayerInfo({Key? key, required this.seatNumber}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final player = _findPlayerBySeat(gameState.players, seatNumber);

    return Container(
      width: 96,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20.0,
            child:
                player != null
                    ? Text(player.name[0])
                    : const Icon(Icons.person),
          ),
          const SizedBox(height: 4.0),
          Text(player?.name ?? '等待加入'),
          Text('剩余: ${player?.cards.length ?? 0}'),
          if (player?.isLandlord ?? false)
            const Icon(Icons.star, color: Colors.yellow, size: 16),
        ],
      ),
    );
  }

  PlayerModel? _findPlayerBySeat(List<PlayerModel> players, int seat) {
    try {
      return players.firstWhere((p) => p.seat == seat);
    } catch (_) {
      return null;
    }
  }
}
