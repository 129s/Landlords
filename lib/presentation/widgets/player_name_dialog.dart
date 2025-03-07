import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:landlords_3/core/name_generator/name_generator.dart';

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
      content: TextField(
        controller: controller,
        decoration: InputDecoration(
          suffixIcon: IconButton(
            icon: const Icon(Icons.casino),
            onPressed: () {
              controller.text = NameGenerator().generate();
            },
            tooltip: '随机生成',
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            if (controller.text.isEmpty) {
              // 自动生成默认名称
              controller.text = NameGenerator().generate();
            } else {
              onConfirm?.call(controller.text);
            }
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}
