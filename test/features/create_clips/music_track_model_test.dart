import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/create_clips/data/models/music_track_model.dart';

void main() {
  test('parses a real GET /music-library entry', () {
    final track = MusicTrackModel.fromJson({
      'id': '507de722-c96a-493a-be2f-b5f683665f1c',
      'title': '"Golden Rays" actual 1928 song sample chop',
      'artist': 'coruscate',
      'duration_seconds': 190.0,
      'preview_url':
          'https://example.r2.cloudflarestorage.com/viralclip/'
          'music-library/70070.mp3?X-Amz-Signature=abc',
      'license_name': 'Attribution (3.0)',
      'license_url': 'http://creativecommons.org/licenses/by/3.0/',
    });

    expect(track.id, '507de722-c96a-493a-be2f-b5f683665f1c');
    expect(track.artist, 'coruscate');
    expect(track.licenseName, 'Attribution (3.0)');
    expect(track.formattedDuration, '3:10');
  });

  test('tolerates a missing license_url', () {
    final track = MusicTrackModel.fromJson({
      'id': 't1',
      'title': 'ARK',
      'artist': 'zikweb',
      'duration_seconds': 69.0,
      'preview_url': 'https://example.com/69.mp3',
      'license_name': 'Attribution',
    });

    expect(track.licenseUrl, isNull);
    expect(track.formattedDuration, '1:09');
  });
}
