import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/presentation/pages/lobby_page/lobby_page.dart';

void main() {
  SocketService();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '斗地主',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LobbyPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
