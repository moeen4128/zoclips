import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/create_clips/data/models/video_source_metadata_model.dart';

void main() {
  test('parses a real POST /videos/metadata response', () {
    final model = VideoSourceMetadataModel.fromJson({
      'title':
          'Nashtar | Full OST  | Shani Arshad | Ft. Danish Taimoor | '
          'Anmol Baloch #shortsfeed',
      'thumbnail_url': 'https://i.ytimg.com/vi/6Fo2-YXzMNM/maxresdefault.jpg',
      'author_name': 'Narm Edits',
      'provider_name': 'Youtube',
      'duration_seconds': 8.0,
    });

    expect(model.title, contains('Nashtar'));
    expect(model.authorName, 'Narm Edits');
    expect(model.providerName, 'Youtube');
    expect(model.durationSeconds, 8.0);
  });

  test('falls back to Untitled when title is missing', () {
    final model = VideoSourceMetadataModel.fromJson({'duration_seconds': 0});
    expect(model.title, 'Untitled');
    expect(model.thumbnailUrl, isNull);
  });
}
