import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/clips/data/models/clip_metadata_model.dart';

void main() {
  test('parses the exact /metadata example from the Swagger docs', () {
    final json = {
      'id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      'clip_candidate_id': '3fa85f64-5717-4562-b3fc-2c963f66afa6',
      'status': 'pending',
      'error_message': 'string',
      'title': 'string',
      'description': 'string',
      'hashtags': ['string'],
      'created_at': '2026-10-01T13:34:57.156Z',
      'updated_at': '2026-10-01T13:34:57.156Z',
    };

    final metadata = ClipMetadataModel.fromJson(json);

    expect(metadata.status, 'pending');
    expect(metadata.title, 'string');
    expect(metadata.description, 'string');
    expect(metadata.hashtags, ['string']);
    expect(metadata.hasContent, isTrue);
  });

  test('hasContent is false when nothing has been generated yet', () {
    final metadata = ClipMetadataModel.fromJson({
      'status': 'pending',
      'title': null,
      'description': null,
      'hashtags': <String>[],
    });

    expect(metadata.hasContent, isFalse);
  });
}
