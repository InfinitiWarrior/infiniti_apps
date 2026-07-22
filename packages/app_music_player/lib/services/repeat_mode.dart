enum PlayerRepeatMode {
  off,
  all,
  one;

  static PlayerRepeatMode fromName(String name) {
    return PlayerRepeatMode.values.firstWhere(
      (mode) => mode.name == name,
      orElse: () => PlayerRepeatMode.off,
    );
  }
}
