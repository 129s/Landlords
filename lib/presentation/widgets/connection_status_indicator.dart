import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network/socket_service.dart';
import 'package:landlords_3/data/providers/socket_provider.dart';

class ConnectionStatusIndicator extends ConsumerWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(socketConnectionProvider);

    return connectionState.when(
      data: (state) {
        switch (state) {
          case GameConnectionState.connected:
            return const SizedBox.shrink(); // 连接成功，不显示任何内容
          case GameConnectionState.connecting:
            return _buildConnectingIndicator();
          case GameConnectionState.disconnected:
          case GameConnectionState.error:
            return _buildErrorIndicator(ref);
        }
      },
      loading: () => _buildConnectingIndicator(),
      error: (error, stackTrace) => _buildErrorIndicator(ref),
    );
  }

  Widget _buildConnectingIndicator() {
    return Container(
      color: Colors.black.withOpacity(0.5), // 半透明背景
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('正在连接到服务器...', style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorIndicator(WidgetRef ref) {
    return Container(
      color: Colors.black.withOpacity(0.5), // 半透明背景
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '无法连接到服务器，请检查网络连接',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // 重新连接
                SocketService().reconnect();
              },
              child: const Text('重试'),
            ),
          ],
        ),
      ),
    );
  }
}
