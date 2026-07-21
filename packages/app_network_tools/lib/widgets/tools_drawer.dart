import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../repositories/network_tools_repository.dart';
import '../screens/dns_lookup_screen.dart';
import '../screens/history_screen.dart';
import '../screens/ping_screen.dart';
import '../screens/port_scanner_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/subnet_calculator_screen.dart';
import '../screens/traceroute_screen.dart';
import '../screens/whois_screen.dart';

enum NetworkTool {
  ping('Ping', Icons.network_ping_outlined),
  traceroute('Traceroute', Icons.route_outlined),
  portScanner('Port Scanner', Icons.settings_ethernet),
  dnsLookup('DNS Lookup', Icons.dns_outlined),
  subnetCalculator('Subnet Calculator', Icons.calculate_outlined),
  whois('Whois', Icons.badge_outlined),
  history('History', Icons.history);

  const NetworkTool(this.label, this.icon);
  final String label;
  final IconData icon;
}

/// Drawer shared by every tool screen so any tool can jump to any other
/// without stacking redundant routes — mirrors the calculator's ModeDrawer.
class ToolsDrawer extends StatelessWidget {
  const ToolsDrawer({super.key, required this.currentTool, required this.repository});

  final NetworkTool currentTool;
  final NetworkToolsRepository repository;

  WidgetBuilder _builderFor(NetworkTool tool) {
    switch (tool) {
      case NetworkTool.ping:
        return (_) => PingScreen(repository: repository);
      case NetworkTool.traceroute:
        return (_) => TracerouteScreen(repository: repository);
      case NetworkTool.portScanner:
        return (_) => PortScannerScreen(repository: repository);
      case NetworkTool.dnsLookup:
        return (_) => DnsLookupScreen(repository: repository);
      case NetworkTool.subnetCalculator:
        return (_) => SubnetCalculatorScreen(repository: repository);
      case NetworkTool.whois:
        return (_) => WhoisScreen(repository: repository);
      case NetworkTool.history:
        return (_) => HistoryScreen(repository: repository);
    }
  }

  void _navigate(BuildContext context, NetworkTool tool) {
    Navigator.of(context).pop();
    if (tool == currentTool) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: _builderFor(tool)));
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.mantle,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.lg,
                AppSpacing.md,
              ),
              child: Row(
                children: [
                  const Expanded(child: Text('Network Tools', style: AppTextStyles.headline)),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: 'Settings',
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => SettingsScreen(repository: repository),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            for (final tool in NetworkTool.values)
              ListTile(
                leading: Icon(
                  tool.icon,
                  color: tool == currentTool ? AppColors.primary : AppColors.subtext0,
                ),
                title: Text(
                  tool.label,
                  style: AppTextStyles.body.copyWith(
                    color: tool == currentTool ? AppColors.primary : AppColors.text,
                    fontWeight: tool == currentTool ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: tool == currentTool,
                selectedTileColor: AppColors.surface0,
                onTap: () => _navigate(context, tool),
              ),
          ],
        ),
      ),
    );
  }
}
