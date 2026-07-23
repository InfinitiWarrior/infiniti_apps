enum DownloadFormat {
  mp3,
  mp4;

  static DownloadFormat fromName(String name) {
    return DownloadFormat.values.firstWhere((format) => format.name == name);
  }
}
