import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:ndef_record/ndef_record.dart';

import '../services/ndef_codec.dart';
import '../services/nfc_service.dart';

class TagInfoCard extends StatelessWidget {
  const TagInfoCard({super.key, required this.info});

  final TagInfo info;

  @override
  Widget build(BuildContext context) {
    final records = info.ndefMessage?.records ?? const <NdefRecord>[];
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tag detected', style: AppTextStyles.title),
          const SizedBox(height: AppSpacing.sm),
          Text('UID  ${info.idHex}', style: AppTextStyles.mono),
          if (info.techList.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                for (final tech in info.techList)
                  Chip(
                    label: Text(tech.split('.').last),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.md),
          Text('NDEF records', style: AppTextStyles.caption),
          const SizedBox(height: AppSpacing.xs),
          if (records.isEmpty)
            const Text('No NDEF content.', style: AppTextStyles.bodyMuted)
          else
            for (final record in records) _RecordTile(record: record),
        ],
      ),
    );
  }
}

class _RecordTile extends StatelessWidget {
  const _RecordTile({required this.record});

  final NdefRecord record;

  @override
  Widget build(BuildContext context) {
    final display = describeRecord(record);
    final icon = switch (display.kind) {
      RecordKind.text => Icons.text_fields,
      RecordKind.uri => Icons.link,
      RecordKind.other => Icons.data_object,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(display.title, style: AppTextStyles.caption),
                Text(display.detail, style: AppTextStyles.body),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
