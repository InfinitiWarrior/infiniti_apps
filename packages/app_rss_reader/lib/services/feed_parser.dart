import 'package:dart_rss/dart_rss.dart';
import 'package:intl/intl.dart';

class ParsedArticle {
  const ParsedArticle({
    required this.guid,
    required this.title,
    this.link,
    this.summary,
    this.content,
    this.author,
    this.publishedAt,
  });

  final String guid;
  final String title;
  final String? link;
  final String? summary;
  final String? content;
  final String? author;
  final DateTime? publishedAt;
}

class ParsedFeed {
  const ParsedFeed({required this.title, required this.articles});

  final String title;
  final List<ParsedArticle> articles;
}

/// Parses raw RSS or Atom XML into a feed-format-agnostic [ParsedFeed].
/// Tries RSS 2.0 first (the common case), then falls back to Atom.
ParsedFeed parseFeedXml(String xmlBody) {
  try {
    final rss = RssFeed.parse(xmlBody);
    return ParsedFeed(
      title: rss.title?.trim().isNotEmpty == true ? rss.title!.trim() : 'Untitled feed',
      articles: rss.items.map((item) {
        final guid = item.guid ?? item.link ?? item.title ?? item.pubDate ?? '';
        return ParsedArticle(
          guid: guid,
          title: item.title?.trim().isNotEmpty == true ? item.title!.trim() : 'Untitled',
          link: item.link,
          summary: item.description,
          content: item.content?.value,
          author: item.author ?? item.dc?.creator,
          publishedAt: _parseDate(item.pubDate),
        );
      }).toList(),
    );
  } on ArgumentError {
    final atom = AtomFeed.parse(xmlBody);
    return ParsedFeed(
      title: atom.title?.trim().isNotEmpty == true ? atom.title!.trim() : 'Untitled feed',
      articles: atom.items.map((item) {
        final link = item.links.isNotEmpty ? item.links.first.href : null;
        final guid = item.id ?? link ?? item.title ?? item.published ?? '';
        return ParsedArticle(
          guid: guid,
          title: item.title?.trim().isNotEmpty == true ? item.title!.trim() : 'Untitled',
          link: link,
          summary: item.summary,
          content: item.content,
          author: item.authors.isNotEmpty ? item.authors.first.name : null,
          publishedAt: _parseDate(item.published ?? item.updated),
        );
      }).toList(),
    );
  }
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final trimmed = raw.trim();
  final direct = DateTime.tryParse(trimmed);
  if (direct != null) return direct;
  const patterns = [
    'EEE, d MMM yyyy HH:mm:ss Z',
    'EEE, d MMM yyyy HH:mm:ss zzz',
    'd MMM yyyy HH:mm:ss Z',
  ];
  for (final pattern in patterns) {
    try {
      return DateFormat(pattern, 'en_US').parseUtc(trimmed);
    } catch (_) {
      // try next pattern
    }
  }
  return null;
}
