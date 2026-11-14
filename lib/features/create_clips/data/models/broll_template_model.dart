/// Mirrors `GET /api/v1/broll/template` — only the fields the create-clips
/// workflow needs to decide whether the "B-Roll Overlay" toggle can be
/// switched on (the rest of the template's own styling fields are edited on
/// the B-Roll page, not here).
class BrollTemplateModel {
  final bool enabled;
  final String? activeAsset;

  const BrollTemplateModel({required this.enabled, this.activeAsset});

  factory BrollTemplateModel.fromJson(Map<String, dynamic> json) {
    return BrollTemplateModel(
      enabled: json['enabled'] as bool? ?? false,
      activeAsset: json['active_asset'] as String?,
    );
  }
}
