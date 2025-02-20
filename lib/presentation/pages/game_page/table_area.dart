import 'package:flutter/material.dart';

class TableArea extends StatelessWidget {
  const TableArea({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/table_background.png'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
