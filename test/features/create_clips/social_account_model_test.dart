import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/create_clips/data/models/social_account_model.dart';

void main() {
  test('parses a real GET /social-accounts entry', () {
    final account = SocialAccountModel.fromJson({
      'id': '33512a93-fce8-45ec-abc7-8a6af3c48d48',
      'platform': 'youtube',
      'platform_user_id': 'UCyVscw4w-OTk5QbCSHIkE_A',
      'handle': '@nocommentary-lo7wg',
      'channel_name': 'No commentary',
      'subscribers': 13,
      'connected_at': '2026-10-01T14:02:41.625258Z',
    });

    expect(account.platform, 'youtube');
    expect(account.channelName, 'No commentary');
    expect(account.handle, '@nocommentary-lo7wg');
  });
}
