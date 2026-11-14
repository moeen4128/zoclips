import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/clips/data/models/clip_model.dart';

void main() {
  test('parses the exact ClipCandidateRead example from the Swagger docs', () {
    final json = {
      'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      'start_segment': 0,
      'end_segment': 0,
      'start_seconds': 0,
      'end_seconds': 0,
      'duration_seconds': 0,
      'title': 'string',
      'category': 'string',
      'llm_metadata': {'additionalProp1': {}},
      'score': 0,
      'rank': 0,
    };

    final clip = ClipModel.fromJson(json);

    expect(clip.id, '3fa85f64-5717-4562-b3fc-2c963f66afa6');
    expect(clip.title, 'string');
    expect(clip.category, 'string');
    expect(clip.score, 0);
    expect(clip.rank, 0);
    expect(clip.durationSeconds, 0);
  });

  test('falls back to a friendly title when the API returns an empty one', () {
    final clip = ClipModel.fromJson({
      'id': 'abc',
      'title': '',
      'category': 'motivational',
      'duration_seconds': 32,
      'score': 70,
      'rank': 1,
    });

    expect(clip.title, 'Untitled clip');
    expect(clip.durationSeconds, 32);
  });
}
