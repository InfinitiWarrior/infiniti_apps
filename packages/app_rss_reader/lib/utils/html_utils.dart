final _tagPattern = RegExp(r'<[^>]*>');
final _whitespacePattern = RegExp(r'[ \t]+');
final _blankLinesPattern = RegExp(r'\n\s*\n+');

/// Strips HTML tags for plain-text display. Feed content/summaries are
/// frequently HTML fragments; this app has no HTML renderer, so article
/// bodies are shown as readable plain text instead.
String stripHtml(String html) {
  final withBreaks = html
      .replaceAll(RegExp(r'<br\s*/?>', caseSensitive: false), '\n')
      .replaceAll(RegExp(r'</p>', caseSensitive: false), '\n\n');
  final withoutTags = withBreaks.replaceAll(_tagPattern, '');
  final unescaped = withoutTags
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#39;', "'")
      .replaceAll('&nbsp;', ' ');
  return unescaped
      .replaceAll(_whitespacePattern, ' ')
      .replaceAll(_blankLinesPattern, '\n\n')
      .trim();
}
