import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/assets/data/models/storage_usage_model.dart';

void main() {
  test('parses the exact /videos/storage-usage example', () {
    final usage = StorageUsageModel.fromJson({
      'source_videos_bytes': 0,
      'rendered_clips_bytes': 59659044,
      'thumbnails_bytes': 573786,
      'caption_cache_bytes': 0,
      'cleaned_audio_bytes': 0,
      'broll_bytes': 0,
      'total_bytes': 60232830,
    });

    expect(usage.sourceVideosBytes, 0);
    expect(usage.renderedClipsBytes, 59659044);
    expect(usage.thumbnailsBytes, 573786);
    expect(usage.totalBytes, 60232830);
  });
}
