/// Mirrors an entry from `GET /api/v1/videos/languages`.
class LanguageModel {
  final String code;
  final String englishName;
  final String nativeName;

  const LanguageModel({
    required this.code,
    required this.englishName,
    required this.nativeName,
  });

  factory LanguageModel.fromJson(Map<String, dynamic> json) {
    return LanguageModel(
      code: json['code'] as String,
      englishName: json['english_name'] as String,
      nativeName: json['native_name'] as String,
    );
  }
}
