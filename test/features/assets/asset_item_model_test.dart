import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/assets/data/models/asset_item_model.dart';

void main() {
  test('parses a real item from GET /videos/assets', () {
    final json = {
      'render_job_id': 'e842bdfd-b673-4c6b-a523-6a981cda449c',
      'video_id': '22e9e744-4982-4009-834d-291fd0047c68',
      'clip_id': 'f86312b9-a75c-42dd-88d0-8b9db2a182fc',
      'title': 'The Truth of Victory',
      'category': 'Motivational',
      'duration_seconds': 32.32,
      'output_url': 'https://example.com/clip.mp4',
      'video_title':
          'Wonder Woman 1984 | Young Diana Takes on The Amazon Games | '
          'Warner Bros. Entertainment',
      'video_thumbnail_url':
          'https://i.ytimg.com/vi_webp/u1NlmFa0-68/maxresdefault.webp',
      'thumbnail_url': 'https://example.com/clip_thumb.jpg',
      'completed_at': '2026-08-14T16:59:47.647151Z',
      'created_at': '2026-08-14T16:45:10.147347Z',
    };

    final item = AssetItemModel.fromJson(json);

    expect(item.videoId, '22e9e744-4982-4009-834d-291fd0047c68');
    expect(item.clipId, 'f86312b9-a75c-42dd-88d0-8b9db2a182fc');
    expect(item.title, 'The Truth of Victory');
    expect(item.category, 'Motivational');
    expect(item.durationSeconds, 32); // truncated from 32.32
    expect(item.outputUrl, 'https://example.com/clip.mp4');
    expect(item.thumbnailUrl, 'https://example.com/clip_thumb.jpg');
    expect(item.completedAt, isNotNull);
  });

  test('tolerates a null thumbnail_url (still processing)', () {
    final item = AssetItemModel.fromJson({
      'render_job_id': 'r1',
      'video_id': 'v1',
      'clip_id': 'c1',
      'title': 'Clip',
      'category': 'social impact',
      'duration_seconds': 12.16,
      'output_url': 'https://example.com/clip.mp4',
      'video_title': 'Source video',
      'video_thumbnail_url': 'https://example.com/video_thumb.jpg',
      'thumbnail_url': null,
      'completed_at': '2026-07-11T21:43:02.893522Z',
      'created_at': '2026-07-11T21:41:36.995769Z',
    });

    expect(item.thumbnailUrl, isNull);
    expect(item.videoThumbnailUrl, 'https://example.com/video_thumb.jpg');
  });

  test('parses the paginated envelope', () {
    final page = AssetsPageModel.fromJson({
      'items': [
        {
          'render_job_id': 'r1',
          'video_id': 'v1',
          'clip_id': 'c1',
          'title': 'Clip',
          'category': 'motivation',
          'duration_seconds': 10,
          'video_title': 'Source',
          'created_at': '2026-07-11T21:41:36.995769Z',
        },
      ],
      'total': 31,
      'page': 1,
      'page_size': 12,
    });

    expect(page.items, hasLength(1));
    expect(page.total, 31);
    expect(page.page, 1);
    expect(page.pageSize, 12);
  });
}
