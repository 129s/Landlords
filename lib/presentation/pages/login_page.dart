import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/data/providers/auth_repo_provider.dart';
import 'package:landlords_3/presentation/providers/user_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController _controller = TextEditingController();

    void _handleLogin(WidgetRef ref, String username) async {
      try {
        final user = await ref.read(authRepoProvider).guestLogin(username);
        ref.read(userProvider.notifier).setUser(user);
        Navigator.pushReplacementNamed(context, '/lobby');
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('登录失败: ${e.toString()}')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('登录')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(
                labelText: '用户名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleLogin(ref, _controller.text),
              child: const Text('游客登录'),
            ),
          ],
        ),
      ),
    );
  }
}
