import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/name_generator/name_generator.dart';
import 'package:landlords_3/core/network_services/socket_service.dart';
import 'package:landlords_3/presentation/pages/lobby/lobby_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  NameGenerator.initialize();
  final socketManager = SocketService();
  socketManager.connect();
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
