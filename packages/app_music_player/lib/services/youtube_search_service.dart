import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt;

/// youtube_explode_dart's HTTP calls have no built-in timeout — a stalled
/// connection hangs forever rather than throwing, which otherwise leaves the
/// search screen stuck on its loading spinner with no error.
const _searchTimeout = Duration(seconds: 20);

class YoutubeSearchResult {
  YoutubeSearchResult({
    required this.videoId,
    required this.title,
    required this.channelTitle,
    required this.duration,
    required this.thumbnailUrl,
  });

  final String videoId;
  final String title;
  final String channelTitle;
  final Duration? duration;
  final String thumbnailUrl;
}

/// YouTube video search. Abstracted so widget tests and Linux dev iteration
/// never make a real network call.
abstract class YoutubeSearchService {
  Future<List<YoutubeSearchResult>> search(String query);
}

class PlatformYoutubeSearchService implements YoutubeSearchService {
  PlatformYoutubeSearchService() : _client = yt.YoutubeExplode();

  final yt.YoutubeExplode _client;

  @override
  Future<List<YoutubeSearchResult>> search(String query) async {
    final results = await _client.search.search(query).timeout(_searchTimeout);
    return results
        .map(
          (video) => YoutubeSearchResult(
            videoId: video.id.value,
            title: video.title,
            channelTitle: video.author,
            duration: video.duration,
            thumbnailUrl: video.thumbnails.mediumResUrl,
          ),
        )
        .toList();
  }
}
