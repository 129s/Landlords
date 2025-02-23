import 'package:flutter/material.dart';

class TopBar extends StatelessWidget {
  const TopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Colors.brown.withAlpha(225)),
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(color: Colors.amberAccent, Icons.exit_to_app),
            onPressed: () {
              // TODO: 实现退出功能
            },
          ),
          const Text(
            '记牌器 ',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.amberAccent),
          ),
          IconButton(
            icon: const Icon(color: Colors.amberAccent, Icons.settings),
            onPressed: () {
              // TODO: 实现设置功能
            },
          ),
        ],
      ),
    );
  }
}
