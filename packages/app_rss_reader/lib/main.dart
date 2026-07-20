import 'package:core/core.dart';
import 'package:flutter/material.dart';

import 'database/rss_database.dart';
import 'repositories/feed_repository.dart';
import 'screens/home_screen.dart';
import 'services/background_refresh_service.dart';

void main() {
  final database = RssDatabase();
  final repository = FeedRepository(database);
  initializeBackgroundRefresh();
  runApp(RssReaderApp(repository: repository));
}

class RssReaderApp extends StatelessWidget {
  const RssReaderApp({super.key, required this.repository});

  final FeedRepository repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RSS Reader',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: HomeScreen(repository: repository),
    );
  }
}
