import 'package:flutter/material.dart';

class TableArea extends StatelessWidget {
  const TableArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/table_background.png'), // 替换为你的牌桌背景图片
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
