import 'package:app_rss_reader/database/rss_database.dart';
import 'package:app_rss_reader/repositories/feed_repository.dart';
import 'package:app_rss_reader/screens/home_screen.dart';
import 'package:core/core.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const _feedXml = '''
<rss version="2.0">
  <channel>
    <title>Example Blog</title>
    <item>
      <title>First Post</title>
      <link>https://example.com/first-post</link>
      <guid>https://example.com/first-post</guid>
      <description>desc</description>
      <pubDate>Mon, 01 Jan 2024 12:00:00 GMT</pubDate>
    </item>
  </channel>
</rss>
''';

void main() {
  testWidgets('shows the empty state with no feeds', (tester) async {
    final database = RssDatabase.forTesting(NativeDatabase.memory());
    final client = MockClient((request) async => http.Response(_feedXml, 200));
    final repository = FeedRepository(database, httpClient: client);

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: HomeScreen(repository: repository)),
    );
    await tester.pump();

    expect(find.text('No feeds yet. Open the menu to add one.'), findsOneWidget);

    repository.dispose();
    await database.close();
  });

  testWidgets('shows articles once a feed has been added', (tester) async {
    final database = RssDatabase.forTesting(NativeDatabase.memory());
    final client = MockClient((request) async => http.Response(_feedXml, 200));
    final repository = FeedRepository(database, httpClient: client);
    await repository.addFeed('https://example.com/feed.xml');

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.dark, home: HomeScreen(repository: repository)),
    );
    await tester.pump();

    expect(find.text('First Post'), findsOneWidget);
    expect(find.text('All Articles'), findsOneWidget);

    repository.dispose();
    await database.close();
  });
}
