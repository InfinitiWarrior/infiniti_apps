import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local storage path helpers shared by every app.
abstract final class AppPaths {
  /// Directory for app-private files not meant to be user-visible
  /// (databases, caches).
  static Future<String> supportDirectory() async {
    final dir = await getApplicationSupportDirectory();
    return dir.path;
  }

  /// Directory for user-facing files (recordings, downloads, exports).
  static Future<String> documentsDirectory() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  /// Path to a named sqlite database file inside the support directory.
  static Future<String> databasePath(String fileName) async {
    final dir = await supportDirectory();
    return p.join(dir, fileName);
  }
}
