import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../database/network_tools_database.dart';
import '../repositories/network_tools_repository.dart';
import '../widgets/tools_drawer.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.repository});

  final NetworkToolsRepository repository;

  IconData _iconFor(NetworkToolType type) {
    return switch (type) {
      NetworkToolType.ping => Icons.network_ping_outlined,
      NetworkToolType.traceroute => Icons.route_outlined,
      NetworkToolType.portScan => Icons.settings_ethernet,
      NetworkToolType.dnsLookup => Icons.dns_outlined,
      NetworkToolType.subnetCalc => Icons.calculate_outlined,
      NetworkToolType.whois => Icons.badge_outlined,
    };
  }

  String _labelFor(NetworkToolType type) {
    return switch (type) {
      NetworkToolType.ping => 'Ping',
      NetworkToolType.traceroute => 'Traceroute',
      NetworkToolType.portScan => 'Port Scan',
      NetworkToolType.dnsLookup => 'DNS Lookup',
      NetworkToolType.subnetCalc => 'Subnet Calc',
      NetworkToolType.whois => 'Whois',
    };
  }

  void _showDetail(BuildContext context, NetworkResult result) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${_labelFor(result.toolType)} · ${result.target}'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: SelectableText(
              result.details ?? result.summary,
              style: AppTextStyles.mono.copyWith(fontSize: 13),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await repository.delete(result.id);
              if (context.mounted) Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const InfinitiAppBar(title: 'History'),
      drawer: ToolsDrawer(
        currentTool: NetworkTool.history,
        repository: repository,
      ),
      body: StreamBuilder<List<NetworkResult>>(
        stream: repository.watchHistory(),
        builder: (context, snapshot) {
          final results = snapshot.data ?? const <NetworkResult>[];
          if (results.isEmpty) {
            return const EmptyState(
              icon: Icons.history,
              message: 'No saved results yet. Run a tool, then save it here.',
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final result = results[index];
              return AppCard(
                onTap: () => _showDetail(context, result),
                child: Row(
                  children: [
                    Icon(_iconFor(result.toolType), color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            result.target,
                            style: AppTextStyles.body,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            result.summary,
                            style: AppTextStyles.bodyMuted,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(result.createdAt.relative, style: AppTextStyles.caption),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
