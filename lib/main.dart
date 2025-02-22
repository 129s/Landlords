// main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/presentation/pages/lobby_page/lobby_page.dart';
import 'package:landlords_3/presentation/pages/login_page.dart'; // Import LoginPage
import 'package:landlords_3/presentation/providers/user_provider.dart'; // Import user provider

void main() {
  SocketService();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return MaterialApp(
      title: '斗地主',
      theme: ThemeData(primarySwatch: Colors.blue),
      home:
          user == null
              ? const LoginPage()
              : const LobbyPage(), // Show LoginPage if user is null
      debugShowCheckedModeBanner: false,
      routes: {'/lobby': (context) => const LobbyPage()},
    );
  }
}
