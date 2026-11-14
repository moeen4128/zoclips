import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/create_clips/data/models/broll_template_model.dart';

void main() {
  test('parses a real GET /broll/template response', () {
    final template = BrollTemplateModel.fromJson({
      'id': '18991d1a-d7d0-44ba-8a14-f38ebed29b76',
      'enabled': false,
      'active_asset': null,
      'position': 'bottom-right',
      'size_preset': 'medium',
      'updated_at': '2026-07-16T20:43:25.260158Z',
    });

    expect(template.enabled, isFalse);
    expect(template.activeAsset, isNull);
  });

  test('tolerates a missing enabled flag by defaulting to false', () {
    final template = BrollTemplateModel.fromJson(const {});
    expect(template.enabled, isFalse);
  });
}
