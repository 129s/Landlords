import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// presentation/widgets/player_name_dialog.dart
class PlayerNameDialog extends ConsumerWidget {
  final String title;
  final ValueChanged<String>? onConfirm;
  final VoidCallback? onCancel;

  const PlayerNameDialog({
    super.key,
    required this.title,
    this.onConfirm,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context, ref) {
    final controller = TextEditingController();
    return AlertDialog(
      title: Text(title),
      content: TextField(controller: controller),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onCancel?.call();
          },
          child: const Text('取消'),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.isNotEmpty) {
              Navigator.pop(context);
              onConfirm?.call(controller.text);
            }
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}
