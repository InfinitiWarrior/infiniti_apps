import 'dart:io';

import 'package:workmanager/workmanager.dart';

import '../database/rss_database.dart';
import '../repositories/feed_repository.dart';

const _refreshTaskName = 'rss_reader.refresh_feeds';

/// Registers a periodic background feed refresh. `workmanager` only has
/// Android/iOS/macOS implementations (no Linux desktop support), so this is
/// a no-op everywhere else — guard against calling it on Linux, or it throws
/// a MissingPluginException the same way permission_handler does there.
Future<void> initializeBackgroundRefresh() async {
  if (!Platform.isAndroid && !Platform.isIOS) return;
  await Workmanager().initialize(_callbackDispatcher);
  await Workmanager().registerPeriodicTask(
    _refreshTaskName,
    _refreshTaskName,
    frequency: const Duration(hours: 1),
    constraints: Constraints(networkType: NetworkType.connected),
  );
}

@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final database = RssDatabase();
    final repository = FeedRepository(database);
    try {
      await repository.refreshAll();
      return true;
    } finally {
      repository.dispose();
      await database.close();
    }
  });
}
