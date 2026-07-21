import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'database/nfc_database.dart';
import 'repositories/scan_repository.dart';
import 'screens/home_screen.dart';
import 'services/nfc_service.dart';
import 'services/platform_nfc_service.dart';

void main() {
  final database = NfcDatabase();
  runApp(
    NfcToolkitApp(
      nfcService: PlatformNfcService(),
      repository: ScanRepository(database),
    ),
  );
}

class NfcToolkitApp extends StatelessWidget {
  const NfcToolkitApp({super.key, required this.nfcService, required this.repository});

  final NfcService nfcService;
  final ScanRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Toolkit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeScreen(nfcService: nfcService, repository: repository),
    );
  }
}
