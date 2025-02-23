import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_manager.dart';
import 'package:landlords_3/presentation/pages/lobby/lobby_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final socketManager = SocketManager();
  socketManager.connect(); // 新增连接初始化
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
