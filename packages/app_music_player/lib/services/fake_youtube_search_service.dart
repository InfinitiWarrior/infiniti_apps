import 'youtube_search_service.dart';

class FakeYoutubeSearchService implements YoutubeSearchService {
  @override
  Future<List<YoutubeSearchResult>> search(String query) async {
    if (query.trim().isEmpty) return [];
    return [
      YoutubeSearchResult(
        videoId: 'fake_video_1',
        title: '$query (Official Audio)',
        channelTitle: 'Fake Channel',
        duration: const Duration(minutes: 3, seconds: 30),
        thumbnailUrl: 'https://img.youtube.com/vi/fake_video_1/mqdefault.jpg',
      ),
      YoutubeSearchResult(
        videoId: 'fake_video_2',
        title: '$query (Live Performance)',
        channelTitle: 'Another Fake Channel',
        duration: const Duration(minutes: 4, seconds: 12),
        thumbnailUrl: 'https://img.youtube.com/vi/fake_video_2/mqdefault.jpg',
      ),
    ];
  }
}
