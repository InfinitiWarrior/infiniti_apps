import 'package:core/core.dart';
import 'package:flutter/material.dart';

Future<String?> showRenameDialog(BuildContext context, String initialValue) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.mantle,
        title: const Text('Rename recording', style: AppTextStyles.title),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: AppTextStyles.body,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final value = controller.text.trim();
              Navigator.of(context).pop(value.isEmpty ? null : value);
            },
            child: const Text('Save'),
          ),
        ],
      );
    },
  );
}
