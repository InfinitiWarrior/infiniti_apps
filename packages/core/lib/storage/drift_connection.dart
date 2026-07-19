import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

import 'app_paths.dart';

/// Opens a lazily-initialized native sqlite connection for a Drift database.
/// Each app's `@DriftDatabase` class should pass this to its constructor:
///
/// ```dart
/// @DriftDatabase(tables: [...])
/// class AppDatabase extends _$AppDatabase {
///   AppDatabase() : super(openAppConnection('app_name.sqlite'));
/// }
/// ```
LazyDatabase openAppConnection(String fileName) {
  return LazyDatabase(() async {
    await applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
    final path = await AppPaths.databasePath(fileName);
    return NativeDatabase.createInBackground(File(path));
  });
}
