import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/calendar/data/models/video_scheduling_summary_model.dart';

void main() {
  test('parses a real GET /videos/scheduling-summary entry', () {
    final video = VideoSchedulingSummaryModel.fromJson({
      'video_id': '22e9e744-4982-4009-834d-291fd0047c68',
      'title':
          'Wonder Woman 1984 | Young Diana Takes on The Amazon Games | '
          'Warner Bros. Entertainment',
      'thumbnail_url':
          'https://i.ytimg.com/vi_webp/u1NlmFa0-68/maxresdefault.webp',
      'total_clips': 2,
      'published_clips': 1,
    });

    expect(video.videoId, '22e9e744-4982-4009-834d-291fd0047c68');
    expect(video.totalClips, 2);
    expect(video.publishedClips, 1);
    expect(video.thumbnailUrl, isNotNull);
  });

  test('falls back to Untitled when title is missing', () {
    final video = VideoSchedulingSummaryModel.fromJson({
      'video_id': 'v1',
      'total_clips': 0,
      'published_clips': 0,
    });

    expect(video.title, 'Untitled');
    expect(video.thumbnailUrl, isNull);
  });
}
