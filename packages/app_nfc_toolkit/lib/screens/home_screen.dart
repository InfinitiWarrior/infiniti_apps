import 'package:core/core.dart';
import 'package:flutter/material.dart';

import '../repositories/scan_repository.dart';
import '../services/nfc_service.dart';
import 'history_screen.dart';
import 'scan_screen.dart';
import 'settings_screen.dart';
import 'write_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.nfcService, required this.repository});

  final NfcService nfcService;
  final ScanRepository repository;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  static const _titles = ['Scan', 'Write', 'History'];

  @override
  Widget build(BuildContext context) {
    final screens = [
      ScanScreen(nfcService: widget.nfcService, repository: widget.repository),
      WriteScreen(nfcService: widget.nfcService, repository: widget.repository),
      HistoryScreen(repository: widget.repository),
    ];

    return Scaffold(
      appBar: InfinitiAppBar(
        title: _titles[_index],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Settings',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => SettingsScreen(repository: widget.repository),
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (index) => setState(() => _index = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.nfc), label: 'Scan'),
          NavigationDestination(icon: Icon(Icons.edit_note), label: 'Write'),
          NavigationDestination(icon: Icon(Icons.history), label: 'History'),
        ],
      ),
    );
  }
}
