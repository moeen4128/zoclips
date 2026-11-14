import 'package:flutter_test/flutter_test.dart';
import 'package:zoclips/features/create_clips/data/models/language_model.dart';

void main() {
  test('parses a real GET /videos/languages entry', () {
    final language = LanguageModel.fromJson({
      'code': 'ur',
      'english_name': 'Urdu',
      'native_name': 'اردو',
    });

    expect(language.code, 'ur');
    expect(language.englishName, 'Urdu');
    expect(language.nativeName, 'اردو');
  });
}
