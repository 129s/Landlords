import 'package:flutter/material.dart';

class PlayerInfo extends StatelessWidget {
  final bool isLeft;

  const PlayerInfo({Key? key, required this.isLeft}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 假设从数据提供端获取玩家信息
    String? avatarUrl;

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
            backgroundImage:
                avatarUrl != null
                    ? AssetImage(avatarUrl) as ImageProvider
                    : null,
            child: avatarUrl == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(height: 4.0), // 修改原硬编码部分
          const Text("从api获取"),
          const Text('得分: 0'),
        ],
      ),
    );
  }
}
