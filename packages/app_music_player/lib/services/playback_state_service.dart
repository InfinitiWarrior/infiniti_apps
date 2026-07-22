import 'package:shared_preferences/shared_preferences.dart';

import 'repeat_mode.dart';

/// Small wrapper around [SharedPreferences] for shuffle/repeat preferences.
/// Not sensitive data, so plain prefs (rather than core's encrypted
/// [SecureStorageService]) is the right fit here.
class PlaybackStateService {
  static const _shuffleKey = 'shuffle_enabled';
  static const _repeatKey = 'repeat_mode';

  Future<bool> getShuffleEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_shuffleKey) ?? false;
  }

  Future<void> setShuffleEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_shuffleKey, enabled);
  }

  Future<PlayerRepeatMode> getRepeatMode() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString(_repeatKey);
    return name == null ? PlayerRepeatMode.off : PlayerRepeatMode.fromName(name);
  }

  Future<void> setRepeatMode(PlayerRepeatMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_repeatKey, mode.name);
  }
}
