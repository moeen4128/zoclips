import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/assets/data/models/subscription_model.dart';

void main() {
  test('parses the exact /subscription/me example', () {
    final subscription = SubscriptionModel.fromJson({
      'plan': {
        'id': '1c246704-9661-4f0a-a8d5-72a5df3a4fda',
        'name': 'Business',
        'slug': 'business',
        'max_storage_gb': 200.0,
        'monthly_credits': 10000,
      },
      'status': 'active',
      'interval': 'lifetime',
      'current_period_start': '2026-09-08T10:18:02.577283Z',
      'current_period_end': null,
      'credit_balance': 10088,
      'credits_used_this_period': 0,
    });

    expect(subscription.planName, 'Business');
    expect(subscription.maxStorageGb, 200.0);
    expect(subscription.creditBalance, 10088);
  });
}
