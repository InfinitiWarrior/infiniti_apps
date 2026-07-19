import 'package:shared_preferences/shared_preferences.dart';

import 'recording_format.dart';

/// Small wrapper around [SharedPreferences] for this app's non-sensitive
/// settings. Recording format isn't secret, so plain prefs (rather than
/// core's encrypted [SecureStorageService]) is the right fit here.
class SettingsService {
  static const _formatKey = 'recording_format';

  Future<RecordingFormat> getFormat() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_formatKey);
    return name == null ? RecordingFormat.aac : RecordingFormat.fromName(name);
  }

  Future<void> setFormat(RecordingFormat format) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_formatKey, format.name);
  }
}
