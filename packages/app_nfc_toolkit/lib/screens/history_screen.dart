import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/nfc_database.dart';
import '../repositories/scan_repository.dart';
import 'scan_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.repository});

  final ScanRepository repository;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<ScanRecord>>(
      stream: repository.watchHistory(),
      builder: (context, snapshot) {
        final records = snapshot.data ?? const <ScanRecord>[];
        if (records.isEmpty) {
          return const EmptyState(
            icon: Icons.history,
            message: 'No saved scans yet. Read or write a tag, then save it here.',
          );
        }
        return ListView.separated(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: records.length,
          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, index) {
            final record = records[index];
            return AppCard(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScanDetailScreen(record: record, repository: repository),
                ),
              ),
              child: Row(
                children: [
                  Icon(_directionIcon(record.direction), color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.label?.isNotEmpty == true ? record.label! : record.idHex,
                          style: AppTextStyles.body,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (record.ndefSummary != null)
                          Text(
                            record.ndefSummary!,
                            style: AppTextStyles.bodyMuted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  Text(record.createdAt.relative, style: AppTextStyles.caption),
                ],
              ),
            );
          },
        );
      },
    );
  }

  IconData _directionIcon(ScanDirection direction) {
    return switch (direction) {
      ScanDirection.read => Icons.nfc,
      ScanDirection.write => Icons.edit_note,
      ScanDirection.format => Icons.delete_forever_outlined,
    };
  }
}
