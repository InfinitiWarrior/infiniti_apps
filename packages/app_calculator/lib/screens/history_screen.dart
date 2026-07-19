import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/calculator_database.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.database});

  final CalculatorDatabase database;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InfinitiAppBar(
        title: 'History',
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear history',
            onPressed: () => database.clearHistory(),
          ),
        ],
      ),
      body: StreamBuilder<List<HistoryEntry>>(
        stream: database.watchHistory(),
        builder: (context, snapshot) {
          final entries = snapshot.data ?? const [];
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icons.calculate_outlined,
              message: 'No calculations yet.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final entry = entries[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: () => Navigator.of(context).pop(entry.result),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(entry.expression, style: AppTextStyles.bodyMuted),
                      const SizedBox(height: AppSpacing.xs),
                      Text('= ${entry.result}', style: AppTextStyles.title),
                      const SizedBox(height: AppSpacing.xs),
                      Text(entry.createdAt.relative, style: AppTextStyles.caption),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
