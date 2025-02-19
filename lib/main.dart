import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/presentation/pages/game_page/game_page.dart';

void main() {
  runApp(
    const ProviderScope(
      // 使用 ProviderScope 包裹 MyApp
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '斗地主',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const GamePage(), // 设置 GamePage 为主页
      debugShowCheckedModeBanner: false,
    );
  }
}
