import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/network_services/constants/constants.dart';
import 'package:landlords_3/core/network_services/socket_service.dart';
import 'package:landlords_3/data/providers/socket_provider.dart';

class ConnectionStatusIndicator extends ConsumerWidget {
  const ConnectionStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionState = ref.watch(connectionStateProvider).value;

    return Tooltip(
      message: _getStatusMessage(connectionState),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: _getStatusColor(connectionState),
          borderRadius: BorderRadius.circular(16),
        ),
        child: _getStatusIcon(connectionState),
      ),
    );
  }

  Color _getStatusColor(GameConnectionState? state) {
    switch (state) {
      case GameConnectionState.connected:
        return Colors.green.shade600;
      case GameConnectionState.connecting:
        return Colors.orange.shade600;
      case GameConnectionState.error:
        return Colors.red.shade600;
      case GameConnectionState.disconnected:
      default:
        return Colors.grey.shade600;
    }
  }

  Widget _getStatusIcon(GameConnectionState? state) {
    const iconSize = 12.0;
    switch (state) {
      case GameConnectionState.connected:
        return const Icon(Icons.wifi, size: iconSize, color: Colors.white);
      case GameConnectionState.connecting:
        return SizedBox(
          width: iconSize,
          height: iconSize,
          child: const CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(Colors.white),
          ),
        );
      case GameConnectionState.error:
        return const Icon(
          Icons.error_outline,
          size: iconSize,
          color: Colors.white,
        );
      case GameConnectionState.disconnected:
      default:
        return const Icon(Icons.wifi_off, size: iconSize, color: Colors.white);
    }
  }

  String _getStatusText(GameConnectionState? state) {
    switch (state) {
      case GameConnectionState.connected:
        return '已连接';
      case GameConnectionState.connecting:
        return '连接中';
      case GameConnectionState.error:
        return '连接错误';
      case GameConnectionState.disconnected:
      default:
        return '未连接';
    }
  }

  String _getStatusMessage(GameConnectionState? state) {
    switch (state) {
      case GameConnectionState.error:
        return '无法连接到服务器，请检查网络设置';
      case GameConnectionState.disconnected:
        return '点击尝试重新连接';
      default:
        return _getStatusText(state);
    }
  }
}
