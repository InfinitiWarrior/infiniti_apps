import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'database/network_tools_database.dart';
import 'repositories/network_tools_repository.dart';
import 'screens/ping_screen.dart';

void main() {
  final database = NetworkToolsDatabase();
  runApp(NetworkToolsApp(repository: NetworkToolsRepository(database)));
}

class NetworkToolsApp extends StatelessWidget {
  const NetworkToolsApp({super.key, required this.repository});

  final NetworkToolsRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Network Tools',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: PingScreen(repository: repository),
    );
  }
}
