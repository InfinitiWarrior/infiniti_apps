import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/nfc_database.dart';
import '../repositories/scan_repository.dart';
import '../utils/hex_format.dart';
import '../widgets/hex_dump_view.dart';

class ScanDetailScreen extends StatelessWidget {
  const ScanDetailScreen({super.key, required this.record, required this.repository});

  final ScanRecord record;
  final ScanRepository repository;

  Future<void> _rename(BuildContext context) async {
    final controller = TextEditingController(text: record.label ?? '');
    final newLabel = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newLabel != null) {
      await repository.rename(record.id, newLabel);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(
        title: record.label?.isNotEmpty == true ? record.label! : record.idHex,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Rename',
            onPressed: () => _rename(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Delete',
            onPressed: () async {
              await repository.delete(record.id);
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_directionLabel(record.direction), style: AppTextStyles.title),
                const SizedBox(height: AppSpacing.sm),
                Text('UID  ${record.idHex}', style: AppTextStyles.mono),
                if (record.techList.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(record.techList, style: AppTextStyles.bodyMuted),
                ],
                const SizedBox(height: AppSpacing.xs),
                Text(record.createdAt.formattedDateTime, style: AppTextStyles.caption),
              ],
            ),
          ),
          if (record.ndefSummary != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('NDEF content', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.sm),
                  Text(record.ndefSummary!, style: AppTextStyles.body),
                ],
              ),
            ),
          ],
          if (record.rawDumpHex != null) ...[
            const SizedBox(height: AppSpacing.md),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Raw dump', style: AppTextStyles.title),
                  const SizedBox(height: AppSpacing.sm),
                  HexDumpView(bytes: hexToBytes(record.rawDumpHex!)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _directionLabel(ScanDirection direction) {
    return switch (direction) {
      ScanDirection.read => 'Read',
      ScanDirection.write => 'Write',
      ScanDirection.format => 'Format',
    };
  }
}
