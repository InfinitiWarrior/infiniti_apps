import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper around permission_handler so apps request only what they
/// need, with a consistent "denied forever -> send to settings" path.
abstract final class PermissionHelpers {
  /// Requests [permission] if not already granted. Returns true if granted.
  static Future<bool> request(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    final result = await permission.request();
    return result.isGranted;
  }

  static Future<bool> isPermanentlyDenied(Permission permission) async {
    return (await permission.status).isPermanentlyDenied;
  }

  static Future<bool> openSettings() => openAppSettings();
}
