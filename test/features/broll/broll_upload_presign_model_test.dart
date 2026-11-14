import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/broll/data/models/broll_upload_presign_model.dart';

void main() {
  test('parses a real POST /broll/assets/uploads/presign response', () {
    final presign = BrollUploadPresignModel.fromJson({
      'upload_url':
          'https://example.r2.cloudflarestorage.com/viralclip/broll/'
          'user-1/519a8dfe-fiverr_profile.webp?X-Amz-Signature=abc',
      'storage_key': 'broll/user-1/519a8dfe-fiverr_profile.webp',
      'expires_in': 3600,
    });

    expect(presign.storageKey, 'broll/user-1/519a8dfe-fiverr_profile.webp');
    expect(presign.expiresIn, 3600);
    expect(presign.uploadUrl, contains('X-Amz-Signature'));
  });
}
